import { createBrowserRouter, Navigate, Outlet } from 'react-router-dom'
import { useAuthStore } from './store/auth.store'
import Shell from './components/layout/Shell'
import LoginPage from './pages/auth/LoginPage'
import DashboardPage from './pages/dashboard/DashboardPage'
import RahbariyatPage from './pages/rahbariyat/RahbariyatPage'
import MahallalarPage from './pages/mahallalar/MahallalarPage'
import PlacesPage from './pages/places/PlacesPage'
import YerPage from './pages/yer/YerPage'
import YangilikPage from './pages/yangiliklar/YangilikPage'
import MurojaatlarPage from './pages/murojaatlar/MurojaatlarPage'
import NotificationsPage from './pages/notifications/NotificationsPage'

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
  {
    element: <RequireAuth />,
    children: [
      {
        element: <Shell />,
        children: [
          { index: true, element: <Navigate to="/dashboard" replace /> },
          { path: 'dashboard', element: <DashboardPage /> },
          { path: 'rahbariyat', element: <RahbariyatPage /> },
          { path: 'mahallalar', element: <MahallalarPage /> },
          { path: 'places/:category', element: <PlacesPage /> },
          { path: 'yer', element: <YerPage /> },
          { path: 'yangiliklar', element: <YangilikPage /> },
          { path: 'murojaatlar', element: <MurojaatlarPage /> },
          { path: 'notifications', element: <NotificationsPage /> },
        ],
      },
    ],
  },
])
