export interface Movie {
  id: number;
  imdb_id?: string;
  title: string;
  overview: string;
  poster_path: string | null;
  backdrop_path: string | null;
  release_date: string;
  vote_average: number;
  genres: { id: number; name: string }[];
  runtime: number | null;
  tagline: string;
  popularity: number;
  videos?: { results: Video[] };
  media_type: 'movie';
}

export interface Season {
  air_date: string;
  episode_count: number;
  id: number;
  name: string;
  overview: string;
  poster_path: string | null;
  season_number: number;
}

export interface Episode {
    id: number;
    name: string;
    overview: string;
    vote_average: number;
    vote_count: number;
    air_date: string;
    episode_number: number;
    episode_type: string;
    production_code: string;
    runtime: number | null;
    season_number: number;
    show_id: number;
    still_path: string | null;
}

export interface SeasonDetails extends Season {
    episodes: Episode[];
}

export interface TVShow {
  id: number;
  imdb_id?: string;
  name: string;
  overview: string;
  poster_path: string | null;
  backdrop_path: string | null;
  first_air_date: string;
  vote_average: number;
  genres: { id: number; name: string }[];
  number_of_seasons: number;
  tagline: string;
  popularity: number;
  videos?: { results: Video[] };
  seasons?: Season[];
  media_type: 'tv';
}

export type Media = (Movie | TVShow) & { media_type: 'movie' | 'tv' | 'person' };

export interface CastMember {
  id: number;
  name: string;
  character: string;
  profile_path: string | null;
  cast_id: number;
}

export interface Credits {
  cast: CastMember[];
}

export interface Video {
  iso_639_1: string;
  iso_3166_1: string;
  name: string;
  key: string;
  site: string;
  size: number;
  type: string;
  official: boolean;
  published_at: string;
  id: string;
}