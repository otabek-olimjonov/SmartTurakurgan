import { createBrowserRouter, Navigate, Outlet } from 'react-router-dom'
import { useAuthStore } from './store/auth.store'
import Shell from './components/layout/Shell'
import LoginPage from './pages/auth/LoginPage'
import AcceptInvitePage from './pages/auth/AcceptInvitePage'
import DashboardPage from './pages/dashboard/DashboardPage'
import RahbariyatPage from './pages/rahbariyat/RahbariyatPage'
import MahallalarPage from './pages/mahallalar/MahallalarPage'
import PlacesPage from './pages/places/PlacesPage'
import YerPage from './pages/yer/YerPage'
import YangilikPage from './pages/yangiliklar/YangilikPage'
import MurojaatlarPage from './pages/murojaatlar/MurojaatlarPage'
import NotificationsPage from './pages/notifications/NotificationsPage'
import AdminUsersPage from './pages/admins/AdminUsersPage'
import PublicShell from './components/public/PublicShell'
import PortalHomePage from './pages/portal/PortalHomePage'
import PortalHokimiyatPage from './pages/portal/PortalHokimiyatPage'
import PortalPlacesPage from './pages/portal/PortalPlacesPage'
import PortalNewsPage from './pages/portal/PortalNewsPage'
import PortalNewsDetailPage from './pages/portal/PortalNewsDetailPage'
import PortalBoglanishPage from './pages/portal/PortalBoglanishPage'

function RequireAuth() {
  const { session, loading } = useAuthStore()
  if (loading) {
    return (
      <div className="flex items-center justify-center h-screen text-sm text-gray-400">
        Yuklanmoqda...
      </div>
    )
  }
  if (!session) return <Navigate to="/login" replace />
  return <Outlet />
}

export const router = createBrowserRouter([
  { path: '/login', element: <LoginPage /> },
  { path: '/accept-invite', element: <AcceptInvitePage /> },

  // Public citizen portal — no auth required
  {
    path: '/',
    element: <PublicShell />,
    children: [
      { index: true, element: <PortalHomePage /> },
      { path: 'hokimiyat', element: <PortalHokimiyatPage /> },
      { path: 'yangiliklar', element: <PortalNewsPage /> },
      { path: 'yangiliklar/:id', element: <PortalNewsDetailPage /> },
      { path: 'boglanish', element: <PortalBoglanishPage /> },
      // :section catches turizm | talim | tibbiyot | tashkilotlar — must come last
      { path: ':section', element: <PortalPlacesPage /> },
    ],
  },

  // Admin dashboard — requires auth
  {
    element: <RequireAuth />,
    children: [
      {
        element: <Shell />,
        children: [
          { path: 'dashboard', element: <DashboardPage /> },
          { path: 'rahbariyat', element: <RahbariyatPage /> },
          { path: 'mahallalar', element: <MahallalarPage /> },
          { path: 'places/:category', element: <PlacesPage /> },
          { path: 'yer', element: <YerPage /> },
          { path: 'yangiliklar', element: <YangilikPage /> },
          { path: 'murojaatlar', element: <MurojaatlarPage /> },
          { path: 'notifications', element: <NotificationsPage /> },
          { path: 'admins', element: <AdminUsersPage /> },
        ],
      },
    ],
  },
])
