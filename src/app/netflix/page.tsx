import Link from 'next/link';
import { discoverMovies } from '@/lib/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import { TrendingCarousel } from '@/components/movies/TrendingCarousel';
import { Button } from '@/components/ui/button';

const NETFLIX_PARAMS = {
  watch_region: 'US',
  with_watch_monetization_types: 'flatrate',
  with_watch_providers: '8', // 8 is Netflix
};

const sections = [
  {
    title: 'Top Rated on Netflix',
    slug: 'top-rated-netflix',
    params: { ...NETFLIX_PARAMS, sort_by: 'vote_average.desc', 'vote_count.gte': 300 },
  },
  {
    title: 'Action & Adventure',
    slug: 'action-netflix',
    params: { ...NETFLIX_PARAMS, with_genres: '28' },
  },
  {
    title: 'Comedy',
    slug: 'comedy-netflix',
    params: { ...NETFLIX_PARAMS, with_genres: '35' },
  },
  {
    title: 'Dramas',
    slug: 'drama-netflix',
    params: { ...NETFLIX_PARAMS, with_genres: '18' },
  },
  {
    title: 'Thrillers',
    slug: 'thriller-netflix',
    params: { ...NETFLIX_PARAMS, with_genres: '53' },
  },
  {
    title: 'Horror',
    slug: 'horror-netflix',
    params: { ...NETFLIX_PARAMS, with_genres: '27' },
  },
  {
    title: 'Sci-Fi & Fantasy',
    slug: 'scifi-netflix',
    params: { ...NETFLIX_PARAMS, with_genres: '878,14' },
  },
];

export default async function NetflixPage() {
  const [trendingNetflix, ...sectionMovies] = await Promise.all([
    discoverMovies({ ...NETFLIX_PARAMS, sort_by: 'popularity.desc' }, 3),
    ...sections.map(section => discoverMovies(section.params, 3)),
  ]);

  return (
    <div className="container mx-auto px-4 py-8 space-y-16">
      <section>
        <h1 className="mb-6 font-headline text-4xl font-bold text-white md:text-5xl">
          All Things Netflix
        </h1>
        {trendingNetflix.length > 0 ? (
          <TrendingCarousel items={trendingNetflix} />
        ) : (
          <p>Could not load trending Netflix content.</p>
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
