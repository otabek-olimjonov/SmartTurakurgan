import { create } from 'zustand'
import type { Session } from '@supabase/supabase-js'
import { supabase } from '../lib/supabase'

type Role = 'admin' | 'superadmin' | null

interface AuthState {
  session: Session | null
  role: Role
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

export const useAuthStore = create<AuthState>((set) => ({
  session: null,
  role: null,
  loading: true,

  setSession: (session) =>
    set({ session, role: extractRole(session), loading: false }),

  signOut: async () => {
    await supabase.auth.signOut()
    set({ session: null, role: null })
  },

  init: async () => {
    const { data } = await supabase.auth.getSession()
    set({
      session: data.session,
      role: extractRole(data.session),
      loading: false,
    })

    const { data: listener } = supabase.auth.onAuthStateChange((_event, session) => {
      set({ session, role: extractRole(session), loading: false })
    })

    return () => listener.subscription.unsubscribe()
  },
}))
