// User Authentication & Scoped Database Engine
import { getSupabaseClient } from './supabase';

export interface UserAccount {
    username: string;
    passwordHash: string;
    createdAt: string;
}

export interface HistoryItem {
    id: number;
    title: string;
    poster_path: string | null;
    media_type: 'movie' | 'tv';
    watchedAt: string;
}

// 1. Password Hashing helper (SHA-256)
async function hashPassword(password: string): Promise<string> {
    const encoder = new TextEncoder();
    const data = encoder.encode(password);
    const hashBuffer = await crypto.subtle.digest('SHA-256', data);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
}

// 2. Register Account
export async function registerUser(username: string, password: string): Promise<{ success: boolean; error?: string }> {
    if (typeof window === 'undefined') return { success: false };

    const cleanUsername = username.trim().toLowerCase();
    if (!cleanUsername || cleanUsername.length < 3) {
        return { success: false, error: 'Username must be at least 3 characters long.' };
    }
    if (password.length < 6) {
        return { success: false, error: 'Password must be at least 6 characters long.' };
    }

    try {
        const supabase = getSupabaseClient();

        // Check if user already exists
        const { data: existingUser, error: checkError } = await supabase
            .from('movora_users')
            .select('username')
            .eq('username', cleanUsername)
            .maybeSingle();

        if (checkError) {
            console.error('Error checking user:', checkError);
        }

        if (existingUser) {
            return { success: false, error: 'Username is already taken.' };
        }

        const passwordHash = await hashPassword(password);

        // Insert new user record
        const { error: insertError } = await supabase
            .from('movora_users')
            .insert([{ username: cleanUsername, password_hash: passwordHash, liked_list: [], watchlist: [] }]);

        if (insertError) {
            console.error('Error inserting user:', insertError);
            return { success: false, error: 'Failed to write account records to Supabase.' };
        }

        // Auto-login after registration
        localStorage.setItem('movora_current_user', cleanUsername);
        localStorage.setItem('watch_username', cleanUsername); // Seamless Watch Together sync!
        localStorage.setItem(`movora_liked_${cleanUsername}`, '[]');
        localStorage.setItem(`movora_watchlater_${cleanUsername}`, '[]');

        window.dispatchEvent(new Event('movora_auth_change'));
        return { success: true };
    } catch (e) {
        console.error(e);
        return { success: false, error: 'Database connection failed.' };
    }
}

// 3. Login Account
export async function loginUser(username: string, password: string): Promise<{ success: boolean; error?: string }> {
    if (typeof window === 'undefined') return { success: false };

    const cleanUsername = username.trim().toLowerCase();
    
    try {
        const supabase = getSupabaseClient();

        // Retrieve user record
        const { data: user, error: fetchError } = await supabase
            .from('movora_users')
            .select('*')
            .eq('username', cleanUsername)
            .maybeSingle();

        if (fetchError || !user) {
            return { success: false, error: 'Incorrect username or password.' };
        }

        const passwordHash = await hashPassword(password);
        if (user.password_hash !== passwordHash) {
            return { success: false, error: 'Incorrect username or password.' };
        }

        localStorage.setItem('movora_current_user', cleanUsername);
        localStorage.setItem('watch_username', cleanUsername); // Seamless Watch Together sync!
        
        // Sync lists from retrieved Supabase record to LocalStorage
        if (user.liked_list) {
            localStorage.setItem(`movora_liked_${cleanUsername}`, JSON.stringify(user.liked_list));
        } else {
            localStorage.setItem(`movora_liked_${cleanUsername}`, '[]');
        }
        if (user.watchlist) {
            localStorage.setItem(`movora_watchlater_${cleanUsername}`, JSON.stringify(user.watchlist));
        } else {
            localStorage.setItem(`movora_watchlater_${cleanUsername}`, '[]');
        }

        window.dispatchEvent(new Event('movora_auth_change'));
        return { success: true };
    } catch (e) {
        console.error(e);
        return { success: false, error: 'Database authentication failed.' };
    }
}

