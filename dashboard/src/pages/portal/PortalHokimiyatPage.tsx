import { useState, useEffect } from 'react'
import { useSearchParams } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { supabase } from '../../lib/supabase'
import { cn, getInitials } from '../../lib/utils'
import { Phone, MapPin, ExternalLink, ChevronDown, ChevronUp, ChevronLeft, ChevronRight } from 'lucide-react'

const PAGE_SIZE = 20

// ─── Types ─────────────────────────────────────────────────────────────────────
type Rahbariyat = {
  id: string
  full_name: string
  birth_year: number | null
  position: string
  category: string
  phone: string | null
  biography: string | null
  reception_days: string | null
  photo_url: string | null
  sort_order: number
}

type Mahalla = {
  id: string
  name: string
  description: string | null
  building_photo_url: string | null
  location_lat: number | null
  location_lng: number | null
}

type YerMaydon = {
  id: string
  title: string
  area_hectares: number | null
  status: string
  auction_url: string | null
  description: string | null
  location_lat: number | null
  location_lng: number | null
}

// ─── Fetchers ───────────────────────────────────────────────────────────────────
async function fetchRahbariyat(categories: string[], page: number) {
  const from = (page - 1) * PAGE_SIZE
  const { data, count } = await supabase
    .from('rahbariyat')
    .select('id, full_name, birth_year, position, category, phone, biography, reception_days, photo_url, sort_order', { count: 'exact' })
    .eq('is_published', true)
    .in('category', categories)
    .order('sort_order')
    .range(from, from + PAGE_SIZE - 1)
  return { data: (data ?? []) as Rahbariyat[], count: count ?? 0 }
}

async function fetchMahallalar(page: number) {
  const from = (page - 1) * PAGE_SIZE
  const { data, count } = await supabase
    .from('mahallalar')
    .select('id, name, description, building_photo_url, location_lat, location_lng', { count: 'exact' })
    .eq('is_published', true)
    .order('name')
    .range(from, from + PAGE_SIZE - 1)
  return { data: (data ?? []) as Mahalla[], count: count ?? 0 }
}

async function fetchYerMaydonlari(page: number) {
  const from = (page - 1) * PAGE_SIZE
  const { data, count } = await supabase
    .from('yer_maydonlari')
    .select('id, title, area_hectares, status, auction_url, description, location_lat, location_lng', { count: 'exact' })
    .eq('is_published', true)
    .order('title')
    .range(from, from + PAGE_SIZE - 1)
  return { data: (data ?? []) as YerMaydon[], count: count ?? 0 }
}

// ─── Sub-components ─────────────────────────────────────────────────────────────
function PersonCard({ person }: { person: Rahbariyat }) {
  const [expanded, setExpanded] = useState(false)
  const initials = getInitials(person.full_name)

  return (
    <div className="bg-white rounded-xl overflow-hidden hover:shadow-md transition-shadow">
      {/* Photo or initials */}
      <div className="flex items-start gap-4 p-4">
        {person.photo_url ? (
          <img
            src={person.photo_url}
            alt={person.full_name}
            className="w-16 h-16 rounded-xl object-cover shrink-0 bg-[#F7F6F3]"
          />
        ) : (
          <div className="w-16 h-16 rounded-xl bg-[#1D9E75]/10 flex items-center justify-center shrink-0">
            <span className="text-lg font-medium text-[#1D9E75]">{initials}</span>
          </div>
        )}
        <div className="flex-1 min-w-0">
          <p className="text-sm font-medium text-[#0A0A0A]">{person.full_name}</p>
          {person.birth_year && (
            <p className="text-[11px] text-[#888780] mt-0.5">{person.birth_year}-yil tug'ilgan</p>
          )}
          <p className="text-xs text-[#888780] mt-1 leading-snug">{person.position}</p>
          {person.phone && (
            <a
              href={`tel:${person.phone}`}
              className="inline-flex items-center gap-1 mt-2 text-xs text-[#1D9E75] hover:underline"
            >
              <Phone size={11} strokeWidth={1.8} />
              {person.phone}
            </a>
          )}
        </div>
      </div>

      {person.reception_days && (
        <div className="px-4 pb-3 -mt-1">
          <p className="text-[11px] text-[#888780]">
            <span className="font-medium text-[#0A0A0A]">Qabulxona: </span>
            {person.reception_days}
          </p>
        </div>
      )}

      {person.biography && (
        <div className="border-t border-[#F7F6F3] px-4 py-3">
          <button
            onClick={() => setExpanded(v => !v)}
            className="flex items-center gap-1 text-[11px] text-[#888780] hover:text-[#0A0A0A] transition-colors w-full"
          >
            {expanded ? <ChevronUp size={13} /> : <ChevronDown size={13} />}
            {expanded ? "Kamroq ko'rsatish" : "Tarjimai hol"}
          </button>
          {expanded && (
            <p className="text-xs text-[#888780] mt-2 leading-relaxed">{person.biography}</p>
          )}
        </div>
      )}
    </div>
  )
}

