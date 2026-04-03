// supabase/functions/submit-murojaat/index.ts

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { handleCors, jsonResponse } from '../_shared/cors.ts'
import { verifyJWT } from '../_shared/auth.ts'

interface MurojaatRequest {
  full_name: string
  phone:     string
  address:   string
  message:   string
}

const RATE_LIMIT_MAX        = 5
const RATE_LIMIT_WINDOW_HRS = 24

serve(async (req: Request) => {
  // CORS preflight
  const corsResponse = handleCors(req)
  if (corsResponse) return corsResponse

  if (req.method !== 'POST') {
    return jsonResponse({ error: 'Method not allowed' }, 405)
  }

  // Require authentication
  let payload
  try {
    payload = await verifyJWT(req)
  } catch (res) {
    return res as Response
  }

  try {
    let body: MurojaatRequest
    try {
      body = await req.json()
    } catch {
      return jsonResponse({ error: 'Invalid JSON body' }, 422)
    }

    // Validate all required fields
    const { full_name, phone, address, message } = body

    if (!full_name || full_name.trim() === '') {
      return jsonResponse({ error: 'full_name is required', field: 'full_name' }, 422)
    }
    if (!phone || phone.trim() === '') {
      return jsonResponse({ error: 'phone is required', field: 'phone' }, 422)
    }
    if (!address || address.trim() === '') {
      return jsonResponse({ error: 'address is required', field: 'address' }, 422)
    }
    if (!message || message.trim() === '') {
      return jsonResponse({ error: 'message is required', field: 'message' }, 422)
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    // Rate limit: max 5 submissions per user in the last 24 hours
    const windowStart = new Date(
      Date.now() - RATE_LIMIT_WINDOW_HRS * 60 * 60 * 1000,
    ).toISOString()

    const { count, error: countError } = await supabase
      .from('murojaatlar')
      .select('id', { count: 'exact', head: true })
      .eq('user_id', payload.sub)
      .gte('created_at', windowStart)

    if (countError) {
      console.error('[submit-murojaat] Rate limit check failed:', countError)
      return jsonResponse({ error: 'Internal server error' }, 500)
    }

    if ((count ?? 0) >= RATE_LIMIT_MAX) {
      return jsonResponse(
        {
          error: `Kuniga ${RATE_LIMIT_MAX} tadan ko'p murojaat yuborib bo'lmaydi. ` +
                 `Iltimos, ertaga qaytadan urinib ko'ring.`,
        },
        429,
      )
    }

    // Insert the appeal
    const { data, error: insertError } = await supabase
      .from('murojaatlar')
      .insert({
        user_id:   payload.sub,
        full_name: full_name.trim(),
        phone:     phone.trim(),
        address:   address.trim(),
        message:   message.trim(),
        status:    'pending',
      })
      .select('id, status, created_at')
      .single()

    if (insertError || !data) {
      console.error('[submit-murojaat] Insert failed:', insertError)
      return jsonResponse({ error: 'Failed to submit appeal' }, 500)
    }

    return jsonResponse({
      id:         data.id,
      status:     data.status,
      created_at: data.created_at,
    })
  } catch (err) {
    console.error('[submit-murojaat] Unexpected error:', err)
    return jsonResponse({ error: 'Internal server error' }, 500)
  }
})
