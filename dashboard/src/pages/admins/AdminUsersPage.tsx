import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { useForm } from 'react-hook-form'
import { z } from 'zod'
import { zodResolver } from '@hookform/resolvers/zod'
import { UserPlus, Trash2, ShieldCheck, Shield } from 'lucide-react'
import { supabase } from '../../lib/supabase'
import { useAuthStore } from '../../store/auth.store'
import Button from '../../components/ui/Button'
import Modal from '../../components/ui/Modal'
import Input from '../../components/ui/Input'
import Select from '../../components/ui/Select'

// ── Types ──────────────────────────────────────────────────────────────────────

interface AdminProfile {
  id: string
  full_name: string | null
  role: 'admin' | 'superadmin'
  created_at: string
  email?: string
}

// ── Invite form schema ─────────────────────────────────────────────────────────

const inviteSchema = z.object({
  email: z.string().email("To'g'ri email kiriting"),
  role: z.enum(['admin', 'superadmin']),
  temp_password: z.string().min(8, 'Kamida 8 ta belgi'),
})
type InviteFormData = z.infer<typeof inviteSchema>

// ── Data helpers ───────────────────────────────────────────────────────────────

async function fetchAdminProfiles(): Promise<AdminProfile[]> {
  const { data, error } = await supabase
    .from('profiles')
    .select('id, full_name, role, created_at')
    .order('created_at', { ascending: false })

  if (error) throw new Error(error.message)
  return data ?? []
}

// ── Component ──────────────────────────────────────────────────────────────────

