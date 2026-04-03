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
    let body: { email?: unknown; role?: unknown; temp_password?: unknown }
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

    if (!body.temp_password || typeof body.temp_password !== 'string' || (body.temp_password as string).length < 8) {
      return new Response(
        JSON.stringify({ error: 'temp_password must be at least 8 characters', field: 'temp_password' }),
        { status: 422, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      )
    }

    const inviteRole = role === 'superadmin' ? 'superadmin' : 'admin'
    const tempPassword = body.temp_password as string

    // ── 4. Create user with temp password (email confirmed immediately) ───
    const { data: createData, error: createError } = await supabaseAdmin.auth.admin.createUser({
      email: email.trim().toLowerCase(),
      password: tempPassword,
      email_confirm: true,
      app_metadata: { role: inviteRole },
    })

    if (createError) {
      return new Response(
        JSON.stringify({ error: createError.message }),
        { status: 422, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      )
    }

    // ── 5. Upsert profile row ─────────────────────────────────────────────
    if (createData?.user?.id) {
      await supabaseAdmin.from('profiles').upsert({
        id: createData.user.id,
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
