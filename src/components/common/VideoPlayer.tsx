'use client';

import { Play, X, Maximize2, AlertCircle, Download, RefreshCw, Loader2 } from 'lucide-react';
import Image from 'next/image';
import { Skeleton } from '../ui/skeleton';
import { Dialog, DialogContent, DialogTrigger, DialogClose } from '@/components/ui/dialog';
import { useState } from 'react';
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
    } catch (err: any) {
      setResolveError(err.message || 'Stream link resolution failed.');
    } finally {
      setIsResolving(false);
    }
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
      // If moviebox was selected previously, re-fetch or clear states
      if (selectedPlayer === 'moviebox') {
        fetchMoviebox();
      }
    } else {
      // Reset states on modal close to allow fresh resolution on new selections
      setMovieboxData(null);
      setResolveError(null);
    }
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
        <div
          className="w-full aspect-video relative cursor-pointer group overflow-hidden rounded-xl bg-black shadow-2xl ring-1 ring-white/10"
        >
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

      <DialogContent className="max-w-screen-xl w-[95vw] h-[80vh] p-0 bg-black border-none shadow-2xl flex flex-col">
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

        <div className="w-full h-full relative bg-black">
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
                <div className="absolute inset-0 flex flex-col items-center justify-center bg-black/90 backdrop-blur-md z-40 gap-4 text-center p-6">
                  <Loader2 className="w-12 h-12 text-violet-500 animate-spin" />
                  <div>
                    <h4 className="text-white font-medium text-lg tracking-wide">Resolving Direct Stream</h4>
                    <p className="text-zinc-500 text-sm max-w-sm mt-1">Scraping high-quality Moviebox streams and captions track list...</p>
                  </div>
                </div>
              )}

              {resolveError && (
                <div className="absolute inset-0 flex flex-col items-center justify-center bg-black/95 z-40 gap-4 text-center p-6">
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
                <div className="flex-1 w-full h-full flex flex-col justify-between relative p-4 pb-16">
                  {/* Dynamic HTML5 Player Area */}
                  <div className="flex-1 w-full flex items-center justify-center relative overflow-hidden rounded-lg bg-black">
                    {movieboxData.streamUrl ? (
                      <video
                        src={
                          typeof window !== 'undefined' && localStorage.getItem('moviebox_proxy')
                            ? `${localStorage.getItem('moviebox_proxy')}${encodeURIComponent(movieboxData.streamUrl)}`
                            : movieboxData.streamUrl
                        }
                        controls
                        className="w-full max-h-full aspect-video rounded bg-black"
                        crossOrigin="anonymous"
                      >
                        {movieboxData.subtitles.map((sub, i) => (
                          <track
                            key={i}
                            kind="subtitles"
                            label={sub.label}
                            src={sub.src}
                            srcLang={sub.lang}
                            default={sub.lang === 'en'}
                          />
                        ))}
                      </video>
                    ) : (
                      <div className="flex flex-col items-center justify-center gap-3 p-6 text-center">
                        <AlertCircle className="w-12 h-12 text-amber-500" />
                        <h5 className="text-white font-medium">No Direct Video URL Returned</h5>
                        <p className="text-zinc-500 text-xs max-w-xs">Direct stream extraction failed, but you can retry or download captions below.</p>
                      </div>
                    )}
                  </div>

                  {/* Sleek Action Controls & Download Area */}
                  <div className="mt-4 flex flex-col md:flex-row items-center justify-between gap-4 p-4 rounded-xl bg-zinc-900/80 border border-white/5 backdrop-blur-md">
                    <div className="text-left">
                      <h4 className="text-white font-semibold text-sm truncate max-w-[300px]">{title}</h4>
                      <p className="text-zinc-500 text-xs mt-0.5">High-speed direct stream provided by Moviebox API</p>
                    </div>

                    <div className="flex flex-wrap items-center gap-2.5">
                      {/* Quality selection option dropdown */}
                      {movieboxData.options && movieboxData.options.length > 0 && (
                        <div className="flex items-center gap-1.5 rounded-lg border border-white/10 bg-zinc-950 px-2 py-1.5 text-xs text-zinc-300">
                          <span className="text-zinc-500 font-bold uppercase tracking-wider text-[9px]">Source Quality:</span>
                          <span className="text-violet-400 font-semibold">{movieboxData.options[0].label}</span>
                        </div>
                      )}

                      {/* Direct Video Download */}
                      {movieboxData.streamUrl && (
                        <a
                          href={movieboxData.streamUrl}
                          target="_blank"
                          rel="noopener noreferrer"
                          className="flex items-center gap-1.5 bg-violet-600 hover:bg-violet-500 text-white rounded-lg px-4 py-2 text-xs font-semibold transition-all shadow-md"
                        >
                          <Download className="w-3.5 h-3.5" /> Download Video File
                        </a>
                      )}

                      {/* Captions Download */}
                      {movieboxData.subtitles && movieboxData.subtitles.length > 0 && (
                        <div className="relative group">
                          <button className="flex items-center gap-1.5 border border-white/10 hover:bg-white/5 text-zinc-300 rounded-lg px-4 py-2 text-xs font-semibold transition-all">
                            <Download className="w-3.5 h-3.5 text-zinc-500" /> Subtitles ({movieboxData.subtitles.length})
                          </button>
                          <div className="absolute bottom-full right-0 mb-2 w-48 rounded-lg border border-white/10 bg-zinc-950 p-1 opacity-0 pointer-events-none group-hover:opacity-100 group-hover:pointer-events-auto transition-all shadow-xl z-50">
                            {movieboxData.subtitles.map((sub, i) => (
                              <a
                                key={i}
                                href={sub.src}
                                target="_blank"
                                rel="noopener noreferrer"
                                className="block rounded px-2.5 py-1.5 text-left text-xs text-zinc-300 hover:bg-white/10 hover:text-white transition-colors"
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
