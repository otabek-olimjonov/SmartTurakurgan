-- ============================================================
-- Smart Turakurgan — Database Localization
-- Migration: 003_i18n.sql
-- Run AFTER 002_rls.sql
-- ============================================================
--
-- Strategy: each content table gets a `translations` JSONB column.
-- Base columns (name, title, description, biography, etc.) always
-- hold the Uzbek Latin (uz) value — the canonical source.
-- The `translations` column stores overrides for other locales:
--
--   {
--     "ru":      { "name": "...", "description": "..." },
--     "uz_cyrl": { "name": "...", "description": "..." },
--     "en":      { "name": "...", "description": "..." }
--   }
--
-- Supported locale keys: "ru" | "uz_cyrl" | "en"
-- Missing keys fall back to the Uzbek Latin base column value.
-- Localizable fields per table are listed below.
-- ============================================================

-- ============================================================
-- RAHBARIYAT
-- Localizable: full_name, position, biography, reception_days
-- ============================================================
ALTER TABLE rahbariyat
  ADD COLUMN IF NOT EXISTS translations jsonb NOT NULL DEFAULT '{}'::jsonb;

-- ============================================================
-- MAHALLALAR
-- Localizable: name, description
-- ============================================================
ALTER TABLE mahallalar
  ADD COLUMN IF NOT EXISTS translations jsonb NOT NULL DEFAULT '{}'::jsonb;

-- ============================================================
-- MAHALLA_XODIMLARI
-- Localizable: full_name, position, biography
-- ============================================================
ALTER TABLE mahalla_xodimlari
  ADD COLUMN IF NOT EXISTS translations jsonb NOT NULL DEFAULT '{}'::jsonb;

-- ============================================================
-- YER_MAYDONLARI
-- Localizable: title, description
-- ============================================================
ALTER TABLE yer_maydonlari
  ADD COLUMN IF NOT EXISTS translations jsonb NOT NULL DEFAULT '{}'::jsonb;

-- ============================================================
-- PLACES
-- Localizable: name, description, director
-- ============================================================
ALTER TABLE places
  ADD COLUMN IF NOT EXISTS translations jsonb NOT NULL DEFAULT '{}'::jsonb;

-- ============================================================
-- YANGILIKLAR
-- Localizable: title, body
-- ============================================================
ALTER TABLE yangiliklar
  ADD COLUMN IF NOT EXISTS translations jsonb NOT NULL DEFAULT '{}'::jsonb;

-- ============================================================
-- BILDIRISHNOMALAR
-- Localizable: title, body
-- ============================================================
ALTER TABLE bildirishnomalar
  ADD COLUMN IF NOT EXISTS translations jsonb NOT NULL DEFAULT '{}'::jsonb;

-- ============================================================
-- Example translation record shape (for reference only):
--
-- INSERT INTO places (name, description, translations, ...) VALUES (
--   'Turakurgʻon Davlat Shifoxonasi',                  -- uz (base)
--   'Tuman markaziy kasalxonasi.',                      -- uz (base)
--   '{
--     "ru":      { "name": "Туракурганская ЦРБ",
--                  "description": "Центральная районная больница." },
--     "uz_cyrl": { "name": "Туракурғон Давлат Шифохонаси",
--                  "description": "Туман марказий касалхонаси." },
--     "en":      { "name": "Turakurgan District Hospital",
--                  "description": "Central district hospital." }
--   }'::jsonb,
--   ...
-- );
-- ============================================================
