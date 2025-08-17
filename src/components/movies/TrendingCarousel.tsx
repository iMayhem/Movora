'use client';

import Image from 'next/image';
import Link from 'next/link';
import {
  Carousel,
  CarouselContent,
  CarouselItem,
  CarouselNext,
  CarouselPrevious,
} from '@/components/ui/carousel';
import type { Media } from '@/types/tmdb';
import Autoplay from 'embla-carousel-autoplay';

type TrendingCarouselProps = {
  items: Media[];
};

export function TrendingCarousel({ items }: TrendingCarouselProps) {
  return (
    <Carousel
      opts={{
        align: 'start',
        loop: true,
      }}
      plugins={[
        Autoplay({
          delay: 5000,
        }),
      ]}
      className="w-full"
    >
      <CarouselContent>
        {items.map(item => {
          const isMovie = 'title' in item;
          const href = isMovie ? `/movie/${item.id}` : `/tv/${item.id}`;
          const title = isMovie ? item.title : item.name;

          return (
            <CarouselItem key={item.id} className="md:basis-1/2 lg:basis-1/3">
              <Link href={href}>
                <div className="relative aspect-video overflow-hidden rounded-lg group">
                  <Image
                    src={item.backdrop_path ? `https://image.tmdb.org/t/p/w780${item.backdrop_path}` : "https://placehold.co/780x439.png"}
                    alt={title}
                    width={780}
                    height={439}
                    className="object-cover w-full h-full transition-transform duration-300 ease-in-out group-hover:scale-105"
                    data-ai-hint="movie scene"
                  />
                  <div className="absolute inset-0 bg-gradient-to-t from-black/70 via-black/20 to-transparent"></div>
                  <div className="absolute bottom-0 left-0 p-4">
                    <h3 className="font-bold text-lg text-white drop-shadow-lg font-headline">
                      {title}
                    </h3>
                  </div>
                </div>
              </Link>
            </CarouselItem>
          );
        })}
      </CarouselContent>
      <CarouselPrevious className="hidden sm:flex" />
      <CarouselNext className="hidden sm:flex" />
    </Carousel>
  );
}
