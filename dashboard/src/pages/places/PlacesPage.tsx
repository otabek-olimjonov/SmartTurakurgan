import { useState } from 'react'
import { useParams } from 'react-router-dom'
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

// Maps URL group name → actual DB category values (match CHECK constraint)
const CATEGORY_GROUPS: Record<string, string[]> = {
  tourism:      ['diqqat_joy', 'ovqatlanish', 'mexmonxona'],
  education:    ['oquv_markaz', 'maktabgacha', 'maktab', 'texnikum', 'oliy_talim'],
  healthcare:   ['davlat_tibbiyot', 'xususiy_tibbiyot'],
  organization: ['davlat_tashkilot', 'xususiy_korxona'],
}

const CATEGORY_OPTIONS: Record<string, { value: string; label: string }[]> = {
  tourism: [
    { value: 'diqqat_joy',   label: 'Diqqatga sazovor joy' },
    { value: 'ovqatlanish',  label: 'Restoran / Choyxona' },
    { value: 'mexmonxona',   label: 'Mehmonxona' },
  ],
  education: [
    { value: 'oquv_markaz',  label: "O'quv markazi" },
    { value: 'maktabgacha',  label: 'Maktabgacha ta\'lim (MTM)' },
    { value: 'maktab',       label: 'Maktab' },
    { value: 'texnikum',     label: 'Texnikum / Kollej' },
    { value: 'oliy_talim',   label: "Oliy ta'lim" },
  ],
  healthcare: [
    { value: 'davlat_tibbiyot',  label: 'Davlat tibbiyot muassasasi' },
    { value: 'xususiy_tibbiyot', label: 'Xususiy klinika' },
  ],
  organization: [
    { value: 'davlat_tashkilot', label: 'Davlat tashkiloti' },
    { value: 'xususiy_korxona',  label: 'Xususiy korxona' },
  ],
}

const schema = z.object({
  name: z.string().min(2, 'Nomni kiriting'),
  category: z.string(),
  director: z.string().optional(),
  phone: z.string().optional(),
  description: z.string().optional(),
  location_lat: z.coerce.number().optional().or(z.literal('')),
  location_lng: z.coerce.number().optional().or(z.literal('')),
  is_published: z.boolean().default(true),
})
type FormData = z.infer<typeof schema>

type Place = {
  id: string
  name: string
  category: string
  director: string | null
  phone: string | null
  description: string | null
  location_lat: number | null
  location_lng: number | null
  rating: number
  is_published: boolean
}

async function fetchPlaces(group: string, page: number) {
  const categories = CATEGORY_GROUPS[group] ?? [group]
  const from = (page - 1) * PAGE_SIZE
  const { data, count, error } = await supabase
    .from('places')
    .select('*', { count: 'exact' })
    .in('category', categories)
    .order('name')
    .range(from, from + PAGE_SIZE - 1)
  if (error) throw error
  return { data: data as Place[], count: count ?? 0 }
}

