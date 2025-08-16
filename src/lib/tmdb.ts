import type { Movie, TVShow, Credits, Media } from '@/types/tmdb';

const API_KEY = process.env.TMDB_API_KEY;
const API_BASE_URL = 'https://api.themoviedb.org/3';

async function fetcher<T>(path: string, params: Record<string, string> = {}): Promise<T> {
  const url = new URL(`${API_BASE_URL}${path}`);
  url.searchParams.append('api_key', API_KEY!);
  Object.entries(params).forEach(([key, value]) => url.searchParams.append(key, value));

  const response = await fetch(url.toString());
  if (!response.ok) {
    console.error(`Failed to fetch from TMDB: ${response.statusText}`);
    return [] as T; // Return empty array or object on error
  }
  return response.json();
}

const normalizeMedia = (items: (Movie | TVShow)[], media_type: 'movie' | 'tv'): Media[] => {
  return items.map(item => ({ ...item, media_type }));
};

export async function getTrending(media_type: 'movie' | 'tv'): Promise<Media[]> {
  const data = await fetcher<{ results: (Movie | TVShow)[] }>(`/trending/${media_type}/week`);
  return normalizeMedia(data.results, media_type);
}

export async function getPopular(media_type: 'movie' | 'tv'): Promise<Media[]> {
  const data = await fetcher<{ results: (Movie | TVShow)[] }>(`/${media_type}/popular`);
  return normalizeMedia(data.results, media_type);
}

export async function searchMedia(query: string, media_type: 'movie' | 'tv'): Promise<Media[]> {
  const data = await fetcher<{ results: (Movie | TVShow)[] }>(`/search/${media_type}`, { query });
  return normalizeMedia(data.results, media_type);
}

// Movie specific functions
export async function getMovieDetails(id: number): Promise<Movie & { media_type: 'movie' }> {
  const movie = await fetcher<Movie>(`/movie/${id}`);
  return { ...movie, media_type: 'movie' };
}

export async function getMovieCredits(id: number): Promise<Credits> {
  return fetcher<Credits>(`/movie/${id}/credits`);
}

export async function getSimilarMovies(id: number): Promise<Media[]> {
  const data = await fetcher<{ results: Movie[] }>(`/movie/${id}/similar`);
  return normalizeMedia(data.results, 'movie');
}


// TV Show specific functions
export async function getTvShowDetails(id: number): Promise<TVShow & { media_type: 'tv' }> {
  const show = await fetcher<TVShow>(`/tv/${id}`);
  return { ...show, media_type: 'tv' };
}

export async function getTvShowCredits(id: number): Promise<Credits> {
  return fetcher<Credits>(`/tv/${id}/credits`);
}

export async function getSimilarTvShows(id: number): Promise<Media[]> {
    const data = await fetcher<{ results: TVShow[] }>(`/tv/${id}/similar`);
    return normalizeMedia(data.results, 'tv');
}
