import { getTrending, getPopular } from '@/lib/tmdb';
import { TrendingCarousel } from '@/components/movies/TrendingCarousel';
import { MovieList } from '@/components/movies/MovieList';
import type { Media } from '@/types/tmdb';
import Link from 'next/link';
import { Button } from '@/components/ui/button';

export default async function Home() {
  const [trendingMovies, popularMovies, popularTv] = await Promise.all([
    getTrending('movie'),
    getPopular('movie', {}, 2), // fetch 2 pages
    getPopular('tv', {}, 2), // fetch 2 pages
  ]);

  const initialMedia: Media[] = [...popularMovies, ...popularTv].sort(
    (a, b) => b.popularity - a.popularity
  );

  return (
    <div className="container mx-auto px-4 py-8">
      <section className="mb-12">
        <h1 className="mb-6 font-headline text-4xl font-bold text-white md:text-5xl">
          Trending Movies
        </h1>
        {trendingMovies.length > 0 ? (
          <TrendingCarousel items={trendingMovies} />
        ) : (
          <p>Could not load trending movies.</p>
        )}
      </section>

      <section>
        <div className="flex flex-col md:flex-row justify-between items-center mb-8 gap-4">
            <h2 className="font-headline text-3xl font-bold">Discover</h2>
            <Link href="/discover/discover">
              <Button variant="outline">More</Button>
            </Link>
        </div>
        <MovieList initialMedia={initialMedia} showControls={false} />
      </section>
    </div>
  );
}
