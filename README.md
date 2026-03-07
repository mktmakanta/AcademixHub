# AcademixHub Blog

A clean, production-ready educational blog built with **Next.js 14**, **TypeScript**, **TailwindCSS**, and **Supabase**. Inspired by Medium, built for simplicity.

---

## Tech Stack

| Layer     | Technology                   |
| --------- | ---------------------------- |
| Framework | Next.js 14 (App Router)      |
| Language  | TypeScript                   |
| Styling   | TailwindCSS                  |
| Database  | Supabase (PostgreSQL)        |
| Auth      | Supabase Auth + Google OAuth |
| Storage   | Supabase Storage             |
| Rich Text | TipTap v2                    |
| Font      | Lora (serif) + Source Sans 3 |

---

## Features

- 📝 **Homepage** — Featured post + post grid with cover images, excerpts, and authors
- 📖 **Single post page** — Full article with rich content (text, images, videos)
- 💬 **Comment system** — Google OAuth login required to comment; avatar + name display
- 🔒 **Admin dashboard** — Create, edit, and publish posts with a rich text editor
- 🖼️ **Media uploads** — Cover images and in-article media via Supabase Storage
- 📱 **Responsive design** — Mobile-first, clean typography
- ⚡ **Server Components** — Fast, SEO-friendly rendering with Next.js App Router

---

## Project Structure

```
AcademixHub-blog/
├── app/
│   ├── layout.tsx                    # Root layout (Navbar, Footer)
│   ├── page.tsx                      # Homepage
│   ├── globals.css                   # Global styles + TipTap CSS
│   ├── not-found.tsx                 # 404 page
│   ├── post/
│   │   └── [slug]/
│   │       └── page.tsx              # Single post page
│   ├── admin/
│   │   ├── layout.tsx                # Admin layout with nav
│   │   ├── page.tsx                  # Posts dashboard
│   │   ├── new/
│   │   │   └── page.tsx              # New post form
│   │   └── edit/
│   │       └── [id]/
│   │           └── page.tsx          # Edit post form
│   ├── auth/
│   │   ├── callback/
│   │   │   └── route.ts              # OAuth callback + profile upsert
│   │   └── auth-code-error/
│   │       └── page.tsx              # Auth error page
│   └── api/
│       └── auth/
│           ├── signin/route.ts
│           └── signout/route.ts
├── components/
│   ├── layout/
│   │   ├── Navbar.tsx                # Sticky navbar with auth state
│   │   └── Footer.tsx
│   ├── post/
│   │   ├── PostCard.tsx              # Grid card for homepage
│   │   ├── FeaturedPost.tsx          # Large hero post
│   │   └── AuthorBadge.tsx           # Author + date display
│   ├── comment/
│   │   ├── CommentSection.tsx        # Section wrapper
│   │   ├── CommentForm.tsx           # Form + Google sign-in CTA
│   │   └── CommentList.tsx           # Rendered comments
│   └── admin/
│       ├── PostEditor.tsx            # Full post editor (title, excerpt, cover, content)
│       └── RichTextEditor.tsx        # TipTap WYSIWYG editor
├── lib/
│   ├── supabase/
│   │   ├── client.ts                 # Browser Supabase client
│   │   ├── server.ts                 # Server Supabase client (cookies)
│   │   └── admin.ts                  # Service role client
│   └── utils.ts                      # formatDate, slugify, getPublicImageUrl...
├── types/
│   └── index.ts                      # Post, Comment, Profile types
├── supabase/
│   └── schema.sql                    # Full DB schema + RLS + storage buckets
├── middleware.ts                     # Auth guard for /admin routes
├── next.config.mjs
├── tailwind.config.js
├── tsconfig.json
└── .env.local.example
```

---

## Setup Guide

### 1. Clone & Install

```bash
git clone <your-repo>
cd academixhub
npm install
```

### 2. Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Wait for the project to be ready (~1 minute)

### 3. Run the Database Schema

1. In your Supabase dashboard, go to **SQL Editor**
2. Open the file `supabase/schema.sql`
3. Paste the contents and click **Run**

This creates:

- `profiles` table with RLS
- `posts` table with RLS and auto-updated `updated_at`
- `comments` table with RLS
- `post-covers` storage bucket (public, 5MB limit)
- `post-media` storage bucket (public, 10MB limit)
- Auto-trigger to create profiles on user signup

### 4. Enable Google OAuth

