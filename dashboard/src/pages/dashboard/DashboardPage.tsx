import { useQuery } from '@tanstack/react-query'
import { Link } from 'react-router-dom'
import { supabase } from '../../lib/supabase'
import { formatDistanceToNow } from 'date-fns'
import { uz } from 'date-fns/locale'
import {
  Users, MapPin, Newspaper, MessageSquare, Bell,
  Building2, GraduationCap, Heart, Briefcase, TreePine,
  Home, Landmark, ArrowRight, CheckCircle2, Clock, AlertCircle,
} from 'lucide-react'

// ─── Data fetchers ────────────────────────────────────────────────────────────

async function fetchOverviewStats() {
  const [
    users, rahbariyat, mahallalar, yer,
    places, yangiliklar, murojaatlar, bildirishnomalar,
    tourism, education, healthcare, org,
    pendingAppeals, resolvedAppeals, yerActive,
  ] = await Promise.all([
    supabase.from('users').select('*', { count: 'exact', head: true }),
    supabase.from('rahbariyat').select('*', { count: 'exact', head: true }).eq('is_published', true),
    supabase.from('mahallalar').select('*', { count: 'exact', head: true }).eq('is_published', true),
    supabase.from('yer_maydonlari').select('*', { count: 'exact', head: true }),
    supabase.from('places').select('*', { count: 'exact', head: true }).eq('is_published', true),
    supabase.from('yangiliklar').select('*', { count: 'exact', head: true }).eq('is_published', true),
    supabase.from('murojaatlar').select('*', { count: 'exact', head: true }),
    supabase.from('bildirishnomalar').select('*', { count: 'exact', head: true }),
    supabase.from('places').select('*', { count: 'exact', head: true }).in('category', ['diqqat_joy', 'ovqatlanish', 'mexmonxona']).eq('is_published', true),
    supabase.from('places').select('*', { count: 'exact', head: true }).in('category', ['oquv_markaz', 'maktabgacha', 'maktab', 'texnikum', 'oliy_talim']).eq('is_published', true),
    supabase.from('places').select('*', { count: 'exact', head: true }).in('category', ['davlat_tibbiyot', 'xususiy_tibbiyot']).eq('is_published', true),
    supabase.from('places').select('*', { count: 'exact', head: true }).in('category', ['davlat_tashkilot', 'xususiy_korxona']).eq('is_published', true),
    supabase.from('murojaatlar').select('*', { count: 'exact', head: true }).eq('status', 'pending'),
    supabase.from('murojaatlar').select('*', { count: 'exact', head: true }).eq('status', 'resolved'),
    supabase.from('yer_maydonlari').select('*', { count: 'exact', head: true }).eq('status', 'active'),
  ])
  return {
    users: users.count ?? 0,
    rahbariyat: rahbariyat.count ?? 0,
    mahallalar: mahallalar.count ?? 0,
    yer: yer.count ?? 0,
    places: places.count ?? 0,
    yangiliklar: yangiliklar.count ?? 0,
    murojaatlar: murojaatlar.count ?? 0,
    bildirishnomalar: bildirishnomalar.count ?? 0,
    tourism: tourism.count ?? 0,
    education: education.count ?? 0,
    healthcare: healthcare.count ?? 0,
    org: org.count ?? 0,
    pendingAppeals: pendingAppeals.count ?? 0,
    resolvedAppeals: resolvedAppeals.count ?? 0,
    yerActive: yerActive.count ?? 0,
  }
}

async function fetchPendingMurojaatlar() {
  const { data } = await supabase
    .from('murojaatlar')
    .select('id, full_name, phone, message, created_at, status')
    .eq('status', 'pending')
    .order('created_at', { ascending: false })
    .limit(6)
  return data ?? []
}

async function fetchRecentNews() {
  const { data } = await supabase
    .from('yangiliklar')
    .select('id, title, category, cover_image_url, published_at, is_published')
    .order('published_at', { ascending: false })
    .limit(6)
  return data ?? []
}

async function fetchRecentUsers() {
  const { data } = await supabase
    .from('users')
    .select('id, full_name, telegram_username, created_at')
    .order('created_at', { ascending: false })
    .limit(5)
  return data ?? []
}

// ─── Sub-components ───────────────────────────────────────────────────────────

