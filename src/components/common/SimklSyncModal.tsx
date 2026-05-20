'use client';

import { useState, useEffect } from 'react';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Loader2, CheckCircle2, RefreshCw, LogOut, ArrowRight, UserCheck } from 'lucide-react';
import { 
    getPinCode, 
    checkPinStatus, 
    runInitialSync, 
    runContinuousSync,
    SIMKL_CLIENT_ID
} from '@/lib/simkl';

interface SimklSyncModalProps {
    isOpen: boolean;
    onClose: () => void;
}

export function SimklSyncModal({ isOpen, onClose }: SimklSyncModalProps) {
    const [token, setToken] = useState<string | null>(null);
    const [pinData, setPinData] = useState<{ user_code: string; code: string; expires_in: number } | null>(null);
    const [loading, setLoading] = useState<boolean>(false);
    const [syncing, setSyncing] = useState<boolean>(false);
    const [syncProgress, setSyncProgress] = useState<string>('');
    const [statusMessage, setStatusMessage] = useState<string>('');
    const [lastSync, setLastSync] = useState<string | null>(null);

    useEffect(() => {
        if (typeof window !== 'undefined') {
            const savedToken = localStorage.getItem('simkl_access_token');
            const savedLastSync = localStorage.getItem('simkl_last_activity_date');
            setToken(savedToken);
            setLastSync(savedLastSync);
        }
    }, [isOpen]);

    // Handle initiating device code PIN authorization
    const handleConnect = async () => {
        try {
            setLoading(true);
            setStatusMessage('Generating PIN Code...');
            const codeData = await getPinCode();
            setPinData(codeData);
            setStatusMessage('Waiting for authorization on Simkl...');
            setLoading(false);

            // Start polling Simkl grant status
            const intervalId = setInterval(async () => {
                const accessToken = await checkPinStatus(codeData.code);
                if (accessToken) {
                    clearInterval(intervalId);
                    localStorage.setItem('simkl_access_token', accessToken);
                    setToken(accessToken);
                    setPinData(null);
                    // Run initial library sync sequentially
                    await handleInitialSync(accessToken);
                }
            }, codeData.interval * 1000);

            // Clear polling after expiration
            setTimeout(() => {
                clearInterval(intervalId);
                setPinData(null);
                setStatusMessage('PIN Code expired. Please generate a new one.');
            }, codeData.expires_in * 1000);

        } catch (e) {
            console.error(e);
            setStatusMessage('Failed to connect to Simkl. Try again.');
            setLoading(false);
        }
    };

    // Phase 1: Sequential Initial Sync
    const handleInitialSync = async (accessToken: string) => {
        try {
            setSyncing(true);
            setSyncProgress('Phase 1: Downloading Movies Library...');
            const data = await runInitialSync(accessToken);
            setSyncProgress(`Success! Synced ${data.movies.length} movies & ${data.shows.length} shows.`);
            setLastSync(localStorage.getItem('simkl_last_activity_date'));
            setSyncing(false);
            // Refresh main page watchlist if any
            window.dispatchEvent(new Event('simkl_sync_complete'));
        } catch (e) {
            console.error(e);
            setSyncProgress('Failed to complete initial synchronization.');
            setSyncing(false);
        }
    };

    // Phase 2: Continuous Delta-Based Sync
    const handleDeltaSync = async () => {
        if (!token) return;
        try {
            setSyncing(true);
            setSyncProgress('Phase 2: Checking activities for changes...');
            const data = await runContinuousSync(token);
            if (data) {
                setSyncProgress(`Watchlist up-to-date! (${data.movies.length} movies, ${data.shows.length} shows/anime Cached)`);
                setLastSync(localStorage.getItem('simkl_last_activity_date'));
            } else {
                setSyncProgress('Watchlist is already synchronized with Simkl.');
            }
            setSyncing(false);
            window.dispatchEvent(new Event('simkl_sync_complete'));
        } catch (e) {
            console.error(e);
            setSyncProgress('Continuous sync failed.');
            setSyncing(false);
        }
    };

    const handleDisconnect = () => {
        localStorage.removeItem('simkl_access_token');
        localStorage.removeItem('simkl_movies');
        localStorage.removeItem('simkl_shows');
        localStorage.removeItem('simkl_last_activity_date');
        setToken(null);
        setLastSync(null);
        setPinData(null);
        setStatusMessage('');
        setSyncProgress('');
        window.dispatchEvent(new Event('simkl_sync_complete'));
    };

    return (
        <Dialog open={isOpen} onOpenChange={(open) => !open && onClose()}>
            <DialogContent className="max-w-[420px] bg-zinc-950 border-zinc-800 text-white rounded-2xl p-6 shadow-2xl">
                <DialogHeader className="text-center">
                    <DialogTitle className="text-xl font-bold flex items-center justify-center gap-2">
                        <span className="text-violet-500 font-extrabold tracking-tight">SIMKL</span> 
                        <span>Watchlist Sync</span>
                    </DialogTitle>
                    <DialogDescription className="text-zinc-400 text-xs mt-1">
                        Synchronize your movies, shows, and anime watchlists across all your devices in real-time.
                    </DialogDescription>
                </DialogHeader>

                <div className="mt-4 flex flex-col items-center justify-center gap-4">
                    {/* Status Screen: CONNECTED */}
                    {token ? (
                        <div className="w-full flex flex-col items-center gap-4 text-center">
                            <div className="relative">
                                <div className="w-16 h-16 rounded-full bg-emerald-950/50 border border-emerald-500/30 flex items-center justify-center text-emerald-400">
                                    <UserCheck className="w-8 h-8" />
                                </div>
                                <div className="absolute -bottom-1 -right-1 w-5 h-5 rounded-full bg-emerald-500 flex items-center justify-center border-2 border-zinc-950">
                                    <CheckCircle2 className="w-3 h-3 text-black font-bold" />
                                </div>
                            </div>
                            
                            <div>
                                <h4 className="font-semibold text-sm">Simkl Account Connected</h4>
                                {lastSync && (
                                    <p className="text-[10px] text-zinc-500 mt-1">
                                        Baseline Baseline Date: {new Date(lastSync).toLocaleString()}
                                    </p>
                                )}
                            </div>

                            {/* Sync Actions */}
                            <div className="w-full flex flex-col gap-2 mt-2">
                                <Button 
                                    onClick={handleDeltaSync} 
                                    disabled={syncing}
                                    className="w-full bg-violet-600 hover:bg-violet-700 text-white font-medium text-xs py-3 rounded-lg flex items-center justify-center gap-2"
                                >
                                    {syncing ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : <RefreshCw className="w-3.5 h-3.5" />}
                                    {syncing ? 'Syncing...' : 'Sync Watchlist Changes'}
                                </Button>
                                
                                <Button 
                                    onClick={handleDisconnect}
                                    variant="ghost"
                                    className="w-full text-zinc-400 hover:text-rose-400 hover:bg-rose-950/20 text-xs py-2 rounded-lg flex items-center justify-center gap-1.5"
                                >
                                    <LogOut className="w-3.5 h-3.5" />
                                    Disconnect Account
                                </Button>
                            </div>
                        </div>
                    ) : (
                        /* Status Screen: DISCONNECTED / INSTRUCTIONS */
                        <div className="w-full flex flex-col items-center gap-4 text-center">
                            {pinData ? (
                                <div className="w-full flex flex-col items-center gap-4">
                                    <div className="p-4 bg-zinc-900 border border-zinc-800 rounded-xl w-full">
                                        <p className="text-[11px] text-zinc-400 mb-2 uppercase tracking-wider font-semibold">Verification Step</p>
                                        <a 
                                            href="https://simkl.com/pin" 
                                            target="_blank" 
                                            rel="noopener noreferrer"
                                            className="text-violet-400 hover:text-violet-300 font-bold text-xs inline-flex items-center gap-1 underline mb-3"
                                        >
                                            Go to simkl.com/pin <ArrowRight className="w-3 h-3" />
                                        </a>
                                        
                                        <div className="bg-black py-4 px-6 rounded-lg font-mono text-3xl font-extrabold tracking-widest border border-zinc-800 text-amber-400 select-all shadow-inner">
                                            {pinData.user_code}
                                        </div>
                                    </div>
                                    
                                    <div className="flex items-center gap-2 text-[11px] text-zinc-500">
                                        <Loader2 className="w-3 h-3 animate-spin text-violet-500" />
                                        <span>Waiting for authorization...</span>
                                    </div>
                                </div>
                            ) : (
                                <div className="w-full flex flex-col items-center gap-3">
                                    <div className="w-12 h-12 rounded-full bg-zinc-900 border border-zinc-800 flex items-center justify-center text-zinc-400 mb-1">
                                        💡
                                    </div>
                                    <p className="text-zinc-400 text-xs leading-relaxed max-w-[320px]">
                                        Authorize this app with your Simkl account to easily import and track what you watch across all libraries.
                                    </p>
                                    <Button 
                                        onClick={handleConnect}
                                        disabled={loading}
                                        className="w-full mt-2 bg-zinc-100 text-zinc-950 hover:bg-zinc-200 font-bold text-xs py-3 rounded-lg flex items-center justify-center gap-1.5"
                                    >
                                        {loading ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : '🔌'}
                                        {loading ? 'Initializing...' : 'Authorize Simkl Account'}
                                    </Button>
                                </div>
                            )}
                        </div>
                    )}

                    {/* Progress / Status Log Banners */}
                    {(statusMessage || syncProgress) && (
                        <div className="w-full mt-3 p-3 rounded-xl bg-zinc-900/50 border border-zinc-800/40 text-left text-[11px] text-zinc-400 leading-normal flex flex-col gap-1">
                            {statusMessage && <p className="font-semibold text-zinc-300">{statusMessage}</p>}
                            {syncProgress && <p className="font-mono text-violet-400">{syncProgress}</p>}
                        </div>
                    )}
                </div>
            </DialogContent>
        </Dialog>
    );
}
