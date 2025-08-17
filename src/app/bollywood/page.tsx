import { discoverMovies } from '@/lib/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import { TrendingCarousel } from '@/components/movies/TrendingCarousel';

const BOLLYWOOD_PARAMS = {
  with_original_language: 'hi',
  region: 'IN',
};

const STREAMING_PARAMS = {
  ...BOLLYWOOD_PARAMS,
  watch_region: 'IN',
  with_watch_monetization_types: 'flatrate',
};

export default async function BollywoodPage() {
  const [
    topBollywood,
    latestBollywood,
    actionMovies,
    romanceMovies,
    thrillerMovies,
    netflixMovies,
    primeMovies,
  ] = await Promise.all([
    discoverMovies({ ...BOLLYWOOD_PARAMS, sort_by: 'vote_average.desc', 'vote_count.gte': 200 }),
    discoverMovies({ ...BOLLYWOOD_PARAMS, sort_by: 'primary_release_date.desc' }),
    discoverMovies({ ...BOLLYWOOD_PARAMS, with_genres: '28' }), // Action
    discoverMovies({ ...BOLLYWOOD_PARAMS, with_genres: '10749' }), // Romance
    discoverMovies({ ...BOLLYWOOD_PARAMS, with_genres: '53' }), // Thriller
    discoverMovies({ ...STREAMING_PARAMS, with_watch_providers: '8' }), // Netflix
    discoverMovies({ ...STREAMING_PARAMS, with_watch_providers: '119' }), // Amazon Prime
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
      
      <section>
        <h2 className="mb-6 font-headline text-3xl font-bold">Latest Releases</h2>
        <MovieList initialMedia={latestBollywood} showControls={false} />
      </section>

      <section>
        <h2 className="mb-6 font-headline text-3xl font-bold">Netflix Bollywood</h2>
        <MovieList initialMedia={netflixMovies} showControls={false} />
      </section>
      
      <section>
        <h2 className="mb-6 font-headline text-3xl font-bold">Amazon Prime Bollywood</h2>
        <MovieList initialMedia={primeMovies} showControls={false} />
      </section>

      <section>
        <h2 className="mb-6 font-headline text-3xl font-bold">Action Packed</h2>
        <MovieList initialMedia={actionMovies} showControls={false} />
      </section>

      <section>
        <h2 className="mb-6 font-headline text-3xl font-bold">Romantic Flicks</h2>
        <MovieList initialMedia={romanceMovies} showControls={false} />
      </section>

      <section>
        <h2 className="mb-6 font-headline text-3xl font-bold">Thrilling Rides</h2>
        <MovieList initialMedia={thrillerMovies} showControls={false} />
      </section>
    </div>
  );
}
