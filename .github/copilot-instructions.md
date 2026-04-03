# Smart Turakurgan — GitHub Copilot Instructions

> Place this file at `.github/copilot-instructions.md` in your repository root.
> Copilot will automatically use it as context for every suggestion in this repo.

---

## Project Overview

**Smart Turakurgan** is a civic super-app for Turakurgan district, Uzbekistan.
Slogan: *"Barcha xizmatlar — bitta ilovada"* (All services — in one app).

The system consists of:
- **Flutter mobile app** — Android + iOS, offline-first, daily sync
- **React + Vite web dashboard** — admin panel for content management
- **Supabase** — backend, database, storage, auth, edge functions
- **Telegram Bot** — citizen authentication in the mobile app only

---

## Repository Structure

```
smart-turakurgan/
├── .github/
│   └── copilot-instructions.md       ← this file
├── mobile/                           ← Flutter app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── core/
│   │   │   ├── db/                   ← sqflite local database
│   │   │   ├── sync/                 ← delta sync engine
│   │   │   ├── auth/                 ← Telegram auth flow
│   │   │   └── theme/                ← design tokens
│   │   ├── features/
│   │   │   ├── home/
│   │   │   ├── hokimiyat/
│   │   │   ├── turizm/
│   │   │   ├── talim/
│   │   │   ├── tibbiyot/
│   │   │   ├── tashkilotlar/
│   │   │   ├── ai_assistant/
│   │   │   └── boglanish/
│   │   └── shared/
│   │       ├── widgets/
│   │       └── models/
│   └── pubspec.yaml
├── dashboard/                        ← React + Vite admin panel
│   ├── src/
│   │   ├── pages/
│   │   ├── components/
│   │   ├── lib/
│   │   │   └── supabase.ts
│   │   └── main.tsx
│   └── package.json
└── supabase/
    ├── functions/
    │   ├── _shared/
    │   │   ├── cors.ts
    │   │   ├── auth.ts
    │   │   └── telegram.ts
    │   ├── auth-telegram-init/
    │   │   └── index.ts
    │   ├── auth-telegram-verify/
    │   │   └── index.ts
    │   ├── bot-webhook/
    │   │   └── index.ts
    │   ├── sync-full/
    │   │   └── index.ts
    │   ├── sync-delta/
    │   │   └── index.ts
    │   └── sync-news/
    │       └── index.ts
    └── migrations/
        └── 001_initial_schema.sql
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile app | Flutter 3.x (Dart), Android + iOS |
| Web dashboard | React 18 + Vite + TypeScript |
| UI components (dashboard) | shadcn/ui + Tailwind CSS |
| Backend / API | Supabase Edge Functions (Deno / TypeScript) |
| Database (cloud) | Supabase PostgreSQL |
| Database (local/mobile) | sqflite |
| Local image storage | path_provider + flutter_cache_manager |
| Auth (mobile / citizens) | Telegram Bot API + custom JWT signed with SUPABASE_JWT_SECRET |
| Auth (dashboard / admins) | Supabase built-in email auth, role stored in `app_metadata` |
| File storage | Supabase Storage |
| Background sync | flutter_background_service |
| State management (Flutter) | Riverpod |
| HTTP client (Flutter) | Dio |
| Maps (Flutter) | flutter_map + OpenStreetMap |

---

## Architecture: Offline-First Mobile

The mobile app is **offline-first**. All data except news is stored locally on the device.

```
Phone (Flutter)                    Supabase (Cloud)
├── sqflite (local DB)    ←──────  Edge Function: /sync/delta  (once/day)
├── File system (images)  ←──────  Supabase Storage             (once/day, delta only)
└── News cache            ←──────  Edge Function: /sync/news    (every app open)
```

### Sync Rules — ALWAYS follow these:
- Static content (hokimiyat, ta'lim, tibbiyot, tashkilotlar, turizm) → sync **once per day** via `sync-delta`
- News (`yangiliklar`) → fetch **on every app open**
- Images → download **only new/changed** images using `updated_at` comparison
- First install → `sync-full` endpoint, show progress indicator to user
- Store `last_sync_at` timestamp in `SharedPreferences`
- All sync functions must be **idempotent** — safe to run multiple times
- Sync must work on **background service**, not block the UI thread

---

## Database Schema

### Supabase (PostgreSQL) — Cloud Tables

```sql
-- Users
users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  telegram_id bigint UNIQUE NOT NULL,
  telegram_username text,
  phone_number text,
  full_name text,
  address text,
  role text DEFAULT 'citizen',  -- 'citizen' | 'admin' | 'superadmin'
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
)

