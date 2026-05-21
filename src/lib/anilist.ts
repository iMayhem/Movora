import type { Media } from '@/types/tmdb';

const ANILIST_API_URL = 'https://graphql.anilist.co';

// Helper to strip HTML tags from AniList descriptions
function stripHtml(html: string): string {
  if (!html) return '';
  return html.replace(/<[^>]*>/g, '');
}

// Normalized Anime structure matching Media/TVShow types
export interface AnimeMedia {
  id: number;
  title: string;
  name: string; // Map name for component compatibility
  overview: string;
  poster_path: string | null;
  backdrop_path: string | null;
  release_date: string;
  vote_average: number;
  episodes: number | null;
  genres: { id: number; name: string }[];
  popularity: number;
  media_type: 'anime';
}

async function fetchAniList<T>(query: string, variables: Record<string, any> = {}): Promise<T | null> {
  try {
    const response = await fetch(ANILIST_API_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: JSON.stringify({
        query,
        variables,
      }),
    });

    if (!response.ok) {
      console.error(`AniList API failed: ${response.status} ${response.statusText}`);
      return null;
    }

    const json = await response.json();
    return json.data as T;
  } catch (error) {
    console.error('Error fetching from AniList:', error);
    return null;
  }
}

// Convert AniList media object into normalized Movora Media format
function normalizeAnime(anime: any): Media {
  const title = anime.title.english || anime.title.romaji || anime.title.native || 'Unknown Anime';
  const genres = (anime.genres || []).map((genreName: string, index: number) => ({
    id: index + 1000,
    name: genreName,
  }));

  return {
    id: anime.id,
    title: title,
    name: title, // mapped for TV selectors
    overview: stripHtml(anime.description || 'No description available.'),
    poster_path: anime.coverImage?.extraLarge || anime.coverImage?.large || null,
    backdrop_path: anime.bannerImage || anime.coverImage?.extraLarge || null,
    release_date: anime.seasonYear ? String(anime.seasonYear) : (anime.startDate?.year ? String(anime.startDate.year) : 'Unknown'),
    vote_average: anime.averageScore ? anime.averageScore / 10 : 0.0,
    popularity: anime.popularity || 0,
    genres: genres,
    media_type: 'anime' as any, // Cast as any for compatibility with existing types
  } as any;
}

export async function getTrendingAnime(page: number = 1, perPage: number = 20): Promise<Media[]> {
  const query = `
    query ($page: Int, $perPage: Int) {
      Page (page: $page, perPage: $perPage) {
        media (type: ANIME, sort: TRENDING_DESC) {
          id
          title {
            romaji
            english
            native
          }
          coverImage {
            extraLarge
            large
          }
          bannerImage
          description
          seasonYear
          startDate {
            year
          }
          averageScore
          popularity
          genres
        }
      }
    }
  `;

  const data = await fetchAniList<{ Page: { media: any[] } }>(query, { page, perPage });
  if (!data?.Page?.media) return [];
  return data.Page.media.map(normalizeAnime);
}

export async function getPopularAnime(page: number = 1, perPage: number = 20): Promise<Media[]> {
  const query = `
    query ($page: Int, $perPage: Int) {
      Page (page: $page, perPage: $perPage) {
        media (type: ANIME, sort: POPULARITY_DESC) {
          id
          title {
            romaji
            english
            native
          }
          coverImage {
            extraLarge
            large
          }
          bannerImage
          description
          seasonYear
          startDate {
            year
          }
          averageScore
          popularity
          genres
        }
      }
    }
  `;

  const data = await fetchAniList<{ Page: { media: any[] } }>(query, { page, perPage });
  if (!data?.Page?.media) return [];
  return data.Page.media.map(normalizeAnime);
}

export async function searchAnime(search: string, page: number = 1, perPage: number = 20): Promise<Media[]> {
  const query = `
    query ($page: Int, $perPage: Int, $search: String) {
      Page (page: $page, perPage: $perPage) {
        media (type: ANIME, search: $search) {
          id
          title {
            romaji
            english
            native
          }
          coverImage {
            extraLarge
            large
          }
          bannerImage
          description
          seasonYear
          startDate {
            year
          }
          averageScore
          popularity
          genres
        }
      }
    }
  `;

  const data = await fetchAniList<{ Page: { media: any[] } }>(query, { page, perPage, search });
  if (!data?.Page?.media) return [];
  return data.Page.media.map(normalizeAnime);
}

export async function getAnimeDetails(id: number): Promise<any | null> {
  const query = `
    query ($id: Int) {
      Media (id: $id, type: ANIME) {
        id
        title {
          romaji
          english
          native
        }
        coverImage {
          extraLarge
          large
        }
        bannerImage
        description
        seasonYear
        startDate {
          year
          month
          day
        }
        endDate {
          year
          month
          day
        }
        averageScore
        popularity
        episodes
        status
        genres
        studios(isMain: true) {
          nodes {
            name
          }
        }
      }
    }
  `;

  const data = await fetchAniList<{ Media: any }>(query, { id });
  if (!data?.Media) return null;
  
  const anime = data.Media;
  const title = anime.title.english || anime.title.romaji || anime.title.native || 'Unknown Anime';
  const genres = (anime.genres || []).map((genreName: string, index: number) => ({
    id: index + 1000,
    name: genreName,
  }));

  return {
    id: anime.id,
    title: title,
    name: title,
    overview: stripHtml(anime.description || 'No description available.'),
    poster_path: anime.coverImage?.extraLarge || anime.coverImage?.large || null,
    backdrop_path: anime.bannerImage || anime.coverImage?.extraLarge || null,
    release_date: anime.seasonYear ? String(anime.seasonYear) : (anime.startDate?.year ? String(anime.startDate.year) : 'Unknown'),
    vote_average: anime.averageScore ? anime.averageScore / 10 : 0.0,
    popularity: anime.popularity || 0,
    genres: genres,
    episodes: anime.episodes || null,
    status: anime.status || 'FINISHED',
    studio: anime.studios?.nodes?.[0]?.name || 'Unknown Studio',
    media_type: 'anime',
  };
}
