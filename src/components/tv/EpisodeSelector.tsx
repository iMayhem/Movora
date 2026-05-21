'use client';
import { useState, useEffect } from 'react';
import { getSeasonDetails } from '@/lib/tmdb';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Label } from '@/components/ui/label';
import type { Season, Episode } from '@/types/tmdb';
import { VideoPlayer } from '@/components/common/VideoPlayer';

export function EpisodeSelector({ 
  tvId, 
  seasons, 
  title, 
  posterPath 
}: { 
  tvId: number; 
  seasons: Season[]; 
  title?: string; 
  posterPath?: string | null;
}) {
  const [selectedSeason, setSelectedSeasonState] = useState<number | undefined>(seasons.length > 0 ? seasons[0].season_number : undefined);
  const [selectedEpisode, setSelectedEpisodeState] = useState<number | undefined>(undefined);
  const [episodes, setEpisodes] = useState<Episode[]>([]);

  useEffect(() => {
    const fetchSeasonData = async () => {
      if (selectedSeason === undefined) return;
      const seasonDetails = await getSeasonDetails(tvId, selectedSeason);
      const fetchedEpisodes = seasonDetails?.episodes || [];
      setEpisodes(fetchedEpisodes);
      setSelectedEpisodeState(fetchedEpisodes.length > 0 ? fetchedEpisodes[0].episode_number : undefined);
    };
    fetchSeasonData();
  }, [tvId, selectedSeason]);

  // Generate dynamic title representing the selected episode
  const activeEpisode = episodes.find(e => e.episode_number === selectedEpisode);
  const playTitle = activeEpisode 
    ? `${title || 'TV Show'} - S${selectedSeason}E${selectedEpisode}: ${activeEpisode.name}`
    : `${title || 'TV Show'} - Season ${selectedSeason} Episode ${selectedEpisode}`;

  return (
    <div className="bg-white/5 backdrop-blur-sm rounded-xl p-6 border border-white/10">
      <h3 className="text-xl font-semibold mb-6">Watch Episodes</h3>
      <div className="grid grid-cols-1 sm:grid-cols-2 gap-6 mb-8">
            <div className="space-y-2">
                <Label className="text-muted-foreground">Season</Label>
                <Select value={String(selectedSeason)} onValueChange={(v) => setSelectedSeasonState(Number(v))}>
                    <SelectTrigger className="bg-black/50 border-white/10"><SelectValue /></SelectTrigger>
                    <SelectContent>{seasons.map(s => <SelectItem key={s.id} value={String(s.season_number)}>{s.name}</SelectItem>)}</SelectContent>
                </Select>
            </div>
            <div className="space-y-2">
                <Label className="text-muted-foreground">Episode</Label>
                <Select value={String(selectedEpisode)} onValueChange={(v) => setSelectedEpisodeState(Number(v))} disabled={!episodes.length}>
                    <SelectTrigger className="bg-black/50 border-white/10"><SelectValue /></SelectTrigger>
                    <SelectContent>{episodes.map(e => <SelectItem key={e.id} value={String(e.episode_number)}>Ep {e.episode_number}: {e.name}</SelectItem>)}</SelectContent>
                </Select>
            </div>
      </div>
      <div className="flex justify-end">
        {selectedSeason !== undefined && selectedEpisode !== undefined && (
          <VideoPlayer 
            mediaId={tvId}
            mediaType="tv"
            season={selectedSeason}
            episode={selectedEpisode}
            posterPath={posterPath}
            title={playTitle}
          />
        )}
      </div>
    </div>
  );
}