-- Pending auth tokens (Telegram auth flow)
pending_auth (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  token uuid UNIQUE NOT NULL,
  device_id text NOT NULL,
  telegram_id bigint,
  confirmed boolean DEFAULT false,
  expires_at timestamptz NOT NULL,
  created_at timestamptz DEFAULT now()
)

-- Hokimiyat: leadership
rahbariyat (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name text NOT NULL,
  birth_year int,
  position text NOT NULL,
  category text NOT NULL,  -- 'hokim' | 'apparat' | 'deputat' | 'kotibiyat'
  phone text,
  biography text,
  reception_days text,
  photo_url text,
  sort_order int DEFAULT 0,
  is_published boolean DEFAULT true,
  translations jsonb DEFAULT '{}',  -- { "ru": {"full_name":"...","position":"...","biography":"..."}, "uz_cyrl": {...}, "en": {...} }
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
)

-- Mahallalar (neighborhoods)
mahallalar (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  location_lat double precision,
  location_lng double precision,
  building_photo_url text,
  is_published boolean DEFAULT true,
  translations jsonb DEFAULT '{}',  -- { "ru": {"name":"...","description":"..."}, "uz_cyrl": {...}, "en": {...} }
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
)

-- Mahalla staff
mahalla_xodimlari (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  mahalla_id uuid REFERENCES mahallalar(id) ON DELETE CASCADE,
  full_name text NOT NULL,
  birth_year int,
  position text NOT NULL,
  phone text,
  biography text,
  photo_url text,
  sort_order int DEFAULT 0,
  translations jsonb DEFAULT '{}',  -- { "ru": {"full_name":"...","position":"...","biography":"..."}, "uz_cyrl": {...}, "en": {...} }
  updated_at timestamptz DEFAULT now()
)

-- E-auction land plots
yer_maydonlari (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  area_hectares numeric,
  location_lat double precision,
  location_lng double precision,
  status text DEFAULT 'active',  -- 'active' | 'sold' | 'pending'
  auction_url text,
  description text,
  is_published boolean DEFAULT true,
  translations jsonb DEFAULT '{}',  -- { "ru": {"title":"...","description":"..."}, "uz_cyrl": {...}, "en": {...} }
  updated_at timestamptz DEFAULT now()
)

-- Generic place table (used for turizm, ta'lim, tibbiyot, tashkilotlar)
places (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category text NOT NULL,
  name text NOT NULL,
  director text,
  phone text,
  description text,
  location_lat double precision,
  location_lng double precision,
  rating numeric(2,1) DEFAULT 0,
  comment_count int DEFAULT 0,
  is_published boolean DEFAULT true,
  translations jsonb DEFAULT '{}',  -- { "ru": {"name":"...","description":"...","director":"..."}, "uz_cyrl": {...}, "en": {...} }
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
)

-- Place images (one-to-many)
place_images (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  place_id uuid REFERENCES places(id) ON DELETE CASCADE,
  image_url text NOT NULL,
  sort_order int DEFAULT 0,
  updated_at timestamptz DEFAULT now()
)

-- Comments / ratings
comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  place_id uuid REFERENCES places(id) ON DELETE CASCADE,
  user_id uuid REFERENCES users(id),
  rating int CHECK (rating BETWEEN 1 AND 5),
  text text,
  is_approved boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
)

-- News
yangiliklar (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  body text,
  cover_image_url text,
  category text DEFAULT 'general',
  is_published boolean DEFAULT true,
  published_at timestamptz DEFAULT now(),
  translations jsonb DEFAULT '{}',  -- { "ru": {"title":"...","body":"..."}, "uz_cyrl": {...}, "en": {...} }
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
)

