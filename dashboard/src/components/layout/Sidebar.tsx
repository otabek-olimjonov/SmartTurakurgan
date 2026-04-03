import { NavLink } from 'react-router-dom'
import { cn } from '../../lib/utils'
import { useAuthStore } from '../../store/auth.store'
import {
  LayoutDashboard,
  Users,
  MapPin,
  Building2,
  GraduationCap,
  Heart,
  Briefcase,
  Newspaper,
  MessageSquare,
  Bell,
  TreePine,
  UserCog,
} from 'lucide-react'

const NAV_ITEMS = [
  { label: 'Dashboard', to: '/dashboard', icon: LayoutDashboard },
  { label: 'Rahbariyat', to: '/rahbariyat', icon: Users },
  { label: 'Mahallalar', to: '/mahallalar', icon: MapPin },
  { label: 'Turizm', to: '/places/tourism', icon: TreePine },
  { label: "Ta'lim", to: '/places/education', icon: GraduationCap },
  { label: 'Tibbiyot', to: '/places/healthcare', icon: Heart },
  { label: 'Tashkilotlar', to: '/places/organization', icon: Briefcase },
  { label: 'Yer maydonlari', to: '/yer', icon: Building2 },
  { label: 'Yangiliklar', to: '/yangiliklar', icon: Newspaper },
  { label: 'Murojaatlar', to: '/murojaatlar', icon: MessageSquare },
  { label: 'Bildirishnomalar', to: '/notifications', icon: Bell },
]

export default function Sidebar() {
  const { role } = useAuthStore()

  return (
    <aside className="w-56 bg-white border-r border-[#E8E6E1] flex flex-col h-full shrink-0">
      <div className="px-5 py-4 border-b border-[#E8E6E1]">
        <span className="font-medium text-[#0A0A0A] text-sm leading-tight">
          Smart<br />
          <span className="text-[#1D9E75]">Turakurgan</span>
        </span>
      </div>
      <nav className="flex-1 overflow-y-auto py-2">
        {NAV_ITEMS.map(({ label, to, icon: Icon }) => (
          <NavLink
            key={to}
            to={to}
            className={({ isActive }) =>
              cn(
                'flex items-center gap-2.5 px-4 py-2 text-sm transition-colors',
                isActive
                  ? 'bg-[#1D9E75]/8 text-[#1D9E75] font-medium'
                  : 'text-[#888780] hover:text-[#0A0A0A]',
              )
            }
          >
            <Icon size={15} strokeWidth={1.8} />
            {label}
          </NavLink>
        ))}

        {/* Superadmin-only section */}
        {role === 'superadmin' && (
          <>
            <div className="mx-4 my-2 border-t border-[#E8E6E1]" />
            <NavLink
              to="/admins"
              className={({ isActive }) =>
                cn(
                  'flex items-center gap-2.5 px-4 py-2 text-sm transition-colors',
                  isActive
                    ? 'bg-[#1D9E75]/8 text-[#1D9E75] font-medium'
                    : 'text-[#888780] hover:text-[#0A0A0A]',
                )
              }
            >
              <UserCog size={15} strokeWidth={1.8} />
              Foydalanuvchilar
            </NavLink>
          </>
        )}
      </nav>
    </aside>
  )
}
