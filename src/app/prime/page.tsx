
import Link from 'next/link';
import { discoverMovies, discoverTvShows } from '@/lib/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import { TrendingCarousel } from '@/components/movies/TrendingCarousel';
import { Button } from '@/components/ui/button';

const PRIME_PARAMS = {
  watch_region: 'US',
  with_watch_monetization_types: 'flatrate',
  with_watch_providers: '9', // 9 is Amazon Prime Video
};

const movieSections = [
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
  {
    title: 'Thrillers',
    slug: 'thriller-prime',
    params: { ...PRIME_PARAMS, with_genres: '53' },
  },
    {
    title: 'Sci-Fi & Fantasy',
    slug: 'scifi-prime',
    params: { ...PRIME_PARAMS, with_genres: '878,14' },
  },
  {
    title: 'Romantic Movies',
    slug: 'romance-prime',
    params: { ...PRIME_PARAMS, with_genres: '10749' },
  },
];

const tvSections = [
    {
        title: 'Popular TV Shows on Prime',
        slug: 'popular-tv-prime',
        params: { ...PRIME_PARAMS, sort_by: 'popularity.desc' },
    },
    {
        title: 'Binge-Worthy Comedies on Prime',
        slug: 'comedy-tv-prime',
        params: { ...PRIME_PARAMS, with_genres: '35' },
    },
    {
        title: 'Gripping Dramas on Prime',
        slug: 'drama-tv-prime',
        params: { ...PRIME_PARAMS, with_genres: '18' },
    }
]

export default async function PrimePage() {
  const [
    trendingPrime, 
    ...sectionMovies
  ] = await Promise.all([
    discoverMovies({ ...PRIME_PARAMS, sort_by: 'popularity.desc' }, 3),
    ...movieSections.map(section => discoverMovies(section.params, 3)),
  ]);

  const sectionTvShows = await Promise.all(tvSections.map(section => discoverTvShows(section.params, 3)))

  return (
    <div className="container mx-auto px-4 py-8 space-y-16">
      <section>
        <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-6 gap-4">
            <h1 className="font-headline text-4xl font-bold text-white md:text-5xl">
            Amazon Prime Video
            </h1>
            <Link href="https://trakt.tv/users/garycrawfordgc/lists/amazon-prime-shows?sort=rank,asc" target="_blank" rel="noopener noreferrer">
                <Button variant="outline">
                    View on Trakt.tv
                </Button>
            </Link>
        </div>
        {trendingPrime.length > 0 ? (
          <TrendingCarousel items={trendingPrime} />
        ) : (
          <p>Could not load trending Prime content.</p>
        )}
      </section>

      {movieSections.map((section, index) => (
        <section key={section.slug}>
          <div className="flex justify-between items-center mb-6">
            <h2 className="font-headline text-3xl font-bold">{section.title}</h2>
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
            <div className="flex justify-between items-center mb-6">
                <h2 className="font-headline text-3xl font-bold">{section.title}</h2>
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
