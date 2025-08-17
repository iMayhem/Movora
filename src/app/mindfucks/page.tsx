
'use client';

import { useState, useEffect, useCallback } from 'react';
import Link from 'next/link';
import { discoverMovies } from '@/lib/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import { Button } from '@/components/ui/button';
import { FeaturedMindfucks } from '@/components/movies/FeaturedMindfucks';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { Skeleton } from '@/components/ui/skeleton';
import type { Media } from '@/types/tmdb';

const MINDFUCK_PARAMS = {
  'vote_count.gte': '500',
  'with_genres': '53,9648,878', // Thriller, Mystery, Sci-Fi
  'without_genres': '16,10751,28', // Exclude Animation, Family, Action
  'include_adult': 'false'
};

export default function MindfucksPage() {
  const [mindfuckMovies, setMindfuckMovies] = useState<Media[]>([]);
  const [sortBy, setSortBy] = useState('primary_release_date.desc');
  const [isLoading, setIsLoading] = useState(true);

  const fetchMovies = useCallback(async (sortOption: string) => {
    setIsLoading(true);
    const movies = await discoverMovies({ ...MINDFUCK_PARAMS, sort_by: sortOption }, 50);
    setMindfuckMovies(movies);
    setIsLoading(false);
  }, []);

  useEffect(() => {
    fetchMovies(sortBy);
  }, [sortBy, fetchMovies]);

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-8 gap-4">
        <div>
          <h1 className="font-headline text-4xl font-bold text-white md:text-5xl">
            Best Mindfucks
          </h1>
          <p className="text-muted-foreground mt-2">
            A collection of films that will mess with your head.
          </p>
        </div>
        <div className="flex gap-4 items-center">
         <Select value={sortBy} onValueChange={setSortBy}>
            <SelectTrigger className="w-[180px]">
              <SelectValue placeholder="Sort by" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="primary_release_date.desc">Release Date</SelectItem>
              <SelectItem value="vote_average.desc">IMDb Rating</SelectItem>
            </SelectContent>
          </Select>
          <Link href="https://trakt.tv/users/benfranklin/lists/best-mindfucks?sort=rank,asc" target="_blank" rel="noopener noreferrer">
            <Button variant="outline">
              View on Trakt.tv
            </Button>
          </Link>
        </div>
      </div>

      <FeaturedMindfucks />

      <div className="mt-12">
        {isLoading ? (
            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-x-6 gap-y-10">
                {Array.from({ length: 24 }).map((_, i) => (
                    <div key={i}>
                        <Skeleton className="h-[450px] w-full rounded-lg" />
                        <Skeleton className="h-4 w-3/4 mt-2" />
                        <Skeleton className="h-4 w-1/2 mt-1" />
                    </div>
                ))}
            </div>
        ) : (
            <MovieList media={mindfuckMovies} showControls={false} />
        )}
      </div>
    </div>
  );
}
