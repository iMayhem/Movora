
'use client';

import Link from 'next/link';
import { usePathname, useRouter, useSearchParams } from 'next/navigation';
import { useState, useEffect, FormEvent } from 'react';
import { Input } from '@/components/ui/input';
import { Search, PanelLeft } from 'lucide-react';
import { cn } from '@/lib/utils';
import { Button } from '@/components/ui/button';
import { Sheet, SheetContent, SheetTrigger } from '@/components/ui/sheet';

const navItems = [
  { name: 'Hollywood', href: '/' },
  { name: 'Bollywood', href: '/bollywood' },
  { name: 'Korean', href: '/korean' },
  { name: 'Netflix', href: '/netflix' },
  { name: 'Prime', href: '/prime' },
  { name: 'Top 250', href: '/letterboxd' },
  { name: 'Animated', href: '/animated' },
  { name: 'Mindfucks', href: '/mindfucks' },
  { name: 'Indian Cartoons', href: '/indian-cartoons' },
  { name: 'Documentaries', href: '/documentaries' },
  { name: 'Adventure', href: '/adventure' },
];

export function Header() {
  const router = useRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const [searchQuery, setSearchQuery] = useState(searchParams.get('query') || '');
  const [isSheetOpen, setIsSheetOpen] = useState(false);

  useEffect(() => {
    // If we navigate away from search, clear the input
    if (pathname !== '/search') {
      setSearchQuery('');
    }
    // Close sheet on navigation
    setIsSheetOpen(false);
  }, [pathname, searchParams]);

  const handleSearch = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (searchQuery.trim()) {
      router.push(`/search?query=${encodeURIComponent(searchQuery)}`);
    }
  };

  return (
    <header className="sticky top-0 z-50 w-full border-b border-border/40 bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="container flex h-14 max-w-screen-2xl items-center px-4">
        <Sheet open={isSheetOpen} onOpenChange={setIsSheetOpen}>
          <SheetTrigger asChild>
            <Button variant="ghost" size="icon" className="md:hidden">
              <PanelLeft />
              <span className="sr-only">Toggle Menu</span>
            </Button>
          </SheetTrigger>
          <SheetContent side="left" className="pr-0">
            <Link href="/" className="mr-6 flex items-center space-x-2">
                <span className="font-bold text-lg">Movora</span>
            </Link>
            <div className="my-4 h-[calc(100vh-8rem)] overflow-y-auto pb-10 pl-6">
                <div className="flex flex-col gap-4">
                    {navItems.map(item => (
                        <Link
                            key={item.name}
                            href={item.href}
                            className={cn(
                                'text-lg font-medium transition-colors hover:text-primary',
                                pathname === item.href ? 'text-primary' : 'text-muted-foreground'
                            )}
                        >
                            {item.name}
                        </Link>
                    ))}
                </div>
            </div>
          </SheetContent>
        </Sheet>
        
        <div className="mr-4 hidden md:flex">
            <Link href="/" className="mr-6 flex items-center space-x-2">
                <span className="font-bold">Movora</span>
            </Link>
        </div>
        <div className="flex flex-1 items-center justify-end space-x-2">
            <nav className="hidden gap-4 md:flex">
                {navItems.map(item => (
                <Link
                    key={item.name}
                    href={item.href}
                    className={cn(
                    'flex items-center text-sm font-medium transition-colors hover:text-foreground/80',
                    pathname === item.href ? 'text-foreground' : 'text-foreground/60'
                    )}
                >
                    {item.name}
                </Link>
                ))}
            </nav>
            <form onSubmit={handleSearch} className="relative ml-auto w-full max-w-xs sm:max-w-sm md:max-w-md lg:max-w-lg">
                <Input
                type="search"
                placeholder="Search..."
                className="pl-10 h-9"
                value={searchQuery}
                onChange={e => setSearchQuery(e.target.value)}
                />
                <Search className="absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2 text-muted-foreground" />
            </form>
        </div>
      </div>
    </header>
  );
}
