type ClassValue = string | undefined | null | boolean | Record<string, boolean>

export function cn(...classes: ClassValue[]): string {
  return classes
    .flatMap((c) => {
      if (!c) return []
      if (typeof c === 'string') return [c]
      if (typeof c === 'object') {
        return Object.entries(c)
          .filter(([, v]) => v)
          .map(([k]) => k)
      }
      return []
    })
    .join(' ')
}

export function formatDate(dateStr: string): string {
  return new Date(dateStr).toLocaleDateString('uz-UZ', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  })
}

export function getInitials(name: string): string {
  return name
    .split(' ')
    .slice(0, 2)
    .map((n) => n[0]?.toUpperCase() ?? '')
    .join('')
}
