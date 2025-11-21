import Image from 'next/image';
import { getTvShowDetails, getSimilarTvShows } from '@/lib/tmdb';
import { Star, Calendar, Tv as TvIcon } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { MovieList } from '@/components/movies/MovieList';
import { EpisodeSelector } from '@/components/tv/EpisodeSelector';
import { Suspense } from 'react';
import { Skeleton } from '@/components/ui/skeleton';

async function SimilarShows({ tvShowId }: { tvShowId: number }) {
    const similarShows = await getSimilarTvShows(tvShowId);
    if (similarShows.length === 0) return null;
    return (
        <section className="mt-12 mb-8">
            <h2 className="font-bold text-xl mb-4 text-white/90 px-1">Similar Shows</h2>
            <MovieList initialMedia={similarShows} carousel />
        </section>
    )
}

export default async function TvShowPage({ params: { id } }: { params: { id: string } }) {
  const tvShowId = Number(id);
  const show = await getTvShowDetails(tvShowId);
  if (!show) return <div className="container py-20 text-center text-muted-foreground">TV show not found.</div>;
  
  const seasons = show?.seasons?.filter(s => s.season_number > 0) || [];

  return (
    <div className="min-h-screen bg-background pb-10">
      {/* Hero Section */}
      <div className="relative w-full h-[45vh] md:h-[60vh]">
        {show.backdrop_path ? (
          <Image 
            src={`https://image.tmdb.org/t/p/original${show.backdrop_path}`} 
            alt={show.name} 
            fill 
            className="object-cover" 
            priority 
          />
        ) : (
           <div className="w-full h-full bg-zinc-900" />
        )}
        <div className="absolute inset-0 bg-gradient-to-t from-background via-background/60 to-transparent" />
      </div>

      <div className="container mx-auto px-4 -mt-32 relative z-10">
        <div className="flex flex-col md:flex-row gap-6 md:gap-10">
          
          {/* Poster */}
          <div className="shrink-0 mx-auto md:mx-0 w-40 md:w-72 lg:w-80 relative group">
            <div className="aspect-[2/3] relative rounded-xl overflow-hidden shadow-2xl ring-1 ring-white/10 bg-zinc-800">
                <Image 
                    src={show.poster_path ? `https://image.tmdb.org/t/p/w500${show.poster_path}` : "https://placehold.co/500x750.png"} 
                    alt={show.name} 
                    fill 
                    className="object-cover" 
                    priority 
                />
            </div>
          </div>

          {/* Info */}
          <div className="flex-1 pt-2 md:pt-32 text-center md:text-left">
            <h1 className="text-3xl md:text-5xl font-extrabold tracking-tight text-white mb-2 leading-tight">
                {show.name}
            </h1>
            
            {show.tagline && (
                <p className="text-base md:text-lg text-primary/90 font-medium italic mb-4">
                    "{show.tagline}"
                </p>
            )}

            <div className="flex flex-wrap justify-center md:justify-start gap-3 mb-6">
              <div className="flex items-center gap-1.5 bg-white/10 backdrop-blur-md px-3 py-1 rounded-full text-xs md:text-sm font-medium text-white border border-white/5">
                <Star className="w-3.5 h-3.5 text-yellow-400 fill-yellow-400" /> 
                {show.vote_average.toFixed(1)}
              </div>
              <div className="flex items-center gap-1.5 bg-white/10 backdrop-blur-md px-3 py-1 rounded-full text-xs md:text-sm font-medium text-white border border-white/5">
                <Calendar className="w-3.5 h-3.5 text-gray-300" /> 
                {show.first_air_date?.substring(0, 4)}
              </div>
              <div className="flex items-center gap-1.5 bg-white/10 backdrop-blur-md px-3 py-1 rounded-full text-xs md:text-sm font-medium text-white border border-white/5">
                <TvIcon className="w-3.5 h-3.5 text-gray-300" /> 
                {show.number_of_seasons} Seasons
              </div>
            </div>

            <div className="flex flex-wrap justify-center md:justify-start gap-2 mb-8">
                {show.genres.map(g => (
                    <Badge key={g.id} variant="secondary" className="bg-zinc-800 hover:bg-zinc-700 text-zinc-300 border border-white/5 px-3 py-1">
                        {g.name}
                    </Badge>
                ))}
            </div>

            <div className="mb-8 max-w-3xl mx-auto md:mx-0">
                <h3 className="text-sm font-bold text-muted-foreground uppercase tracking-wider mb-2">Overview</h3>
                <p className="text-sm md:text-base leading-relaxed text-gray-300 text-justify md:text-left">
                    {show.overview}
                </p>
            </div>

            <div className="max-w-3xl mx-auto md:mx-0 mb-10">
                <EpisodeSelector tvId={tvShowId} seasons={seasons} />
            </div>
          </div>
        </div>

        <Suspense fallback={<Skeleton className="h-48 w-full mt-10 rounded-xl bg-white/5" />}>
            <SimilarShows tvShowId={tvShowId} />
        </Suspense>
      </div>
    </div>
  );
}