
'use client';

import { useState, useEffect, useCallback } from 'react';
import Image from 'next/image';
import { getTvShowDetails, getTvShowCredits, getSimilarTvShows, getSeasonDetails } from '@/lib/tmdb';
import { Star, Calendar, Tv, PlayCircle, AlertCircle } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { WatchLaterButton } from '@/components/movies/WatchLaterButton';
import { MovieList } from '@/components/movies/MovieList';
import { VideoPlayer } from '@/components/common/VideoPlayer';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Label } from '@/components/ui/label';
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert';
import type { Media, TVShow, Credits, Episode } from '@/types/tmdb';

type TvShowPageProps = {
  params: { id: string };
};

export default function TvShowPage({ params }: TvShowPageProps) {
  const [show, setShow] = useState<(TVShow & { media_type: 'tv' }) | null>(null);
  const [credits, setCredits] = useState<Credits | null>(null);
  const [similarShows, setSimilarShows] = useState<Media[]>([]);
  const [isVideoPlayerOpen, setIsVideoPlayerOpen] = useState(false);
  const [selectedSeason, setSelectedSeason] = useState<number | undefined>(undefined);
  const [selectedEpisode, setSelectedEpisode] = useState<number | undefined>(undefined);
  const [episodes, setEpisodes] = useState<Episode[]>([]);
  const [isSeasonUpcoming, setIsSeasonUpcoming] = useState(false);
  const [seasonAirDate, setSeasonAirDate] = useState<string | null>(null);

  const tvShowId = Number(params.id);

  useEffect(() => {
    const fetchTvShowData = async () => {
      const showDetails = await getTvShowDetails(tvShowId);
      setShow(showDetails);
      const showCredits = await getTvShowCredits(tvShowId);
      setCredits(showCredits);
      const similar = await getSimilarTvShows(tvShowId);
      setSimilarShows(similar);
      if (showDetails?.seasons && showDetails.seasons.length > 0) {
        const firstAiredSeason = showDetails.seasons.find(s => s.season_number > 0);
        if (firstAiredSeason) {
          setSelectedSeason(firstAiredSeason.season_number);
        }
      }
    };

    fetchTvShowData();
  }, [tvShowId]);

  useEffect(() => {
    const fetchSeasonData = async () => {
      if (selectedSeason === undefined) return;
      
      const season = show?.seasons?.find(s => s.season_number === selectedSeason);
      if (season && new Date(season.air_date) > new Date()) {
        setIsSeasonUpcoming(true);
        setSeasonAirDate(new Date(season.air_date).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' }));
        setEpisodes([]);
        setSelectedEpisode(undefined);
      } else {
        setIsSeasonUpcoming(false);
        setSeasonAirDate(null);
        const seasonDetails = await getSeasonDetails(tvShowId, selectedSeason);
        setEpisodes(seasonDetails?.episodes || []);
        setSelectedEpisode(seasonDetails?.episodes?.[0]?.episode_number || 1);
      }
    };

    if (show) {
        fetchSeasonData();
    }
  }, [show, selectedSeason, tvShowId]);

  const handleSeasonChange = (value: string) => {
    setSelectedSeason(Number(value));
  };

  const isEpisodeUpcoming = useCallback((episodeNumber: number | undefined) => {
    if(episodeNumber === undefined) return true;
    const episode = episodes.find(e => e.episode_number === episodeNumber);
    return episode ? new Date(episode.air_date) > new Date() : true;
  }, [episodes]);

  if (!show) {
    return <div>Loading...</div>;
  }

  const cast = credits?.cast.slice(0, 10) || [];
  const seasons = show.seasons?.filter(s => s.season_number > 0) || [];

  return (
    <>
      <VideoPlayer
        isOpen={isVideoPlayerOpen}
        onClose={() => setIsVideoPlayerOpen(false)}
        mediaId={show.id}
        mediaType={show.media_type}
        season={selectedSeason}
        episode={selectedEpisode}
      />
      <div className="container mx-auto px-4 py-8 text-white">
        <div className="relative h-[30vh] md:h-[50vh] w-full">
          {show.backdrop_path && (
            <Image
              src={`https://image.tmdb.org/t/p/original${show.backdrop_path}`}
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
                src={show.poster_path ? `https://image.tmdb.org/t/p/w500${show.poster_path}` : "https://placehold.co/500x750.png"}
                alt={`${show.name} poster`}
                width={500}
                height={750}
                className="rounded-lg shadow-2xl"
                data-ai-hint="tv show poster"
              />
            </div>
            <div className="w-full md:w-2/3 lg:w-3/4 pt-0 md:pt-24">
              <h1 className="font-headline text-4xl md:text-6xl font-bold mb-2">{show.name}</h1>
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
                  <span>{show.number_of_seasons} Season{show.number_of_seasons > 1 ? 's' : ''}</span>
                </div>
              </div>
              <div className="flex flex-wrap gap-2 mb-6">
                {show.genres.map(genre => (
                  <Badge key={genre.id} variant="secondary">{genre.name}</Badge>
                ))}
              </div>
              <p className="text-base leading-relaxed mb-6">{show.overview}</p>
              
              <div className="bg-background/50 backdrop-blur-sm rounded-lg p-4 mb-6">
                <h3 className="text-xl font-semibold mb-4">Select Episode</h3>
                <div className="flex flex-col sm:flex-row gap-4">
                  <div className="flex-1">
                    <Label htmlFor="season-select">Season</Label>
                    <Select
                      value={selectedSeason !== undefined ? String(selectedSeason) : ''}
                      onValueChange={handleSeasonChange}
                      disabled={seasons.length === 0}
                    >
                      <SelectTrigger id="season-select">
                        <SelectValue placeholder="Select season" />
                      </SelectTrigger>
                      <SelectContent>
                        {seasons.map(season => (
                          <SelectItem key={season.id} value={String(season.season_number)}>
                            {season.name}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                    {isSeasonUpcoming ? (
                         <div className="flex-1 flex items-end">
                            <Alert variant="default" className="border-accent">
                                <AlertCircle className="h-4 w-4 text-accent" />
                                <AlertTitle className="text-accent">Coming Soon!</AlertTitle>
                                <AlertDescription>
                                    This season is scheduled to air on {seasonAirDate}.
                                </AlertDescription>
                            </Alert>
                        </div>
                    ) : (
                        <div className="flex-1">
                            <Label htmlFor="episode-select">Episode</Label>
                            <Select
                            value={selectedEpisode !== undefined ? String(selectedEpisode) : ''}
                            onValueChange={(value) => setSelectedEpisode(Number(value))}
                            disabled={episodes.length === 0}
                            >
                            <SelectTrigger id="episode-select">
                                <SelectValue placeholder="Select episode" />
                            </SelectTrigger>
                            <SelectContent>
                                {episodes.map(ep => {
                                    const upcoming = new Date(ep.air_date) > new Date();
                                    return (
                                        <SelectItem key={ep.id} value={String(ep.episode_number)} disabled={upcoming}>
                                            Episode {ep.episode_number} {upcoming ? `(Airs ${new Date(ep.air_date).toLocaleDateString()})` : ''}
                                        </SelectItem>
                                    )
                                })}
                            </SelectContent>
                            </Select>
                        </div>
                    )}
                </div>
              </div>
              
              <div className="flex items-center gap-4">
                <Button onClick={() => setIsVideoPlayerOpen(true)} size="lg" disabled={isSeasonUpcoming || isEpisodeUpcoming(selectedEpisode)}>
                  <PlayCircle className="mr-2" />
                  Watch Now
                </Button>
                <WatchLaterButton item={show} />
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
                    src={member.profile_path ? `https://image.tmdb.org/t/p/w185${member.profile_path}` : "https://placehold.co/185x278.png"}
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

          {similarShows.length > 0 && (
            <section>
              <h2 className="font-headline text-3xl font-bold mb-6">Similar Shows</h2>
              <MovieList initialMedia={similarShows} showControls={false} />
            </section>
          )}
        </div>
      </div>
    </>
  );
}