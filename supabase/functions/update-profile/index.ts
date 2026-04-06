// supabase/functions/update-profile/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { corsHeaders } from '../_shared/cors.ts'
import { verifyJWT } from '../_shared/auth.ts'

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders })
  }

  try {
    const payload = await verifyJWT(req)

    if (req.method !== 'PUT') {
      return new Response(JSON.stringify({ error: 'Method not allowed' }), {
        status: 405,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const body = await req.json()
    const fullName = (body.full_name ?? '').toString().trim()
    const phoneNumber = (body.phone_number ?? '').toString().trim()
    const address = (body.address ?? '').toString().trim()
    const photoUrl = (body.photo_url ?? '').toString().trim()

    if (body.full_name !== undefined && !fullName) {
      return new Response(JSON.stringify({ error: 'full_name cannot be empty', field: 'full_name' }), {
        status: 422,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    if (phoneNumber && !/^\+998\d{9}$/.test(phoneNumber.replace(/\s/g, ''))) {
      return new Response(
        JSON.stringify({ error: 'Invalid phone number format. Use +998XXXXXXXXX', field: 'phone_number' }),
        { status: 422, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      )
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    )

    const updates: Record<string, string> = { updated_at: new Date().toISOString() }
    if (fullName) updates.full_name = fullName
    if (phoneNumber) updates.phone_number = phoneNumber
    if (address) updates.address = address
    if (photoUrl) updates.photo_url = photoUrl

    const { error } = await supabase
      .from('users')
      .update(updates)
      .eq('id', payload.sub)

    if (error) throw error

    return new Response(JSON.stringify({ ok: true }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  } catch (err) {
    if (err instanceof Response) return err
    console.error('update-profile error:', err)
    return new Response(JSON.stringify({ error: 'Internal server error' }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
