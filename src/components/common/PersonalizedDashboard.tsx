'use client';

import { useState, useEffect } from 'react';
import { getCurrentUser, getHistory, getLikes, HistoryItem } from '@/lib/auth';
import { getMovieDetails, getTvShowDetails, discoverMovies, discoverTvShows } from '@/lib/tmdb';
import type { Media } from '@/types/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import { Loader2, Clock, Compass } from 'lucide-react';

export function PersonalizedDashboard() {
    const [username, setUsername] = useState<string | null>(null);
    const [history, setHistory] = useState<HistoryItem[]>([]);
    const [recommendations, setRecommendations] = useState<Media[]>([]);
    const [loadingRecs, setLoadingRecs] = useState(false);

    const loadUserData = async () => {
        if (typeof window === 'undefined') return;
        
        const currentUser = getCurrentUser();
        setUsername(currentUser);
        
        if (!currentUser) {
            setHistory([]);
            setRecommendations([]);
            return;
        }

        // 1. History
        const userHistory = getHistory(currentUser);
        setHistory(userHistory);

        // 2. Custom Recommendations based on Liked Genres
        setLoadingRecs(true);
        try {
            const likedIds = getLikes(currentUser);
            let genreIds: number[] = [];
            
            // Gather genres from liked media
            if (likedIds.length > 0) {
                const details = await Promise.all(
                    likedIds.slice(0, 3).map(async (item) => {
                        try {
                            if (item.type === 'movie') {
                                const movie = await getMovieDetails(item.id);
                                if (movie) return movie;
                            } else {
                                const tv = await getTvShowDetails(item.id);
                                if (tv) return tv;
                            }
                        } catch {}
                        return null;
                    })
                );
                details.forEach(item => {
                    if (item && item.genres) {
                        item.genres.forEach(g => {
                            if (!genreIds.includes(g.id)) genreIds.push(g.id);
                        });
                    }
                });
            }

            let recList: Media[] = [];
            if (genreIds.length > 0) {
                // Find movies matching their favorite genres
                const matching = await discoverMovies({ with_genres: genreIds.slice(0, 2).join(',') });
                recList = matching.slice(0, 10);
            } else {
                // Default fallback: general popular TV Shows
                const general = await discoverTvShows();
                recList = general.slice(0, 10);
            }
            setRecommendations(recList);
        } catch (e) {
            console.error(e);
        } finally {
            setLoadingRecs(false);
        }
    };

    useEffect(() => {
        loadUserData();

        window.addEventListener('movora_auth_change', loadUserData);
        window.addEventListener('movora_userdata_change', loadUserData);
        
        return () => {
            window.removeEventListener('movora_auth_change', loadUserData);
            window.removeEventListener('movora_userdata_change', loadUserData);
        };
    }, []);

    if (!username) return null;

    // Map history item format to standard Media item format for MovieList renderer
    const historyMediaList: Media[] = history.map(item => ({
        id: item.id,
        title: item.media_type === 'movie' ? item.title : '',
        name: item.media_type === 'tv' ? item.title : '',
        overview: '',
        poster_path: item.poster_path,
        backdrop_path: null,
        release_date: '',
        first_air_date: '',
        vote_average: 0,
        genres: [],
        media_type: item.media_type,
    } as any as Media));

    return (
        <div className="space-y-12 animate-fade-in">
            {/* Row 1: Continue Watching */}
            {historyMediaList.length > 0 && (
                <section>
                    <div className="flex items-center gap-2 mb-6">
                        <Clock className="w-5 h-5 text-violet-400" />
                        <h2 className="font-headline text-2xl font-bold text-gradient">Continue Watching</h2>
                    </div>
                    <MovieList initialMedia={historyMediaList} carousel />
                </section>
            )}

            {/* Row 2: Customized Recommendations */}
            <section>
                <div className="flex items-center gap-2 mb-6">
                    <Compass className="w-5 h-5 text-emerald-400" />
                    <div className="flex items-center gap-2">
                        <h2 className="font-headline text-2xl font-bold text-gradient">Recommended For You</h2>
                        <span className="text-[9px] bg-emerald-500/10 text-emerald-400 font-bold border border-emerald-500/20 px-2 py-0.5 rounded-full uppercase tracking-wider">Customized</span>
                    </div>
                </div>
                {loadingRecs ? (
                    <div className="flex justify-center py-6"><Loader2 className="w-6 h-6 animate-spin text-emerald-500" /></div>
                ) : (
                    <MovieList initialMedia={recommendations} carousel />
                )}
            </section>
        </div>
    );
}
