
import Link from 'next/link';
import { discoverMovies } from '@/lib/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import { Button } from '@/components/ui/button';

const LETTERBOXD_PARAMS = {
  'sort_by': 'vote_average.desc',
  'vote_count.gte': '1000',
  'with_original_language': 'en',
  'include_adult': 'false',
  'without_genres': '99,10751'
};

export default async function LetterboxdPage() {
  const topMovies = await discoverMovies({ ...LETTERBOXD_PARAMS }, 10); // Fetch 10 pages for ~200 movies

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-8 gap-4">
        <div>
          <h1 className="font-headline text-4xl font-bold text-white md:text-5xl">
            Letterboxd Top 250
          </h1>
          <p className="text-muted-foreground mt-2">
            Based on TMDB ratings, inspired by the official Letterboxd list.
          </p>
        </div>
        <Link href="https://letterboxd.com/dave/list/official-top-250-narrative-feature-films/" target="_blank" rel="noopener noreferrer">
          <Button variant="outline">
            View on Letterboxd
          </Button>
        </Link>
      </div>
      <MovieList initialMedia={topMovies.slice(0, 250)} showControls={false} />
    </div>
  );
}
