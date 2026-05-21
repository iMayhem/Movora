'use client';

import { 
  Play, Pause, Volume2, VolumeX, Maximize2, Minimize2, X, AlertCircle, 
  Download, RefreshCw, Loader2, Info, Film, RotateCcw, RotateCw, Subtitles, Settings, Check
} from 'lucide-react';
import Image from 'next/image';
import { Skeleton } from '../ui/skeleton';
import { Dialog, DialogContent, DialogTrigger, DialogClose, DialogTitle } from '@/components/ui/dialog';
import { useState, useRef, useEffect } from 'react';
import { cn } from '@/lib/utils';
import { getCurrentUser, addToHistory } from '@/lib/auth';

type VideoPlayerProps = {
  mediaId?: number;
  mediaType?: 'movie' | 'tv';
  season?: number;
  episode?: number;
  posterPath?: string | null;
  title?: string;
};

type PlayerKey = 'vidplus' | 'videasy' | 'vidsrc' | 'moviebox';

export function VideoPlayer({ mediaId, mediaType, season = 1, episode = 1, posterPath, title }: VideoPlayerProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [selectedPlayer, setSelectedPlayer] = useState<PlayerKey>('vidplus');
  const [movieboxData, setMovieboxData] = useState<{
    streamUrl: string | null;
    subtitles: { label: string; src: string; lang: string }[];
    options: { label: string; url: string }[];
  } | null>(null);
  const [isResolving, setIsResolving] = useState(false);
  const [resolveError, setResolveError] = useState<string | null>(null);

  // Modern Netflix player controls state
  const videoRef = useRef<HTMLVideoElement>(null);
  const playerContainerRef = useRef<HTMLDivElement>(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [currentTime, setCurrentTime] = useState(0);
  const [duration, setDuration] = useState(0);
  const [volume, setVolume] = useState(1);
  const [isMuted, setIsMuted] = useState(false);
  const [isFullscreen, setIsFullscreen] = useState(false);
  const [playbackRate, setPlaybackRate] = useState(1);
  const [activeSubtitle, setActiveSubtitle] = useState<string>('disabled'); // language code or 'disabled'
  const [isBuffering, setIsBuffering] = useState(false);
  const [showControls, setShowControls] = useState(true);
  const [showVolumeSlider, setShowVolumeSlider] = useState(false);
  const [showSettingsPanel, setShowSettingsPanel] = useState(false); // Netflix-like Audio & Subtitles overlay
  const [playActionToast, setPlayActionToast] = useState<'play' | 'pause' | null>(null);

  const controlsTimeoutRef = useRef<NodeJS.Timeout | null>(null);

  const fetchMoviebox = async () => {
    if (!title || isResolving) return;
    setIsResolving(true);
    setResolveError(null);
    try {
      const url = `/api/moviebox?title=${encodeURIComponent(title)}&type=${mediaType}&season=${season}&episode=${episode}`;
      const res = await fetch(url);
      if (!res.ok) {
        throw new Error('Failed to resolve stream link from Moviebox.');
      }
      const data = await res.json();
      setMovieboxData(data);
      
      // Auto-enable English captions if available
      if (data.subtitles && data.subtitles.length > 0) {
        const hasEn = data.subtitles.some((sub: any) => sub.lang === 'en');
        if (hasEn) {
          setActiveSubtitle('en');
          // Give text tracks time to bind, then enable it
          setTimeout(() => {
            if (videoRef.current) {
              const tracks = videoRef.current.textTracks;
              for (let i = 0; i < tracks.length; i++) {
                tracks[i].mode = tracks[i].language === 'en' ? 'showing' : 'disabled';
              }
            }
          }, 500);
        }
      }
    } catch (err: any) {
      setResolveError(err.message || 'Stream link resolution failed.');
    } finally {
      setIsResolving(false);
    }
  };

  const getStreamUrlWithProxy = () => {
    if (!movieboxData || !movieboxData.streamUrl) return '';
    if (typeof window === 'undefined') return movieboxData.streamUrl;
    const proxy = 'https://proxy.moovie.fun/';
    return `${proxy}${encodeURIComponent(movieboxData.streamUrl)}`;
  };

  const getSubUrlWithProxy = (subUrl: string) => {
    if (!subUrl) return '';
    if (typeof window === 'undefined') return subUrl;
    const proxy = 'https://proxy.moovie.fun/';
    return `${proxy}${encodeURIComponent(subUrl)}`;
  };

  const handlePlayerSelect = (player: PlayerKey) => {
    setSelectedPlayer(player);
    if (player === 'moviebox' && !movieboxData) {
      fetchMoviebox();
    }
  };

  const handleOpenChange = (open: boolean) => {
    setIsOpen(open);
    if (open) {
      if (mediaId && mediaType) {
        const currentUser = getCurrentUser();
        if (currentUser) {
          addToHistory(currentUser, {
            id: mediaId,
            title: title || 'Media Item',
            poster_path: posterPath || null,
            media_type: mediaType,
          });
        }
      }
      if (selectedPlayer === 'moviebox') {
        fetchMoviebox();
      }
    } else {
      setMovieboxData(null);
      setResolveError(null);
      setIsPlaying(false);
      setCurrentTime(0);
      setDuration(0);
      setPlaybackRate(1);
      setActiveSubtitle('disabled');
      setShowSettingsPanel(false);
    }
  };

  // Autohide controls utility
  const resetControlsTimeout = () => {
    setShowControls(true);
    if (controlsTimeoutRef.current) {
      clearTimeout(controlsTimeoutRef.current);
    }
    controlsTimeoutRef.current = setTimeout(() => {
      if (isPlaying && !showSettingsPanel) {
        setShowControls(false);
      }
    }, 3000);
  };

  const handleMouseMove = () => {
    resetControlsTimeout();
  };

  // Custom player events and triggers
  const togglePlay = (e?: React.MouseEvent) => {
    if (e) {
      e.stopPropagation();
      // If clicking inside controls, ignore
      const target = e.target as HTMLElement;
      if (target.closest('.player-controls-bar') || target.closest('.settings-overlay-panel')) return;
    }
    if (!videoRef.current) return;
    
    if (isPlaying) {
      videoRef.current.pause();
      setPlayActionToast('pause');
    } else {
      videoRef.current.play().catch(() => {});
      setPlayActionToast('play');
    }
    setIsPlaying(!isPlaying);
    setTimeout(() => setPlayActionToast(null), 800);
    resetControlsTimeout();
  };

  const handleTimeUpdate = () => {
    if (!videoRef.current) return;
    setCurrentTime(videoRef.current.currentTime);
  };

  const handleLoadedMetadata = () => {
    if (!videoRef.current) return;
    setDuration(videoRef.current.duration);
  };

  const handleSeek = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (!videoRef.current) return;
    const time = parseFloat(e.target.value);
    videoRef.current.currentTime = time;
    setCurrentTime(time);
    resetControlsTimeout();
  };

  const handleVolumeChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (!videoRef.current) return;
    const vol = parseFloat(e.target.value);
    videoRef.current.volume = vol;
    setVolume(vol);
    if (vol === 0) {
      setIsMuted(true);
      videoRef.current.muted = true;
    } else {
      setIsMuted(false);
      videoRef.current.muted = false;
    }
    resetControlsTimeout();
  };

  const toggleMute = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (!videoRef.current) return;
    const muted = !isMuted;
    videoRef.current.muted = muted;
    setIsMuted(muted);
    resetControlsTimeout();
  };

  const skipForward = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (!videoRef.current) return;
    videoRef.current.currentTime = Math.min(videoRef.current.duration || 0, videoRef.current.currentTime + 10);
    resetControlsTimeout();
  };

  const skipBackward = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (!videoRef.current) return;
    videoRef.current.currentTime = Math.max(0, videoRef.current.currentTime - 10);
    resetControlsTimeout();
  };

  const handleSpeedChange = (rate: number) => {
    if (!videoRef.current) return;
    videoRef.current.playbackRate = rate;
    setPlaybackRate(rate);
    resetControlsTimeout();
  };

  const handleSubtitleChange = (lang: string) => {
    if (!videoRef.current) return;
    setActiveSubtitle(lang);

    const tracks = videoRef.current.textTracks;
    for (let i = 0; i < tracks.length; i++) {
      if (lang === 'disabled') {
        tracks[i].mode = 'disabled';
      } else {
        tracks[i].mode = tracks[i].language === lang ? 'showing' : 'disabled';
      }
    }
    resetControlsTimeout();
  };

  const toggleFullscreen = (e?: React.MouseEvent) => {
    if (e) e.stopPropagation();
    if (!playerContainerRef.current) return;
    if (!document.fullscreenElement) {
      playerContainerRef.current.requestFullscreen().catch(() => {});
      setIsFullscreen(true);
    } else {
      document.exitFullscreen().catch(() => {});
      setIsFullscreen(false);
    }
    resetControlsTimeout();
  };

  useEffect(() => {
    const handleFullscreenChange = () => {
      setIsFullscreen(!!document.fullscreenElement);
    };
    document.addEventListener('fullscreenchange', handleFullscreenChange);
    return () => document.removeEventListener('fullscreenchange', handleFullscreenChange);
  }, []);

  // Keyboard controls listener
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (!isOpen || selectedPlayer !== 'moviebox' || !videoRef.current) return;
      
      const tag = document.activeElement?.tagName.toLowerCase();
      if (tag === 'input' || tag === 'textarea' || tag === 'button') return;

      switch (e.key.toLowerCase()) {
        case ' ':
          e.preventDefault();
          if (isPlaying) {
            videoRef.current.pause();
            setIsPlaying(false);
            setPlayActionToast('pause');
          } else {
            videoRef.current.play().catch(() => {});
            setIsPlaying(true);
            setPlayActionToast('play');
          }
          setTimeout(() => setPlayActionToast(null), 800);
          resetControlsTimeout();
          break;
        case 'arrowleft':
          e.preventDefault();
          videoRef.current.currentTime = Math.max(0, videoRef.current.currentTime - 10);
          resetControlsTimeout();
          break;
        case 'arrowright':
          e.preventDefault();
          videoRef.current.currentTime = Math.min(videoRef.current.duration || 0, videoRef.current.currentTime + 10);
          resetControlsTimeout();
          break;
        case 'arrowup':
          e.preventDefault();
          const newVolUp = Math.min(1, videoRef.current.volume + 0.05);
          videoRef.current.volume = newVolUp;
          setVolume(newVolUp);
          resetControlsTimeout();
          break;
        case 'arrowdown':
          e.preventDefault();
          const newVolDown = Math.max(0, videoRef.current.volume - 0.05);
          videoRef.current.volume = newVolDown;
          setVolume(newVolDown);
          resetControlsTimeout();
          break;
        case 'm':
          e.preventDefault();
          const nextMuted = !isMuted;
          videoRef.current.muted = nextMuted;
          setIsMuted(nextMuted);
          resetControlsTimeout();
          break;
        case 'f':
          e.preventDefault();
          toggleFullscreen();
          break;
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [isOpen, selectedPlayer, isPlaying, isMuted, volume]);

  // Clean controls timer on unmount
  useEffect(() => {
    return () => {
      if (controlsTimeoutRef.current) {
        clearTimeout(controlsTimeoutRef.current);
      }
    };
  }, []);

  const formatTime = (seconds: number) => {
    if (isNaN(seconds) || seconds === Infinity) return '00:00';
    const hrs = Math.floor(seconds / 3600);
    const mins = Math.floor((seconds % 3600) / 60);
    const secs = Math.floor(seconds % 60);
    if (hrs > 0) {
      return `${hrs}:${String(mins).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
    }
    return `${String(mins).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
  };

  if (!mediaId || !mediaType) {
    return <Skeleton className="w-full aspect-video rounded-xl bg-white/5" />;
  }

  const playerSources: Record<Exclude<PlayerKey, 'moviebox'>, string> = {
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

  const src = selectedPlayer !== 'moviebox' ? playerSources[selectedPlayer] : '';
  const posterSrc = posterPath
    ? `https://images.weserv.nl/?url=${encodeURIComponent(`image.tmdb.org/t/p/original${posterPath}`)}&w=1600&h=900&fit=cover&output=webp&q=80`
    : null;

  return (
    <Dialog open={isOpen} onOpenChange={handleOpenChange}>
      <DialogTrigger asChild>
        <div className="w-full aspect-video relative cursor-pointer group overflow-hidden rounded-xl bg-black shadow-2xl ring-1 ring-white/10">
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

      <DialogContent className="max-w-screen-xl w-[95vw] h-[80vh] p-0 bg-black border-none shadow-2xl flex flex-col overflow-hidden">
        <DialogTitle className="sr-only">Video Player - {title}</DialogTitle>
        
        {/* Sleek Floating Top Switcher */}
        <div className="absolute top-0 right-0 z-50 p-4 flex items-center gap-2">
          <div className="flex items-center gap-1 rounded-full border border-white/10 bg-zinc-950/40 p-1 backdrop-blur-md">
            <button
              type="button"
              onClick={() => handlePlayerSelect('vidplus')}
              className={cn(
                'rounded-full px-3 py-1.5 text-xs font-semibold tracking-wide transition-all',
                selectedPlayer === 'vidplus'
                  ? 'bg-white text-black shadow-md'
                  : 'text-zinc-300 hover:text-white hover:bg-white/10',
              )}
            >
              VidPlus
            </button>
            <button
              type="button"
              onClick={() => handlePlayerSelect('videasy')}
              className={cn(
                'rounded-full px-3 py-1.5 text-xs font-semibold tracking-wide transition-all',
                selectedPlayer === 'videasy'
                  ? 'bg-white text-black shadow-md'
                  : 'text-zinc-300 hover:text-white hover:bg-white/10',
              )}
            >
              VIDEASY
            </button>
            <button
              type="button"
              onClick={() => handlePlayerSelect('vidsrc')}
              className={cn(
                'rounded-full px-3 py-1.5 text-xs font-semibold tracking-wide transition-all',
                selectedPlayer === 'vidsrc'
                  ? 'bg-white text-black shadow-md'
                  : 'text-zinc-300 hover:text-white hover:bg-white/10',
              )}
            >
              VIDSRC
            </button>
            <button
              type="button"
              onClick={() => handlePlayerSelect('moviebox')}
              className={cn(
                'rounded-full px-3 py-1.5 text-xs font-semibold tracking-wide transition-all relative overflow-hidden',
                selectedPlayer === 'moviebox'
                  ? 'bg-[#E50914] text-white shadow-md'
                  : 'text-red-400 hover:text-red-300 hover:bg-red-950/20 border border-red-500/20',
              )}
            >
              <span className="flex items-center gap-1.5">
                Moviebox <span className="text-[9px] bg-black/40 px-1 py-0.5 rounded text-white font-bold uppercase tracking-widest">Direct</span>
              </span>
            </button>
          </div>
          <DialogClose className="bg-zinc-950/40 hover:bg-white/20 text-white rounded-full p-2.5 backdrop-blur-md transition-colors border border-white/5">
            <X className="w-5 h-5" />
          </DialogClose>
        </div>

        <div className="w-full h-full relative bg-black flex-1">
          {selectedPlayer !== 'moviebox' ? (
            <iframe
              src={src}
              className="w-full h-full rounded-md"
              frameBorder="0"
              allowFullScreen
              allow="autoplay; encrypted-media"
              title="Video Player"
            ></iframe>
          ) : (
            <div className="w-full h-full flex flex-col justify-between bg-black rounded-md overflow-hidden relative">
              
              {/* Dynamic Overlay Styling for Subtitles & Cue Controls */}
              <style>{`
                /* Beautiful High-Contrast Netflix Subtitles Styling */
                video::cue {
                  background-color: rgba(0, 0, 0, 0.75) !important;
                  color: #ffffff !important;
                  font-size: 1.1em !important;
                  font-family: 'Helvetica Neue', Arial, sans-serif !important;
                  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.9) !important;
                  padding: 4px 10px !important;
                  border-radius: 4px !important;
                  line-height: 1.4 !important;
                }
                
                /* Netflix Red Range slider thumb & styling */
                .netflix-slider::-webkit-slider-thumb {
                  -webkit-appearance: none;
                  appearance: none;
                  width: 14px;
                  height: 14px;
                  border-radius: 50%;
                  background: #E50914;
                  cursor: pointer;
                  transition: transform 0.15s ease;
                }
                .netflix-slider:hover::-webkit-slider-thumb {
                  transform: scale(1.3);
                }
                .netflix-slider::-moz-range-thumb {
                  width: 14px;
                  height: 14px;
                  border-radius: 50%;
                  background: #E50914;
                  border: none;
                  cursor: pointer;
                  transition: transform 0.15s ease;
                }
                .netflix-slider:hover::-moz-range-thumb {
                  transform: scale(1.3);
                }
                .netflix-volume-slider::-webkit-slider-thumb {
                  width: 10px;
                  height: 10px;
                  background: #ffffff;
                }
                .netflix-volume-slider::-moz-range-thumb {
                  width: 10px;
                  height: 10px;
                  background: #ffffff;
                }
                .controls-fade-enter { opacity: 0; }
                .controls-fade-enter-active { opacity: 1; transition: opacity 0.3s ease; }
                .controls-fade-exit { opacity: 1; }
                .controls-fade-exit-active { opacity: 0; transition: opacity 0.3s ease; }
              `}</style>

              {isResolving && (
                <div className="absolute inset-0 flex flex-col items-center justify-center bg-black/90 z-45 gap-4 text-center p-6">
                  <Loader2 className="w-12 h-12 text-[#E50914] animate-spin" />
                  <div>
                    <h4 className="text-white font-medium text-lg tracking-wide">Resolving Stream</h4>
                    <p className="text-zinc-500 text-sm max-w-sm mt-1">Scraping high-speed direct streams and WebVTT captions...</p>
                  </div>
                </div>
              )}

              {resolveError && (
                <div className="absolute inset-0 flex flex-col items-center justify-center bg-black/95 z-45 gap-4 text-center p-6">
                  <AlertCircle className="w-14 h-14 text-[#E50914]" />
                  <div>
                    <h4 className="text-white font-semibold text-lg">Failed to Resolve Moviebox Source</h4>
                    <p className="text-zinc-500 text-sm max-w-md mt-2 font-mono text-xs bg-zinc-900 border border-white/5 p-3 rounded-lg">{resolveError}</p>
                  </div>
                  <button 
                    onClick={fetchMoviebox} 
                    className="flex items-center gap-2 bg-[#E50914] hover:bg-red-700 text-white rounded-lg px-6 py-3 text-xs font-bold transition-all shadow-md active:scale-95"
                  >
                    <RefreshCw className="w-3.5 h-3.5" /> Retry Connection
                  </button>
                </div>
              )}

              {movieboxData && (
                <div 
                  ref={playerContainerRef}
                  className="flex-1 w-full h-full flex flex-col justify-between relative overflow-hidden select-none bg-black"
                  onMouseMove={handleMouseMove}
                  onClick={togglePlay}
                >
                  {/* Dynamic Video Viewport */}
                  <div className="absolute inset-0 w-full h-full flex items-center justify-center bg-black z-0">
                    {movieboxData.streamUrl ? (
                      <>
                        <video
                          ref={videoRef}
                          src={getStreamUrlWithProxy()}
                          className="w-full max-h-full aspect-video bg-black z-0"
                          crossOrigin="anonymous"
                          onTimeUpdate={handleTimeUpdate}
                          onLoadedMetadata={handleLoadedMetadata}
                          onWaiting={() => setIsBuffering(true)}
                          onPlaying={() => { setIsBuffering(false); setIsPlaying(true); }}
                          onPause={() => setIsPlaying(false)}
                          onSeeked={() => setIsBuffering(false)}
                        >
                          {movieboxData.subtitles.map((sub, i) => (
                            <track
                              key={i}
                              kind="subtitles"
                              label={sub.label}
                              src={getSubUrlWithProxy(sub.src)}
                              srcLang={sub.lang}
                              default={sub.lang === 'en'}
                            />
                          ))}
                        </video>

                        {/* Large Centered Play/Pause/Buffer overlay */}
                        {isBuffering && (
                          <div className="absolute inset-0 flex items-center justify-center bg-black/40 backdrop-blur-sm z-30 pointer-events-none">
                            <Loader2 className="w-12 h-12 text-[#E50914] animate-spin" />
                          </div>
                        )}

                        {/* Centered actions toast overlay */}
                        {playActionToast && (
                          <div className="absolute inset-0 flex items-center justify-center bg-black/10 pointer-events-none z-30">
                            <div className="w-20 h-20 rounded-full bg-black/60 flex items-center justify-center border border-white/10 scale-100 opacity-90 animate-ping">
                              {playActionToast === 'play' ? (
                                <Play className="w-8 h-8 text-white fill-white ml-1" />
                              ) : (
                                <Pause className="w-8 h-8 text-white fill-white" />
                              )}
                            </div>
                          </div>
                        )}
                      </>
                    ) : (
                      <div className="flex flex-col items-center justify-center gap-3 p-6 text-center">
                        <AlertCircle className="w-12 h-12 text-amber-500" />
                        <h5 className="text-white font-medium">No Direct Video URL Returned</h5>
                        <p className="text-zinc-500 text-xs max-w-xs">Direct stream extraction failed, but you can retry or download captions below.</p>
                      </div>
                    )}
                  </div>

                  {/* Netflix-like Modern Controls Panel */}
                  <div 
                    className={cn(
                      "player-controls-bar absolute inset-x-0 bottom-0 z-35 flex flex-col justify-end p-6 bg-gradient-to-t from-black via-black/80 to-transparent pt-32 transition-opacity duration-300 pointer-events-auto",
                      showControls ? "opacity-100" : "opacity-0 pointer-events-none"
                    )}
                  >
                    {/* Top Progress bar and Times row */}
                    <div className="w-full flex flex-col gap-2 mb-4">
                      <div className="w-full flex items-center gap-3">
                        <input
                          type="range"
                          min={0}
                          max={duration || 0}
                          value={currentTime}
                          onChange={handleSeek}
                          onClick={(e) => e.stopPropagation()}
                          className="netflix-slider flex-1 h-1.5 bg-zinc-700/80 rounded-lg appearance-none cursor-pointer outline-none transition-all duration-300"
                        />
                      </div>
                      
                      <div className="w-full flex items-center justify-between text-xs font-semibold tracking-wide text-zinc-300 font-sans">
                        <span>{formatTime(currentTime)}</span>
                        <div className="flex items-center gap-1.5">
                          <span className="text-[10px] uppercase font-bold text-zinc-400 bg-zinc-900 border border-white/5 px-2 py-0.5 rounded">{mediaType === 'movie' ? 'MOVIE' : `EPISODE ${episode}`}</span>
                          <span className="text-zinc-500">|</span>
                          <span>-{formatTime(Math.max(0, duration - currentTime))}</span>
                        </div>
                      </div>
                    </div>

                    {/* Bottom controls panel row */}
                    <div className="w-full flex items-center justify-between">
                      {/* Left: Playback, skip back/forward, Volume */}
                      <div className="flex items-center gap-6">
                        {/* Play/Pause */}
                        <button
                          type="button"
                          onClick={togglePlay}
                          className="text-white hover:text-red-500 transition-colors active:scale-90"
                          title={isPlaying ? "Pause (Space)" : "Play (Space)"}
                        >
                          {isPlaying ? (
                            <Pause className="w-7 h-7 fill-white" />
                          ) : (
                            <Play className="w-7 h-7 fill-white ml-0.5" />
                          )}
                        </button>

                        {/* Back 10s */}
                        <button
                          type="button"
                          onClick={skipBackward}
                          className="text-zinc-400 hover:text-white transition-colors active:scale-95"
                          title="Back 10s"
                        >
                          <RotateCcw className="w-6 h-6" />
                        </button>

                        {/* Forward 10s */}
                        <button
                          type="button"
                          onClick={skipForward}
                          className="text-zinc-400 hover:text-white transition-colors active:scale-95"
                          title="Forward 10s"
                        >
                          <RotateCw className="w-6 h-6" />
                        </button>

                        {/* Sleek Netflix slider Volume controller */}
                        <div 
                          className="flex items-center gap-2 cursor-pointer"
                          onMouseEnter={() => setShowVolumeSlider(true)}
                          onMouseLeave={() => setShowVolumeSlider(false)}
                          onClick={(e) => e.stopPropagation()}
                        >
                          <button 
                            type="button"
                            onClick={toggleMute} 
                            className="text-zinc-400 hover:text-white transition-colors"
                          >
                            {isMuted ? (
                              <VolumeX className="w-6 h-6 text-red-500" />
                            ) : (
                              <Volume2 className="w-6 h-6" />
                            )}
                          </button>
                          
                          <div className={cn(
                            "flex items-center overflow-hidden transition-all duration-300 ease-out",
                            showVolumeSlider ? "w-20 opacity-100" : "w-0 opacity-0"
                          )}>
                            <input
                              type="range"
                              min={0}
                              max={1}
                              step={0.05}
                              value={isMuted ? 0 : volume}
                              onChange={handleVolumeChange}
                              className="netflix-volume-slider w-16 accent-white h-1 bg-zinc-700/80 rounded appearance-none cursor-pointer outline-none"
                            />
                          </div>
                        </div>
                      </div>

                      {/* Center Title Display */}
                      <div className="hidden lg:block text-center select-none max-w-sm truncate text-white font-medium text-sm tracking-wide">
                        {title}
                      </div>

                      {/* Right: Subtitles Menu, Speeds, Fullscreen */}
                      <div className="flex items-center gap-6" onClick={(e) => e.stopPropagation()}>
                        
                        {/* Netflix-like Audio & Subtitles Panel Trigger */}
                        <button
                          type="button"
                          onClick={() => {
                            setShowSettingsPanel(true);
                            setShowControls(true);
                          }}
                          className="flex items-center gap-2 text-zinc-400 hover:text-white transition-colors py-1.5 px-3 rounded-lg bg-zinc-950/40 hover:bg-white/5 border border-white/5"
                        >
                          <Subtitles className="w-4 h-4 text-violet-400" />
                          <span className="text-xs font-semibold tracking-wide">Subtitles</span>
                        </button>

                        {/* Fullscreen icon */}
                        <button
                          type="button"
                          onClick={toggleFullscreen}
                          className="text-zinc-400 hover:text-white transition-colors active:scale-90"
                          title="Fullscreen (F)"
                        >
                          {isFullscreen ? (
                            <Minimize2 className="w-6 h-6" />
                          ) : (
                            <Maximize2 className="w-6 h-6" />
                          )}
                        </button>
                      </div>
                    </div>
                  </div>

                  {/* Netflix-like Fully Custom Audio & Subtitles Overlay Screen */}
                  {showSettingsPanel && (
                    <div 
                      className="settings-overlay-panel absolute inset-0 z-40 bg-black/85 backdrop-blur-md flex flex-col justify-center items-center p-6 text-white"
                      onClick={(e) => e.stopPropagation()}
                    >
                      <button 
                        type="button"
                        onClick={() => {
                          setShowSettingsPanel(false);
                          resetControlsTimeout();
                        }}
                        className="absolute top-6 right-6 p-2 rounded-full border border-white/10 bg-zinc-950 hover:bg-white/10 transition-colors"
                      >
                        <X className="w-5 h-5 text-zinc-400 hover:text-white" />
                      </button>

                      <div className="w-full max-w-2xl flex flex-col gap-6">
                        <div className="text-center">
                          <h3 className="text-xl font-bold tracking-wide">Audio & Subtitles</h3>
                          <p className="text-xs font-mono text-zinc-500 mt-1 uppercase tracking-widest">{title}</p>
                        </div>

                        <div className="grid grid-cols-1 md:grid-cols-2 gap-8 border-t border-b border-white/10 py-8">
                          {/* Left Column: Stream Quality & Options */}
                          <div className="flex flex-col gap-4">
                            <h4 className="text-zinc-400 text-xs font-bold uppercase tracking-wider font-mono">Stream Quality</h4>
                            <div className="flex flex-col gap-2">
                              {movieboxData.options && movieboxData.options.map((opt, i) => (
                                <button
                                  key={i}
                                  type="button"
                                  onClick={() => handleSpeedChange(1)}
                                  className="flex items-center justify-between w-full text-left rounded-lg bg-zinc-950/60 hover:bg-white/5 border border-white/5 px-4 py-3 text-sm font-medium text-white transition-all"
                                >
                                  <span className="font-mono text-xs">{opt.label}</span>
                                  <Check className="w-4 h-4 text-[#E50914]" />
                                </button>
                              ))}

                              {/* Speeds list */}
                              <div className="mt-4 flex flex-col gap-3">
                                <h4 className="text-zinc-400 text-xs font-bold uppercase tracking-wider font-mono">Playback Speed</h4>
                                <div className="flex items-center gap-1.5 flex-wrap">
                                  {[0.5, 1, 1.25, 1.5, 2].map((rate) => (
                                    <button
                                      key={rate}
                                      type="button"
                                      onClick={() => handleSpeedChange(rate)}
                                      className={cn(
                                        "px-3 py-1.5 text-xs font-bold tracking-wide rounded-md border transition-all",
                                        playbackRate === rate
                                          ? "bg-white text-black border-white"
                                          : "bg-zinc-950 border-white/10 text-zinc-400 hover:text-white"
                                      )}
                                    >
                                      {rate.toFixed(2)}x
                                    </button>
                                  ))}
                                </div>
                              </div>
                            </div>
                          </div>

                          {/* Right Column: WebVTT Subtitles Tracks (Now fully working!) */}
                          <div className="flex flex-col gap-4">
                            <h4 className="text-zinc-400 text-xs font-bold uppercase tracking-wider font-mono">Subtitles</h4>
                            <div className="flex flex-col gap-2 max-h-56 overflow-y-auto pr-2 custom-scrollbar">
                              <button
                                type="button"
                                onClick={() => handleSubtitleChange('disabled')}
                                className={cn(
                                  "flex items-center justify-between w-full text-left rounded-lg border px-4 py-3 text-sm font-medium transition-all",
                                  activeSubtitle === 'disabled'
                                    ? "bg-white/5 border-[#E50914] text-white font-bold"
                                    : "bg-zinc-950/60 border-white/5 text-zinc-400 hover:text-white hover:bg-white/5"
                                )}
                              >
                                <span>OFF</span>
                                {activeSubtitle === 'disabled' && <Check className="w-4 h-4 text-[#E50914]" />}
                              </button>

                              {movieboxData.subtitles.map((sub, i) => (
                                <button
                                  key={i}
                                  type="button"
                                  onClick={() => handleSubtitleChange(sub.lang)}
                                  className={cn(
                                    "flex items-center justify-between w-full text-left rounded-lg border px-4 py-3 text-sm font-medium transition-all",
                                    activeSubtitle === sub.lang
                                      ? "bg-white/5 border-[#E50914] text-white font-bold"
                                      : "bg-zinc-950/60 border-white/5 text-zinc-400 hover:text-white hover:bg-white/5"
                                  )}
                                >
                                  <span>{sub.label} ({sub.lang.toUpperCase()})</span>
                                  {activeSubtitle === sub.lang && <Check className="w-4 h-4 text-[#E50914]" />}
                                </button>
                              ))}
                            </div>
                          </div>
                        </div>

                        <div className="flex justify-center mt-2">
                          <button
                            type="button"
                            onClick={() => {
                              setShowSettingsPanel(false);
                              resetControlsTimeout();
                            }}
                            className="bg-[#E50914] hover:bg-red-700 text-white rounded-lg px-8 py-3.5 text-xs font-bold tracking-wide transition-all shadow-md active:scale-95"
                          >
                            Apply and Continue
                          </button>
                        </div>
                      </div>
                    </div>
                  )}
                </div>
              )}

              {/* Action buttons below player (download captures/mp4) */}
              {movieboxData && !showSettingsPanel && (
                <div className="absolute bottom-2 left-6 right-6 flex flex-col md:flex-row items-center justify-between gap-4 p-3.5 rounded-xl bg-zinc-900/80 border border-white/5 backdrop-blur-md z-10 shadow-lg">
                  <div className="text-left">
                    <h4 className="text-white font-semibold text-sm truncate max-w-[280px]">{title}</h4>
                    <p className="text-zinc-500 text-[10px] font-mono mt-0.5 flex items-center gap-1">
                      <Info className="w-3 h-3 text-[#E50914]" /> Subtitles converted on-the-fly to WebVTT for browser compatibility!
                    </p>
                  </div>

                  <div className="flex flex-wrap items-center gap-2">
                    {/* Quality selection option indicator */}
                    {movieboxData.options && movieboxData.options.length > 0 && (
                      <div className="flex items-center gap-1.5 rounded-lg border border-white/10 bg-zinc-950 px-2.5 py-1.5 text-xs text-zinc-300 font-mono">
                        <span className="text-zinc-500 font-bold uppercase tracking-wider text-[9px]">Source:</span>
                        <span className="text-[#E50914] font-semibold">{movieboxData.options[0].label}</span>
                      </div>
                    )}

                    {/* Direct Video Download */}
                    {movieboxData.streamUrl && (
                      <a
                        href={movieboxData.streamUrl}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="flex items-center gap-1.5 bg-red-700/80 hover:bg-[#E50914] text-white rounded-lg px-4 py-2 text-xs font-bold transition-all shadow-md active:scale-95"
                      >
                        <Download className="w-3.5 h-3.5" /> Download MP4
                      </a>
                    )}

                    {/* Subtitles Downloader list */}
                    {movieboxData.subtitles && movieboxData.subtitles.length > 0 && (
                      <div className="relative group">
                        <button className="flex items-center gap-1.5 border border-white/10 hover:bg-white/5 text-zinc-300 rounded-lg px-4 py-2 text-xs font-semibold transition-all">
                          <Download className="w-3.5 h-3.5 text-zinc-500" /> Subtitles ({movieboxData.subtitles.length})
                        </button>
                        <div className="absolute bottom-full right-0 mb-2 w-48 rounded-lg border border-white/10 bg-zinc-950 p-1 opacity-0 pointer-events-none group-hover:opacity-100 group-hover:pointer-events-auto transition-all shadow-xl z-55 max-h-48 overflow-y-auto">
                          {movieboxData.subtitles.map((sub, i) => (
                            <a
                              key={i}
                              href={sub.src}
                              target="_blank"
                              rel="noopener noreferrer"
                              className="block rounded px-2.5 py-1.5 text-left text-[11px] text-zinc-300 hover:bg-red-950/20 hover:text-red-400 transition-colors"
                            >
                              {sub.label} ({sub.lang.toUpperCase()})
                            </a>
                          ))}
                        </div>
                      </div>
                    )}
                  </div>
                </div>
              )}

            </div>
          )}
        </div>
      </DialogContent>
    </Dialog>
  );
}
