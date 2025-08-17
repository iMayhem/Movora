
import { searchMedia } from '@/lib/tmdb';
import { MovieList } from './MovieList';
import type { Media } from '@/types/tmdb';
import Link from 'next/link';
import { Button } from '../ui/button';

const cartoonNetworkTitles = [
  'The Powerpuff Girls', 'Dexter\'s Laboratory', 'Courage the Cowardly Dog', 'Johnny Bravo',
  'Samurai Jack', 'Ed, Edd n Eddy', 'Ben 10', 'Ben 10: Alien Force', 'Ben 10: Ultimate Alien',
  'Ben 10: Omniverse', 'Roll No. 21', 'Teen Titans', 'Justice League', 'Justice League Unlimited',
  'The Grim Adventures of Billy & Mandy', 'Codename: Kids Next Door', 'Tom and Jerry', 'Scooby-Doo, Where Are You!',
  'Looney Tunes', 'Popeye the Sailor', 'Dragon Ball Z', 'Dragon Ball Super', 'Transformers: Prime',
  'Beyblade', 'Pokémon', 'Adventure Time', 'The Amazing World of Gumball', 'Regular Show',
  'Steven Universe', 'We Bare Bears', 'Chhota Bheem', 'Cow and Chicken', 'I Am Weasel',
  'Mike, Lu & Og', 'Sheep in the Big City', 'Time Squad', 'Whatever Happened to... Robot Jones?',
  'The Life and Times of Juniper Lee', 'Hi Hi Puffy AmiYumi', 'Megas XLR', 'Class of 3000',
  'Chowder', 'The Marvelous Misadventures of Flapjack', 'Total Drama Island', 'Robotboy',
  'Generator Rex', 'The Secret Saturdays', 'Sym-Bionic Titan', 'OK K.O.! Let\'s Be Heroes',
  'Craig of the Creek', 'Victor and Valentino', 'Apple & Onion', 'Summer Camp Island',
  'Uncle Grandpa', 'Clarence', 'Transformers: Animated', 'Inazuma Eleven', 'Gundam Wing',
  'F-Zero GP Legend', 'Galaxy Racers', 'The Mr. Men Show', 'Horrid Henry',
  'Foster\'s Home for Imaginary Friends', 'Camp Lazlo', 'My Gym Partner\'s a Monkey', 'Atomic Betty',
  'Ekkans', 'Mera Bhai Logi', 'Lamput', 'Bandbudh Aur Budbak', 'The Mask: Animated Series',
  'Jackie Chan Adventures', 'Stuart Little: The Animated Series', 'Baby Looney Tunes',
  'The Sylvester & Tweety Mysteries', 'Duck Dodgers', 'What\'s New, Scooby-Doo?', 'The Batman',
  'Batman: The Brave and the Bold', 'Green Lantern: The Animated Series', 'Young Justice',
  'George of the Jungle', 'Code Lyoko', 'Skyland', 'Deltora Quest', 'The Adventures of Tintin'
];

const pogoTitles = [
  'M.A.D.', "Takeshi's Castle", 'Mr. Bean: The Animated Series', 'Oswald', 'Noddy', 'Pingu',
  'Bob the Builder', 'Thomas & Friends', 'F.A.Q.', 'Galli Galli Sim Sim', 'Kumbh Karan',
  'Mighty Raju', 'Super Bheem', 'Andy Pandy',
  'Just Kidding', 'Sunaina', 'C.I.A. (Cambala Investigation Agency)', 'My Little Pony: Friendship Is Magic',
  'Titoo – Har Jawaab Ka Sawaal Hu', 'Grizzy and the Lemmings', 'Tik Tak Tail', 'Yo-kai Watch',
  'The Flintstones', 'Pat & Mat', 'LazyTown', 'HLL: Hollywood\'s Laziest Lessies (Lola & Virginia)',
  'Kipper', 'Angelina Ballerina', 'Fireman Sam', 'Postman Pat', 'Barney & Friends',
  'Sitaare Zameen Par', 'Pogo Amazing Kids Awards', 'Chamki Ki Duniya', 'Kalari Kids',
  'Ek Tha Jungle', 'Bam Bam Bam Gir Pade Hum', 'Inspector Chingum', 'Smashing Simmba',
  'Martin Morning', 'The Smurfs', 'Clifford the Big Red Dog', 'Dragon Tales',
  'Caillou', 'The Garfield Show', 'Nate is Late', 'Wow! Wow! Wubbzy!', 'Gerald McBoing-Boing',
  'Monster Allergy', 'Tara Duncan', 'Bunty Billa Aur Babban'
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
  'Shaka Laka Boom Boom', 'Golmaal Jr.', 'Bhootraja Aur Ronnie', 'Ting Tong', 'Rocko\'s Modern Life',
  'Aaahh!!! Real Monsters', 'As Told by Ginger', 'El Tigre: The Adventures of Manny Rivera',
  'Catscratch', 'The Mighty B!', 'Planet Sheen', 'Sanjay and Craig', 'Harvey Beaks',
  'The Loud House', 'PAW Patrol', 'Go, Diego, Go!', 'Team Umizoomi', 'Bubble Guppies',
  'Blaze and the Monster Machines', 'Shimmer and Shine', 'Max & Ruby', 'Blue\'s Clues',
  'Wonder Pets!', 'All That', 'The Amanda Show', 'True Jackson, VP', 'Big Time Rush',
  'The Haunted Hathaways', 'The Thundermans', 'Nicky, Ricky, Dicky & Dawn', 'Game Shakers',
  'School of Rock', 'Legends of the Hidden Temple', 'Global Guts', 'Figure It Out',
  'Peppa Pig', 'Ben & Holly\'s Little Kingdom', 'Danger Mouse', 'Rabbids Invasion',
  'ALVINNN!!! and the Chipmunks', 'Regal Academy', 'Winx Club', 'Breadwinners', 'Invader Zim',
  'Miss Spider\'s Sunny Patch Friends', 'Oobi', 'Yo Gabba Gabba!'
];

