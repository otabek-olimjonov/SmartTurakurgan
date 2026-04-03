import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { useForm } from 'react-hook-form'
import { z } from 'zod'
import { zodResolver } from '@hookform/resolvers/zod'
import { supabase } from '../../lib/supabase'
import Input from '../../components/ui/Input'
import Button from '../../components/ui/Button'

const schema = z
  .object({
    full_name: z.string().min(2, 'Kamida 2 ta belgi'),
    password: z.string().min(8, 'Kamida 8 ta belgi'),
    confirm: z.string(),
  })
  .refine((d) => d.password === d.confirm, {
    message: 'Parollar mos kelmaydi',
    path: ['confirm'],
  })

type FormData = z.infer<typeof schema>

export default function AcceptInvitePage() {
  const navigate = useNavigate()
  const [serverError, setServerError] = useState('')
  const [checking, setChecking] = useState(true)

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({ resolver: zodResolver(schema) as never })

  useEffect(() => {
    // Supabase automatically exchanges the invite token from the URL hash
    supabase.auth.getSession().then(({ data }) => {
      if (!data.session) {
        // No active session — invite link is invalid or expired
        navigate('/login', { replace: true })
      } else {
        setChecking(false)
      }
    })
  }, [navigate])

  async function onSubmit(data: FormData) {
    setServerError('')

    // 1. Set the user's password and full_name in user_metadata
    const { error: updateError } = await supabase.auth.updateUser({
      password: data.password,
      data: { full_name: data.full_name },
    })

    if (updateError) {
      setServerError(updateError.message)
      return
    }

    // 2. Update profiles table with the chosen full_name
    const { data: session } = await supabase.auth.getSession()
    if (session.session?.user.id) {
      await supabase
        .from('profiles')
        .update({ full_name: data.full_name })
        .eq('id', session.session.user.id)
    }

    navigate('/dashboard', { replace: true })
  }

  if (checking) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#F7F6F3]">
        <p className="text-sm text-[#888780]">Tekshirilmoqda...</p>
      </div>
    )
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-[#F7F6F3]">
      <div className="w-full max-w-sm bg-white border border-[#E8E6E1] rounded-xl p-8">
        <div className="mb-6 text-center">
          <p className="text-xs text-[#1D9E75] font-medium uppercase tracking-widest mb-1">
            Admin panel
          </p>
          <h1 className="text-lg font-medium text-[#0A0A0A]">Profilni sozlash</h1>
          <p className="text-xs text-[#888780] mt-1">
            Ism va parol belgilang
          </p>
        </div>

        <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4">
          <Input
            label="Ism va familiya"
            type="text"
            autoComplete="name"
            placeholder="Abdullayev Abdulla"
            error={errors.full_name?.message}
            {...register('full_name')}
          />
          <Input
            label="Parol"
            type="password"
            autoComplete="new-password"
            placeholder="••••••••"
            error={errors.password?.message}
            {...register('password')}
          />
          <Input
            label="Parolni tasdiqlang"
            type="password"
            autoComplete="new-password"
            placeholder="••••••••"
            error={errors.confirm?.message}
            {...register('confirm')}
          />

          {serverError && (
            <p className="text-xs text-[#E24B4A] text-center">{serverError}</p>
          )}

          <Button
            type="submit"
            variant="primary"
            loading={isSubmitting}
            className="w-full justify-center mt-1"
          >
            Kirish
          </Button>
        </form>
      </div>
    </div>
  )
}
