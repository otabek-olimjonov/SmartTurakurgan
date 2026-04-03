// supabase/functions/_shared/auth.ts

import { create, verify, getNumericDate } from 'https://deno.land/x/djwt@v3.0.2/mod.ts'

export interface JWTPayload {
  sub: string        // user uuid
  telegram_id: number
  role: string       // 'citizen' | 'admin' | 'superadmin'
  exp: number
  iat: number
}

/**
 * Returns a CryptoKey for HS256 signing / verification using
 * SUPABASE_JWT_SECRET (set via Supabase dashboard secrets).
 */
async function getKey(): Promise<CryptoKey> {
  const secret = Deno.env.get('APP_JWT_SECRET')
  if (!secret) throw new Error('SUPABASE_JWT_SECRET is not set')

  const enc = new TextEncoder()
  return crypto.subtle.importKey(
    'raw',
    enc.encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign', 'verify'],
  )
}

/**
 * Issues a signed JWT for the given user.
 * exp: 30 days from now (long-lived token as per spec).
 */
export async function issueJWT(payload: Omit<JWTPayload, 'exp' | 'iat'>): Promise<string> {
  const key = await getKey()
  const now = getNumericDate(0)
  return create(
    { alg: 'HS256', typ: 'JWT' },
    { ...payload, iat: now, exp: getNumericDate(60 * 60 * 24 * 30) },
    key,
  )
}

/**
 * Extracts and verifies the Bearer JWT from the Authorization header.
 * Throws a Response (401) if missing, malformed, or expired.
 */
export async function verifyJWT(req: Request): Promise<JWTPayload> {
  const authHeader = req.headers.get('Authorization')
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    throw new Response(
      JSON.stringify({ error: 'Missing or invalid Authorization header' }),
      { status: 401, headers: { 'Content-Type': 'application/json' } },
    )
  }

  const token = authHeader.slice(7)
  try {
    const key = await getKey()
    const payload = await verify(token, key) as JWTPayload
    return payload
  } catch {
    throw new Response(
      JSON.stringify({ error: 'Invalid or expired token' }),
      { status: 401, headers: { 'Content-Type': 'application/json' } },
    )
  }
}

/**
 * Throws a 401 Response if the JWT payload does not have an admin role.
 */
export function requireAdmin(payload: JWTPayload): void {
  if (!['admin', 'superadmin'].includes(payload.role)) {
    throw new Response(
      JSON.stringify({ error: 'Insufficient permissions' }),
      { status: 401, headers: { 'Content-Type': 'application/json' } },
    )
  }
}
