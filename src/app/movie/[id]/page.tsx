
import Image from 'next/image';
import { getMovieDetails, getSimilarMovies } from '@/lib/tmdb';
import { Star, Calendar, Clock } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { MovieList } from '@/components/movies/MovieList';
import { VideoPlayerDialog } from '@/components/common/VideoPlayerDialog';
import { PlayerDialogButton } from '@/components/common/PlayerDialogButton';
import type { Media } from '@/types/tmdb';

type MoviePageProps = {
  params: { id: string };
};

export default async function MoviePage({ params: { id } }: MoviePageProps) {
  const movieId = Number(id);
  const movie = await getMovieDetails(movieId);
  
  if (!movie) {
    return <div>Movie not found.</div>;
  }
  
  const similarMovies = await getSimilarMovies(movieId);

  return (
    <VideoPlayerDialog
      mediaId={movie.id}
      mediaType={movie.media_type}
    >
      <div className="container mx-auto px-4 py-6 text-white">
        <div className="relative h-[30vh] md:h-[50vh] w-full">
          {movie.backdrop_path && (
            <Image
              src={`https://image.tmdb.org/t/p/w1280${movie.backdrop_path}`}
              alt={`${movie.title} backdrop`}
              fill
              style={{ objectFit: 'cover' }}
              className="rounded-lg opacity-30"
              data-ai-hint="movie backdrop"
              priority
            />
          )}
          <div className="absolute inset-0 bg-gradient-to-t from-background to-transparent"></div>
        </div>

        <div className="relative -mt-24 md:-mt-48 px-4 md:px-8 pb-12">
          <div className="flex flex-col md:flex-row gap-8">
            <div className="w-full md:w-1/3 lg:w-1/4">
              <Image
                src={movie.poster_path ? `https://image.tmdb.org/t/p/w342${movie.poster_path}` : "https://placehold.co/500x750.png"}
                alt={`${movie.title} poster`}
                width={500}
                height={750}
                className="rounded-lg shadow-2xl"
                data-ai-hint="movie poster"
              />
            </div>
            <div className="w-full md:w-2/3 lg:w-3/4 pt-0 md:pt-24">
              <h1 className="font-headline text-3xl md:text-5xl font-bold mb-2">{movie.title}</h1>
              <p className="text-lg text-muted-foreground mb-4">{movie.tagline}</p>
              <div className="flex flex-wrap items-center gap-4 mb-6">
                <div className="flex items-center gap-2">
                  <Star className="text-accent" />
                  <span>{movie.vote_average.toFixed(1)} / 10</span>
                </div>
                <div className="flex items-center gap-2">
                  <Calendar className="text-accent" />
                  <span>{movie.release_date?.substring(0, 4)}</span>
                </div>
                {movie.runtime && (
                  <div className="flex items-center gap-2">
                    <Clock className="text-accent" />
                    <span>{movie.runtime} min</span>
                  </div>
                )}
              </div>
              <div className="flex flex-wrap gap-2 mb-6">
                {movie.genres.map(genre => (
                  <Badge key={genre.id} variant="secondary">{genre.name}</Badge>
                ))}
              </div>
              <p className="text-base leading-relaxed mb-6">{movie.overview}</p>
              <div className="flex items-center gap-4">
                <PlayerDialogButton />
              </div>
            </div>
          </div>
        </div>

        <div className="px-4 md:px-8">
          {similarMovies.length > 0 && (
            <section className="mt-12">
              <h2 className="font-headline text-2xl font-bold mb-4">Similar Movies</h2>
              <MovieList initialMedia={similarMovies as Media[]} />
            </section>
          )}
        </div>
      </div>
    </VideoPlayerDialog>
  );
}
