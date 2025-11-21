import Image from 'next/image';
import Link from 'next/link';
import type { Media } from '@/types/tmdb';
import { Card, CardContent } from '@/components/ui/card';
import { Star, PlayCircle } from 'lucide-react';

type MovieCardProps = {
  item: Media;
};

export function MovieCard({ item }: MovieCardProps) {
  if (!item) {
    return null;
  }
  
  const href = item.media_type === 'movie' ? `/movie/${item.id}` : `/tv/${item.id}`;
  const title = item.media_type === 'movie' ? item.title : item.name;
  const releaseDate = 'release_date' in item ? item.release_date : item.first_air_date;
  const voteAverage = item.vote_average ? item.vote_average.toFixed(1) : 'NR';

  return (
    <Card className="group w-full h-full overflow-hidden bg-transparent border-0 shadow-none hover:z-10 transition-all duration-300">
      <CardContent className="p-0 relative h-full flex flex-col">
        <Link href={href} prefetch={false} className="relative block aspect-[2/3] overflow-hidden rounded-xl bg-secondary/50">
            <Image
              src={item.poster_path ? `https://image.tmdb.org/t/p/w500${item.poster_path}` : "https://placehold.co/500x750/202020/FFFFFF.png?text=No+Image"}
              alt={title || 'Movie Poster'}
              fill
              sizes="(max-width: 640px) 50vw, (max-width: 1024px) 33vw, 20vw"
              className="object-cover transition-transform duration-500 ease-out group-hover:scale-110"
              loading="lazy"
            />
            
            {/* Hover Overlay */}
            <div className="absolute inset-0 bg-black/60 opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex items-center justify-center backdrop-blur-[2px]">
                <PlayCircle className="w-12 h-12 text-white opacity-90 scale-90 group-hover:scale-100 transition-transform duration-300" />
            </div>

            {/* Rating Badge */}
            <div className="absolute top-2 right-2 bg-black/60 backdrop-blur-md px-2 py-1 rounded-md flex items-center gap-1 text-xs font-medium text-white border border-white/10">
                <Star className="h-3 w-3 text-yellow-400 fill-yellow-400" />
                <span>{voteAverage}</span>
            </div>
        </Link>
        
        <div className="pt-3 flex-1 flex flex-col justify-between">
          <Link href={href} prefetch={false}>
            <h3 className="truncate font-bold text-base text-gray-100 group-hover:text-primary transition-colors duration-200" title={title}>
                {title}
            </h3>
          </Link>
          <div className="flex justify-between items-center text-xs text-muted-foreground mt-1">
            <span>{releaseDate?.substring(0, 4) || 'Unknown'}</span>
            <span className="uppercase border border-white/10 px-1 rounded text-[10px] tracking-wider">{item.media_type}</span>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}