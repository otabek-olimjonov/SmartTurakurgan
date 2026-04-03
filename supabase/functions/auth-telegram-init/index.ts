// supabase/functions/auth-telegram-init/index.ts

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { handleCors, jsonResponse } from '../_shared/cors.ts'

interface InitRequest {
  device_id: string
}

serve(async (req: Request) => {
  // CORS preflight
  const corsResponse = handleCors(req)
  if (corsResponse) return corsResponse

  if (req.method !== 'POST') {
    return jsonResponse({ error: 'Method not allowed' }, 405)
  }

  try {
    // Parse and validate body
    let body: InitRequest
    try {
      body = await req.json()
    } catch {
      return jsonResponse({ error: 'Invalid JSON body' }, 422)
    }

    const { device_id } = body
    if (!device_id || typeof device_id !== 'string' || device_id.trim() === '') {
      return jsonResponse({ error: 'device_id is required', field: 'device_id' }, 422)
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    // Invalidate any existing pending tokens for this device
    await supabase
      .from('pending_auth')
      .delete()
      .eq('device_id', device_id.trim())

    // Generate new token (uuid v4) and 5-minute expiry
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000).toISOString()

    const { data, error } = await supabase
      .from('pending_auth')
      .insert({
        device_id: device_id.trim(),
        expires_at: expiresAt,
        confirmed: false,
      })
      .select('token')
      .single()

    if (error || !data) {
      console.error('[auth-telegram-init] DB insert error:', error)
      return jsonResponse({ error: 'Failed to create auth token' }, 500)
    }

    const token: string = data.token
    const botUsername = Deno.env.get('TELEGRAM_BOT_USERNAME') ?? 'SmartTurakurganBot'
    const telegramUrl = `https://t.me/${botUsername}?start=${token}`

    return jsonResponse({ token, telegram_url: telegramUrl })
  } catch (err) {
    console.error('[auth-telegram-init] Unexpected error:', err)
    return jsonResponse({ error: 'Internal server error' }, 500)
  }
})
