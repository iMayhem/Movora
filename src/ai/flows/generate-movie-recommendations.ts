// This is a server-side file.
'use server';
/**
 * @fileOverview Generates movie recommendations based on user viewing history.
 *
 * - generateMovieRecommendations - A function that generates movie recommendations.
 * - GenerateMovieRecommendationsInput - The input type for the generateMovieRecommendations function.
 * - GenerateMovieRecommendationsOutput - The return type for the generateMovieRecommendations function.
 */

import {ai} from '@/ai/genkit';
import {z} from 'genkit';

const GenerateMovieRecommendationsInputSchema = z.object({
  viewingHistory: z
    .array(z.string())
    .describe('The user viewing history as a list of movie titles.'),
});
export type GenerateMovieRecommendationsInput = z.infer<
  typeof GenerateMovieRecommendationsInputSchema
>;

const GenerateMovieRecommendationsOutputSchema = z.object({
  recommendations: z
    .array(z.string())
    .describe('A list of recommended movie titles.'),
});
export type GenerateMovieRecommendationsOutput = z.infer<
  typeof GenerateMovieRecommendationsOutputSchema
>;

export async function generateMovieRecommendations(
  input: GenerateMovieRecommendationsInput
): Promise<GenerateMovieRecommendationsOutput> {
  return generateMovieRecommendationsFlow(input);
}

const prompt = ai.definePrompt({
  name: 'generateMovieRecommendationsPrompt',
  input: {schema: GenerateMovieRecommendationsInputSchema},
  output: {schema: GenerateMovieRecommendationsOutputSchema},
  prompt: `You are a movie expert. Based on the user's viewing history, you will suggest some movies that they might like.

  Here is the user's viewing history:
  {{#each viewingHistory}}
  - {{this}}
  {{/each}}

  Suggest some movies that the user might like, based on their viewing history. Only list the movie title.
  `,
});

const generateMovieRecommendationsFlow = ai.defineFlow(
  {
    name: 'generateMovieRecommendationsFlow',
    inputSchema: GenerateMovieRecommendationsInputSchema,
    outputSchema: GenerateMovieRecommendationsOutputSchema,
  },
  async input => {
    const {output} = await prompt(input);
    return output!;
  }
);
