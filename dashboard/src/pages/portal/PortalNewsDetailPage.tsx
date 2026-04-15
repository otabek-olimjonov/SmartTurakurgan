import { Link, useParams } from 'react-router-dom'
import { useQuery } from '@tanstack/react-query'
import { supabase } from '../../lib/supabase'
import { formatDate } from '../../lib/utils'
import { ArrowLeft, Newspaper } from 'lucide-react'

type YangilikDetail = {
  id: string
  title: string
  body: string | null
  cover_image_url: string | null
  category: string
  published_at: string | null
}

async function fetchNewsDetail(id: string) {
  const { data } = await supabase
    .from('yangiliklar')
    .select('id, title, body, cover_image_url, category, published_at')
    .eq('id', id)
    .eq('is_published', true)
    .single()
  return data as YangilikDetail | null
}

async function fetchRelatedNews(id: string, category: string) {
  const { data } = await supabase
    .from('yangiliklar')
    .select('id, title, cover_image_url, published_at')
    .eq('is_published', true)
    .eq('category', category)
    .neq('id', id)
    .order('published_at', { ascending: false })
    .limit(3)
  return data ?? []
}

export default function PortalNewsDetailPage() {
  const { id } = useParams<{ id: string }>()

  const { data: news, isLoading } = useQuery({
    queryKey: ['public-news-detail', id],
    queryFn: () => fetchNewsDetail(id!),
    enabled: !!id,
  })

  const { data: related } = useQuery({
    queryKey: ['public-news-related', id, news?.category],
    queryFn: () => fetchRelatedNews(id!, news!.category),
    enabled: !!news?.category,
  })

  if (isLoading) {
    return (
      <div className="max-w-3xl mx-auto px-4 py-8">
        <div className="animate-pulse space-y-4">
          <div className="h-6 bg-[#F7F6F3] rounded w-1/3" />
          <div className="h-64 bg-[#F7F6F3] rounded-xl" />
          <div className="h-4 bg-[#F7F6F3] rounded w-3/4" />
          <div className="h-4 bg-[#F7F6F3] rounded w-full" />
          <div className="h-4 bg-[#F7F6F3] rounded w-2/3" />
        </div>
      </div>
    )
  }

  if (!news) {
    return (
      <div className="max-w-3xl mx-auto px-4 py-16 text-center">
        <p className="text-sm text-[#888780]">Yangilik topilmadi</p>
        <Link to="/yangiliklar" className="text-sm text-[#1D9E75] hover:underline mt-3 inline-block">
          Yangiliklarga qaytish
        </Link>
      </div>
    )
  }

  return (
    <div className="max-w-3xl mx-auto px-4 py-8">
      {/* Back */}
      <Link
        to="/yangiliklar"
        className="inline-flex items-center gap-1.5 text-sm text-[#888780] hover:text-[#0A0A0A] transition-colors mb-6"
      >
        <ArrowLeft size={15} strokeWidth={1.8} />
        Yangiliklarga qaytish
      </Link>

      {/* Article */}
      <article className="bg-white rounded-xl overflow-hidden">
        {news.cover_image_url ? (
          <img
            src={news.cover_image_url}
            alt={news.title}
            className="w-full max-h-80 object-cover bg-[#F7F6F3]"
          />
        ) : (
          <div className="w-full h-48 bg-[#F7F6F3] flex items-center justify-center">
            <Newspaper size={36} className="text-[#E8E6E1]" />
          </div>
        )}

        <div className="p-6 md:p-8">
          <div className="flex items-center gap-3 mb-4">
            {news.category && (
              <span className="text-[10px] bg-[#1D9E75] text-white px-2 py-0.5 rounded-full font-medium">
                {news.category}
              </span>
            )}
            {news.published_at && (
              <span className="text-xs text-[#888780]">{formatDate(news.published_at)}</span>
            )}
          </div>

          <h1 className="text-xl font-medium text-[#0A0A0A] leading-snug mb-6">{news.title}</h1>

          {news.body && (
            <div className="text-sm text-[#0A0A0A] leading-[1.8] whitespace-pre-wrap">{news.body}</div>
          )}
        </div>
      </article>

      {/* Related */}
      {related && related.length > 0 && (
        <div className="mt-10">
          <h2 className="text-xs font-medium text-[#888780] uppercase tracking-wide mb-4">O'xshash yangiliklar</h2>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            {related.map((n: { id: string; title: string; cover_image_url: string | null; published_at: string | null }) => (
              <Link
                key={n.id}
                to={`/yangiliklar/${n.id}`}
                className="bg-white rounded-xl overflow-hidden hover:shadow-md transition-all group"
              >
                {n.cover_image_url ? (
                  <img src={n.cover_image_url} alt={n.title} className="w-full h-32 object-cover" />
                ) : (
                  <div className="w-full h-32 bg-[#F7F6F3] flex items-center justify-center">
                    <Newspaper size={20} className="text-[#E8E6E1]" />
                  </div>
                )}
                <div className="p-3">
                  <p className="text-xs font-medium text-[#0A0A0A] line-clamp-2 group-hover:text-[#1D9E75] transition-colors">
                    {n.title}
                  </p>
                  {n.published_at && (
                    <p className="text-[10px] text-[#888780] mt-1">{formatDate(n.published_at)}</p>
                  )}
                </div>
              </Link>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}
