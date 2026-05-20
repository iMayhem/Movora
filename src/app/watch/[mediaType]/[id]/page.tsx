'use client';

import { Suspense } from 'react';
import { useSearchParams } from 'next/navigation';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { ArrowLeft } from 'lucide-react';
import { cn } from '@/lib/utils';

type PlayerKey = 'vidplus' | 'videasy' | 'vidsrc';

function WatchPageContent({ params }: { params: { mediaType: 'movie' | 'tv', id: string }}) {
    const searchParams = useSearchParams();
    const season = searchParams.get('s') || '1';
    const episode = searchParams.get('e') || '1';
    const player = (searchParams.get('player') as PlayerKey) || 'vidplus';

    const sources: Record<PlayerKey, string> = {
        vidplus: params.mediaType === 'movie'
            ? `https://player.vidplus.to/embed/movie/${params.id}`
            : `https://player.vidplus.to/embed/tv/${params.id}/${season}/${episode}`,
        videasy: params.mediaType === 'movie'
            ? `https://player.videasy.net/movie/${params.id}`
            : `https://player.videasy.net/tv/${params.id}/${season}/${episode}?nextEpisode=true&autoplayNextEpisode=true&episodeSelector=true`,
        vidsrc: params.mediaType === 'movie'
            ? `https://vidsrc-embed.ru/embed/movie?tmdb=${params.id}&autoplay=1`
            : `https://vidsrc-embed.ru/embed/tv?tmdb=${params.id}&season=${season}&episode=${episode}&autoplay=1&autonext=1`,
    };

    const src = sources[player] || sources.vidplus;

    const mkHref = (nextPlayer: PlayerKey) => {
        const sp = new URLSearchParams(searchParams.toString());
        sp.set('player', nextPlayer);
        return `/watch/${params.mediaType}/${params.id}?${sp.toString()}`;
    };

    return (
        <div className="fixed inset-0 bg-black flex flex-col z-[100]">
            <div className="absolute top-0 left-0 w-full p-4 z-20 bg-gradient-to-b from-black/80 to-transparent opacity-0 hover:opacity-100 transition-opacity duration-300">
                <div className="flex items-center justify-between gap-4">
                    <Link href={params.mediaType === 'movie' ? `/movie/${params.id}` : `/tv/${params.id}`}>
                        <Button variant="ghost" className="text-white hover:bg-white/20">
                            <ArrowLeft className="mr-2 h-4 w-4" />
                            Back to Details
                        </Button>
                    </Link>
                    <div className="flex items-center gap-1 rounded-full border border-white/20 bg-black/50 p-1 backdrop-blur-md">
                        {(['vidplus', 'videasy', 'vidsrc'] as PlayerKey[]).map((p) => (
                            <Link key={p} href={mkHref(p)}>
                                <span
                                    className={cn(
                                        'inline-block rounded-full px-3 py-1 text-xs font-medium transition-colors text-white/80 hover:bg-white/10 hover:text-white',
                                        player === p && 'bg-primary text-primary-foreground hover:bg-primary',
                                    )}
                                >
                                    {p.toUpperCase()}
                                </span>
                            </Link>
                        ))}
                    </div>
                </div>
            </div>
            <iframe
                src={src}
                className="w-full h-full"
                frameBorder="0"
                allowFullScreen
                title="Video Player"
            ></iframe>
        </div>
    );
}

export default function WatchPage({ params }: { params: { mediaType: 'movie' | 'tv', id:string }}) {
    return (
        <Suspense fallback={
            <div className="fixed inset-0 bg-black flex items-center justify-center">
                <div className="flex flex-col items-center gap-4">
                    <div className="w-12 h-12 border-4 border-primary border-t-transparent rounded-full animate-spin"></div>
                    <p className="text-white font-medium">Loading Stream...</p>
                </div>
            </div>
        }>
            <WatchPageContent params={params} />
        </Suspense>
    )
}
