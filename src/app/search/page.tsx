'use client';
import { useSearchParams } from 'next/navigation';
import { useEffect, useState, Suspense } from 'react';
import { searchMedia } from '@/lib/tmdb';
import type { Media } from '@/types/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import { Skeleton } from '@/components/ui/skeleton';

function SearchResults() {
  const searchParams = useSearchParams();
  const query = searchParams.get('query') || '';
  const [results, setResults] = useState<Media[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetch = async () => {
        if(!query) return;
        setLoading(true);
        const movieResults = await searchMedia(query, 'movie');
        const tvResults = await searchMedia(query, 'tv');
        setResults([...movieResults, ...tvResults].sort((a,b) => b.popularity - a.popularity));
        setLoading(false);
    }
    fetch();
  }, [query]);

  return (
    <div className="container mx-auto px-4 py-6">
      <h1 className="font-headline text-3xl font-bold mb-6">Results for "{query}"</h1>
      {loading ? (
         <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">{Array.from({length:8}).map((_,i)=><Skeleton key={i} className="h-64 w-full"/>)}</div>
      ) : (
        results.length > 0 ? <MovieList initialMedia={results} /> : <p>No results found.</p>
      )}
    </div>
  );
}

export default function SearchPage() {
    return <Suspense fallback={<div>Loading...</div>}><SearchResults /></Suspense>
}