'use client';

import { useEffect, useState } from 'react';
import { useFormState, useFormStatus } from 'react-dom';
import { useWatchLater } from '@/hooks/useWatchLater';
import { Button } from '@/components/ui/button';
import { searchMedia } from '@/lib/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import type { Media } from '@/types/tmdb';
import { getAIRecommendations } from '@/app/actions/recommendations';
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert';
import { Terminal } from 'lucide-react';

function SubmitButton() {
  const { pending } = useFormStatus();
  return (
    <Button type="submit" disabled={pending} size="lg">
      {pending ? 'Generating...' : 'Get AI Recommendations'}
    </Button>
  );
}

export default function RecommendationsPage() {
  const { watchLater } = useWatchLater();
  const [state, formAction] = useFormState(getAIRecommendations, undefined);
  const [recommendedMedia, setRecommendedMedia] = useState<Media[]>([]);
  const [isLoadingMedia, setIsLoadingMedia] = useState(false);

  useEffect(() => {
    if (state?.success && state.recommendations) {
      const fetchRecommendedMedia = async () => {
        setIsLoadingMedia(true);
        const mediaPromises = state.recommendations!.map(title =>
          searchMedia(title, 'movie').then(results => results[0])
        );
        const results = await Promise.all(mediaPromises);
        setRecommendedMedia(results.filter(Boolean) as Media[]);
        setIsLoadingMedia(false);
      };
      fetchRecommendedMedia();
    }
  }, [state]);

  const viewingHistoryTitles = watchLater.map(item => 'title' in item ? item.title : item.name);

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="text-center mb-12">
        <h1 className="font-headline text-4xl md:text-6xl font-bold mb-4">
          Personalized Recommendations
        </h1>
        <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
          Based on your &quot;Watch Later&quot; list, our AI will suggest new movies you might enjoy.
        </p>
      </div>

      {watchLater.length > 0 ? (
        <div className="flex flex-col items-center">
          <form action={formAction} className="mb-8">
            {viewingHistoryTitles.map(title => (
              <input key={title} type="hidden" name="viewingHistory" value={title} />
            ))}
            <SubmitButton />
          </form>

          {state?.error && (
             <Alert variant="destructive" className="max-w-md mb-8">
                <Terminal className="h-4 w-4" />
                <AlertTitle>Error</AlertTitle>
                <AlertDescription>{state.error}</AlertDescription>
            </Alert>
          )}

          {isLoadingMedia ? (
            <p>Loading recommendations...</p>
          ) : recommendedMedia.length > 0 ? (
            <div className="w-full">
              <h2 className="font-headline text-3xl font-bold text-center mb-6">Our Suggestions For You</h2>
              <MovieList initialMedia={recommendedMedia} showControls={false} />
            </div>
          ) : (
            !state?.error && state?.success && (
                <p>We couldn&apos;t find any recommendations based on your list.</p>
            )
          )}
        </div>
      ) : (
         <Alert className="max-w-lg mx-auto">
            <Terminal className="h-4 w-4" />
            <AlertTitle>Your Watch Later list is empty!</AlertTitle>
            <AlertDescription>
                Add some movies or TV shows to your list to get personalized AI recommendations.
            </AlertDescription>
        </Alert>
      )}
    </div>
  );
}
