import Link from 'next/link';
import { discoverMovies } from '@/lib/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import { TrendingCarousel } from '@/components/movies/TrendingCarousel';
import { Button } from '@/components/ui/button';

const PRIME_PARAMS = {
  watch_region: 'US',
  with_watch_monetization_types: 'flatrate',
  with_watch_providers: '9', // 9 is Amazon Prime Video
};

const sections = [
  {
    title: 'Top Rated on Prime',
    slug: 'top-rated-prime',
    params: { ...PRIME_PARAMS, sort_by: 'vote_average.desc', 'vote_count.gte': 300 },
  },
  {
    title: 'Action & Adventure',
    slug: 'action-prime',
    params: { ...PRIME_PARAMS, with_genres: '28' },
  },
  {
    title: 'Comedy',
    slug: 'comedy-prime',
    params: { ...PRIME_PARAMS, with_genres: '35' },
  },
  {
    title: 'Drama',
    slug: 'drama-prime',
    params: { ...PRIME_PARAMS, with_genres: '18' },
  },
];

export default async function PrimePage() {
  const [trendingPrime, ...sectionMovies] = await Promise.all([
    discoverMovies({ ...PRIME_PARAMS, sort_by: 'popularity.desc' }, 1),
    ...sections.map(section => discoverMovies(section.params, 1)),
  ]);

  return (
    <div className="container mx-auto px-4 py-8 space-y-16">
      <section>
        <h1 className="mb-6 font-headline text-4xl font-bold text-white md:text-5xl">
          Amazon Prime Video
        </h1>
        {trendingPrime.length > 0 ? (
          <TrendingCarousel items={trendingPrime} />
        ) : (
          <p>Could not load trending Prime content.</p>
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