// ─── Shared pagination nav ────────────────────────────────────────────────────
function PageNav({ page, totalPages, onChange }: { page: number; totalPages: number; onChange: (p: number) => void }) {
  if (totalPages <= 1) return null
  return (
    <div className="flex items-center justify-center gap-2 mt-8">
      <button
        onClick={() => onChange(Math.max(1, page - 1))}
        disabled={page <= 1}
        className="p-2 rounded-lg border border-[#E8E6E1] text-[#888780] hover:text-[#0A0A0A] hover:border-[#0A0A0A] disabled:opacity-30 disabled:cursor-not-allowed transition-colors bg-white"
      >
        <ChevronLeft size={14} />
      </button>
      {Array.from({ length: Math.min(totalPages, 7) }, (_, i) => {
        const p = totalPages <= 7 ? i + 1 : i + Math.max(1, page - 3)
        if (p > totalPages) return null
        return (
          <button
            key={p}
            onClick={() => onChange(p)}
            className={cn(
              'w-8 h-8 text-xs rounded-lg border transition-colors',
              p === page ? 'bg-[#1D9E75] text-white border-[#1D9E75] font-medium' : 'bg-white text-[#888780] border-[#E8E6E1] hover:border-[#0A0A0A]',
            )}
          >
            {p}
          </button>
        )
      })}
      <button
        onClick={() => onChange(Math.min(totalPages, page + 1))}
        disabled={page >= totalPages}
        className="p-2 rounded-lg border border-[#E8E6E1] text-[#888780] hover:text-[#0A0A0A] hover:border-[#0A0A0A] disabled:opacity-30 disabled:cursor-not-allowed transition-colors bg-white"
      >
        <ChevronRight size={14} />
      </button>
    </div>
  )
}

const STATUS_LABELS: Record<string, { label: string; className: string }> = {
  active: { label: 'Faol', className: 'bg-[#1D9E75]/10 text-[#1D9E75]' },
  sold: { label: 'Sotilgan', className: 'bg-[#888780]/10 text-[#888780]' },
  pending: { label: 'Kutilmoqda', className: 'bg-[#FF9500]/10 text-[#FF9500]' },
}

const TABS = [
  { key: 'rahbariyat', label: 'Rahbariyat' },
  { key: 'apparat', label: "Apparat va boshqaruv" },
  { key: 'kengash', label: "Xalq deputatlari Kengashi" },
  { key: 'mahallalar', label: 'Mahallalar' },
  { key: 'yer', label: 'Yer maydonlari' },
]

