'use client';

import { Play, X, Maximize2 } from 'lucide-react';
import Image from 'next/image';
import { Skeleton } from '../ui/skeleton';
import { Dialog, DialogContent, DialogTrigger, DialogClose } from '@/components/ui/dialog';
import { useState } from 'react';
import { cn } from '@/lib/utils';

type VideoPlayerProps = {
  mediaId?: number;
  mediaType?: 'movie' | 'tv';
  season?: number;
  episode?: number;
  posterPath?: string | null;
};

type PlayerKey = 'vidplus' | 'videasy' | 'vidsrc';

export function VideoPlayer({ mediaId, mediaType, season = 1, episode = 1, posterPath }: VideoPlayerProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [selectedPlayer, setSelectedPlayer] = useState<PlayerKey>('vidplus');

  if (!mediaId || !mediaType) {
    return <Skeleton className="w-full aspect-video rounded-xl bg-white/5" />;
  }

  const playerSources: Record<PlayerKey, string> = {
    vidplus: mediaType === 'movie'
      ? `https://player.vidplus.to/embed/movie/${mediaId}`
      : `https://player.vidplus.to/embed/tv/${mediaId}/${season}/${episode}`,
    videasy: mediaType === 'movie'
      ? `https://player.videasy.net/movie/${mediaId}`
      : `https://player.videasy.net/tv/${mediaId}/${season}/${episode}?nextEpisode=true&autoplayNextEpisode=true&episodeSelector=true`,
    vidsrc: mediaType === 'movie'
      ? `https://vidsrc-embed.ru/embed/movie?tmdb=${mediaId}&autoplay=1`
      : `https://vidsrc-embed.ru/embed/tv?tmdb=${mediaId}&season=${season}&episode=${episode}&autoplay=1&autonext=1`,
  };

  const src = playerSources[selectedPlayer];
  const posterSrc = posterPath
    ? `https://images.weserv.nl/?url=${encodeURIComponent(`image.tmdb.org/t/p/original${posterPath}`)}&w=1600&h=900&fit=cover&output=webp&q=80`
    : null;

  return (
    <Dialog open={isOpen} onOpenChange={setIsOpen}>
      <DialogTrigger asChild>
        <div
          className="w-full aspect-video relative cursor-pointer group overflow-hidden rounded-xl bg-black shadow-2xl ring-1 ring-white/10"
        >
          {posterSrc && (
            <Image
              src={posterSrc}
              alt="Video thumbnail"
              fill
              sizes="100vw"
              className="object-cover opacity-40 group-hover:opacity-30 group-hover:scale-105 transition-all duration-700 ease-out"
            />
          )}

          <div className="absolute inset-0 flex flex-col items-center justify-center">
            <div className="w-20 h-20 rounded-full bg-white/10 backdrop-blur-sm flex items-center justify-center border border-white/20 group-hover:scale-110 group-hover:bg-primary group-hover:border-primary transition-all duration-300 shadow-lg">
              <Play className="w-8 h-8 text-white fill-white ml-1" />
            </div>
            <p className="mt-4 text-sm font-medium tracking-wider uppercase text-white/70 group-hover:text-white transition-colors">
              Play Now
            </p>
          </div>
          <div className="absolute bottom-4 right-4 bg-black/80 text-white text-xs px-2 py-1 rounded border border-white/10 flex items-center gap-1">
            <Maximize2 className="w-3 h-3" /> Click to Expand
          </div>
        </div>
      </DialogTrigger>

      <DialogContent className="max-w-screen-xl w-[95vw] h-[80vh] p-0 bg-black border-none shadow-2xl flex flex-col">
        <div className="absolute top-0 right-0 z-50 p-4 flex items-center gap-2">
          <div className="flex items-center gap-1 rounded-full border border-white/20 bg-black/50 p-1 backdrop-blur-md">
            <button
              type="button"
              onClick={() => setSelectedPlayer('vidplus')}
              className={cn(
                'rounded-full px-3 py-1 text-xs font-medium transition-colors',
                selectedPlayer === 'vidplus'
                  ? 'bg-primary text-primary-foreground'
                  : 'text-white/80 hover:bg-white/10 hover:text-white',
              )}
            >
              VidPlus
            </button>
            <button
              type="button"
              onClick={() => setSelectedPlayer('videasy')}
              className={cn(
                'rounded-full px-3 py-1 text-xs font-medium transition-colors',
                selectedPlayer === 'videasy'
                  ? 'bg-primary text-primary-foreground'
                  : 'text-white/80 hover:bg-white/10 hover:text-white',
              )}
            >
              VIDEASY
            </button>
            <button
              type="button"
              onClick={() => setSelectedPlayer('vidsrc')}
              className={cn(
                'rounded-full px-3 py-1 text-xs font-medium transition-colors',
                selectedPlayer === 'vidsrc'
                  ? 'bg-primary text-primary-foreground'
                  : 'text-white/80 hover:bg-white/10 hover:text-white',
              )}
            >
              VIDSRC
            </button>
          </div>
          <DialogClose className="bg-black/50 hover:bg-white/20 text-white rounded-full p-2 backdrop-blur-md transition-colors">
            <X className="w-6 h-6" />
          </DialogClose>
        </div>

        <div className="w-full h-full relative bg-black">
          <iframe
            src={src}
            className="w-full h-full rounded-md"
            frameBorder="0"
            allowFullScreen
            allow="autoplay; encrypted-media"
            title="Video Player"
          ></iframe>
        </div>
      </DialogContent>
    </Dialog>
  );
}
