'use client';

import { useState, useEffect } from 'react';
import { Sheet, SheetContent, SheetHeader, SheetTitle, SheetDescription } from '@/components/ui/sheet';
import { getCurrentUser, getLikes, getWatchLater, toggleLike, toggleWatchLater } from '@/lib/auth';
import { getMovieDetails, getTvShowDetails } from '@/lib/tmdb';
import type { Media } from '@/types/tmdb';
import { Loader2, Heart, Bookmark, Trash2, Play } from 'lucide-react';
import Link from 'next/link';
import Image from 'next/image';

interface PersonalizedListDrawerProps {
    type: 'likes' | 'watchlater';
    isOpen: boolean;
    onClose: () => void;
}

export function PersonalizedListDrawer({ type, isOpen, onClose }: PersonalizedListDrawerProps) {
    const [username, setUsername] = useState<string | null>(null);
    const [items, setItems] = useState<Media[]>([]);
    const [loading, setLoading] = useState<boolean>(false);

    const loadItems = async () => {
        if (typeof window === 'undefined' || !isOpen) return;

        const currentUser = getCurrentUser();
        setUsername(currentUser);

        if (!currentUser) {
            setItems([]);
            return;
        }

        const ids = type === 'likes' ? getLikes(currentUser) : getWatchLater(currentUser);
        if (ids.length === 0) {
            setItems([]);
            return;
        }

        setLoading(true);

        try {
            const resolved = await Promise.all(
                ids.map(async (id) => {
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
            setItems(resolved.filter((item): item is Media => item !== null));
        } catch (e) {
            console.error('Error resolving list items:', e);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        loadItems();
    }, [isOpen, type]);

    const handleRemove = (id: number) => {
        if (!username) return;
        
        if (type === 'likes') {
            toggleLike(username, id);
        } else {
            toggleWatchLater(username, id);
        }
        
        // Optimistic UI removal update
        setItems(prev => prev.filter(item => item.id !== id));
    };

    const titleText = type === 'likes' ? 'My Liked List' : 'My Watchlist';
    const descriptionText = type === 'likes' 
        ? 'Your curated list of favorite movies and TV shows.' 
        : 'Movies and TV shows you saved to watch later.';

    return (
        <Sheet open={isOpen} onOpenChange={(open) => !open && onClose()}>
            <SheetContent className="w-full sm:max-w-md bg-zinc-950 border-zinc-800 text-white p-6 flex flex-col h-full shadow-2xl">
                <SheetHeader className="pb-4 border-b border-zinc-900">
                    <SheetTitle className="text-xl font-bold flex items-center gap-2">
                        {type === 'likes' ? <Heart className="w-5 h-5 text-rose-500 fill-rose-500" /> : <Bookmark className="w-5 h-5 text-indigo-500 fill-indigo-500" />}
                        <span className="font-headline">{titleText}</span>
                    </SheetTitle>
                    <SheetDescription className="text-zinc-400 text-xs">
                        {descriptionText}
                    </SheetDescription>
                </SheetHeader>

                <div className="flex-1 overflow-y-auto mt-4 pr-1 space-y-4 select-none scrollbar-thin scrollbar-thumb-zinc-800 scrollbar-track-transparent">
                    {loading ? (
                        <div className="flex flex-col items-center justify-center h-48 gap-2 text-zinc-500">
                            <Loader2 className="w-6 h-6 animate-spin text-violet-500" />
                            <span className="text-xs">Resolving items from TMDB...</span>
                        </div>
                    ) : items.length === 0 ? (
                        <div className="flex flex-col items-center justify-center h-48 gap-2 text-center px-4 text-zinc-500 border border-dashed border-zinc-900 rounded-xl">
                            <span className="text-2xl">🍿</span>
                            <span className="text-xs font-medium">Your list is currently empty.</span>
                        </div>
                    ) : (
                        items.map((item) => {
                            const href = item.media_type === 'movie' ? `/movie/${item.id}` : `/tv/${item.id}`;
                            const title = item.media_type === 'movie' ? item.title : item.name;
                            const rating = item.vote_average ? item.vote_average.toFixed(1) : null;
                            const poster = item.poster_path ? `https://image.tmdb.org/t/p/w92${item.poster_path}` : 'https://placehold.co/92x138/202020/FFFFFF.png?text=No+Image';

                            return (
                                <div 
                                    key={item.id} 
                                    className="flex items-center gap-3 p-2 bg-zinc-900/40 hover:bg-zinc-900/80 border border-zinc-900/60 rounded-xl group transition-all duration-200"
                                >
                                    {/* Thumbnail Poster */}
                                    <Link href={href} onClick={onClose} className="relative w-12 aspect-[2/3] rounded-lg overflow-hidden shrink-0 border border-zinc-800">
                                        <Image 
                                            src={poster} 
                                            alt={title}
                                            fill
                                            className="object-cover group-hover:scale-105 transition-transform duration-300"
                                            sizes="48px"
                                        />
                                    </Link>

                                    {/* Details */}
                                    <div className="flex-1 min-w-0">
                                        <Link href={href} onClick={onClose}>
                                            <h4 className="font-semibold text-xs text-zinc-200 hover:text-white truncate" title={title}>
                                                {title}
                                            </h4>
                                        </Link>
                                        <div className="flex items-center gap-2 mt-1 text-[10px] text-zinc-500 font-medium">
                                            {rating && (
                                                <span className="flex items-center gap-0.5 bg-zinc-950 px-1.5 py-0.5 rounded text-amber-400 font-bold border border-zinc-800">
                                                    ★ {rating}
                                                </span>
                                            )}
                                            <span className="capitalize">{item.media_type}</span>
                                        </div>
                                    </div>

                                    {/* Actions */}
                                    <div className="flex items-center gap-1">
                                        <Link 
                                            href={href} 
                                            onClick={onClose}
                                            className="p-2 rounded-full hover:bg-violet-950/20 text-zinc-400 hover:text-violet-400 transition-colors"
                                            title="Play Now"
                                        >
                                            <Play className="w-4 h-4 fill-current" />
                                        </Link>
                                        <button 
                                            onClick={() => handleRemove(item.id)}
                                            className="p-2 rounded-full hover:bg-rose-950/20 text-zinc-500 hover:text-rose-400 transition-colors"
                                            title="Remove Item"
                                        >
                                            <Trash2 className="w-4 h-4" />
                                        </button>
                                    </div>
                                </div>
                            );
                        })
                    )}
                </div>
            </SheetContent>
        </Sheet>
    );
}
