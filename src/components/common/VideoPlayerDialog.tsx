
'use client';

import { createContext, useContext, useState, ReactNode } from 'react';
import {
  Dialog,
  DialogContent,
  DialogTitle,
} from '@/components/ui/dialog';
import { VideoPlayer } from './VideoPlayer';

type VideoPlayerContextType = {
  mediaId: number;
  mediaType: 'movie' | 'tv';
  season?: number;
  episode?: number;
  setSeason: (season: number) => void;
  setEpisode: (episode: number) => void;
  isPlayable: boolean;
  setIsPlayable: (playable: boolean) => void;
};

const VideoPlayerContext = createContext<VideoPlayerContextType | null>(null);

export function useVideoPlayer() {
  const context = useContext(VideoPlayerContext);
  if (!context) {
    throw new Error('useVideoPlayer must be used within a VideoPlayerDialog');
  }
  return context;
}

type VideoPlayerDialogProps = {
  children: ReactNode;
  mediaId: number;
  mediaType: 'movie' | 'tv';
};

export function VideoPlayerDialog({ children, mediaId, mediaType }: VideoPlayerDialogProps) {
  const [season, setSeason] = useState(1);
  const [episode, setEpisode] = useState(1);
  const [isPlayable, setIsPlayable] = useState(mediaType === 'movie');

  return (
    <VideoPlayerContext.Provider value={{ mediaId, mediaType, season, episode, setSeason, setEpisode, isPlayable, setIsPlayable }}>
      <Dialog>
        {children}
        <DialogContent className="max-w-4xl p-0 bg-black border-0">
          <DialogTitle className="sr-only">VIDEASY Player</DialogTitle>
          <VideoPlayer mediaId={mediaId} mediaType={mediaType} season={season} episode={episode} />
        </DialogContent>
      </Dialog>
    </VideoPlayerContext.Provider>
  );
}
