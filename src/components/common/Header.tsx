'use client';

import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { useState, useEffect, FormEvent, useTransition } from 'react';
import { Input } from '@/components/ui/input';
import { 
  Search, Menu, Loader2, Heart, Bookmark, LayoutGrid, ChevronDown, ChevronUp,
  Flame, Palette, Star, Gem, History, Smile, Eye, Compass, Zap, Trophy, Activity, Tv, Sun,
  Film, Sparkles, Gamepad2, Skull, Music, Newspaper, MessageSquare, MonitorPlay, Flag, EyeOff, Users
} from 'lucide-react';
import { cn } from '@/lib/utils';
import { Button } from '@/components/ui/button';
import { Sheet, SheetContent, SheetTrigger, SheetClose } from '@/components/ui/sheet';
import { useLoader } from './LoaderProvider';
import { getCurrentUser, logoutUser, getLikes, getWatchLater, syncUserDataWithSupabase } from '@/lib/auth';
import { AuthModal } from './AuthModal';
import { PersonalizedListDrawer } from './PersonalizedListDrawer';

// Mapped genres matching Left column of the screenshot
const leftColumnGenres = [
  { name: 'Action', slug: 'action', icon: Flame, color: 'text-orange-500' },
  { name: 'Animation', slug: 'animation', icon: Palette, color: 'text-violet-400' },
  { name: 'Crime', slug: 'crime', icon: Search, color: 'text-cyan-400' },
  { name: 'Drama', slug: 'drama', icon: Star, color: 'text-yellow-400' },
  { name: 'Fantasy', slug: 'fantasy', icon: Gem, color: 'text-purple-400' },
  { name: 'History', slug: 'history', icon: History, color: 'text-zinc-400' },
  { name: 'Kids', slug: 'kids', icon: Smile, color: 'text-amber-400' },
  { name: 'Mystery', slug: 'mystery', icon: Eye, color: 'text-indigo-400' },
  { name: 'Reality', slug: 'reality', icon: Compass, color: 'text-emerald-400' },
  { name: 'Science Fiction', slug: 'science-fiction', icon: Zap, color: 'text-amber-500' },
  { name: 'Sports', slug: 'sports', icon: Trophy, color: 'text-yellow-500' },
  { name: 'Thriller', slug: 'thriller', icon: Activity, color: 'text-rose-500' },
  { name: 'Tv Show', slug: 'tv-show', icon: Tv, color: 'text-sky-400' },
  { name: 'Western', slug: 'western', icon: Sun, color: 'text-yellow-400' }
];

// Mapped genres matching Right column of the screenshot
const rightColumnGenres = [
  { name: 'Adventure', slug: 'adventure', icon: Compass, color: 'text-emerald-500' },
  { name: 'Comedy', slug: 'comedy', icon: Smile, color: 'text-yellow-400' },
  { name: 'Documentary', slug: 'documentary', icon: Film, color: 'text-blue-400' },
  { name: 'Family', slug: 'family', icon: Sparkles, color: 'text-pink-400' },
  { name: 'Game Show', slug: 'game-show', icon: Gamepad2, color: 'text-green-400' },
  { name: 'Horror', slug: 'horror', icon: Skull, color: 'text-red-500' },
  { name: 'Music', slug: 'music', icon: Music, color: 'text-pink-500' },
  { name: 'News', slug: 'news', icon: Newspaper, color: 'text-sky-500' },
  { name: 'Romance', slug: 'romance', icon: Heart, color: 'text-red-400' },
  { name: 'Sports', slug: 'sports', icon: Trophy, color: 'text-yellow-500' },
  { name: 'Talk', slug: 'talk', icon: MessageSquare, color: 'text-teal-400' },
  { name: 'TV Movie', slug: 'tv-movie', icon: MonitorPlay, color: 'text-blue-400' },
  { name: 'War', slug: 'war', icon: Flag, color: 'text-red-400' },
  { name: 'Adult (18+)', slug: 'adult', icon: EyeOff, color: 'text-rose-500' }
];

