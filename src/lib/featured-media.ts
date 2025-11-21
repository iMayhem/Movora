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