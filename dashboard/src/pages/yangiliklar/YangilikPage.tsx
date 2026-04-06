import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { useForm } from 'react-hook-form'
import { z } from 'zod'
import { zodResolver } from '@hookform/resolvers/zod'
import { Plus, Pencil, Trash2, ImageOff } from 'lucide-react'
import { supabase } from '../../lib/supabase'
import Button from '../../components/ui/Button'
import Input from '../../components/ui/Input'
import Textarea from '../../components/ui/Textarea'
import Select from '../../components/ui/Select'
import Modal from '../../components/ui/Modal'
import Pagination from '../../components/ui/Pagination'
import { formatDate } from '../../lib/utils'
import ImageUploader, { type ManagedImage } from '../../components/ui/ImageUploader'

const PAGE_SIZE = 20

const CATEGORIES = [
  { value: 'general', label: 'Umumiy' },
  { value: 'hokimiyat', label: 'Hokimiyat' },
  { value: 'education', label: "Ta'lim" },
  { value: 'healthcare', label: 'Tibbiyot' },
  { value: 'tourism', label: 'Turizm' },
]

const schema = z.object({
  title: z.string().min(2, 'Sarlavhani kiriting'),
  body: z.string().optional(),
  category: z.string().default('general'),
  is_published: z.boolean().default(true),
})
type FormData = z.infer<typeof schema>

type Yangilik = {
  id: string
  title: string
  body: string | null
  cover_image_url: string | null
  category: string
  is_published: boolean
  published_at: string
}

async function fetchYangiliklar(page: number) {
  const from = (page - 1) * PAGE_SIZE
  const { data, count, error } = await supabase
    .from('yangiliklar')
    .select('*', { count: 'exact' })
    .order('published_at', { ascending: false })
    .range(from, from + PAGE_SIZE - 1)
  if (error) throw error
  return { data: data as Yangilik[], count: count ?? 0 }
}

