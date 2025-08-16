'use client';

import { useWatchLater } from '@/hooks/useWatchLater';
import { Button } from '@/components/ui/button';
import { Bookmark } from 'lucide-react';
import type { Media } from '@/types/tmdb';

type WatchLaterButtonProps = {
  item: Media;
};

export function WatchLaterButton({ item }: WatchLaterButtonProps) {
  const { addToWatchLater, removeFromWatchLater, isInWatchLater, isClient } = useWatchLater();

  if (!isClient) {
    return (
      <Button size="icon" variant="secondary" disabled className="rounded-full">
        <Bookmark />
      </Button>
    );
  }

  const isSaved = isInWatchLater(item.id, item.media_type);

  const handleClick = (e: React.MouseEvent<HTMLButtonElement>) => {
    e.preventDefault();
    if (isSaved) {
      removeFromWatchLater(item.id, item.media_type);
    } else {
      addToWatchLater(item);
    }
  };

  return (
    <Button
      onClick={handleClick}
      size="icon"
      variant={isSaved ? "primary" : "secondary"}
      className="rounded-full bg-black/50 hover:bg-black/70 border-0 text-white"
    >
      <Bookmark className={isSaved ? 'fill-current' : ''} />
      <span className="sr-only">{isSaved ? 'Remove from Watch Later' : 'Add to Watch Later'}</span>
    </Button>
  );
}