// ─── Main page ──────────────────────────────────────────────────────────────────
export default function PortalHokimiyatPage() {
  const [searchParams, setSearchParams] = useSearchParams()
  const activeTab = searchParams.get('tab') ?? 'rahbariyat'

  // Per-tab page state
  const [rahPage, setRahPage] = useState(1)
  const [apparatPage, setApparatPage] = useState(1)
  const [kengashPage, setKengashPage] = useState(1)
  const [mahPage, setMahPage] = useState(1)
  const [yerPage, setYerPage] = useState(1)

  useEffect(() => { window.scrollTo({ top: 0 }) }, [activeTab])

  const { data: rahData } = useQuery({
    queryKey: ['public-rahbariyat', 'rahbariyat-tab', rahPage],
    queryFn: () => fetchRahbariyat(['hokim', 'apparat'], rahPage),
    enabled: activeTab === 'rahbariyat',
  })
  const { data: apparatData } = useQuery({
    queryKey: ['public-rahbariyat', 'apparat-tab', apparatPage],
    queryFn: () => fetchRahbariyat(['apparat'], apparatPage),
    enabled: activeTab === 'apparat',
  })
  const { data: kengashData } = useQuery({
    queryKey: ['public-rahbariyat', 'kengash-tab', kengashPage],
    queryFn: () => fetchRahbariyat(['kotibiyat', 'deputat'], kengashPage),
    enabled: activeTab === 'kengash',
  })
  const { data: mahData } = useQuery({
    queryKey: ['public-mahallalar', mahPage],
    queryFn: () => fetchMahallalar(mahPage),
    enabled: activeTab === 'mahallalar',
  })
  const { data: yerData } = useQuery({
    queryKey: ['public-yer', yerPage],
    queryFn: () => fetchYerMaydonlari(yerPage),
    enabled: activeTab === 'yer',
  })

  const rahbariyat = rahData?.data ?? []
  const apparatList = apparatData?.data ?? []
  const kengashList = kengashData?.data ?? []

  const hokim = rahbariyat.filter(r => r.category === 'hokim')
  const apparatInRah = rahbariyat.filter(r => r.category === 'apparat')
  const kotibiyat = kengashList.filter(r => r.category === 'kotibiyat')
  const deputat = kengashList.filter(r => r.category === 'deputat')

  function setTab(tab: string) {
    setSearchParams({ tab })
  }

  return (
    <div className="max-w-6xl mx-auto px-4 py-8">
      <h1 className="text-xl font-medium text-[#0A0A0A] mb-6">Tuman Hokimligi</h1>

      {/* Tabs */}
      <div className="flex gap-1 flex-wrap mb-8 bg-white p-1 rounded-xl border border-[#E8E6E1] w-fit">
        {TABS.map(({ key, label }) => (
          <button
            key={key}
            onClick={() => setTab(key)}
            className={cn(
              'px-4 py-2 text-sm rounded-lg transition-colors whitespace-nowrap',
              activeTab === key
                ? 'bg-[#1D9E75] text-white font-medium shadow-sm'
                : 'text-[#888780] hover:text-[#0A0A0A]',
            )}
          >
            {label}
          </button>
        ))}
      </div>

      {/* Rahbariyat tab */}
      {activeTab === 'rahbariyat' && (
        <div>
          {hokim.length > 0 && (
            <div className="mb-8">
              <h2 className="text-xs font-medium text-[#888780] uppercase tracking-wide mb-3">Hokim</h2>
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                {hokim.map(p => <PersonCard key={p.id} person={p} />)}
              </div>
            </div>
          )}
          {apparatInRah.length > 0 && (
            <div>
              <h2 className="text-xs font-medium text-[#888780] uppercase tracking-wide mb-3">Hokim o'rinbosarlari</h2>
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                {apparatInRah.map(p => <PersonCard key={p.id} person={p} />)}
              </div>
            </div>
          )}
          {hokim.length === 0 && apparatInRah.length === 0 && (
            <p className="text-sm text-[#888780]">Ma'lumot topilmadi</p>
          )}
          <PageNav page={rahPage} totalPages={Math.ceil((rahData?.count ?? 0) / PAGE_SIZE)} onChange={setRahPage} />
        </div>
      )}

      {/* Apparat tab */}
      {activeTab === 'apparat' && (
        <div>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {apparatList.map(p => <PersonCard key={p.id} person={p} />)}
          </div>
          {apparatList.length === 0 && <p className="text-sm text-[#888780]">Ma'lumot topilmadi</p>}
          <PageNav page={apparatPage} totalPages={Math.ceil((apparatData?.count ?? 0) / PAGE_SIZE)} onChange={setApparatPage} />
        </div>
      )}

      {/* Kengash tab */}
      {activeTab === 'kengash' && (
        <div>
          {kotibiyat.length > 0 && (
            <div className="mb-8">
              <h2 className="text-xs font-medium text-[#888780] uppercase tracking-wide mb-3">Kotibiyat</h2>
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                {kotibiyat.map(p => <PersonCard key={p.id} person={p} />)}
              </div>
            </div>
          )}
          {deputat.length > 0 && (
            <div>
              <h2 className="text-xs font-medium text-[#888780] uppercase tracking-wide mb-3">Deputatlar</h2>
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                {deputat.map(p => <PersonCard key={p.id} person={p} />)}
              </div>
            </div>
          )}
          {kotibiyat.length === 0 && deputat.length === 0 && (
            <p className="text-sm text-[#888780]">Ma'lumot topilmadi</p>
          )}
          <PageNav page={kengashPage} totalPages={Math.ceil((kengashData?.count ?? 0) / PAGE_SIZE)} onChange={setKengashPage} />
        </div>
      )}

      {/* Mahallalar tab */}
      {activeTab === 'mahallalar' && (
        <div>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {mahData?.data.map(m => (
              <div key={m.id} className="bg-white rounded-xl overflow-hidden hover:shadow-md transition-shadow">
                {m.building_photo_url ? (
                  <img
                    src={m.building_photo_url}
                    alt={m.name}
                    className="w-full h-36 object-cover bg-[#F7F6F3]"
                  />
                ) : (
                  <div className="w-full h-36 bg-[#FF6B6B]/10 flex items-center justify-center">
                    <MapPin size={28} className="text-[#FF6B6B]" strokeWidth={1.5} />
                  </div>
                )}
                <div className="p-4">
                  <p className="text-sm font-medium text-[#0A0A0A]">{m.name}</p>
                  {m.description && (
                    <p className="text-xs text-[#888780] mt-1.5 leading-relaxed line-clamp-3">{m.description}</p>
                  )}
                  {m.location_lat && m.location_lng && (
                    <a
                      href={`https://maps.google.com/?q=${m.location_lat},${m.location_lng}`}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="inline-flex items-center gap-1 mt-3 text-xs text-[#1D9E75] hover:underline"
                    >
                      <MapPin size={11} strokeWidth={1.8} /> Xaritada ko'rish
                    </a>
                  )}
                </div>
              </div>
            ))}
            {mahData?.data.length === 0 && <p className="text-sm text-[#888780]">Ma'lumot topilmadi</p>}
          </div>
          <PageNav page={mahPage} totalPages={Math.ceil((mahData?.count ?? 0) / PAGE_SIZE)} onChange={setMahPage} />
        </div>
      )}

      {/* Yer maydonlari tab */}
      {activeTab === 'yer' && (
        <div>
          <div className="flex flex-col gap-3">
            {yerData?.data.map(y => {
              const status = STATUS_LABELS[y.status] ?? { label: y.status, className: 'bg-[#888780]/10 text-[#888780]' }
              return (
                <div key={y.id} className="bg-white rounded-xl p-5 hover:shadow-md transition-shadow flex flex-col sm:flex-row sm:items-start gap-4">
                  <div className="flex-1">
                    <div className="flex items-start gap-3 flex-wrap">
                      <p className="text-sm font-medium text-[#0A0A0A] flex-1">{y.title}</p>
                      <span className={cn('text-[11px] px-2 py-0.5 rounded-full font-medium shrink-0', status.className)}>
                        {status.label}
                      </span>
                    </div>
                    {y.area_hectares && (
                      <p className="text-xs text-[#888780] mt-1.5">{y.area_hectares} gektar</p>
                    )}
                    {y.description && (
                      <p className="text-xs text-[#888780] mt-2 leading-relaxed">{y.description}</p>
                    )}
                    <div className="flex items-center gap-4 mt-3 flex-wrap">
                      {y.location_lat && y.location_lng && (
                        <a
                          href={`https://maps.google.com/?q=${y.location_lat},${y.location_lng}`}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="inline-flex items-center gap-1 text-xs text-[#888780] hover:text-[#0A0A0A]"
                        >
                          <MapPin size={11} strokeWidth={1.8} /> Xaritada
                        </a>
                      )}
                      {y.auction_url && (
                        <a
                          href={y.auction_url}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="inline-flex items-center gap-1 text-xs text-[#1D9E75] hover:underline"
                        >
                          <ExternalLink size={11} strokeWidth={1.8} /> E-auksion
                        </a>
                      )}
                    </div>
                  </div>
                </div>
              )
            })}
            {yerData?.data.length === 0 && <p className="text-sm text-[#888780]">Ma'lumot topilmadi</p>}
          </div>
          <PageNav page={yerPage} totalPages={Math.ceil((yerData?.count ?? 0) / PAGE_SIZE)} onChange={setYerPage} />
        </div>
      )}
    </div>
  )
}