export default function PlacesPage() {
  const { category = 'tourism' } = useParams()
  const qc = useQueryClient()
  const [page, setPage] = useState(1)
  const [modalOpen, setModalOpen] = useState(false)
  const [editing, setEditing] = useState<Place | null>(null)

  const { data, isLoading } = useQuery({
    queryKey: ['places', category, page],
    queryFn: () => fetchPlaces(category, page),
  })

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({ resolver: zodResolver(schema) as any })

  function openCreate() {
    setEditing(null)
    const defaultCategory = (CATEGORY_GROUPS[category] ?? [category])[0]
    reset({ category: defaultCategory, is_published: true })
    setModalOpen(true)
  }

  function openEdit(p: Place) {
    setEditing(p)
    reset({
      name: p.name,
      category: p.category,
      director: p.director ?? '',
      phone: p.phone ?? '',
      description: p.description ?? '',
      location_lat: p.location_lat ?? '',
      location_lng: p.location_lng ?? '',
      is_published: p.is_published,
    })
    setModalOpen(true)
  }

  const saveMutation = useMutation({
    mutationFn: async (values: FormData) => {
      const payload = {
        ...values,
        location_lat: values.location_lat === '' ? null : values.location_lat,
        location_lng: values.location_lng === '' ? null : values.location_lng,
      }
      if (editing) {
        const { error } = await supabase.from('places').update(payload).eq('id', editing.id)
        if (error) throw error
      } else {
        const { error } = await supabase.from('places').insert(payload)
        if (error) throw error
      }
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['places', category] })
      setModalOpen(false)
    },
  })

  const deleteMutation = useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from('places').delete().eq('id', id)
      if (error) throw error
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ['places', category] }),
  })

  const totalPages = Math.ceil((data?.count ?? 0) / PAGE_SIZE)

  return (
    <div>
      <div className="flex justify-between items-center mb-4">
        <p className="text-xs text-[#888780]">{data?.count ?? 0} ta joy</p>
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
                <th className="text-left px-4 py-2.5 text-xs font-medium text-[#888780]">Direktor</th>
                <th className="text-left px-4 py-2.5 text-xs font-medium text-[#888780]">Telefon</th>
                <th className="text-left px-4 py-2.5 text-xs font-medium text-[#888780]">Reyting</th>
                <th className="text-left px-4 py-2.5 text-xs font-medium text-[#888780]">Holat</th>
                <th className="px-4 py-2.5" />
              </tr>
            </thead>
            <tbody className="divide-y divide-[#E8E6E1]">
              {data.data.map((p) => (
                <tr key={p.id} className="hover:bg-[#F7F6F3] transition-colors">
                  <td className="px-4 py-3 font-medium text-[#0A0A0A]">{p.name}</td>
                  <td className="px-4 py-3 text-[#888780]">{p.director ?? '—'}</td>
                  <td className="px-4 py-3 text-[#888780]">{p.phone ?? '—'}</td>
                  <td className="px-4 py-3 text-[#888780]">{p.rating}</td>
                  <td className="px-4 py-3">
                    <span className={`text-xs ${p.is_published ? 'text-[#1D9E75]' : 'text-[#888780]'}`}>
                      {p.is_published ? 'Aktiv' : 'Yashirin'}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-1 justify-end">
                      <button onClick={() => openEdit(p)} className="p-1.5 text-[#888780] hover:text-[#0A0A0A]">
                        <Pencil size={13} />
                      </button>
                      <button
                        onClick={() => { if (confirm("O'chirishni tasdiqlaysizmi?")) deleteMutation.mutate(p.id) }}
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
        title={editing ? 'Joyni tahrirlash' : "Yangi joy qo'shish"}
        onClose={() => setModalOpen(false)}
        size="lg"
      >
        <form onSubmit={handleSubmit((v) => saveMutation.mutateAsync(v as FormData))} className="flex flex-col gap-4">
          <Input label="Nomi *" error={errors.name?.message} {...register('name')} />
          <div className="grid grid-cols-2 gap-4">
            <Input label="Direktor / Rahbar" {...register('director')} />
            <Input label="Telefon" {...register('phone')} />
          </div>
          <Textarea label="Tavsif" rows={3} {...register('description')} />
          <div className="grid grid-cols-2 gap-4">
            <Input label="Kenglik (lat)" type="number" step="any" {...register('location_lat')} />
            <Input label="Uzunlik (lng)" type="number" step="any" {...register('location_lng')} />
          </div>
          <div className="flex flex-col gap-1">
            <label className="text-xs font-medium text-[#0A0A0A]">Kategoriya</label>
            <select
              {...register('category')}
              className="h-9 rounded-lg border border-[#E8E6E1] px-3 text-sm text-[#0A0A0A] bg-white focus:outline-none focus:ring-1 focus:ring-[#1D9E75]"
            >
              {(CATEGORY_OPTIONS[category] ?? [{ value: category, label: category }]).map((opt) => (
                <option key={opt.value} value={opt.value}>{opt.label}</option>
              ))}
            </select>
          </div>
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
