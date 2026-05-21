'use client';

import { 
  Play, X, AlertCircle, Download, RefreshCw, Loader2, Info
} from 'lucide-react';
import { Dialog, DialogContent, DialogTrigger, DialogClose, DialogTitle } from '@/components/ui/dialog';
import { useState, useRef, useEffect } from 'react';
import { cn } from '@/lib/utils';
import { getCurrentUser, addToHistory } from '@/lib/auth';
import Artplayer from 'artplayer';

type VideoPlayerProps = {
  mediaId?: number;
  mediaType?: 'movie' | 'tv';
  season?: number;
  episode?: number;
  posterPath?: string | null;
  title?: string;
};

type PlayerKey = 'moviebox' | 'vidplus' | 'videasy' | 'vidsrc';

const ISO_MAP: Record<string, { label: string; code: string }> = {
  eng: { label: 'English', code: 'en' },
  spa: { label: 'Spanish', code: 'es' },
  fre: { label: 'French', code: 'fr' },
  ger: { label: 'German', code: 'de' },
  ita: { label: 'Italian', code: 'it' },
  por: { label: 'Portuguese', code: 'pt' },
  pob: { label: 'Portuguese (BR)', code: 'pt-br' },
  rus: { label: 'Russian', code: 'ru' },
  tur: { label: 'Turkish', code: 'tr' },
  chi: { label: 'Chinese', code: 'zh' },
  zho: { label: 'Chinese', code: 'zh' },
  ell: { label: 'Greek', code: 'el' },
  dut: { label: 'Dutch', code: 'nl' },
  ara: { label: 'Arabic', code: 'ar' },
  kor: { label: 'Korean', code: 'ko' },
  jpn: { label: 'Japanese', code: 'ja' },
  hin: { label: 'Hindi', code: 'hi' },
  ind: { label: 'Indonesian', code: 'id' },
  vie: { label: 'Vietnamese', code: 'vi' },
  tha: { label: 'Thai', code: 'th' },
};