// 4. Logout Account
export function logoutUser() {
    if (typeof window === 'undefined') return;
    localStorage.removeItem('movora_current_user');
    // Note: We keep watch_username for backward lobby compatibility or let it clear
    localStorage.removeItem('watch_username');
    window.dispatchEvent(new Event('movora_auth_change'));
}

// 5. Get Active Session
export function getCurrentUser(): string | null {
    if (typeof window === 'undefined') return null;
    return localStorage.getItem('movora_current_user');
}

// Helper to push user lists to Supabase
async function pushUserDataToSupabase(username: string, likes: number[] | null, watchlist: number[] | null) {
    try {
        const supabase = getSupabaseClient();
        const updateData: any = {};
        if (likes !== null) updateData.liked_list = likes;
        if (watchlist !== null) updateData.watchlist = watchlist;
        
        const { error } = await supabase
            .from('movora_users')
            .update(updateData)
            .eq('username', username.toLowerCase());
            
        if (error) {
            console.error('Error updating user lists in Supabase:', error);
        }
    } catch (e) {
        console.error('Failed to update lists in Supabase:', e);
    }
}

// Helper to fetch user lists from Supabase
export async function syncUserDataWithSupabase(username: string) {
    if (typeof window === 'undefined' || !username) return;
    try {
        const supabase = getSupabaseClient();
        const { data: user, error } = await supabase
            .from('movora_users')
            .select('liked_list, watchlist')
            .eq('username', username.toLowerCase())
            .maybeSingle();

        if (!error && user) {
            if (user.liked_list) {
                localStorage.setItem(`movora_liked_${username}`, JSON.stringify(user.liked_list));
            }
            if (user.watchlist) {
                localStorage.setItem(`movora_watchlater_${username}`, JSON.stringify(user.watchlist));
            }
            window.dispatchEvent(new Event('movora_userdata_change'));
        }
    } catch (e) {
        console.error('Failed to sync user data from Supabase:', e);
    }
}

// 6. User Scoped Likes
export function getLikes(username: string): number[] {
    if (typeof window === 'undefined') return [];
    return JSON.parse(localStorage.getItem(`movora_liked_${username}`) || '[]');
}

export function toggleLike(username: string, mediaId: number): boolean {
    const likes = getLikes(username);
    const index = likes.indexOf(mediaId);
    let liked = false;
    if (index > -1) {
        likes.splice(index, 1);
    } else {
        likes.push(mediaId);
        liked = true;
    }
    localStorage.setItem(`movora_liked_${username}`, JSON.stringify(likes));
    window.dispatchEvent(new Event('movora_userdata_change'));
    
    // Async save to Supabase
    pushUserDataToSupabase(username, likes, null);
    
    return liked;
}

// 7. User Scoped Watch Later
export function getWatchLater(username: string): number[] {
    if (typeof window === 'undefined') return [];
    return JSON.parse(localStorage.getItem(`movora_watchlater_${username}`) || '[]');
}

export function toggleWatchLater(username: string, mediaId: number): boolean {
    const list = getWatchLater(username);
    const index = list.indexOf(mediaId);
    let added = false;
    if (index > -1) {
        list.splice(index, 1);
    } else {
        list.push(mediaId);
        added = true;
    }
    localStorage.setItem(`movora_watchlater_${username}`, JSON.stringify(list));
    window.dispatchEvent(new Event('movora_userdata_change'));
    
    // Async save to Supabase
    pushUserDataToSupabase(username, null, list);
    
    return added;
}

// 8. User Scoped Watch History
export function getHistory(username: string): HistoryItem[] {
    if (typeof window === 'undefined') return [];
    return JSON.parse(localStorage.getItem(`movora_history_${username}`) || '[]');
}

export function addToHistory(username: string, item: Omit<HistoryItem, 'watchedAt'>) {
    const history = getHistory(username);
    const filtered = history.filter(h => h.id !== item.id);
    const newItem: HistoryItem = {
        ...item,
        watchedAt: new Date().toISOString()
    };
    filtered.unshift(newItem); // Add to top
    localStorage.setItem(`movora_history_${username}`, JSON.stringify(filtered.slice(0, 20))); // Keep top 20
    window.dispatchEvent(new Event('movora_userdata_change'));
}
