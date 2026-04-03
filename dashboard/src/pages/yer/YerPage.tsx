import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { useForm } from 'react-hook-form'
import { z } from 'zod'
import { zodResolver } from '@hookform/resolvers/zod'
import { Plus, Pencil, Trash2, ExternalLink } from 'lucide-react'
import { supabase } from '../../lib/supabase'
import Button from '../../components/ui/Button'
import Input from '../../components/ui/Input'
import Textarea from '../../components/ui/Textarea'
import Select from '../../components/ui/Select'
import Modal from '../../components/ui/Modal'
import Pagination from '../../components/ui/Pagination'
import { statusBadge } from '../../components/ui/Badge'

const PAGE_SIZE = 20

const STATUS_OPTIONS = [
  { value: 'active', label: 'Aktiv' },
  { value: 'sold', label: 'Sotilgan' },
  { value: 'pending', label: 'Kutilmoqda' },
]

const numOrUndef = (v: unknown) => (v === '' || v == null ? undefined : Number(v))

const schema = z.object({
  title: z.string().min(2, 'Sarlavhani kiriting'),
  area_hectares: z.preprocess(numOrUndef, z.number().positive().optional()),
  location_lat: z.preprocess(numOrUndef, z.number().optional()),
  location_lng: z.preprocess(numOrUndef, z.number().optional()),
  status: z.string().default('active'),
  auction_url: z.string().optional(),
  description: z.string().optional(),
  is_published: z.boolean().default(true),
})
type FormData = z.infer<typeof schema>

type YerMaydon = {
  id: string
  title: string
  area_hectares: number | null
  location_lat: number | null
  location_lng: number | null
  status: string
  auction_url: string | null
  is_published: boolean
}

async function fetchYer(page: number) {
  const from = (page - 1) * PAGE_SIZE
  const { data, count, error } = await supabase
    .from('yer_maydonlari')
    .select('*', { count: 'exact' })
    .order('updated_at', { ascending: false })
    .range(from, from + PAGE_SIZE - 1)
  if (error) throw error
  return { data: data as YerMaydon[], count: count ?? 0 }
}

