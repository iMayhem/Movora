import Link from 'next/link';
import { discoverMovies } from '@/lib/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import { TrendingCarousel } from '@/components/movies/TrendingCarousel';
import { Button } from '@/components/ui/button';

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

export default async function BollywoodPage() {
  const [topBollywood, ...sectionMovies] = await Promise.all([
    discoverMovies({ ...BOLLYWOOD_PARAMS, sort_by: 'vote_average.desc', 'vote_count.gte': 200 }, 1),
    ...sections.map(section => discoverMovies(section.params, 1)),
  ]);

  return (
    <div className="container mx-auto px-4 py-8 space-y-16">
      <section>
        <h1 className="mb-6 font-headline text-4xl font-bold text-white md:text-5xl">
          Spotlight on Bollywood
        </h1>
        {topBollywood.length > 0 ? (
          <TrendingCarousel items={topBollywood} />
        ) : (
          <p>Could not load trending movies.</p>
        )}
      </section>

      {sections.map((section, index) => (
        <section key={section.slug}>
          <div className="flex justify-between items-center mb-6">
            <h2 className="font-headline text-3xl font-bold">{section.title}</h2>
            <Link href={`/discover/${section.slug}`}>
              <Button variant="outline">More</Button>
            </Link>
          </div>
          <MovieList
            initialMedia={sectionMovies[index]}
            showControls={false}
            carousel
          />
        </section>
      ))}
    </div>
  );
}
