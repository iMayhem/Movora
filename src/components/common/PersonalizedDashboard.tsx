'use client';

import { useState, useEffect } from 'react';
import { getCurrentUser, getHistory, getLikes, getWatchLater, HistoryItem } from '@/lib/auth';
import { getMovieDetails, getTvShowDetails, discoverMovies, discoverTvShows } from '@/lib/tmdb';
import type { Media } from '@/types/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import { Loader2, Heart, Clock, Compass, Bookmark } from 'lucide-react';

export function PersonalizedDashboard() {
    const [username, setUsername] = useState<string | null>(null);
    const [history, setHistory] = useState<HistoryItem[]>([]);
    const [likedMedia, setLikedMedia] = useState<Media[]>([]);
    const [watchLaterMedia, setWatchLaterMedia] = useState<Media[]>([]);
    const [recommendations, setRecommendations] = useState<Media[]>([]);
    
    const [loadingLikes, setLoadingLikes] = useState(false);
    const [loadingWatchLater, setLoadingWatchLater] = useState(false);
    const [loadingRecs, setLoadingRecs] = useState(false);

    const loadUserData = async () => {
        if (typeof window === 'undefined') return;
        
        const currentUser = getCurrentUser();
        setUsername(currentUser);
        
        if (!currentUser) {
            setHistory([]);
            setLikedMedia([]);
            setWatchLaterMedia([]);
            setRecommendations([]);
            return;
        }

        // 1. History
        const userHistory = getHistory(currentUser);
        setHistory(userHistory);

        // 2. Liked Items (Resolve TMDB)
        const likedIds = getLikes(currentUser);
        if (likedIds.length > 0) {
            setLoadingLikes(true);
            try {
                const resolved = await Promise.all(
                    likedIds.slice(0, 10).map(async (id) => {
                        // First try movie, then TV
                        try {
                            const movie = await getMovieDetails(id);
                            if (movie) return movie;
                        } catch {}
                        try {
                            const tv = await getTvShowDetails(id);
                            if (tv) return tv;
                        } catch {}
                        return null;
                    })
                );
                setLikedMedia(resolved.filter((item): item is Media => item !== null));
            } catch (e) {
                console.error(e);
            } finally {
                setLoadingLikes(false);
            }
        } else {
            setLikedMedia([]);
        }

        // 3. Watch Later Items (Resolve TMDB)
        const watchLaterIds = getWatchLater(currentUser);
        if (watchLaterIds.length > 0) {
            setLoadingWatchLater(true);
            try {
                const resolved = await Promise.all(
                    watchLaterIds.slice(0, 10).map(async (id) => {
                        try {
                            const movie = await getMovieDetails(id);
                            if (movie) return movie;
                        } catch {}
                        try {
                            const tv = await getTvShowDetails(id);
                            if (tv) return tv;
                        } catch {}
                        return null;
                    })
                );
                setWatchLaterMedia(resolved.filter((item): item is Media => item !== null));
            } catch (e) {
                console.error(e);
            } finally {
                setLoadingWatchLater(false);
            }
        } else {
            setWatchLaterMedia([]);
        }

        // 4. Custom Recommendations based on Liked Genres
        setLoadingRecs(true);
        try {
            let genreIds: number[] = [];
            
            // Gather genres from liked media
            if (likedIds.length > 0) {
                const details = await Promise.all(
                    likedIds.slice(0, 3).map(async (id) => {
                        try {
                            const movie = await getMovieDetails(id);
                            if (movie) return movie;
                        } catch {}
                        try {
                            const tv = await getTvShowDetails(id);
                            if (tv) return tv;
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

            {/* Row 2: Watch Later */}
            {watchLaterMedia.length > 0 && (
                <section>
                    <div className="flex items-center gap-2 mb-6">
                        <Bookmark className="w-5 h-5 text-indigo-400" />
                        <h2 className="font-headline text-2xl font-bold text-gradient">My Watch Later</h2>
                    </div>
                    {loadingWatchLater ? (
                        <div className="flex justify-center py-6"><Loader2 className="w-6 h-6 animate-spin text-indigo-500" /></div>
                    ) : (
                        <MovieList initialMedia={watchLaterMedia} carousel />
                    )}
                </section>
            )}

            {/* Row 3: Liked Movies & TV Shows */}
            {likedMedia.length > 0 && (
                <section>
                    <div className="flex items-center gap-2 mb-6">
                        <Heart className="w-5 h-5 text-rose-400 fill-rose-400/20" />
                        <h2 className="font-headline text-2xl font-bold text-gradient">My Liked List</h2>
                    </div>
                    {loadingLikes ? (
                        <div className="flex justify-center py-6"><Loader2 className="w-6 h-6 animate-spin text-rose-500" /></div>
                    ) : (
                        <MovieList initialMedia={likedMedia} carousel />
                    )}
                </section>
            )}

            {/* Row 4: Customized Recommendations */}
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
