
'use client';

import { useVideoPlayer } from './VideoPlayerDialog';
import { Button } from '@/components/ui/button';
import { PlayCircle } from 'lucide-react';
import { DialogTrigger } from '@/components/ui/dialog';

export function PlayerDialogButton() {
  const { isPlayable } = useVideoPlayer();
  return (
    <DialogTrigger asChild>
      <Button size="lg" disabled={!isPlayable}>
        <PlayCircle className="mr-2" />
        Watch Now
      </Button>
    </DialogTrigger>
  );
}
