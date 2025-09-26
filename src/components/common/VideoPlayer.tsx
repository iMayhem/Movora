import React from 'react';
import { NativeVidPlusPlayer } from './NativeVidPlusPlayer';

type VideoPlayerProps = {
  mediaId?: number;
  mediaType?: 'movie' | 'tv';
  season?: number;
  episode?: number;
};

export function VideoPlayer({ mediaId, mediaType, season = 1, episode = 1 }: VideoPlayerProps) {
  if (!mediaId || !mediaType) {
    return (
      <div className="w-full aspect-video bg-black flex items-center justify-center text-white">
        Select a movie or episode to play.
      </div>
    );
  }

  return (
    <NativeVidPlusPlayer
      mediaId={mediaId}
      mediaType={mediaType}
      season={season}
      episode={episode}
    />
  );
}
