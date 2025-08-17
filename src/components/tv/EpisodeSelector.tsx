
'use client';

import { useState, useEffect, useCallback } from 'react';
import { getSeasonDetails } from '@/lib/tmdb';
import { useVideoPlayer } from '@/components/common/VideoPlayerDialog';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Label } from '@/components/ui/label';
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert';
import { AlertCircle } from 'lucide-react';
import type { Season, Episode } from '@/types/tmdb';

type EpisodeSelectorProps = {
  tvId: number;
  seasons: Season[];
};

export function EpisodeSelector({ tvId, seasons }: EpisodeSelectorProps) {
  const { setSeason, setEpisode, setIsPlayable } = useVideoPlayer();
  const [selectedSeason, setSelectedSeasonState] = useState<number | undefined>(undefined);
  const [selectedEpisode, setSelectedEpisodeState] = useState<number | undefined>(undefined);
  const [episodes, setEpisodes] = useState<Episode[]>([]);
  const [isSeasonUpcoming, setIsSeasonUpcoming] = useState(false);
  const [seasonAirDate, setSeasonAirDate] = useState<string | null>(null);

  useEffect(() => {
    if (seasons.length > 0) {
      const firstAiredSeason = seasons.find(s => s.season_number > 0);
      if (firstAiredSeason) {
        setSelectedSeasonState(firstAiredSeason.season_number);
      }
    }
  }, [seasons]);

  useEffect(() => {
    const fetchSeasonData = async () => {
      if (selectedSeason === undefined) return;

      const season = seasons.find(s => s.season_number === selectedSeason);
      if (season && new Date(season.air_date) > new Date()) {
        setIsSeasonUpcoming(true);
        setSeasonAirDate(new Date(season.air_date).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' }));
        setEpisodes([]);
        setSelectedEpisodeState(undefined);
        setIsPlayable(false);
      } else {
        setIsSeasonUpcoming(false);
        setSeasonAirDate(null);
        const seasonDetails = await getSeasonDetails(tvId, selectedSeason);
        const fetchedEpisodes = seasonDetails?.episodes || [];
        setEpisodes(fetchedEpisodes);
        const firstEpisode = fetchedEpisodes.length > 0 ? fetchedEpisodes[0].episode_number : 1;
        setSelectedEpisodeState(firstEpisode);
      }
    };

    fetchSeasonData();
  }, [tvId, selectedSeason, seasons, setIsPlayable]);
  
  useEffect(() => {
    if (selectedSeason !== undefined) {
        setSeason(selectedSeason);
    }
    if (selectedEpisode !== undefined) {
        setEpisode(selectedEpisode)
    }
  }, [selectedSeason, selectedEpisode, setSeason, setEpisode]);

  const isEpisodeUpcoming = useCallback((episodeNumber: number | undefined) => {
    if (episodeNumber === undefined) return true;
    const episode = episodes.find(e => e.episode_number === episodeNumber);
    return episode ? new Date(episode.air_date) > new Date() : true;
  }, [episodes]);

  useEffect(() => {
      setIsPlayable(!isSeasonUpcoming && !isEpisodeUpcoming(selectedEpisode));
  }, [isSeasonUpcoming, selectedEpisode, isEpisodeUpcoming, setIsPlayable])

  const handleSeasonChange = (value: string) => {
    setSelectedSeasonState(Number(value));
  };
  
  const handleEpisodeChange = (value: string) => {
      setSelectedEpisodeState(Number(value))
  }

  return (
    <div className="bg-background/50 backdrop-blur-sm rounded-lg p-4">
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
              onValueChange={handleEpisodeChange}
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
  );
}
