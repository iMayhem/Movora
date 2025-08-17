'use client';

import Link from 'next/link';
import { usePathname, useRouter, useSearchParams } from 'next/navigation';
import { useState, useEffect, FormEvent } from 'react';
import { Input } from '@/components/ui/input';
import { Search } from 'lucide-react';
import { cn } from '@/lib/utils';

const navItems = [
  { name: 'Home', href: '/' },
  { name: 'Bollywood', href: '/bollywood' },
  { name: 'Korean', href: '/korean' },
  { name: 'Netflix', href: '/netflix' },
  { name: 'Prime', href: '/prime' },
  { name: 'Top 250', href: '/letterboxd' },
  { name: 'Animated', href: '/animated' },
  { name: 'Mindfucks', href: '/mindfucks' },
  { name: 'Indian Cartoons', href: '/indian-cartoons' },
];

export function Header() {
  const router = useRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const [searchQuery, setSearchQuery] = useState(searchParams.get('query') || '');

  useEffect(() => {
    // If we navigate away from search, clear the input
    if (pathname !== '/search') {
      setSearchQuery('');
    }
  }, [pathname]);

  const handleSearch = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    if (searchQuery.trim()) {
      router.push(`/search?query=${encodeURIComponent(searchQuery)}`);
    }
  };

  return (
    <header className="sticky top-0 z-50 w-full border-b border-border/40 bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="container flex h-16 max-w-screen-2xl items-center">
        <div className="mr-4 flex">
            <Link href="/" className="mr-6 flex items-center space-x-2">
                <span className="font-bold">Movora</span>
            </Link>
            <nav className="hidden gap-6 md:flex">
                {navItems.map(item => (
                <Link
                    key={item.name}
                    href={item.href}
                    className={cn(
                    'flex items-center text-lg font-medium transition-colors hover:text-foreground/80 sm:text-sm',
                    pathname === item.href ? 'text-foreground' : 'text-foreground/60'
                    )}
                >
                    {item.name}
                </Link>
                ))}
            </nav>
        </div>
        <div className="flex flex-1 items-center justify-end space-x-4">
          <form onSubmit={handleSearch} className="relative w-full max-w-[200px]">
              <Input
              type="search"
              placeholder="Search movies & shows..."
              className="pl-10"
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