-- Citizen appeals / murojaatlar
murojaatlar (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users(id),
  full_name text NOT NULL,
  phone text NOT NULL,
  address text NOT NULL,
  message text NOT NULL,
  status text DEFAULT 'pending',  -- 'pending' | 'in_review' | 'resolved'
  created_at timestamptz DEFAULT now()
)

-- Notifications
bildirishnomalar (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  body text,
  target text DEFAULT 'all',   -- 'all' | user telegram_id
  is_sent boolean DEFAULT false,
  translations jsonb DEFAULT '{}',  -- { "ru": {"title":"...","body":"..."}, "uz_cyrl": {...}, "en": {...} }
  created_at timestamptz DEFAULT now()
)
```

### sqflite (Local — Flutter)

The local database mirrors the cloud schema but only stores what the mobile app needs.
All local tables must have an `updated_at` column for delta sync comparison.

```dart
// Always create tables with IF NOT EXISTS
// Always use updated_at for delta sync tracking
// Never store sensitive data (tokens) in sqflite — use flutter_secure_storage
```

---

## Authentication Flow

There are **two separate authentication systems** — one for citizens (mobile), one for admins (dashboard).

---

### Citizen Auth — Mobile App (Telegram)

Telegram is the **only** login method for citizens. No email or password.

```
1. User opens app → no session found
2. App calls POST /auth-telegram-init with { device_id }
3. Edge function returns { token, telegram_url }
   telegram_url = "https://t.me/SmartTurakurganBot?start={token}"
4. App opens Telegram deep link
5. User taps START in Telegram bot
6. Bot calls POST /bot-webhook
7. Edge function finds pending_auth by token, marks confirmed = true,
   creates/updates user record in the `users` table, issues custom JWT
8. App polls GET /auth-telegram-verify?token={token} every 2 seconds
9. When confirmed, app receives JWT → store in flutter_secure_storage
10. App navigates to onboarding (if new user) or home (if existing)
```

#### Citizen token rules:
- Token expires in **5 minutes**
- One token per device_id at a time — invalidate previous on new request
- JWT is signed with `SUPABASE_JWT_SECRET` (same secret Supabase uses)
- JWT contains: `{ sub: user_id, telegram_id, role, exp }`
- Refresh token validity: 30 days

#### Onboarding (new citizens only):
After first Telegram auth, collect:
1. `full_name` (text input)
2. `phone_number` (text input, Uzbekistan format +998)
3. `address` (text input — tuman, mahalla)

---

### Admin / Superadmin Auth — Dashboard (Supabase Email)

Admins and superadmins log in via the Supabase-hosted dashboard using **email + password** (Supabase built-in Auth). They do **not** use the Telegram bot.

```
1. Admin opens the React dashboard
2. Logs in with email + password via Supabase Auth UI / supabase.auth.signInWithPassword()
3. Supabase issues a standard session JWT
4. Admin role is checked via JWT app_metadata.role
```

#### Admin role assignment:
- Roles are assigned by a superadmin via the **Supabase dashboard** (Authentication → Users → Edit user → `app_metadata`)
- Set `app_metadata = { "role": "admin" }` or `{ "role": "superadmin" }` using the service_role API
- `app_metadata` is set **server-side only** — users cannot modify it themselves
- The `users` table (which stores citizen telegram data) is **not used** for admin identity — admin identity lives entirely in Supabase Auth

#### Never mix these two systems:
- Admins do NOT have telegram_id records in the `users` table
- Citizens do NOT have Supabase Auth accounts
- All RLS admin checks use `(auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'superadmin')`

---

## Edge Functions

All business logic lives in Supabase Edge Functions. No separate backend server.

### Shared utilities — always import from `../_shared/`

```typescript
// _shared/cors.ts
export const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// _shared/auth.ts
export async function verifyJWT(req: Request): Promise<JWTPayload>

