// supabase/functions/invite-admin/index.ts
// Invite a new admin/superadmin user by email.
// Only callable by existing superadmins.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders } from '../_shared/cors.ts'

const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // ── 1. Verify caller JWT ──────────────────────────────────────────────
    const authHeader = req.headers.get('Authorization')
    if (!authHeader?.startsWith('Bearer ')) {
      return new Response(
        JSON.stringify({ error: 'Missing or invalid Authorization header' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      )
    }

    const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey, {
      auth: { autoRefreshToken: false, persistSession: false },
    })

    const token = authHeader.slice(7)
    const { data: { user }, error: authError } = await supabaseAdmin.auth.getUser(token)

    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: 'Invalid or expired token' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      )
    }

    // ── 2. Check caller is superadmin ─────────────────────────────────────
    if (user.app_metadata?.role !== 'superadmin') {
      return new Response(
        JSON.stringify({ error: 'Only superadmins can invite users' }),
        { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      )
    }

    // ── 3. Validate request body ──────────────────────────────────────────
    let body: { email?: unknown; role?: unknown }
    try {
      body = await req.json()
    } catch {
      return new Response(
        JSON.stringify({ error: 'Invalid JSON body' }),
        { status: 422, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      )
    }

    const { email, role } = body

    if (!email || typeof email !== 'string' || !email.includes('@')) {
      return new Response(
        JSON.stringify({ error: 'Valid email is required', field: 'email' }),
        { status: 422, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      )
    }

    const inviteRole = role === 'superadmin' ? 'superadmin' : 'admin'

    // ── 4. Build redirect URL from the request origin ─────────────────────
    const origin = req.headers.get('origin') ?? req.headers.get('referer')?.replace(/\/$/, '') ?? ''
    const redirectTo = origin ? `${origin}/accept-invite` : undefined

    // ── 5. Send the invite email ───────────────────────────────────────────
    const { data: inviteData, error: inviteError } = await supabaseAdmin.auth.admin.inviteUserByEmail(
      email.trim().toLowerCase(),
      { redirectTo },
    )

    if (inviteError) {
      return new Response(
        JSON.stringify({ error: inviteError.message }),
        { status: 422, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      )
    }

    // ── 6. Set app_metadata.role so the user gets the right permissions ───
    if (inviteData?.user?.id) {
      const { error: updateError } = await supabaseAdmin.auth.admin.updateUserById(
        inviteData.user.id,
        { app_metadata: { role: inviteRole } },
      )
      if (updateError) {
        console.error('[invite-admin] Failed to set role:', updateError.message)
      }

      // Also insert profile row in case trigger hasn't fired yet
      await supabaseAdmin.from('profiles').upsert({
        id: inviteData.user.id,
        full_name: email.split('@')[0],
        role: inviteRole,
      }, { onConflict: 'id' })
    }

    return new Response(
      JSON.stringify({ success: true }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    )
  } catch (err) {
    console.error('[invite-admin] Unexpected error:', err)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    )
  }
})
