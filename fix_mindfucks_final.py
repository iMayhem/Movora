import os

files = {
    # 1. FIX MINDFUCKS PAGE: Use '|' (OR) instead of ',' (AND) for genres
    "src/app/mindfucks/page.tsx": """
import { discoverMovies } from '@/lib/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import { fetchFeaturedMindfucks } from '@/lib/featured-media';
import { Button } from '@/components/ui/button';
import Link from 'next/link';

// FIXED: Changed ',' (AND) to '|' (OR). 
// Now fetches movies that are Thriller OR Mystery OR Sci-Fi, with a high rating.
const MINDFUCK_PARAMS = { 
    'sort_by': 'vote_average.desc', 
    'vote_count.gte': '200', 
    'with_genres': '9648|53|878', // Mystery OR Thriller OR Sci-Fi
    'without_genres': '10751', // No Family movies
    'include_adult': 'false' 
};

export default async function MindfucksPage() {
  const featuredMedia = await fetchFeaturedMindfucks();
  const mindfuckMovies = await discoverMovies(MINDFUCK_PARAMS, 1);

  return (
    <div className="container mx-auto px-4 py-6 space-y-10">
      <div className="flex justify-between items-center">
        <h1 className="font-headline text-3xl font-bold text-gradient">Best Mindfucks</h1>
         <Link href={`/discover/mindfucks-movies`}><Button variant="outline">More</Button></Link>
      </div>
      
      <section>
        <h2 className="font-headline text-xl font-semibold mb-4 text-muted-foreground">Curated Classics</h2>
        <MovieList initialMedia={featuredMedia} carousel />
      </section>

      <div className="mt-12">
        <h2 className="font-headline text-2xl font-bold mb-4 text-gradient">Critically Acclaimed Thrillers</h2>
         <MovieList initialMedia={mindfuckMovies} slug="mindfucks-movies" carousel/>
      </div>
    </div>
  );
}
""",

    # 2. FIX FEATURED MEDIA: Replace the name-search (unreliable) with a reliable Discover query
    "src/lib/featured-media.ts": """
import { discoverMovies, searchMedia } from '@/lib/tmdb';
import type { Media } from '@/types/tmdb';

export async function fetchFeaturedBollywood(page: number = 1): Promise<Media[]> {
  return await discoverMovies({
    with_original_language: 'hi',
    sort_by: 'popularity.desc',
    'vote_count.gte': '10', 
  }, page);
}

export async function fetchFeaturedHollywood(page: number = 1): Promise<Media[]> {
  return await discoverMovies({
    with_original_language: 'en',
    region: 'US',
    sort_by: 'popularity.desc',
    'vote_count.gte': '200',
    'primary_release_date.lte': new Date().toISOString().split('T')[0]
  }, page);
}

export async function fetchFeaturedKorean(page: number = 1): Promise<Media[]> {
    return await discoverMovies({ 
        with_original_language: 'ko', 
        sort_by: 'popularity.desc',
        'vote_count.gte': '10'
    }, page);
}

export async function fetchFeaturedAnimated(page: number = 1): Promise<Media[]> {
    // Just fetch popular animated movies, it's cleaner and faster than searching titles
    return discoverMovies({ with_genres: '16', sort_by: 'popularity.desc' }, page);
}

export const allShows = {
  'survivalists': ['Man vs. Wild', 'Survivorman', 'Alone', 'Naked and Afraid', 'Bear Grylls', 'Dual Survival'],
  'adventurers': ['Expedition Unknown', 'River Monsters', 'Parts Unknown', 'Man vs. Wild'],
  'wild-kingdom': ['Planet Earth', 'Blue Planet', 'Our Planet', 'Frozen Planet'],
  'competition': ['Survivor', 'The Amazing Race', 'Wipeout', 'American Ninja Warrior'],
  'expeditions': ['Free Solo', 'The Dawn Wall', '14 Peaks', 'Meru'],
};

export async function fetchMedia(titles: string[], page: number = 1): Promise<Media[]> {
  if (page > 1) return []; 
  
  const mediaPromises = titles.map(async (title) => {
    const tvResults = await searchMedia(title, 'tv');
    if (tvResults.length > 0) return tvResults[0];
    const movieResults = await searchMedia(title, 'movie');
    if (movieResults.length > 0) return movieResults[0];
    return null;
  });
  const results = await Promise.all(mediaPromises);
  return results.filter((m): m is Media => m !== null);
}

export async function fetchAllAdventure(page: number = 1): Promise<Media[]> {
    if (page > 1) return [];
    const allTitles = Object.values(allShows).flat();
    return fetchMedia(allTitles);
}

// FIXED: Switched to a Discover query for reliability. 
// Fetches highly rated Mystery movies (Genre 9648)
export async function fetchFeaturedMindfucks(page: number = 1): Promise<Media[]> {
    return discoverMovies({ 
        with_genres: '9648', // Mystery
        sort_by: 'vote_average.desc', 
        'vote_count.gte': '1000', // High vote count = Classics like Inception/Se7en
        'primary_release_date.gte': '1990-01-01'
    }, page);
}

export const allCartoonShows = {
    'cartoon-network': ['Ben 10', 'Dexter', 'Powerpuff Girls', 'Johnny Bravo', 'Courage the Cowardly Dog', 'Samurai Jack', 'Teen Titans'],
    'pogo': ['M.A.D', 'Takeshi Castle', 'Mr. Bean', 'Oswald', 'Noddy', 'Bob the Builder'],
    'nick': ['SpongeBob', 'Avatar: The Last Airbender', 'Danny Phantom', 'Fairly OddParents'],
    'disney': ['Doraemon', 'Shinchan', 'Phineas and Ferb', 'Gravity Falls', 'Kim Possible'],
    'hungama': ['Shinchan', 'Perman', 'Hattori'],
    'disney-xd': ['Kick Buttowski', 'Slugterra', 'Beyblade'],
    'other-channels': ['Oggy', 'Zig & Sharko'],
};

export async function fetchCartoonsByChannel(channel: keyof typeof allCartoonShows, page: number = 1): Promise<Media[]> {
    if (page > 1) return [];
    const titles = allCartoonShows[channel];
    if (!titles) return [];
    return fetchMedia(titles);
}
""",

    # 3. FIX DISCOVER: Ensure the "mindfucks-movies" slug is using the pipe '|' logic too
    "src/lib/discover-categories.ts": """
import { getPopular, getTrending, discoverMoviesPage, discoverTvShowsPage } from '@/lib/tmdb';
import { fetchFeaturedBollywood, fetchFeaturedAnimated, fetchFeaturedKorean, fetchAllAdventure, fetchMedia, allShows, fetchFeaturedHollywood, fetchCartoonsByChannel, fetchFeaturedMindfucks } from '@/lib/featured-media';

const HOLLYWOOD_PARAMS = { with_original_language: 'en', region: 'US' };
const HOLLYWOOD_VOTE_COUNT = { 'vote_count.gte': '300' };
const HOLLYWOOD_POPULAR_VOTE_COUNT = { 'vote_count.gte': '150' };

type Fetcher = (page?: number) => Promise<any>;

export const discoverCategories: Record<string, { title: string; fetcher: Fetcher }> = {
    'top-weekly': {
        title: 'Trending Now',
        fetcher: (page = 1) => getTrending('all', 'week', page),
    },
    'latest-release': {
        title: 'Latest Release',
        fetcher: (page = 1) => discoverMoviesPage({ ...HOLLYWOOD_PARAMS, ...HOLLYWOOD_POPULAR_VOTE_COUNT, sort_by: 'primary_release_date.desc', 'primary_release_date.lte': new Date().toISOString().split('T')[0] }, page),
    },
    'featured-hollywood': {
        title: 'Featured Hollywood',
        fetcher: (page = 1) => fetchFeaturedHollywood(page),
    },
    'top-rated-hollywood-movies': {
        title: 'Top Rated Hollywood Movies',
        fetcher: (page = 1) => discoverMoviesPage({ ...HOLLYWOOD_PARAMS, ...HOLLYWOOD_VOTE_COUNT, sort_by: 'vote_average.desc' }, page),
    },
    'featured-bollywood': {
        title: 'Featured Bollywood',
        fetcher: (page = 1) => fetchFeaturedBollywood(page),
    },
    'featured-animated': {
        title: 'Featured Animated',
        fetcher: (page = 1) => fetchFeaturedAnimated(page),
    },
    'featured-korean': {
        title: 'Featured Korean Cinema',
        fetcher: (page = 1) => fetchFeaturedKorean(page),
    },
    'featured-adventure': {
        title: 'Adventure & Survival',
        fetcher: (page = 1) => fetchAllAdventure(page),
    },
    'mindfucks-movies': {
        title: 'Best Mindfucks',
        // Use OR (|) instead of AND (,)
        fetcher: (page = 1) => discoverMoviesPage({ 'sort_by': 'vote_average.desc', 'vote_count.gte': '200', 'with_genres': '9648|53|878', 'without_genres': '10751', 'include_adult': 'false' }, page),
    },
    'survival-docs': {
        title: 'The Survivalists: Pushing Human Limits',
        fetcher: (page = 1) => fetchMedia(allShows.survivalists, page),
    },
    'explorer-docs': {
        title: 'The Adventurers & Explorers: Journey to the Unknown',
        fetcher: (page = 1) => fetchMedia(allShows.adventurers, page),
    },
    'wildlife-docs': {
        title: 'The Wild Kingdom',
        fetcher: (page = 1) => fetchMedia(allShows['wild-kingdom'], page),
    },
    'competition-docs': {
        title: 'The Competition: Survival of the Fittest',
        fetcher: (page = 1) => fetchMedia(allShows.competition, page),
    },
    'expedition-docs': {
        title: 'Deep Dives: Ocean and Mountain Expeditions',
        fetcher: (page = 1) => fetchMedia(allShows.expeditions, page),
    },
    'popular-hindi-tv': {
        title: 'Popular Hindi TV Shows',
        fetcher: (page = 1) => discoverTvShowsPage({ with_original_language: 'hi', sort_by: 'popularity.desc', 'vote_count.gte': '5' }, page),
    },
    'top-rated-netflix': {
        title: 'Top Rated on Netflix',
        fetcher: (page = 1) => discoverMoviesPage({ watch_region: 'US', with_watch_monetization_types: 'flatrate', with_watch_providers: '8', sort_by: 'vote_average.desc', 'vote_count.gte': '300' }, page),
    },
    'popular-animated-tv': {
        title: 'Popular Animated TV Shows',
        fetcher: (page = 1) => discoverTvShowsPage({ with_genres: '16,10751', sort_by: 'popularity.desc' }, page),
    },
    'popular-korean-tv': {
        title: 'Popular Korean TV Shows',
        fetcher: (page = 1) => discoverTvShowsPage({ with_original_language: 'ko', sort_by: 'popularity.desc', 'vote_count.gte': '10', include_adult: 'false' }, page),
    },
    'latest-bollywood': { title: 'Latest Bollywood Releases', fetcher: (page=1) => discoverMoviesPage({ with_original_language: 'hi', sort_by: 'primary_release_date.desc', 'primary_release_date.lte': new Date().toISOString().split('T')[0] }, page) },
    'classics-bollywood': { title: 'Top-Rated Bollywood Classics', fetcher: (page=1) => discoverMoviesPage({ with_original_language: 'hi', 'primary_release_date.lte': '2000-12-31', sort_by: 'vote_average.desc', 'vote_count.gte': '20' }, page) },
    'action-bollywood': { title: 'Action Bollywood', fetcher: (page=1) => discoverMoviesPage({ with_original_language: 'hi', with_genres: '28' }, page) },
    'romance-bollywood': { title: 'Romantic Bollywood', fetcher: (page=1) => discoverMoviesPage({ with_original_language: 'hi', with_genres: '10749' }, page) },
    'latest-korean-movies': { title: 'Latest Korean Releases', fetcher: (page=1) => discoverMoviesPage({ with_original_language: 'ko', sort_by: 'primary_release_date.desc', 'vote_count.gte': '10' }, page) },
    'top-rated-korean-movies': { title: 'Top-Rated Korean Movies', fetcher: (page=1) => discoverMoviesPage({ with_original_language: 'ko', sort_by: 'vote_average.desc', 'vote_count.gte': '20' }, page) },
    'cartoons-cn': { title: 'Cartoon Network', fetcher: (page=1) => fetchCartoonsByChannel('cartoon-network', page) },
    'cartoons-pogo': { title: 'Pogo', fetcher: (page=1) => fetchCartoonsByChannel('pogo', page) },
    'cartoons-nick': { title: 'Nickelodeon', fetcher: (page=1) => fetchCartoonsByChannel('nick', page) },
    'cartoons-disney': { title: 'Disney Channel', fetcher: (page=1) => fetchCartoonsByChannel('disney', page) },
};
"""
}

for path, content in files.items():
    dir_name = os.path.dirname(path)
    if dir_name:
        os.makedirs(dir_name, exist_ok=True)
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content.strip())
    print(f"Fixed {path}")

print("\\nMindfucks fixed! Restart your server to see the movies.")