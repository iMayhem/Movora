-- 1. Create the Rooms table
CREATE TABLE IF NOT EXISTS public.rooms (
    id TEXT PRIMARY KEY,
    movie_title TEXT NOT NULL,
    embed_sources JSONB NOT NULL,
    scheduled_start_time TIMESTAMP WITH TIME ZONE NOT NULL
);

-- 2. Clear any existing records to allow re-seeding
TRUNCATE TABLE public.rooms;

-- 3. Seed active scheduled rooms with relative start times
-- This dynamically calculates the times based on current timestamp so the lobbies are immediately testable!
INSERT INTO public.rooms (id, movie_title, embed_sources, scheduled_start_time)
VALUES 
(
    'interstellar', 
    'Interstellar', 
    '{
        "vidplus": "https://player.vidplus.to/embed/movie/157336",
        "videasy": "https://player.videasy.net/movie/157336",
        "vidsrc": "https://vidsrc-embed.ru/embed/movie?tmdb=157336&autoplay=1"
    }'::jsonb,
    NOW() + INTERVAL '2 minutes' -- COUNTDOWN MODE: starts in 2 minutes
),
(
    'dark-knight', 
    'The Dark Knight', 
    '{
        "vidplus": "https://player.vidplus.to/embed/movie/155",
        "videasy": "https://player.videasy.net/movie/155",
        "vidsrc": "https://vidsrc-embed.ru/embed/movie?tmdb=155&autoplay=1"
    }'::jsonb,
    NOW() - INTERVAL '5 seconds' -- ALERT MODE: started 5 seconds ago
),
(
    'spider-verse', 
    'Spider-Man: Into the Spider-Verse', 
    '{
        "vidplus": "https://player.vidplus.to/embed/movie/324857",
        "videasy": "https://player.videasy.net/movie/324857",
        "vidsrc": "https://vidsrc-embed.ru/embed/movie?tmdb=324857&autoplay=1"
    }'::jsonb,
    NOW() - INTERVAL '45 minutes' -- CATCH-UP MODE: started 45 minutes ago
);

-- 4. Enable Row Level Security (RLS) and allow public reading of rooms
ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read access to rooms" 
ON public.rooms 
FOR SELECT 
USING (true);

CREATE POLICY "Allow public insert access to rooms" 
ON public.rooms 
FOR INSERT 
WITH CHECK (true);
