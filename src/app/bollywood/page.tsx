import { getPopular } from '@/lib/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import type { Media } from '@/types/tmdb';

export default async function BollywoodPage() {
  const bollywoodMovies = await getPopular('movie', { with_original_language: 'hi' });

  return (
    <div className="container mx-auto px-4 py-8">
       <section className="mb-12">
        <h1 className="mb-6 font-headline text-4xl font-bold text-white md:text-5xl">
          Popular Bollywood Movies
        </h1>
      </section>

      <section>
        <MovieList initialMedia={bollywoodMovies as Media[]} />
      </section>
    </div>
  );
}
