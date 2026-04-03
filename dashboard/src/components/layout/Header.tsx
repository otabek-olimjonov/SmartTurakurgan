import { useLocation } from 'react-router-dom'
import { useAuthStore } from '../../store/auth.store'
import { LogOut } from 'lucide-react'
import { getInitials } from '../../lib/utils'

const TITLES: Record<string, string> = {
  '/dashboard': 'Dashboard',
  '/rahbariyat': 'Rahbariyat',
  '/mahallalar': 'Mahallalar',
  '/yer': 'Yer maydonlari',
  '/yangiliklar': 'Yangiliklar',
  '/murojaatlar': 'Murojaatlar',
  '/notifications': 'Bildirishnomalar',
  '/admins': 'Foydalanuvchilar',
}

function getTitle(pathname: string): string {
  if (pathname.startsWith('/places/tourism')) return 'Turizm joylari'
  if (pathname.startsWith('/places/education')) return "Ta'lim muassasalari"
  if (pathname.startsWith('/places/healthcare')) return 'Tibbiyot muassasalari'
  if (pathname.startsWith('/places/organization')) return 'Tashkilotlar'
  return TITLES[pathname] ?? 'Admin panel'
}

export default function Header() {
  const { pathname } = useLocation()
  const { session, profile, signOut } = useAuthStore()
  const email = session?.user.email ?? ''
  const name = profile?.full_name ?? (session?.user.user_metadata?.full_name as string | undefined)

  return (
    <header className="h-12 bg-white border-b border-[#E8E6E1] flex items-center px-5 gap-4 shrink-0">
      <h1 className="flex-1 text-sm font-medium text-[#0A0A0A]">
        {getTitle(pathname)}
      </h1>
      <div className="flex items-center gap-2.5">
        <div className="w-7 h-7 rounded-full bg-[#1D9E75]/15 flex items-center justify-center text-[11px] font-medium text-[#1D9E75]">
          {getInitials(name ?? email)}
        </div>
        <span className="text-xs text-[#888780] hidden sm:block">{name ?? email}</span>
        <button
          onClick={signOut}
          title="Chiqish"
          className="p-1 text-[#888780] hover:text-[#E24B4A] transition-colors"
        >
          <LogOut size={15} />
        </button>
      </div>
    </header>
  )
}
