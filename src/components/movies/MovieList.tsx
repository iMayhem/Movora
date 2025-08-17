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

type MovieListProps = {
  initialMedia?: Media[];
  media?: Media[]; // For client-side updates
  showControls?: boolean;
  carousel?: boolean;
};


export function MovieList({ initialMedia, media, showControls = true, carousel = false }: MovieListProps) {
  const items = media || initialMedia || [];

  if (carousel) {
    return (
       <Carousel
        opts={{
          align: 'start',
          dragFree: true,
        }}
        className="w-full"
      >
        <CarouselContent className="-ml-2">
          {items.map((item, index) => (
            <CarouselItem key={`${item.id}-${index}`} className="pl-2 basis-1/2 sm:basis-1/3 md:basis-1/4 lg:basis-1/5 xl:basis-1/6">
               <MovieCard item={item} />
            </CarouselItem>
          ))}
        </CarouselContent>
        <CarouselPrevious className="hidden sm:flex" />
        <CarouselNext className="hidden sm:flex" />
      </Carousel>
    )
  }

  return (
    <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-x-6 gap-y-10">
      {items.map(item => (
        <MovieCard key={`${item.id}-${item.media_type}`} item={item} />
      ))}
    </div>
  );
}
