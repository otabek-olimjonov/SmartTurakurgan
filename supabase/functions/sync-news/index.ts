// supabase/functions/sync-news/index.ts

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
  try {
    await verifyJWT(req)
  } catch (res) {
    return res as Response
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    const { data, error } = await supabase
      .from('yangiliklar')
      .select('*')
      .eq('is_published', true)
      .order('published_at', { ascending: false })
      .limit(20)

    if (error) {
      console.error('[sync-news] DB error:', error)
      return jsonResponse({ error: 'Failed to fetch news' }, 500)
    }

    const newsIds = (data ?? []).map((n: Record<string, unknown>) => n.id as string)
    let yangilik_images: unknown[] = []
    if (newsIds.length > 0) {
      const { data: imgData } = await supabase
        .from('yangilik_images')
        .select('*')
        .in('yangilik_id', newsIds)
        .order('sort_order', { ascending: true })
      yangilik_images = imgData ?? []
    }

    return jsonResponse({
      yangiliklar: data ?? [],
      yangilik_images,
      fetched_at:  new Date().toISOString(),
    })
  } catch (err) {
    console.error('[sync-news] Unexpected error:', err)
    return jsonResponse({ error: 'Internal server error' }, 500)
  }
})
