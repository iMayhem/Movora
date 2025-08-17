import { getTrending, getPopular } from '@/lib/tmdb';
import { TrendingCarousel } from '@/components/movies/TrendingCarousel';
import { MovieList } from '@/components/movies/MovieList';
import type { Media } from '@/types/tmdb';

export default async function Home() {
  const [trendingMovies, popularMovies, popularTv] = await Promise.all([
    getTrending('movie'),
    getPopular('movie'),
    getPopular('tv'),
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
        <MovieList initialMedia={initialMedia} />
      </section>
    </div>
  );
}
