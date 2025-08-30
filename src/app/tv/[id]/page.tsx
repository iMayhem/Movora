
import Image from 'next/image';
import { getTvShowDetails, getSimilarTvShows, getUpcomingEpisodes } from '@/lib/tmdb';
import { Star, Calendar, Tv, Clock } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { MovieList } from '@/components/movies/MovieList';
import { EpisodeSelector } from '@/components/tv/EpisodeSelector';
import { VideoPlayerDialog } from '@/components/common/VideoPlayerDialog';
import { PlayerDialogButton } from '@/components/common/PlayerDialogButton';
import type { Media, TVShow, Episode } from '@/types/tmdb';

type TvShowPageProps = {
  params: { id: string };
};

export default async function TvShowPage({ params: { id } }: TvShowPageProps) {
  const tvShowId = Number(id);
  const show = await getTvShowDetails(tvShowId);

  if (!show) {
    return <div>TV show not found.</div>;
  }
  
  const similarShows = await getSimilarTvShows(tvShowId);
  const upcomingEpisodes = await getUpcomingEpisodes(tvShowId);
  
  // Filter seasons: exclude season 0 (specials) and sort by season number
  const seasons = show.seasons
    ?.filter(s => s.season_number > 0)
    .sort((a, b) => a.season_number - b.season_number) || [];

  // Separate aired and upcoming seasons
  const now = new Date();
  const airedSeasons = seasons.filter(s => 
    s.air_date && new Date(s.air_date) <= now
  );
  const upcomingSeasons = seasons.filter(s => 
    s.air_date && new Date(s.air_date) > now
  );

  return (
    <VideoPlayerDialog mediaId={show.id} mediaType={show.media_type}>
      <div className="container mx-auto px-4 py-6 text-white">
        <div className="relative h-[30vh] md:h-[50vh] w-full">
          {show.backdrop_path && (
            <Image
              src={`https://image.tmdb.org/t/p/w1280${show.backdrop_path}`}
              alt={`${show.name} backdrop`}
              fill
              style={{ objectFit: 'cover' }}
              className="rounded-lg opacity-30"
              data-ai-hint="tv show backdrop"
              priority
            />
          )}
          <div className="absolute inset-0 bg-gradient-to-t from-background to-transparent"></div>
        </div>

        <div className="relative -mt-24 md:-mt-48 px-4 md:px-8 pb-12">
          <div className="flex flex-col md:flex-row gap-8">
            <div className="w-full md:w-1/3 lg:w-1/4">
              <Image
                src={show.poster_path ? `https://image.tmdb.org/t/p/w342${show.poster_path}` : "https://placehold.co/500x750.png"}
                alt={`${show.name} poster`}
                width={500}
                height={750}
                className="rounded-lg shadow-2xl"
                data-ai-hint="tv show poster"
              />
            </div>
            <div className="w-full md:w-2/3 lg:w-3/4 pt-0 md:pt-24">
              <h1 className="font-headline text-3xl md:text-5xl font-bold mb-2">{show.name}</h1>
              <p className="text-lg text-muted-foreground mb-4">{show.tagline}</p>
              <div className="flex flex-wrap items-center gap-4 mb-6">
                <div className="flex items-center gap-2">
                  <Star className="text-accent" />
                  <span>{show.vote_average.toFixed(1)} / 10</span>
                </div>
                <div className="flex items-center gap-2">
                  <Calendar className="text-accent" />
                  <span>{show.first_air_date?.substring(0, 4)}</span>
                </div>
                <div className="flex items-center gap-2">
                  <Tv className="text-accent" />
                  <span>{airedSeasons.length} Season{airedSeasons.length > 1 ? 's' : ''} Available</span>
                </div>
                {upcomingSeasons.length > 0 && (
                  <div className="flex items-center gap-2">
                    <Clock className="text-accent" />
                    <span>{upcomingSeasons.length} Season{upcomingSeasons.length > 1 ? 's' : ''} Coming Soon</span>
                  </div>
                )}
              </div>
              <div className="flex flex-wrap gap-2 mb-6">
                {show.genres.map(genre => (
                  <Badge key={genre.id} variant="secondary">{genre.name}</Badge>
                ))}
              </div>
              <p className="text-base leading-relaxed mb-6">{show.overview}</p>

              {/* Show upcoming episodes if available */}
              {upcomingEpisodes.length > 0 && (
                <div className="mb-6 p-4 bg-accent/10 rounded-lg border border-accent/20">
                  <h3 className="text-lg font-semibold mb-3 flex items-center gap-2">
                    <Clock className="h-5 w-5 text-accent" />
                    Upcoming Episodes
                  </h3>
                  <div className="space-y-2">
                    {upcomingEpisodes.map(episode => (
                      <div key={episode.id} className="flex justify-between items-center text-sm">
                        <span>
                          S{episode.season_number}E{episode.episode_number}: {episode.name}
                        </span>
                        <span className="text-accent">
                          {new Date(episode.air_date).toLocaleDateString('en-US', { 
                            month: 'short', 
                            day: 'numeric',
                            year: 'numeric'
                          })}
                        </span>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* Only show episode selector if there are aired seasons */}
              {airedSeasons.length > 0 ? (
                <EpisodeSelector tvId={tvShowId} seasons={airedSeasons} />
              ) : (
                <div className="mb-6 p-4 bg-muted/20 rounded-lg">
                  <p className="text-center text-muted-foreground">
                    No episodes available yet. Check back later!
                  </p>
                </div>
              )}
              
              <div className="flex items-center gap-4 mt-6">
                <PlayerDialogButton />
              </div>
            </div>
          </div>
        </div>

        <div className="px-4 md:px-8">
          {similarShows.length > 0 && (
            <section className="mt-12">
              <h2 className="font-headline text-2xl font-bold mb-4">Similar Shows</h2>
              <MovieList initialMedia={similarShows as Media[]} />
            </section>
          )}
        </div>
      </div>
    </VideoPlayerDialog>
  );
}
