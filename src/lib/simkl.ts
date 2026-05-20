// Simkl API integration service
export const SIMKL_CLIENT_ID = '063ca1885820ecffde5d3310c508fc49a0d39d562bd3693c96ed5826760c464e';
export const SIMKL_CLIENT_SECRET = '5c62204f2aead2d9bea5d385b01b6b2b5473e440cf53fa85ba533a663c7b7393';
export const APP_NAME = 'moovie';
export const APP_VERSION = '1.0';

export interface SimklItem {
    last_watched_at?: string;
    movie?: {
        title: string;
        year: number;
        ids: {
            simkl: number;
            tmdb?: string;
            imdb?: string;
        };
    };
    show?: {
        title: string;
        year: number;
        ids: {
            simkl: number;
            tmdb?: string;
            imdb?: string;
        };
    };
}

export interface SimklActivities {
    all_items?: {
        all?: string;
    };
    movies?: {
        watched?: string;
        watchlist?: string;
    };
    shows?: {
        watched?: string;
        watchlist?: string;
    };
}

// Helper to get common fetch headers
function getHeaders(token: string) {
    return {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
        'simkl-api-key': SIMKL_CLIENT_ID,
        'User-Agent': 'MoovieApp/1.0',
    };
}

// 1. Request PIN Code for device authentication
export async function getPinCode(): Promise<{ user_code: string; code: string; expires_in: number; interval: number }> {
    const res = await fetch('https://api.simkl.com/oauth/pin', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'simkl-api-key': SIMKL_CLIENT_ID,
            'User-Agent': 'MoovieApp/1.0',
        },
        body: JSON.stringify({
            client_id: SIMKL_CLIENT_ID,
        }),
    });
    if (!res.ok) {
        throw new Error(`Failed to generate PIN code: ${res.statusText}`);
    }
    return res.json();
}

// 2. Poll for the approved access token
export async function checkPinStatus(code: string): Promise<string | null> {
    const res = await fetch(`https://api.simkl.com/oauth/pin/grant?code=${code}&client_id=${SIMKL_CLIENT_ID}`, {
        method: 'GET',
        headers: {
            'Content-Type': 'application/json',
            'simkl-api-key': SIMKL_CLIENT_ID,
            'User-Agent': 'MoovieApp/1.0',
        },
    });

    if (!res.ok) {
        return null; // Not approved yet or pending
    }

    const data = await res.json();
    if (data && data.access_token) {
        return data.access_token;
    }
    return null;
}

// 3. Fetch Activities to check for updates
export async function fetchActivities(token: string): Promise<SimklActivities | null> {
    try {
        const res = await fetch(`https://api.simkl.com/sync/activities?client_id=${SIMKL_CLIENT_ID}&app-name=${APP_NAME}&app-version=${APP_VERSION}`, {
            method: 'GET',
            headers: getHeaders(token),
        });
        if (!res.ok) return null;
        return res.json();
    } catch (e) {
        console.error('Error fetching activities:', e);
        return null;
    }
}

// Helper to delay execution (prevents overloading & processor spikes)
const delay = (ms: number) => new Promise(resolve => setTimeout(resolve, ms));

