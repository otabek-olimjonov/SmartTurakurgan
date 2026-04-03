import { cn } from '../../lib/utils'

type Variant = 'success' | 'warning' | 'danger' | 'default'

const VARIANTS: Record<Variant, string> = {
  success: 'bg-[#1D9E75]/10 text-[#1D9E75]',
  warning: 'bg-[#BA7517]/10 text-[#BA7517]',
  danger: 'bg-[#E24B4A]/10 text-[#E24B4A]',
  default: 'bg-[#E8E6E1] text-[#888780]',
}

interface BadgeProps {
  label: string
  variant?: Variant
  className?: string
}

export default function Badge({ label, variant = 'default', className }: BadgeProps) {
  return (
    <span
      className={cn(
        'inline-flex items-center px-2 py-0.5 rounded text-xs font-medium',
        VARIANTS[variant],
        className,
      )}
    >
      {label}
    </span>
  )
}

export function statusBadge(status: string) {
  const map: Record<string, { label: string; variant: Variant }> = {
    pending: { label: 'Kutilmoqda', variant: 'warning' },
    in_review: { label: "Ko'rib chiqilmoqda", variant: 'default' },
    resolved: { label: 'Hal qilindi', variant: 'success' },
    active: { label: 'Aktiv', variant: 'success' },
    sold: { label: 'Sotilgan', variant: 'danger' },
    published: { label: 'Chop etilgan', variant: 'success' },
    draft: { label: 'Qoralama', variant: 'default' },
  }
  const entry = map[status] ?? { label: status, variant: 'default' as Variant }
  return <Badge label={entry.label} variant={entry.variant} />
}
