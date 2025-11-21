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