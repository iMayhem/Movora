

import { discoverMovies, discoverTvShows } from '@/lib/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import { notFound } from 'next/navigation';
import { fetchFeaturedBollywood } from '@/components/movies/FeaturedBollywood';
import { fetchFeaturedAnimated } from '@/components/movies/FeaturedAnimated';

type DiscoverPageProps = {
  params: { slug: string };
};

const CURRENT_YEAR = new Date().getFullYear();

const discoverCategories: Record<string, { title: string; fetcher: () => Promise<any> }> = {
  'letterboxd-top-250': {
    title: 'Top 250',
    fetcher: () => discoverMovies({ 'sort_by': 'vote_average.desc', 'vote_count.gte': '1000', 'with_original_language': 'en', 'include_adult': 'false', 'without_genres': '99,10751' }, 13),
  },
  'mindfucks-movies': {
    title: 'Best Mindfucks',
    fetcher: () => discoverMovies({ 'sort_by': 'vote_average.desc', 'vote_count.gte': '500', 'with_genres': '53,9648,878', 'without_genres': '16,10751,28', 'include_adult': 'false' }, 10),
  },
  'featured-bollywood': {
    title: 'Featured Bollywood',
    fetcher: () => fetchFeaturedBollywood(),
  },
  'featured-animated': {
    title: 'Featured Animated',
    fetcher: () => fetchFeaturedAnimated(),
  },
  'latest-bollywood': {
    title: 'Latest Bollywood Releases',
    fetcher: () => discoverMovies({ with_original_language: 'hi', region: 'IN', sort_by: 'primary_release_date.desc', 'vote_count.gte': 25 }, 50),
  },
  'classics-bollywood': {
    title: 'Top-Rated Bollywood Classics',
    fetcher: () => discoverMovies({ with_original_language: 'hi', region: 'IN', 'primary_release_date.lte': '2000-12-31', sort_by: 'vote_average.desc', 'vote_count.gte': 50 }, 5),
  },
  'netflix-bollywood': {
    title: 'Netflix Bollywood',
    fetcher: () => discoverMovies({ with_original_language: 'hi', region: 'IN', watch_region: 'IN', with_watch_monetization_types: 'flatrate', with_watch_providers: '8', 'vote_count.gte': 25 }, 5),
  },
  'prime-bollywood': {
    title: 'Amazon Prime Bollywood',
    fetcher: () => discoverMovies({ with_original_language: 'hi', region: 'IN', watch_region: 'IN', with_watch_monetization_types: 'flatrate', with_watch_providers: '119', 'vote_count.gte': 25 }, 5),
  },
  'action-bollywood': {
    title: 'Action Packed Bollywood',
    fetcher: () => discoverMovies({ with_original_language: 'hi', region: 'IN', with_genres: '28', 'vote_count.gte': 25 }, 5),
  },
  'romance-bollywood': {
    title: 'Romantic Bollywood Flicks',
    fetcher: () => discoverMovies({ with_original_language: 'hi', region: 'IN', with_genres: '10749', 'vote_count.gte': 25 }, 5),
  },
  'thriller-bollywood': {
    title: 'Thrilling Bollywood Rides',
    fetcher: () => discoverMovies({ with_original_language: 'hi', region: 'IN', with_genres: '53', 'vote_count.gte': 25 }, 5),
  },
    'popular-hindi-tv': {
    title: 'Popular Hindi TV Shows',
    fetcher: () => discoverTvShows({ with_original_language: 'hi', region: 'IN', sort_by: 'popularity.desc' }, 5),
  },
  'top-rated-hindi-tv': {
    title: 'Top-Rated Hindi TV Shows',
    fetcher: () => discoverTvShows({ with_original_language: 'hi', region: 'IN', sort_by: 'vote_average.desc', 'vote_count.gte': 20 }, 5),
  },
  'top-rated-netflix': {
    title: 'Top Rated on Netflix',
    fetcher: () => discoverMovies({ watch_region: 'US', with_watch_monetization_types: 'flatrate', with_watch_providers: '8', sort_by: 'vote_average.desc', 'vote_count.gte': 300 }, 15),
  },
  'action-netflix': {
    title: 'Action & Adventure on Netflix',
    fetcher: () => discoverMovies({ watch_region: 'US', with_watch_monetization_types: 'flatrate', with_watch_providers: '8', with_genres: '28' }, 15),
  },
  'comedy-netflix': {
    title: 'Comedies on Netflix',
    fetcher: () => discoverMovies({ watch_region: 'US', with_watch_monetization_types: 'flatrate', with_watch_providers: '8', with_genres: '35' }, 15),
  },
  'drama-netflix': {
    title: 'Dramas on Netflix',
    fetcher: () => discoverMovies({ watch_region: 'US', with_watch_monetization_types: 'flatrate', with_watch_providers: '8', with_genres: '18' }, 15),
  },
  'thriller-netflix': {
    title: 'Thrillers on Netflix',
    fetcher: () => discoverMovies({ watch_region: 'US', with_watch_monetization_types: 'flatrate', with_watch_providers: '8', with_genres: '53' }, 15),
  },
  'horror-netflix': {
    title: 'Horror on Netflix',
    fetcher: () => discoverMovies({ watch_region: 'US', with_watch_monetization_types: 'flatrate', with_watch_providers: '8', with_genres: '27' }, 15),
  },
  'scifi-netflix': {
    title: 'Sci-Fi & Fantasy on Netflix',
    fetcher: () => discoverMovies({ watch_region: 'US', with_watch_monetization_types: 'flatrate', with_watch_providers: '8', with_genres: '878,14' }, 15),
  },
  'top-rated-prime': {
    title: 'Top Rated on Prime',
    fetcher: () => discoverMovies({ watch_region: 'US', with_watch_monetization_types: 'flatrate', with_watch_providers: '9', sort_by: 'vote_average.desc', 'vote_count.gte': 300 }, 15),
  },
  'action-prime': {
    title: 'Action & Adventure on Prime',
    fetcher: () => discoverMovies({ watch_region: 'US', with_watch_monetization_types: 'flatrate', with_watch_providers: '9', with_genres: '28' }, 15),
  },
  'comedy-prime': {
    title: 'Comedies on Prime',
    fetcher: () => discoverMovies({ watch_region: 'US', with_watch_monetization_types: 'flatrate', with_watch_providers: '9', with_genres: '35' }, 15),
  },
  'drama-prime': {
    title: 'Dramas on Prime',
    fetcher: () => discoverMovies({ watch_region: 'US', with_watch_monetization_types: 'flatrate', with_watch_providers: '9', with_genres: '18' }, 15),
  },
  'thriller-prime': {
    title: 'Thrillers on Prime',
    fetcher: () => discoverMovies({ watch_region: 'US', with_watch_monetization_types: 'flatrate', with_watch_providers: '9', with_genres: '53' }, 15),
  },
  'scifi-prime': {
    title: 'Sci-Fi & Fantasy on Prime',
    fetcher: () => discoverMovies({ watch_region: 'US', with_watch_monetization_types: 'flatrate', with_watch_providers: '9', with_genres: '878,14' }, 15),
  },
  'romance-prime': {
    title: 'Romantic Movies on Prime',
    fetcher: () => discoverMovies({ watch_region: 'US', with_watch_monetization_types: 'flatrate', with_watch_providers: '9', with_genres: '10749' }, 15),
  },
    'popular-tv-prime': {
    title: 'Popular TV Shows on Prime',
    fetcher: () => discoverTvShows({ watch_region: 'US', with_watch_monetization_types: 'flatrate', with_watch_providers: '9', sort_by: 'popularity.desc' }, 15),
  },
  'comedy-tv-prime': {
    title: 'Binge-Worthy Comedies on Prime',
    fetcher: () => discoverTvShows({ watch_region: 'US', with_watch_monetization_types: 'flatrate', with_watch_providers: '9', with_genres: '35' }, 15),
  },
  'drama-tv-prime': {
    title: 'Gripping Dramas on Prime',
    fetcher: () => discoverTvShows({ watch_region: 'US', with_watch_monetization_types: 'flatrate', with_watch_providers: '9', with_genres: '18' }, 15),
  },
  'top-rated-animated': {
    title: 'Top Rated Animated Movies',
    fetcher: () => discoverMovies({ with_genres: '16', sort_by: 'vote_average.desc', 'vote_count.gte': '250' }, 5),
  },
  'pixar-animated': {
    title: 'Pixar Animation Studios',
    fetcher: () => discoverMovies({ with_genres: '16', with_companies: '3' }, 5),
  },
  'ghibli-animated': {
    title: 'Studio Ghibli',
    fetcher: () => discoverMovies({ with_genres: '16', with_companies: '10342' }, 5),
  },
  'popular-animated-tv': {
    title: 'Popular Animated TV Shows',
    fetcher: () => discoverTvShows({ with_genres: '16', sort_by: 'popularity.desc' }, 5),
  },
  'recent-upcoming-animated': {
    title: 'Recent & Upcoming Animated Movies',
    fetcher: () => discoverMovies({
      with_genres: '16',
      'primary_release_date.gte': '2020-01-01',
      'primary_release_date.lte': '2025-12-31',
      sort_by: 'popularity.desc'
    }, 5),
  },
  'latest-korean-movies': {
    title: 'Latest Korean Releases',
    fetcher: () => discoverMovies({ with_original_language: 'ko', region: 'KR', sort_by: 'primary_release_date.desc', 'vote_count.gte': 10 }, 15),
  },
  'top-rated-korean-movies': {
    title: 'Top-Rated Korean Movies',
    fetcher: () => discoverMovies({ with_original_language: 'ko', region: 'KR', sort_by: 'vote_average.desc', 'vote_count.gte': 50 }, 15),
  },
  'action-korean-movies': {
    title: 'Korean Action Movies',
    fetcher: () => discoverMovies({ with_original_language: 'ko', region: 'KR', with_genres: '28' }, 15),
  },
  'thriller-korean-movies': {
    title: 'Korean Thrillers',
    fetcher: () => discoverMovies({ with_original_language: 'ko', region: 'KR', with_genres: '53' }, 15),
  },
  'romance-korean-movies': {
    title: 'Korean Romance',
    fetcher: () => discoverMovies({ with_original_language: 'ko', region: 'KR', with_genres: '10749' }, 15),
  },
  'popular-korean-tv': {
    title: 'Popular Korean TV Shows',
    fetcher: () => discoverTvShows({ with_original_language: 'ko', region: 'KR', sort_by: 'popularity.desc' }, 15),
  },
  'top-rated-korean-tv': {
    title: 'Top-Rated Korean TV Shows',
    fetcher: () => discoverTvShows({ with_original_language: 'ko', region: 'KR', sort_by: 'vote_average.desc', 'vote_count.gte': 20 }, 15),
  },
};

export default async function DiscoverPage({ params }: DiscoverPageProps) {
  const category = discoverCategories[params.slug];

  if (!category) {
    notFound();
  }

  const movies = await category.fetcher();

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="mb-8 font-headline text-4xl font-bold text-white md:text-5xl">
        {category.title}
      </h1>
      <MovieList initialMedia={movies} showControls={false} />
    </div>
  );
}
