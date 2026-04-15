import { Link } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { supabase } from '../../lib/supabase'
import { formatDistanceToNow } from 'date-fns'
import { uz } from 'date-fns/locale'
import {
  Landmark, TreePine, GraduationCap, Heart, Briefcase,
  Newspaper, Home, MessageSquare, ArrowRight, ChevronRight, Building2,
} from 'lucide-react'

async function fetchLatestNews() {
  const { data } = await supabase
    .from('yangiliklar')
    .select('id, title, cover_image_url, category, published_at')
    .eq('is_published', true)
    .order('published_at', { ascending: false })
    .limit(6)
  return data ?? []
}

const MODULES = [
  {
    label: 'Tuman Hokimligi',
    icon: Landmark,
    to: '/hokimiyat',
    bg: 'bg-[#5856D6]/10',
    color: 'text-[#5856D6]',
    desc: 'Rahbariyat, mahallalar, yer maydonlari',
  },
  {
    label: 'Turizm',
    icon: TreePine,
    to: '/turizm',
    bg: 'bg-[#30B0C7]/10',
    color: 'text-[#30B0C7]',
    desc: 'Diqqatga sazovor joylar, mehmonxonalar',
  },
  {
    label: "Ta'lim",
    icon: GraduationCap,
    to: '/talim',
    bg: 'bg-[#FF9500]/10',
    color: 'text-[#FF9500]',
    desc: "Maktablar, universitetlar, o'quv markazlari",
  },
  {
    label: 'Tibbiyot',
    icon: Heart,
    to: '/tibbiyot',
    bg: 'bg-[#34C759]/10',
    color: 'text-[#34C759]',
    desc: 'Davlat va xususiy tibbiyot muassasalari',
  },
  {
    label: 'Tashkilotlar',
    icon: Briefcase,
    to: '/tashkilotlar',
    bg: 'bg-[#007AFF]/10',
    color: 'text-[#007AFF]',
    desc: 'Davlat tashkilotlari va xususiy korxonalar',
  },
  {
    label: 'Yangiliklar',
    icon: Newspaper,
    to: '/yangiliklar',
    bg: 'bg-[#FF6B6B]/10',
    color: 'text-[#FF6B6B]',
    desc: "Tuman yangiliklari va e'lonlar",
  },
  {
    label: 'Mahallalar',
    icon: Home,
    to: '/hokimiyat?tab=mahallalar',
    bg: 'bg-[#FF6B6B]/10',
    color: 'text-[#FF6B6B]',
    desc: "Tuman mahalla fuqarolar yig'inlari",
  },
  {
    label: 'Yer maydonlari',
    icon: Building2,
    to: '/hokimiyat?tab=yer',
    bg: 'bg-[#C8A96E]/10',
    color: 'text-[#C8A96E]',
    desc: "Elektron auksion yer maydonlari",
  },
  {
    label: "Bog'lanish",
    icon: MessageSquare,
    to: '/boglanish',
    bg: 'bg-[#AF52DE]/10',
    color: 'text-[#AF52DE]',
    desc: "Murojaat yozish va aloqa ma'lumotlari",
  },
]

