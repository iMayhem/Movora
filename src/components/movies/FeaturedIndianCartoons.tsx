
import { searchMedia } from '@/lib/tmdb';
import { MovieList } from './MovieList';
import type { Media } from '@/types/tmdb';
import Link from 'next/link';
import { Button } from '../ui/button';

const cartoonNetworkTitles = [
  'The Powerpuff Girls', 'Dexter\'s Laboratory', 'Courage the Cowardly Dog', 'Johnny Bravo',
  'Samurai Jack', 'Ed, Edd n Eddy', 'Ben 10', 'Ben 10: Alien Force', 'Ben 10: Ultimate Alien',
  'Ben 10: Omniverse', 'Roll No. 21', 'Teen Titans', 'Justice League',
  'The Grim Adventures of Billy & Mandy', 'Codename: Kids Next Door', 'Tom and Jerry', 'Scooby-Doo, Where Are You!',
  'Looney Tunes', 'Popeye the Sailor', 'Dragon Ball Z', 'Dragon Ball Super', 'Transformers: Prime',
  'Beyblade', 'Pokémon', 'Adventure Time', 'The Amazing World of Gumball', 'Regular Show',
  'Steven Universe', 'We Bare Bears', 'Chhota Bheem'
];

const pogoTitles = [
  'M.A.D.', "Takeshi's Castle", 'Mr. Bean: The Animated Series', 'Oswald', 'Noddy', 'Pingu',
  'Bob the Builder', 'Thomas & Friends', 'F.A.Q.', 'Galli Galli Sim Sim', 'Kumbh Karan',
  'The Powerpuff Girls', 'Chhota Bheem', 'Mighty Raju', 'Super Bheem', 'Andy Pandy',
  'Just Kidding', 'Sunaina', 'C.I.A. (Cambala Investigation Agency)', 'My Little Pony: Friendship Is Magic',
  'Titoo – Har Jawaab Ka Sawaal Hu', 'Grizzy and the Lemmings', 'Tik Tak Tail', 'Yo-kai Watch',
  'The Flintstones'
];

const nickelodeonTitles = [
  'SpongeBob SquarePants', 'Dora the Explorer', 'Motu Patlu', 'Pakdam Pakdai', 'Ninja Hattori-kun',
  'Perman', 'Avatar: The Last Airbender', 'The Penguins of Madagascar', 'Kung Fu Panda: Legends of Awesomeness',
  'Shaun the Sheep', 'Rudra: Boom Chik Chik Boom', 'Gattu Battu', 'Shiva', 'Oggy and the Cockroaches',
  'Keymon Ache', 'Teenage Mutant Ninja Turtles', 'The Fairly OddParents', 'Jimmy Neutron: Boy Genius',
  'Rocket Power', 'Hey Arnold!', 'Rugrats', 'Kenan & Kel', 'Drake & Josh', 'iCarly',
  'Victorious', 'Sam & Cat', 'Henry Danger', 'Zig & Sharko', 'Power Rangers', 'Little Krishna',
  'Johnny Test', 'Back at the Barnyard', 'T.U.F.F. Puppy', 'Fanboy & Chum Chum', 'Danny Phantom',
  'My Life as a Teenage Robot', 'ChalkZone', 'The Wild Thornberrys', 'CatDog', 'The Angry Beavers',
  'Shaka Laka Boom Boom', 'Golmaal Jr.', 'Bhootraja Aur Ronnie', 'Ting Tong'
];

const disneyChannelTitles = [
  'Doraemon', 'Shin-chan', 'Art Attack', 'Best of Luck Nikki', 'The Suite Life of Karan & Kabir',
  'Oye Jassie', 'Hannah Montana', 'Wizards of Waverly Place', 'Phineas and Ferb', 'Mickey Mouse Clubhouse',
  'Kim Possible', 'That\'s So Raven', 'Lizzie McGuire', 'The Suite Life of Zack & Cody', 'Recess',
  'American Dragon: Jake Long', 'Gravity Falls', 'Sofia the First', 'Elena of Avalor', 'Tangled: The Series',
  'Milo Murphy\'s Law', 'Vicky & Vetaal', 'Agadam Bagadam Tigadam', 'Dhoom Machaao Dhoom', 'Ishaan',
  'Fish Hooks', 'Brandy & Mr. Whiskers', "The Emperor's New School", 'Lilo & Stitch: The Series', 'Son Pari',
  'The Oddbods Show'
];

