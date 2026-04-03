import { useQuery } from '@tanstack/react-query'
import { supabase } from '../../lib/supabase'
import { Users, MapPin, Newspaper, MessageSquare } from 'lucide-react'

async function fetchStats() {
  const [users, yangiliklar, murojaatlar, places] = await Promise.all([
    supabase.from('users').select('*', { count: 'exact', head: true }),
    supabase.from('yangiliklar').select('*', { count: 'exact', head: true }).eq('is_published', true),
    supabase.from('murojaatlar').select('*', { count: 'exact', head: true }),
    supabase.from('places').select('*', { count: 'exact', head: true }).eq('is_published', true),
  ])
  return {
    users: users.count ?? 0,
    yangiliklar: yangiliklar.count ?? 0,
    murojaatlar: murojaatlar.count ?? 0,
    places: places.count ?? 0,
  }
}

async function fetchPendingMurojaatlar() {
  const { data } = await supabase
    .from('murojaatlar')
    .select('id, full_name, message, created_at, status')
    .eq('status', 'pending')
    .order('created_at', { ascending: false })
    .limit(5)
  return data ?? []
}

async function fetchRecentNews() {
  const { data } = await supabase
    .from('yangiliklar')
    .select('id, title, published_at, is_published')
    .order('published_at', { ascending: false })
    .limit(5)
  return data ?? []
}

const STAT_CARDS = [
  { key: 'users', label: 'Foydalanuvchilar', icon: Users, color: 'text-[#1D9E75]' },
  { key: 'places', label: 'Joylar', icon: MapPin, color: 'text-[#C8A96E]' },
  { key: 'yangiliklar', label: 'Yangiliklar', icon: Newspaper, color: 'text-[#1D9E75]' },
  { key: 'murojaatlar', label: 'Murojaatlar', icon: MessageSquare, color: 'text-[#BA7517]' },
] as const

export default function DashboardPage() {
  const { data: stats } = useQuery({ queryKey: ['stats'], queryFn: fetchStats })
  const { data: pending } = useQuery({ queryKey: ['pending-murojaatlar'], queryFn: fetchPendingMurojaatlar })
  const { data: recentNews } = useQuery({ queryKey: ['recent-news'], queryFn: fetchRecentNews })

  return (
    <div className="flex flex-col gap-5">
      {/* Stats */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        {STAT_CARDS.map(({ key, label, icon: Icon, color }) => (
          <div key={key} className="bg-white border border-[#E8E6E1] rounded-xl p-4">
            <div className="flex items-center justify-between mb-3">
              <span className="text-xs text-[#888780]">{label}</span>
              <Icon size={16} className={color} />
            </div>
            <p className="text-2xl font-medium text-[#0A0A0A]">
              {stats ? stats[key as keyof typeof stats].toLocaleString() : '—'}
            </p>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        {/* Pending appeals */}
        <div className="bg-white border border-[#E8E6E1] rounded-xl p-4">
          <h2 className="text-sm font-medium mb-3">Kutilayotgan murojaatlar</h2>
          {pending?.length === 0 && (
            <p className="text-xs text-[#888780]">Kutilayotgan murojaatlar yo'q</p>
          )}
          <div className="flex flex-col divide-y divide-[#E8E6E1]">
            {pending?.map((m) => (
              <div key={m.id} className="py-2.5">
                <p className="text-sm font-medium text-[#0A0A0A]">{m.full_name}</p>
                <p className="text-xs text-[#888780] mt-0.5 line-clamp-1">{m.message}</p>
              </div>
            ))}
          </div>
        </div>

        {/* Recent news */}
        <div className="bg-white border border-[#E8E6E1] rounded-xl p-4">
          <h2 className="text-sm font-medium mb-3">So'nggi yangiliklar</h2>
          {recentNews?.length === 0 && (
            <p className="text-xs text-[#888780]">Yangiliklar yo'q</p>
          )}
          <div className="flex flex-col divide-y divide-[#E8E6E1]">
            {recentNews?.map((n) => (
              <div key={n.id} className="py-2.5 flex items-center justify-between gap-4">
                <p className="text-sm text-[#0A0A0A] line-clamp-1 flex-1">{n.title}</p>
                <span className={`text-xs ${n.is_published ? 'text-[#1D9E75]' : 'text-[#888780]'}`}>
                  {n.is_published ? 'Chop etilgan' : 'Qoralama'}
                </span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  )
}