// _shared/telegram.ts
export async function sendTelegramMessage(chatId: number, text: string): Promise<void>
export async function sendTelegramKeyboard(chatId: number, text: string, keyboard: any): Promise<void>
```

### Every edge function MUST:
1. Handle `OPTIONS` preflight first (CORS)
2. Verify JWT for protected routes using `verifyJWT(req)`
3. Use `SUPABASE_SERVICE_ROLE_KEY` (not anon key) for DB operations
4. Return proper HTTP status codes (200, 401, 422, 500)
5. Always return `Content-Type: application/json`
6. Wrap in try/catch and return `{ error: message }` on failure

### Function list:

| Function | Method | Auth required | Description |
|---|---|---|---|
| `auth-telegram-init` | POST | No | Generate token, return Telegram deep link |
| `auth-telegram-verify` | GET | No | Poll for confirmation, return JWT |
| `bot-webhook` | POST | Bot secret | Handle all Telegram bot updates |
| `sync-full` | GET | Yes | Full data dump for first install |
| `sync-delta` | POST | Yes | Changed records since `last_sync_at` |
| `sync-news` | GET | Yes | Latest published news |
| `submit-murojaat` | POST | Yes | Submit citizen appeal |
| `admin-content` | POST/PUT/DELETE | Admin only | CRUD for all content types |

---

## Design System

### Color Palette

```dart
// Flutter — lib/core/theme/colors.dart
const kColorPrimary    = Color(0xFF1D9E75);  // Teal — main brand color
const kColorGold       = Color(0xFFC8A96E);  // Gold — accent
const kColorInk        = Color(0xFF0A0A0A);  // Near-black text
const kColorCream      = Color(0xFFF7F6F3);  // Background
const kColorStone      = Color(0xFFE8E6E1);  // Dividers, borders
const kColorTextMuted  = Color(0xFF888780);  // Secondary text
const kColorSuccess    = Color(0xFF1D9E75);
const kColorWarning    = Color(0xFFBA7517);
const kColorDanger     = Color(0xFFE24B4A);
```

```typescript
// Dashboard — src/lib/tokens.ts
export const colors = {
  primary: '#1D9E75',
  gold:    '#C8A96E',
  ink:     '#0A0A0A',
  cream:   '#F7F6F3',
  stone:   '#E8E6E1',
}
```

### Design Principles — ALWAYS follow:
- **Quiet luxury** — clean, minimal, spacious. Not flashy.
- **No gradients** in UI components (only data visualizations if needed)
- **Rounded corners**: `BorderRadius.circular(12)` for cards, `8` for tags/chips
- **Typography**: Use system fonts. Weight 400 for body, 500 for headings. Never 700.
- **Whitespace is intentional** — never pack elements tightly
- **Card-based layout** — each content item is a card with subtle border
- **Primary color (teal)** for CTAs and active states only — not decorative use
- **No drop shadows** — use `0.5px` borders instead

### Flutter Widget Conventions:

```dart
// Card style — use everywhere
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: kColorStone, width: 0.5),
  ),
)

// Person card (rahbariyat, xodimlar) — always this structure:
// [Avatar initials circle] [Name + Position] [Phone button]
// [Biography text — collapsed by default, expandable]

// Place card (turizm, ta'lim, tibbiyot, tashkilotlar):
// [Cover image] [Name] [Address + Phone] [Map button] [Detail button]