export function Header() {
  const router = useRouter();
  const pathname = usePathname();
  const [searchQuery, setSearchQuery] = useState('');
  const [isScrolled, setIsScrolled] = useState(false);
  const [isPending, startTransition] = useTransition();
  const { showLoader, hideLoader } = useLoader();
  const [isAuthOpen, setIsAuthOpen] = useState(false);
  const [currentUser, setCurrentUser] = useState<string | null>(null);
  
  const [isLikesOpen, setIsLikesOpen] = useState(false);
  const [isWatchlistOpen, setIsWatchlistOpen] = useState(false);
  const [likesCount, setLikesCount] = useState(0);
  const [watchlistCount, setWatchlistCount] = useState(0);

  // Genre Dropdown Menu States
  const [isGenreOpen, setIsGenreOpen] = useState(false);
  const [mobileGenresOpen, setMobileGenresOpen] = useState(false);

  useEffect(() => {
    // Check current Supabase auth session
    const user = getCurrentUser();
    setCurrentUser(user);
    if (user) {
        setLikesCount(getLikes(user).length);
        setWatchlistCount(getWatchLater(user).length);
        syncUserDataWithSupabase(user);
    }

    // Bind event listeners for real-time updates
    const handleAuthChange = () => {
        const u = getCurrentUser();
        setCurrentUser(u);
        if (u) {
            setLikesCount(getLikes(u).length);
            setWatchlistCount(getWatchLater(u).length);
            syncUserDataWithSupabase(u);
        } else {
            setLikesCount(0);
            setWatchlistCount(0);
        }
    };

    const handleUserDataChange = () => {
        const u = getCurrentUser();
        if (u) {
            setLikesCount(getLikes(u).length);
            setWatchlistCount(getWatchLater(u).length);
        }
    };

    window.addEventListener('movora_auth_change', handleAuthChange);
    window.addEventListener('movora_userdata_change', handleUserDataChange);

    return () => {
      window.removeEventListener('movora_auth_change', handleAuthChange);
      window.removeEventListener('movora_userdata_change', handleUserDataChange);
    };
  }, []);

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 0);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const handleSearch = (e: FormEvent) => {
    e.preventDefault();
    if (!searchQuery.trim()) return;

    showLoader();
    startTransition(() => {
      router.push(`/search?q=${encodeURIComponent(searchQuery.trim())}`);
      hideLoader();
    });
  };

  const handleLogout = () => {
      logoutUser();
  };

  const handleLinkClick = (href: string) => {
    if (pathname === href) return;
    showLoader();
    setIsGenreOpen(false);
    startTransition(() => {
      router.push(href);
      hideLoader();
    });
  };

  return (
    <header
      className={cn(
        'sticky top-0 z-40 w-full border-b border-white/5 bg-zinc-950/80 backdrop-blur-md transition-all duration-300',
        isScrolled ? 'h-16 shadow-lg shadow-black/20' : 'h-20'
      )}
    >
      <div className="container mx-auto flex h-full items-center px-4 md:px-6">
        {/* Mobile Nav Drawer */}
        <Sheet>
          <SheetTrigger asChild>
            <Button
              variant="ghost"
              className="mr-2 px-0 text-base hover:bg-transparent hover:text-white focus-visible:bg-transparent focus-visible:ring-0 focus-visible:ring-offset-0 lg:hidden"
            >
              <Menu className="h-6 w-6" />
              <span className="sr-only">Toggle Menu</span>
            </Button>
          </SheetTrigger>
          
          <SheetContent side="left" className="w-[300px] bg-zinc-950 border-zinc-900 text-white p-6 flex flex-col justify-between">
              <div>
                <div className="flex items-center gap-2 mb-8">
                    <Link href="/home" className="flex items-center" onClick={() => handleLinkClick('/home')}>
                        <span className="font-bold text-xl tracking-tight text-gradient">moovie</span>
                    </Link>
                </div>
                
                <div className="overflow-y-auto max-h-[calc(100vh-120px)] space-y-2 pr-1">
                    <Link href="/discover/tv-show" onClick={() => handleLinkClick('/discover/tv-show')}>
                        <SheetClose className={cn(
                            'flex w-full items-center py-2.5 px-4 rounded-xl text-sm font-semibold transition-all',
                            pathname === '/discover/tv-show' ? 'bg-violet-950/40 text-violet-400 border border-violet-500/20' : 'text-zinc-400 hover:bg-white/5 hover:text-white'
                        )}>
                            TV Shows
                        </SheetClose>
                    </Link>

                    <Link href="/discover/anime" onClick={() => handleLinkClick('/discover/anime')}>
                        <SheetClose className={cn(
                            'flex w-full items-center py-2.5 px-4 rounded-xl text-sm font-semibold transition-all',
                            pathname === '/discover/anime' ? 'bg-violet-950/40 text-violet-400 border border-violet-500/20' : 'text-zinc-400 hover:bg-white/5 hover:text-white'
                        )}>
                            Anime
                        </SheetClose>
                    </Link>

                    {/* Expandable Genres Accordion for Mobile */}
                    <div>
                        <button 
                            onClick={() => setMobileGenresOpen(!mobileGenresOpen)}
                            className="flex w-full items-center justify-between py-2.5 px-4 rounded-xl text-sm font-semibold text-zinc-400 hover:bg-white/5 hover:text-white transition-all"
                        >
                            <span className="flex items-center gap-2">
                                <LayoutGrid className="w-4 h-4 text-violet-400" />
                                Genres
                            </span>
                            {mobileGenresOpen ? <ChevronUp className="w-4 h-4" /> : <ChevronDown className="w-4 h-4" />}
                        </button>
                        
                        {mobileGenresOpen && (
                            <div className="pl-4 pr-2 py-1 mt-1 grid grid-cols-2 gap-1 animate-fade-in">
                                {[...leftColumnGenres, ...rightColumnGenres].map((gen, idx) => {
                                    const Icon = gen.icon;
                                    const path = `/discover/${gen.slug}`;
                                    return (
                                        <Link key={idx} href={path} onClick={() => handleLinkClick(path)}>
                                            <SheetClose className={cn(
                                                'flex w-full items-center gap-2 py-2 px-3 rounded-lg text-xs font-medium transition-all text-left',
                                                pathname === path ? 'bg-violet-950/20 text-violet-400' : 'text-zinc-500 hover:text-zinc-300'
                                            )}>
                                                <Icon className={cn("w-3.5 h-3.5", gen.color)} />
                                                <span className="truncate">{gen.name}</span>
                                            </SheetClose>
                                        </Link>
                                    );
                                })}
                            </div>
                        )}
                    </div>


                    <Link href="/discover/top-weekly" onClick={() => handleLinkClick('/discover/top-weekly')}>
                        <SheetClose className={cn(
                            'flex w-full items-center py-2.5 px-4 rounded-xl text-sm font-semibold transition-all justify-between',
                            pathname === '/discover/top-weekly' ? 'bg-violet-950/40 text-violet-400 border border-violet-500/20' : 'text-zinc-400 hover:bg-white/5 hover:text-white'
                        )}>
                            <span>Trending</span>
                            <span className="bg-red-500/10 text-red-500 border border-red-500/20 rounded-full px-2 py-0.5 text-[9px] uppercase tracking-wide font-extrabold">Hot</span>
                        </SheetClose>
                    </Link>

                    <Link href="/discover/top-rated-hollywood-movies" onClick={() => handleLinkClick('/discover/top-rated-hollywood-movies')}>
                        <SheetClose className={cn(
                            'flex w-full items-center py-2.5 px-4 rounded-xl text-sm font-semibold transition-all',
                            pathname === '/discover/top-rated-hollywood-movies' ? 'bg-violet-950/40 text-violet-400 border border-violet-500/20' : 'text-zinc-400 hover:bg-white/5 hover:text-white'
                        )}>
                            Top IMDb
                        </SheetClose>
                    </Link>
                </div>
              </div>
          </SheetContent>
        </Sheet>
        
        {/* Logo (Desktop & Mobile redirection throwbacks to /home) */}
        <div className="mr-6 flex">
            <Link href="/home" className="flex items-center" onClick={() => handleLinkClick('/home')}>
                <span className="font-bold text-xl tracking-tight text-gradient">moovie</span>
            </Link>
        </div>
<Link href="/party" className="inline-flex items-center gap-2 rounded-full bg-zinc-950 hover:bg-zinc-900 text-zinc-300 hover:text-white font-semibold py-2 px-5 text-xs md:text-sm transition-all border border-zinc-800 hover:border-zinc-700 shadow-md hover:scale-[1.02] active:scale-[0.98] mr-4">
  <Users className="w-4 h-4 text-violet-500" />
  <span>Watch Together</span>
</Link>
        {/* Desktop Nav: Aligned to Screenshot */}
        <nav className="hidden lg:flex items-center gap-6 text-[13px] font-semibold text-zinc-400">
             {/* TV Shows */}
             <Link
                 href="/discover/tv-show"
                 onClick={() => handleLinkClick('/discover/tv-show')}
                 className={cn(
                    'transition-colors hover:text-white py-1 relative after:absolute after:bottom-0 after:left-0 after:h-[2px] after:w-0 after:bg-violet-500 after:transition-all hover:after:w-full',
                    pathname === '/discover/tv-show' ? 'text-white after:w-full' : 'text-zinc-400'
                 )}
             >
                 TV Shows
             </Link>

             <Link
                 href="/discover/anime"
                 onClick={() => handleLinkClick('/discover/anime')}
                 className={cn(
                    'transition-colors hover:text-white py-1 relative after:absolute after:bottom-0 after:left-0 after:h-[2px] after:w-0 after:bg-violet-500 after:transition-all hover:after:w-full',
                    pathname === '/discover/anime' ? 'text-white after:w-full' : 'text-zinc-400'
                 )}
             >
                 Anime
             </Link>

             {/* Dynamic Genre Dropdown Container */}
             <div 
                 className="relative"
                 onMouseEnter={() => setIsGenreOpen(true)}
                 onMouseLeave={() => setIsGenreOpen(false)}
             >
                 <button 
                     onClick={() => setIsGenreOpen(!isGenreOpen)}
                     className={cn(
                         "transition-all flex items-center gap-2 px-3 py-1.5 rounded-xl border font-bold select-none cursor-pointer",
                         isGenreOpen 
                             ? "border-violet-500 bg-violet-600/10 text-violet-400" 
                             : "border-transparent text-zinc-400 hover:text-white hover:bg-white/5"
                     )}
                 >
                     <LayoutGrid className="w-4 h-4" />
                     <span>Genre</span>
                     {isGenreOpen ? <ChevronUp className="w-3.5 h-3.5" /> : <ChevronDown className="w-3.5 h-3.5" />}
                 </button>

                 {/* Dropdown Menu (Premium glassmorphism 2-column layout matching screenshot) */}
                 {isGenreOpen && (
                     <div className="absolute top-full left-1/2 -translate-x-[160px] pt-4 w-[520px] z-50 animate-fade-in">
                         <div className="bg-zinc-950/95 backdrop-blur-xl border border-zinc-800 rounded-2xl shadow-2xl p-4 flex gap-6">
                             {/* Left Column */}
                         <div className="flex-1 flex flex-col gap-0.5">
                             {leftColumnGenres.map((gen, idx) => {
                                 const Icon = gen.icon;
                                 const path = `/discover/${gen.slug}`;
                                 return (
                                     <Link 
                                         key={idx} 
                                         href={path} 
                                         onClick={() => handleLinkClick(path)}
                                         className={cn(
                                             "flex items-center gap-3 px-3 py-2 rounded-xl transition-all cursor-pointer",
                                             pathname === path 
                                                 ? "bg-violet-600/10 text-violet-400 font-bold" 
                                                 : "text-zinc-400 hover:bg-white/5 hover:text-white hover:translate-x-1"
                                         )}
                                     >
                                         <Icon className={cn("w-4 h-4", gen.color)} />
                                         <span className="text-[13px]">{gen.name}</span>
                                     </Link>
                                 );
                             })}
                         </div>

                         {/* Divider line */}
                         <div className="w-[1px] bg-zinc-800/60 self-stretch"></div>

                         {/* Right Column */}
                         <div className="flex-1 flex flex-col gap-0.5">
                             {rightColumnGenres.map((gen, idx) => {
                                 const Icon = gen.icon;
                                 const path = `/discover/${gen.slug}`;
                                 return (
                                     <Link 
                                         key={idx} 
                                         href={path} 
                                         onClick={() => handleLinkClick(path)}
                                         className={cn(
                                             "flex items-center gap-3 px-3 py-2 rounded-xl transition-all cursor-pointer",
                                             pathname === path 
                                                 ? "bg-violet-600/10 text-violet-400 font-bold" 
                                                 : "text-zinc-400 hover:bg-white/5 hover:text-white hover:translate-x-1"
                                         )}
                                     >
                                         <Icon className={cn("w-4 h-4", gen.color)} />
                                         <span className="text-[13px]">{gen.name}</span>
                                     </Link>
                                 );
                             })}
                         </div>
                         </div>
                     </div>
                 )}
             </div>


             {/* Trending (with Hot Badge) */}
             <Link
                 href="/discover/top-weekly"
                 onClick={() => handleLinkClick('/discover/top-weekly')}
                 className={cn(
                    'transition-colors hover:text-white py-1 relative after:absolute after:bottom-0 after:left-0 after:h-[2px] after:w-0 after:bg-violet-500 after:transition-all hover:after:w-full flex items-center gap-1.5',
                    pathname === '/discover/top-weekly' ? 'text-white after:w-full' : 'text-zinc-400'
                 )}
             >
                 <Activity className="w-3.5 h-3.5 text-orange-400" />
                 <span>Trending</span>
                 <span className="bg-red-500/10 text-red-500 border border-red-500/20 rounded-full px-1.5 py-0.5 text-[8px] uppercase tracking-wider font-extrabold scale-90 select-none">Hot</span>
             </Link>

             {/* Top IMDb */}
             <Link
                 href="/discover/top-rated-hollywood-movies"
                 onClick={() => handleLinkClick('/discover/top-rated-hollywood-movies')}
                 className={cn(
                    'transition-colors hover:text-white py-1 relative after:absolute after:bottom-0 after:left-0 after:h-[2px] after:w-0 after:bg-violet-500 after:transition-all hover:after:w-full',
                    pathname === '/discover/top-rated-hollywood-movies' ? 'text-white after:w-full' : 'text-zinc-400'
                 )}
             >
                 Top IMDb
             </Link>
        </nav>

        {/* Search & Actions */}
        <div className="flex flex-1 items-center justify-end gap-4">
            <form onSubmit={handleSearch} className="relative w-full max-w-[140px] md:max-w-[220px] transition-all focus-within:max-w-[280px]">
                <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <Input
                    key={pathname}
                    type="search"
                    placeholder="Search movies..."
                    className="pl-9 h-10 bg-white/5 border-white/10 focus:bg-black focus:border-primary/50 rounded-full transition-all text-xs"
                    defaultValue={pathname === '/search' ? searchQuery : ''}
                    onChange={e => setSearchQuery(e.target.value)}
                />
                 {isPending && <div className="absolute right-3 top-1/2 -translate-y-1/2"><Loader2 className="h-4 w-4 animate-spin text-primary" /></div>}
            </form>
            
            {/* Liked List Shortcut */}
            <Button 
                onClick={() => currentUser ? setIsLikesOpen(true) : setIsAuthOpen(true)}
                variant="ghost"
                size="icon"
                className="relative rounded-full bg-white/5 border border-white/5 hover:bg-white/10 hover:border-white/10 text-zinc-300 hover:text-rose-400 transition-all w-10 h-10 flex items-center justify-center"
                title="My Liked List"
            >
                <Heart className={cn("w-4 h-4", likesCount > 0 && "fill-rose-500 text-rose-500")} />
                {likesCount > 0 && (
                    <span className="absolute -top-1 -right-1 bg-rose-500 text-white font-bold rounded-full w-4 h-4 flex items-center justify-center text-[8px] border border-zinc-950 font-sans">
                        {likesCount}
                    </span>
                )}
            </Button>

            {/* Watchlist Shortcut */}
            <Button 
                onClick={() => currentUser ? setIsWatchlistOpen(true) : setIsAuthOpen(true)}
                variant="ghost"
                size="icon"
                className="relative rounded-full bg-white/5 border border-white/5 hover:bg-white/10 hover:border-white/10 text-zinc-300 hover:text-indigo-400 transition-all w-10 h-10 flex items-center justify-center mr-1"
                title="My Watchlist"
            >
                <Bookmark className={cn("w-4 h-4", watchlistCount > 0 && "fill-indigo-500 text-indigo-500")} />
                {watchlistCount > 0 && (
                    <span className="absolute -top-1 -right-1 bg-indigo-500 text-white font-bold rounded-full w-4 h-4 flex items-center justify-center text-[8px] border border-zinc-950 font-sans">
                        {watchlistCount}
                    </span>
                )}
            </Button>

            {/* Auth Session Area */}
            {currentUser ? (
                <div className="flex items-center gap-2 rounded-full bg-zinc-900 border border-zinc-800 px-3 h-10 backdrop-blur-sm text-xs font-semibold text-zinc-300 animate-fade-in">
                    <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span>
                    <span className="capitalize">{currentUser}</span>
                    <button 
                        onClick={handleLogout} 
                        className="text-zinc-500 hover:text-rose-400 font-bold ml-2 transition-colors text-[9px] uppercase tracking-wider"
                        title="Logout"
                    >
                        Sign Out
                    </button>
                </div>
            ) : (
                <Button 
                    onClick={() => setIsAuthOpen(true)}
                    className="rounded-full bg-violet-600 hover:bg-violet-700 text-white font-semibold text-xs px-4 h-10 shadow-lg shadow-violet-600/10 border border-violet-500/20"
                >
                    Sign In
                </Button>
            )}

             <AuthModal isOpen={isAuthOpen} onClose={() => setIsAuthOpen(false)} />
             <PersonalizedListDrawer type="likes" isOpen={isLikesOpen} onClose={() => setIsLikesOpen(false)} />
             <PersonalizedListDrawer type="watchlater" isOpen={isWatchlistOpen} onClose={() => setIsWatchlistOpen(false)} />
        </div>
      </div>
    </header>
  );
}
