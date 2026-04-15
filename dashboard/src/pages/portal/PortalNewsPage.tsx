import { useState } from 'react'
import { Link } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { supabase } from '../../lib/supabase'
import { formatDistanceToNow } from 'date-fns'
import { uz } from 'date-fns/locale'
import { Newspaper, ChevronLeft, ChevronRight } from 'lucide-react'

const PAGE_SIZE = 12

type Yangilik = {
  id: string
  title: string
  cover_image_url: string | null
  category: string
  published_at: string | null
}

async function fetchNews(page: number) {
  const from = (page - 1) * PAGE_SIZE
  const { data, count } = await supabase
    .from('yangiliklar')
    .select('id, title, cover_image_url, category, published_at', { count: 'exact' })
    .eq('is_published', true)
    .order('published_at', { ascending: false })
    .range(from, from + PAGE_SIZE - 1)
  return { data: (data ?? []) as Yangilik[], count: count ?? 0 }
}

export default function PortalNewsPage() {
  const [page, setPage] = useState(1)
  const { data, isLoading } = useQuery({
    queryKey: ['public-news', page],
    queryFn: () => fetchNews(page),
  })

  const totalPages = Math.ceil((data?.count ?? 0) / PAGE_SIZE)

  return (
    <div className="max-w-6xl mx-auto px-4 py-8">
      <div className="flex items-center gap-3 mb-6">
        <div className="w-10 h-10 rounded-xl bg-[#FF6B6B]/10 flex items-center justify-center">
          <Newspaper size={18} className="text-[#FF6B6B]" strokeWidth={1.8} />
        </div>
        <div>
          <h1 className="text-xl font-medium text-[#0A0A0A]">Yangiliklar</h1>
          {data && <p className="text-xs text-[#888780]">{data.count} ta yangilik</p>}
        </div>
      </div>

      {isLoading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {[...Array(6)].map((_, i) => (
            <div key={i} className="bg-white rounded-xl h-72 animate-pulse" />
          ))}
        </div>
      ) : (
        <>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 mb-8">
            {data?.data.map((n) => (
              <Link
                key={n.id}
                to={`/yangiliklar/${n.id}`}
                className="bg-white rounded-xl overflow-hidden hover:shadow-md transition-all group"
              >
                {n.cover_image_url ? (
                  <img src={n.cover_image_url} alt={n.title} className="w-full h-44 object-cover bg-[#F7F6F3]" />
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
                  <p className="text-sm font-medium text-[#0A0A0A] mt-2 line-clamp-3 leading-snug group-hover:text-[#1D9E75] transition-colors">
                    {n.title}
                  </p>
                  {n.published_at && (
                    <p className="text-[11px] text-[#888780] mt-2">
                      {formatDistanceToNow(new Date(n.published_at), { addSuffix: true, locale: uz })}
                    </p>
                  )}
                </div>
              </Link>
            ))}
          </div>

          {/* Pagination */}
          {totalPages > 1 && (
            <div className="flex items-center justify-center gap-2">
              <button
                onClick={() => setPage(p => Math.max(1, p - 1))}
                disabled={page === 1}
                className="p-2 rounded-lg border border-[#E8E6E1] text-[#888780] hover:text-[#0A0A0A] disabled:opacity-40 disabled:cursor-not-allowed bg-white"
              >
                <ChevronLeft size={16} />
              </button>
              {[...Array(totalPages)].map((_, i) => (
                <button
                  key={i}
                  onClick={() => setPage(i + 1)}
                  className={`w-8 h-8 rounded-lg text-sm border transition-colors ${
                    page === i + 1
                      ? 'bg-[#1D9E75] text-white border-[#1D9E75]'
                      : 'bg-white text-[#888780] border-[#E8E6E1] hover:border-[#0A0A0A] hover:text-[#0A0A0A]'
                  }`}
                >
                  {i + 1}
                </button>
              ))}
              <button
                onClick={() => setPage(p => Math.min(totalPages, p + 1))}
                disabled={page === totalPages}
                className="p-2 rounded-lg border border-[#E8E6E1] text-[#888780] hover:text-[#0A0A0A] disabled:opacity-40 disabled:cursor-not-allowed bg-white"
              >
                <ChevronRight size={16} />
              </button>
            </div>
          )}
        </>
      )}
    </div>
  )
}
