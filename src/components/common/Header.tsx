'use client';

import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { useState, useEffect, FormEvent, useTransition } from 'react';
import { Input } from '@/components/ui/input';
import { Search, Menu, Download, Loader2, X } from 'lucide-react';
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
             <div className="p-6 border-b border-white/10 flex items-center justify-between">
                <Link href="/" className="flex items-center gap-2" onClick={() => handleLinkClick('/')}>
                    <div className="h-8 w-8 bg-primary rounded-lg flex items-center justify-center font-bold text-white">M</div>
                    <span className="font-bold text-xl tracking-tight">Movora</span>
                </Link>
                <SheetClose className="rounded-sm opacity-70 ring-offset-background transition-opacity hover:opacity-100 focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2">
                    <X className="h-4 w-4" />
                    <span className="sr-only">Close</span>
                </SheetClose>
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
        
        {/* Logo */}
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