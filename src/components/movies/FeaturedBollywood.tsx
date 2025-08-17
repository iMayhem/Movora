
import { searchMedia } from '@/lib/tmdb';
import { MovieList } from './MovieList';
import type { Media } from '@/types/tmdb';

const featuredTitles = [
    "Sardar Udham",
    "Gangubai Kathiawadi",
    "The Kashmir Files",
    "Jogi",
    "12th Fail",
    "Sirf Ek Bandaa Kaafi Hai",
    "Mrs. Chatterjee vs Norway",
    "Zwigato",
    "Laapataa Ladies",
    "Article 370",
    "Pathaan",
    "Jawan",
    "Animal",
    "Gadar 2",
    "Brahmāstra: Part One – Shiva",
    "Drishyam 2",
    "Bhool Bhulaiyaa 2",
    "Rocky Aur Rani Kii Prem Kahaani",
    "Tu Jhoothi Main Makkaar",
    "Fighter",
    "Chandigarh Kare Aashiqui",
    "83",
    "Badhaai Do",
    "Jhund",
    "Uunchai",
    "OMG 2",
    "Satyaprem Ki Katha",
    "Bheed",
    "Gulmohar",
    "Chandu Champion",
    "Dhamaka",
    "A Thursday",
    "Freddy",
    "An Action Hero",
    "Chor Nikal Ke Bhaga",
    "Gaslight",
    "Gumraah",
    "Jaane Jaan",
    "Merry Christmas",
    "Shaitaan",
    "Mimi",
    "Dasvi",
    "Govinda Naam Mera",
    "Doctor G",
    "Zara Hatke Zara Bachke",
    "Dream Girl 2",
    "Fukrey 3",
    "Dunki",
    "Madgaon Express",
    "Crew",
    "Shershaah",
    "Ram Setu",
    "Bhediya",
    "Vikram Vedha",
    "Cirkus",
    "Salaam Venky",
    "Selfiee",
    "Bholaa",
    "Kisi Ka Bhai Kisi Ki Jaan",
    "Adipurush",
    "Bawaal",
    "Ghoomer",
    "The Great Indian Family",
    "Mission Raniganj",
    "Ganapath",
    "Tejas",
    "Tiger 3",
    "Sam Bahadur",
    "Pippa",
    "Kadak Singh",
    "Teri Baaton Mein Aisa Uljha Jiya",
    "Crakk",
    "Bade Miyan Chote Miyan",
    "Maidaan",
    "Srikanth",
    "Mr. & Mrs. Mahi",
    "Munjya",
    "Stree 2",
    "Bhool Bhulaiyaa 3",
    "Singham Again",
    "Bunty Aur Babli 2",
    "Atrangi Re",
    "Gehraiyaan",
    "Love Hostel",
    "Kaun Pravin Tambe?",
    "Jersey",
    "Runway 34",
    "Jayeshbhai Jordaar",
    "Samrat Prithviraj",
    "Jugjugg Jeeyo",
    "Shamshera",
    "Raksha Bandhan",
    "Darlings",
    "Laal Singh Chaddha",
    "Cuttputlli",
    "Monica, O My Darling",
    "Kuttey",
    "Shehzada",
    "Afwaah",
    "IB 71"
];

async function fetchFeaturedMedia(): Promise<Media[]> {
  const uniqueTitles = [...new Set(featuredTitles)];
  const mediaPromises = uniqueTitles.map(async (title) => {
    const movieResults = await searchMedia(title, 'movie', { region: 'IN' });
    if (movieResults.length > 0) return movieResults[0];

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

export async function FeaturedBollywood() {
  const featuredMedia = await fetchFeaturedMedia();

  return (
    <section>
        <div className="flex justify-between items-center mb-6">
            <h2 className="font-headline text-3xl font-bold">Featured Bollywood</h2>
        </div>
        <MovieList initialMedia={featuredMedia} showControls={false} />
    </section>
  );
}
