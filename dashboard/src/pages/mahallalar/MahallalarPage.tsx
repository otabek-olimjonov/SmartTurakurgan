import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { useForm } from 'react-hook-form'
import { z } from 'zod'
import { zodResolver } from '@hookform/resolvers/zod'
import { Plus, Pencil, Trash2 } from 'lucide-react'
import { supabase } from '../../lib/supabase'
import Button from '../../components/ui/Button'
import Input from '../../components/ui/Input'
import Textarea from '../../components/ui/Textarea'
import Modal from '../../components/ui/Modal'
import Pagination from '../../components/ui/Pagination'

const PAGE_SIZE = 20

const mahallSchema = z.object({
  name: z.string().min(2, 'Nomni kiriting'),
  description: z.string().optional(),
  location_lat: z.union([z.coerce.number(), z.literal('')]).optional(),
  location_lng: z.union([z.coerce.number(), z.literal('')]).optional(),
  building_photo_url: z.string().optional(),
  is_published: z.boolean(),
})
type MahallForm = z.infer<typeof mahallSchema>

type Mahalla = {
  id: string
  name: string
  description: string | null
  location_lat: number | null
  location_lng: number | null
  building_photo_url: string | null
  is_published: boolean
}

async function fetchMahallalar(page: number) {
  const from = (page - 1) * PAGE_SIZE
  const { data, count, error } = await supabase
    .from('mahallalar')
    .select('*', { count: 'exact' })
    .order('name')
    .range(from, from + PAGE_SIZE - 1)
  if (error) throw error
  return { data: data as Mahalla[], count: count ?? 0 }
}

export default function MahallalarPage() {
  const qc = useQueryClient()
  const [page, setPage] = useState(1)
  const [modalOpen, setModalOpen] = useState(false)
  const [editing, setEditing] = useState<Mahalla | null>(null)

  const { data, isLoading } = useQuery({
    queryKey: ['mahallalar', page],
    queryFn: () => fetchMahallalar(page),
  })

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<MahallForm>({ resolver: zodResolver(mahallSchema) as any })

  function openCreate() {
    setEditing(null)
    reset({ is_published: true })
    setModalOpen(true)
  }

  function openEdit(m: Mahalla) {
    setEditing(m)
    reset({
      name: m.name,
      description: m.description ?? '',
      location_lat: m.location_lat ?? '',
      location_lng: m.location_lng ?? '',
      building_photo_url: m.building_photo_url ?? '',
      is_published: m.is_published,
    })
    setModalOpen(true)
  }

  const saveMutation = useMutation({
    mutationFn: async (values: MahallForm) => {
      const payload = {
        ...values,
        location_lat: values.location_lat === '' ? null : values.location_lat,
        location_lng: values.location_lng === '' ? null : values.location_lng,
        building_photo_url: values.building_photo_url === '' ? null : values.building_photo_url,
      }
      if (editing) {
        const { error } = await supabase.from('mahallalar').update(payload).eq('id', editing.id)
        if (error) throw error
      } else {
        const { error } = await supabase.from('mahallalar').insert(payload)
        if (error) throw error
      }
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['mahallalar'] })
      setModalOpen(false)
    },
  })

  const deleteMutation = useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from('mahallalar').delete().eq('id', id)
      if (error) throw error
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ['mahallalar'] }),
  })

  const totalPages = Math.ceil((data?.count ?? 0) / PAGE_SIZE)

  return (
    <div>
      <div className="flex justify-between items-center mb-4">
        <p className="text-xs text-[#888780]">{data?.count ?? 0} ta mahalla</p>
        <Button variant="primary" size="sm" onClick={openCreate}>
          <Plus size={14} /> Qo'shish
        </Button>
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
                <th className="text-left px-4 py-2.5 text-xs font-medium text-[#888780]">Nomi</th>
                <th className="text-left px-4 py-2.5 text-xs font-medium text-[#888780]">Joylashuv</th>
                <th className="text-left px-4 py-2.5 text-xs font-medium text-[#888780]">Holat</th>
                <th className="px-4 py-2.5" />
              </tr>
            </thead>
            <tbody className="divide-y divide-[#E8E6E1]">
              {data.data.map((m) => (
                <tr key={m.id} className="hover:bg-[#F7F6F3] transition-colors">
                  <td className="px-4 py-3 font-medium text-[#0A0A0A]">{m.name}</td>
                  <td className="px-4 py-3 text-[#888780] text-xs">
                    {m.location_lat && m.location_lng
                      ? `${m.location_lat.toFixed(4)}, ${m.location_lng.toFixed(4)}`
                      : '—'}
                  </td>
                  <td className="px-4 py-3">
                    <span className={`text-xs ${m.is_published ? 'text-[#1D9E75]' : 'text-[#888780]'}`}>
                      {m.is_published ? 'Aktiv' : 'Yashirin'}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-1 justify-end">
                      <button onClick={() => openEdit(m)} className="p-1.5 text-[#888780] hover:text-[#0A0A0A]">
                        <Pencil size={13} />
                      </button>
                      <button
                        onClick={() => { if (confirm("O'chirishni tasdiqlaysizmi?")) deleteMutation.mutate(m.id) }}
                        className="p-1.5 text-[#888780] hover:text-[#E24B4A]"
                      >
                        <Trash2 size={13} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          <Pagination page={page} totalPages={totalPages} onChange={setPage} />
        </div>
      )}

      <Modal
        open={modalOpen}
        title={editing ? 'Mahallani tahrirlash' : "Yangi mahalla qo'shish"}
        onClose={() => setModalOpen(false)}
        size="lg"
      >
        <form onSubmit={handleSubmit((v) => saveMutation.mutateAsync(v as MahallForm))} className="flex flex-col gap-4">
          <Input label="Nomi *" error={errors.name?.message} {...register('name')} />
          <Textarea label="Tavsif" rows={3} {...register('description')} />
          <div className="grid grid-cols-2 gap-4">
            <Input label="Kenglik (lat)" type="number" step="any" {...register('location_lat')} />
            <Input label="Uzunlik (lng)" type="number" step="any" {...register('location_lng')} />
          </div>
          <Input label="Bino rasmi URL" {...register('building_photo_url')} />
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