1. In Supabase dashboard → **Authentication** → **Providers**
2. Enable **Google**
3. Go to [Google Cloud Console](https://console.cloud.google.com/)
4. Create a project → **APIs & Services** → **Credentials** → **OAuth 2.0 Client IDs**
5. Set **Authorized redirect URI** to:
   ```
   https://<your-supabase-project>.supabase.co/auth/v1/callback
   ```
6. Copy the **Client ID** and **Client Secret** back to Supabase → Google provider settings

### 5. Configure Environment Variables

```bash
cp .env.local.example .env.local
```

Fill in `.env.local`:

```env
# From Supabase: Settings > API
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Your Supabase user ID (after signing in with Google)
# Go to Supabase Dashboard > Authentication > Users to find your UUID
ADMIN_USER_ID=your-uuid-here

# For local dev
NEXT_PUBLIC_SITE_URL=http://localhost:3000
```

> **How to get your Admin User ID:**
>
> 1. Start the app (`npm run dev`)
> 2. Sign in with Google on the homepage
> 3. Go to Supabase Dashboard → Authentication → Users
> 4. Copy your User UUID and paste it as `ADMIN_USER_ID`

### 6. Run Locally

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000)

---

## Usage

### Writing a Post (Admin)

1. Sign in with Google (your account must match `ADMIN_USER_ID`)
2. Click **Dashboard** in the navbar or go to `/admin`
3. Click **Write a story**
4. Fill in:
   - Cover image (drag or click to upload)
   - Title
   - Excerpt (optional subtitle)
   - Author name
   - Body content using the rich text editor
5. Toggle **Publish** to make it live, or save as draft
6. Click **Publish Story** or **Save Draft**

### Editor Toolbar

| Button       | Action                             |
| ------------ | ---------------------------------- |
| B / I / S    | Bold, Italic, Strikethrough        |
| H1 / H2 / H3 | Headings                           |
| "            | Blockquote                         |
| List icons   | Bullet & ordered lists             |
| `< >`        | Code block                         |
| 🔗           | Insert link                        |
| 🖼️           | Upload image (to Supabase Storage) |
| ▶            | Embed YouTube video                |
| ↩ / ↪        | Undo / Redo                        |

### Commenting

1. Open any published post
2. Scroll to the **Responses** section
3. If not signed in, click **Sign in with Google to comment**
4. Type your response and click **Respond**

---

## Database Schema

### `profiles`

| Column     | Type        | Description                |
| ---------- | ----------- | -------------------------- |
| id         | UUID (PK)   | References `auth.users.id` |
| name       | TEXT        | Display name               |
| avatar     | TEXT        | Avatar URL (from Google)   |
| email      | TEXT        | Email address              |
| created_at | TIMESTAMPTZ | Auto-set                   |

### `posts`

| Column      | Type          | Description                       |
| ----------- | ------------- | --------------------------------- |
| id          | UUID (PK)     | Auto-generated                    |
| title       | TEXT          | Post title                        |
| slug        | TEXT (UNIQUE) | URL-friendly identifier           |
| cover_image | TEXT          | Storage path (post-covers bucket) |
| content     | TEXT          | HTML content from TipTap          |
| excerpt     | TEXT          | Short description                 |
| author      | TEXT          | Author display name               |
| published   | BOOLEAN       | Draft vs published                |
| created_at  | TIMESTAMPTZ   | Auto-set                          |
| updated_at  | TIMESTAMPTZ   | Auto-updated via trigger          |

### `comments`

| Column     | Type        | Description                |
| ---------- | ----------- | -------------------------- |
| id         | UUID (PK)   | Auto-generated             |
| post_id    | UUID (FK)   | References `posts.id`      |
| user_id    | UUID (FK)   | References `auth.users.id` |
| comment    | TEXT        | Comment body               |
| created_at | TIMESTAMPTZ | Auto-set                   |

---

## Storage Buckets

| Bucket        | Public | Max Size | Used For          |
| ------------- | ------ | -------- | ----------------- |
| `post-covers` | ✅     | 5MB      | Post cover images |
| `post-media`  | ✅     | 10MB     | In-article images |

---

## Deployment (Vercel)

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel
```

Set the same environment variables from `.env.local` in your Vercel project settings.

Update `NEXT_PUBLIC_SITE_URL` to your production URL.

Update the Google OAuth redirect URI to include your production domain:

```
https://your-project.supabase.co/auth/v1/callback
```

---

## Security Notes

- `/admin` routes are protected by middleware that checks `ADMIN_USER_ID`
- Supabase RLS ensures posts can only be created/edited by the admin user
- Comments require authentication (`auth.role() = 'authenticated'`)
- The `SUPABASE_SERVICE_ROLE_KEY` is server-side only and never exposed to the client
- Row Level Security is enabled on all tables

---

## Customization

- **Brand name**: Search & replace `Inkwell` across the project
- **Admin**: Change `ADMIN_USER_ID` in `.env.local` to any Supabase user UUID
- **Fonts**: Edit `app/globals.css` Google Fonts import and `tailwind.config.js`
- **Colors**: CSS variables in `globals.css` (`:root` block)
- **Post card layout**: Edit `components/post/PostCard.tsx`
