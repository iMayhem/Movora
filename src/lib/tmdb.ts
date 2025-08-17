import type { Movie, TVShow, Credits, Media, SeasonDetails } from '@/types/tmdb';

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

  try {
    const response = await fetch(url.toString(), { cache: 'no-store' });
    if (!response.ok) {
      console.error(`Failed to fetch from TMDB: ${response.statusText}`);
      return null;
    }
    return response.json();
  } catch (error) {
    console.error('Error fetching from TMDB:', error);
    return null;
  }
}

const normalizeMedia = (items: (Movie | TVShow)[], media_type?: 'movie' | 'tv'): Media[] => {
  if (!items) return [];
  return items
    .filter(item => item.poster_path) // Filter out items without a poster_path
    .map(item => ({ 
    ...item, 
    media_type: item.media_type || ('title' in item ? 'movie' : 'tv')
  }));
};

export async function getTrending(media_type: 'movie' | 'tv', time_window: 'day' | 'week' = 'week', pages = 3): Promise<Media[]> {
  const pagePromises = Array.from({ length: pages }, (_, i) =>
    fetcher<{ results: (Movie | TVShow)[] }>(`/trending/${media_type}/${time_window}`, { page: String(i + 1) })
  );
  const allPages = await Promise.all(pagePromises);
  const allResults = allPages.flatMap(page => page?.results || []);
  if (!allResults?.length) return [];
  return normalizeMedia(allResults);
}

export async function getPopular(media_type: 'movie' | 'tv', params: Record<string, string> = {}, pages = 1): Promise<Media[]> {
  const pagePromises = Array.from({ length: pages }, (_, i) => 
    fetcher<{ results: (Movie | TVShow)[] }>(`/${media_type}/popular`, { ...params, page: String(i + 1) })
  );
  const allPages = await Promise.all(pagePromises);
  const allResults = allPages.flatMap(page => page?.results || []);

  if (!allResults.length) return [];
  return normalizeMedia(allResults, media_type);
}

export async function getNowPlayingMovies(pages = 1): Promise<Media[]> {
    const pagePromises = Array.from({ length: pages }, (_, i) => 
        fetcher<{ results: Movie[] }>(`/movie/now_playing`, { page: String(i + 1) })
    );
    const allPages = await Promise.all(pagePromises);
    const allResults = allPages.flatMap(page => page?.results || []);

    if (!allResults.length) return [];
    return normalizeMedia(allResults, 'movie');
}


export async function searchMedia(query: string, media_type: 'movie' | 'tv', params: Record<string, string> = {}): Promise<Media[]> {
  const data = await fetcher<{ results: (Movie | TVShow)[] }>(`/search/${media_type}`, { query, ...params });
  if (!data?.results) return [];
  return normalizeMedia(data.results, media_type);
}

// Discover movies with specific criteria
export async function discoverMovies(params: Record<string, string> = {}, pages = 2): Promise<Media[]> {
  const pagePromises = Array.from({ length: pages }, (_, i) => 
    fetcher<{ results: Movie[] }>(`/discover/movie`, { ...params, page: String(i + 1) })
  );
  
  const allPages = await Promise.all(pagePromises);
  const allResults = allPages.flatMap(page => page?.results || []);
  
  if (!allResults.length) return [];
  return normalizeMedia(allResults, 'movie');
}

export async function discoverTvShows(params: Record<string, string> = {}, pages = 1): Promise<Media[]> {
  const pagePromises = Array.from({ length: pages }, (_, i) => 
    fetcher<{ results: TVShow[] }>(`/discover/tv`, { ...params, page: String(i + 1) })
  );
  
  const allPages = await Promise.all(pagePromises);
  const allResults = allPages.flatMap(page => page?.results || []);
  
  if (!allResults.length) return [];
  return normalizeMedia(allResults, 'tv');
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
  const show = await fetcher<TVShow>(`/tv/${id}`, { append_to_response: 'videos,season_details' });
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

export async function getSeasonDetails(tvId: number, seasonNumber: number): Promise<SeasonDetails | null> {
  return fetcher<SeasonDetails>(`/tv/${tvId}/season/${seasonNumber}`);
}
