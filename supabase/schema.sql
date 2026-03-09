-- =================================================================
-- INKWELL BLOG — Supabase Database Setup
-- Run this SQL in your Supabase SQL Editor
-- =================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =================================================================
-- PROFILES TABLE
-- =================================================================
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  name TEXT,
  avatar TEXT,
  email TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- RLS for profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public profiles are viewable by everyone"
  ON public.profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can insert their own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- =================================================================
-- POSTS TABLE
-- =================================================================
CREATE TABLE IF NOT EXISTS public.posts (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  title TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  cover_image TEXT,
  content TEXT NOT NULL DEFAULT '',
  excerpt TEXT,
  author TEXT NOT NULL DEFAULT 'Editor',
  published BOOLEAN DEFAULT FALSE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Indexes
CREATE INDEX IF NOT EXISTS posts_slug_idx ON public.posts (slug);
CREATE INDEX IF NOT EXISTS posts_published_idx ON public.posts (published);
CREATE INDEX IF NOT EXISTS posts_created_at_idx ON public.posts (created_at DESC);

-- RLS for posts
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Published posts are viewable by everyone"
  ON public.posts FOR SELECT
  USING (published = true OR auth.uid()::TEXT = current_setting('app.admin_user_id', true));

CREATE POLICY "Only admin can insert posts"
  ON public.posts FOR INSERT
  WITH CHECK (auth.uid()::TEXT = current_setting('app.admin_user_id', true));

CREATE POLICY "Only admin can update posts"
  ON public.posts FOR UPDATE
  USING (auth.uid()::TEXT = current_setting('app.admin_user_id', true));

CREATE POLICY "Only admin can delete posts"
  ON public.posts FOR DELETE
  USING (auth.uid()::TEXT = current_setting('app.admin_user_id', true));

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_posts_updated_at
  BEFORE UPDATE ON public.posts
  FOR EACH ROW
  EXECUTE PROCEDURE update_updated_at_column();

-- =================================================================
-- COMMENTS TABLE
-- =================================================================
CREATE TABLE IF NOT EXISTS public.comments (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  post_id UUID REFERENCES public.posts(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  comment TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Indexes
CREATE INDEX IF NOT EXISTS comments_post_id_idx ON public.comments (post_id);
CREATE INDEX IF NOT EXISTS comments_created_at_idx ON public.comments (created_at);

-- RLS for comments
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Comments are viewable by everyone"
  ON public.comments FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can insert comments"
  ON public.comments FOR INSERT
  WITH CHECK (auth.uid() = user_id AND auth.role() = 'authenticated');

CREATE POLICY "Users can delete their own comments"
  ON public.comments FOR DELETE
  USING (auth.uid() = user_id);

-- =================================================================
-- STORAGE BUCKETS
-- Run these via Supabase Dashboard > Storage > Create bucket
-- OR use the SQL below (requires Supabase Storage API)
-- =================================================================

-- Bucket: post-covers (public)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'post-covers',
  'post-covers',
  true,
  5242880, -- 5MB
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO NOTHING;

-- Bucket: post-media (public)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'post-media',
  'post-media',
  true,
  10485760, -- 10MB
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif', 'video/mp4']
)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for post-covers
CREATE POLICY "post-covers are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'post-covers');

CREATE POLICY "Admin can upload post covers"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'post-covers' AND auth.role() = 'authenticated');

CREATE POLICY "Admin can update post covers"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'post-covers' AND auth.role() = 'authenticated');

CREATE POLICY "Admin can delete post covers"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'post-covers' AND auth.role() = 'authenticated');

-- Storage policies for post-media
CREATE POLICY "post-media is publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'post-media');

CREATE POLICY "Authenticated users can upload post media"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'post-media' AND auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can update their media"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'post-media' AND auth.role() = 'authenticated');

-- =================================================================
-- HELPER FUNCTION: Auto-create profile on signup
-- =================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, name, avatar, email)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', SPLIT_PART(NEW.email, '@', 1)),
    NEW.raw_user_meta_data->>'avatar_url',
    NEW.email
  )
  ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    avatar = EXCLUDED.avatar,
    email = EXCLUDED.email;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on new user signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- =================================================================
-- SAMPLE DATA (optional — remove in production)
-- =================================================================
INSERT INTO public.posts (title, slug, excerpt, author, content, published)
VALUES (
  'Welcome to Inkwell',
  'welcome-to-inkwell',
  'A new platform for human stories and ideas. Simple, beautiful, and distraction-free.',
  'The Inkwell Team',
  '<h2>Welcome to Inkwell</h2><p>This is a place for human stories and ideas. We believe that great writing deserves a great home.</p><p>Inkwell is inspired by the best parts of blogging — clean typography, distraction-free reading, and a community of curious minds.</p><h2>Getting Started</h2><p>Sign in with your Google account to leave comments and engage with stories. The writing experience is crafted to help you focus on what matters most: your words.</p><blockquote>The pen is mightier than the sword. And considerably easier to write with.</blockquote><p>We hope you enjoy reading (and writing) here.</p>',
  true
)
ON CONFLICT (slug) DO NOTHING;
