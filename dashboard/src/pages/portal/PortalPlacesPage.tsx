import { useState, useEffect } from 'react'
import { useParams } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { supabase } from '../../lib/supabase'
import { cn } from '../../lib/utils'
import { Phone, MapPin, Star, TreePine, GraduationCap, Heart, Briefcase, ImageOff, ChevronLeft, ChevronRight } from 'lucide-react'

const PAGE_SIZE = 20

// ─── Config ─────────────────────────────────────────────────────────────────────
type SectionConf = {
  title: string
  icon: React.ElementType
  iconBg: string
  iconColor: string
  allCategories: string[]
  filters: { key: string; label: string }[]
}

const SECTION_CONFIG: Record<string, SectionConf> = {
  turizm: {
    title: 'Turizm',
    icon: TreePine,
    iconBg: 'bg-[#30B0C7]/10',
    iconColor: 'text-[#30B0C7]',
    allCategories: ['diqqat_joy', 'ovqatlanish', 'mexmonxona'],
    filters: [
      { key: 'all', label: 'Barchasi' },
      { key: 'diqqat_joy', label: 'Diqqatga sazovor' },
      { key: 'ovqatlanish', label: 'Restoran / Choyxona' },
      { key: 'mexmonxona', label: 'Mehmonxona' },
    ],
  },
  talim: {
    title: "Ta'lim",
    icon: GraduationCap,
    iconBg: 'bg-[#FF9500]/10',
    iconColor: 'text-[#FF9500]',
    allCategories: ['oquv_markaz', 'maktabgacha', 'maktab', 'texnikum', 'oliy_talim'],
    filters: [
      { key: 'all', label: 'Barchasi' },
      { key: 'oquv_markaz', label: "O'quv markazi" },
      { key: 'maktabgacha', label: "Maktabgacha ta'lim" },
      { key: 'maktab', label: 'Maktab' },
      { key: 'texnikum', label: 'Texnikum / Kollej' },
      { key: 'oliy_talim', label: "Oliy ta'lim" },
    ],
  },
  tibbiyot: {
    title: 'Tibbiyot',
    icon: Heart,
    iconBg: 'bg-[#34C759]/10',
    iconColor: 'text-[#34C759]',
    allCategories: ['davlat_tibbiyot', 'xususiy_tibbiyot'],
    filters: [
      { key: 'all', label: 'Barchasi' },
      { key: 'davlat_tibbiyot', label: 'Davlat tibbiyot muassasasi' },
      { key: 'xususiy_tibbiyot', label: 'Xususiy klinika' },
    ],
  },
  tashkilotlar: {
    title: 'Tashkilotlar',
    icon: Briefcase,
    iconBg: 'bg-[#007AFF]/10',
    iconColor: 'text-[#007AFF]',
    allCategories: ['davlat_tashkilot', 'xususiy_korxona'],
    filters: [
      { key: 'all', label: 'Barchasi' },
      { key: 'davlat_tashkilot', label: 'Davlat tashkiloti' },
      { key: 'xususiy_korxona', label: 'Xususiy korxona' },
    ],
  },
}

const CATEGORY_LABELS: Record<string, string> = {
  diqqat_joy: 'Diqqatga sazovor',
  ovqatlanish: 'Restoran',
  mexmonxona: 'Mehmonxona',
  oquv_markaz: "O'quv markazi",
  maktabgacha: "Maktabgacha ta'lim",
  maktab: 'Maktab',
  texnikum: 'Texnikum',
  oliy_talim: "Oliy ta'lim",
  davlat_tibbiyot: 'Davlat tibbiyot',
  xususiy_tibbiyot: 'Xususiy klinika',
  davlat_tashkilot: 'Davlat tashkiloti',
  xususiy_korxona: 'Xususiy korxona',
}

// ─── Types ───────────────────────────────────────────────────────────────────────
type PlaceImage = { image_url: string; sort_order: number }

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
  comment_count: number
  place_images: PlaceImage[]
}

// ─── Fetcher ─────────────────────────────────────────────────────────────────────
async function fetchPlaces(categories: string[], page: number) {
  const from = (page - 1) * PAGE_SIZE
  const { data, count, error } = await supabase
    .from('places')
    .select('id, name, category, director, phone, description, location_lat, location_lng, rating, comment_count, place_images(image_url, sort_order)', { count: 'exact' })
    .eq('is_published', true)
    .in('category', categories)
    .order('rating', { ascending: false })
    .range(from, from + PAGE_SIZE - 1)
  if (error) throw error
  return { data: (data ?? []) as Place[], count: count ?? 0 }
}

