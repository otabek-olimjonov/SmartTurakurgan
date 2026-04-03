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
import Select from '../../components/ui/Select'
import Modal from '../../components/ui/Modal'
import Pagination from '../../components/ui/Pagination'

const PAGE_SIZE = 20

const CATEGORIES = [
  { value: 'hokim', label: 'Hokim' },
  { value: 'apparat', label: 'Apparat' },
  { value: 'deputat', label: 'Deputat' },
  { value: 'kotibiyat', label: 'Kotibiyat' },
]

const numOrUndef = (v: unknown) => (v === '' || v == null ? undefined : Number(v))

const schema = z.object({
  full_name: z.string().min(2, 'Ism-familiyani kiriting'),
  position: z.string().min(2, 'Lavozimni kiriting'),
  category: z.string(),
  birth_year: z.preprocess(numOrUndef, z.number().min(1900).max(2010).optional()),
  phone: z.string().optional(),
  biography: z.string().optional(),
  reception_days: z.string().optional(),
  photo_url: z.string().url("To'g'ri URL kiriting").optional().or(z.literal('')),
  sort_order: z.preprocess((v) => (v === '' || v == null ? 0 : Number(v)), z.number().default(0)),
  is_published: z.boolean().default(true),
})
type FormData = z.infer<typeof schema>

type Person = {
  id: string
  full_name: string
  position: string
  category: string
  birth_year: number | null
  phone: string | null
  biography: string | null
  reception_days: string | null
  photo_url: string | null
  sort_order: number
  is_published: boolean
  updated_at: string
}

async function fetchRahbariyat(page: number) {
  const from = (page - 1) * PAGE_SIZE
  const { data, count, error } = await supabase
    .from('rahbariyat')
    .select('*', { count: 'exact' })
    .order('sort_order', { ascending: true })
    .range(from, from + PAGE_SIZE - 1)
  if (error) throw error
  return { data: data as Person[], count: count ?? 0 }
}