// 4. Initial Sync Strategy (Phase 1): Sequential fetches
export async function runInitialSync(token: string): Promise<{ movies: SimklItem[]; shows: SimklItem[] }> {
    console.log('Starting Phase 1 initial sync...');
    
    // Fetch Movies
    const moviesRes = await fetch(`https://api.simkl.com/sync/movies?client_id=${SIMKL_CLIENT_ID}&app-name=${APP_NAME}&app-version=${APP_VERSION}`, {
        method: 'GET',
        headers: getHeaders(token),
    });
    const movies: SimklItem[] = moviesRes.ok ? await moviesRes.json() : [];
    
    await delay(1000); // 1-second delay between requests to preserve API limits
    
    // Fetch Shows
    const showsRes = await fetch(`https://api.simkl.com/sync/shows?client_id=${SIMKL_CLIENT_ID}&app-name=${APP_NAME}&app-version=${APP_VERSION}`, {
        method: 'GET',
        headers: getHeaders(token),
    });
    const shows: SimklItem[] = showsRes.ok ? await showsRes.json() : [];
    
    await delay(1000);

    // Fetch Anime (Can combine with shows or keep placeholder)
    const animeRes = await fetch(`https://api.simkl.com/sync/anime?client_id=${SIMKL_CLIENT_ID}&app-name=${APP_NAME}&app-version=${APP_VERSION}`, {
        method: 'GET',
        headers: getHeaders(token),
    });
    const anime: SimklItem[] = animeRes.ok ? await animeRes.json() : [];

    // Combine shows and anime
    const combinedShows = [...shows, ...anime];

    // Fetch initial activities timestamp to use as baseline for Phase 2
    const activities = await fetchActivities(token);
    const lastActivityDate = activities?.all_items?.all || new Date().toISOString();

    // Persist baseline watchlists locally
    localStorage.setItem('simkl_movies', JSON.stringify(movies));
    localStorage.setItem('simkl_shows', JSON.stringify(combinedShows));
    localStorage.setItem('simkl_last_activity_date', lastActivityDate);

    return { movies, shows: combinedShows };
}

// 5. Continuous Sync Loop (Phase 2): Delta-based update
export async function runContinuousSync(token: string): Promise<{ movies: SimklItem[]; shows: SimklItem[] } | null> {
    const savedDate = localStorage.getItem('simkl_last_activity_date');
    if (!savedDate) {
        // Fallback to Phase 1 if no saved timestamp exists
        return runInitialSync(token);
    }

    console.log('Starting Phase 2 check activities...');
    const activities = await fetchActivities(token);
    if (!activities) return null;

    const latestActivityDate = activities.all_items?.all;
    if (latestActivityDate === savedDate) {
        console.log('No new updates on Simkl. Skipping sync.');
        // Return locally stored data
        const localMovies = JSON.parse(localStorage.getItem('simkl_movies') || '[]');
        const localShows = JSON.parse(localStorage.getItem('simkl_shows') || '[]');
        return { movies: localMovies, shows: localShows };
    }

    console.log(`Updates found (Local: ${savedDate}, Remote: ${latestActivityDate}). Fetching changes...`);
    
    // Fetch delta updates since the saved date
    const res = await fetch(`https://api.simkl.com/sync/all-items/?client_id=${SIMKL_CLIENT_ID}&app-name=${APP_NAME}&app-version=${APP_VERSION}&date_from=${savedDate}`, {
        method: 'GET',
        headers: getHeaders(token),
    });

    if (!res.ok) {
        console.error('Failed to sync all-items delta:', res.statusText);
        return null;
    }

    const deltaData: { movies?: SimklItem[]; shows?: SimklItem[]; anime?: SimklItem[] } = await res.json();
    
    // Merge updates into our local storage cache
    let localMovies: SimklItem[] = JSON.parse(localStorage.getItem('simkl_movies') || '[]');
    let localShows: SimklItem[] = JSON.parse(localStorage.getItem('simkl_shows') || '[]');

    if (deltaData.movies && deltaData.movies.length > 0) {
        deltaData.movies.forEach(item => {
            const index = localMovies.findIndex(m => m.movie?.ids.simkl === item.movie?.ids.simkl);
            if (index > -1) {
                localMovies[index] = item;
            } else {
                localMovies.unshift(item);
            }
        });
    }

    const deltaShows = [...(deltaData.shows || []), ...(deltaData.anime || [])];
    if (deltaShows.length > 0) {
        deltaShows.forEach(item => {
            const index = localShows.findIndex(s => s.show?.ids.simkl === item.show?.ids.simkl);
            if (index > -1) {
                localShows[index] = item;
            } else {
                localShows.unshift(item);
            }
        });
    }

    // Save back updated watchlists and fresh date stamp
    localStorage.setItem('simkl_movies', JSON.stringify(localMovies));
    localStorage.setItem('simkl_shows', JSON.stringify(localShows));
    if (latestActivityDate) {
        localStorage.setItem('simkl_last_activity_date', latestActivityDate);
    }

    return { movies: localMovies, shows: localShows };
}
