import Image from 'next/image';
import { getMovieDetails, getMovieCredits, getSimilarMovies } from '@/lib/tmdb';
import { Star, Calendar, Clock, PlayCircle } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { WatchLaterButton } from '@/components/movies/WatchLaterButton';
import { MovieList } from '@/components/movies/MovieList';
import { VideoPlayerDialog } from '@/components/common/VideoPlayerDialog';
import type { Media } from '@/types/tmdb';

type MoviePageProps = {
  params: { id: string };
};

export default async function MoviePage({ params }: MoviePageProps) {
  const movieId = Number(params.id);
  const movie = await getMovieDetails(movieId);
  
  if (!movie) {
    return <div>Movie not found.</div>;
  }
  
  const [credits, similarMovies] = await Promise.all([
    getMovieCredits(movieId),
    getSimilarMovies(movieId),
  ]);

  const cast = credits?.cast.slice(0, 10) || [];

  return (
    <>
      <VideoPlayerDialog
        mediaId={movie.id}
        mediaType={movie.media_type}
      />
      <div className="container mx-auto px-4 py-8 text-white">
        <div className="relative h-[30vh] md:h-[50vh] w-full">
          {movie.backdrop_path && (
            <Image
              src={`https://image.tmdb.org/t/p/original${movie.backdrop_path}`}
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
                src={movie.poster_path ? `https://image.tmdb.org/t/p/w500${movie.poster_path}` : "https://placehold.co/500x750.png"}
                alt={`${movie.title} poster`}
                width={500}
                height={750}
                className="rounded-lg shadow-2xl"
                data-ai-hint="movie poster"
              />
            </div>
            <div className="w-full md:w-2/3 lg:w-3/4 pt-0 md:pt-24">
              <h1 className="font-headline text-4xl md:text-6xl font-bold mb-2">{movie.title}</h1>
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
                <VideoPlayerDialog.Button />
                <WatchLaterButton item={movie} />
              </div>
            </div>
          </div>
        </div>

        <div className="px-4 md:px-8">
          <section className="mb-12">
            <h2 className="font-headline text-3xl font-bold mb-6">Top Cast</h2>
            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-6">
              {cast.map(member => (
                <div key={member.id} className="text-center">
                  <Image
                    src={member.profile_path ? `https://image.tmdb.org/t/p/w185${member.profile_path}`: "https://placehold.co/185x278.png"}
                    alt={member.name}
                    width={185}
                    height={278}
                    className="rounded-lg mb-2 mx-auto"
                    data-ai-hint="actor portrait"
                  />
                  <p className="font-semibold">{member.name}</p>
                  <p className="text-sm text-muted-foreground">{member.character}</p>
                </div>
              ))}
            </div>
          </section>

          {similarMovies.length > 0 && (
            <section>
              <h2 className="font-headline text-3xl font-bold mb-6">Similar Movies</h2>
              <MovieList initialMedia={similarMovies as Media[]} showControls={false} />
            </section>
          )}
        </div>
      </div>
    </>
  );
}
