import { create } from 'zustand'
import type { Session } from '@supabase/supabase-js'
import { supabase } from '../lib/supabase'

type Role = 'admin' | 'superadmin' | null

export interface Profile {
  id: string
  full_name: string | null
  role: 'admin' | 'superadmin'
}

interface AuthState {
  session: Session | null
  role: Role
  profile: Profile | null
  loading: boolean
  setSession: (session: Session | null) => void
  signOut: () => Promise<void>
  init: () => Promise<() => void>
}

function extractRole(session: Session | null): Role {
  if (!session) return null
  const meta = session.user.app_metadata as Record<string, unknown>
  const r = meta?.role
  if (r === 'admin' || r === 'superadmin') return r
  return null
}

async function fetchProfile(userId: string): Promise<Profile | null> {
  const { data } = await supabase
    .from('profiles')
    .select('id, full_name, role')
    .eq('id', userId)
    .single()
  return data ?? null
}

export const useAuthStore = create<AuthState>((set) => ({
  session: null,
  role: null,
  profile: null,
  loading: true,

  setSession: (session) =>
    set({ session, role: extractRole(session), loading: false }),

  signOut: async () => {
    await supabase.auth.signOut()
    set({ session: null, role: null, profile: null })
  },

  init: async () => {
    const { data } = await supabase.auth.getSession()
    const profile = data.session ? await fetchProfile(data.session.user.id) : null
    set({
      session: data.session,
      role: extractRole(data.session),
      profile,
      loading: false,
    })

    const { data: listener } = supabase.auth.onAuthStateChange(async (_event, session) => {
      const updatedProfile = session ? await fetchProfile(session.user.id) : null
      set({ session, role: extractRole(session), profile: updatedProfile, loading: false })
    })

    return () => listener.subscription.unsubscribe()
  },
}))
