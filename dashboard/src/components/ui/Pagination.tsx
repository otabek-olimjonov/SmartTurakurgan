import { ChevronLeft, ChevronRight } from 'lucide-react'
import Button from './Button'

interface PaginationProps {
  page: number
  totalPages: number
  onChange: (page: number) => void
}

export default function Pagination({ page, totalPages, onChange }: PaginationProps) {
  if (totalPages <= 1) return null
  return (
    <div className="flex items-center gap-2 justify-end mt-4">
      <Button
        size="sm"
        disabled={page <= 1}
        onClick={() => onChange(page - 1)}
        aria-label="Oldingi"
      >
        <ChevronLeft size={14} />
      </Button>
      <span className="text-xs text-[#888780]">
        {page} / {totalPages}
      </span>
      <Button
        size="sm"
        disabled={page >= totalPages}
        onClick={() => onChange(page + 1)}
        aria-label="Keyingi"
      >
        <ChevronRight size={14} />
      </Button>
    </div>
  )
}