// News card:
// [Cover image] [Category badge] [Title] [Time ago]
```

---

## Module Definitions

### 1. Tuman Hokimligi (8 sub-sections)
- `to'g'risida` — static text about the district
- `hokimiyat_to'g'risida` — static text about the hokimiyat
- `rahbariyat` — leadership cards (photo, FISh, birth year, position, phone, biography, reception days)
- `apparat` — management staff cards (same fields as rahbariyat)
- `kengash` — people's council: kotibiyat + deputies (same card format)
- `mahallalar` — neighborhood list → detail (map, building photo, staff cards)
- `yer_maydonlari` — e-auction land plots (list, status badge, external link to e-auksion.uz)

### 2. Turizm (3 tabs)
- `diqqatga_sazovor_joylar` — attractions
- `ovqatlanish` — restaurants / cafes
- `mexmonxonalar` — hotels

Each item: images, name, location (map), phone, description, rating, comments.

### 3. Ta'lim (5 sub-sections)
- `oquv_markazlari` — learning centers
- `maktabgacha` — preschools (MTM)
- `maktablar` — schools
- `texnikumlar` — vocational colleges
- `oliy_talim` — universities

Each item: images, name, director, phone, location, description, comments.

### 4. Tibbiyot (2 sub-sections)
- `davlat_tibbiyot` — state medical facilities
- `xususiy_tibbiyot` — private clinics

Each item: images, name, phone, location, description, comments.
Action button: "Yo'nalish olish" (Get directions — opens map).

### 5. Tashkilotlar (2 sub-sections)
- `davlat_tashkilotlar` — state organizations
- `xususiy_korxonalar` — private businesses

Each item: images, name, director/head, phone, location, description, comments.

### 6. AI Assistant
- Full-screen chat UI
- Calls Supabase Edge Function which calls Gemini API (`gemini-2.0-flash` or latest stable)
- System prompt: expert on Turakurgan district services, Uzbek government procedures
- Quick question buttons: "Subsidiya olish tartibi", "Yer olish tartibi", "Nafaqa masalalari"
- Chat history stored locally in sqflite (max 50 messages)
- Language: respond in Uzbek by default

### 7. Bog'lanish (2 sub-sections)
- `kontaktlar` — phone, address, working hours, social media links
- `murojaat` — appeal form (full_name, phone, address, message text)
  - Submit via Edge Function `submit-murojaat`
  - Show success confirmation after submission
  - Store submitted appeals locally so user can see history

---

## Global Features

### Map Screen
- Shows ALL place types with filter chips (maktab, shifoxona, restoran, etc.)
- Uses `flutter_map` with OpenStreetMap tiles
- Marker tap → mini card popup → navigate to detail screen
- Filter by category with multi-select chips

### Search
- Global search across all local sqflite tables
- Fuzzy match on `name`, `full_name`, `description` fields
- Results grouped by category
- Fully offline — no network required

### Notifications
- Telegram bot sends push updates for important news
- In-app notification bell shows unread count
- Notification list screen with mark-as-read

---

## Coding Standards

### Dart / Flutter

```dart
// Feature folder structure — always use this pattern:
// features/{feature_name}/
//   ├── data/
//   │   ├── models/{feature}_model.dart
//   │   └── repositories/{feature}_repository.dart
//   ├── presentation/
//   │   ├── screens/{feature}_screen.dart
//   │   └── widgets/{feature}_card.dart
//   └── providers/{feature}_provider.dart  ← Riverpod

// Always use Riverpod for state management — never setState in feature screens
// Always use Dio for HTTP — never http package
// Always handle loading / error / empty states in every screen
// Always use const constructors where possible
// Never hardcode strings — use lib/core/constants/strings.dart
// Database queries always go in Repository classes, never in widgets
```

### TypeScript / Edge Functions

```typescript
// Always type request/response bodies
// Always validate input — return 422 with { error, field } if invalid
// Always use Deno.env.get() for secrets — never hardcode
// Use async/await — never .then() chains
// Export a single default serve() handler per function
// Log errors with console.error() — Supabase captures these
```

### React / Dashboard

```typescript
// Use React Query (TanStack Query) for all server state
// Use Zustand for UI state
// Components go in src/components/{ComponentName}/index.tsx
// Pages go in src/pages/{PageName}/index.tsx
// All Supabase calls go through src/lib/supabase.ts client
// Never call Supabase directly from components
// Always handle loading and error states in every data-fetching component
```

---

## Security Rules

### Row Level Security (RLS) — ALWAYS enabled on all tables

```sql
-- Public: read published content only (no auth required)
CREATE POLICY "public_read" ON places
  FOR SELECT USING (is_published = true);

-- Admins: full CRUD on content tables
-- Role is stored in Supabase Auth app_metadata (set via service_role only)
CREATE POLICY "admin_write" ON places
  FOR ALL USING (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'superadmin')
  );

-- Admins: read all citizen records
CREATE POLICY "admin_read_users" ON users
  FOR SELECT USING (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'superadmin')
  );

-- Admins: read and manage all appeals
CREATE POLICY "admin_all_murojaatlar" ON murojaatlar
  FOR ALL USING (
    (auth.jwt() -> 'app_metadata' ->> 'role') IN ('admin', 'superadmin')
  );
