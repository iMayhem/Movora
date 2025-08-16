'use server';

import { generateMovieRecommendations } from '@/ai/flows/generate-movie-recommendations';
import { z } from 'zod';

const RecommendationsSchema = z.object({
  viewingHistory: z.array(z.string()).min(1, 'Please provide at least one movie.'),
});

type State = {
  success: boolean;
  recommendations?: string[];
  error?: string;
};

export async function getAIRecommendations(
  prevState: State | undefined,
  formData: FormData
): Promise<State> {
  const viewingHistory = formData.getAll('viewingHistory').map(String);

  const validatedFields = RecommendationsSchema.safeParse({
    viewingHistory,
  });

  if (!validatedFields.success) {
    return {
      success: false,
      error: validatedFields.error.flatten().fieldErrors.viewingHistory?.join(', '),
    };
  }

  try {
    const result = await generateMovieRecommendations({ viewingHistory });
    if (result && result.recommendations.length > 0) {
      return { success: true, recommendations: result.recommendations };
    } else {
      return { success: false, error: 'Could not generate recommendations.' };
    }
  } catch (e) {
    console.error(e);
    return { success: false, error: 'An unexpected error occurred.' };
  }
}
