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