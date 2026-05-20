'use client';

import { useState, useEffect } from 'react';
import type { Media } from '@/types/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import { getMovieDetails, getTvShowDetails } from '@/lib/tmdb';
import { Loader2 } from 'lucide-react';
import type { SimklItem } from '@/lib/simkl';

export function SimklWatchlistSection() {
    const [watchlist, setWatchlist] = useState<Media[]>([]);
    const [loading, setLoading] = useState<boolean>(false);
    const [isConnected, setIsConnected] = useState<boolean>(false);

    const loadSimklWatchlist = async () => {
        if (typeof window === 'undefined') return;

        const token = localStorage.getItem('simkl_access_token');
        if (!token) {
            setIsConnected(false);
            setWatchlist([]);
            return;
        }

        setIsConnected(true);
        const simklMovies: SimklItem[] = JSON.parse(localStorage.getItem('simkl_movies') || '[]');
        const simklShows: SimklItem[] = JSON.parse(localStorage.getItem('simkl_shows') || '[]');

        if (simklMovies.length === 0 && simklShows.length === 0) {
            setWatchlist([]);
            return;
        }

        setLoading(true);

        try {
            // Take the top 8 movies and top 8 shows to keep it super fast & optimized
            const topMovies = simklMovies.slice(0, 8);
            const topShows = simklShows.slice(0, 8);

            const fetchedMedia: Media[] = [];

            // Resolve Movie TMDB Details
            await Promise.all(
                topMovies.map(async (item) => {
                    const tmdbId = item.movie?.ids.tmdb;
                    if (tmdbId) {
                        try {
                            const details = await getMovieDetails(Number(tmdbId));
                            if (details) {
                                fetchedMedia.push(details);
                            }
                        } catch (e) {
                            console.error('Failed to resolve movie TMDB:', tmdbId, e);
                        }
                    }
                })
            );

            // Resolve TV Show TMDB Details
            await Promise.all(
                topShows.map(async (item) => {
                    const tmdbId = item.show?.ids.tmdb;
                    if (tmdbId) {
                        try {
                            const details = await getTvShowDetails(Number(tmdbId));
                            if (details) {
                                fetchedMedia.push(details);
                            }
                        } catch (e) {
                            console.error('Failed to resolve show TMDB:', tmdbId, e);
                        }
                    }
                })
            );

            // Sort them: combined results
            setWatchlist(fetchedMedia);
        } catch (error) {
            console.error('Error resolving watchlist details:', error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        loadSimklWatchlist();

        window.addEventListener('simkl_sync_complete', loadSimklWatchlist);
        return () => window.removeEventListener('simkl_sync_complete', loadSimklWatchlist);
    }, []);

    if (!isConnected || (watchlist.length === 0 && !loading)) {
        return null; // Don't show anything if not connected or empty
    }

    return (
        <section className="animate-fade-in">
            <div className="flex justify-between items-center mb-6">
                <div className="flex items-center gap-2">
                    <h2 className="font-headline text-3xl font-bold text-gradient">My Simkl Watchlist</h2>
                    <span className="text-[10px] bg-violet-500/10 text-violet-400 font-bold border border-violet-500/20 px-2 py-0.5 rounded-full uppercase tracking-wider">Synced</span>
                </div>
            </div>

            {loading ? (
                <div className="flex items-center justify-center py-10 gap-2 text-sm text-muted-foreground bg-zinc-950/20 border border-zinc-900 rounded-xl">
                    <Loader2 className="w-4 h-4 animate-spin text-violet-500" />
                    <span>Resolving watchlists from TMDB...</span>
                </div>
            ) : (
                <MovieList initialMedia={watchlist} carousel />
            )}
        </section>
    );
}
