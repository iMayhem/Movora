'use client';

import {
  Dialog,
  DialogContent,
} from '@/components/ui/dialog';

type VideoPlayerProps = {
  isOpen: boolean;
  onClose: () => void;
  videoKey?: string;
};

export function VideoPlayer({ isOpen, onClose, videoKey }: VideoPlayerProps) {
  if (!videoKey) {
    return null;
  }

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="max-w-3xl p-0 bg-black border-0">
        <div className="aspect-video">
          <iframe
            src={`https://www.youtube.com/embed/${videoKey}?autoplay=1`}
            title="YouTube video player"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowFullScreen
            className="w-full h-full border-0"
          ></iframe>
        </div>
      </DialogContent>
    </Dialog>
  );
}