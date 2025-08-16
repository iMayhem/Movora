'use client';

import { useState } from 'react';
import type { Media } from '@/types/tmdb';
import { MovieCard } from './MovieCard';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';

type MovieListProps = {
  initialMedia: Media[];
  showControls?: boolean;
};

type SortOption = 'popularity.desc' | 'release_date.desc' | 'vote_average.desc';

export function MovieList({ initialMedia, showControls = true }: MovieListProps) {
  const [media, setMedia] = useState<Media[]>(initialMedia);
  const [sort, setSort] = useState<SortOption>('popularity.desc');
  const [type, setType] = useState('all');

  const handleSortChange = (value: SortOption) => {
    setSort(value);
    sortMedia(value, type);
  };

  const handleTypeChange = (value: string) => {
    setType(value);
    sortMedia(sort, value);
  };

  const sortMedia = (currentSort: SortOption, currentType: string) => {
    let sortedAndFiltered = [...initialMedia];

    if (currentType !== 'all') {
      sortedAndFiltered = sortedAndFiltered.filter(item => item.media_type === currentType);
    }

    sortedAndFiltered.sort((a, b) => {
      switch (currentSort) {
        case 'popularity.desc':
          return b.popularity - a.popularity;
        case 'vote_average.desc':
          return b.vote_average - a.vote_average;
        case 'release_date.desc':
          const dateA = new Date('release_date' in a ? a.release_date ?? 0 : a.first_air_date ?? 0).getTime();
          const dateB = new Date('release_date' in b ? b.release_date ?? 0 : b.first_air_date ?? 0).getTime();
          return dateB - dateA;
        default:
          return 0;
      }
    });

    setMedia(sortedAndFiltered);
  };
  
  return (
    <div>
      {showControls && (
        <div className="flex flex-col md:flex-row justify-between items-center mb-8 gap-4">
          <h2 className="font-headline text-3xl font-bold">Discover</h2>
          <div className="flex gap-4">
            <Select onValueChange={handleTypeChange} defaultValue="all">
              <SelectTrigger className="w-[180px]">
                <SelectValue placeholder="Filter by Type" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All</SelectItem>
                <SelectItem value="movie">Movies</SelectItem>
                <SelectItem value="tv">TV Shows</SelectItem>
              </SelectContent>
            </Select>
            <Select onValueChange={handleSortChange} defaultValue="popularity.desc">
              <SelectTrigger className="w-[180px]">
                <SelectValue placeholder="Sort by" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="popularity.desc">Popularity</SelectItem>
                <SelectItem value="release_date.desc">Release Date</SelectItem>
                <SelectItem value="vote_average.desc">Rating</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </div>
      )}
      <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-x-6 gap-y-10">
        {media.map(item => (
          <MovieCard key={`${item.id}-${item.media_type}`} item={item} />
        ))}
      </div>
    </div>
  );
}
