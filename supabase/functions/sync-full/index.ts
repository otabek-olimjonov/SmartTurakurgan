// supabase/functions/sync-full/index.ts

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { handleCors, jsonResponse } from '../_shared/cors.ts'
import { verifyJWT } from '../_shared/auth.ts'

serve(async (req: Request) => {
  // CORS preflight
  const corsResponse = handleCors(req)
  if (corsResponse) return corsResponse

  if (req.method !== 'GET') {
    return jsonResponse({ error: 'Method not allowed' }, 405)
  }

  // Require authentication
  let _payload
  try {
    _payload = await verifyJWT(req)
  } catch (res) {
    return res as Response
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    // Fetch all published content in parallel
    const [
      rahbariyatResult,
      mahallalarResult,
      mahalla_xodimlariResult,
      yer_maydonlariResult,
      placesResult,
      place_imagesResult,
      yangilikResult,
    ] = await Promise.all([
      supabase
        .from('rahbariyat')
        .select('*')
        .eq('is_published', true)
        .order('sort_order', { ascending: true }),

      supabase
        .from('mahallalar')
        .select('*')
        .eq('is_published', true)
        .order('name', { ascending: true }),

      supabase
        .from('mahalla_xodimlari')
        .select('*')
        .order('sort_order', { ascending: true }),

      supabase
        .from('yer_maydonlari')
        .select('*')
        .eq('is_published', true)
        .order('updated_at', { ascending: false }),

      supabase
        .from('places')
        .select('*')
        .eq('is_published', true)
        .order('name', { ascending: true }),

      supabase
        .from('place_images')
        .select('*')
        .order('sort_order', { ascending: true }),

      supabase
        .from('yangiliklar')
        .select('*')
        .eq('is_published', true)
        .order('published_at', { ascending: false })
        .limit(50),
    ])

    // Check for errors
    const errors = [
      rahbariyatResult.error,
      mahallalarResult.error,
      mahalla_xodimlariResult.error,
      yer_maydonlariResult.error,
      placesResult.error,
      place_imagesResult.error,
      yangilikResult.error,
    ].filter(Boolean)

    if (errors.length > 0) {
      console.error('[sync-full] DB errors:', errors)
      return jsonResponse({ error: 'Failed to fetch data' }, 500)
    }

    return jsonResponse({
      rahbariyat:        rahbariyatResult.data        ?? [],
      mahallalar:        mahallalarResult.data        ?? [],
      mahalla_xodimlari: mahalla_xodimlariResult.data ?? [],
      yer_maydonlari:    yer_maydonlariResult.data    ?? [],
      places:            placesResult.data            ?? [],
      place_images:      place_imagesResult.data      ?? [],
      yangiliklar:       yangilikResult.data          ?? [],
      synced_at:         new Date().toISOString(),
    })
  } catch (err) {
    console.error('[sync-full] Unexpected error:', err)
    return jsonResponse({ error: 'Internal server error' }, 500)
  }
})
