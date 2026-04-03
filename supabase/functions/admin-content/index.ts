// supabase/functions/admin-content/index.ts

import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { handleCors, jsonResponse } from '../_shared/cors.ts'
import { verifyJWT, requireAdmin } from '../_shared/auth.ts'

// Tables that admins are permitted to write to via this function.
// Never allow arbitrary table names from the request body.
const ALLOWED_TABLES = new Set([
  'rahbariyat',
  'mahallalar',
  'mahalla_xodimlari',
  'yer_maydonlari',
  'places',
  'place_images',
  'yangiliklar',
  'bildirishnomalar',
])

interface ContentRequest {
  table: string
  data?: Record<string, unknown>   // for POST / PUT
  id?:   string                    // for PUT / DELETE
}

serve(async (req: Request) => {
  // CORS preflight
  const corsResponse = handleCors(req)
  if (corsResponse) return corsResponse

  const method = req.method

  if (!['POST', 'PUT', 'DELETE'].includes(method)) {
    return jsonResponse({ error: 'Method not allowed' }, 405)
  }

  // Require authentication + admin role
  let payload
  try {
    payload = await verifyJWT(req)
  } catch (res) {
    return res as Response
  }

  try {
    requireAdmin(payload)
  } catch (res) {
    return res as Response
  }

  try {
    let body: ContentRequest
    try {
      body = await req.json()
    } catch {
      return jsonResponse({ error: 'Invalid JSON body' }, 422)
    }

    const { table, data, id } = body

    // Validate table name against whitelist
    if (!table || !ALLOWED_TABLES.has(table)) {
      return jsonResponse(
        { error: `Invalid or disallowed table: "${table}"`, field: 'table' },
        422,
      )
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    // ---- POST: Create a new record ----
    if (method === 'POST') {
      if (!data || typeof data !== 'object') {
        return jsonResponse({ error: 'data object is required for POST', field: 'data' }, 422)
      }

      const { data: created, error } = await supabase
        .from(table)
        .insert(sanitizeData(data))
        .select()
        .single()

      if (error) {
        console.error(`[admin-content] INSERT ${table} failed:`, error)
        return jsonResponse({ error: error.message }, 500)
      }

      return jsonResponse(created, 201)
    }

    // ---- PUT: Update an existing record ----
    if (method === 'PUT') {
      if (!id || typeof id !== 'string') {
        return jsonResponse({ error: 'id is required for PUT', field: 'id' }, 422)
      }
      if (!data || typeof data !== 'object') {
        return jsonResponse({ error: 'data object is required for PUT', field: 'data' }, 422)
      }

      // Prevent overwriting primary key or timestamps via client
      const safeData = sanitizeData(data)
      delete safeData['id']
      delete safeData['created_at']

      const { data: updated, error } = await supabase
        .from(table)
        .update(safeData)
        .eq('id', id)
        .select()
        .single()

      if (error) {
        console.error(`[admin-content] UPDATE ${table} id=${id} failed:`, error)
        return jsonResponse({ error: error.message }, 500)
      }

      if (!updated) {
        return jsonResponse({ error: 'Record not found' }, 404)
      }

      return jsonResponse(updated)
    }

    // ---- DELETE: Soft-delete by setting is_published = false ----
    if (method === 'DELETE') {
      if (!id || typeof id !== 'string') {
        return jsonResponse({ error: 'id is required for DELETE', field: 'id' }, 422)
      }

      // Tables without is_published are hard-deleted (e.g. place_images, mahalla_xodimlari)
      const softDeleteTables = new Set([
        'rahbariyat',
        'mahallalar',
        'yer_maydonlari',
        'places',
        'yangiliklar',
      ])

      if (softDeleteTables.has(table)) {
        const { data: deleted, error } = await supabase
          .from(table)
          .update({ is_published: false })
          .eq('id', id)
          .select('id, is_published')
          .single()

        if (error) {
          console.error(`[admin-content] SOFT DELETE ${table} id=${id} failed:`, error)
          return jsonResponse({ error: error.message }, 500)
        }

        if (!deleted) {
          return jsonResponse({ error: 'Record not found' }, 404)
        }

        return jsonResponse({ success: true, id, is_published: false })
      } else {
        // Hard delete for child tables (place_images, mahalla_xodimlari, bildirishnomalar)
        const { error } = await supabase
          .from(table)
          .delete()
          .eq('id', id)

        if (error) {
          console.error(`[admin-content] DELETE ${table} id=${id} failed:`, error)
          return jsonResponse({ error: error.message }, 500)
        }

        return jsonResponse({ success: true, id })
      }
    }

    return jsonResponse({ error: 'Unhandled method' }, 405)
  } catch (err) {
    console.error('[admin-content] Unexpected error:', err)
    return jsonResponse({ error: 'Internal server error' }, 500)
  }
})

/**
 * Strips any keys with null-prototype objects or function values
 * before inserting into the database.
 */
function sanitizeData(data: Record<string, unknown>): Record<string, unknown> {
  const result: Record<string, unknown> = {}
  for (const [key, value] of Object.entries(data)) {
    if (typeof value === 'function') continue
    if (typeof key !== 'string' || key.trim() === '') continue
    result[key] = value
  }
  return result
}
