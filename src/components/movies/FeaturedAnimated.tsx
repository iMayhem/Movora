
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
    'Sausage Party',
    'Beauty and the Beast',
    'The Lego Batman Movie',
    'Incredibles 2',
    'How to Train Your Dragon 2',
    'Ice Age',
    'Shrek 2',
    'Kung Fu Panda',
    'The Angry Birds Movie',
    'Storks',
    'The Nightmare Before Christmas',
    'Kung Fu Panda 3',
    'The Good Dinosaur',
    'A Bug\'s Life',
    'Madagascar',
    'The Little Mermaid',
    'Hotel Transylvania',
    'Kubo and the Two Strings',
    'Hotel Transylvania 2',
    'Cars 2',
    'Cars 3',
    'Mulan',
    'The Croods',
    'The Simpsons Movie',
    'Ice Age: Collision Course',
    'Megamind',
    'Ralph Breaks the Internet',
    'Bolt',
    'Home',
    'Cloudy with a Chance of Meatballs',
    'Rio',
    'Ice Age: Dawn of the Dinosaurs',
    'Kung Fu Panda 2',
    'Shrek the Third',
    'The Polar Express',
    'Ice Age: The Meltdown',
    'Rise of the Guardians',
    'The Jungle Book',
    'Hercules',
    'Lilo & Stitch',
    'The Emoji Movie',
    'Toy Story 4',
    'Coraline',
    'The Adventures of Tintin',
    'Rango',
    'Tarzan',
    'Cinderella',
    'Ice Age: Continental Drift',
    'The Emperor\'s New Groove',
    'Snow White and the Seven Dwarfs',
    'Madagascar 3: Europe\'s Most Wanted',
    'Madagascar: Escape 2 Africa',
    'How to Train Your Dragon: The Hidden World',
    'Corpse Bride',
    'Shrek Forever After',
    'The Princess and the Frog',
    'Peter Pan',
    '101 Dalmatians',
    'Ferdinand',
    'Puss in Boots',
    'Pocahontas',
    'Alice in Wonderland',
    'Cloudy with a Chance of Meatballs 2',
    'Who Framed Roger Rabbit',
    'The Iron Giant',
    'Smurfs: The Lost Village',
    'Lady and the Tramp',
    'Penguins of Madagascar',
    'Hotel Transylvania 3: Summer Vacation',
    'Space Jam',
    'Captain Underpants: The First Epic Movie',
    'The Lorax',
    'Bambi',
    'Pinocchio',
    'Dumbo',
    'Bee Movie',
    'Turbo',
    '9',
    'The Peanuts Movie',
    'Sleeping Beauty',
    'Rio 2',
    'The Aristocats',
    'Fantastic Mr. Fox',
    'Happy Feet',
    'Batman: The Killing Joke',
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
    } else if (title === 'Beauty and the Beast') {
        movieResults = await searchMedia('Beauty and the Beast', 'movie', { year: '1991' });
    } else if (title === 'The Little Mermaid') {
        movieResults = await searchMedia('The Little Mermaid', 'movie', { year: '1989' });
    } else if (title === 'Mulan') {
        movieResults = await searchMedia('Mulan', 'movie', { year: '1998' });
    } else if (title === 'The Jungle Book') {
        movieResults = await searchMedia(title, 'movie', { year: '1967' });
    } else if (title === 'Hercules') {
        movieResults = await searchMedia(title, 'movie', { year: '1997' });
    } else if (title === 'Tarzan') {
        movieResults = await searchMedia(title, 'movie', { year: '1999' });
    } else if (title === 'Cinderella') {
        movieResults = await searchMedia(title, 'movie', { year: '1950' });
    } else if (title === 'Snow White and the Seven Dwarfs') {
        movieResults = await searchMedia(title, 'movie', { year: '1937' });
    } else if (title === 'Peter Pan') {
        movieResults = await searchMedia(title, 'movie', { year: '1953' });
    } else if (title === '101 Dalmatians') {
        movieResults = await searchMedia(title, 'movie', { year: '1961' });
    } else if (title === 'Pocahontas') {
        movieResults = await searchMedia(title, 'movie', { year: '1995' });
    } else if (title === 'Alice in Wonderland') {
        movieResults = await searchMedia(title, 'movie', { year: '1951' });
    } else if (title === 'Lady and the Tramp') {
        movieResults = await searchMedia(title, 'movie', { year: '1955' });
    } else if (title === 'Bambi') {
        movieResults = await searchMedia(title, 'movie', { year: '1942' });
    } else if (title === 'Pinocchio') {
        movieResults = await searchMedia(title, 'movie', { year: '1940' });
    } else if (title === 'Dumbo') {
        movieResults = await searchMedia(title, 'movie', { year: '1941' });
    } else if (title === 'Sleeping Beauty') {
        movieResults = await searchMedia(title, 'movie', { year: '1959' });
    } else if (title === 'The Aristocats') {
        movieResults = await searchMedia(title, 'movie', { year: '1970' });
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
