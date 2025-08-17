
import { searchMedia } from '@/lib/tmdb';
import { MovieList } from './MovieList';
import type { Media } from '@/types/tmdb';

const featuredTitles = [
    'Moana',
    'Frozen',
    'Zootopia',
    'Inside Out',
    'Finding Nemo',
    'The Secret Life of Pets',
    'The Lion King',
    'Up',
    'WALL-E',
    'Toy Story',
    'Big Hero 6',
    'The Incredibles',
    'Monsters, Inc.',
    'Despicable Me',
    'Finding Dory',
    'The Boss Baby',
    'Sing',
    'Wreck-It Ralph',
    'How to Train Your Dragon',
    'Toy Story 3',
    'Despicable Me 2',
    'Ratatouille',
    'Shrek',
    'Trolls',
    'Tangled',
    'Coco',
    'Minions',
    'The Lego Movie',
    'Cars',
    'Toy Story 2',
    'Brave',
    'Aladdin',
    'Monsters University',
    'Spider-Man: Into the Spider-Verse',
    'Despicable Me 3',
    'Sausage Party'
];

async function fetchFeaturedMedia(): Promise<Media[]> {
  const mediaPromises = featuredTitles.map(async (title) => {
    let movieResults;
    if (title === 'Moana') {
       movieResults = await searchMedia('Moana', 'movie', { year: '2016' });
    } else if (title === 'WALL-E') {
        movieResults = await searchMedia('WALL-E', 'movie', { year: '2008' });
    } else if (title === 'The Lion King') {
        movieResults = await searchMedia('The Lion King', 'movie', { year: '1994' });
    }
    else {
       movieResults = await searchMedia(title, 'movie');
    }
    
    if (movieResults.length > 0) return movieResults[0];

    const tvResults = await searchMedia(title, 'tv');
    if (tvResults.length > 0) return tvResults[0];

    return null;
  });

  const results = await Promise.all(mediaPromises);
  return results.filter((media): media is Media => media !== null);
}

export async function FeaturedAnimated() {
  const featuredMedia = await fetchFeaturedMedia();

  return (
    <section className="mb-12">
        <MovieList initialMedia={featuredMedia} showControls={false} />
    </section>
  );
}
