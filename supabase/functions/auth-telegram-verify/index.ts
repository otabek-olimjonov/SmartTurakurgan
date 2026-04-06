// supabase/functions/auth-telegram-verify/index.ts

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { handleCors, jsonResponse } from '../_shared/cors.ts'
import { issueJWT } from '../_shared/auth.ts'

serve(async (req: Request) => {
  // CORS preflight
  const corsResponse = handleCors(req)
  if (corsResponse) return corsResponse

  if (req.method !== 'GET') {
    return jsonResponse({ error: 'Method not allowed' }, 405)
  }

  try {
    const url = new URL(req.url)
    const token = url.searchParams.get('token')

    if (!token || token.trim() === '') {
      return jsonResponse({ error: 'token query parameter is required', field: 'token' }, 422)
    }

    // Basic UUID format check to avoid unnecessary DB queries
    const uuidRegex =
      /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i
    if (!uuidRegex.test(token)) {
      return jsonResponse({ error: 'expired' }, 404)
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    // Fetch the pending auth record
    const { data: authRecord, error } = await supabase
      .from('pending_auth')
      .select('id, confirmed, telegram_id, expires_at')
      .eq('token', token)
      .single()

    if (error || !authRecord) {
      return jsonResponse({ error: 'expired' }, 404)
    }

    // Check expiry
    if (new Date(authRecord.expires_at) < new Date()) {
      // Clean up expired record
      await supabase.from('pending_auth').delete().eq('token', token)
      return jsonResponse({ error: 'expired' }, 404)
    }

    // Not yet confirmed — mobile polls again
    if (!authRecord.confirmed) {
      return jsonResponse({ status: 'pending' }, 202)
    }

    // Confirmed — look up the user and issue a JWT
    const { data: user, error: userError } = await supabase
      .from('users')
      .select('id, telegram_id, role, full_name, phone_number')
      .eq('telegram_id', authRecord.telegram_id)
      .single()

    if (userError || !user) {
      console.error('[auth-telegram-verify] User lookup failed:', userError)
      return jsonResponse({ error: 'User not found' }, 500)
    }

    const jwt = await issueJWT({
      sub: user.id,
      telegram_id: user.telegram_id,
      role: user.role,
    })

    const isNewUser = !user.full_name

    // Clean up consumed token
    await supabase.from('pending_auth').delete().eq('token', token)

    return jsonResponse({
      jwt,
      user_id: user.id,
      role: user.role,
      is_new_user: isNewUser,
      full_name: user.full_name ?? null,
      phone_number: user.phone_number ?? null,
    })
  } catch (err) {
    console.error('[auth-telegram-verify] Unexpected error:', err)
    return jsonResponse({ error: 'Internal server error' }, 500)
  }
})
