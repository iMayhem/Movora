import os

# This script fixes the TypeScript error in src/lib/tmdb.ts
# by adding 'as Media[]' to the return statement of normalizeMedia.

tmdb_content = """
import {unstable_cache as cache} from 'next/cache';
import type {Media, Movie, SeasonDetails, TVShow, Video} from '@/types/tmdb';
import { discoverCategories } from './discover-categories';

// Use NEXT_PUBLIC_ prefix so it's available in the browser
const API_KEY = process.env.NEXT_PUBLIC_TMDB_API_KEY || process.env.TMDB_API_KEY;
const API_BASE_URL = 'https://api.themoviedb.org/3';

async function fetcher<T>(
  path: string,
  params: Record<string, string> = {}
): Promise<T | null> {
  if (!API_KEY) {
    console.error('TMDB API key is missing. Make sure NEXT_PUBLIC_TMDB_API_KEY is set in .env.local');
    return null;
  }

  const url = new URL(`${API_BASE_URL}${path}`);
  url.searchParams.append('api_key', API_KEY);
  Object.entries(params).forEach(([key, value]) =>
    url.searchParams.append(key, value)
  );

  try {
    const response = await fetch(url.toString());
    if (!response.ok) {
      console.error(`Failed to fetch from TMDB: ${response.status} ${response.statusText}`);
      return null;
    }
    return response.json();
  } catch (error) {
    console.error('Error fetching from TMDB:', error);
    return null;
  }
}

const normalizeMedia = (
  items: (Movie | TVShow)[],
  media_type?: 'movie' | 'tv' | 'all'
): Media[] => {
  if (!items) return [];
  return items
    .filter(item => item && item.poster_path)
    .map(item => ({
      ...item,
      media_type: item.media_type || ('title' in item ? 'movie' : 'tv'),
    })) as Media[]; // <--- THE FIX: Explicit type assertion
};

const cachedFetcher = <T>(
  path: string,
  params: Record<string, string> = {},
  revalidate: number,
  tags: string[]
) => {
  // If running in browser, fetch directly (no cache)
  if (typeof window !== 'undefined') {
    return () => fetcher<T>(path, params);
  }
  // If running on server, use Next.js cache
  return cache(
    () => fetcher<T>(path, params),
    [path, ...Object.values(params)],
    {revalidate, tags}
  );
};

export async function fetchPage(page: number, slug: string): Promise<Media[]> {
    const category = discoverCategories[slug];
    if (!category) return [];
    return category.fetcher(page);
}

export async function getTrending(
  media_type: 'movie' | 'tv' | 'all',
  time_window: 'day' | 'week' = 'week',
  pages = 3
): Promise<Media[]> {
  const pagePromises = Array.from({length: pages}, (_, i) =>
    cachedFetcher<{results: (Movie | TVShow)[]}>(
      `/trending/${media_type}/${time_window}`,
      {page: String(i + 1)},
      3600,
      [`trending-${media_type}`]
    )()
  );
  const allPages = await Promise.all(pagePromises);
  const allResults = allPages.flatMap(page => page?.results || []);
  if (!allResults?.length) return [];
  return normalizeMedia(allResults);
}

export async function getPopular(
  media_type: 'movie' | 'tv',
  params: Record<string, string> = {},
  pages = 1
): Promise<Media[]> {
  const pagePromises = Array.from({length: pages}, (_, i) =>
    cachedFetcher<{results: (Movie | TVShow)[]}>(
      `/${media_type}/popular`,
      {...params, page: String(i + 1)},
      3600,
      [`popular-${media_type}`]
    )()
  );
  const allPages = await Promise.all(pagePromises);
  const allResults = allPages.flatMap(page => page?.results || []);
  if (!allResults.length) return [];
  return normalizeMedia(allResults, media_type);
}

export async function searchMedia(
  query: string,
  media_type: 'movie' | 'tv',
  params: Record<string, string> = {},
  page: number = 1,
): Promise<Media[]> {
  const fetchFunction = cachedFetcher<{results: (Movie | TVShow)[]}>(
    `/search/${media_type}`,
    {query, ...params, page: String(page)},
    3600,
    [`search-${media_type}-${query}-p${page}`]
  );
  const data = await fetchFunction();
  if (!data?.results) return [];
  return normalizeMedia(data.results, media_type);
}

export async function discoverMovies(
  params: Record<string, string> = {},
  pages = 2
): Promise<Media[]> {
  const pagePromises = Array.from({length: pages}, (_, i) =>
    cachedFetcher<{results: Movie[]}>(
      `/discover/movie`,
      {...params, page: String(i + 1)},
      3600,
      ['discover-movies', ...Object.values(params)]
    )()
  );
  const allPages = await Promise.all(pagePromises);
  const allResults = allPages.flatMap(page => page?.results || []);
  if (!allResults.length) return [];
  return normalizeMedia(allResults, 'movie');
}

export async function discoverTvShows(
  params: Record<string, string> = {},
  pages = 1
): Promise<Media[]> {
  const pagePromises = Array.from({length: pages}, (_, i) =>
    cachedFetcher<{results: TVShow[]}>(
      `/discover/tv`,
      {...params, page: String(i + 1)},
      3600,
      ['discover-tv']
    )()
  );
  const allPages = await Promise.all(pagePromises);
  const allResults = allPages.flatMap(page => page?.results || []);
  if (!allResults.length) return [];
  return normalizeMedia(allResults, 'tv');
}

export async function getMovieDetails(
  id: number
): Promise<(Movie & {media_type: 'movie'}) | null> {
  const movie = await cachedFetcher<Movie>(
    `/movie/${id}`,
    {append_to_response: 'videos,external_ids'},
    3600,
    [`movie-${id}`]
  )();
  if (!movie) return null;
  return {...movie, media_type: 'movie'};
}

export async function getSimilarMovies(id: number): Promise<Media[]> {
  const data = await cachedFetcher<{results: Movie[]}>(
    `/movie/${id}/similar`,
    {},
    3600,
    [`movie-${id}-similar`]
  )();
  if (!data?.results) return [];
  return normalizeMedia(data.results, 'movie');
}

export async function getTvShowDetails(
  id: number
): Promise<(TVShow & {media_type: 'tv'}) | null> {
  const show = await cachedFetcher<TVShow>(
    `/tv/${id}`,
    {append_to_response: 'videos,season_details,external_ids'},
    3600,
    [`tv-${id}`]
  )();
  if (!show) return null;
  return {...show, media_type: 'tv'};
}

export async function getSimilarTvShows(id: number): Promise<Media[]> {
  const data = await cachedFetcher<{results: TVShow[]}>(
    `/tv/${id}/similar`,
    {},
    3600,
    [`tv-${id}-similar`]
  )();
  if (!data?.results) return [];
  return normalizeMedia(data.results, 'tv');
}

export async function getSeasonDetails(
  tvId: number,
  seasonNumber: number
): Promise<SeasonDetails | null> {
  return cachedFetcher<SeasonDetails>(
    `/tv/${tvId}/season/${seasonNumber}`,
    {},
    3600,
    [`tv-${tvId}-season-${seasonNumber}`]
  )();
}

export async function discoverMoviesPage(
  params: Record<string, string> = {},
  page: number = 1
): Promise<Media[]> {
  const data = await cachedFetcher<{results: Movie[]}>(
    `/discover/movie`,
    {...params, page: String(page)},
    3600,
    [`discover-movies-page-${page}`, ...Object.values(params)]
  )();
  if (!data?.results) return [];
  return normalizeMedia(data.results, 'movie');
}

export async function discoverTvShowsPage(
  params: Record<string, string> = {},
  page: number = 1
): Promise<Media[]> {
    const data = await cachedFetcher<{results: TVShow[]}>(
        `/discover/tv`,
        {...params, page: String(page)},
        3600,
        [`discover-tv-page-${page}`]
    )();
    if (!data?.results) return [];
    return normalizeMedia(data.results, 'tv');
}
"""

with open("src/lib/tmdb.ts", "w", encoding="utf-8") as f:
    f.write(tmdb_content.strip())

print("Fixed src/lib/tmdb.ts successfully.")