const hungamaTvTitles = [
  'Shin-chan', 'Doraemon', 'Kiteretsu', 'Pokémon', 'Hagimaru', 'Kochikame', 'Power Rangers',
  'Slugterra', 'Beyblade', 'Selfi with Bajrangi', 'Chacha Bhatija', 'Harry & Bunnie', 'BoBoiBoy',
  'Upin & Ipin', 'Vir: The Robot Boy', 'Shaktimaan: The Animated Series', 'Haddi Mera Buddy',
  'Lucky Man', 'Tensai Bakabon', 'Freaktown', 'Hero: Bhakti Hi Shakti Hai', 'Zoran', 'Hatim', 'Supa Strikas'
];

const disneyXdTitles = [
  'Iron Man: Armored Adventures', 'The Avengers: Earth\'s Mightiest Heroes', 'Ultimate Spider-Man',
  'Guardians of the Galaxy', 'Hulk and the Agents of S.M.A.S.H.', 'Star Wars Rebels',
  'Kick Buttowski: Suburban Daredevil', 'Pair of Kings', 'Zeke and Luther', "I'm in the Band",
  'Aaron Stone', 'Kekkashi', 'Big Hero 6: The Series', 'TRON: Uprising', 'Randy Cunningham: 9th Grade Ninja',
  'Motorcity', 'Kid vs. Kat', 'Penn Zero: Part-Time Hero', 'Ryukendo', 'Captain Tsubasa', 'Digimon'
];

const allShows = {
  'cartoon-network': cartoonNetworkTitles,
  'pogo': pogoTitles,
  'nick': nickelodeonTitles,
  'disney': disneyChannelTitles,
  'hungama': hungamaTvTitles,
  'disney-xd': disneyXdTitles,
};

export async function fetchIndianCartoonsByChannel(channel: keyof typeof allShows): Promise<Media[]> {
  const titles = allShows[channel];
  if (!titles) return [];
  
  const uniqueTitles = [...new Set(titles)];
  const mediaPromises = uniqueTitles.map(async (title) => {
    let searchTitle = title;
    if (title === 'Justice League') {
        searchTitle = 'Justice League Unlimited';
    } else if (title === 'Pokémon') {
        return (await searchMedia(searchTitle, 'tv', { year: '1997' }))[0];
    } else if (title === 'Beyblade') {
        return (await searchMedia(searchTitle, 'tv', { year: '2001' }))[0];
    }

    const tvResults = await searchMedia(searchTitle, 'tv');
    if (tvResults.length > 0) return tvResults[0];

    const movieResults = await searchMedia(searchTitle, 'movie');
    if (movieResults.length > 0) return movieResults[0];

    return null;
  });

  const results = await Promise.all(mediaPromises);
  const validResults = results.filter((media): media is Media => media !== null);

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

const sections = [
    { title: 'Cartoon Network', slug: 'indian-cartoons-cn', channel: 'cartoon-network' as const },
    { title: 'Pogo', slug: 'indian-cartoons-pogo', channel: 'pogo' as const },
    { title: 'Nickelodeon', slug: 'indian-cartoons-nick', channel: 'nick' as const },
    { title: 'Disney Channel', slug: 'indian-cartoons-disney', channel: 'disney' as const },
    { title: 'Hungama TV', slug: 'indian-cartoons-hungama', channel: 'hungama' as const },
    { title: 'Disney XD', slug: 'indian-cartoons-disney-xd', channel: 'disney-xd' as const },
]

export async function FeaturedIndianCartoons() {
  const allSectionMedia = await Promise.all(
      sections.map(section => fetchIndianCartoonsByChannel(section.channel))
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
                    showControls={false}
                    carousel
                />
            </section>
        ))}
    </>
  );
}
