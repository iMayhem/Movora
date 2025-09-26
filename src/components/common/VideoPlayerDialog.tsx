
'use client';

import { createContext, useContext, useState, ReactNode, useEffect, useRef } from 'react';
import {
  Dialog,
  DialogContent,
  DialogTitle,
} from '@/components/ui/dialog';
import { VideoPlayer } from './VideoPlayer';
import { ServerSelector } from './ServerSelector';
import { useIsMobile } from '@/hooks/use-mobile';
import { VideoServerType } from '@/lib/video-servers';


type VideoPlayerContextType = {
  mediaId: number;
  mediaType: 'movie' | 'tv';
  season?: number;
  episode?: number;
  setSeason: (season: number) => void;
  setEpisode: (episode: number) => void;
  isPlayable: boolean;
  setIsPlayable: (playable: boolean) => void;
  currentServer: VideoServerType;
  setCurrentServer: (server: VideoServerType) => void;
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
  const [open, setOpen] = useState(false);
  const [season, setSeason] = useState(1);
  const [episode, setEpisode] = useState(1);
  const [isPlayable, setIsPlayable] = useState(mediaType === 'movie');
  const [currentServer, setCurrentServer] = useState<VideoServerType>(VideoServerType.VIDPLUS);
  const isMobile = useIsMobile();
  const dialogContentRef = useRef<HTMLDivElement>(null);


  useEffect(() => {
    const enterFullscreen = async () => {
        if (dialogContentRef.current) {
            try {
                await dialogContentRef.current.requestFullscreen();
            } catch (error) {
                console.warn("Fullscreen request failed:", error);
            }
        }
    };
  
    const exitFullscreen = () => {
        if (document.fullscreenElement) {
            document.exitFullscreen().catch(err => console.warn("Could not exit fullscreen:", err));
        }
    };

    if (isMobile) {
      if (open) {
        screen.orientation.lock('landscape').catch(() => {});
        enterFullscreen();
      } else {
        screen.orientation.unlock();
        exitFullscreen();
      }
    }

    const handleFullscreenChange = () => {
        if (!document.fullscreenElement) {
            setOpen(false);
        }
    };

    document.addEventListener('fullscreenchange', handleFullscreenChange);
    
    return () => {
        document.removeEventListener('fullscreenchange', handleFullscreenChange);
        if (isMobile) {
            try {
                screen.orientation.unlock();
                exitFullscreen();
            }
            catch (error) {
                // Ignore errors on cleanup
            }
        }
    }
  }, [open, isMobile]);

  return (
    <VideoPlayerContext.Provider
      value={{
        mediaId,
        mediaType,
        season,
        episode,
        setSeason,
        setEpisode,
        isPlayable,
        setIsPlayable,
        currentServer,
        setCurrentServer,
      }}
    >
      <Dialog open={open} onOpenChange={setOpen}>
        {children}
        <DialogContent 
            ref={dialogContentRef}
            className="max-w-4xl w-full h-full p-0 bg-black border-0"
            hideCloseButton={isMobile}
        >
          <DialogTitle className="sr-only">Video Player</DialogTitle>
          <div className="relative w-full h-full">
            <VideoPlayer mediaId={mediaId} mediaType={mediaType} season={season} episode={episode} />
          </div>
        </DialogContent>
      </Dialog>
    </VideoPlayerContext.Provider>
  );
}
