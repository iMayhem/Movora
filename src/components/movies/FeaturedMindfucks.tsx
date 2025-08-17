
import { searchMedia } from '@/lib/tmdb';
import { MovieList } from './MovieList';
import type { Media } from '@/types/tmdb';

const featuredTitles = [
  'Inception',
  'Lost',
  'Fight Club',
  'The Sixth Sense',
  'Memento',
  'Brainscan',
  'A Beautiful Mind',
  'The Prestige',
  'The Illusionist',
  'Shutter Island',
  'The Devil\'s Advocate',
  'Black Swan',
  'The Matrix',
  'The Shining',
  'The Machinist',
  'Donnie Darko',
  'Vanilla Sky',
  'The Game',
  '1408',
  'American Psycho',
  'The Usual Suspects',
  'Unbreakable',
  'Saw',
  'Cube',
  'Moon',
  'Requiem for a Dream',
  'Total Recall',
  'Event Horizon',
  'Source Code',
  'Awake',
  'Repo Men',
  'Twelve Monkeys',
  'eXistenZ',
  'The Cell',
  'The Jacket',
  'The Others',
  'Identity',
  'Flightplan',
  'The Manchurian Candidate',
  'Breakdown',
  'K-PAX',
  'Paycheck',
  'Total Recall',
  'Jackie Brown',
  'Pan\'s Labyrinth',
  'Gothika',
  'Solaris',
  'Frailty',
  'Open Your Eyes',
  'Jacob\'s Ladder',
  'Swordfish',
  'Basic',
  'Perfect Stranger',
  'Insomnia'
];

async function fetchFeaturedMedia(): Promise<Media[]> {
  const mediaPromises = featuredTitles.map(async (title) => {
    const movieResults = await searchMedia(title, 'movie');
    if (movieResults.length > 0) return movieResults[0];

    const tvResults = await searchMedia(title, 'tv');
    if (tvResults.length > 0) return tvResults[0];

    return null;
  });

  const results = await Promise.all(mediaPromises);
  return results.filter((media): media is Media => media !== null);
}

export async function FeaturedMindfucks() {
  const featuredMedia = await fetchFeaturedMedia();

  return (
    <section className="mb-12">
        <h2 className="font-headline text-3xl font-bold mb-6">Featured</h2>
        <MovieList initialMedia={featuredMedia} showControls={false} />
    </section>
  );
}
