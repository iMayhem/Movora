
import { searchMedia } from '@/lib/tmdb';
import { MovieList } from './MovieList';
import type { Media } from '@/types/tmdb';
import Link from 'next/link';
import { Button } from '../ui/button';

const survivalistTitles = [
    'Survivorman', 'Dual Survival', 'Naked and Afraid', 'Naked and Afraid XL', 'Alone',
    'The Island with Bear Grylls', 'Marooned with Ed Stafford', 'Man, Woman, Wild',
    'Primal Survivor', 'Dude, You\'re Screwed', 'Win the Wilderness', 'Out of the Wild: The Alaska Experiment',
    'Fat Guys in the Woods', 'Survive This', 'I Shouldn\'t Be Alive', 'Kicking and Screaming',
    'Remote Survival', 'The Colony', 'Tethered', 'Stranded with a Million Dollars', 'Surviving the Cut',
    'SOS: How to Survive', 'Manhunt', 'Beyond Survival with Les Stroud', 'Ed Stafford: First Man Out',
    'Naked and Afraid: Last One Standing', '100 Days Wild', 'The Bridge', 'The Selection: Special Operations Experiment',
    'Outlast', 'Can You Survive?', 'Escape', 'Surviving a Serial Killer', 'Worst-Case Scenario',
    'I Survived...', 'The Boonies', 'Building Off the Grid', 'Homestead Rescue', 'Mountain Men',
    'Live Free or Die', 'Life After People', 'The Last Alaskans', 'Yukon Men', 'Ice Lake Rebels',
    'The Legend of Mick Dodge', 'Ultimate Survivor’s Guide', 'How to Survive the End of the World',
    'Surviving a Disaster', 'Doomsday Preppers', 'Apocalypse Man', 'Surviving Death', '72 Hours', 'Castaways'
];

const adventurerTitles = [
    'Expedition Unknown', 'Running Wild with Bear Grylls', 'Life Below Zero', 'Pole to Pole with Michael Palin',
    'Long Way Round', 'Long Way Down', 'Conan Without Borders', 'Parts Unknown', 'Dark Tourist',
    'Departures', 'Globe Trekker', 'An Idiot Abroad', 'The World\'s Most Dangerous Roads',
    'Tales by Light', 'Extreme Treks', 'Walking the Himalayas', 'Race to the Center of the Earth', 'The Kindness Diaries',
    'Travels with My Father', 'Somebody Feed Phil', 'Ugly Delicious', 'Restaurants on the Edge', 'Down to Earth with Zac Efron',
    'The Americas with Simon Reeve', 'Russia with Simon Reeve', 'Turkey with Simon Reeve', 'Caribbean with Simon Reeve',
    'Burma with Simon Reeve', 'The Indian Ocean with Simon Reeve', 'Joanna Lumley\'s Silk Road Adventure',
    'Joanna Lumley\'s Trans-Siberian Adventure', 'Stephen Fry in America', 'Billy Connolly: Journey to the Edge of the World',
    'The Grand Tour', 'Top Gear', 'Anthony Bourdain: No Reservations', 'Rick Steves\' Europe', 'House Hunters International',

    'Lost Cities with Albert Lin', 'Gordon Ramsay: Uncharted', 'Edge of the Unknown with Jimmy Chin',
    'Welcome to Earth', 'The Misadventures of Romesh Ranganathan', 'Larry Charles\' Dangerous World of Comedy',
    'Huang\'s World', 'Gaycation', 'Action Bronson Watches Ancient Aliens', 'Fuck, That\'s Delicious', 'Dead Set on Life',
    'Abandoned', 'Black Market', 'Weediquette', 'States of Undress'
];