export default function PortalHomePage() {
  const { data: news } = useQuery({ queryKey: ['public-news-home'], queryFn: fetchLatestNews })

  return (
    <div>
      {/* Hero */}
      <div className="bg-white border-b border-[#E8E6E1]">
        <div className="max-w-6xl mx-auto px-4 py-16 md:py-20 text-center">
          <div className="inline-block px-3 py-1 rounded-full bg-[#1D9E75]/10 text-[#1D9E75] text-xs font-medium mb-5">
            Turakurgan tumani — Namangan viloyati
          </div>
          <h1 className="text-3xl md:text-4xl font-medium text-[#0A0A0A] mb-3 leading-tight">
            Barcha xizmatlar —<br className="hidden md:block" /> bitta joyda
          </h1>
          <p className="text-[#888780] text-sm max-w-md mx-auto mb-8 leading-relaxed">
            Tuman hokimiyati, ta'lim, tibbiyot, turizm va boshqa davlat xizmatlari haqida to'liq ma'lumot.
          </p>
          <div className="flex items-center justify-center gap-3 flex-wrap">
            <Link
              to="/boglanish"
              className="bg-[#1D9E75] text-white text-sm px-6 py-2.5 rounded-lg hover:bg-[#178a65] transition-colors"
            >
              Murojaat yozish
            </Link>
            <Link
              to="/yangiliklar"
              className="bg-[#F7F6F3] text-[#0A0A0A] text-sm px-6 py-2.5 rounded-lg hover:bg-[#E8E6E1] transition-colors border border-[#E8E6E1]"
            >
              Yangiliklar
            </Link>
          </div>
        </div>
      </div>

      <div className="max-w-6xl mx-auto px-4 py-10">
        {/* Module grid */}
        <h2 className="text-xs font-medium text-[#888780] uppercase tracking-wide mb-4">Xizmatlar bo'limlari</h2>
        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-3 mb-14">
          {MODULES.map(({ label, icon: Icon, to, bg, color, desc }) => (
            <Link
              key={label}
              to={to}
              className="bg-white rounded-xl p-4 flex flex-col gap-3 hover:shadow-md transition-all group border border-transparent hover:border-[#E8E6E1]"
            >
              <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${bg} shrink-0`}>
                <Icon size={18} className={color} strokeWidth={1.8} />
              </div>
              <div className="flex-1">
                <p className="text-sm font-medium text-[#0A0A0A]">{label}</p>
                <p className="text-[11px] text-[#888780] mt-0.5 line-clamp-2 leading-snug">{desc}</p>
              </div>
              <ChevronRight size={13} className={`${color} opacity-0 group-hover:opacity-100 transition-opacity`} />
            </Link>
          ))}
        </div>

        {/* Latest news */}
        {news && news.length > 0 && (
          <div className="mb-14">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-xs font-medium text-[#888780] uppercase tracking-wide">So'nggi yangiliklar</h2>
              <Link
                to="/yangiliklar"
                className="text-xs text-[#1D9E75] hover:underline flex items-center gap-0.5"
              >
                Barchasi <ArrowRight size={11} />
              </Link>
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
              {news.map((n) => (
                <Link
                  key={n.id}
                  to={`/yangiliklar/${n.id}`}
                  className="bg-white rounded-xl overflow-hidden hover:shadow-md transition-all group"
                >
                  {n.cover_image_url ? (
                    <img src={n.cover_image_url} alt={n.title} className="w-full h-44 object-cover" />
                  ) : (
                    <div className="w-full h-44 bg-[#F7F6F3] flex items-center justify-center">
                      <Newspaper size={28} className="text-[#E8E6E1]" />
                    </div>
                  )}
                  <div className="p-4">
                    {n.category && (
                      <span className="text-[9px] bg-[#1D9E75] text-white px-1.5 py-0.5 rounded-full font-medium">
                        {n.category}
                      </span>
                    )}
                    <p className="text-sm font-medium text-[#0A0A0A] mt-2 line-clamp-2 leading-snug group-hover:text-[#1D9E75] transition-colors">
                      {n.title}
                    </p>
                    {n.published_at && (
                      <p className="text-[11px] text-[#888780] mt-1.5">
                        {formatDistanceToNow(new Date(n.published_at), { addSuffix: true, locale: uz })}
                      </p>
                    )}
                  </div>
                </Link>
              ))}
            </div>
          </div>
        )}

        {/* Murojaat CTA */}
        <div className="bg-[#1D9E75]/8 rounded-2xl p-8 flex flex-col md:flex-row items-center justify-between gap-5">
          <div>
            <h3 className="text-base font-medium text-[#0A0A0A]">Murojaatingiz bormi?</h3>
            <p className="text-sm text-[#888780] mt-1 max-w-sm">
              Tuman hokimiyatiga rasmiy murojaat yo'llang. Barcha murojaatlar ko'rib chiqiladi.
            </p>
          </div>
          <Link
            to="/boglanish"
            className="bg-[#1D9E75] text-white text-sm px-7 py-3 rounded-lg hover:bg-[#178a65] transition-colors shrink-0"
          >
            Murojaat yozish
          </Link>
        </div>
      </div>
    </div>
  )
}