function StatCard({ label, value, icon: Icon, iconBg, iconColor }: {
  label: string; value: number | undefined; icon: React.ElementType
  iconBg: string; iconColor: string
}) {
  return (
    <div className="bg-white rounded-xl p-4 flex items-center gap-4">
      <div className={`w-10 h-10 rounded-xl flex items-center justify-center shrink-0 ${iconBg}`}>
        <Icon size={18} className={iconColor} strokeWidth={1.8} />
      </div>
      <div>
        <p className="text-[11px] text-[#888780] leading-none mb-1">{label}</p>
        <p className="text-xl font-medium text-[#0A0A0A]">{value?.toLocaleString() ?? '—'}</p>
      </div>
    </div>
  )
}

function ModuleCard({ title, icon: Icon, iconBg, iconColor, stats, to }: {
  title: string; icon: React.ElementType; iconBg: string; iconColor: string
  stats: { label: string; value: number | undefined }[]; to: string
}) {
  return (
    <Link to={to} className="bg-white rounded-xl p-4 flex flex-col gap-3 hover:shadow-md transition-shadow group">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2.5">
          <div className={`w-8 h-8 rounded-lg flex items-center justify-center ${iconBg}`}>
            <Icon size={15} className={iconColor} strokeWidth={1.8} />
          </div>
          <span className="text-sm font-medium text-[#0A0A0A]">{title}</span>
        </div>
        <ArrowRight size={14} className="text-[#888780] group-hover:text-[#1D9E75] transition-colors" />
      </div>
      <div className="flex gap-3">
        {stats.map(s => (
          <div key={s.label} className="flex-1 bg-[#F7F6F3] rounded-lg px-3 py-2">
            <p className="text-base font-medium text-[#0A0A0A]">{s.value?.toLocaleString() ?? '—'}</p>
            <p className="text-[10px] text-[#888780] mt-0.5">{s.label}</p>
          </div>
        ))}
      </div>
    </Link>
  )
}

const STATUS_LABEL: Record<string, string> = {
  pending: 'Kutilmoqda',
  in_review: 'Ko\'rib chiqilmoqda',
  resolved: 'Hal qilindi',
}
const STATUS_COLOR: Record<string, string> = {
  pending: 'text-[#BA7517] bg-[#BA7517]/10',
  in_review: 'text-[#007AFF] bg-[#007AFF]/10',
  resolved: 'text-[#1D9E75] bg-[#1D9E75]/10',
}

// ─── Main page ────────────────────────────────────────────────────────────────

