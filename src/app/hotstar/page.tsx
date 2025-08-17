import Link from 'next/link';
import { discoverMovies } from '@/lib/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import { TrendingCarousel } from '@/components/movies/TrendingCarousel';
import { Button } from '@/components/ui/button';

const HOTSTAR_PARAMS = {
  watch_region: 'IN',
  with_watch_monetization_types: 'flatrate',
  with_watch_providers: '122', // 122 is Disney+ Hotstar
};

const sections = [
  {
    title: 'Top Rated on Hotstar',
    slug: 'top-rated-hotstar',
    params: { ...HOTSTAR_PARAMS, sort_by: 'vote_average.desc', 'vote_count.gte': 100 },
  },
  {
    title: 'Action & Adventure',
    slug: 'action-hotstar',
    params: { ...HOTSTAR_PARAMS, with_genres: '28' },
  },
  {
    title: 'Comedy',
    slug: 'comedy-hotstar',
    params: { ...HOTSTAR_PARAMS, with_genres: '35' },
  },
  {
    title: 'Drama',
    slug: 'drama-hotstar',
    params: { ...HOTSTAR_PARAMS, with_genres: '18' },
  },
];

export default async function HotstarPage() {
  const [trendingHotstar, ...sectionMovies] = await Promise.all([
    discoverMovies({ ...HOTSTAR_PARAMS, sort_by: 'popularity.desc' }, 1),
    ...sections.map(section => discoverMovies(section.params, 1)),
  ]);

  return (
    <div className="container mx-auto px-4 py-8 space-y-16">
      <section>
        <h1 className="mb-6 font-headline text-4xl font-bold text-white md:text-5xl">
          Disney+ Hotstar
        </h1>
        {trendingHotstar.length > 0 ? (
          <TrendingCarousel items={trendingHotstar} />
        ) : (
          <p>Could not load trending Hotstar content.</p>
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
