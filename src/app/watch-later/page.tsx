'use client';

import { useWatchLater } from '@/hooks/useWatchLater';
import { MovieList } from '@/components/movies/MovieList';
import { Film } from 'lucide-react';
import Link from 'next/link';
import { Button } from '@/components/ui/button';

export default function WatchLaterPage() {
  const { watchLater, isClient } = useWatchLater();

  if (!isClient) {
    return null; // or a loading skeleton
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="font-headline text-4xl font-bold mb-8">My Watch Later List</h1>
      {watchLater.length > 0 ? (
        <MovieList initialMedia={watchLater} />
      ) : (
        <div className="flex flex-col items-center justify-center text-center py-20 bg-card rounded-lg border-dashed border-2 border-border">
          <Film className="w-16 h-16 text-muted-foreground mb-4" />
          <h2 className="text-2xl font-semibold mb-2">Your list is empty</h2>
          <p className="text-muted-foreground mb-6">
            Add movies and TV shows to your list to see them here.
          </p>
          <Button asChild>
            <Link href="/">Browse Content</Link>
          </Button>
        </div>
      )}
    </div>
  );
}
