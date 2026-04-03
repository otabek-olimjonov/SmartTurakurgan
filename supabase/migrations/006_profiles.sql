-- ============================================================
-- 006_profiles.sql
-- Admin user profiles table (separate from citizens `users` table)
-- ============================================================

CREATE TABLE IF NOT EXISTS profiles (
  id          uuid        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name   text,
  role        text        NOT NULL DEFAULT 'admin'
                          CHECK (role IN ('admin', 'superadmin')),
  created_at  timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Any authenticated user can read all profiles
CREATE POLICY "profiles_read" ON profiles
  FOR SELECT TO authenticated
  USING (true);

-- Superadmin can insert profiles
CREATE POLICY "profiles_insert" ON profiles
  FOR INSERT TO authenticated
  WITH CHECK (
    (auth.jwt() -> 'app_metadata' ->> 'role') = 'superadmin'
  );

-- Superadmin can update any profile (including role)
CREATE POLICY "profiles_superadmin_update" ON profiles
  FOR UPDATE TO authenticated
  USING (
    (auth.jwt() -> 'app_metadata' ->> 'role') = 'superadmin'
  );

-- Regular admins can update their own profile (full_name only — role is protected)
CREATE POLICY "profiles_self_update" ON profiles
  FOR UPDATE TO authenticated
  USING (id = auth.uid())
  WITH CHECK (
    id = auth.uid() AND
    -- Prevent role escalation: new role must equal existing role
    role = (SELECT role FROM profiles WHERE id = auth.uid())
  );

-- Superadmin can delete profiles
CREATE POLICY "profiles_delete" ON profiles
  FOR DELETE TO authenticated
  USING (
    (auth.jwt() -> 'app_metadata' ->> 'role') = 'superadmin'
  );

-- ============================================================
-- Trigger: auto-create profile when an admin auth user is created
-- (fires for all auth.users inserts, e.g. invite flow)
-- ============================================================
CREATE OR REPLACE FUNCTION handle_new_admin_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Only create a profile for admin/superadmin users
  IF COALESCE(NEW.raw_app_meta_data->>'role', '') IN ('admin', 'superadmin') THEN
    INSERT INTO public.profiles (id, full_name, role)
    VALUES (
      NEW.id,
      COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
      COALESCE(NEW.raw_app_meta_data->>'role', 'admin')
    )
    ON CONFLICT (id) DO NOTHING;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_admin_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_admin_user();

-- ============================================================
-- Trigger: keep updated_at fresh
-- ============================================================
CREATE OR REPLACE FUNCTION update_profiles_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_profiles_updated_at();

-- ============================================================
-- Backfill: create profiles for existing admin/superadmin users
-- ============================================================
INSERT INTO profiles (id, full_name, role)
SELECT
  id,
  COALESCE(raw_user_meta_data->>'full_name', split_part(email, '@', 1)),
  COALESCE(raw_app_meta_data->>'role', 'admin')
FROM auth.users
WHERE raw_app_meta_data->>'role' IN ('admin', 'superadmin')
ON CONFLICT (id) DO NOTHING;
