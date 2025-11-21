'use client';

import { Play, X, Maximize2 } from 'lucide-react';
import Image from 'next/image';
import { Skeleton } from '../ui/skeleton';
import { Dialog, DialogContent, DialogTrigger, DialogClose, DialogOverlay } from '@/components/ui/dialog';
import { useState } from 'react';
import { cn } from '@/lib/utils';

type VideoPlayerProps = {
  mediaId?: number;
  mediaType?: 'movie' | 'tv';
  season?: number;
  episode?: number;
  posterPath?: string | null;
};

export function VideoPlayer({ mediaId, mediaType, season = 1, episode = 1, posterPath }: VideoPlayerProps) {
  const [isOpen, setIsOpen] = useState(false);

  if (!mediaId || !mediaType) {
    return <Skeleton className="w-full aspect-video rounded-xl bg-white/5" />;
  }

  const src = mediaType === 'movie'
    ? `https://player.vidplus.to/embed/movie/${mediaId}`
    : `https://player.vidplus.to/embed/tv/${mediaId}/${season}/${episode}`;

  return (
    <Dialog open={isOpen} onOpenChange={setIsOpen}>
      <DialogTrigger asChild>
        <div 
          className="w-full aspect-video relative cursor-pointer group overflow-hidden rounded-xl bg-black shadow-2xl ring-1 ring-white/10"
        >
          {posterPath && (
            <Image
              src={`https://image.tmdb.org/t/p/original${posterPath}`}
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
         {/* Header inside modal */}
         <div className="absolute top-0 right-0 z-50 p-4">
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