export default function AdminUsersPage() {
  const { role: currentRole, session } = useAuthStore()
  const isSuperadmin = currentRole === 'superadmin'
  const queryClient = useQueryClient()

  const [inviteOpen, setInviteOpen] = useState(false)
  const [inviteError, setInviteError] = useState('')
  const [deleteTarget, setDeleteTarget] = useState<AdminProfile | null>(null)

  const { data: profiles = [], isLoading, error } = useQuery({
    queryKey: ['admin-profiles'],
    queryFn: fetchAdminProfiles,
  })

  // ── Invite mutation ──────────────────────────────────────────────────────────
  const inviteMutation = useMutation({
    mutationFn: async (body: InviteFormData) => {
      const { data: sessionData } = await supabase.auth.getSession()
      const token = sessionData.session?.access_token
      if (!token) throw new Error('Not authenticated')

      const res = await fetch(
        `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/invite-admin`,
        {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${token}`,
          },
          body: JSON.stringify(body),
        },
      )
      const json = await res.json()
      if (!res.ok) throw new Error(json.error ?? 'Xatolik yuz berdi')
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['admin-profiles'] })
      setInviteOpen(false)
      inviteForm.reset()
    },
    onError: (err: Error) => setInviteError(err.message),
  })

  // ── Delete mutation ──────────────────────────────────────────────────────────
  const deleteMutation = useMutation({
    mutationFn: async (userId: string) => {
      const { data: sessionData } = await supabase.auth.getSession()
      const token = sessionData.session?.access_token
      if (!token) throw new Error('Not authenticated')

      const res = await fetch(
        `${import.meta.env.VITE_SUPABASE_URL}/functions/v1/invite-admin`,
        {
          method: 'DELETE',
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${token}`,
          },
          body: JSON.stringify({ user_id: userId }),
        },
      )
      const json = await res.json()
      if (!res.ok) throw new Error(json.error ?? 'Xatolik yuz berdi')
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['admin-profiles'] })
      setDeleteTarget(null)
    },
  })

  // ── Invite form ──────────────────────────────────────────────────────────────
  const inviteForm = useForm<InviteFormData>({
    resolver: zodResolver(inviteSchema) as never,
    defaultValues: { role: 'admin' },
  })

  function openInvite() {
    setInviteError('')
    inviteForm.reset({ role: 'admin' })
    setInviteOpen(true)
  }

  async function onInviteSubmit(data: InviteFormData) {
    setInviteError('')
    inviteMutation.mutate(data)
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  function formatDate(iso: string) {
    return new Date(iso).toLocaleDateString('uz-UZ', {
      year: 'numeric', month: 'short', day: 'numeric',
    })
  }

  // ── Render ───────────────────────────────────────────────────────────────────
  return (
    <div className="max-w-3xl mx-auto space-y-5">
      {/* Header row */}
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-sm font-medium text-[#0A0A0A]">Admin foydalanuvchilar</h2>
          <p className="text-xs text-[#888780] mt-0.5">Faqat taklif orqali kirish</p>
        </div>
        {isSuperadmin && (
          <Button variant="primary" size="sm" onClick={openInvite}>
            <UserPlus size={14} />
            Admin yaratish
          </Button>
        )}
      </div>

      {/* List */}
      {isLoading && (
        <p className="text-sm text-[#888780]">Yuklanmoqda...</p>
      )}
      {error && (
        <p className="text-sm text-[#E24B4A]">Xatolik: {(error as Error).message}</p>
      )}

      {!isLoading && profiles.length === 0 && (
        <p className="text-sm text-[#888780]">Foydalanuvchilar yo'q</p>
      )}

      <div className="space-y-2">
        {profiles.map((p) => {
          const isMe = p.id === session?.user.id
          return (
            <div
              key={p.id}
              className="flex items-center gap-3 bg-white border border-[#E8E6E1] rounded-xl px-4 py-3"
            >
              {/* Avatar */}
              <div className="w-9 h-9 rounded-full bg-[#1D9E75]/12 flex items-center justify-center text-[13px] font-medium text-[#1D9E75] shrink-0">
                {(p.full_name ?? p.id.slice(0, 2)).slice(0, 2).toUpperCase()}
              </div>

              {/* Info */}
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-[#0A0A0A] truncate">
                  {p.full_name ?? '—'}
                  {isMe && (
                    <span className="ml-1.5 text-[10px] text-[#1D9E75] font-medium">(siz)</span>
                  )}
                </p>
                <p className="text-xs text-[#888780]">{formatDate(p.created_at)}</p>
              </div>

              {/* Role badge */}
              <div className="flex items-center gap-1 shrink-0">
                {p.role === 'superadmin' ? (
                  <ShieldCheck size={14} className="text-[#1D9E75]" />
                ) : (
                  <Shield size={14} className="text-[#888780]" />
                )}
                <span className={`text-xs font-medium ${p.role === 'superadmin' ? 'text-[#1D9E75]' : 'text-[#888780]'}`}>
                  {p.role === 'superadmin' ? 'Superadmin' : 'Admin'}
                </span>
              </div>

              {/* Delete — superadmin only, not self */}
              {isSuperadmin && !isMe && (
                <button
                  onClick={() => setDeleteTarget(p)}
                  className="p-1.5 text-[#888780] hover:text-[#E24B4A] transition-colors"
                  title="O'chirish"
                >
                  <Trash2 size={14} />
                </button>
              )}
            </div>
          )
        })}
      </div>

      {/* ── Invite modal ─────────────────────────────────────────────────────── */}
      <Modal open={inviteOpen} title="Yangi admin yaratish" onClose={() => setInviteOpen(false)}>
        <form
          onSubmit={inviteForm.handleSubmit(onInviteSubmit)}
          className="flex flex-col gap-4"
        >
          <Input
            label="Email manzil"
            type="email"
            placeholder="admin@example.com"
            error={inviteForm.formState.errors.email?.message}
            {...inviteForm.register('email')}
          />
          <Select
            label="Rol"
            options={[
              { value: 'admin', label: 'Admin' },
              { value: 'superadmin', label: 'Superadmin' },
            ]}
            {...inviteForm.register('role')}
          />
          <Input
            label="Vaqtinchalik parol"
            type="text"
            placeholder="Min. 8 ta belgi"
            autoComplete="off"
            error={inviteForm.formState.errors.temp_password?.message}
            {...inviteForm.register('temp_password')}
          />
          <p className="text-xs text-[#888780] -mt-2">
            Bu parolni yangi adminга xabar orqali yuboring. Kirganidan so'ng o'zgartirishi mumkin.
          </p>

          {inviteError && (
            <p className="text-xs text-[#E24B4A]">{inviteError}</p>
          )}

          <div className="flex justify-end gap-2 mt-1">
            <Button
              type="button"
              variant="ghost"
              size="sm"
              onClick={() => setInviteOpen(false)}
            >
              Bekor qilish
            </Button>
            <Button
              type="submit"
              variant="primary"
              size="sm"
              loading={inviteMutation.isPending}
            >
            Yaratish
            </Button>
          </div>
        </form>
      </Modal>

      {/* ── Delete confirm modal ─────────────────────────────────────────────── */}
      <Modal
        open={!!deleteTarget}
        title="Foydalanuvchini o'chirish"
        onClose={() => setDeleteTarget(null)}
      >
        <p className="text-sm text-[#0A0A0A] mb-4">
          <strong>{deleteTarget?.full_name ?? deleteTarget?.id}</strong> ni o'chirishni
          tasdiqlaysizmi? Bu amalni qaytarib bo'lmaydi.
        </p>
        <div className="flex justify-end gap-2">
          <Button
            type="button"
            variant="ghost"
            size="sm"
            onClick={() => setDeleteTarget(null)}
          >
            Bekor qilish
          </Button>
          <Button
            type="button"
            variant="danger"
            size="sm"
            loading={deleteMutation.isPending}
            onClick={() => deleteTarget && deleteMutation.mutate(deleteTarget.id)}
          >
            O'chirish
          </Button>
        </div>
      </Modal>
    </div>
  )
}
