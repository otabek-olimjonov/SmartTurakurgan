import { useState } from 'react'
import { NavLink, Outlet, Link } from 'react-router-dom'
import { cn } from '../../lib/utils'
import { Menu, X, ExternalLink } from 'lucide-react'

const NAV_LINKS = [
  { label: 'Hokimiyat', to: '/hokimiyat' },
  { label: 'Turizm', to: '/turizm' },
  { label: "Ta'lim", to: '/talim' },
  { label: 'Tibbiyot', to: '/tibbiyot' },
  { label: 'Tashkilotlar', to: '/tashkilotlar' },
  { label: 'Yangiliklar', to: '/yangiliklar' },
  { label: "Bog'lanish", to: '/boglanish' },
]

export default function PublicShell() {
  const [open, setOpen] = useState(false)

  return (
    <div className="min-h-screen flex flex-col bg-[#F7F6F3]">
      {/* Sticky header */}
      <header className="sticky top-0 z-50 bg-white border-b border-[#E8E6E1]">
        <div className="max-w-6xl mx-auto px-4 h-14 flex items-center justify-between gap-4">
          <Link to="/" className="flex items-center gap-2 shrink-0">
            <div className="w-7 h-7 rounded-lg bg-[#1D9E75] flex items-center justify-center">
              <span className="text-white text-xs font-medium">ST</span>
            </div>
            <span className="font-medium text-[#0A0A0A] text-sm">Smart Turakurgan</span>
          </Link>

          {/* Desktop nav */}
          <nav className="hidden md:flex items-center gap-0.5 flex-1 justify-center">
            {NAV_LINKS.map(({ label, to }) => (
              <NavLink
                key={to}
                to={to}
                className={({ isActive }) =>
                  cn(
                    'px-3 py-1.5 text-[13px] rounded-lg transition-colors whitespace-nowrap',
                    isActive
                      ? 'bg-[#1D9E75]/10 text-[#1D9E75] font-medium'
                      : 'text-[#888780] hover:text-[#0A0A0A]',
                  )
                }
              >
                {label}
              </NavLink>
            ))}
          </nav>

          <Link
            to="/dashboard"
            className="hidden md:flex items-center gap-1 text-xs text-[#888780] hover:text-[#0A0A0A] transition-colors shrink-0"
          >
            Admin <ExternalLink size={11} />
          </Link>

          {/* Mobile hamburger */}
          <button className="md:hidden p-1.5 text-[#888780]" onClick={() => setOpen(v => !v)}>
            {open ? <X size={20} /> : <Menu size={20} />}
          </button>
        </div>

        {/* Mobile menu */}
        {open && (
          <div className="md:hidden border-t border-[#E8E6E1] bg-white px-4 pb-4 pt-2 flex flex-col gap-0.5">
            {NAV_LINKS.map(({ label, to }) => (
              <NavLink
                key={to}
                to={to}
                onClick={() => setOpen(false)}
                className={({ isActive }) =>
                  cn('block py-2 text-sm rounded px-2', isActive ? 'text-[#1D9E75] font-medium' : 'text-[#888780]')
                }
              >
                {label}
              </NavLink>
            ))}
            <Link to="/dashboard" className="flex items-center gap-1 py-2 px-2 text-xs text-[#888780]" onClick={() => setOpen(false)}>
              Admin panel <ExternalLink size={11} />
            </Link>
          </div>
        )}
      </header>

      {/* Content */}
      <main className="flex-1">
        <Outlet />
      </main>

      {/* Footer */}
      <footer className="bg-white border-t border-[#E8E6E1] py-8 mt-16">
        <div className="max-w-6xl mx-auto px-4">
          <div className="flex flex-col md:flex-row items-start md:items-center justify-between gap-6">
            <div>
              <p className="font-medium text-[#0A0A0A] text-sm">Smart Turakurgan</p>
              <p className="text-xs text-[#888780] mt-0.5">Barcha xizmatlar — bitta ilovada</p>
            </div>
            <div className="flex flex-wrap gap-x-5 gap-y-1.5">
              {NAV_LINKS.map(({ label, to }) => (
                <Link key={to} to={to} className="text-xs text-[#888780] hover:text-[#0A0A0A] transition-colors">
                  {label}
                </Link>
              ))}
            </div>
          </div>
          <div className="mt-6 pt-4 border-t border-[#E8E6E1] text-xs text-[#888780]">
            © {new Date().getFullYear()} Turakurgan tuman hokimligi. Barcha huquqlar himoyalangan.
          </div>
        </div>
      </footer>
    </div>
  )
}
