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
  
  const src = mediaType === 'movie' 
    ? `https://player.videasy.net/movie/${mediaId}`
    : `https://player.videasy.net/tv/${mediaId}/${season}/${episode}`;

  return (
    <div className="w-full" style={{ position: 'relative', paddingBottom: '56.25%', height: 0 }}>
      <iframe
        key={`${mediaId}-${season}-${episode}`}
        src={src}
        title="VIDEASY Player"
        sandbox="allow-scripts allow-same-origin"
        allow="autoplay; encrypted-media; picture-in-picture"
        allowFullScreen
        className="w-full h-full border-0"
        style={{ position: 'absolute', top: 0, left: 0, width: '100%', height: '100%' }}
      ></iframe>
    </div>
  );
}