const wildKingdomTitles = [
    'Planet Earth', 'Planet Earth II', 'Blue Planet', 'Blue Planet II', 'Our Planet', 'Frozen Planet', 'Frozen Planet II',
    'The Hunt', 'Dynasties', 'Dynasties II', 'Night on Earth', 'Life', 'Africa', 'Yellowstone', 'Untamed Americas',
    'Wildest Islands', 'Serengeti', 'Hostile Planet', 'Seven Worlds, One Planet', 'A Perfect Planet', 'The Green Planet',
    'Wild Babies', 'Animal', 'Our Great National Parks', 'Absurd Planet', 'Tiny Creatures', 'Dancing with the Birds',
    'Growing Up Wild', 'Chimp Empire', 'Queens', 'Predators', 'Our Universe', 'Life on Our Planet',
    'Wild Isles', 'Big Cats', 'Shark', 'The Mating Game', 'Spy in the Wild',
    'The Rockies: Kingdoms of the Sky', 'Japan: Earth\'s Enchanted Islands', 'Mexico: Earth\'s Festival of Life',
    'India: Nature\'s Wonderland', 'Ganges', 'Wild China', 'The Nile: Egypt\'s Great River', 'The Amazon with Bruce Parry',
    'South Pacific', 'Great Barrier Reef with David Attenborough', 'Galapagos', 'Madagascar', 'Nature\'s Great Events',
    'The Life of Birds', 'The Life of Mammals', 'Life in the Undergrowth', 'Life in Cold Blood', 'The Private Life of Plants'
];

const competitionTitles = [
    'Survivor', 'The Amazing Race', 'Eco-Challenge', 'Ultimate Survival Alaska',
    '72 Dangerous Animals to Live With', 'Top Shot', 'Forged in Fire', 'The Genius', 'The Mole',
    'American Ninja Warrior', 'Physical: 100', 'The Circle', 'Big Brother', 'The Challenge',
    'MasterChef', 'The Great British Bake Off', 'Project Runway', 'RuPaul\'s Drag Race', 'Top Chef',
    'The Voice', 'American Idol', 'Dancing with the Stars', 'America\'s Got Talent', 'Wipeout',
    'Holey Moley', 'Floor Is Lava', 'Awake: The Million Dollar Game', 'The Titan Games',
    'Tough as Nails', 'American Grit', 'Steve Austin\'s Broken Skull Challenge', 'The World\'s Toughest Race: Eco-Challenge Fiji',
    'The Great Climb', 'Race across the World', 'Hunted', 'The Traitors', 'Traitors Canada', 'Traitors Australia', 'Traitors UK',
    'SAS: Who Dares Wins', 'Alone: The Skills Challenge', 'Alone: Frozen', 'Go-Big Show',
    'Domino Masters', 'Lego Masters', 'Making It', 'Blown Away', 'The Big Flower Fight', 'Next in Fashion', 'Glow Up'
];

const expeditionTitles = [
    'The Blue Planet: A Natural History of the Oceans', 'Oceans', 'Mission Blue', 'Chasing Coral',
    'Blackfish', 'My Octopus Teacher', 'Touching the Void', 'Free Solo', 'Meru', 'The Dawn Wall',
    '14 Peaks: Nothing Is Impossible', 'Sherpa', 'Everest: Beyond the Limit', 'The Alpinist',
    'The Last Mountain', 'Mountain', 'Valley Uprising', 'Dirtbag: The Legend of Fred Beckey',
    'The Wildest Dream: Conquest of Everest', 'Beyond the Edge', 'Blindsight', 'The Summit',

    'Secrets of the Whales', 'Puff: Wonders of the Reef', 'Becoming Cousteau', 'The Rescue',
    'The Cave', 'Last Breath', 'Apollo 11', 'For All Mankind', 'In the Shadow of the Moon',
    'Into the Inferno', 'The Fire Within: A Requiem for Katia and Maurice Krafft', 'Attica', 'Ascension',
    'The Biggest Little Farm', 'Honeyland', 'Grizzly Man', 'Encounters at the End of the World',
    'Cave of Forgotten Dreams', 'The White Diamond', 'Jiro Dreams of Sushi', 'Man on Wire',
    'Searching for Sugar Man', 'The Imposter', 'Three Identical Strangers', 'Won\'t You Be My Neighbor?', 'RBG', 'Summer of Soul'
];

export const allShows = {
  'survivalists': survivalistTitles,
  'adventurers': adventurerTitles,
  'wild-kingdom': wildKingdomTitles,
  'competition': competitionTitles,
  'expeditions': expeditionTitles,
};

export async function fetchMedia(titles: string[]): Promise<Media[]> {
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
                    <Link href={`/discover/${section.slug}`}>
                        <Button variant="outline">More</Button>
                    </Link>
                </div>
                <MovieList
                    initialMedia={allSectionMedia[index]}
                    
                    carousel
                />
            </section>
        ))}
    </>
  );
}
