
import { searchMedia } from '@/lib/tmdb';
import { MovieList } from './MovieList';
import type { Media } from '@/types/tmdb';
import Link from 'next/link';
import { Button } from '../ui/button';

const survivalistTitles = [
    'Survivorman', 'Dual Survival', 'Naked and Afraid', 'Naked and Afraid XL', 'Alone',
    'The Island with Bear Grylls', 'Marooned with Ed Stafford', 'Man, Woman, Wild',
    'Primal Survivor', 'Dude, You\'re Screwed', 'Win the Wilderness', 'Out of the Wild: The Alaska Experiment',
    'Fat Guys in the Woods', 'Survive This', 'I Shouldn\'t Be Alive'
];

const adventurerTitles = [
    'Expedition Unknown', 'Running Wild with Bear Grylls', 'Life Below Zero', 'Pole to Pole with Michael Palin',
    'Long Way Round', 'Long Way Down', 'Conan Without Borders', 'Parts Unknown', 'Dark Tourist',
    'Departures', 'Globe Trekker', 'An Idiot Abroad', 'The World\'s Most Dangerous Roads',
    'Tales by Light', 'Extreme Treks', 'Walking the Himalayas'
];

const wildKingdomTitles = [
    'Planet Earth', 'Planet Earth II', 'Blue Planet', 'Blue Planet II', 'Our Planet', 'Frozen Planet',
    'The Hunt', 'Dynasties', 'Night on Earth', 'Life', 'Africa', 'Yellowstone', 'Untamed Americas',
    'Wildest Islands', 'Serengeti', 'Hostile Planet', 'Seven Worlds, One Planet'
];

const competitionTitles = [
    'Survivor', 'The Amazing Race', 'Eco-Challenge', 'Ultimate Survival Alaska',
    '72 Dangerous Animals to Live With', 'Top Shot', 'Forged in Fire'
];

const expeditionTitles = [
    'The Blue Planet: A Natural History of the Oceans', 'Oceans', 'Mission Blue', 'Chasing Coral',
    'Blackfish', 'My Octopus Teacher', 'Touching the Void', 'Free Solo', 'Meru', 'The Dawn Wall',
    '14 Peaks: Nothing Is Impossible', 'Sherpa', 'Everest: Beyond the Limit'
];

const allShows = {
  'survivalists': survivalistTitles,
  'adventurers': adventurerTitles,
  'wild-kingdom': wildKingdomTitles,
  'competition': competitionTitles,
  'expeditions': expeditionTitles,
};

async function fetchMedia(titles: string[]): Promise<Media[]> {
  const uniqueTitles = [...new Set(titles)];
  const mediaPromises = uniqueTitles.map(async (title) => {
    const tvResults = await searchMedia(title, 'tv');
    if (tvResults.length > 0) return tvResults[0];
    
    const movieResults = await searchMedia(title, 'movie');
    if (movieResults.length > 0) return movieResults[0];

    return null;
  });

  const results = await Promise.all(mediaPromises);
  const validResults = results.filter((media): media is Media => media !== null);

  const uniqueMedia: Media[] = [];
  const seenIds = new Set<number>();
  for (const media of validResults) {
    if (media && !seenIds.has(media.id)) {
      uniqueMedia.push(media);
      seenIds.add(media.id);
    }
  }
  return uniqueMedia;
}

export async function fetchAllAdventure(): Promise<Media[]> {
    const allTitles = Object.values(allShows).flat();
    return fetchMedia(allTitles);
}

const sections = [
    { title: 'The Survivalists: Pushing Human Limits', slug: 'survival-docs', titles: survivalistTitles },
    { title: 'The Adventurers & Explorers: Journey to the Unknown', slug: 'explorer-docs', titles: adventurerTitles },
    { title: 'The Wild Kingdom: Up Close with Nature\'s Wonders', slug: 'wildlife-docs', titles: wildKingdomTitles },
    { title: 'The Competition: Survival of the Fittest', slug: 'competition-docs', titles: competitionTitles },
    { title: 'Deep Dives: Ocean and Mountain Expeditions', slug: 'expedition-docs', titles: expeditionTitles },
]

export async function FeaturedAdventure() {
  const allSectionMedia = await Promise.all(
      sections.map(section => fetchMedia(section.titles))
  )

  return (
    <>
        {sections.map((section, index) => (
            <section key={section.slug}>
                <div className="flex justify-between items-center mb-6">
                    <h2 className="font-headline text-3xl font-bold">{section.title}</h2>
                    {/* <Link href={`/discover/${section.slug}`}>
                        <Button variant="outline">More</Button>
                    </Link> */}
                </div>
                <MovieList
                    initialMedia={allSectionMedia[index]}
                    showControls={false}
                    carousel
                />
            </section>
        ))}
    </>
  );
}
