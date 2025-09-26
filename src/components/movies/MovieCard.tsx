import Image from 'next/image';
import Link from 'next/link';
import type { Media } from '@/types/tmdb';
import { Card, CardContent } from '@/components/ui/card';
import { Star } from 'lucide-react';

type MovieCardProps = {
  item: Media;
};

export function MovieCard({ item }: MovieCardProps) {
  const href = item.media_type === 'movie' ? `/movie/${item.id}` : `/tv/${item.id}`;
  const title = item.media_type === 'movie' ? item.title : item.name;
  const releaseDate = 'release_date' in item ? item.release_date : item.first_air_date;

  return (
    <Card className="group w-full max-w-sm overflow-hidden bg-transparent border-0 shadow-none">
      <CardContent className="p-0">
        <div className="relative">
          <Link href={href}>
            <Image
              src={item.poster_path ? `https://image.tmdb.org/t/p/w500${item.poster_path}` : "https://placehold.co/500x750.png"}
              alt={title}
              width={500}
              height={750}
              className="rounded-lg object-cover transition-transform duration-300 ease-in-out group-hover:scale-105"
              data-ai-hint="movie poster"
            />
          </Link>
        </div>
        <div className="pt-3">
          <Link href={href}>
            <h3 className="truncate font-bold font-headline group-hover:text-primary">{title}</h3>
          </Link>
          <div className="flex justify-between items-center text-sm text-muted-foreground mt-1">
            <span>{releaseDate?.substring(0, 4)}</span>
            <div className="flex items-center gap-1">
              <Star className="h-4 w-4 text-accent" />
              <span>{item.vote_average.toFixed(1)}</span>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  );
}
