'use client';

import { Suspense } from 'react';
import { useSearchParams } from 'next/navigation';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { ArrowLeft } from 'lucide-react';

function WatchPageContent({ params }: { params: { mediaType: 'movie' | 'tv', id: string }}) {
    const searchParams = useSearchParams();
    const season = searchParams.get('s');
    const episode = searchParams.get('e');

    const src = params.mediaType === 'movie'
        ? `https://player.vidplus.to/embed/movie/${params.id}`
        : `https://player.vidplus.to/embed/tv/${params.id}/${season || 1}/${episode || 1}`;

    return (
        <div className="fixed inset-0 bg-black flex flex-col z-[100]">
            <div className="absolute top-0 left-0 w-full p-4 z-20 bg-gradient-to-b from-black/80 to-transparent opacity-0 hover:opacity-100 transition-opacity duration-300 pointer-events-none hover:pointer-events-auto">
                <Link href={params.mediaType === 'movie' ? `/movie/${params.id}` : `/tv/${params.id}`}>
                    <Button variant="ghost" className="text-white pointer-events-auto hover:bg-white/20">
                        <ArrowLeft className="mr-2 h-4 w-4" />
                        Back to Details
                    </Button>
                </Link>
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