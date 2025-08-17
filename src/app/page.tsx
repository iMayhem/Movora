import { getPopular, getNowPlayingMovies, getTrending } from '@/lib/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import type { Media } from '@/types/tmdb';
import Link from 'next/link';
import { Button } from '@/components/ui/button';

const removeDuplicates = (media: Media[]): Media[] => {
  const seen = new Set<number>();
  return media.filter(item => {
    if (!item || typeof item.id === 'undefined') {
        return false;
    }
    const duplicate = seen.has(item.id);
    seen.add(item.id);
    return !duplicate;
  });
}

const HOLLYWOOD_PARAMS = { with_original_language: 'en', region: 'US' };

export default async function Home() {
  const [
    popularMovies, 
    popularTv,
    nowPlayingMovies,
    topWeeklyMovies,
    topWeeklyTv
  ] = await Promise.all([
    getPopular('movie', HOLLYWOOD_PARAMS, 1),
    getPopular('tv', HOLLYWOOD_PARAMS, 1),
    getNowPlayingMovies(1, HOLLYWOOD_PARAMS),
    getTrending('movie', 'week', 1), // Trending is global, no region filter needed
    getTrending('tv', 'week', 1),
  ]);

  const mostViewed: Media[] = removeDuplicates([...popularMovies, ...popularTv]).sort(
    (a, b) => b.popularity - a.popularity
  ).slice(0, 12);

  const topWeekly: Media[] = removeDuplicates([...topWeeklyMovies, ...topWeeklyTv]).sort(
    (a, b) => b.popularity - a.popularity
  ).slice(0, 12);

  return (
    <div className="container mx-auto px-4 py-8 space-y-12">
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
            <h2 className="font-headline text-3xl font-bold">Newly Released in Theaters</h2>
            <Link href="/discover/newly-released">
              <Button variant="outline">More</Button>
            </Link>
        </div>
        <MovieList initialMedia={nowPlayingMovies} carousel />
      </section>

      <section>
        <div className="flex flex-col md:flex-row justify-between items-center mb-8 gap-4">
            <h2 className="font-headline text-3xl font-bold">Most Popular</h2>
            <Link href="/discover/most-viewed">
              <Button variant="outline">More</Button>
            </Link>
        </div>
        <MovieList initialMedia={mostViewed} carousel />
      </section>
    </div>
  );
}
