
import { searchMedia } from '@/lib/tmdb';
import { MovieList } from './MovieList';
import type { Media } from '@/types/tmdb';
import Link from 'next/link';
import { Button } from '../ui/button';

const featuredTitles = [
    'Moana', 'Frozen', 'Zootopia', 'Inside Out', 'Finding Nemo', 'The Secret Life of Pets',
    'The Lion King', 'Up', 'WALL-E', 'Toy Story', 'Big Hero 6', 'The Incredibles',
    'Monsters, Inc.', 'Despicable Me', 'Finding Dory', 'The Boss Baby', 'Sing', 'Wreck-It Ralph',
    'How to Train Your Dragon', 'Toy Story 3', 'Despicable Me 2', 'Ratatouille', 'Shrek',
    'Trolls', 'Tangled', 'Coco', 'Minions', 'The Lego Movie', 'Cars', 'Toy Story 2',
    'Brave', 'Aladdin', 'Monsters University', 'Spider-Man: Into the Spider-Verse',
    'Despicable Me 3', 'Sausage Party', 'Beauty and the Beast', 'The Lego Batman Movie',
    'Incredibles 2', 'How to Train Your Dragon 2', 'Ice Age', 'Shrek 2', 'Kung Fu Panda',
    'The Angry Birds Movie', 'Storks', 'The Nightmare Before Christmas', 'Kung Fu Panda 3',
    'The Good Dinosaur', 'A Bug\'s Life', 'Madagascar', 'The Little Mermaid',
    'Hotel Transylvania', 'Kubo and the Two Strings', 'Hotel Transylvania 2', 'Cars 2',
    'Cars 3', 'Mulan', 'The Croods', 'The Simpsons Movie', 'Ice Age: Collision Course',
    'Megamind', 'Ralph Breaks the Internet', 'Bolt', 'Home', 'Cloudy with a Chance of Meatballs',
    'Rio', 'Ice Age: Dawn of the Dinosaurs', 'Kung Fu Panda 2', 'Shrek the Third',
    'The Polar Express', 'Ice Age: The Meltdown', 'Rise of the Guardians', 'The Jungle Book',
    'Hercules', 'Lilo & Stitch', 'The Emoji Movie', 'Toy Story 4', 'Coraline',
    'The Adventures of Tintin', 'Rango', 'Tarzan', 'Cinderella', 'Ice Age: Continental Drift',
    'The Emperor\'s New Groove', 'Snow White and the Seven Dwarfs',
    'Madagascar 3: Europe\'s Most Wanted', 'Madagascar: Escape 2 Africa',
    'How to Train Your Dragon: The Hidden World', 'Corpse Bride', 'Shrek Forever After',
    'The Princess and the Frog', 'Peter Pan', '101 Dalmatians', 'Ferdinand', 'Puss in Boots',
    'Pocahontas', 'Alice in Wonderland', 'Cloudy with a Chance of Meatballs 2',
    'Who Framed Roger Rabbit', 'The Iron Giant', 'Smurfs: The Lost Village',
    'Lady and the Tramp', 'Penguins of Madagascar', 'Hotel Transylvania 3: Summer Vacation',
    'Space Jam', 'Captain Underpants: The First Epic Movie', 'The Lorax', 'Bambi', 'Pinocchio',
    'Dumbo', 'Bee Movie', 'Turbo', '9', 'The Peanuts Movie', 'Sleeping Beauty', 'Rio 2',
    'The Aristocats', 'Fantastic Mr. Fox', 'Happy Feet', 'Batman: The Killing Joke',
    'The Bad Guys 2', 'The Cat in the Hat', 'Dog Man', 'Elio', 'Frozen 3',
    'Gabby\'s Dollhouse: The Movie', 'In Your Dreams', 'K-Pop: Demon Hunters', 'Moana 2',
    'Night of the Zoopocalypse', 'Plankton: The Movie', 'Pookoo', 'Raymie Nightingale',
    'Shrek 5', 'The Smurfs Movie', 'Sneaks', 'The SpongeBob Movie: Search for SquarePants',
    'Toy Story 5', 'Wildwood', 'Zootopia 2', 'The Amazing Maurice',
    'Apollo 10 ½: A Space Age Childhood', 'Argonuts', 'The Bad Guys',
    'The Bob\'s Burgers Movie', 'Catwoman: Hunted', 'Chickenhare and the Hamster of Darkness',
    'Chip \'n Dale: Rescue Rangers', 'DC League of Super-Pets', 'Disenchanted',
    'Dragon Ball Super: Super Hero', 'Elemental', 'Entergalactic', 'Garfield',
    'Hotel Transylvania: Transformania', 'The Ice Age Adventures of Buck Wild',
    'Inside Out 2', 'Kung Fu Panda 4', 'Ladybug & Cat Noir: Awakening', 'Lightyear', 'Luck',
    'Marmaduke', 'Minions: The Rise of Gru', 'My Father\'s Dragon',
    'Night at the Museum: Kahmunrah Rises Again', 'Orion and the Dark',
    'Paws of Fury: The Legend of Hank', 'Pinocchio (Guillermo del Toro\'s)',
    'Puss in Boots: The Last Wish', 'The Sea Beast', 'Seal Team', 'Sonic the Hedgehog 3',
    'Spider-Man: Across the Spider-Verse', 'Strange World',
    'Teenage Mutant Ninja Turtles: Mutant Mayhem', 'That Christmas', 'The Tiger\'s Apprentice',
    'Transformers One', 'Turning Red', 'The Wild Robot', 'Wendell & Wild', 'Wish',
    'The Angry Birds Movie 3', 'The Canterville Ghost', 'Chicken Run: Dawn of the Nugget',
    'Coyote vs. Acme', 'Diary of a Wimpy Kid: Rodrick Rules', 'Dragonkeeper',
    'The Duke of Crows', 'The Flash', 'The Flying Squirrels', 'Ghostbusters: Afterlife',
    'The Magician\'s Elephant', 'Migration', 'Miraculous: Ladybug & Cat Noir, The Movie',
    'The Monkey King', 'Nimona', 'PAW Patrol: The Mighty Movie', 'The Peasants',
    'Rally Road Racers', 'Ruby Gillman, Teenage Kraken', 'The Super Mario Bros. Movie',
    'Strays', 'Suzume', 'Trolls Band Together', 'Under the Boardwalk', 'Unicorn Wars',
    'Beavis and Butt-Head Do the Universe', 'Charlotte', 'Ernest & Celestine: A Trip to Gibberitia',
    'Eternal Spring', 'The House', 'Inu-Oh', 'Little Nicholas: Happy as Can Be', 'Mad God',
    'Oink', 'Tom and Jerry: Cowboy Up!', 'The Addams Family 2', 'Ainbo: Spirit of the Amazon',
    'America: The Motion Picture', 'Back to the Outback', 'Batman: The Long Halloween, Part One',
    'Batman: The Long Halloween, Part Two', 'Belle', 'The Boss Baby: Family Business',
    'Clifford the Big Red Dog', 'Cryptozoo', 'Demon Slayer: Kimetsu no Yaiba – The Movie: Mugen Train',
    'Diary of a Wimpy Kid', 'Dragon Rider', 'Encanto', 'Evangelion: 3.0+1.0 Thrice Upon a Time',
    'Extinct', 'Flee', 'The Loud House Movie', 'Luca', 'The Mitchells vs. the Machines',
    'Mortal Kombat Legends: Battle of the Realms', 'My Little Pony: A New Generation',
    'PAW Patrol: The Movie', 'Peter Rabbit 2: The Runaway', 'Pompo: The Cinéphile',
    'Raya and the Last Dragon', 'Ron\'s Gone Wrong', 'Sing 2', 'Space Jam: A New Legacy',
    'Spirit Untamed', 'The SpongeBob Movie: Sponge on the Run', 'The Summit of the Gods',
    'Tom and Jerry', 'Trollhunters: Rise of the Titans', 'Vivo', 'Wish Dragon', '100% Wolf',
    'Accidental Luxuriance of the Translucent Watery Rebus', 'Animal Crackers',
    'Another Day of Life', 'Away', 'Bigfoot Family', 'Bombay Rose',
    'Calamity, a Childhood of Martha Jane Cannary', 'A Christmas Carol', 'Connected',
    'The Croods: A New Age', 'Demon Slayer: Kimetsu no Yaiba the Movie: Mugen Train',
    'Dreambuilders', 'Earwig and the Witch', 'Fearless', 'Fei Fei\'s Adventure to the Moon',
    'A Folded Wish', 'Funny Little Bugs', 'Godzilla: Planet of the Monsters', 'The Grinch',
    'Here We Are: Notes for Living on Planet Earth', 'Jungle Beat: The Movie', 'Klaus',
    'Lego Star Wars Holiday Special', 'Lupin III: The First', 'The Mitchells vs. The Machines',
    'Moominvalley', 'Mosley', 'My Favorite War', 'Nahuel and the Magic Book', 'No. 7 Cherry Lane',
    'Onward', 'Over the Moon', 'Red Shoes and the Seven Dwarfs', 'Ride Your Wave', 'Scoob!',
    'A Shaun the Sheep Movie: Farmageddon', 'Soul', 'Terra Willy', 'Trolls World Tour',
    'True North', 'The Willoughbys', 'Wolfwalkers', 'A Whisker Away', 'Abominable',
    'The Addams Family', 'The Angry Birds Movie 2', 'Buñuel in the Labyrinth of the Turtles',
    'Children of the Sea', 'Dilili in Paris', 'Frozen II', 'Funan', 'I Lost My Body',
    'Jacob, Mimmi and the Talking Dogs', 'The Last Fiction', 'The Lego Movie 2: The Second Part',
    'Marona\'s Fantastic Tale', 'Missing Link', 'Okko\'s Inn', 'Pachamama',
    'Playmobil: The Movie', 'Promare', 'Rezo', 'The Royal Exchange', 'Ruben Brandt, Collector',
    'The Secret Life of Pets 2', 'Spies in Disguise', 'Steven Universe: The Movie',
    'The Swallows of Kabul', 'The Tower', 'Upin & Ipin: The Lone Gibbon Kris',
    'Weathering with You', 'White Snake', 'Wonder Park', 'Zero Impunity', 'Ana y Bruno',
    'Batman Ninja', 'The Breadwinner', 'Cinderella the Cat', 'Dr. Seuss\' The Grinch',
    'Early Man', 'Fireworks', 'Have a Nice Day', 'Isle of Dogs', 'Leo Da Vinci: Mission Mona Lisa',
    'Lu over the Wall', 'Mary and the Witch\'s Flower', 'Maquia: When the Promised Flower Blooms',
    'Mirai', 'Next Gen', 'On Happiness Road', 'Peter Rabbit', 'Seder-Masochism',
    'Sgt. Stubby: An American Hero', 'Sherlock Gnomes', 'Smallfoot',
    'Tall Tales from the Magical Garden of Antoon Krings', 'Teen Titans Go! To the Movies',
    'Tito and the Birds', 'The Wolf House'
].filter((v, i, a) => a.indexOf(v) === i);


export async function fetchFeaturedAnimated(): Promise<Media[]> {
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
  const validResults = results.filter((media): media is Media => media !== null);

  // Remove duplicates based on ID
  const uniqueMedia: Media[] = [];
  const seenIds = new Set<number>();
  for (const media of validResults) {
    if (!seenIds.has(media.id)) {
      uniqueMedia.push(media);
      seenIds.add(media.id);
    }
  }
  return uniqueMedia;
}

export async function FeaturedAnimated({ showMore = false }: { showMore?: boolean }) {
  const featuredMedia = await fetchFeaturedAnimated();

  return (
    <section>
      <div className="flex justify-between items-center mb-6">
        <h2 className="font-headline text-3xl font-bold">Featured Animated</h2>
        {showMore && (
          <Link href="/discover/featured-animated">
            <Button variant="outline">More</Button>
          </Link>
        )}
      </div>
      <MovieList initialMedia={featuredMedia} showControls={false} carousel={showMore} />
    </section>
  );
}
