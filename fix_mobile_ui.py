import os

files = {
    # 1. HEADER FIX: Removed "M" Icon, Removed extra "Close" button
    "src/components/common/Header.tsx": """
'use client';

import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { useState, useEffect, FormEvent, useTransition } from 'react';
import { Input } from '@/components/ui/input';
import { Search, Menu, Download, Loader2 } from 'lucide-react';
import { cn } from '@/lib/utils';
import { Button } from '@/components/ui/button';
import { Sheet, SheetContent, SheetTrigger, SheetClose } from '@/components/ui/sheet';
import { useLoader } from './LoaderProvider';

const navItems = [
  { name: 'Hollywood', href: '/home' },
  { name: 'Bollywood', href: '/bollywood' },
  { name: 'Korean', href: '/korean' },
  { name: 'Netflix', href: '/netflix' },
  { name: 'Prime', href: '/prime' },
  { name: 'Cartoons', href: '/cartoons' },
  { name: 'Animated', href: '/animated' },
  { name: 'Mindfucks', href: '/mindfucks' },
  { name: 'Docs', href: '/documentaries' },
  { name: 'Adventure', href: '/adventure' },
];

const androidAppLink = "https://github.com/iMayhem/Movora/releases/latest/download/app-release.apk";

export function Header() {
  const router = useRouter();
  const pathname = usePathname();
  const [searchQuery, setSearchQuery] = useState('');
  const [isScrolled, setIsScrolled] = useState(false);
  const [isPending, startTransition] = useTransition();
  const { showLoader } = useLoader();

  useEffect(() => {
    const handleScroll = () => {
        setIsScrolled(window.scrollY > 10);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const handleSearch = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (searchQuery.trim()) {
        showLoader();
        startTransition(() => {
            router.push(`/search?query=${encodeURIComponent(searchQuery)}`);
        });
    }
  };
  
  const handleLinkClick = (href: string) => {
    if (pathname !== href) showLoader();
  }

  return (
    <header 
        className={cn(
            "sticky top-0 z-50 w-full transition-all duration-300 border-b border-transparent",
            isScrolled ? "bg-black/80 backdrop-blur-md border-white/10 shadow-lg" : "bg-transparent"
        )}
    >
      <div className="container flex h-16 max-w-screen-2xl items-center px-4 gap-4">
        
        {/* Mobile Menu */}
        <Sheet>
          <SheetTrigger asChild>
            <Button variant="ghost" size="icon" className="md:hidden hover:bg-white/10">
              <Menu className="h-6 w-6" />
              <span className="sr-only">Toggle Menu</span>
            </Button>
          </SheetTrigger>
          <SheetContent side="left" className="w-[300px] bg-black/95 backdrop-blur-xl border-r border-white/10 p-0">
             {/* Header of Sidebar: No Icon, No Extra Close Button (Default one is absolute) */}
             <div className="p-6 border-b border-white/10 flex items-center">
                <Link href="/" className="flex items-center gap-2" onClick={() => handleLinkClick('/')}>
                    <span className="font-bold text-xl tracking-tight">Movora</span>
                </Link>
             </div>
            
            <div className="py-4 overflow-y-auto h-[calc(100vh-80px)]">
                <div className="flex flex-col px-4 space-y-1">
                    {navItems.map(item => (
                        <Link
                            key={item.name}
                            href={item.href}
                            onClick={() => handleLinkClick(item.href)}
                        >
                             <SheetClose className={cn(
                                'flex w-full items-center py-3 px-4 rounded-lg text-sm font-medium transition-all',
                                pathname === item.href ? 'bg-primary/20 text-primary' : 'text-muted-foreground hover:bg-white/5 hover:text-white'
                            )}>
                                {item.name}
                            </SheetClose>
                        </Link>
                    ))}
                    <div className="pt-4 mt-4 border-t border-white/10">
                         <a
                            href={androidAppLink}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="flex w-full items-center justify-center gap-2 py-3 px-4 rounded-lg bg-white/10 text-white font-medium hover:bg-white/20 transition-colors"
                        >
                            <Download className="h-4 w-4" />
                            Download App
                        </a>
                    </div>
                </div>
            </div>
          </SheetContent>
        </Sheet>
        
        {/* Logo (Desktop) */}
        <div className="hidden md:flex mr-4">
            <Link href="/" className="flex items-center gap-2" onClick={() => handleLinkClick('/')}>
                <div className="h-8 w-8 bg-primary rounded-lg flex items-center justify-center font-bold text-white shadow-glow">M</div>
                <span className="font-bold text-xl tracking-tight hidden lg:block">Movora</span>
            </Link>
        </div>

        {/* Desktop Nav */}
        <nav className="hidden lg:flex items-center gap-6 text-sm font-medium">
             {navItems.slice(0, 5).map(item => (
                <Link
                    key={item.name}
                    href={item.href}
                    onClick={() => handleLinkClick(item.href)}
                    className={cn(
                    'transition-colors hover:text-primary relative py-1 after:absolute after:bottom-0 after:left-0 after:h-[2px] after:w-0 after:bg-primary after:transition-all hover:after:w-full',
                    pathname === item.href ? 'text-primary after:w-full' : 'text-muted-foreground'
                    )}
                >
                    {item.name}
                </Link>
            ))}
             <div className="relative group">
                <button className="text-muted-foreground hover:text-primary transition-colors flex items-center gap-1">More</button>
                <div className="absolute top-full left-0 w-48 bg-black/90 border border-white/10 rounded-lg shadow-xl p-2 opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-200 translate-y-2 group-hover:translate-y-0 backdrop-blur-md">
                    {navItems.slice(5).map(item => (
                         <Link
                            key={item.name}
                            href={item.href}
                            onClick={() => handleLinkClick(item.href)}
                            className="block px-4 py-2 text-sm text-muted-foreground hover:text-white hover:bg-white/10 rounded-md transition-colors"
                        >
                            {item.name}
                        </Link>
                    ))}
                </div>
             </div>
        </nav>

        {/* Search & Actions */}
        <div className="flex flex-1 items-center justify-end gap-4">
            <form onSubmit={handleSearch} className="relative w-full max-w-[200px] md:max-w-[300px] transition-all focus-within:max-w-[350px]">
                <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <Input
                    key={pathname}
                    type="search"
                    placeholder="Search movies..."
                    className="pl-9 h-10 bg-white/5 border-white/10 focus:bg-black focus:border-primary/50 rounded-full transition-all text-sm"
                    defaultValue={pathname === '/search' ? searchQuery : ''}
                    onChange={e => setSearchQuery(e.target.value)}
                />
                 {isPending && <div className="absolute right-3 top-1/2 -translate-y-1/2"><Loader2 className="h-4 w-4 animate-spin text-primary" /></div>}
            </form>
            
            <Button asChild className="hidden sm:inline-flex rounded-full bg-white/10 text-white hover:bg-white/20 border border-white/5 backdrop-blur-sm" variant="ghost">
            <a href={androidAppLink} target="_blank" rel="noopener noreferrer">
                <Download className="mr-2 h-4 w-4" />
                App
            </a>
            </Button>
        </div>
      </div>
    </header>
  );
}
""",

    # 2. LAYOUT CLEANUP: Ensures Debugger is gone
    "src/components/common/MainLayout.tsx": """
'use client';

import { Header } from '@/components/common/Header';
import { Footer } from '@/components/common/Footer';
import { usePathname } from 'next/navigation';

export function MainLayout({ children }: { children: React.ReactNode }) {
    const pathname = usePathname();
    const isLandingPage = pathname === '/';
    const isWatchPage = pathname?.startsWith('/watch');

    return (
        <div className="relative flex min-h-screen flex-col bg-background text-foreground">
            {!isLandingPage && !isWatchPage && <Header />}
            <main className="flex-1 w-full">{children}</main>
            {!isLandingPage && !isWatchPage && <Footer />}
        </div>
    );
}
""",

    # 3. COMPACT GRID (Re-applying to ensure you have the 3-column layout)
    "src/components/movies/MovieList.tsx": """
'use client';

import type { Media } from '@/types/tmdb';
import { MovieCard } from './MovieCard';
import {
  Carousel,
  CarouselContent,
  CarouselItem,
  CarouselNext,
  CarouselPrevious,
} from '@/components/ui/carousel';
import { useState, useEffect, useRef, useCallback } from 'react';
import { fetchPage } from '@/lib/tmdb';
import { Skeleton } from '../ui/skeleton';

type MovieListProps = {
  initialMedia?: Media[];
  carousel?: boolean;
  slug?: string;
};

export function MovieList({ initialMedia = [], carousel = false, slug }: MovieListProps) {
  const [media, setMedia] = useState<Media[]>(initialMedia);
  const [page, setPage] = useState(2);
  const [loading, setLoading] = useState(false);
  const [hasMore, setHasMore] = useState(true);
  const loader = useRef(null);

  useEffect(() => {
    setMedia(initialMedia);
    setPage(2);
    setHasMore(initialMedia.length > 0);
    setLoading(false);
  }, [initialMedia, slug]);

  const loadMore = useCallback(async () => {
    if (loading || !hasMore || !slug) return;
    
    setLoading(true);
    try {
        const newMedia = await fetchPage(page, slug);
        
        if (newMedia && newMedia.length > 0) {
            setMedia((prev) => {
                const existingIds = new Set(prev.map(p => p.id));
                const uniqueNewMedia = newMedia.filter(m => !existingIds.has(m.id));
                
                if (uniqueNewMedia.length === 0) {
                    setHasMore(false);
                    return prev;
                }
                return [...prev, ...uniqueNewMedia];
            });
            setPage((prev) => prev + 1);
        } else {
            setHasMore(false);
        }
    } catch (error) {
        setHasMore(false); 
    } finally {
        setLoading(false);
    }
  }, [page, loading, hasMore, slug]);

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        if (entries[0].isIntersecting && hasMore && !loading) {
          loadMore();
        }
      },
      { rootMargin: '400px' }
    );

    if (loader.current && !carousel) {
      observer.observe(loader.current);
    }

    return () => {
      if (loader.current && !carousel) {
        observer.unobserve(loader.current);
      }
    };
  }, [loadMore, carousel, hasMore, loading]);

  if (carousel) {
    return (
      <Carousel
        opts={{ align: 'start', dragFree: true, loop: false, containScroll: 'trimSnaps' }}
        className="w-full"
      >
        <CarouselContent className="-ml-2 pb-2">
          {media.length > 0 ? media.map((item, index) => (
            <CarouselItem key={`${item.media_type}-${item.id}-${index}`} className="pl-2 basis-[30%] sm:basis-[22%] md:basis-[18%] lg:basis-[14%] xl:basis-[12%]">
              <MovieCard item={item} compact />
            </CarouselItem>
          )) : (
             <div className="pl-4 text-muted-foreground text-xs p-4">No content found.</div>
          )}
        </CarouselContent>
      </Carousel>
    );
  }

  return (
    <>
      {media.length > 0 ? (
        <div className="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-5 lg:grid-cols-6 xl:grid-cols-7 gap-2 gap-y-4 animate-fade-in">
            {media.map((item, index) => (
            <MovieCard key={`${item.media_type}-${item.id}-${index}`} item={item} />
            ))}
        </div>
      ) : (
        <div className="text-center py-10">
            <h3 className="text-sm font-medium text-muted-foreground">No content found.</h3>
        </div>
      )}
      
      <div ref={loader} className="col-span-full py-8 w-full flex justify-center">
        {loading && (
          <div className="grid grid-cols-3 sm:grid-cols-4 md:grid-cols-5 lg:grid-cols-6 gap-2 w-full">
            {Array.from({ length: 6 }).map((_, i) => (
              <div key={i} className="space-y-1">
                <Skeleton className="aspect-[2/3] w-full rounded-lg bg-white/5" />
                <Skeleton className="h-3 w-3/4 bg-white/5" />
              </div>
            ))}
          </div>
        )}
      </div>
    </>
  );
}
"""
}

for path, content in files.items():
    dir_name = os.path.dirname(path)
    if dir_name:
        os.makedirs(dir_name, exist_ok=True)
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content.strip())
    print(f"Fixed {path}")

print("\nUI polished! Push to GitHub to see changes.")