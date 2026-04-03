-- ============================================================
-- Smart Turakurgan — Row Level Security Policies
-- Migration: 002_rls.sql
-- Run AFTER 001_initial_schema.sql
-- ============================================================
--
-- Auth model:
--   Citizens  → custom JWT (signed with SUPABASE_JWT_SECRET, sub = users.id)
--               Always go through Edge Functions (service_role) — RLS bypassed.
--   Admins    → Supabase email auth. Role is stored in Supabase Auth
--               `app_metadata.role` (set server-side only via service_role).
--               admin check: (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin','superadmin')
-- ============================================================

-- Enable RLS on all tables
ALTER TABLE users              ENABLE ROW LEVEL SECURITY;
ALTER TABLE pending_auth       ENABLE ROW LEVEL SECURITY;
ALTER TABLE rahbariyat         ENABLE ROW LEVEL SECURITY;
ALTER TABLE mahallalar         ENABLE ROW LEVEL SECURITY;
ALTER TABLE mahalla_xodimlari  ENABLE ROW LEVEL SECURITY;
ALTER TABLE yer_maydonlari     ENABLE ROW LEVEL SECURITY;
ALTER TABLE places             ENABLE ROW LEVEL SECURITY;
ALTER TABLE place_images       ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments           ENABLE ROW LEVEL SECURITY;
ALTER TABLE yangiliklar        ENABLE ROW LEVEL SECURITY;
ALTER TABLE murojaatlar        ENABLE ROW LEVEL SECURITY;
ALTER TABLE bildirishnomalar   ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- USERS
-- Citizens never access this table directly (edge functions use service_role).
-- Admins can read all citizen records from the dashboard.
-- ============================================================

-- Admins can read all user records from the dashboard
CREATE POLICY "admin_read_users" ON users
  FOR SELECT
  USING (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'superadmin')
  );

-- Admins can update any user record (e.g., add notes, update phone)
CREATE POLICY "admin_update_users" ON users
  FOR UPDATE
  USING (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'superadmin')
  )
  WITH CHECK (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'superadmin')
  );

-- Direct inserts disallowed; only via service_role edge functions
CREATE POLICY "service_insert_users" ON users
  FOR INSERT
  WITH CHECK (false);

-- ============================================================
-- PENDING_AUTH
-- Edge functions use service_role key — no user-level access needed.
-- Citizens must not be able to read/write this table directly.
-- ============================================================

-- No citizen policies — service_role bypass handles all operations.

-- ============================================================
-- RAHBARIYAT
-- ============================================================

CREATE POLICY "public_read_rahbariyat" ON rahbariyat
  FOR SELECT
  USING (is_published = true);

CREATE POLICY "admin_write_rahbariyat" ON rahbariyat
  FOR ALL
  USING (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'superadmin')
  )
  WITH CHECK (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'superadmin')
  );

-- ============================================================
-- MAHALLALAR
-- ============================================================

CREATE POLICY "public_read_mahallalar" ON mahallalar
  FOR SELECT
  USING (is_published = true);

CREATE POLICY "admin_write_mahallalar" ON mahallalar
  FOR ALL
  USING (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'superadmin')
  )
  WITH CHECK (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'superadmin')
  );

-- ============================================================
-- MAHALLA_XODIMLARI
-- ============================================================

CREATE POLICY "public_read_mahalla_xodimlari" ON mahalla_xodimlari
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM mahallalar m
      WHERE m.id = mahalla_xodimlari.mahalla_id
        AND m.is_published = true
    )
  );

CREATE POLICY "admin_write_mahalla_xodimlari" ON mahalla_xodimlari
  FOR ALL
  USING (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'superadmin')
  )
  WITH CHECK (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'superadmin')
  );

-- ============================================================
-- YER_MAYDONLARI
-- ============================================================

CREATE POLICY "public_read_yer_maydonlari" ON yer_maydonlari
  FOR SELECT
  USING (is_published = true);

CREATE POLICY "admin_write_yer_maydonlari" ON yer_maydonlari
  FOR ALL
  USING (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'superadmin')
  )
  WITH CHECK (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'superadmin')
  );

-- ============================================================
-- PLACES
-- ============================================================

CREATE POLICY "public_read_places" ON places
  FOR SELECT
  USING (is_published = true);

CREATE POLICY "admin_write_places" ON places
  FOR ALL
  USING (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'superadmin')
  )
  WITH CHECK (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'superadmin')
  );

-- ============================================================
-- PLACE_IMAGES
-- ============================================================

CREATE POLICY "public_read_place_images" ON place_images
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM places p
      WHERE p.id = place_images.place_id
        AND p.is_published = true
    )
  );

CREATE POLICY "admin_write_place_images" ON place_images
  FOR ALL
  USING (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'superadmin')
  )
  WITH CHECK (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'superadmin')
  );

-- ============================================================
-- COMMENTS
-- ============================================================

-- Anyone can read approved comments on published places (no auth required)
CREATE POLICY "public_read_comments" ON comments
  FOR SELECT
  USING (
    is_approved = true
    AND EXISTS (
      SELECT 1 FROM places p
      WHERE p.id = comments.place_id
        AND p.is_published = true
    )
  );

-- Admins can approve / manage all comments
CREATE POLICY "admin_write_comments" ON comments
  FOR ALL
  USING (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'superadmin')
  )
  WITH CHECK (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'superadmin')
  );

-- ============================================================
-- YANGILIKLAR (News)
-- ============================================================

CREATE POLICY "public_read_yangiliklar" ON yangiliklar
  FOR SELECT
  USING (is_published = true);

CREATE POLICY "admin_write_yangiliklar" ON yangiliklar
  FOR ALL
  USING (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'superadmin')
  )
  WITH CHECK (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'superadmin')
  );

-- ============================================================
-- MUROJAATLAR (Citizen appeals)
-- Citizens submit and view appeals through edge functions (service_role).
-- Admins view and manage all appeals from the dashboard.
-- ============================================================

-- Admins can read and manage all appeals
CREATE POLICY "admin_all_murojaatlar" ON murojaatlar
  FOR ALL
  USING (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'superadmin')
  )
  WITH CHECK (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'superadmin')
  );

-- ============================================================
-- BILDIRISHNOMALAR (Notifications)
-- ============================================================

-- Any Supabase Auth session (admins in dashboard) can read 'all' notifications
CREATE POLICY "public_read_bildirishnomalar" ON bildirishnomalar
  FOR SELECT
  USING (target = 'all');

-- Only admins can create/manage notifications
CREATE POLICY "admin_write_bildirishnomalar" ON bildirishnomalar
  FOR ALL
  USING (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'superadmin')
  )
  WITH CHECK (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'superadmin')
  );