export default function YerPage() {
  const qc = useQueryClient()
  const [page, setPage] = useState(1)
  const [modalOpen, setModalOpen] = useState(false)
  const [editing, setEditing] = useState<YerMaydon | null>(null)

  const { data, isLoading } = useQuery({ queryKey: ['yer', page], queryFn: () => fetchYer(page) })

  const { register, handleSubmit, reset, formState: { errors, isSubmitting } } = useForm<FormData>({ resolver: zodResolver(schema) })

  function openCreate() {
    setEditing(null)
    reset({ status: 'active', is_published: true })
    setModalOpen(true)
  }
  function openEdit(y: YerMaydon) {
    setEditing(y)
    reset({
      title: y.title,
      area_hectares: y.area_hectares ?? '',
      location_lat: y.location_lat ?? '',
      location_lng: y.location_lng ?? '',
      status: y.status,
      auction_url: y.auction_url ?? '',
      is_published: y.is_published,
    })
    setModalOpen(true)
  }

  const saveMutation = useMutation({
    mutationFn: async (values: FormData) => {
      const payload = {
        ...values,
        area_hectares: values.area_hectares === '' ? null : values.area_hectares,
        location_lat: values.location_lat === '' ? null : values.location_lat,
        location_lng: values.location_lng === '' ? null : values.location_lng,
        auction_url: values.auction_url === '' ? null : values.auction_url,
      }
      if (editing) {
        const { error } = await supabase.from('yer_maydonlari').update(payload).eq('id', editing.id)
        if (error) throw error
      } else {
        const { error } = await supabase.from('yer_maydonlari').insert(payload)
        if (error) throw error
      }
    },
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['yer'] }); setModalOpen(false) },
  })

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const deleteMutation = useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from('yer_maydonlari').delete().eq('id', id)
      if (error) throw error
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ['yer'] }),
  })

  const totalPages = Math.ceil((data?.count ?? 0) / PAGE_SIZE)

  return (
    <div>
      <div className="flex justify-between items-center mb-4">
        <p className="text-xs text-[#888780]">{data?.count ?? 0} ta yer maydoni</p>
        <Button variant="primary" size="sm" onClick={openCreate}><Plus size={14} /> Qo'shish</Button>
      </div>

      {isLoading && (
        <div className="flex flex-col gap-2">
          {Array.from({ length: 5 }).map((_, i) => (
            <div key={i} className="h-14 bg-[#E8E6E1]/50 rounded-lg animate-pulse" />
          ))}
        </div>
      )}

      {data && (
        <div className="bg-white border border-[#E8E6E1] rounded-xl overflow-hidden">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-[#E8E6E1] bg-[#F7F6F3]">
                <th className="text-left px-4 py-2.5 text-xs font-medium text-[#888780]">Sarlavha</th>
                <th className="text-left px-4 py-2.5 text-xs font-medium text-[#888780]">Maydon (ga)</th>
                <th className="text-left px-4 py-2.5 text-xs font-medium text-[#888780]">Holat</th>
                <th className="text-left px-4 py-2.5 text-xs font-medium text-[#888780]">Auksion</th>
                <th className="px-4 py-2.5" />
              </tr>
            </thead>
            <tbody className="divide-y divide-[#E8E6E1]">
              {data.data.map((y) => (
                <tr key={y.id} className="hover:bg-[#F7F6F3] transition-colors">
                  <td className="px-4 py-3 font-medium text-[#0A0A0A]">{y.title}</td>
                  <td className="px-4 py-3 text-[#888780]">{y.area_hectares ?? '—'}</td>
                  <td className="px-4 py-3">{statusBadge(y.status)}</td>
                  <td className="px-4 py-3">
                    {y.auction_url ? (
                      <a href={y.auction_url} target="_blank" rel="noreferrer" className="text-[#1D9E75] flex items-center gap-1 text-xs">
                        <ExternalLink size={12} /> Link
                      </a>
                    ) : '—'}
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-1 justify-end">
                      <button onClick={() => openEdit(y)} className="p-1.5 text-[#888780] hover:text-[#0A0A0A]"><Pencil size={13} /></button>
                      <button onClick={() => { if (confirm("O'chirishni tasdiqlaysizmi?")) deleteMutation.mutate(y.id) }} className="p-1.5 text-[#888780] hover:text-[#E24B4A]"><Trash2 size={13} /></button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          <Pagination page={page} totalPages={totalPages} onChange={setPage} />
        </div>
      )}

      <Modal open={modalOpen} title={editing ? 'Tahrirlash' : "Yangi yer maydoni"} onClose={() => setModalOpen(false)} size="lg">
        <form onSubmit={handleSubmit((v: FormData) => saveMutation.mutateAsync(v))} className="flex flex-col gap-4">
          <Input label="Sarlavha *" error={errors.title?.message} {...register('title')} />
          <div className="grid grid-cols-2 gap-4">
            <Input label="Maydon (gektar)" type="number" step="any" {...register('area_hectares')} />
            <Select label="Holat" options={STATUS_OPTIONS} {...register('status')} />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <Input label="Kenglik (lat)" type="number" step="any" {...register('location_lat')} />
            <Input label="Uzunlik (lng)" type="number" step="any" {...register('location_lng')} />
          </div>
          <Input label="Auksion URL" {...register('auction_url')} />
          <Textarea label="Tavsif" rows={3} {...register('description')} />
          <div className="flex items-center gap-2">
            <input type="checkbox" id="is_published" {...register('is_published')} />
            <label htmlFor="is_published" className="text-sm">Chop etilgan</label>
          </div>
          <div className="flex justify-end gap-2 mt-2">
            <Button type="button" onClick={() => setModalOpen(false)}>Bekor qilish</Button>
            <Button type="submit" variant="primary" loading={isSubmitting}>Saqlash</Button>
          </div>
        </form>
      </Modal>
    </div>
  )
}
