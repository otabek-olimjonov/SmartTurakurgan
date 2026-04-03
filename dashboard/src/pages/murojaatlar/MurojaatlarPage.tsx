import { useState } from 'react'
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { supabase } from '../../lib/supabase'
import Button from '../../components/ui/Button'
import Select from '../../components/ui/Select'
import Pagination from '../../components/ui/Pagination'
import Modal from '../../components/ui/Modal'
import { statusBadge } from '../../components/ui/Badge'
import { formatDate } from '../../lib/utils'

const PAGE_SIZE = 20

const STATUS_OPTIONS = [
  { value: 'pending', label: 'Kutilmoqda' },
  { value: 'in_review', label: "Ko'rib chiqilmoqda" },
  { value: 'resolved', label: 'Hal qilindi' },
]

type Murojaat = {
  id: string
  full_name: string
  phone: string
  address: string
  message: string
  status: string
  created_at: string
}

async function fetchMurojaatlar(page: number) {
  const from = (page - 1) * PAGE_SIZE
  const { data, count, error } = await supabase
    .from('murojaatlar')
    .select('*', { count: 'exact' })
    .order('created_at', { ascending: false })
    .range(from, from + PAGE_SIZE - 1)
  if (error) throw error
  return { data: data as Murojaat[], count: count ?? 0 }
}

export default function MurojaatlarPage() {
  const qc = useQueryClient()
  const [page, setPage] = useState(1)
  const [selected, setSelected] = useState<Murojaat | null>(null)
  const [newStatus, setNewStatus] = useState('pending')

  const { data, isLoading } = useQuery({ queryKey: ['murojaatlar', page], queryFn: () => fetchMurojaatlar(page) })

  const statusMutation = useMutation({
    mutationFn: async ({ id, status }: { id: string; status: string }) => {
      const { error } = await supabase.from('murojaatlar').update({ status }).eq('id', id)
      if (error) throw error
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ['murojaatlar'] })
      setSelected(null)
    },
  })

  const totalPages = Math.ceil((data?.count ?? 0) / PAGE_SIZE)

  return (
    <div>
      <div className="flex justify-between items-center mb-4">
        <p className="text-xs text-[#888780]">{data?.count ?? 0} ta murojaat</p>
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
                <th className="text-left px-4 py-2.5 text-xs font-medium text-[#888780]">Ism-familiya</th>
                <th className="text-left px-4 py-2.5 text-xs font-medium text-[#888780]">Telefon</th>
                <th className="text-left px-4 py-2.5 text-xs font-medium text-[#888780]">Xabar</th>
                <th className="text-left px-4 py-2.5 text-xs font-medium text-[#888780]">Sana</th>
                <th className="text-left px-4 py-2.5 text-xs font-medium text-[#888780]">Holat</th>
                <th className="px-4 py-2.5" />
              </tr>
            </thead>
            <tbody className="divide-y divide-[#E8E6E1]">
              {data.data.map((m) => (
                <tr key={m.id} className="hover:bg-[#F7F6F3] transition-colors">
                  <td className="px-4 py-3 font-medium text-[#0A0A0A]">{m.full_name}</td>
                  <td className="px-4 py-3 text-[#888780]">{m.phone}</td>
                  <td className="px-4 py-3 text-[#888780] max-w-xs">
                    <p className="truncate">{m.message}</p>
                  </td>
                  <td className="px-4 py-3 text-[#888780] text-xs">{formatDate(m.created_at)}</td>
                  <td className="px-4 py-3">{statusBadge(m.status)}</td>
                  <td className="px-4 py-3">
                    <Button
                      size="sm"
                      variant="ghost"
                      onClick={() => { setSelected(m); setNewStatus(m.status) }}
                    >
                      Ko'rish
                    </Button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          <Pagination page={page} totalPages={totalPages} onChange={setPage} />
        </div>
      )}

      <Modal open={!!selected} title="Murojaat tafsilotlari" onClose={() => setSelected(null)} size="md">
        {selected && (
          <div className="flex flex-col gap-4">
            <div className="flex flex-col gap-1.5">
              <div className="flex gap-2 text-sm">
                <span className="text-[#888780] w-20 shrink-0">Ism:</span>
                <span className="text-[#0A0A0A]">{selected.full_name}</span>
              </div>
              <div className="flex gap-2 text-sm">
                <span className="text-[#888780] w-20 shrink-0">Telefon:</span>
                <span className="text-[#0A0A0A]">{selected.phone}</span>
              </div>
              <div className="flex gap-2 text-sm">
                <span className="text-[#888780] w-20 shrink-0">Manzil:</span>
                <span className="text-[#0A0A0A]">{selected.address}</span>
              </div>
              <div className="flex gap-2 text-sm">
                <span className="text-[#888780] w-20 shrink-0">Sana:</span>
                <span className="text-[#0A0A0A]">{formatDate(selected.created_at)}</span>
              </div>
            </div>
            <div className="bg-[#F7F6F3] rounded-lg p-3 text-sm text-[#0A0A0A]">
              {selected.message}
            </div>
            <Select
              label="Holat"
              options={STATUS_OPTIONS}
              value={newStatus}
              onChange={(e) => setNewStatus(e.target.value)}
            />
            <div className="flex justify-end gap-2">
              <Button onClick={() => setSelected(null)}>Yopish</Button>
              <Button
                variant="primary"
                loading={statusMutation.isPending}
                onClick={() => statusMutation.mutate({ id: selected.id, status: newStatus })}
              >
                Holatni saqlash
              </Button>
            </div>
          </div>
        )}
      </Modal>
    </div>
  )
}
