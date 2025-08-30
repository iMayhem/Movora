
'use client';

import { useState, useEffect, useCallback } from 'react';
import { getSeasonDetails } from '@/lib/tmdb';
import { useVideoPlayer } from '@/components/common/VideoPlayerDialog';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Label } from '@/components/ui/label';
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert';
import { AlertCircle, Loader2 } from 'lucide-react';
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
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (seasons.length > 0) {
      // Find the first aired season (not upcoming)
      const now = new Date();
      const firstAiredSeason = seasons.find(s => 
        s.season_number > 0 && s.air_date && new Date(s.air_date) <= now
      );
      if (firstAiredSeason) {
        setSelectedSeasonState(firstAiredSeason.season_number);
      } else if (seasons.length > 0) {
        // Fallback to first season if no aired seasons
        setSelectedSeasonState(seasons[0].season_number);
      }
    }
  }, [seasons]);

  useEffect(() => {
    const fetchSeasonData = async () => {
      if (selectedSeason === undefined) return;

      setIsLoading(true);
      setError(null);

      try {
        const season = seasons.find(s => s.season_number === selectedSeason);
        if (!season) {
          setError('Season not found');
          return;
        }

        // Check if season is upcoming
        if (season.air_date && new Date(season.air_date) > new Date()) {
          setIsSeasonUpcoming(true);
          setSeasonAirDate(new Date(season.air_date).toLocaleDateString('en-US', { 
            year: 'numeric', 
            month: 'long', 
            day: 'numeric' 
          }));
          setEpisodes([]);
          setSelectedEpisodeState(undefined);
          setIsPlayable(false);
        } else {
          setIsSeasonUpcoming(false);
          setSeasonAirDate(null);
          
          const seasonDetails = await getSeasonDetails(tvId, selectedSeason);
          if (seasonDetails?.episodes) {
            const fetchedEpisodes = seasonDetails.episodes.sort((a, b) => a.episode_number - b.episode_number);
            setEpisodes(fetchedEpisodes);
            
            // Find first available episode (not upcoming)
            const now = new Date();
            const firstAvailableEpisode = fetchedEpisodes.find(ep => 
              ep.air_date && new Date(ep.air_date) <= now
            );
            
            if (firstAvailableEpisode) {
              setSelectedEpisodeState(firstAvailableEpisode.episode_number);
            } else if (fetchedEpisodes.length > 0) {
              setSelectedEpisodeState(fetchedEpisodes[0].episode_number);
            }
          } else {
            setEpisodes([]);
            setSelectedEpisodeState(undefined);
          }
        }
      } catch (err) {
        console.error('Error fetching season data:', err);
        setError('Failed to load season data');
        setEpisodes([]);
        setSelectedEpisodeState(undefined);
      } finally {
        setIsLoading(false);
      }
    };

    fetchSeasonData();
  }, [tvId, selectedSeason, seasons, setIsPlayable]);
  
  useEffect(() => {
    if (selectedSeason !== undefined) {
      setSeason(selectedSeason);
    }
    if (selectedEpisode !== undefined) {
      setEpisode(selectedEpisode);
    }
  }, [selectedSeason, selectedEpisode, setSeason, setEpisode]);

  const isEpisodeUpcoming = useCallback((episodeNumber: number | undefined) => {
    if (episodeNumber === undefined) return true;
    const episode = episodes.find(e => e.episode_number === episodeNumber);
    return episode ? new Date(episode.air_date) > new Date() : true;
  }, [episodes]);

  useEffect(() => {
    setIsPlayable(!isSeasonUpcoming && !isEpisodeUpcoming(selectedEpisode));
  }, [isSeasonUpcoming, selectedEpisode, isEpisodeUpcoming, setIsPlayable]);

  const handleSeasonChange = (value: string) => {
    setSelectedSeasonState(Number(value));
    setSelectedEpisodeState(undefined); // Reset episode when season changes
  };
  
  const handleEpisodeChange = (value: string) => {
    setSelectedEpisodeState(Number(value));
  };

  if (seasons.length === 0) {
    return (
      <div className="bg-background/50 backdrop-blur-sm rounded-lg p-4">
        <p className="text-center text-muted-foreground">No seasons available.</p>
      </div>
    );
  }

  return (
    <div className="bg-background/50 backdrop-blur-sm rounded-lg p-4">
      <h3 className="text-xl font-semibold mb-4">Select Episode</h3>
      
      {error && (
        <Alert variant="destructive" className="mb-4">
          <AlertCircle className="h-4 w-4" />
          <AlertTitle>Error</AlertTitle>
          <AlertDescription>{error}</AlertDescription>
        </Alert>
      )}
      
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
              {seasons.map(season => {
                const isUpcoming = season.air_date && new Date(season.air_date) > new Date();
                return (
                  <SelectItem key={season.id} value={String(season.season_number)}>
                    {season.name} {isUpcoming ? '(Coming Soon)' : ''}
                  </SelectItem>
                );
              })}
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
              disabled={episodes.length === 0 || isLoading}
            >
              <SelectTrigger id="episode-select">
                {isLoading ? (
                  <div className="flex items-center gap-2">
                    <Loader2 className="h-4 w-4 animate-spin" />
                    Loading...
                  </div>
                ) : (
                  <SelectValue placeholder="Select episode" />
                )}
              </SelectTrigger>
              <SelectContent>
                {episodes.map(ep => {
                  const upcoming = ep.air_date && new Date(ep.air_date) > new Date();
                  return (
                    <SelectItem 
                      key={ep.id} 
                      value={String(ep.episode_number)} 
                      disabled={upcoming}
                    >
                      Episode {ep.episode_number}: {ep.name}
                      {upcoming && ` (Airs ${new Date(ep.air_date).toLocaleDateString()})`}
                    </SelectItem>
                  );
                })}
              </SelectContent>
            </Select>
          </div>
        )}
      </div>
      
      {episodes.length > 0 && !isSeasonUpcoming && (
        <div className="mt-4 p-3 bg-muted/20 rounded-lg">
          <p className="text-sm text-muted-foreground">
            {episodes.length} episode{episodes.length > 1 ? 's' : ''} available in this season
          </p>
        </div>
      )}
    </div>
  );
}
