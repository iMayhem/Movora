import { discoverMovies } from '@/lib/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import { notFound } from 'next/navigation';

type DiscoverPageProps = {
  params: { slug: string };
};

const discoverCategories: Record<string, { title: string; params: Record<string, string> }> = {
  'latest-bollywood': {
    title: 'Latest Bollywood Releases',
    params: { with_original_language: 'hi', region: 'IN', sort_by: 'primary_release_date.desc', 'vote_count.gte': 25 },
  },
  'netflix-bollywood': {
    title: 'Netflix Bollywood',
    params: { with_original_language: 'hi', region: 'IN', watch_region: 'IN', with_watch_monetization_types: 'flatrate', with_watch_providers: '8', 'vote_count.gte': 25 },
  },
  'prime-bollywood': {
    title: 'Amazon Prime Bollywood',
    params: { with_original_language: 'hi', region: 'IN', watch_region: 'IN', with_watch_monetization_types: 'flatrate', with_watch_providers: '119', 'vote_count.gte': 25 },
  },
  'action-bollywood': {
    title: 'Action Packed Bollywood',
    params: { with_original_language: 'hi', region: 'IN', with_genres: '28', 'vote_count.gte': 25 },
  },
  'romance-bollywood': {
    title: 'Romantic Bollywood Flicks',
    params: { with_original_language: 'hi', region: 'IN', with_genres: '10749', 'vote_count.gte': 25 },
  },
  'thriller-bollywood': {
    title: 'Thrilling Bollywood Rides',
    params: { with_original_language: 'hi', region: 'IN', with_genres: '53', 'vote_count.gte': 25 },
  },
  'top-rated-netflix': {
    title: 'Top Rated on Netflix',
    params: { watch_region: 'US', with_watch_monetization_types: 'flatrate', with_watch_providers: '8', sort_by: 'vote_average.desc', 'vote_count.gte': 300 },
  },
  'action-netflix': {
    title: 'Action & Adventure on Netflix',
    params: { watch_region: 'US', with_watch_monetization_types: 'flatrate', with_watch_providers: '8', with_genres: '28' },
  },
  'comedy-netflix': {
    title: 'Comedies on Netflix',
    params: { watch_region: 'US', with_watch_monetization_types: 'flatrate', with_watch_providers: '8', with_genres: '35' },
  },
  'scifi-netflix': {
    title: 'Sci-Fi & Fantasy on Netflix',
    params: { watch_region: 'US', with_watch_monetization_types: 'flatrate', with_watch_providers: '8', with_genres: '878,14' },
  },
  'top-rated-prime': {
    title: 'Top Rated on Prime',
    params: { watch_region: 'US', with_watch_monetization_types: 'flatrate', with_watch_providers: '9', sort_by: 'vote_average.desc', 'vote_count.gte': 300 },
  },
  'action-prime': {
    title: 'Action & Adventure on Prime',
    params: { watch_region: 'US', with_watch_monetization_types: 'flatrate', with_watch_providers: '9', with_genres: '28' },
  },
  'comedy-prime': {
    title: 'Comedies on Prime',
    params: { watch_region: 'US', with_watch_monetization_types: 'flatrate', with_watch_providers: '9', with_genres: '35' },
  },
  'drama-prime': {
    title: 'Dramas on Prime',
    params: { watch_region: 'US', with_watch_monetization_types: 'flatrate', with_watch_providers: '9', with_genres: '18' },
  },
   'top-rated-hotstar': {
    title: 'Top Rated on Hotstar',
    params: { watch_region: 'IN', with_watch_monetization_types: 'flatrate', with_watch_providers: '122', sort_by: 'vote_average.desc', 'vote_count.gte': 100 },
  },
  'action-hotstar': {
    title: 'Action & Adventure on Hotstar',
    params: { watch_region: 'IN', with_watch_monetization_types: 'flatrate', with_watch_providers: '122', with_genres: '28' },
  },
  'comedy-hotstar': {
    title: 'Comedies on Hotstar',
    params: { watch_region: 'IN', with_watch_monetization_types: 'flatrate', with_watch_providers: '122', with_genres: '35' },
  },
  'drama-hotstar': {
    title: 'Dramas on Hotstar',
    params: { watch_region: 'IN', with_watch_monetization_types: 'flatrate', with_watch_providers: '122', with_genres: '18' },
  },
};

export default async function DiscoverPage({ params }: DiscoverPageProps) {
  const category = discoverCategories[params.slug];

  if (!category) {
    notFound();
  }

  const movies = await discoverMovies(category.params, 5); // Fetch 5 pages for "More" pages

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="mb-8 font-headline text-4xl font-bold text-white md:text-5xl">
        {category.title}
      </h1>
      <MovieList initialMedia={movies} showControls={false} />
    </div>
  );
}