export default function DashboardPage() {
  const { data: stats } = useQuery({ queryKey: ['overview-stats'], queryFn: fetchOverviewStats })
  const { data: pending } = useQuery({ queryKey: ['pending-murojaatlar'], queryFn: fetchPendingMurojaatlar })
  const { data: recentNews } = useQuery({ queryKey: ['recent-news'], queryFn: fetchRecentNews })
  const { data: recentUsers } = useQuery({ queryKey: ['recent-users'], queryFn: fetchRecentUsers })

  const today = new Date().toLocaleDateString('uz-UZ', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })

  return (
    <div className="flex flex-col gap-6">

      {/* Page header */}
      <div>
        <h1 className="text-lg font-medium text-[#0A0A0A]">Boshqaruv paneli</h1>
        <p className="text-xs text-[#888780] mt-0.5 capitalize">{today}</p>
      </div>

      {/* Top stats row */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        <StatCard label="Foydalanuvchilar" value={stats?.users} icon={Users} iconBg="bg-[#1D9E75]/10" iconColor="text-[#1D9E75]" />
        <StatCard label="Joylar (jami)" value={stats?.places} icon={MapPin} iconBg="bg-[#007AFF]/10" iconColor="text-[#007AFF]" />
        <StatCard label="Yangiliklar" value={stats?.yangiliklar} icon={Newspaper} iconBg="bg-[#FF9500]/10" iconColor="text-[#FF9500]" />
        <StatCard label="Murojaatlar" value={stats?.murojaatlar} icon={MessageSquare} iconBg="bg-[#AF52DE]/10" iconColor="text-[#AF52DE]" />
      </div>

      {/* Module grid — mirrors mobile home screen */}
      <div>
        <h2 className="text-xs font-medium text-[#888780] uppercase tracking-wide mb-3">Modullar</h2>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">

          <ModuleCard
            title="Tuman Hokimligi"
            icon={Landmark}
            iconBg="bg-[#5856D6]/10"
            iconColor="text-[#5856D6]"
            to="/rahbariyat"
            stats={[
              { label: 'Rahbariyat', value: stats?.rahbariyat },
              { label: 'Mahallalar', value: stats?.mahallalar },
              { label: 'Yer maydonlari', value: stats?.yer },
            ]}
          />

          <ModuleCard
            title="Turizm"
            icon={TreePine}
            iconBg="bg-[#30B0C7]/10"
            iconColor="text-[#30B0C7]"
            to="/places/tourism"
            stats={[
              { label: 'Jami joylar', value: stats?.tourism },
            ]}
          />

          <ModuleCard
            title="Ta'lim"
            icon={GraduationCap}
            iconBg="bg-[#FF9500]/10"
            iconColor="text-[#FF9500]"
            to="/places/education"
            stats={[
              { label: "Ta'lim muassasalari", value: stats?.education },
            ]}
          />

          <ModuleCard
            title="Tibbiyot"
            icon={Heart}
            iconBg="bg-[#34C759]/10"
            iconColor="text-[#34C759]"
            to="/places/healthcare"
            stats={[
              { label: 'Tibbiyot muassasalari', value: stats?.healthcare },
            ]}
          />

          <ModuleCard
            title="Tashkilotlar"
            icon={Briefcase}
            iconBg="bg-[#007AFF]/10"
            iconColor="text-[#007AFF]"
            to="/places/organization"
            stats={[
              { label: 'Tashkilotlar', value: stats?.org },
            ]}
          />

          <ModuleCard
            title="Yangiliklar"
            icon={Newspaper}
            iconBg="bg-[#FF6B6B]/10"
            iconColor="text-[#FF6B6B]"
            to="/yangiliklar"
            stats={[
              { label: 'Chop etilgan', value: stats?.yangiliklar },
            ]}
          />

          <ModuleCard
            title="Mahallalar"
            icon={Home}
            iconBg="bg-[#FF6B6B]/10"
            iconColor="text-[#FF6B6B]"
            to="/mahallalar"
            stats={[
              { label: 'Mahallalar', value: stats?.mahallalar },
            ]}
          />

          <ModuleCard
            title="Yer maydonlari"
            icon={Building2}
            iconBg="bg-[#C8A96E]/10"
            iconColor="text-[#C8A96E]"
            to="/yer"
            stats={[
              { label: 'Jami', value: stats?.yer },
              { label: 'Faol', value: stats?.yerActive },
            ]}
          />

          <ModuleCard
            title="Bildirishnomalar"
            icon={Bell}
            iconBg="bg-[#AF52DE]/10"
            iconColor="text-[#AF52DE]"
            to="/notifications"
            stats={[
              { label: "Jo'natilgan", value: stats?.bildirishnomalar },
            ]}
          />
        </div>
      </div>

      {/* Murojaatlar appeal stats */}
      <div className="grid grid-cols-3 gap-3">
        <div className="bg-white rounded-xl p-4 flex items-center gap-3">
          <AlertCircle size={18} className="text-[#BA7517] shrink-0" strokeWidth={1.8} />
          <div>
            <p className="text-base font-medium text-[#0A0A0A]">{stats?.pendingAppeals?.toLocaleString() ?? '—'}</p>
            <p className="text-[11px] text-[#888780]">Kutilayotgan</p>
          </div>
        </div>
        <div className="bg-white rounded-xl p-4 flex items-center gap-3">
          <Clock size={18} className="text-[#007AFF] shrink-0" strokeWidth={1.8} />
          <div>
            <p className="text-base font-medium text-[#0A0A0A]">
              {stats && stats.murojaatlar && stats.pendingAppeals !== undefined && stats.resolvedAppeals !== undefined
                ? (stats.murojaatlar - stats.pendingAppeals - stats.resolvedAppeals).toLocaleString()
                : '—'}
            </p>
            <p className="text-[11px] text-[#888780]">Ko'rib chiqilmoqda</p>
          </div>
        </div>
        <div className="bg-white rounded-xl p-4 flex items-center gap-3">
          <CheckCircle2 size={18} className="text-[#1D9E75] shrink-0" strokeWidth={1.8} />
          <div>
            <p className="text-base font-medium text-[#0A0A0A]">{stats?.resolvedAppeals?.toLocaleString() ?? '—'}</p>
            <p className="text-[11px] text-[#888780]">Hal qilindi</p>
          </div>
        </div>
      </div>

      {/* Bottom 3-col grid: appeals, news, users */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">

        {/* Pending appeals */}
        <div className="bg-white rounded-xl p-4 flex flex-col">
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-sm font-medium text-[#0A0A0A]">Yangi murojaatlar</h2>
            <Link to="/murojaatlar" className="text-[11px] text-[#1D9E75] hover:underline flex items-center gap-0.5">
              Barchasi <ArrowRight size={10} />
            </Link>
          </div>
          {!pending?.length ? (
            <p className="text-xs text-[#888780] flex-1">Kutilayotgan murojaat yo'q</p>
          ) : (
            <div className="flex flex-col divide-y divide-[#F7F6F3]">
              {pending.map((m) => (
                <div key={m.id} className="py-2.5 flex items-start justify-between gap-2">
                  <div className="min-w-0">
                    <p className="text-sm font-medium text-[#0A0A0A] truncate">{m.full_name}</p>
                    <p className="text-xs text-[#888780] mt-0.5 line-clamp-1">{m.message}</p>
                    <p className="text-[10px] text-[#888780] mt-0.5">
                      {m.created_at ? formatDistanceToNow(new Date(m.created_at), { addSuffix: true, locale: uz }) : ''}
                    </p>
                  </div>
                  <span className={`text-[10px] px-1.5 py-0.5 rounded-full shrink-0 font-medium ${STATUS_COLOR[m.status] ?? 'text-[#888780] bg-[#F7F6F3]'}`}>
                    {STATUS_LABEL[m.status] ?? m.status}
                  </span>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Recent news */}
        <div className="bg-white rounded-xl p-4 flex flex-col">
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-sm font-medium text-[#0A0A0A]">So'nggi yangiliklar</h2>
            <Link to="/yangiliklar" className="text-[11px] text-[#1D9E75] hover:underline flex items-center gap-0.5">
              Barchasi <ArrowRight size={10} />
            </Link>
          </div>
          {!recentNews?.length ? (
            <p className="text-xs text-[#888780]">Yangiliklar yo'q</p>
          ) : (
            <div className="flex flex-col divide-y divide-[#F7F6F3]">
              {recentNews.map((n) => (
                <div key={n.id} className="py-2.5 flex items-start gap-2">
                  {n.cover_image_url ? (
                    <img src={n.cover_image_url} alt="" className="w-10 h-10 rounded-lg object-cover shrink-0 bg-[#F7F6F3]" />
                  ) : (
                    <div className="w-10 h-10 rounded-lg bg-[#F7F6F3] shrink-0 flex items-center justify-center">
                      <Newspaper size={14} className="text-[#888780]" />
                    </div>
                  )}
                  <div className="min-w-0 flex-1">
                    <p className="text-sm text-[#0A0A0A] line-clamp-2 leading-snug">{n.title}</p>
                    <div className="flex items-center gap-2 mt-1">
                      {n.category && (
                        <span className="text-[9px] bg-[#1D9E75] text-white px-1.5 py-0.5 rounded-full font-medium">{n.category}</span>
                      )}
                      <span className={`text-[10px] ${n.is_published ? 'text-[#1D9E75]' : 'text-[#888780]'}`}>
                        {n.is_published ? 'Chop etilgan' : 'Qoralama'}
                      </span>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Recent users */}
        <div className="bg-white rounded-xl p-4 flex flex-col">
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-sm font-medium text-[#0A0A0A]">Yangi foydalanuvchilar</h2>
            <span className="text-[11px] text-[#888780]">Telegram orqali</span>
          </div>
          {!recentUsers?.length ? (
            <p className="text-xs text-[#888780]">Foydalanuvchilar yo'q</p>
          ) : (
            <div className="flex flex-col divide-y divide-[#F7F6F3]">
              {recentUsers.map((u) => {
                const initials = (u.full_name ?? 'U')
                  .trim().split(' ').filter(Boolean).slice(0, 2)
                  .map((s: string) => s[0].toUpperCase()).join('')
                return (
                  <div key={u.id} className="py-2.5 flex items-center gap-2.5">
                    <div className="w-8 h-8 rounded-full bg-[#1D9E75]/10 flex items-center justify-center shrink-0">
                      <span className="text-xs font-medium text-[#1D9E75]">{initials}</span>
                    </div>
                    <div className="min-w-0">
                      <p className="text-sm font-medium text-[#0A0A0A] truncate">{u.full_name ?? 'Noma\'lum'}</p>
                      {u.telegram_username && (
                        <p className="text-[10px] text-[#888780]">@{u.telegram_username}</p>
                      )}
                    </div>
                    <span className="ml-auto text-[10px] text-[#888780] shrink-0">
                      {u.created_at ? formatDistanceToNow(new Date(u.created_at), { addSuffix: true, locale: uz }) : ''}
                    </span>
                  </div>
                )
              })}
            </div>
          )}
        </div>

      </div>
    </div>
  )
}
