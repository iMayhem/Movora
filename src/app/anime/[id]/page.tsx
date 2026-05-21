import Image from 'next/image';
import { getAnimeDetails, getPopularAnime } from '@/lib/anilist';
import { searchMedia, getTvShowDetails } from '@/lib/tmdb';
import { Star, Calendar, Tv as TvIcon, Play, AlertCircle } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { MovieList } from '@/components/movies/MovieList';
import { VideoPlayer } from '@/components/common/VideoPlayer';
import { EpisodeSelector } from '@/components/tv/EpisodeSelector';
import { DetailsActions } from '@/components/common/DetailsActions';
import { Suspense } from 'react';
import { Skeleton } from '@/components/ui/skeleton';

async function RelatedAnime() {
    const popularAnime = await getPopularAnime(1, 12);
    if (popularAnime.length === 0) return null;
    return (
        <section className="mt-12 mb-8">
            <h2 className="font-bold text-xl mb-4 text-white/90 px-1 font-headline text-gradient">You might also like</h2>
            <MovieList initialMedia={popularAnime} carousel />
        </section>
    );
}

export default async function AnimePage({ params: { id } }: { params: { id: string } }) {
  const animeId = Number(id);
  const anime = await getAnimeDetails(animeId);
  if (!anime) return <div className="container py-20 text-center text-muted-foreground">Anime not found.</div>;

  // Bridge dynamically to TMDB
  let bridgedMedia: { id: number; mediaType: 'movie' | 'tv'; seasons?: any[]; backdrop_path?: string | null } | null = null;
  let bridgingError = false;

  try {
      // 1. Clean the title slightly for higher match rates (remove specific seasons info)
      const cleanTitle = anime.title.replace(/Season \d+|Part \d+|S\d+/gi, '').trim();
      
      // 2. Search TV first (95% of anime are TV series)
      const tvSearch = await searchMedia(cleanTitle, 'tv');
      if (tvSearch && tvSearch.length > 0) {
          const tmdbId = tvSearch[0].id;
          const tvDetails = await getTvShowDetails(tmdbId);
          bridgedMedia = {
              id: tmdbId,
              mediaType: 'tv',
              seasons: tvDetails?.seasons?.filter(s => s.season_number > 0) || [],
              backdrop_path: tvSearch[0].backdrop_path
          };
      } else {
          // 3. Fallback to Movie Search (e.g. anime films)
          const movieSearch = await searchMedia(cleanTitle, 'movie');
          if (movieSearch && movieSearch.length > 0) {
              bridgedMedia = {
                  id: movieSearch[0].id,
                  mediaType: 'movie',
                  backdrop_path: movieSearch[0].backdrop_path
              };
          }
      }
  } catch (e) {
      console.error('Bridging to TMDB failed:', e);
      bridgingError = true;
  }

  return (
    <div className="min-h-screen bg-background pb-10">
      {/* Hero Banner Section with Glassmorphic Overlay */}
      <div className="relative w-full h-[45vh] md:h-[60vh]">
        {anime.backdrop_path ? (
          <Image 
            src={anime.backdrop_path} 
            alt={anime.title} 
            fill 
            className="object-cover" 
            priority 
            unoptimized={anime.backdrop_path.startsWith('http')}
          />
        ) : (
           <div className="w-full h-full bg-zinc-900" />
        )}
        <div className="absolute inset-0 bg-gradient-to-t from-background via-background/60 to-transparent" />
      </div>

      <div className="container mx-auto px-4 -mt-32 relative z-10">
        <div className="flex flex-col md:flex-row gap-6 md:gap-10">
          
          {/* Floating Poster Card */}
          <div className="shrink-0 mx-auto md:mx-0 w-40 md:w-72 lg:w-80 relative group">
            <div className="aspect-[2/3] relative rounded-xl overflow-hidden shadow-2xl ring-1 ring-white/10 bg-zinc-800">
                <Image 
                    src={anime.poster_path ? anime.poster_path : "https://placehold.co/500x750.png"} 
                    alt={anime.title} 
                    fill 
                    className="object-cover" 
                    priority 
                    unoptimized={anime.poster_path && anime.poster_path.startsWith('http')}
                />
            </div>
          </div>

          {/* Details / Info Area */}
          <div className="flex-1 pt-2 md:pt-32 text-center md:text-left">
            <h1 className="text-3xl md:text-5xl font-extrabold tracking-tight text-white mb-2 leading-tight font-headline">
                {anime.title}
            </h1>
            
            {anime.studio && (
                <p className="text-base md:text-lg text-primary/95 font-medium mb-4">
                    Produced by <span className="font-semibold text-violet-400">{anime.studio}</span>
                </p>
            )}

            {/* Metadata Pills */}
            <div className="flex flex-wrap justify-center md:justify-start gap-3 mb-6">
              <div className="flex items-center gap-1.5 bg-white/10 backdrop-blur-md px-3 py-1 rounded-full text-xs md:text-sm font-medium text-white border border-white/5">
                <Star className="w-3.5 h-3.5 text-yellow-400 fill-yellow-400" /> 
                {anime.vote_average.toFixed(1)} / 10
              </div>
              <div className="flex items-center gap-1.5 bg-white/10 backdrop-blur-md px-3 py-1 rounded-full text-xs md:text-sm font-medium text-white border border-white/5">
                <Calendar className="w-3.5 h-3.5 text-gray-300" /> 
                {anime.release_date}
              </div>
              {anime.episodes && (
                <div className="flex items-center gap-1.5 bg-white/10 backdrop-blur-md px-3 py-1 rounded-full text-xs md:text-sm font-medium text-white border border-white/5">
                  <TvIcon className="w-3.5 h-3.5 text-gray-300" /> 
                  {anime.episodes} Episodes ({anime.status})
                </div>
              )}
            </div>

            {/* Genres badges */}
            <div className="flex flex-wrap justify-center md:justify-start gap-2 mb-8">
                {anime.genres.map((g: any) => (
                    <Badge key={g.id} variant="secondary" className="bg-zinc-800 hover:bg-zinc-700 text-zinc-300 border border-white/5 px-3 py-1">
                        {g.name}
                    </Badge>
                ))}
            </div>

            {/* Overview */}
            <div className="mb-8 max-w-3xl mx-auto md:mx-0">
                <h3 className="text-sm font-bold text-muted-foreground uppercase tracking-wider mb-2">Synopsis</h3>
                <p className="text-sm md:text-base leading-relaxed text-gray-300 text-justify md:text-left">
                    {anime.overview}
                </p>
            </div>

            {/* Playback Actions / Players */}
            <div className="max-w-3xl mx-auto md:mx-0 mb-10">
                <h3 className="text-sm font-bold text-muted-foreground uppercase tracking-wider mb-3">Watch Now</h3>
                <div className="space-y-4 text-left">
                    {bridgedMedia ? (
                        <>
                            {bridgedMedia.mediaType === 'tv' && bridgedMedia.seasons && bridgedMedia.seasons.length > 0 ? (
                                <EpisodeSelector 
                                    tvId={bridgedMedia.id} 
                                    seasons={bridgedMedia.seasons} 
                                />
                            ) : bridgedMedia.mediaType === 'movie' ? (
                                <VideoPlayer 
                                    mediaId={bridgedMedia.id} 
                                    mediaType="movie" 
                                    posterPath={bridgedMedia.backdrop_path || anime.backdrop_path} 
                                    title={anime.title}
                                />
                            ) : (
                                <div className="flex items-center gap-3 p-4 bg-zinc-950/60 border border-zinc-900 rounded-xl">
                                    <AlertCircle className="w-5 h-5 text-amber-500 shrink-0" />
                                    <span className="text-sm text-zinc-400">TV show matched on TMDB, but no detailed seasons were found.</span>
                                </div>
                            )}
                            
                            {/* Actions Drawer support */}
                            <DetailsActions 
                                mediaId={bridgedMedia.id} 
                                mediaType={bridgedMedia.mediaType} 
                                title={anime.title} 
                                posterPath={bridgedMedia.backdrop_path || null} 
                            />
                        </>
                    ) : (
                        <div className="flex flex-col items-center justify-center p-8 bg-zinc-950/60 border border-zinc-900 rounded-xl text-center gap-3">
                            <AlertCircle className="w-10 h-10 text-violet-500" />
                            <div>
                                <h4 className="font-semibold text-white text-sm">Streaming Unavailable for this Title</h4>
                                <p className="text-xs text-zinc-500 max-w-sm mt-1">This anime could not be bridged to standard media sources. You can still explore details and watchlist features on AniList!</p>
                            </div>
                        </div>
                    )}
                </div>
            </div>
          </div>
        </div>

        <Suspense fallback={<Skeleton className="h-48 w-full mt-10 rounded-xl bg-white/5" />}>
            <RelatedAnime />
        </Suspense>
      </div>
    </div>
  );
}
