import os

files = {
    # 1. CLEAN LAYOUT: Removed Mobile Debugger
    "src/components/common/MainLayout.tsx": """
'use client';

import { Header } from '@/components/common/Header';
import { Footer } from '@/components/common/Footer';
import { usePathname } from 'next/navigation';

export function MainLayout({ children }: { children: React.ReactNode }) {
    const pathname = usePathname();
    const isLandingPage = pathname === '/';
    const isWatchPage = pathname?.startsWith('/watch');

    return (
        <div className="relative flex min-h-screen flex-col bg-background text-foreground">
            {!isLandingPage && !isWatchPage && <Header />}
            <main className="flex-1 w-full">{children}</main>
            {!isLandingPage && !isWatchPage && <Footer />}
        </div>
    );
}
""",

    # 2. COMPACT GRID: Changed to grid-cols-3 and reduced gaps for mobile
    "src/components/movies/MovieList.tsx": """
'use client';

import type { Media } from '@/types/tmdb';
import { MovieCard } from './MovieCard';
import {
  Carousel,
  CarouselContent,
  CarouselItem,
  CarouselNext,
  CarouselPrevious,
} from '@/components/ui/carousel';
import { useState, useEffect, useRef, useCallback } from 'react';
import { fetchPage } from '@/lib/tmdb';
import { Skeleton } from '../ui/skeleton';

type MovieListProps = {
  initialMedia?: Media[];
  carousel?: boolean;
  slug?: string;
};

export function MovieList({ initialMedia = [], carousel = false, slug }: MovieListProps) {
  const [media, setMedia] = useState<Media[]>(initialMedia);
  const [page, setPage] = useState(2);
  const [loading, setLoading] = useState(false);
  const [hasMore, setHasMore] = useState(true);
  const loader = useRef(null);

  useEffect(() => {
    setMedia(initialMedia);
    setPage(2);
    setHasMore(initialMedia.length > 0);
    setLoading(false);
  }, [initialMedia, slug]);

  const loadMore = useCallback(async () => {
    if (loading || !hasMore || !slug) return;
    
    setLoading(true);
    try {
        const newMedia = await fetchPage(page, slug);
        
        if (newMedia && newMedia.length > 0) {
            setMedia((prev) => {
                const existingIds = new Set(prev.map(p => p.id));
                const uniqueNewMedia = newMedia.filter(m => !existingIds.has(m.id));
                
                if (uniqueNewMedia.length === 0) {
                    setHasMore(false);
                    return prev;
                }
                return [...prev, ...uniqueNewMedia];
            });
            setPage((prev) => prev + 1);
        } else {
            setHasMore(false);
        }
    } catch (error) {
        setHasMore(false); 
    } finally {
        setLoading(false);
    }
  }, [page, loading, hasMore, slug]);

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting && hasMore && !loading) {
          loadMore();
        }
      },
      { rootMargin: '400px' }
    );

    if (loader.current && !carousel) {
      observer.observe(loader.current);
    }

    return () => {
      if (loader.current && !carousel) {
        observer.unobserve(loader.current);
      }
    };
  }, [loadMore, carousel, hasMore, loading]);

  if (carousel) {
    return (
      <Carousel
        opts={{ align: 'start', dragFree: true, loop: false, containScroll: 'trimSnaps' }}
        className="w-full"
      >
        <CarouselContent className="-ml-2 pb-2">
          {media.length > 0 ? media.map((item, index) => (
            <CarouselItem key={`${item.media_type}-${item.id}-${index}`} className="pl-2 basis-[30%] sm:basis-[22%] md:basis-[18%] lg:basis-[14%] xl:basis-[12%]">
              <MovieCard item={item} compact />
            </CarouselItem>
          )) : (
             <div className="pl-4 text-muted-foreground text-xs p-4">No content found.</div>
          )}
        </CarouselContent>
      </Carousel>
    );
  }

  return (
    <>
      {media.length > 0 ? (
        // GRID OPTIMIZED: grid-cols-3 on mobile, tighter gap (gap-2)
        <div className="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-5 lg:grid-cols-6 xl:grid-cols-7 gap-2 gap-y-4 animate-fade-in">
            {media.map((item, index) => (
            <MovieCard key={`${item.media_type}-${item.id}-${index}`} item={item} />
            ))}
        </div>
      ) : (
        <div className="text-center py-10">
            <h3 className="text-sm font-medium text-muted-foreground">No content found.</h3>
        </div>
      )}
      
      <div ref={loader} className="col-span-full py-8 w-full flex justify-center">
        {loading && (
          <div className="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-5 lg:grid-cols-6 gap-2 w-full">
            {Array.from({ length: 6 }).map((_, i) => (
              <div key={i} className="space-y-1">
                <Skeleton className="aspect-[2/3] w-full rounded-lg bg-white/5" />
                <Skeleton className="h-3 w-3/4 bg-white/5" />
              </div>
            ))}
          </div>
        )}
      </div>
    </>
  );
}
""",

    # 3. LIGHTWEIGHT CARD: Optimized image sizes (33vw), reduced DOM, smaller text
    "src/components/movies/MovieCard.tsx": """
import Image from 'next/image';
import Link from 'next/link';
import type { Media } from '@/types/tmdb';
import { Card, CardContent } from '@/components/ui/card';
import { Star } from 'lucide-react';

type MovieCardProps = {
  item: Media;
  compact?: boolean;
};

export function MovieCard({ item, compact }: MovieCardProps) {
  if (!item) return null;
  
  const href = item.media_type === 'movie' ? `/movie/${item.id}` : `/tv/${item.id}`;
  const title = item.media_type === 'movie' ? item.title : item.name;
  const voteAverage = item.vote_average ? item.vote_average.toFixed(1) : null;

  return (
    <Card className="group w-full h-full bg-transparent border-0 shadow-none">
      <CardContent className="p-0 relative h-full flex flex-col">
        <Link href={href} prefetch={false} className="relative block aspect-[2/3] overflow-hidden rounded-lg bg-secondary/30">
            <Image
              src={item.poster_path ? `https://image.tmdb.org/t/p/w342${item.poster_path}` : "https://placehold.co/342x513/202020/FFFFFF.png?text=No+Image"}
              alt={title || 'Poster'}
              fill
              // PERF: 33vw on mobile means browser downloads smaller images. Critical for speed.
              sizes="(max-width: 640px) 33vw, (max-width: 1024px) 20vw, 15vw"
              className="object-cover transition-opacity duration-300 hover:opacity-90"
              loading="lazy"
            />
            
            {/* Rating Badge - Simplified for performance */}
            {voteAverage && (
                <div className="absolute top-1 right-1 bg-black/70 backdrop-blur-[2px] px-1.5 py-0.5 rounded text-[10px] font-bold text-white flex items-center gap-0.5">
                    <Star className="h-2 w-2 text-yellow-400 fill-yellow-400" />
                    {voteAverage}
                </div>
            )}
        </Link>
        
        <div className="pt-2">
          <Link href={href} prefetch={false}>
            {/* CSS line-clamp to prevent titles from taking too much space */}
            <h3 className="font-medium text-[11px] sm:text-xs md:text-sm leading-tight text-gray-200 line-clamp-2" title={title}>
                {title}
            </h3>
          </Link>
        </div>
      </CardContent>
    </Card>
  );
}
"""
}

for path, content in files.items():
    dir_name = os.path.dirname(path)
    if dir_name:
        os.makedirs(dir_name, exist_ok=True)
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content.strip())
    print(f"Optimized {path}")

print("\nMobile optimization complete! Push to GitHub to update.")