'use client';

import {
  Dialog,
  DialogContent,
} from '@/components/ui/dialog';

type VideoPlayerProps = {
  isOpen: boolean;
  onClose: () => void;
  mediaId?: number;
  mediaType?: 'movie' | 'tv';
};

export function VideoPlayer({ isOpen, onClose, mediaId, mediaType }: VideoPlayerProps) {
  if (!mediaId || !mediaType) {
    return null;
  }
  
  const src = mediaType === 'movie' 
    ? `https://player.videasy.net/movie/${mediaId}`
    : `https://player.videasy.net/tv/${mediaId}/1/1`;

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="max-w-4xl p-0 bg-black border-0">
        <div style={{ position: 'relative', paddingBottom: '56.25%', height: 0 }}>
          <iframe
            src={src}
            title="VIDEASY Player"
            allow="autoplay; encrypted-media; picture-in-picture"
            allowFullScreen
            className="w-full h-full border-0"
            style={{ position: 'absolute', top: 0, left: 0, width: '100%', height: '100%' }}
          ></iframe>
        </div>
      </DialogContent>
    </Dialog>
  );
}
