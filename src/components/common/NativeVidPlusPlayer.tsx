import React from 'react';
import { VideoServerType } from '@/lib/video-servers';

type NativeVidPlusPlayerProps = {
  mediaId: number;
  mediaType: 'movie' | 'tv';
  season?: number;
  episode?: number;
};

export function NativeVidPlusPlayer({ 
  mediaId, 
  mediaType, 
  season = 1, 
  episode = 1 
}: NativeVidPlusPlayerProps) {
  
  const getVidPlusUrl = () => {
    const baseUrl = 'https://player.vidplus.to/embed';
    
    if (mediaType === 'movie') {
      return `${baseUrl}/movie/${mediaId}`;
    } else {
      return `${baseUrl}/tv/${mediaId}/${season}/${episode}`;
    }
  };

  return (
    <div className="w-full aspect-video bg-black">
      <iframe
        src={getVidPlusUrl()}
        className="w-full h-full border-0"
        allowFullScreen
        allow="autoplay; encrypted-media; picture-in-picture; fullscreen"
      />
    </div>
  );
}