export function VideoPlayer({ mediaId, mediaType, season = 1, episode = 1, posterPath, title }: VideoPlayerProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [selectedPlayer, setSelectedPlayer] = useState<PlayerKey>('moviebox');
  const [movieboxData, setMovieboxData] = useState<{
    streamUrl: string | null;
    subtitles: { label: string; src: string; lang: string }[];
    options: { label: string; url: string }[];
  } | null>(null);
  const [isResolving, setIsResolving] = useState(false);
  const [resolveError, setResolveError] = useState<string | null>(null);
  const [fallbackMessage, setFallbackMessage] = useState<string | null>(null);
  const [resolvedStreamUrl, setResolvedStreamUrl] = useState<string>('');

  const artRef = useRef<HTMLDivElement>(null);
  const artInstanceRef = useRef<Artplayer | null>(null);

  const fetchMoviebox = async () => {
    if (!title || isResolving) return;
    setIsResolving(true);
    setResolveError(null);
    setFallbackMessage(null);
    try {
      // 1. Fetch TMDb External IDs to get the IMDb ID
      let imdbId = '';
      try {
        const tmdbRes = await fetch(
          `https://api.themoviedb.org/3/${mediaType === 'movie' ? 'movie' : 'tv'}/${mediaId}/external_ids?api_key=dfa4c2c7c1de1005adee824dc5593672`
        );
        if (tmdbRes.ok) {
          const tmdbData = await tmdbRes.json();
          imdbId = tmdbData.imdb_id || '';
        }
      } catch (err) {
        console.error('Failed to fetch IMDb ID from TMDb:', err);
      }

      // 2. Fetch Stremio Cloud OpenSubtitles
      const cloudSubtitles: { label: string; src: string; lang: string }[] = [];
      if (imdbId) {
        try {
          const stremioUrl = mediaType === 'movie'
            ? `https://opensubtitles-v3.strem.io/subtitles/movie/${imdbId}.json`
            : `https://opensubtitles-v3.strem.io/subtitles/series/${imdbId}:${season}:${episode}.json`;
            
          const stremioRes = await fetch(stremioUrl);
          if (stremioRes.ok) {
            const stremioData = await stremioRes.json();
            if (stremioData && stremioData.subtitles) {
              stremioData.subtitles.forEach((s: any) => {
                const mapped = ISO_MAP[s.lang] || { label: s.lang.toUpperCase(), code: s.lang };
                cloudSubtitles.push({
                  label: `${mapped.label} (Cloud)`,
                  src: s.url,
                  lang: `${mapped.code}-cloud-${s.id}`
                });
              });
            }
          }
        } catch (err) {
          console.error('Failed to fetch cloud subtitles from Stremio:', err);
        }
      }

      // 3. Query Moviebox API for stream URLs and subtitles
      const url = `/api/moviebox?title=${encodeURIComponent(title)}&type=${mediaType}&season=${season}&episode=${episode}`;
      const res = await fetch(url);
      if (!res.ok) {
        throw new Error('Failed to resolve stream link from Moviebox.');
      }
      const data = await res.json();
      if (!data || !data.streamUrl) {
        throw new Error('No working stream found on Moviebox.');
      }

      // Merge Moviebox subtitles with Stremio cloud subtitles
      const mergedSubtitles = [
        ...(data.subtitles || []).map((sub: any) => ({
          ...sub,
          label: `${sub.label} (Moviebox)`
        })),
        ...cloudSubtitles
      ];

      const enrichedData = {
        ...data,
        subtitles: mergedSubtitles
      };
      setMovieboxData(enrichedData);
      
      const streamUrlWithProxy = `https://proxy.moovie.fun/${encodeURIComponent(data.streamUrl)}`;
      setResolvedStreamUrl(streamUrlWithProxy);
    } catch (err: any) {
      const errMsg = err.message || 'Stream link resolution failed.';
      setResolveError(errMsg);
      setFallbackMessage('Content not found on Moviebox. Automatically switching to high-reliability server (VIDSRC) in 2.5 seconds...');
      
      // Automatically switch to backup server after 2.5 seconds!
      setTimeout(() => {
        setSelectedPlayer('vidsrc');
        setResolveError(null);
        setFallbackMessage(null);
      }, 2500);
    } finally {
      setIsResolving(false);
    }
  };

  // Scrape stream links immediately upon dialog opening or episode/season changes
  useEffect(() => {
    if (isOpen) {
      setSelectedPlayer('moviebox');
      setMovieboxData(null);
      setResolvedStreamUrl('');
      setResolveError(null);
      setFallbackMessage(null);
      fetchMoviebox();
    } else {
      // Clear data on dialog close to save memory and stop audio
      setMovieboxData(null);
      setResolvedStreamUrl('');
      if (artInstanceRef.current) {
        artInstanceRef.current.destroy(false);
        artInstanceRef.current = null;
      }
    }
  }, [isOpen, season, episode]);

  // ArtPlayer Instantiation Hook
  useEffect(() => {
    if (selectedPlayer !== 'moviebox' || !resolvedStreamUrl || !artRef.current) return;

    // Clean up any existing Artplayer instance
    if (artInstanceRef.current) {
      artInstanceRef.current.destroy(false);
      artInstanceRef.current = null;
    }

    // Build subtitle selectors for control panel
    const subtitleSelector = [
      {
        default: true,
        html: 'Off',
        url: '',
      },
      ...(movieboxData?.subtitles || []).map((sub: any) => ({
        html: sub.label,
        url: `https://proxy.moovie.fun/${encodeURIComponent(sub.src)}`,
      }))
    ];

    // Identify standard English subtitle to auto-enable
    const defaultSub = (movieboxData?.subtitles || []).find(
      (sub: any) => sub.lang === 'en' || sub.lang.startsWith('en-cloud') || sub.lang.startsWith('eng-cloud')
    );
    const defaultSubUrl = defaultSub ? `https://proxy.moovie.fun/${encodeURIComponent(defaultSub.src)}` : '';

    // Create a new premium Artplayer instance
    const art = new Artplayer({
      container: artRef.current,
      url: resolvedStreamUrl,
      poster: posterPath ? `https://image.tmdb.org/t/p/original${posterPath}` : '',
      volume: 1.0,
      autoplay: true,
      muted: false,
      pip: true,
      autoSize: true,
      playbackRate: true,
      aspectRatio: true,
      setting: true,
      fullscreen: true,
      miniProgressBar: true,
      theme: '#E50914', // Premium Netflix Red Theme!
      lang: 'en',
      moreVideoAttr: {
        crossOrigin: 'anonymous',
        playsInline: true,
      },
      subtitle: defaultSubUrl ? {
        url: defaultSubUrl,
        type: 'srt',
        style: {
          color: '#ffffff',
          fontSize: '24px',
          textShadow: '0 2px 4px rgba(0,0,0,0.95)',
          fontFamily: "'Helvetica Neue', Arial, sans-serif",
          fontWeight: 'medium',
        },
      } : undefined,
      controls: [
        // 1. Subtitles Selector Dropdown
        {
          name: 'subtitle-selector',
          position: 'right',
          html: 'Subtitles',
          selector: subtitleSelector,
          onSelect: function (item: any) {
            if (item.url) {
              art.subtitle.url = item.url;
              art.subtitle.show = true;
            } else {
              art.subtitle.show = false;
            }
            return item.html;
          },
        },
        // 2. Qualities Switcher Dropdown (if options returned)
        ...(movieboxData?.options && movieboxData.options.length > 0 ? [
          {
            name: 'quality-selector',
            position: 'right',
            html: 'Quality',
            selector: movieboxData.options.map((opt: any, idx: number) => ({
              default: idx === 0,
              html: opt.label,
              url: opt.url,
            })),
            onSelect: function (item: any) {
              art.switchUrl(item.url);
              return item.html;
            }
          }
        ] : [])
      ]
    });

    artInstanceRef.current = art;

    // Track watching history on playback start
    art.on('play', () => {
      const username = getCurrentUser();
      if (username && mediaId) {
        addToHistory(username, {
          id: mediaId,
          media_type: mediaType || 'movie',
          title: title || '',
          poster_path: posterPath || null
        });
      }
    });

    // Handle stream playback issues
    art.on('error', () => {
      setResolveError('Video stream failed due to direct server target connection loss.');
      setFallbackMessage('Switching to high-reliability backup stream server (VIDSRC) in 2.5 seconds...');
      setTimeout(() => {
        setSelectedPlayer('vidsrc');
        setResolveError(null);
        setFallbackMessage(null);
      }, 2500);
    });

    return () => {
      if (art && art.destroy) {
        art.destroy(false);
      }
    };
  }, [resolvedStreamUrl, selectedPlayer]);

  const handlePlayerSelect = (player: PlayerKey) => {
    setSelectedPlayer(player);
    // Destroy Artplayer instance if shifting away from moviebox
    if (player !== 'moviebox' && artInstanceRef.current) {
      artInstanceRef.current.destroy(false);
      artInstanceRef.current = null;
    }
  };

  const getIframeSource = () => {
    if (mediaType === 'movie') {
      if (selectedPlayer === 'vidplus') return `https://player.vidplus.to/embed/movie/${mediaId}`;
      if (selectedPlayer === 'videasy') return `https://player.videasy.net/movie/${mediaId}`;
      if (selectedPlayer === 'vidsrc') return `https://vidsrc-embed.ru/embed/movie?tmdb=${mediaId}&autoplay=1`;
    } else {
      if (selectedPlayer === 'vidplus') return `https://player.vidplus.to/embed/tv/${mediaId}/${season}/${episode}`;
      if (selectedPlayer === 'videasy') return `https://player.videasy.net/tv/${mediaId}/${season}/${episode}?nextEpisode=true&autoplayNextEpisode=true&episodeSelector=true`;
      if (selectedPlayer === 'vidsrc') return `https://vidsrc-embed.ru/embed/tv?tmdb=${mediaId}&season=${season}&episode=${episode}&autoplay=1&autonext=1`;
    }
    return '';
  };

  return (
    <Dialog open={isOpen} onOpenChange={setIsOpen}>
      <DialogTrigger asChild>
        <button className="flex items-center gap-2.5 bg-[#E50914] hover:bg-red-700 text-white rounded-xl px-7 py-4 text-sm font-bold tracking-wide transition-all shadow-lg shadow-red-950/20 active:scale-95">
          <Play className="w-5 h-5 fill-white" /> Watch Now
        </button>
      </DialogTrigger>

      <DialogContent className="max-w-screen-xl w-[95vw] h-[85vh] p-0 bg-black border border-white/10 rounded-2xl shadow-2xl flex flex-col overflow-hidden">
        <DialogTitle className="sr-only">{title || 'Video Player'}</DialogTitle>

        {/* Row 1: Header Bar (Always visible at the top, holds server switcher and close button) */}
        <div className="w-full p-4 bg-zinc-950/90 border-b border-white/5 flex flex-wrap items-center justify-between gap-4 shrink-0 z-20 relative">
          <div className="flex items-center gap-2 bg-black/60 border border-white/5 rounded-full p-1.5 backdrop-blur-md">
            <button
              type="button"
              onClick={() => handlePlayerSelect('moviebox')}
              className={cn(
                'rounded-full px-3 py-1.5 text-xs font-semibold tracking-wide transition-all',
                selectedPlayer === 'moviebox'
                  ? 'bg-[#E50914] text-white shadow-md'
                  : 'text-zinc-300 hover:text-white hover:bg-white/10',
              )}
            >
              Moviebox Direct (Default)
            </button>
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
          </div>
          <DialogClose className="bg-zinc-950/40 hover:bg-white/20 text-white rounded-full p-2.5 backdrop-blur-md transition-colors border border-white/5">
            <X className="w-5 h-5" />
          </DialogClose>
        </div>

        {/* Row 2: Video Player Main Viewport (Fills all remaining vertical space) */}
        <div className="flex-1 w-full relative bg-black min-h-0 flex items-center justify-center overflow-hidden">
          {selectedPlayer !== 'moviebox' ? (
            <>
              {/* Smart Fallback Assist floating pill */}
              <div className="absolute top-4 left-1/2 -translate-x-1/2 z-30 bg-black/85 border border-white/10 backdrop-blur-md rounded-full px-4.5 py-2.5 flex items-center gap-3 animate-fade-in shadow-2xl pointer-events-auto">
                <span className="text-zinc-400 text-xs font-semibold tracking-wide">Not playing or showing 404?</span>
                <div className="flex gap-2">
                  {(['moviebox', 'vidplus', 'videasy', 'vidsrc'] as PlayerKey[]).filter(p => p !== selectedPlayer).map((p) => (
                    <button
                      key={p}
                      onClick={() => handlePlayerSelect(p)}
                      className="bg-white/10 hover:bg-[#E50914] text-white rounded-full px-3 py-1.5 text-[9px] font-extrabold uppercase tracking-widest transition-all"
                    >
                      Try {p === 'moviebox' ? 'Moviebox' : (p === 'vidplus' ? 'VidPlus' : p.toUpperCase())}
                    </button>
                  ))}
                </div>
              </div>
              
              <iframe
                src={getIframeSource()}
                className="w-full h-full"
                frameBorder="0"
                allowFullScreen
                allow="autoplay; encrypted-media"
                title="Video Player"
              ></iframe>
            </>
          ) : (
            <div className="w-full h-full relative bg-black flex items-center justify-center">
              {isResolving && (
                <div className="absolute inset-0 flex flex-col items-center justify-center bg-black/90 z-20 gap-4 text-center p-6">
                  <Loader2 className="w-12 h-12 text-[#E50914] animate-spin" />
                  <div>
                    <h4 className="text-white font-medium text-lg tracking-wide">Resolving Stream</h4>
                    <p className="text-zinc-500 text-sm max-w-sm mt-1">Scraping high-speed direct streams and WebVTT captions...</p>
                  </div>
                </div>
              )}

              {resolveError && (
                <div className="absolute inset-0 flex flex-col items-center justify-center bg-black/95 z-20 gap-4 text-center p-6 text-white">
                  <AlertCircle className="w-14 h-14 text-[#E50914]" />
                  <div>
                    <h4 className="text-white font-semibold text-lg">Failed to Resolve Moviebox Source</h4>
                    <p className="text-zinc-500 text-sm max-w-md mt-2 font-mono text-xs bg-zinc-900 border border-white/5 p-3 rounded-lg">{resolveError}</p>
                    {fallbackMessage && (
                      <p className="text-yellow-400 text-xs font-semibold mt-4 tracking-wide animate-pulse">
                        ⚠️ {fallbackMessage}
                      </p>
                    )}
                  </div>
                  {!fallbackMessage && (
                    <button 
                      onClick={fetchMoviebox} 
                      className="flex items-center gap-2 bg-[#E50914] hover:bg-red-700 text-white rounded-lg px-6 py-3 text-xs font-bold transition-all shadow-md active:scale-95"
                    >
                      <RefreshCw className="w-3.5 h-3.5" /> Retry Connection
                    </button>
                  )}
                </div>
              )}

              {/* ArtPlayer Container Mount point */}
              {resolvedStreamUrl && (
                <div ref={artRef} className="w-full h-full bg-black z-0" />
              )}
            </div>
          )}
        </div>

        {/* Row 3: Footer bar (Always visible at the bottom when moviebox resolves, never overlaps!) */}
        {selectedPlayer === 'moviebox' && movieboxData && (
          <div className="w-full p-4 bg-zinc-950/90 border-t border-white/5 flex flex-col md:flex-row items-center justify-between gap-4 shrink-0 z-20 relative">
            <div className="text-left">
              <h4 className="text-white font-semibold text-sm truncate max-w-[280px] md:max-w-[400px]">{title}</h4>
              <p className="text-zinc-500 text-[10px] font-mono mt-0.5 flex items-center gap-1">
                <Info className="w-3.5 h-3.5 text-[#E50914]" /> Subtitles parsed in real-time. Built-in quality switcher loaded!
              </p>
            </div>

            <div className="flex flex-wrap items-center gap-2">
              {/* Quality option label indicator */}
              {movieboxData.options && movieboxData.options.length > 0 && (
                <div className="flex items-center gap-1.5 rounded-lg border border-white/10 bg-zinc-950 px-2.5 py-1.5 text-xs text-zinc-300 font-mono">
                  <span className="text-zinc-500 font-bold uppercase tracking-wider text-[9px]">Default:</span>
                  <span className="text-[#E50914] font-semibold">{movieboxData.options[0].label}</span>
                </div>
              )}

              {/* Direct Video Download link */}
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

              {/* Subtitle direct download options */}
              {movieboxData.subtitles && movieboxData.subtitles.length > 0 && (
                <div className="relative group">
                  <button className="flex items-center gap-1.5 border border-white/10 hover:bg-white/5 text-zinc-300 rounded-lg px-4 py-2 text-xs font-semibold transition-all">
                    <Download className="w-3.5 h-3.5 text-zinc-500" /> Subtitles ({movieboxData.subtitles.length})
                  </button>
                  <div className="absolute bottom-full right-0 mb-2 w-48 rounded-lg border border-white/10 bg-zinc-950 p-1 opacity-0 pointer-events-none group-hover:opacity-100 group-hover:pointer-events-auto transition-all shadow-xl z-50 max-h-48 overflow-y-auto">
                    {movieboxData.subtitles.map((sub, i) => (
                      <a
                        key={i}
                        href={sub.src}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="block rounded px-2.5 py-1.5 text-left text-[11px] text-zinc-300 hover:bg-red-950/20 hover:text-red-400 transition-colors"
                      >
                        {sub.label}
                      </a>
                    ))}
                  </div>
                </div>
              )}
            </div>
          </div>
        )}
      </DialogContent>
    </Dialog>
  );
}