export default function RahbariyatPage() {
  const qc = useQueryClient()
  const [page, setPage] = useState(1)
  const [modalOpen, setModalOpen] = useState(false)
  const [editing, setEditing] = useState<Person | null>(null)

  const { data, isLoading, isError } = useQuery({
    queryKey: ['rahbariyat', page],
    queryFn: () => fetchRahbariyat(page),
  })

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({ resolver: zodResolver(schema) as any })

  function openCreate() {
    setEditing(null)
    reset({ category: 'rahbariyat', sort_order: 0, is_published: true })
    setModalOpen(true)
  }

  function openEdit(person: Person) {
    setEditing(person)
    reset({
      full_name: person.full_name,
      position: person.position,
      category: person.category,
      birth_year: person.birth_year ?? undefined,
      phone: person.phone ?? '',
      biography: person.biography ?? '',
      reception_days: person.reception_days ?? '',
      photo_url: person.photo_url ?? '',
      sort_order: person.sort_order,
      is_published: person.is_published,
    })
    setModalOpen(true)
  }

  const saveMutation = useMutation({
    mutationFn: async (values: FormData) => {
      const payload = {
        ...values,
        birth_year: values.birth_year == null ? null : values.birth_year,
        photo_url: values.photo_url === '' ? null : values.photo_url,
      }
      if (editing) {
        const { error } = await supabase.from('rahbariyat').update(payload).eq('id', editing.id)
        if (error) throw error
      } else {
        const { error } = await supabase.from('rahbariyat').insert(payload)
        if (error) throw error
      }
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['rahbariyat'] })
      setModalOpen(false)
    },
  })

  const deleteMutation = useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from('rahbariyat').delete().eq('id', id)
      if (error) throw error
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ['rahbariyat'] }),
  })

  const totalPages = Math.ceil((data?.count ?? 0) / PAGE_SIZE)

  return (
    <div>
      <div className="flex justify-between items-center mb-4">
        <p className="text-xs text-[#888780]">{data?.count ?? 0} ta yozuv</p>
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

      {isError && (
        <p className="text-sm text-[#E24B4A]">Ma'lumotlarni yuklashda xatolik</p>
      )}

      {data && (
        <div className="bg-white border border-[#E8E6E1] rounded-xl overflow-hidden">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b border-[#E8E6E1] bg-[#F7F6F3]">
                <th className="text-left px-4 py-2.5 text-xs font-medium text-[#888780]">Ism-familiya</th>
                <th className="text-left px-4 py-2.5 text-xs font-medium text-[#888780]">Lavozim</th>
                <th className="text-left px-4 py-2.5 text-xs font-medium text-[#888780]">Kategoriya</th>
                <th className="text-left px-4 py-2.5 text-xs font-medium text-[#888780]">Holat</th>
                <th className="px-4 py-2.5" />
              </tr>
            </thead>
            <tbody className="divide-y divide-[#E8E6E1]">
              {data.data.map((p) => (
                <tr key={p.id} className="hover:bg-[#F7F6F3] transition-colors">
                  <td className="px-4 py-3 font-medium text-[#0A0A0A]">{p.full_name}</td>
                  <td className="px-4 py-3 text-[#888780]">{p.position}</td>
                  <td className="px-4 py-3 text-[#888780] capitalize">{p.category}</td>
                  <td className="px-4 py-3">
                    <span className={`text-xs ${p.is_published ? 'text-[#1D9E75]' : 'text-[#888780]'}`}>
                      {p.is_published ? 'Aktiv' : 'Yashirin'}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-1 justify-end">
                      <button
                        onClick={() => openEdit(p)}
                        className="p-1.5 text-[#888780] hover:text-[#0A0A0A] transition-colors"
                      >
                        <Pencil size={13} />
                      </button>
                      <button
                        onClick={() => {
                          if (confirm("O'chirishni tasdiqlaysizmi?")) deleteMutation.mutate(p.id)
                        }}
                        className="p-1.5 text-[#888780] hover:text-[#E24B4A] transition-colors"
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
        title={editing ? 'Tahrirlash' : "Yangi xodim qo'shish"}
        onClose={() => setModalOpen(false)}
        size="lg"
      >
        <form onSubmit={handleSubmit((v) => saveMutation.mutateAsync(v))} className="flex flex-col gap-4">
          <div className="grid grid-cols-2 gap-4">
            <Input label="Ism-familiya *" error={errors.full_name?.message} {...register('full_name')} />
            <Input label="Lavozim *" error={errors.position?.message} {...register('position')} />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <Select label="Kategoriya" options={CATEGORIES} {...register('category')} />
            <Input label="Tug'ilgan yili" type="number" {...register('birth_year')} />
          </div>
          <div className="grid grid-cols-2 gap-4">
            <Input label="Telefon" {...register('phone')} />
            <Input label="Qabul kunlari" {...register('reception_days')} />
          </div>
          <Input label="Rasm URL" {...register('photo_url')} />
          <Textarea label="Biografiya" rows={3} {...register('biography')} />
          <div className="grid grid-cols-2 gap-4">
            <Input label="Tartib raqami" type="number" {...register('sort_order')} />
            <div className="flex items-center gap-2 mt-5">
              <input type="checkbox" id="is_published" {...register('is_published')} />
              <label htmlFor="is_published" className="text-sm text-[#0A0A0A]">Chop etilgan</label>
            </div>
          </div>

          {saveMutation.isError && (
            <p className="text-xs text-[#E24B4A]">Xatolik yuz berdi. Qayta urinib ko'ring.</p>
          )}

          <div className="flex justify-end gap-2 mt-2">
            <Button type="button" onClick={() => setModalOpen(false)}>Bekor qilish</Button>
            <Button type="submit" variant="primary" loading={isSubmitting}>Saqlash</Button>
          </div>
        </form>
      </Modal>
    </div>
  )
}