export default function YangilikPage() {
  const qc = useQueryClient()
  const [page, setPage] = useState(1)
  const [modalOpen, setModalOpen] = useState(false)
  const [editing, setEditing] = useState<Yangilik | null>(null)
  const [images, setImages] = useState<ManagedImage[]>([])

  const { data, isLoading } = useQuery({ queryKey: ['yangiliklar', page], queryFn: () => fetchYangiliklar(page) })

  const { register, handleSubmit, reset, formState: { errors, isSubmitting } } = useForm<FormData>({ resolver: zodResolver(schema) as any })

  function openCreate() {
    setEditing(null)
    setImages([])
    reset({ category: 'general', is_published: true })
    setModalOpen(true)
  }
  async function openEdit(n: Yangilik) {
    setEditing(n)
    const { data: imgs } = await supabase
      .from('yangilik_images')
      .select('image_url, is_main')
      .eq('yangilik_id', n.id)
      .order('sort_order')
    let managed: ManagedImage[] = (imgs ?? []).map(img => ({ url: img.image_url, is_main: img.is_main }))
    if (managed.length === 0 && n.cover_image_url) managed = [{ url: n.cover_image_url, is_main: true }]
    setImages(managed)
    reset({ title: n.title, body: n.body ?? '', category: n.category, is_published: n.is_published })
    setModalOpen(true)
  }

  const saveMutation = useMutation({
    mutationFn: async (values: FormData) => {
      const mainImg = images.find(img => img.is_main) ?? images[0]
      const cover_image_url = mainImg?.url ?? null
      const payload = { ...values, cover_image_url }
      let yangilikId: string
      if (editing) {
        const { error } = await supabase.from('yangiliklar').update(payload).eq('id', editing.id)
        if (error) throw error
        yangilikId = editing.id
      } else {
        const { data, error } = await supabase.from('yangiliklar').insert(payload).select('id').single()
        if (error) throw error
        yangilikId = data.id
      }
      // sync yangilik_images
      await supabase.from('yangilik_images').delete().eq('yangilik_id', yangilikId)
      if (images.length > 0) {
        const rows = images.map((img, idx) => ({
          yangilik_id: yangilikId,
          image_url: img.url,
          is_main: img.is_main,
          sort_order: idx,
        }))
        const { error } = await supabase.from('yangilik_images').insert(rows)
        if (error) throw error
      }
    },
    onSuccess: () => { qc.invalidateQueries({ queryKey: ['yangiliklar'] }); setModalOpen(false) },
  })

  const deleteMutation = useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from('yangiliklar').delete().eq('id', id)
      if (error) throw error
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ['yangiliklar'] }),
  })

  const totalPages = Math.ceil((data?.count ?? 0) / PAGE_SIZE)

  return (
    <div>
      <div className="flex justify-between items-center mb-4">
        <p className="text-xs text-[#888780]">{data?.count ?? 0} ta yangilik</p>
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
                <th className="px-4 py-2.5 w-14" />
                <th className="text-left px-4 py-2.5 text-xs font-medium text-[#888780]">Sarlavha</th>
                <th className="text-left px-4 py-2.5 text-xs font-medium text-[#888780]">Kategoriya</th>
                <th className="text-left px-4 py-2.5 text-xs font-medium text-[#888780]">Sana</th>
                <th className="text-left px-4 py-2.5 text-xs font-medium text-[#888780]">Holat</th>
                <th className="px-4 py-2.5" />
              </tr>
            </thead>
            <tbody className="divide-y divide-[#E8E6E1]">
              {data.data.map((n) => (
                <tr key={n.id} className="hover:bg-[#F7F6F3] transition-colors">
                  <td className="px-4 py-2.5">
                    {n.cover_image_url ? (
                      <img src={n.cover_image_url} alt="" className="w-10 h-10 rounded-lg object-cover border border-[#E8E6E1]" />
                    ) : (
                      <div className="w-10 h-10 rounded-lg bg-[#F7F6F3] border border-[#E8E6E1] flex items-center justify-center">
                        <ImageOff size={14} className="text-[#E8E6E1]" />
                      </div>
                    )}
                  </td>
                  <td className="px-4 py-3 font-medium text-[#0A0A0A] max-w-xs">
                    <p className="truncate">{n.title}</p>
                  </td>
                  <td className="px-4 py-3 text-[#888780] capitalize">{n.category}</td>
                  <td className="px-4 py-3 text-[#888780] text-xs">{formatDate(n.published_at)}</td>
                  <td className="px-4 py-3">
                    <span className={`text-xs ${n.is_published ? 'text-[#1D9E75]' : 'text-[#888780]'}`}>
                      {n.is_published ? 'Chop etilgan' : 'Qoralama'}
                    </span>
                  </td>
                  <td className="px-4 py-3">
                    <div className="flex items-center gap-1 justify-end">
                      <button onClick={() => openEdit(n)} className="p-1.5 text-[#888780] hover:text-[#0A0A0A]"><Pencil size={13} /></button>
                      <button onClick={() => { if (confirm("O'chirishni tasdiqlaysizmi?")) deleteMutation.mutate(n.id) }} className="p-1.5 text-[#888780] hover:text-[#E24B4A]"><Trash2 size={13} /></button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          <Pagination page={page} totalPages={totalPages} onChange={setPage} />
        </div>
      )}

      <Modal open={modalOpen} title={editing ? "Yangilikni tahrirlash" : "Yangi yangilik"} onClose={() => setModalOpen(false)} size="lg">
        <form onSubmit={handleSubmit((v) => saveMutation.mutateAsync(v as unknown as FormData))}>
          <div className="flex flex-col gap-4 max-h-[65vh] overflow-y-auto pr-1 pb-1">
            <ImageUploader value={images} onChange={setImages} folder="news" disabled={isSubmitting} />
            <Input label="Sarlavha *" error={errors.title?.message} {...register('title')} />
            <Select label="Kategoriya" options={CATEGORIES} {...register('category')} />
            <Textarea label="Matn" rows={6} {...register('body')} />
            <div className="flex items-center gap-2">
              <input type="checkbox" id="is_published" {...register('is_published')} />
              <label htmlFor="is_published" className="text-sm">Chop etilgan</label>
            </div>
          </div>
          <div className="flex justify-end gap-2 mt-4 pt-4 border-t border-[#E8E6E1]">
            <Button type="button" onClick={() => setModalOpen(false)}>Bekor qilish</Button>
            <Button type="submit" variant="primary" loading={isSubmitting || saveMutation.isPending}>Saqlash</Button>
          </div>
        </form>
      </Modal>
    </div>
  )
}
