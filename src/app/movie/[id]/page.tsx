import Image from 'next/image';
import { getMovieDetails, getSimilarMovies } from '@/lib/tmdb';
import { Star, Calendar, Clock, PlayCircle } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { MovieList } from '@/components/movies/MovieList';
import { VideoPlayer } from '@/components/common/VideoPlayer';
import { Suspense } from 'react';
import { Skeleton } from '@/components/ui/skeleton';

async function SimilarMovies({ movieId }: { movieId: number }) {
  const similarMovies = await getSimilarMovies(movieId);
  if (similarMovies.length === 0) return null;
  return (
    <section className="mt-12 mb-8">
      <h2 className="font-bold text-xl mb-4 text-white/90 px-1">You might also like</h2>
      <MovieList initialMedia={similarMovies} carousel />
    </section>
  );
}

export default async function MoviePage({ params: { id } }: { params: { id: string } }) {
  const movieId = Number(id);
  const movie = await getMovieDetails(movieId);
  if (!movie) return <div className="container py-20 text-center text-muted-foreground">Movie not found.</div>;

  return (
    <div className="min-h-screen bg-background pb-10">
      {/* Hero Section with Backdrop */}
      <div className="relative w-full h-[45vh] md:h-[60vh]">
        {movie.backdrop_path ? (
          <Image 
            src={`https://image.tmdb.org/t/p/original${movie.backdrop_path}`} 
            alt={movie.title} 
            fill 
            className="object-cover" 
            priority 
          />
        ) : (
           <div className="w-full h-full bg-zinc-900" />
        )}
        {/* Gradient Overlay for readability */}
        <div className="absolute inset-0 bg-gradient-to-t from-background via-background/60 to-transparent" />
      </div>

      <div className="container mx-auto px-4 -mt-32 relative z-10">
        <div className="flex flex-col md:flex-row gap-6 md:gap-10">
          
          {/* Poster Card - Floating */}
          <div className="shrink-0 mx-auto md:mx-0 w-40 md:w-72 lg:w-80 relative group">
            <div className="aspect-[2/3] relative rounded-xl overflow-hidden shadow-2xl ring-1 ring-white/10 bg-zinc-800">
                <Image 
                    src={movie.poster_path ? `https://image.tmdb.org/t/p/w500${movie.poster_path}` : "https://placehold.co/500x750.png"} 
                    alt={movie.title} 
                    fill 
                    className="object-cover" 
                    priority 
                />
            </div>
          </div>

          {/* Info Content */}
          <div className="flex-1 pt-2 md:pt-32 text-center md:text-left">
            <h1 className="text-3xl md:text-5xl font-extrabold tracking-tight text-white mb-2 leading-tight">
                {movie.title}
            </h1>
            
            {movie.tagline && (
                <p className="text-base md:text-lg text-primary/90 font-medium italic mb-4">
                    "{movie.tagline}"
                </p>
            )}

            {/* Metadata Pills */}
            <div className="flex flex-wrap justify-center md:justify-start gap-3 mb-6">
              <div className="flex items-center gap-1.5 bg-white/10 backdrop-blur-md px-3 py-1 rounded-full text-xs md:text-sm font-medium text-white border border-white/5">
                <Star className="w-3.5 h-3.5 text-yellow-400 fill-yellow-400" /> 
                {movie.vote_average.toFixed(1)}
              </div>
              <div className="flex items-center gap-1.5 bg-white/10 backdrop-blur-md px-3 py-1 rounded-full text-xs md:text-sm font-medium text-white border border-white/5">
                <Calendar className="w-3.5 h-3.5 text-gray-300" /> 
                {movie.release_date?.substring(0, 4)}
              </div>
              <div className="flex items-center gap-1.5 bg-white/10 backdrop-blur-md px-3 py-1 rounded-full text-xs md:text-sm font-medium text-white border border-white/5">
                <Clock className="w-3.5 h-3.5 text-gray-300" /> 
                {movie.runtime} min
              </div>
            </div>

            {/* Genres */}
            <div className="flex flex-wrap justify-center md:justify-start gap-2 mb-8">
                {movie.genres.map(g => (
                    <Badge key={g.id} variant="secondary" className="bg-zinc-800 hover:bg-zinc-700 text-zinc-300 border border-white/5 px-3 py-1">
                        {g.name}
                    </Badge>
                ))}
            </div>

            {/* Plot */}
            <div className="mb-8 max-w-3xl mx-auto md:mx-0">
                <h3 className="text-sm font-bold text-muted-foreground uppercase tracking-wider mb-2">Synopsis</h3>
                <p className="text-sm md:text-base leading-relaxed text-gray-300 text-justify md:text-left">
                    {movie.overview}
                </p>
            </div>

            {/* Action Area */}
            <div className="max-w-3xl mx-auto md:mx-0 mb-10">
                <h3 className="text-sm font-bold text-muted-foreground uppercase tracking-wider mb-3">Watch Now</h3>
                <VideoPlayer mediaId={movie.id} mediaType="movie" posterPath={movie.backdrop_path} />
            </div>
          </div>
        </div>

        <Suspense fallback={<Skeleton className="h-48 w-full mt-10 rounded-xl bg-white/5" />}>
            <SimilarMovies movieId={movieId} />
        </Suspense>
      </div>
    </div>
  );
}