const disneyChannelTitles = [
  'Doraemon', 'Shin-chan', 'Art Attack', 'Best of Luck Nikki', 'The Suite Life of Karan & Kabir',
  'Oye Jassie', 'Hannah Montana', 'Wizards of Waverly Place', 'Phineas and Ferb', 'Mickey Mouse Clubhouse',
  'Kim Possible', 'That\'s So Raven', 'Lizzie McGuire', 'The Suite Life of Zack & Cody', 'Recess',
  'American Dragon: Jake Long', 'Gravity Falls', 'Sofia the First', 'Elena of Avalor', 'Tangled: The Series',
  'Milo Murphy\'s Law', 'Vicky & Vetaal', 'Agadam Bagadam Tigadam', 'Dhoom Machaao Dhoom', 'Ishaan',
  'Fish Hooks', 'Brandy & Mr. Whiskers', "The Emperor's New School", 'Lilo & Stitch: The Series', 'Son Pari',
  'The Oddbods Show', 'The Replacements', 'Good Luck Charlie', 'Jessie', 'Austin & Ally', 'Shake It Up',
  'Liv and Maddie', 'Girl Meets World', 'Dog with a Blog', 'The Proud Family', 'Fillmore!', 'Lloyd in Space',
  'Hannah Montana: The Movie', 'High School Musical', 'Camp Rock', 'Tsum Tsum', 'Zindagi Khatti Meethi',
  'Minnie\'s Bow-Toons', 'Jake and the Never Land Pirates', 'Handy Manny', 'Doc McStuffins'
];

const hungamaTvTitles = [
  'Kiteretsu', 'Hagimaru', 'Kochikame',
  'Slugterra', 'Selfi with Bajrangi', 'Chacha Bhatija', 'Harry & Bunnie', 'BoBoiBoy',
  'Upin & Ipin', 'Vir: The Robot Boy', 'Shaktimaan: The Animated Series', 'Haddi Mera Buddy',
  'Lucky Man', 'Tensai Bakabon', 'Freaktown', 'Hero: Bhakti Hi Shakti Hai', 'Zoran', 'Hatim', 'Supa Strikas',
  'Beyblade: Metal Fusion', 'Zatch Bell!', 'Telematches', 'Bucky Aur Buckette', 'Teletubbies',
  'Eena Meena Deeka', 'Fab5', 'Pokémon: Black & White', 'Pokémon: XY', 'Bernard',
  'V.I.P.O - The Flying Dog'
];

