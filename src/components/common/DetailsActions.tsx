'use client';

import { useState, useEffect } from 'react';
import { Heart, Bookmark, Users } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { getCurrentUser, getLikes, getWatchLater, toggleLike, toggleWatchLater } from '@/lib/auth';
import { cn } from '@/lib/utils';
import { AuthModal } from './AuthModal';

interface DetailsActionsProps {
    mediaId: number;
    mediaType: 'movie' | 'tv';
    title: string;
    posterPath: string | null;
}

export function DetailsActions({ mediaId, mediaType, title, posterPath }: DetailsActionsProps) {
    const [username, setUsername] = useState<string | null>(null);
    const [isLiked, setIsLiked] = useState<boolean>(false);
    const [isWatchLater, setIsWatchLater] = useState<boolean>(false);
    const [isAuthOpen, setIsAuthOpen] = useState<boolean>(false);

    const updateStates = () => {
        const user = getCurrentUser();
        setUsername(user);
        if (user) {
            setIsLiked(getLikes(user).some(item => item.id === mediaId && item.type === mediaType));
            setIsWatchLater(getWatchLater(user).some(item => item.id === mediaId && item.type === mediaType));
        } else {
            setIsLiked(false);
            setIsWatchLater(false);
        }
    };

    useEffect(() => {
        updateStates();
        window.addEventListener('movora_auth_change', updateStates);
        return () => window.removeEventListener('movora_auth_change', updateStates);
    }, [mediaId]);

    const handleLike = () => {
        if (!username) {
            setIsAuthOpen(true);
            return;
        }
        const state = toggleLike(username, mediaId, mediaType);
        setIsLiked(state);
    };

    const handleWatchLater = () => {
        if (!username) {
            setIsAuthOpen(true);
            return;
        }
        const state = toggleWatchLater(username, mediaId, mediaType);
        setIsWatchLater(state);
    };

    return (
        <div className="flex flex-wrap gap-3 mt-4 items-center">
            {/* Watch Together Action Pill */}
            <a 
              href={`/party/?room=${mediaId}&title=${encodeURIComponent(title)}`}
              className="inline-flex items-center gap-2 rounded-full bg-zinc-950 hover:bg-zinc-900 text-zinc-300 hover:text-white font-semibold py-2 px-5 text-xs md:text-sm transition-all duration-200 border border-zinc-800 hover:border-zinc-700 shadow-md hover:scale-[1.02] active:scale-[0.98]"
            >
              <Users className="w-4 h-4 text-violet-500" />
              <span>Watch Together</span>
            </a>

            {/* Like Action Pill */}
            <Button 
                onClick={handleLike}
                variant="ghost"
                className={cn(
                    "rounded-full border text-xs font-semibold py-2 px-5 h-auto transition-all duration-200 hover:scale-[1.02] active:scale-[0.98]",
                    isLiked 
                        ? "bg-rose-950/30 text-rose-400 border-rose-500/30 hover:bg-rose-950/50" 
                        : "bg-zinc-950 hover:bg-zinc-900 text-zinc-400 hover:text-white border-zinc-800 hover:border-zinc-700"
                )}
            >
                <Heart className={cn("w-4 h-4 mr-1.5 transition-transform", isLiked && "fill-rose-500 text-rose-500 scale-110")} />
                <span>{isLiked ? 'Liked' : 'Like'}</span>
            </Button>

            {/* Watch Later Action Pill */}
            <Button 
                onClick={handleWatchLater}
                variant="ghost"
                className={cn(
                    "rounded-full border text-xs font-semibold py-2 px-5 h-auto transition-all duration-200 hover:scale-[1.02] active:scale-[0.98]",
                    isWatchLater 
                        ? "bg-indigo-950/30 text-indigo-400 border-indigo-500/30 hover:bg-indigo-950/50" 
                        : "bg-zinc-950 hover:bg-zinc-900 text-zinc-400 hover:text-white border-zinc-800 hover:border-zinc-700"
                )}
            >
                <Bookmark className={cn("w-4 h-4 mr-1.5 transition-transform", isWatchLater && "fill-indigo-500 text-indigo-500 scale-110")} />
                <span>{isWatchLater ? 'Added' : 'Watch Later'}</span>
            </Button>

            <AuthModal isOpen={isAuthOpen} onClose={() => setIsAuthOpen(false)} />
        </div>
    );
}
