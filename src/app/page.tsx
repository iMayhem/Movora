import { getTrending, getPopular, getNowPlayingMovies } from '@/lib/tmdb';
import { TrendingCarousel } from '@/components/movies/TrendingCarousel';
import { MovieList } from '@/components/movies/MovieList';
import type { Media } from '@/types/tmdb';
import Link from 'next/link';
import { Button } from '@/components/ui/button';

export default async function Home() {
  const [
    trendingMovies, 
    popularMovies, 
    popularTv,
    nowPlayingMovies,
    topWeeklyMovies,
    topWeeklyTv
  ] = await Promise.all([
    getTrending('movie', 'day'),
    getPopular('movie', {}, 1),
    getPopular('tv', {}, 1),
    getNowPlayingMovies(1),
    getTrending('movie', 'week', 1),
    getTrending('tv', 'week', 1),
  ]);

  const mostViewed: Media[] = [...popularMovies, ...popularTv].sort(
    (a, b) => b.popularity - a.popularity
  ).slice(0, 12);

  const topWeekly: Media[] = [...topWeeklyMovies, ...topWeeklyTv].sort(
    (a, b) => b.popularity - a.popularity
  ).slice(0, 12);

  return (
    <div className="container mx-auto px-4 py-8 space-y-12">
      <section>
        <h1 className="mb-6 font-headline text-4xl font-bold text-white md:text-5xl">
          Trending Today
        </h1>
        {trendingMovies.length > 0 ? (
          <TrendingCarousel items={trendingMovies} />
        ) : (
          <p>Could not load trending movies.</p>
        )}
      </section>

      <section>
        <div className="flex flex-col md:flex-row justify-between items-center mb-8 gap-4">
            <h2 className="font-headline text-3xl font-bold">Top Weekly</h2>
            <Link href="/discover/top-weekly">
              <Button variant="outline">More</Button>
            </Link>
        </div>
        <MovieList initialMedia={topWeekly} carousel />
      </section>
      
      <section>
        <div className="flex flex-col md:flex-row justify-between items-center mb-8 gap-4">
            <h2 className="font-headline text-3xl font-bold">Newly Released</h2>
            <Link href="/discover/newly-released">
              <Button variant="outline">More</Button>
            </Link>
        </div>
        <MovieList initialMedia={nowPlayingMovies} carousel />
      </section>

      <section>
        <div className="flex flex-col md:flex-row justify-between items-center mb-8 gap-4">
            <h2 className="font-headline text-3xl font-bold">Most Viewed</h2>
            <Link href="/discover/most-viewed">
              <Button variant="outline">More</Button>
            </Link>
        </div>
        <MovieList initialMedia={mostViewed} carousel />
      </section>
    </div>
  );
}
