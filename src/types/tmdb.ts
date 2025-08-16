export interface Movie {
  id: number;
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
}

export interface TVShow {
  id: number;
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
}

export type Media = (Movie & { media_type: 'movie' }) | (TVShow & { media_type: 'tv' });

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
