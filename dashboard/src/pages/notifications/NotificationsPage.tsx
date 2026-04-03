import { useState } from 'react'
import { useForm } from 'react-hook-form'
import { z } from 'zod'
import { zodResolver } from '@hookform/resolvers/zod'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { supabase } from '../../lib/supabase'
import Button from '../../components/ui/Button'
import Input from '../../components/ui/Input'
import Textarea from '../../components/ui/Textarea'
import Select from '../../components/ui/Select'
import { formatDate } from '../../lib/utils'

const TARGET_OPTIONS = [
  { value: 'all', label: 'Barcha foydalanuvchilar' },
]

const schema = z.object({
  title: z.string().min(2, 'Sarlavhani kiriting'),
  body: z.string().optional(),
  target: z.string().default('all'),
})
type FormData = z.infer<typeof schema>

type Bildirishnoma = {
  id: string
  title: string
  body: string | null
  target: string
  is_sent: boolean
  created_at: string
}

async function fetchNotifications() {
  const { data, error } = await supabase
    .from('bildirishnomalar')
    .select('*')
    .order('created_at', { ascending: false })
    .limit(50)
  if (error) throw error
  return data as Bildirishnoma[]
}

export default function NotificationsPage() {
  const qc = useQueryClient()
  const { data, isLoading } = useQuery({ queryKey: ['notifications'], queryFn: fetchNotifications })

  const { register, handleSubmit, reset, formState: { errors, isSubmitting } } = useForm<FormData>({ resolver: zodResolver(schema) })

  const sendMutation = useMutation({
    mutationFn: async (values: FormData) => {
      const { error } = await supabase.from('bildirishnomalar').insert({ ...values, is_sent: false })
      if (error) throw error
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['notifications'] })
      reset({ title: '', body: '', target: 'all' })
    },
  })

  return (
    <div className="grid grid-cols-1 lg:grid-cols-2 gap-5">
      {/* Send form */}
      <div className="bg-white border border-[#E8E6E1] rounded-xl p-5">
        <h2 className="text-sm font-medium mb-4">Yangi bildirishnoma</h2>
        <form onSubmit={handleSubmit((v) => sendMutation.mutateAsync(v))} className="flex flex-col gap-4">
          <Input label="Sarlavha *" error={errors.title?.message} {...register('title')} />
          <Textarea label="Matn" rows={4} {...register('body')} />
          <Select label="Kimga" options={TARGET_OPTIONS} {...register('target')} />

          {sendMutation.isError && (
            <p className="text-xs text-[#E24B4A]">Xatolik yuz berdi</p>
          )}
          {sendMutation.isSuccess && (
            <p className="text-xs text-[#1D9E75]">Bildirishnoma qo'shildi</p>
          )}

          <Button type="submit" variant="primary" loading={isSubmitting} className="self-start">
            Yuborish
          </Button>
        </form>
      </div>

      {/* History */}
      <div className="bg-white border border-[#E8E6E1] rounded-xl p-5">
        <h2 className="text-sm font-medium mb-4">Yuborilgan bildirishnomalar</h2>
        {isLoading && (
          <div className="flex flex-col gap-2">
            {Array.from({ length: 4 }).map((_, i) => (
              <div key={i} className="h-12 bg-[#E8E6E1]/50 rounded animate-pulse" />
            ))}
          </div>
        )}
        {data?.length === 0 && (
          <p className="text-xs text-[#888780]">Bildirishnomalar yo'q</p>
        )}
        <div className="flex flex-col divide-y divide-[#E8E6E1]">
          {data?.map((n) => (
            <div key={n.id} className="py-3">
              <div className="flex items-center justify-between gap-2">
                <p className="text-sm font-medium text-[#0A0A0A]">{n.title}</p>
                <span className={`text-xs shrink-0 ${n.is_sent ? 'text-[#1D9E75]' : 'text-[#888780]'}`}>
                  {n.is_sent ? 'Yuborildi' : 'Kutilmoqda'}
                </span>
              </div>
              {n.body && <p className="text-xs text-[#888780] mt-0.5 line-clamp-2">{n.body}</p>}
              <p className="text-xs text-[#888780] mt-1">{formatDate(n.created_at)}</p>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
