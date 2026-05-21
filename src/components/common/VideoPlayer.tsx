'use client';

import { 
  Play, Pause, Volume2, VolumeX, Maximize2, Minimize2, X, AlertCircle, 
  Download, RefreshCw, Loader2, Monitor, Square, Check, Info, Film
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

  // Custom retro HTML player controls state
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
  const [showCrtFilter, setShowCrtFilter] = useState(false);
  const [isBuffering, setIsBuffering] = useState(false);
  const [showSubDropdown, setShowSubDropdown] = useState(false);
  const [showSpeedDropdown, setShowSpeedDropdown] = useState(false);
  const [playActionToast, setPlayActionToast] = useState<'play' | 'pause' | null>(null);

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
        if (hasEn) setActiveSubtitle('en');
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
    }
  };

  // Custom player events and triggers
  const togglePlay = () => {
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
  };

  const stopPlayback = () => {
    if (!videoRef.current) return;
    videoRef.current.pause();
    videoRef.current.currentTime = 0;
    setIsPlaying(false);
    setCurrentTime(0);
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
  };

  const toggleMute = () => {
    if (!videoRef.current) return;
    const muted = !isMuted;
    videoRef.current.muted = muted;
    setIsMuted(muted);
  };

  const handleSpeedChange = (rate: number) => {
    if (!videoRef.current) return;
    videoRef.current.playbackRate = rate;
    setPlaybackRate(rate);
    setShowSpeedDropdown(false);
  };

  const handleSubtitleChange = (lang: string) => {
    if (!videoRef.current) return;
    setActiveSubtitle(lang);
    setShowSubDropdown(false);

    const tracks = videoRef.current.textTracks;
    for (let i = 0; i < tracks.length; i++) {
      if (lang === 'disabled') {
        tracks[i].mode = 'disabled';
      } else {
        tracks[i].mode = tracks[i].language === lang ? 'showing' : 'disabled';
      }
    }
  };

  const toggleFullscreen = () => {
    if (!playerContainerRef.current) return;
    if (!document.fullscreenElement) {
      playerContainerRef.current.requestFullscreen().catch(() => {});
      setIsFullscreen(true);
    } else {
      document.exitFullscreen().catch(() => {});
      setIsFullscreen(false);
    }
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
          togglePlay();
          break;
        case 'arrowleft':
          e.preventDefault();
          videoRef.current.currentTime = Math.max(0, videoRef.current.currentTime - 10);
          break;
        case 'arrowright':
          e.preventDefault();
          videoRef.current.currentTime = Math.min(videoRef.current.duration || 0, videoRef.current.currentTime + 10);
          break;
        case 'arrowup':
          e.preventDefault();
          const newVolUp = Math.min(1, videoRef.current.volume + 0.1);
          videoRef.current.volume = newVolUp;
          setVolume(newVolUp);
          break;
        case 'arrowdown':
          e.preventDefault();
          const newVolDown = Math.max(0, videoRef.current.volume - 0.1);
          videoRef.current.volume = newVolDown;
          setVolume(newVolDown);
          break;
        case 'm':
          e.preventDefault();
          toggleMute();
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

  const formatTime = (seconds: number) => {
    if (isNaN(seconds) || seconds === Infinity) return '00:00:00';
    const hrs = Math.floor(seconds / 3600);
    const mins = Math.floor((seconds % 3600) / 60);
    const secs = Math.floor(seconds % 60);
    return `${String(hrs).padStart(2, '0')}:${String(mins).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
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
        <div className="absolute top-0 right-0 z-50 p-4 flex items-center gap-2">
          <div className="flex items-center gap-1 rounded-full border border-white/20 bg-black/50 p-1 backdrop-blur-md">
            <button
              type="button"
              onClick={() => handlePlayerSelect('vidplus')}
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
              onClick={() => handlePlayerSelect('videasy')}
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
              onClick={() => handlePlayerSelect('vidsrc')}
              className={cn(
                'rounded-full px-3 py-1 text-xs font-medium transition-colors',
                selectedPlayer === 'vidsrc'
                  ? 'bg-primary text-primary-foreground'
                  : 'text-white/80 hover:bg-white/10 hover:text-white',
              )}
            >
              VIDSRC
            </button>
            <button
              type="button"
              onClick={() => handlePlayerSelect('moviebox')}
              className={cn(
                'rounded-full px-3 py-1 text-xs font-medium transition-colors relative overflow-hidden',
                selectedPlayer === 'moviebox'
                  ? 'bg-primary text-primary-foreground shadow-md'
                  : 'text-violet-400 hover:bg-white/10 hover:text-violet-300 border border-violet-500/30',
              )}
            >
              <span className="flex items-center gap-1">
                Moviebox <span className="text-[9px] bg-violet-600/30 px-1 py-0.5 rounded text-violet-300 font-bold uppercase tracking-wide">Direct</span>
              </span>
            </button>
          </div>
          <DialogClose className="bg-black/50 hover:bg-white/20 text-white rounded-full p-2 backdrop-blur-md transition-colors">
            <X className="w-6 h-6" />
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
            <div className="w-full h-full flex flex-col justify-between bg-zinc-950/80 rounded-md overflow-hidden relative border border-white/5">
              {isResolving && (
                <div className="absolute inset-0 flex flex-col items-center justify-center bg-black/90 backdrop-blur-md z-45 gap-4 text-center p-6">
                  <Loader2 className="w-12 h-12 text-violet-500 animate-spin" />
                  <div>
                    <h4 className="text-white font-medium text-lg tracking-wide">Resolving Direct Stream</h4>
                    <p className="text-zinc-500 text-sm max-w-sm mt-1">Scraping high-quality Moviebox streams and captions track list...</p>
                  </div>
                </div>
              )}

              {resolveError && (
                <div className="absolute inset-0 flex flex-col items-center justify-center bg-black/95 z-45 gap-4 text-center p-6">
                  <AlertCircle className="w-14 h-14 text-rose-500" />
                  <div>
                    <h4 className="text-white font-semibold text-lg">Failed to Resolve Moviebox Source</h4>
                    <p className="text-rose-400/80 text-sm max-w-md mt-1 font-mono text-xs bg-rose-950/20 border border-rose-900/30 p-3 rounded-lg">{resolveError}</p>
                  </div>
                  <button 
                    onClick={fetchMoviebox} 
                    className="flex items-center gap-2 bg-violet-600 hover:bg-violet-500 text-white rounded-full px-5 py-2.5 text-xs font-semibold shadow-lg shadow-violet-500/20 transition-all"
                  >
                    <RefreshCw className="w-3.5 h-3.5" /> Retry Connection
                  </button>
                </div>
              )}

              {movieboxData && (
                <div className="flex-1 w-full h-full flex flex-col justify-between relative p-4 pb-20 select-none">
                  {/* Style Declarations for Vintage controls */}
                  <style>{`
                    .retro-lcd-glow {
                      text-shadow: 0 0 8px rgba(34, 197, 94, 0.6);
                    }
                    .retro-bezel-out {
                      box-shadow: inset 1px 1px 0px rgba(255,255,255,0.15), 1px 2px 4px rgba(0,0,0,0.5);
                    }
                    .retro-bezel-in {
                      box-shadow: inset 2px 2px 4px rgba(0,0,0,0.7), 1px 1px 0px rgba(255,255,255,0.05);
                    }
                    .crt-glow {
                      position: relative;
                    }
                    .crt-glow::after {
                      content: " ";
                      display: block;
                      position: absolute;
                      top: 0; left: 0; bottom: 0; right: 0;
                      background: linear-gradient(rgba(18, 16, 16, 0) 50%, rgba(0, 0, 0, 0.25) 50%), linear-gradient(90deg, rgba(255, 0, 0, 0.05), rgba(0, 255, 0, 0.02), rgba(0, 0, 255, 0.05));
                      z-index: 20;
                      background-size: 100% 3px, 3px 100%;
                      pointer-events: none;
                    }
                    .equalizer-col {
                      animation: eqBounce 1.2s ease-in-out infinite alternate;
                    }
                    @keyframes eqBounce {
                      0% { height: 4px; }
                      100% { height: 28px; }
                    }
                    /* Custom Range Input Styles */
                    .retro-slider::-webkit-slider-thumb {
                      -webkit-appearance: none;
                      appearance: none;
                      width: 14px;
                      height: 18px;
                      background: #e4e4e7;
                      border: 1px solid #18181b;
                      border-radius: 2px;
                      cursor: pointer;
                      box-shadow: inset 1px 1px 0px white, 0px 1px 3px black;
                    }
                    .retro-slider::-moz-range-thumb {
                      width: 14px;
                      height: 18px;
                      background: #e4e4e7;
                      border: 1px solid #18181b;
                      border-radius: 2px;
                      cursor: pointer;
                      box-shadow: inset 1px 1px 0px white, 0px 1px 3px black;
                    }
                  `}</style>

                  {/* MooviePlayer Classic Retro Frame */}
                  <div 
                    ref={playerContainerRef}
                    className={cn(
                      "flex-1 w-full flex flex-col justify-between relative overflow-hidden rounded-xl bg-[#1c1d1f] border-2 border-[#373a40] shadow-[0_25px_60px_-15px_rgba(0,0,0,0.9)] p-2 gap-2",
                      showCrtFilter && "crt-glow"
                    )}
                  >
                    {/* Retro Windows-like Window Header Titlebar */}
                    <div className="w-full flex items-center justify-between bg-gradient-to-r from-[#2a2c31] via-[#3a3d45] to-[#2a2c31] border border-[#4c505b] px-3 py-2 rounded shadow-inner text-xs font-mono font-bold text-zinc-300">
                      <div className="flex items-center gap-2">
                        <Film className="w-3.5 h-3.5 text-violet-400 animate-pulse" />
                        <span className="tracking-wide truncate max-w-[400px]">📁 MOOVIEPLAYER CLASSIC - {title}</span>
                      </div>
                      
                      <div className="flex items-center gap-2">
                        {/* CRT Screen Mode Selector */}
                        <button
                          type="button"
                          onClick={() => setShowCrtFilter(!showCrtFilter)}
                          className={cn(
                            "flex items-center gap-1.5 px-2 py-0.5 rounded border text-[10px] uppercase font-bold tracking-wider transition-all duration-300 cursor-pointer",
                            showCrtFilter 
                              ? "bg-emerald-950/80 border-emerald-500 text-emerald-400 shadow-[0_0_8px_rgba(16,185,129,0.3)]"
                              : "bg-zinc-800 border-zinc-700 hover:border-zinc-500 text-zinc-400"
                          )}
                        >
                          <Monitor className="w-2.5 h-2.5" />
                          CRT SCREEN: {showCrtFilter ? "ON" : "OFF"}
                        </button>
                      </div>
                    </div>

                    {/* Interactive Video Canvas */}
                    <div 
                      className="flex-1 w-full flex items-center justify-center relative overflow-hidden rounded-lg bg-black border-2 border-[#121315] shadow-inner cursor-pointer"
                      onClick={togglePlay}
                      onDoubleClick={toggleFullscreen}
                    >
                      {movieboxData.streamUrl ? (
                        <>
                          <video
                            ref={videoRef}
                            src={getStreamUrlWithProxy()}
                            className="w-full max-h-full aspect-video rounded bg-black"
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

                          {/* Quick Center Action Icons Toast */}
                          {playActionToast && (
                            <div className="absolute inset-0 flex items-center justify-center bg-black/10 pointer-events-none z-30">
                              <div className="w-16 h-16 rounded-full bg-black/80 flex items-center justify-center border border-white/10 scale-100 opacity-90 animate-ping">
                                {playActionToast === 'play' ? (
                                  <Play className="w-6 h-6 text-emerald-400 fill-emerald-400" />
                                ) : (
                                  <Pause className="w-6 h-6 text-zinc-400 fill-zinc-400" />
                                )}
                              </div>
                            </div>
                          )}

                          {/* Captions custom renderer (overlay on fullscreen) */}
                          {isBuffering && (
                            <div className="absolute inset-0 flex items-center justify-center bg-black/60 backdrop-blur-sm z-30">
                              <div className="flex flex-col items-center gap-3">
                                <Loader2 className="w-10 h-10 text-violet-500 animate-spin" />
                                <span className="text-zinc-400 font-mono text-xs uppercase tracking-widest animate-pulse">BUFFERING...</span>
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

                    {/* Retro LCD Glass Dashboard Panel */}
                    <div className="w-full flex items-center justify-between gap-3 bg-[#111214] border border-[#2b2c30] p-2.5 rounded-lg retro-bezel-in">
                      {/* Bouncing Audio Equalizer Bar Graph (emerald green classic visualizer) */}
                      <div className="hidden sm:flex items-end gap-[3px] w-24 h-8 bg-zinc-950 border border-zinc-900 rounded p-1">
                        {[1, 2, 3, 4, 5, 6, 7, 8].map((i) => (
                          <div 
                            key={i} 
                            style={{ 
                              animationDelay: `${i * 0.15}s`,
                              animationPlayState: isPlaying ? 'running' : 'paused'
                            }}
                            className={cn(
                              "w-2 bg-gradient-to-t from-emerald-600 via-green-400 to-green-300 rounded-sm opacity-80",
                              isPlaying ? "equalizer-col" : "h-[4px]"
                            )} 
                          />
                        ))}
                      </div>

                      {/* Giant glowing Digital Clock LCD Status Screen */}
                      <div className="flex-1 flex flex-col items-center justify-center font-mono py-1 px-3 bg-zinc-950 border border-zinc-900 rounded text-center">
                        <div className="flex items-center gap-2 text-xs font-semibold text-zinc-500 tracking-wider">
                          <span className={cn(
                            "w-2 h-2 rounded-full",
                            isBuffering ? "bg-amber-500 animate-ping" : (isPlaying ? "bg-green-500 animate-pulse" : "bg-red-500")
                          )} />
                          <span className="retro-lcd-glow tracking-widest text-[10px] uppercase font-bold">
                            {isBuffering ? "BUFFERING" : (isPlaying ? "PLAYING" : "PAUSED")}
                          </span>
                          <span className="text-zinc-700">|</span>
                          <span className="text-[10px] uppercase text-zinc-400 font-bold">{mediaType === 'movie' ? 'MOVIE' : `TV S${season} E${episode}`}</span>
                        </div>
                        
                        <div className="text-lg font-bold text-green-500 retro-lcd-glow tracking-widest mt-0.5">
                          {formatTime(currentTime)} <span className="text-green-900">/</span> {formatTime(duration)}
                        </div>
                      </div>

                      {/* Quick Option Indicators Status LEDs */}
                      <div className="hidden md:flex flex-col gap-1 w-28 bg-zinc-950 border border-zinc-900 rounded p-1 text-[9px] font-mono font-bold tracking-wide">
                        <div className="flex items-center justify-between px-1 text-zinc-500">
                          <span>CC SUBTITLE:</span>
                          <span className={activeSubtitle !== 'disabled' ? "text-green-500" : "text-zinc-700"}>
                            {activeSubtitle !== 'disabled' ? activeSubtitle.toUpperCase() : "OFF"}
                          </span>
                        </div>
                        <div className="flex items-center justify-between px-1 text-zinc-500">
                          <span>SPEED:</span>
                          <span className="text-green-500">{playbackRate.toFixed(2)}X</span>
                        </div>
                        <div className="flex items-center justify-between px-1 text-zinc-500">
                          <span>AUDIO:</span>
                          <span className={isMuted ? "text-red-500" : "text-green-500"}>
                            {isMuted ? "MUTED" : `${Math.round(volume * 100)}%`}
                          </span>
                        </div>
                      </div>
                    </div>

                    {/* Custom 3D Bevel Raised tactile Button control panel */}
                    <div className="w-full flex flex-col gap-2 p-2 bg-[#2a2c31] border border-[#41454f] rounded-lg shadow-md">
                      
                      {/* Tactile Progress Seek Bar */}
                      <div className="w-full flex items-center gap-2">
                        <span className="font-mono text-[10px] text-zinc-400 w-12 text-left">{formatTime(currentTime)}</span>
                        <input
                          type="range"
                          min={0}
                          max={duration || 0}
                          value={currentTime}
                          onChange={handleSeek}
                          className="flex-1 accent-zinc-200 h-2 bg-[#121315] border border-zinc-800 rounded-md retro-slider appearance-none cursor-pointer outline-none transition-all"
                        />
                        <span className="font-mono text-[10px] text-zinc-400 w-12 text-right">{formatTime(duration)}</span>
                      </div>

                      {/* Tactile Controls Buttons Area */}
                      <div className="w-full flex items-center justify-between flex-wrap gap-2.5 pt-1">
                        
                        {/* Playback Buttons Group */}
                        <div className="flex items-center gap-2">
                          <button
                            type="button"
                            onClick={togglePlay}
                            className="retro-win98-btn flex items-center justify-center w-8 h-8 rounded border active:scale-95 shadow transition-all hover:bg-zinc-300 border-t-white border-l-white border-b-zinc-700 border-r-zinc-700"
                            title="Play/Pause"
                          >
                            {isPlaying ? (
                              <Pause className="w-4 h-4 text-zinc-950 fill-zinc-950" />
                            ) : (
                              <Play className="w-4 h-4 text-zinc-950 fill-zinc-950 ml-0.5" />
                            )}
                          </button>

                          <button
                            type="button"
                            onClick={stopPlayback}
                            className="retro-win98-btn flex items-center justify-center w-8 h-8 rounded border active:scale-95 shadow transition-all hover:bg-zinc-300 border-t-white border-l-white border-b-zinc-700 border-r-zinc-700"
                            title="Stop Playback"
                          >
                            <Square className="w-4 h-4 text-zinc-950 fill-zinc-950" />
                          </button>
                        </div>

                        {/* Mute and Volume Control Group */}
                        <div className="flex items-center gap-2 bg-[#1c1d1f] border border-zinc-800 rounded px-2.5 py-1 text-xs">
                          <button 
                            type="button"
                            onClick={toggleMute} 
                            className="text-zinc-400 hover:text-white transition-colors"
                          >
                            {isMuted ? (
                              <VolumeX className="w-4 h-4 text-red-400" />
                            ) : (
                              <Volume2 className="w-4 h-4 text-zinc-300" />
                            )}
                          </button>
                          <input
                            type="range"
                            min={0}
                            max={1}
                            step={0.05}
                            value={isMuted ? 0 : volume}
                            onChange={handleVolumeChange}
                            className="w-16 accent-violet-500 h-1.5 bg-zinc-900 border border-zinc-850 rounded appearance-none cursor-pointer outline-none"
                          />
                        </div>

                        {/* Right Buttons group (Subtitles, Speed, Fullscreen) */}
                        <div className="flex items-center gap-2 relative">
                          
                          {/* Captions Selector Dropdown */}
                          {movieboxData.subtitles && movieboxData.subtitles.length > 0 && (
                            <div className="relative">
                              <button
                                type="button"
                                onClick={() => {
                                  setShowSubDropdown(!showSubDropdown);
                                  setShowSpeedDropdown(false);
                                }}
                                className={cn(
                                  "retro-win98-btn flex items-center gap-1.5 px-3 py-1.5 rounded text-[10px] uppercase font-bold tracking-wider transition-all",
                                  showSubDropdown && "bg-zinc-400 shadow-inner"
                                )}
                              >
                                <span>CC Captions ({movieboxData.subtitles.length})</span>
                              </button>
                              
                              {showSubDropdown && (
                                <div className="absolute bottom-full right-0 mb-2 w-48 rounded border-2 border-zinc-700 bg-zinc-900 p-1 shadow-2xl z-55 flex flex-col max-h-48 overflow-y-auto">
                                  <button
                                    type="button"
                                    onClick={() => handleSubtitleChange('disabled')}
                                    className="flex items-center justify-between rounded px-2.5 py-1.5 text-left text-[11px] font-mono text-zinc-300 hover:bg-violet-600 hover:text-white transition-colors"
                                  >
                                    <span>[DISABLE SUBTITLES]</span>
                                    {activeSubtitle === 'disabled' && <Check className="w-3.5 h-3.5 text-emerald-400" />}
                                  </button>
                                  <div className="h-[1px] bg-zinc-800 my-1" />
                                  {movieboxData.subtitles.map((sub, i) => (
                                    <button
                                      key={i}
                                      type="button"
                                      onClick={() => handleSubtitleChange(sub.lang)}
                                      className="flex items-center justify-between rounded px-2.5 py-1.5 text-left text-[11px] font-mono text-zinc-300 hover:bg-violet-600 hover:text-white transition-colors"
                                    >
                                      <span>{sub.label} ({sub.lang.toUpperCase()})</span>
                                      {activeSubtitle === sub.lang && <Check className="w-3.5 h-3.5 text-emerald-400" />}
                                    </button>
                                  ))}
                                </div>
                              )}
                            </div>
                          )}

                          {/* Playback Rate Dropdown */}
                          <div className="relative">
                            <button
                              type="button"
                              onClick={() => {
                                setShowSpeedDropdown(!showSpeedDropdown);
                                setShowSubDropdown(false);
                              }}
                              className={cn(
                                "retro-win98-btn flex items-center gap-1 px-3 py-1.5 rounded text-[10px] uppercase font-bold tracking-wider transition-all",
                                showSpeedDropdown && "bg-zinc-400 shadow-inner"
                              )}
                            >
                              <span>Speed: {playbackRate.toFixed(2)}x</span>
                            </button>
                            
                            {showSpeedDropdown && (
                              <div className="absolute bottom-full right-0 mb-2 w-32 rounded border-2 border-zinc-700 bg-zinc-900 p-1 shadow-2xl z-55 flex flex-col">
                                {[0.5, 1, 1.25, 1.5, 2].map((rate) => (
                                  <button
                                    key={rate}
                                    type="button"
                                    onClick={() => handleSpeedChange(rate)}
                                    className="flex items-center justify-between rounded px-2.5 py-1.5 text-left text-[11px] font-mono text-zinc-300 hover:bg-violet-600 hover:text-white transition-colors"
                                  >
                                    <span>{rate.toFixed(2)}x</span>
                                    {playbackRate === rate && <Check className="w-3.5 h-3.5 text-emerald-400" />}
                                  </button>
                                ))}
                              </div>
                            )}
                          </div>

                          {/* Fullscreen Toggle */}
                          <button
                            type="button"
                            onClick={toggleFullscreen}
                            className="retro-win98-btn flex items-center justify-center w-8 h-8 rounded border active:scale-95 shadow transition-all hover:bg-zinc-300 border-t-white border-l-white border-b-zinc-700 border-r-zinc-700"
                            title="Toggle Fullscreen (F)"
                          >
                            {isFullscreen ? (
                              <Minimize2 className="w-4 h-4 text-zinc-950" />
                            ) : (
                              <Maximize2 className="w-4 h-4 text-zinc-950" />
                            )}
                          </button>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Sleek Action Controls & Download Area below Player */}
                  <div className="absolute bottom-2 left-4 right-4 flex flex-col md:flex-row items-center justify-between gap-4 p-3.5 rounded-xl bg-zinc-900/80 border border-white/5 backdrop-blur-md z-10 shadow-lg">
                    <div className="text-left">
                      <h4 className="text-white font-semibold text-sm truncate max-w-[280px]">{title}</h4>
                      <p className="text-zinc-500 text-[10px] font-mono mt-0.5 flex items-center gap-1">
                        <Info className="w-3 h-3 text-violet-400" /> Hotkeys enabled (Space: Play/Pause, F: Fullscreen, M: Mute)
                      </p>
                    </div>

                    <div className="flex flex-wrap items-center gap-2">
                      {/* Quality selection option indicator */}
                      {movieboxData.options && movieboxData.options.length > 0 && (
                        <div className="flex items-center gap-1.5 rounded-lg border border-white/10 bg-zinc-950 px-2.5 py-1.5 text-xs text-zinc-300 font-mono">
                          <span className="text-zinc-500 font-bold uppercase tracking-wider text-[9px]">Quality:</span>
                          <span className="text-violet-400 font-semibold">{movieboxData.options[0].label}</span>
                        </div>
                      )}

                      {/* Direct Video Download */}
                      {movieboxData.streamUrl && (
                        <a
                          href={movieboxData.streamUrl}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="flex items-center gap-1.5 bg-violet-650 hover:bg-violet-600 text-white rounded-lg px-4 py-2 text-xs font-semibold transition-all shadow-md active:scale-95"
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
                          <div className="absolute bottom-full right-0 mb-2 w-48 rounded-lg border border-white/10 bg-[#121315] p-1 opacity-0 pointer-events-none group-hover:opacity-100 group-hover:pointer-events-auto transition-all shadow-xl z-55 max-h-48 overflow-y-auto">
                            {movieboxData.subtitles.map((sub, i) => (
                              <a
                                key={i}
                                href={sub.src}
                                target="_blank"
                                rel="noopener noreferrer"
                                className="block rounded px-2.5 py-1.5 text-left text-[11px] text-zinc-300 hover:bg-violet-600 hover:text-white transition-colors"
                              >
                                {sub.label} ({sub.lang.toUpperCase()})
                              </a>
                            ))}
                          </div>
                        </div>
                      )}
                    </div>
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