```

### General Security Rules:
- Never expose `SUPABASE_SERVICE_ROLE_KEY` to the client
- Never store JWT in sqflite — use `flutter_secure_storage`
- Validate and sanitize all user input before inserting to DB
- Telegram bot webhook must verify `X-Telegram-Bot-Api-Secret-Token` header
- Rate limit `submit-murojaat` to 5 submissions per user per day

---

## Environment Variables

```bash
# Supabase Edge Functions — set via Supabase dashboard secrets
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJ...
TELEGRAM_BOT_TOKEN=7xxx:AAA...
TELEGRAM_WEBHOOK_SECRET=your-random-secret-here
GEMINI_API_KEY=AIza...  # for AI assistant

# Flutter — lib/core/config/env.dart (gitignored, use --dart-define)
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_ANON_KEY=eyJ...

# Dashboard — .env.local (gitignored)
VITE_SUPABASE_URL=https://xxxx.supabase.co
VITE_SUPABASE_ANON_KEY=eyJ...
```

---

## Localization

Supported languages (in priority order):
1. **Uzbek Latin** (`uz`) — primary language, default
2. **Uzbek Cyrillic** (`uz_cyrl`) — for older / rural users
3. **Russian** (`ru`) — widely used secondary language
4. **English** (`en`) — for testing and international users

### UI Localization (Flutter)
- All UI strings must use `AppLocalizations` — never hardcode text in widgets
- Locale files live in `mobile/lib/l10n/` as `app_uz.arb`, `app_uz_cyrl.arb`, `app_ru.arb`, `app_en.arb`
- Language switcher must be accessible from the app settings screen

### Database Localization
- Base columns (`name`, `title`, `description`, `biography`, etc.) always store **Uzbek Latin** — the canonical source
- Every content table has a `translations jsonb` column for other locales:
  ```json
  {
    "ru":      { "name": "...", "description": "..." },
    "uz_cyrl": { "name": "...", "description": "..." },
    "en":      { "name": "...", "description": "..." }
  }
  ```
- Tables with `translations`: `rahbariyat`, `mahallalar`, `mahalla_xodimlari`, `yer_maydonlari`, `places`, `yangiliklar`, `bildirishnomalar`
- Missing locale key → fall back to the Uzbek Latin base column value
- The Flutter app reads the active locale and picks the right value from `translations` if available
- Admin dashboard must provide translation input fields for all localizable text fields

### AI Assistant
- Responds in Uzbek Latin by default
- Switches language to match the user's input locale

---

## Performance Rules

- All list screens must use lazy loading / pagination (20 items per page)
- Images must be compressed to WebP, max 200KB before upload
- Local sqflite queries must use indexes on `category`, `updated_at`, `is_published`
- Dashboard tables must use virtual scrolling for lists > 100 items
- Edge functions must complete in < 2 seconds — use `Promise.all()` for parallel queries
- Never download images that already exist locally (check file existence before download)

---

## Naming Conventions

| Context | Convention | Example |
|---|---|---|
| Dart files | snake_case | `rahbariyat_card.dart` |
| Dart classes | PascalCase | `RahbariyatCard` |
| Dart variables | camelCase | `lastSyncAt` |
| TypeScript files | kebab-case | `sync-delta.ts` |
| TypeScript types | PascalCase | `DeltaSyncResponse` |
| Database tables | snake_case | `pending_auth` |
| Database columns | snake_case | `telegram_id` |
| Supabase functions | kebab-case | `auth-telegram-init` |
| React components | PascalCase | `PlaceCard.tsx` |

---

## Do Not

- Do NOT use `GetX` — use Riverpod for state management
- Do NOT use `http` package — use `Dio`
- Do NOT store secrets in source code or `.env` files committed to git
- Do NOT call Supabase directly from Flutter widgets — always go through a Repository
- Do NOT use `dynamic` type in Dart — always type your models
- Do NOT skip RLS policies — every table must have them
- Do NOT add content directly to the database — always go through admin dashboard
- Do NOT use REST API directly for sync — always use Edge Functions
- Do NOT use paid map providers — OpenStreetMap only
