import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { z } from 'zod'
import { zodResolver } from '@hookform/resolvers/zod'
import { Navigate, useNavigate } from 'react-router-dom'
import { supabase } from '../../lib/supabase'
import { useAuthStore } from '../../store/auth.store'
import Input from '../../components/ui/Input'
import Button from '../../components/ui/Button'

const schema = z.object({
  email: z.string().email("To'g'ri email kiriting"),
  password: z.string().min(6, 'Kamida 6 ta belgi'),
})
type FormData = z.infer<typeof schema>

export default function LoginPage() {
  const { session } = useAuthStore()
  const navigate = useNavigate()
  const [serverError, setServerError] = useState('')
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({ resolver: zodResolver(schema) })

  if (session) return <Navigate to="/dashboard" replace />

  async function onSubmit(data: FormData) {
    setServerError('')
    const { error } = await supabase.auth.signInWithPassword({
      email: data.email,
      password: data.password,
    })
    if (error) {
      setServerError(error.message)
    } else {
      navigate('/dashboard', { replace: true })
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-[#F7F6F3]">
      <div className="w-full max-w-sm bg-white border border-[#E8E6E1] rounded-xl p-8">
        <div className="mb-6 text-center">
          <p className="text-xs text-[#1D9E75] font-medium uppercase tracking-widest mb-1">
            Admin panel
          </p>
          <h1 className="text-lg font-medium text-[#0A0A0A]">Smart Turakurgan</h1>
        </div>

        <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-4">
          <Input
            label="Email"
            type="email"
            autoComplete="email"
            placeholder="admin@turakurgan.uz"
            error={errors.email?.message}
            {...register('email')}
          />
          <Input
            label="Parol"
            type="password"
            autoComplete="current-password"
            placeholder="••••••••"
            error={errors.password?.message}
            {...register('password')}
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
