'use client';

import { useEffect, useState, useActionState } from 'react';
import { useFormStatus } from 'react-dom';
import { Button } from '@/components/ui/button';
import { searchMedia } from '@/lib/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import type { Media } from '@/types/tmdb';
import { getAIRecommendations } from '@/app/actions/recommendations';
import { Alert, AlertDescription, AlertTitle } from '@/components/ui/alert';
import { Terminal } from 'lucide-react';
import { Textarea } from '@/components/ui/textarea';
import { Label } from '@/components/ui/label';

function SubmitButton() {
  const { pending } = useFormStatus();
  return (
    <Button type="submit" disabled={pending} size="lg">
      {pending ? 'Generating...' : 'Get AI Recommendations'}
    </Button>
  );
}

export default function RecommendationsPage() {
  const [state, formAction] = useActionState(getAIRecommendations, undefined);
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

  return (
    <div className="container mx-auto px-4 py-6">
      <div className="text-center mb-10">
        <h1 className="font-headline text-3xl md:text-5xl font-bold mb-4">
          Personalized Recommendations
        </h1>
        <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
          Enter some movies you've enjoyed, and our AI will suggest new ones you might like.
        </p>
      </div>

        <div className="flex flex-col items-center">
          <form action={formAction} className="mb-8 w-full max-w-lg space-y-4 text-center">
            <div>
                <Label htmlFor="viewingHistory" className="sr-only">Your favorite movies</Label>
                <Textarea 
                    id="viewingHistory"
                    name="viewingHistory"
                    placeholder="Enter movie titles, one per line...&#10;The Dark Knight&#10;Inception&#10;Parasite"
                    rows={5}
                    className="text-center"
                />
            </div>
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
              <h2 className="font-headline text-2xl font-bold text-center mb-6">Our Suggestions For You</h2>
              <MovieList initialMedia={recommendedMedia} />
            </div>
          ) : (
            !state?.error && state?.success && (
                <p>We couldn&apos;t find any recommendations based on your list.</p>
            )
          )}
        </div>
    </div>
  );
}
