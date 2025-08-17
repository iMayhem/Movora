
import Link from 'next/link';
import { discoverMovies, discoverTvShows } from '@/lib/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import { Button } from '@/components/ui/button';
import { FeaturedBollywood } from '@/components/movies/FeaturedBollywood';

const BOLLYWOOD_PARAMS = {
  with_original_language: 'hi',
  region: 'IN',
  'vote_count.gte': 25,
};

const STREAMING_PARAMS = {
  ...BOLLYWOOD_PARAMS,
  watch_region: 'IN',
  with_watch_monetization_types: 'flatrate',
};

const sections = [
  {
    title: 'Latest Releases',
    slug: 'latest-bollywood',
    params: { ...BOLLYWOOD_PARAMS, sort_by: 'primary_release_date.desc' },
  },
  {
    title: 'Top-Rated Classics',
    slug: 'classics-bollywood',
    params: { ...BOLLYWOOD_PARAMS, 'primary_release_date.lte': '2000-12-31', sort_by: 'vote_average.desc', 'vote_count.gte': 50 },
  },
  {
    title: 'Netflix Bollywood',
    slug: 'netflix-bollywood',
    params: { ...STREAMING_PARAMS, with_watch_providers: '8' },
  },
  {
    title: 'Amazon Prime Bollywood',
    slug: 'prime-bollywood',
    params: { ...STREAMING_PARAMS, with_watch_providers: '119' },
  },
  {
    title: 'Action Packed',
    slug: 'action-bollywood',
    params: { ...BOLLYWOOD_PARAMS, with_genres: '28' },
  },
  {
    title: 'Romantic Flicks',
    slug: 'romance-bollywood',
    params: { ...BOLLYWOOD_PARAMS, with_genres: '10749' },
  },
  {
    title: 'Thrilling Rides',
    slug: 'thriller-bollywood',
    params: { ...BOLLYWOOD_PARAMS, with_genres: '53' },
  },
];

const tvSections = [
  {
    title: 'Popular Hindi TV Shows',
    slug: 'popular-hindi-tv',
    fetcher: () => discoverTvShows({ with_original_language: 'hi', region: 'IN', sort_by: 'popularity.desc' }, 1),
  },
  {
    title: 'Top-Rated Hindi TV Shows',
    slug: 'top-rated-hindi-tv',
    fetcher: () => discoverTvShows({ with_original_language: 'hi', region: 'IN', sort_by: 'vote_average.desc', 'vote_count.gte': 20 }, 1),
  }
];

export default async function BollywoodPage() {
  const sectionMovies = await Promise.all([
    ...sections.map(section => discoverMovies(section.params, 1)),
  ]);

  const sectionTvShows = await Promise.all(tvSections.map(section => section.fetcher()));

  return (
    <div className="container mx-auto px-4 py-6 space-y-10">
      <FeaturedBollywood showMore />

      {sections.map((section, index) => (
        <section key={section.slug}>
          <div className="flex justify-between items-center mb-4">
            <h2 className="font-headline text-2xl font-bold">{section.title}</h2>
            <Link href={`/discover/${section.slug}`}>
              <Button variant="outline">More</Button>
            </Link>
          </div>
          <MovieList
            initialMedia={sectionMovies[index]}
            
            carousel
          />
        </section>
      ))}

      {tvSections.map((section, index) => (
        <section key={section.slug}>
          <div className="flex justify-between items-center mb-4">
            <h2 className="font-headline text-2xl font-bold">{section.title}</h2>
            <Link href={`/discover/${section.slug}`}>
              <Button variant="outline">More</Button>
            </Link>
          </div>
          <MovieList
            initialMedia={sectionTvShows[index]}
            
            carousel
          />
        </section>
      ))}
    </div>
  );
}
