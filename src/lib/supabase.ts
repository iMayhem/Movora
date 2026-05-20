import { createClient } from '@supabase/supabase-js';

const DEFAULT_SUPABASE_URL = 'https://ggzuydqfxamvwalbfvyr.supabase.co';
const DEFAULT_SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdnenV5ZHFmeGFtdndhbGJmdnlyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkyODk3MzQsImV4cCI6MjA5NDg2NTczNH0.B6A0oTZmds2vSrrKbfd0Nb1_Dal1pUnJutigiRZda2I';

export function getSupabaseClient() {
    if (typeof window === 'undefined') {
        return createClient(DEFAULT_SUPABASE_URL, DEFAULT_SUPABASE_KEY);
    }
    
    const url = localStorage.getItem('supabase_url') || DEFAULT_SUPABASE_URL;
    const key = localStorage.getItem('supabase_key') || DEFAULT_SUPABASE_KEY;
    
    return createClient(url, key);
}