// ─── PlaceCard ──────────────────────────────────────────────────────────────────
function PlaceCard({ place }: { place: Place }) {
  const [expanded, setExpanded] = useState(false)
  const cover = place.place_images
    ?.sort((a, b) => a.sort_order - b.sort_order)
    ?.find(i => i.image_url)

  return (
    <div className="bg-white rounded-xl overflow-hidden hover:shadow-md transition-shadow">
      {cover?.image_url ? (
        <img src={cover.image_url} alt={place.name} className="w-full h-44 object-cover bg-[#F7F6F3]" />
      ) : (
        <div className="w-full h-44 bg-[#F7F6F3] flex items-center justify-center">
          <ImageOff size={24} className="text-[#E8E6E1]" />
        </div>
      )}
      <div className="p-4">
        <div className="flex items-start justify-between gap-2 mb-1">
          <span className="text-[10px] bg-[#F7F6F3] text-[#888780] px-2 py-0.5 rounded-full">
            {CATEGORY_LABELS[place.category] ?? place.category}
          </span>
          {place.rating > 0 && (
            <div className="flex items-center gap-0.5 shrink-0">
              <Star size={11} className="text-[#FF9500] fill-[#FF9500]" />
              <span className="text-[11px] text-[#888780]">{place.rating.toFixed(1)}</span>
            </div>
          )}
        </div>
        <p className="text-sm font-medium text-[#0A0A0A] mt-1.5">{place.name}</p>
        {place.director && (
          <p className="text-[11px] text-[#888780] mt-0.5">Rahbar: {place.director}</p>
        )}

        {/* Action row */}
        <div className="flex items-center gap-2 mt-3 flex-wrap">
          {place.phone && (
            <a
              href={`tel:${place.phone}`}
              className="inline-flex items-center gap-1 text-xs text-[#1D9E75] bg-[#1D9E75]/8 px-2.5 py-1.5 rounded-lg hover:bg-[#1D9E75]/15 transition-colors"
            >
              <Phone size={11} strokeWidth={1.8} /> {place.phone}
            </a>
          )}
          {place.location_lat && place.location_lng && (
            <a
              href={`https://maps.google.com/?q=${place.location_lat},${place.location_lng}`}
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-1 text-xs text-[#888780] bg-[#F7F6F3] px-2.5 py-1.5 rounded-lg hover:bg-[#E8E6E1] transition-colors"
            >
              <MapPin size={11} strokeWidth={1.8} /> Xarita
            </a>
          )}
        </div>

        {/* Description */}
        {place.description && (
          <div className="mt-3">
            <p className={cn('text-xs text-[#888780] leading-relaxed', !expanded && 'line-clamp-2')}>
              {place.description}
            </p>
            {place.description.length > 100 && (
              <button
                onClick={() => setExpanded(v => !v)}
                className="text-[11px] text-[#1D9E75] mt-1 hover:underline"
              >
                {expanded ? "Kamroq" : "Ko'proq"}
              </button>
            )}
          </div>
        )}
      </div>
    </div>
  )
}

// ─── Main page ──────────────────────────────────────────────────────────────────
export default function PortalPlacesPage() {
  const { section } = useParams<{ section: string }>()
  const config = SECTION_CONFIG[section ?? '']
  const [activeFilter, setActiveFilter] = useState('all')
  const [page, setPage] = useState(1)

  // Reset page when filter or section changes
  useEffect(() => { setPage(1) }, [activeFilter, section])

  const filteredCategories =
    activeFilter === 'all' ? config?.allCategories ?? [] : [activeFilter]

  const { data, isLoading } = useQuery({
    queryKey: ['public-places', section, activeFilter, page],
    queryFn: () => fetchPlaces(filteredCategories, page),
    enabled: !!config && filteredCategories.length > 0,
  })

  const places = data?.data ?? []
  const totalPages = Math.ceil((data?.count ?? 0) / PAGE_SIZE)

  if (!config) {
    return (
      <div className="max-w-6xl mx-auto px-4 py-16 text-center">
        <p className="text-sm text-[#888780]">Bo'lim topilmadi</p>
      </div>
    )
  }

  const Icon = config.icon

  return (
    <div className="max-w-6xl mx-auto px-4 py-8">
      {/* Header */}
      <div className="flex items-center gap-3 mb-6">
        <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${config.iconBg}`}>
          <Icon size={18} className={config.iconColor} strokeWidth={1.8} />
        </div>
        <div>
          <h1 className="text-xl font-medium text-[#0A0A0A]">{config.title}</h1>
          <p className="text-xs text-[#888780]">{data?.count ?? 0} ta ob'ekt</p>
        </div>
      </div>

      {/* Filter chips */}
      <div className="flex gap-2 flex-wrap mb-6">
        {config.filters.map(({ key, label }) => (
          <button
            key={key}
            onClick={() => setActiveFilter(key)}
            className={cn(
              'px-3 py-1.5 text-xs rounded-full border transition-colors',
              activeFilter === key
                ? 'bg-[#1D9E75] text-white border-[#1D9E75]'
                : 'bg-white text-[#888780] border-[#E8E6E1] hover:border-[#0A0A0A] hover:text-[#0A0A0A]',
            )}
          >
            {label}
          </button>
        ))}
      </div>

      {/* Places grid */}
      {isLoading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {[...Array(6)].map((_, i) => (
            <div key={i} className="bg-white rounded-xl h-64 animate-pulse" />
          ))}
        </div>
      ) : places.length === 0 ? (
        <div className="py-16 text-center">
          <p className="text-sm text-[#888780]">Ma'lumot topilmadi</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {places.map(p => <PlaceCard key={p.id} place={p} />)}
        </div>
      )}

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="flex items-center justify-center gap-2 mt-8">
          <button
            onClick={() => setPage(p => Math.max(1, p - 1))}
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
                onClick={() => setPage(p)}
                className={cn(
                  'w-8 h-8 text-xs rounded-lg border transition-colors',
                  p === page
                    ? 'bg-[#1D9E75] text-white border-[#1D9E75] font-medium'
                    : 'bg-white text-[#888780] border-[#E8E6E1] hover:border-[#0A0A0A] hover:text-[#0A0A0A]',
                )}
              >
                {p}
              </button>
            )
          })}
          <button
            onClick={() => setPage(p => Math.min(totalPages, p + 1))}
            disabled={page >= totalPages}
            className="p-2 rounded-lg border border-[#E8E6E1] text-[#888780] hover:text-[#0A0A0A] hover:border-[#0A0A0A] disabled:opacity-30 disabled:cursor-not-allowed transition-colors bg-white"
          >
            <ChevronRight size={14} />
          </button>
        </div>
      )}
    </div>
  )
}
