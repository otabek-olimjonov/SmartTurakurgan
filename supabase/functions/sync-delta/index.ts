// supabase/functions/sync-delta/index.ts

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { handleCors, jsonResponse } from '../_shared/cors.ts'
import { verifyJWT } from '../_shared/auth.ts'

interface DeltaRequest {
  last_sync_at: string  // ISO 8601 timestamp
}

serve(async (req: Request) => {
  // CORS preflight
  const corsResponse = handleCors(req)
  if (corsResponse) return corsResponse

  if (req.method !== 'POST') {
    return jsonResponse({ error: 'Method not allowed' }, 405)
  }

  // Require authentication
  try {
    await verifyJWT(req)
  } catch (res) {
    return res as Response
  }

  try {
    let body: DeltaRequest
    try {
      body = await req.json()
    } catch {
      return jsonResponse({ error: 'Invalid JSON body' }, 422)
    }

    const { last_sync_at } = body

    if (!last_sync_at || typeof last_sync_at !== 'string') {
      return jsonResponse(
        { error: 'last_sync_at is required', field: 'last_sync_at' },
        422,
      )
    }

    // Validate it parses as a valid date
    const sinceDate = new Date(last_sync_at)
    if (isNaN(sinceDate.getTime())) {
      return jsonResponse(
        { error: 'last_sync_at must be a valid ISO 8601 date', field: 'last_sync_at' },
        422,
      )
    }

    const since = sinceDate.toISOString()

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    // Fetch only records changed since last_sync_at, in parallel
    const [
      rahbariyatResult,
      mahallalarResult,
      mahalla_xodimlariResult,
      yer_maydonlariResult,
      placesResult,
      place_imagesResult,
      yangilik_imagesResult,
    ] = await Promise.all([
      supabase
        .from('rahbariyat')
        .select('*')
        .eq('is_published', true)
        .gt('updated_at', since)
        .order('sort_order', { ascending: true }),

      supabase
        .from('mahallalar')
        .select('*')
        .eq('is_published', true)
        .gt('updated_at', since),

      supabase
        .from('mahalla_xodimlari')
        .select('*')
        .gt('updated_at', since),

      supabase
        .from('yer_maydonlari')
        .select('*')
        .eq('is_published', true)
        .gt('updated_at', since),

      supabase
        .from('places')
        .select('*')
        .eq('is_published', true)
        .gt('updated_at', since),

      supabase
        .from('place_images')
        .select('*')
        .gt('updated_at', since),

      supabase
        .from('yangilik_images')
        .select('*')
        .gt('updated_at', since),
    ])

    const errors = [
      rahbariyatResult.error,
      mahallalarResult.error,
      mahalla_xodimlariResult.error,
      yer_maydonlariResult.error,
      placesResult.error,
      place_imagesResult.error,
      yangilik_imagesResult.error,
    ].filter(Boolean)

    if (errors.length > 0) {
      console.error('[sync-delta] DB errors:', errors)
      return jsonResponse({ error: 'Failed to fetch data' }, 500)
    }

    return jsonResponse({
      rahbariyat:        rahbariyatResult.data        ?? [],
      mahallalar:        mahallalarResult.data        ?? [],
      mahalla_xodimlari: mahalla_xodimlariResult.data ?? [],
      yer_maydonlari:    yer_maydonlariResult.data    ?? [],
      places:            placesResult.data            ?? [],
      place_images:      place_imagesResult.data      ?? [],
      yangilik_images:   yangilik_imagesResult.data   ?? [],
      synced_at:         new Date().toISOString(),
    })
  } catch (err) {
    console.error('[sync-delta] Unexpected error:', err)
    return jsonResponse({ error: 'Internal server error' }, 500)
  }
})
