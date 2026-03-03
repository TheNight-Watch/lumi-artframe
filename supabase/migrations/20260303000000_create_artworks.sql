-- Create artworks table
CREATE TABLE artworks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  title TEXT,
  image_url TEXT NOT NULL,
  video_url TEXT,
  video_task_id TEXT,
  video_status TEXT DEFAULT 'pending',
  story_title TEXT,
  story_content TEXT,
  video_prompt TEXT,
  creativity_analysis TEXT,
  mood_analysis TEXT,
  additional_insights TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- RLS policies: users can only access their own artworks
ALTER TABLE artworks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own artworks"
  ON artworks FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own artworks"
  ON artworks FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own artworks"
  ON artworks FOR UPDATE
  USING (auth.uid() = user_id);

-- Enable Realtime for artworks table
ALTER PUBLICATION supabase_realtime ADD TABLE artworks;

-- Create storage bucket for artwork images
INSERT INTO storage.buckets (id, name, public)
VALUES ('artworks', 'artworks', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies
CREATE POLICY "Users can upload artwork images"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'artworks' AND auth.uid() IS NOT NULL);

CREATE POLICY "Anyone can view artwork images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'artworks');
