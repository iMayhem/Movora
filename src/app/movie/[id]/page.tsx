import Image from 'next/image';
import { getMovieDetails, getSimilarMovies } from '@/lib/tmdb';
import { Star, Calendar, Clock } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { MovieList } from '@/components/movies/MovieList';
import { VideoPlayer } from '@/components/common/VideoPlayer';
import { Suspense } from 'react';
import { Skeleton } from '@/components/ui/skeleton';

async function SimilarMovies({ movieId }: { movieId: number }) {
  const similarMovies = await getSimilarMovies(movieId);
  if (similarMovies.length === 0) return null;
  return (
    <section className="mt-12">
      <h2 className="font-headline text-2xl font-bold mb-4 text-gradient">Similar Movies</h2>
      <MovieList initialMedia={similarMovies} carousel />
    </section>
  );
}

export default async function MoviePage({ params: { id } }: { params: { id: string } }) {
  const movieId = Number(id);
  const movie = await getMovieDetails(movieId);
  if (!movie) return <div className="container py-10 text-center">Movie not found.</div>;

  return (
    <div className="min-h-screen">
      <div className="relative h-[50vh] w-full">
        {movie.backdrop_path && (
          <Image src={`https://image.tmdb.org/t/p/original${movie.backdrop_path}`} alt={movie.title} fill className="object-cover opacity-30" priority />
        )}
        <div className="absolute inset-0 bg-gradient-to-t from-background to-transparent"></div>
      </div>

      <div className="container mx-auto px-4 relative -mt-32 z-10">
        <div className="flex flex-col md:flex-row gap-8">
          <div className="w-full md:w-1/3 lg:w-1/4 shrink-0">
            <Image src={movie.poster_path ? `https://image.tmdb.org/t/p/w500${movie.poster_path}` : "https://placehold.co/500x750.png"} alt={movie.title} width={500} height={750} className="rounded-xl shadow-2xl border border-white/10" priority />
          </div>
          <div className="w-full pt-4 md:pt-32">
            <h1 className="text-4xl md:text-6xl font-bold mb-2 text-gradient">{movie.title}</h1>
            <p className="text-lg text-muted-foreground mb-6 italic">{movie.tagline}</p>
            
            <div className="flex flex-wrap gap-4 mb-8">
              <div className="flex items-center gap-2 bg-white/5 px-3 py-1 rounded-full border border-white/10"><Star className="w-4 h-4 text-yellow-500" /> {movie.vote_average.toFixed(1)}</div>
              <div className="flex items-center gap-2 bg-white/5 px-3 py-1 rounded-full border border-white/10"><Calendar className="w-4 h-4 text-primary" /> {movie.release_date?.substring(0, 4)}</div>
              <div className="flex items-center gap-2 bg-white/5 px-3 py-1 rounded-full border border-white/10"><Clock className="w-4 h-4 text-primary" /> {movie.runtime} min</div>
            </div>
            
            <div className="flex flex-wrap gap-2 mb-8">{movie.genres.map(g => <Badge key={g.id} variant="secondary" className="bg-primary/20 hover:bg-primary/30 text-primary-foreground border-none">{g.name}</Badge>)}</div>
            <p className="text-lg leading-relaxed mb-8 text-gray-300">{movie.overview}</p>
            
            <div className="max-w-4xl">
                <VideoPlayer mediaId={movie.id} mediaType="movie" posterPath={movie.backdrop_path} />
            </div>
          </div>
        </div>
        <Suspense fallback={<Skeleton className="h-64 w-full mt-10" />}><SimilarMovies movieId={movieId} /></Suspense>
      </div>
    </div>
  );
}