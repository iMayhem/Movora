
import { discoverMovies } from '@/lib/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import { FeaturedMindfucks } from '@/components/movies/FeaturedMindfucks';

const MINDFUCK_PARAMS = {
  'sort_by': 'vote_average.desc',
  'vote_count.gte': '500',
  'with_genres': '53,9648,878', // Thriller, Mystery, Sci-Fi
  'without_genres': '16,10751,28', // Exclude Animation, Family, Action
  'include_adult': 'false'
};

export default async function MindfucksPage() {
  const mindfuckMovies = await discoverMovies(MINDFUCK_PARAMS, 50);

  // Sort by vote_average in descending order
  const sortedMovies = mindfuckMovies.sort((a, b) => b.vote_average - a.vote_average);

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-8 gap-4">
        <div>
          <h1 className="font-headline text-4xl font-bold text-white md:text-5xl">
            Best Mindfucks
          </h1>
          <p className="text-muted-foreground mt-2">
            A collection of films that will mess with your head.
          </p>
        </div>
      </div>

      <FeaturedMindfucks />

      <div className="mt-12">
        <MovieList initialMedia={sortedMovies} />
      </div>
    </div>
  );
}
