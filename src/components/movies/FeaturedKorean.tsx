
import { searchMedia } from '@/lib/tmdb';
import { MovieList } from './MovieList';
import type { Media } from '@/types/tmdb';
import Link from 'next/link';
import { Button } from '../ui/button';

export const featuredKoreanTitles = [
    'Parasite', 'Oldboy', 'Memories of Murder', 'The Handmaiden', 'Train to Busan',
    'Burning', 'The Wailing', 'Mother', 'Decision to Leave', 'Minari',
    'The Man from Nowhere', 'I Saw the Devil', 'The Chaser', 'A Bittersweet Life',
    'The Host', 'New World', 'The Villainess', 'The Outlaws', 'Veteran',
    'The Good, the Bad, the Weird', 'Assassination', 'The Thieves', 'Extreme Job',
    'The Roundup', 'A Hard Day', 'Forgotten', 'The Call', '#Alive', 'Time to Hunt',
    'Project Wolf Hunting', 'Miracle in Cell No. 7', 'Ode to My Father', 'A Taxi Driver',
    'The Attorney', 'Silenced', 'Hope', 'Miss Granny', 'Sunny',
    'Castaway on the Moon', 'Poetry', 'A Moment to Remember', 'The Classic',
    'Il Mare', 'Christmas in August', 'My Sassy Girl', 'The Beauty Inside',
    'On Your Wedding Day', 'Architecture 101', 'Always', 'Be With You',
    'A Werewolf Boy', 'Little Forest', 'House of Hummingbird', 'The World of Us',
    'Secret Sunshine', 'Oasis', 'Pieta', '3-Iron',
    'Spring, Summer, Fall, Winter... and Spring', 'Joint Security Area',
    'The Admiral: Roaring Currents', 'Taegukgi: The Brotherhood of War',
    'The King and the Clown', 'Masquerade', 'The Throne', 'The Age of Shadows',
    '1987: When the Day Comes', 'The Great Battle', 'A Resistance', 'The Last Princess',
    'A Tale of Two Sisters', 'Gonjiam: Haunted Asylum', 'Thirst', 'The Red Shoes',
    'Whispering Corridors', 'Bedevilled', 'Svaha: The Sixth Finger', 'Exhuma',
    'Save the Green Planet!', 'Welcome to Dongmakgol', 'The Foul King', 'Okja',
    'Snowpiercer', 'Psychokinesis', 'The President\'s Last Bang', 'I\'m a Cyborg, But That\'s OK',
    'Haemoo', 'The Tiger: An Old Hunter\'s Tale', 'Along with the Gods: The Two Worlds',
    'Along with the Gods: The Last 49 Days', 'Space Sweepers', 'Concrete Utopia',
    'The Pirates', 'The Face Reader', 'Kundo: Age of the Rampant', 'War of the Arrows',
    'Secretly, Greatly', 'Exit'
];

export async function fetchFeaturedKorean(): Promise<Media[]> {
  const uniqueTitles = [...new Set(featuredKoreanTitles)];
  const mediaPromises = uniqueTitles.map(async (title) => {
    // TMDB search can be finicky, so we search for movies first
    const movieResults = await searchMedia(title, 'movie', { language: 'en' });
    if (movieResults.length > 0) return movieResults[0];

    // Fallback to searching TV shows if no movie is found
    const tvResults = await searchMedia(title, 'tv', { language: 'en' });
    if (tvResults.length > 0) return tvResults[0];

    return null;
  });

  const results = await Promise.all(mediaPromises);
  const validResults = results.filter((media): media is Media => media !== null);
  
  // Post-filter to ensure we only get Korean content
  const koreanResults = validResults.filter(media => {
      if ('original_language' in media) {
          return media.original_language === 'ko';
      }
      return false;
  });

  // Remove duplicates based on ID
  const uniqueMedia: Media[] = [];
  const seenIds = new Set<number>();
  for (const media of koreanResults) {
    if (!seenIds.has(media.id)) {
      uniqueMedia.push(media);
      seenIds.add(media.id);
    }
  }
  return uniqueMedia;
}

export async function FeaturedKorean({ showMore = false }: { showMore?: boolean }) {
  const featuredMedia = await fetchFeaturedKorean();

  return (
    <section>
        <div className="flex justify-between items-center mb-6">
            <h2 className="font-headline text-3xl font-bold">Featured Korean Cinema</h2>
            {showMore && (
                 <Link href="/discover/featured-korean">
                    <Button variant="outline">More</Button>
                </Link>
            )}
        </div>
        <MovieList initialMedia={featuredMedia} showControls={false} carousel={showMore} />
    </section>
  );
}
