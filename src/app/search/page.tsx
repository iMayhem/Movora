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
    if (!query) {
      setResults([]);
      setLoading(false);
      return;
    }

    setLoading(true);
    const fetchResults = async () => {
      const movieResults = await searchMedia(query, 'movie');
      const tvResults = await searchMedia(query, 'tv');
      
      const seen = new Set();
      const combined = [...movieResults, ...tvResults].filter(item => {
        const duplicate = seen.has(item.id);
        seen.add(item.id);
        return !duplicate;
      });

      setResults(combined.sort((a,b) => b.popularity - a.popularity));
      setLoading(false);
    };

    const timeoutId = setTimeout(fetchResults, 300); // Debounce search
    return () => clearTimeout(timeoutId);
  }, [query]);

  return (
    <div className="container mx-auto px-4 py-6">
      <h1 className="font-headline text-3xl font-bold mb-6">
        {query ? `Search Results for "${query}"` : 'Please enter a search term'}
      </h1>

      {loading ? (
        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-4">
          {Array.from({ length: 12 }).map((_, i) => (
            <div key={i}>
                <Skeleton className="h-[450px] w-full rounded-lg" />
                <Skeleton className="h-4 w-3/4 mt-2" />
                <Skeleton className="h-4 w-1/2 mt-1" />
            </div>
          ))}
        </div>
      ) : (
        results.length > 0 ? (
          <MovieList initialMedia={results} />
        ) : (
          query && <p>No results found for &quot;{query}&quot;.</p>
        )
      )}
    </div>
  );
}


export default function SearchPage() {
    return (
        <Suspense fallback={<div>Loading...</div>}>
            <SearchResults />
        </Suspense>
    )
}
