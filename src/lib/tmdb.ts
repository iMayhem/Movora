import type { Movie, TVShow, Credits, Media } from '@/types/tmdb';

const API_KEY = process.env.TMDB_API_KEY;
const API_BASE_URL = 'https://api.themoviedb.org/3';

async function fetcher<T>(path: string, params: Record<string, string> = {}): Promise<T | null> {
  if (!API_KEY || API_KEY === 'your_tmdb_api_key_here') {
    console.error('TMDB API key is not set. Please set TMDB_API_KEY in your environment variables.');
    return null;
  }
  
  const url = new URL(`${API_BASE_URL}${path}`);
  url.searchParams.append('api_key', API_KEY!);
  Object.entries(params).forEach(([key, value]) => url.searchParams.append(key, value));

  const response = await fetch(url.toString());
  if (!response.ok) {
    console.error(`Failed to fetch from TMDB: ${response.statusText}`);
    return null;
  }
  return response.json();
}

const normalizeMedia = (items: (Movie | TVShow)[], media_type: 'movie' | 'tv'): Media[] => {
  if (!items) return [];
  return items.map(item => ({ ...item, media_type }));
};

export async function getTrending(media_type: 'movie' | 'tv'): Promise<Media[]> {
  const data = await fetcher<{ results: (Movie | TVShow)[] }>(`/trending/${media_type}/week`);
  if (!data?.results) return [];
  return normalizeMedia(data.results, media_type);
}

export async function getPopular(media_type: 'movie' | 'tv'): Promise<Media[]> {
  const data = await fetcher<{ results: (Movie | TVShow)[] }>(`/${media_type}/popular`);
  if (!data?.results) return [];
  return normalizeMedia(data.results, media_type);
}

export async function searchMedia(query: string, media_type: 'movie' | 'tv'): Promise<Media[]> {
  const data = await fetcher<{ results: (Movie | TVShow)[] }>(`/search/${media_type}`, { query });
  if (!data?.results) return [];
  return normalizeMedia(data.results, media_type);
}

// Movie specific functions
export async function getMovieDetails(id: number): Promise<(Movie & { media_type: 'movie' }) | null> {
  const movie = await fetcher<Movie>(`/movie/${id}`, { append_to_response: 'videos' });
  if (!movie) return null;
  return { ...movie, media_type: 'movie' };
}

export async function getMovieCredits(id: number): Promise<Credits | null> {
  return fetcher<Credits>(`/movie/${id}/credits`);
}

export async function getSimilarMovies(id: number): Promise<Media[]> {
  const data = await fetcher<{ results: Movie[] }>(`/movie/${id}/similar`);
  if (!data?.results) return [];
  return normalizeMedia(data.results, 'movie');
}


// TV Show specific functions
export async function getTvShowDetails(id: number): Promise<(TVShow & { media_type: 'tv' }) | null> {
  const show = await fetcher<TVShow>(`/tv/${id}`, { append_to_response: 'videos' });
  if (!show) return null;
  return { ...show, media_type: 'tv' };
}

export async function getTvShowCredits(id: number): Promise<Credits | null> {
  return fetcher<Credits>(`/tv/${id}/credits`);
}

export async function getSimilarTvShows(id: number): Promise<Media[]> {
    const data = await fetcher<{ results: TVShow[] }>(`/tv/${id}/similar`);
    if (!data?.results) return [];
    return normalizeMedia(data.results, 'tv');
}