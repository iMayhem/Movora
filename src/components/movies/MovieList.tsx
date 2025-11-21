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
  const isInitialMount = useRef(true);

  useEffect(() => {
    // When initialMedia changes (or slug changes), reset everything
    setMedia(initialMedia);
    setPage(2);
    setHasMore(initialMedia.length > 0);
    setLoading(false);
  }, [initialMedia, slug]);

  const loadMore = useCallback(async () => {
    if (loading || !hasMore || !slug) return;
    
    setLoading(true);
    try {
        // removed artificial delay for snappier feel
        const newMedia = await fetchPage(page, slug);
        
        if (newMedia && newMedia.length > 0) {
            setMedia((prev) => {
                // Strict deduplication
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
        console.error("Failed to load more", error);
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
      { rootMargin: '100px' }
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
        opts={{ align: 'start', dragFree: true, loop: false }}
        className="w-full"
      >
        <CarouselContent className="-ml-2 pb-4">
          {media.length > 0 ? media.map((item, index) => (
            <CarouselItem key={`${item.media_type}-${item.id}-${index}`} className="pl-4 basis-[40%] sm:basis-[28%] md:basis-[20%] lg:basis-[16%] xl:basis-[14%]">
              <MovieCard item={item} />
            </CarouselItem>
          )) : (
             // Empty state for carousel
             <div className="pl-4 text-muted-foreground text-sm p-4">No content found.</div>
          )}
        </CarouselContent>
        <CarouselPrevious className="hidden md:flex -left-4 bg-black/50 border-none text-white hover:bg-primary hover:text-white" />
        <CarouselNext className="hidden md:flex -right-4 bg-black/50 border-none text-white hover:bg-primary hover:text-white" />
      </Carousel>
    );
  }

  return (
    <>
      {media.length > 0 ? (
        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-x-4 gap-y-8 animate-fade-in">
            {media.map((item, index) => (
            <MovieCard key={`${item.media_type}-${item.id}-${index}`} item={item} />
            ))}
        </div>
      ) : (
        <div className="text-center py-20">
            <h3 className="text-xl font-semibold text-muted-foreground">No movies found in this category.</h3>
        </div>
      )}
      
      <div ref={loader} className="col-span-full py-12 w-full flex justify-center">
        {loading && (
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-x-4 gap-y-8 w-full">
            {Array.from({ length: 6 }).map((_, i) => (
              <div key={i} className="space-y-2">
                <Skeleton className="aspect-[2/3] w-full rounded-xl bg-white/5" />
                <Skeleton className="h-4 w-3/4 bg-white/5" />
                <Skeleton className="h-3 w-1/2 bg-white/5" />
              </div>
            ))}
          </div>
        )}
      </div>
    </>
  );
}