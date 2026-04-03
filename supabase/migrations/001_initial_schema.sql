-- ============================================================
-- Smart Turakurgan — Initial Schema
-- Migration: 001_initial_schema.sql
-- ============================================================

-- Enable uuid extension (already available on Supabase by default)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- USERS
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  telegram_id     bigint      UNIQUE NOT NULL,
  telegram_username text,
  phone_number    text,
  full_name       text,
  address         text,
  role            text        NOT NULL DEFAULT 'citizen'
                              CHECK (role IN ('citizen', 'admin', 'superadmin')),
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS users_telegram_id_idx ON users (telegram_id);
CREATE INDEX IF NOT EXISTS users_role_idx ON users (role);

-- ============================================================
-- PENDING AUTH (Telegram auth flow)
-- ============================================================
CREATE TABLE IF NOT EXISTS pending_auth (
  id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  token       uuid        UNIQUE NOT NULL DEFAULT gen_random_uuid(),
  device_id   text        NOT NULL,
  telegram_id bigint,
  confirmed   boolean     NOT NULL DEFAULT false,
  expires_at  timestamptz NOT NULL,
  created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS pending_auth_token_idx      ON pending_auth (token);
CREATE INDEX IF NOT EXISTS pending_auth_device_id_idx  ON pending_auth (device_id);
CREATE INDEX IF NOT EXISTS pending_auth_expires_at_idx ON pending_auth (expires_at);

-- ============================================================
-- RAHBARIYAT (Hokimiyat leadership)
-- ============================================================
CREATE TABLE IF NOT EXISTS rahbariyat (
  id             uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name      text        NOT NULL,
  birth_year     int,
  position       text        NOT NULL,
  category       text        NOT NULL
                             CHECK (category IN ('rahbariyat', 'apparat', 'deputat', 'kotibiyat')),
  phone          text,
  biography      text,
  reception_days text,
  photo_url      text,
  sort_order     int         NOT NULL DEFAULT 0,
  is_published   boolean     NOT NULL DEFAULT true,
  created_at     timestamptz NOT NULL DEFAULT now(),
  updated_at     timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS rahbariyat_category_idx   ON rahbariyat (category);
CREATE INDEX IF NOT EXISTS rahbariyat_updated_at_idx ON rahbariyat (updated_at);
CREATE INDEX IF NOT EXISTS rahbariyat_published_idx  ON rahbariyat (is_published);

-- ============================================================
-- MAHALLALAR (Neighborhoods)
-- ============================================================
CREATE TABLE IF NOT EXISTS mahallalar (
  id                 uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  name               text        NOT NULL,
  description        text,
  location_lat       double precision,
  location_lng       double precision,
  building_photo_url text,
  is_published       boolean     NOT NULL DEFAULT true,
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS mahallalar_updated_at_idx ON mahallalar (updated_at);
CREATE INDEX IF NOT EXISTS mahallalar_published_idx  ON mahallalar (is_published);

-- ============================================================
-- MAHALLA_XODIMLARI (Neighborhood staff)
-- ============================================================
CREATE TABLE IF NOT EXISTS mahalla_xodimlari (
  id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  mahalla_id  uuid        NOT NULL REFERENCES mahallalar (id) ON DELETE CASCADE,
  full_name   text        NOT NULL,
  birth_year  int,
  position    text        NOT NULL,
  phone       text,
  biography   text,
  photo_url   text,
  sort_order  int         NOT NULL DEFAULT 0,
  updated_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS mahalla_xodimlari_mahalla_id_idx  ON mahalla_xodimlari (mahalla_id);
CREATE INDEX IF NOT EXISTS mahalla_xodimlari_updated_at_idx  ON mahalla_xodimlari (updated_at);

-- ============================================================
-- YER_MAYDONLARI (E-auction land plots)
-- ============================================================
CREATE TABLE IF NOT EXISTS yer_maydonlari (
  id             uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  title          text        NOT NULL,
  area_hectares  numeric,
  location_lat   double precision,
  location_lng   double precision,
  status         text        NOT NULL DEFAULT 'active'
                             CHECK (status IN ('active', 'sold', 'pending')),
  auction_url    text,
  description    text,
  is_published   boolean     NOT NULL DEFAULT true,
  updated_at     timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS yer_maydonlari_status_idx     ON yer_maydonlari (status);
CREATE INDEX IF NOT EXISTS yer_maydonlari_updated_at_idx ON yer_maydonlari (updated_at);
CREATE INDEX IF NOT EXISTS yer_maydonlari_published_idx  ON yer_maydonlari (is_published);

-- ============================================================
-- PLACES (turizm / ta'lim / tibbiyot / tashkilotlar)
-- ============================================================
CREATE TABLE IF NOT EXISTS places (
  id            uuid            PRIMARY KEY DEFAULT gen_random_uuid(),
  category      text            NOT NULL
                                CHECK (category IN (
                                  'diqqat_joy', 'ovqatlanish', 'mexmonxona',
                                  'oquv_markaz', 'maktabgacha', 'maktab', 'texnikum', 'oliy_talim',
                                  'davlat_tibbiyot', 'xususiy_tibbiyot',
                                  'davlat_tashkilot', 'xususiy_korxona'
                                )),
  name          text            NOT NULL,
  director      text,
  phone         text,
  description   text,
  location_lat  double precision,
  location_lng  double precision,
  rating        numeric(2, 1)   NOT NULL DEFAULT 0
                                CHECK (rating >= 0 AND rating <= 5),
  comment_count int             NOT NULL DEFAULT 0,
  is_published  boolean         NOT NULL DEFAULT true,
  created_at    timestamptz     NOT NULL DEFAULT now(),
  updated_at    timestamptz     NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS places_category_idx   ON places (category);
CREATE INDEX IF NOT EXISTS places_updated_at_idx ON places (updated_at);
CREATE INDEX IF NOT EXISTS places_published_idx  ON places (is_published);

-- ============================================================
-- PLACE_IMAGES (one-to-many for places)
-- ============================================================
CREATE TABLE IF NOT EXISTS place_images (
  id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  place_id   uuid        NOT NULL REFERENCES places (id) ON DELETE CASCADE,
  image_url  text        NOT NULL,
  sort_order int         NOT NULL DEFAULT 0,
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS place_images_place_id_idx  ON place_images (place_id);
CREATE INDEX IF NOT EXISTS place_images_updated_at_idx ON place_images (updated_at);

-- ============================================================
-- COMMENTS / RATINGS
-- ============================================================
CREATE TABLE IF NOT EXISTS comments (
  id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  place_id    uuid        NOT NULL REFERENCES places (id) ON DELETE CASCADE,
  user_id     uuid        REFERENCES users (id) ON DELETE SET NULL,
  rating      int         CHECK (rating BETWEEN 1 AND 5),
  text        text,
  is_approved boolean     NOT NULL DEFAULT false,
  created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS comments_place_id_idx   ON comments (place_id);
CREATE INDEX IF NOT EXISTS comments_user_id_idx    ON comments (user_id);
CREATE INDEX IF NOT EXISTS comments_approved_idx   ON comments (is_approved);

-- ============================================================
-- YANGILIKLAR (News)
-- ============================================================
CREATE TABLE IF NOT EXISTS yangiliklar (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  title           text        NOT NULL,
  body            text,
  cover_image_url text,
  category        text        NOT NULL DEFAULT 'general',
  is_published    boolean     NOT NULL DEFAULT true,
  published_at    timestamptz NOT NULL DEFAULT now(),
  created_at      timestamptz NOT NULL DEFAULT now(),
  updated_at      timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS yangiliklar_published_at_idx ON yangiliklar (published_at DESC);
CREATE INDEX IF NOT EXISTS yangiliklar_updated_at_idx   ON yangiliklar (updated_at);
CREATE INDEX IF NOT EXISTS yangiliklar_published_idx    ON yangiliklar (is_published);
CREATE INDEX IF NOT EXISTS yangiliklar_category_idx     ON yangiliklar (category);

-- ============================================================
-- MUROJAATLAR (Citizen appeals)
-- ============================================================
CREATE TABLE IF NOT EXISTS murojaatlar (
  id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id    uuid        REFERENCES users (id) ON DELETE SET NULL,
  full_name  text        NOT NULL,
  phone      text        NOT NULL,
  address    text        NOT NULL,
  message    text        NOT NULL,
  status     text        NOT NULL DEFAULT 'pending'
                         CHECK (status IN ('pending', 'in_review', 'resolved')),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS murojaatlar_user_id_idx   ON murojaatlar (user_id);
CREATE INDEX IF NOT EXISTS murojaatlar_status_idx    ON murojaatlar (status);
CREATE INDEX IF NOT EXISTS murojaatlar_created_at_idx ON murojaatlar (created_at);

-- ============================================================
-- BILDIRISHNOMALAR (Notifications)
-- ============================================================
CREATE TABLE IF NOT EXISTS bildirishnomalar (
  id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  title      text        NOT NULL,
  body       text,
  target     text        NOT NULL DEFAULT 'all',
  is_sent    boolean     NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS bildirishnomalar_is_sent_idx    ON bildirishnomalar (is_sent);
CREATE INDEX IF NOT EXISTS bildirishnomalar_created_at_idx ON bildirishnomalar (created_at);

-- ============================================================
-- updated_at auto-update trigger helper
-- ============================================================
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

-- Attach trigger to every table that has updated_at
DO $$
DECLARE
  t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'users', 'rahbariyat', 'mahallalar', 'mahalla_xodimlari',
    'yer_maydonlari', 'places', 'place_images', 'yangiliklar'
  ]
  LOOP
    EXECUTE format(
      'CREATE TRIGGER trg_set_updated_at
       BEFORE UPDATE ON %I
       FOR EACH ROW EXECUTE FUNCTION set_updated_at()',
      t
    );
  END LOOP;
END;
$$;
