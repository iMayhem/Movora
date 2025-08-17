
import { getPopular, getNowPlayingMovies, getTrending, discoverMovies, discoverTvShows } from '@/lib/tmdb';
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
const HOLLYWOOD_VOTE_COUNT = { 'vote_count.gte': '300' };
const HOLLYWOOD_TV_VOTE_COUNT = { 'vote_count.gte': '200' };

export default async function Home() {
  const [
    popularMovies, 
    popularTv,
    nowPlayingMovies,
    topWeeklyMovies,
    topWeeklyTv,
    topRatedMovies,
    topRatedTv,
    actionMovies,
    comedyMovies,
    scifiMovies,
  ] = await Promise.all([
    getPopular('movie', HOLLYWOOD_PARAMS, 1),
    getPopular('tv', HOLLYWOOD_PARAMS, 1),
    getNowPlayingMovies(1, HOLLYWOOD_PARAMS),
    getTrending('movie', 'week', 1), // Trending is global, no region filter needed
    getTrending('tv', 'week', 1),
    discoverMovies({ ...HOLLYWOOD_PARAMS, ...HOLLYWOOD_VOTE_COUNT, sort_by: 'vote_average.desc' }, 1),
    discoverTvShows({ ...HOLLYWOOD_PARAMS, ...HOLLYWOOD_TV_VOTE_COUNT, sort_by: 'vote_average.desc' }, 1),
    discoverMovies({ ...HOLLYWOOD_PARAMS, with_genres: '28,12' }, 1),
    discoverMovies({ ...HOLLYWOOD_PARAMS, with_genres: '35' }, 1),
    discoverMovies({ ...HOLLYWOOD_PARAMS, with_genres: '878,14' }, 1),
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
            <h2 className="font-headline text-3xl font-bold">Trending Now</h2>
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

      <section>
        <div className="flex flex-col md:flex-row justify-between items-center mb-8 gap-4">
            <h2 className="font-headline text-3xl font-bold">Top Rated Movies</h2>
            <Link href="/discover/top-rated-hollywood-movies">
              <Button variant="outline">More</Button>
            </Link>
        </div>
        <MovieList initialMedia={topRatedMovies} carousel />
      </section>

      <section>
        <div className="flex flex-col md:flex-row justify-between items-center mb-8 gap-4">
            <h2 className="font-headline text-3xl font-bold">Top Rated TV Shows</h2>
            <Link href="/discover/top-rated-hollywood-tv">
              <Button variant="outline">More</Button>
            </Link>
        </div>
        <MovieList initialMedia={topRatedTv} carousel />
      </section>
      
      <section>
        <div className="flex flex-col md:flex-row justify-between items-center mb-8 gap-4">
            <h2 className="font-headline text-3xl font-bold">Action & Adventure</h2>
            <Link href="/discover/action-adventure-hollywood">
              <Button variant="outline">More</Button>
            </Link>
        </div>
        <MovieList initialMedia={actionMovies} carousel />
      </section>
      
      <section>
        <div className="flex flex-col md:flex-row justify-between items-center mb-8 gap-4">
            <h2 className="font-headline text-3xl font-bold">Comedy</h2>
            <Link href="/discover/comedy-hollywood">
              <Button variant="outline">More</Button>
            </Link>
        </div>
        <MovieList initialMedia={comedyMovies} carousel />
      </section>

      <section>
        <div className="flex flex-col md:flex-row justify-between items-center mb-8 gap-4">
            <h2 className="font-headline text-3xl font-bold">Sci-Fi & Fantasy</h2>
            <Link href="/discover/scifi-fantasy-hollywood">
              <Button variant="outline">More</Button>
            </Link>
        </div>
        <MovieList initialMedia={scifiMovies} carousel />
      </section>
    </div>
  );
}
