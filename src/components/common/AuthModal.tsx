'use client';

import { useState } from 'react';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription } from '@/components/ui/dialog';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Loader2, KeyRound, User, Sparkles } from 'lucide-react';
import { registerUser, loginUser } from '@/lib/auth';

interface AuthModalProps {
    isOpen: boolean;
    onClose: () => void;
}

export function AuthModal({ isOpen, onClose }: AuthModalProps) {
    const [mode, setMode] = useState<'login' | 'signup'>('login');
    const [username, setUsername] = useState<string>('');
    const [password, setPassword] = useState<string>('');
    const [loading, setLoading] = useState<boolean>(false);
    const [error, setError] = useState<string>('');
    const [success, setSuccess] = useState<string>('');

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setError('');
        setSuccess('');

        if (!username.trim() || !password) {
            setError('Please fill in all fields.');
            return;
        }

        setLoading(true);

        try {
            if (mode === 'signup') {
                const res = await registerUser(username, password);
                if (res.success) {
                    setSuccess('Welcome to Movora! Account registered.');
                    setTimeout(() => {
                        onClose();
                        // Reset forms
                        setUsername('');
                        setPassword('');
                        setSuccess('');
                    }, 1500);
                } else {
                    setError(res.error || 'Failed to sign up.');
                }
            } else {
                const res = await loginUser(username, password);
                if (res.success) {
                    setSuccess('Successfully logged in! Enjoy your streaming.');
                    setTimeout(() => {
                        onClose();
                        setUsername('');
                        setPassword('');
                        setSuccess('');
                    }, 1500);
                } else {
                    setError(res.error || 'Failed to login.');
                }
            }
        } catch (err) {
            setError('An unexpected error occurred. Try again.');
        } finally {
            setLoading(false);
        }
    };

    return (
        <Dialog open={isOpen} onOpenChange={(open) => !open && onClose()}>
            <DialogContent className="max-w-[380px] bg-zinc-950 border-zinc-800 text-white rounded-2xl p-6 shadow-2xl">
                <DialogHeader className="text-center flex flex-col items-center">
                    <div className="w-10 h-10 rounded-full bg-violet-600/10 border border-violet-500/30 flex items-center justify-center text-violet-400 mb-2">
                        <Sparkles className="w-5 h-5 animate-pulse" />
                    </div>
                    <DialogTitle className="text-xl font-bold font-headline">
                        {mode === 'login' ? 'Welcome Back' : 'Create Account'}
                    </DialogTitle>
                    <DialogDescription className="text-zinc-400 text-xs mt-1">
                        {mode === 'login' 
                            ? 'Sign in to sync your watch history, likes, and watchlists.' 
                            : 'Choose a unique username to personalize your experience.'
                        }
                    </DialogDescription>
                </DialogHeader>

                <form onSubmit={handleSubmit} className="mt-4 space-y-4">
                    {/* Username Input */}
                    <div className="space-y-1.5 relative">
                        <label className="text-[11px] font-bold uppercase tracking-wider text-zinc-400">Username</label>
                        <div className="relative">
                            <User className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-zinc-500" />
                            <Input 
                                type="text" 
                                placeholder="Enter unique username" 
                                value={username}
                                onChange={(e) => setUsername(e.target.value)}
                                className="pl-10 bg-zinc-900 border-zinc-800 focus:border-violet-500/50 rounded-lg text-sm"
                                disabled={loading}
                            />
                        </div>
                    </div>

                    {/* Password Input */}
                    <div className="space-y-1.5 relative">
                        <label className="text-[11px] font-bold uppercase tracking-wider text-zinc-400">Password</label>
                        <div className="relative">
                            <KeyRound className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-zinc-500" />
                            <Input 
                                type="password" 
                                placeholder="Enter password" 
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                className="pl-10 bg-zinc-900 border-zinc-800 focus:border-violet-500/50 rounded-lg text-sm"
                                disabled={loading}
                            />
                        </div>
                    </div>

                    {/* Messages */}
                    {error && (
                        <div className="p-2.5 rounded-lg bg-rose-950/20 border border-rose-500/30 text-rose-400 text-xs text-center font-medium leading-normal animate-shake">
                            ⚠️ {error}
                        </div>
                    )}
                    {success && (
                        <div className="p-2.5 rounded-lg bg-emerald-950/20 border border-emerald-500/30 text-emerald-400 text-xs text-center font-medium leading-normal">
                            ✨ {success}
                        </div>
                    )}

                    {/* Action Button */}
                    <Button 
                        type="submit" 
                        disabled={loading}
                        className="w-full bg-violet-600 hover:bg-violet-700 text-white font-bold text-xs py-3 rounded-lg flex items-center justify-center gap-2 mt-2 shadow-lg shadow-violet-600/10"
                    >
                        {loading && <Loader2 className="w-3.5 h-3.5 animate-spin" />}
                        {mode === 'login' ? 'Sign In' : 'Sign Up'}
                    </Button>
                </form>

                <div className="mt-4 text-center text-xs text-zinc-500">
                    {mode === 'login' ? (
                        <span>
                            Don't have an account?{' '}
                            <button 
                                onClick={() => { setMode('signup'); setError(''); }}
                                className="text-violet-400 hover:underline font-semibold"
                            >
                                Sign Up
                            </button>
                        </span>
                    ) : (
                        <span>
                            Already have an account?{' '}
                            <button 
                                onClick={() => { setMode('login'); setError(''); }}
                                className="text-violet-400 hover:underline font-semibold"
                            >
                                Sign In
                            </button>
                        </span>
                    )}
                </div>
            </DialogContent>
        </Dialog>
    );
}
