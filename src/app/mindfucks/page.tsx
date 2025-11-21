import { discoverMovies } from '@/lib/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import { fetchFeaturedMindfucks } from '@/lib/featured-media';
import { Button } from '@/components/ui/button';
import Link from 'next/link';

// FIXED: Changed ',' (AND) to '|' (OR). 
// Now fetches movies that are Thriller OR Mystery OR Sci-Fi, with a high rating.
const MINDFUCK_PARAMS = { 
    'sort_by': 'vote_average.desc', 
    'vote_count.gte': '200', 
    'with_genres': '9648|53|878', // Mystery OR Thriller OR Sci-Fi
    'without_genres': '10751', // No Family movies
    'include_adult': 'false' 
};

export default async function MindfucksPage() {
  const featuredMedia = await fetchFeaturedMindfucks();
  const mindfuckMovies = await discoverMovies(MINDFUCK_PARAMS, 1);

  return (
    <div className="container mx-auto px-4 py-6 space-y-10">
      <div className="flex justify-between items-center">
        <h1 className="font-headline text-3xl font-bold text-gradient">Best Mindfucks</h1>
         <Link href={`/discover/mindfucks-movies`}><Button variant="outline">More</Button></Link>
      </div>
      
      <section>
        <h2 className="font-headline text-xl font-semibold mb-4 text-muted-foreground">Curated Classics</h2>
        <MovieList initialMedia={featuredMedia} carousel />
      </section>

      <div className="mt-12">
        <h2 className="font-headline text-2xl font-bold mb-4 text-gradient">Critically Acclaimed Thrillers</h2>
         <MovieList initialMedia={mindfuckMovies} slug="mindfucks-movies" carousel/>
      </div>
    </div>
  );
}