const disneyXdTitles = [
  'Iron Man: Armored Adventures', 'The Avengers: Earth\'s Mightiest Heroes', 'Ultimate Spider-Man',
  'Guardians of the Galaxy', 'Hulk and the Agents of S.M.A.S.H.', 'Star Wars Rebels',
  'Kick Buttowski: Suburban Daredevil', 'Pair of Kings', 'Zeke and Luther', "I'm in the Band",
  'Aaron Stone', 'Kekkashi', 'Big Hero 6: The Series', 'TRON: Uprising', 'Randy Cunningham: 9th Grade Ninja',
  'Motorcity', 'Kid vs. Kat', 'Penn Zero: Part-Time Hero', 'Ryukendo', 'Captain Tsubasa', 'Digimon', 'Pucca',
  'Yin Yang Yo!', 'Super Robot Monkey Team Hyperforce Go!', 'Get Ed', 'W.I.T.C.H.', 'Shaman King',
  'Galactik Football', 'Oban Star-Racers', 'Monster Buster Club', 'Dinosaur King', 'Tutenstein',
  'Kickin\' It', 'Lab Rats', 'Mighty Med', 'Crash & Bernstein', 'Star vs. the Forces of Evil',
  'Wander Over Yonder', 'Pickle and Peanut', 'Future-Worm!', 'Atomic Puppet', 'Doctor Who'
];

const otherChannelTitles = [
  'Sab Jholmaal Hai', 'Honey Bunny ka Jholmaal', 'Paap-O-Meter', 'Guru Aur Bhole',
  'Prince Jai Aur Dumdaar Viru', 'Pyaar Mohabbat Happy Lucky', 'Kicko & Super Speedo',
  'DinoCore', 'Little Singham', 'Fukrey Boyzzz', 'Kisna', 'Sheikh Chilli and Friendz',
  'Rollie with Ollie', 'Wild Kratts', 'Angry Birds Toons', 'Sally Bollywood', 'Chaplin & Co',
  'Transformers: Rescue Bots', 'Maya the Bee', 'How to Be Indie', 'Horrible Histories',
  'Oscar\'s Oasis', 'Dumb Bunnies', 'Arthur', 'Chi\'s Sweet Home', 'Let\'s Go! Anpanman',
  'Larva'
];

const allShows = {
  'cartoon-network': cartoonNetworkTitles,
  'pogo': pogoTitles,
  'nick': nickelodeonTitles,
  'disney': disneyChannelTitles,
  'hungama': hungamaTvTitles,
  'disney-xd': disneyXdTitles,
  'other-channels': otherChannelTitles,
};

export async function fetchIndianCartoonsByChannel(channel: keyof typeof allShows): Promise<Media[]> {
  const titles = allShows[channel];
  if (!titles) return [];
  
  const uniqueTitles = [...new Set(titles)];
  const mediaPromises = uniqueTitles.map(async (title) => {
    let searchTitle = title;
    // Specific search overrides for better accuracy
    if (title === 'Justice League') searchTitle = 'Justice League Unlimited';
    else if (title === 'Pokémon') return (await searchMedia(searchTitle, 'tv', { year: '1997' }))[0];
    else if (title === 'Beyblade') return (await searchMedia(searchTitle, 'tv', { year: '2001' }))[0];
    else if (title === 'High School Musical') return (await searchMedia('High School Musical', 'movie', { year: '2006' }))[0];
    else if (title === 'Camp Rock') return (await searchMedia('Camp Rock', 'movie', { year: '2008' }))[0];
    else if (title === 'He-Man and the Masters of the Universe') return (await searchMedia(searchTitle, 'tv', { year: '1983' }))[0];
    else if (title === 'The Adventures of Tintin') return (await searchMedia(searchTitle, 'tv', { year: '1991' }))[0];
    else if (title === 'Sab Jholmaal Hai') return (await searchMedia('Zig & Sharko', 'tv'))[0];
    else if (title === 'Doraemon') return (await searchMedia(searchTitle, 'tv', { year: '2005' }))[0];


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
    if (media && !seenIds.has(media.id)) {
      uniqueMedia.push(media);
      seenIds.add(media.id);
    }
  }
  return uniqueMedia;
}

const sections = [
    { title: 'Cartoon Network', slug: 'indian-cartoons-cn', channel: 'cartoon-network' as const },
    { title: 'Pogo', slug: 'indian-cartoons-pogo', channel: 'pogo' as const },
    { title: 'Nickelodeon & Nick Jr.', slug: 'indian-cartoons-nick', channel: 'nick' as const },
    { title: 'The Disney Family', slug: 'indian-cartoons-disney', channel: 'disney' as const },
    { title: 'Hungama TV', slug: 'indian-cartoons-hungama', channel: 'hungama' as const },
    { title: 'Disney XD & Jetix', slug: 'indian-cartoons-disney-xd', channel: 'disney-xd' as const },
    { title: 'Sony Yay!, Discovery Kids & More', slug: 'indian-cartoons-other', channel: 'other-channels' as const },
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

    
