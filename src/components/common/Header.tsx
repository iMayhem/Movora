'use client';

import Link from 'next/link';
import { usePathname, useRouter, useSearchParams } from 'next/navigation';
import { useState, useEffect, FormEvent } from 'react';
import { Logo } from '@/components/icons/Logo';
import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Search } from 'lucide-react';
import { cn } from '@/lib/utils';

const navItems = [
  { name: 'Home', href: '/' },
  { name: 'Watch Later', href: '/watch-later' },
  { name: 'AI Recommendations', href: '/recommendations' },
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
      <div className="container flex h-16 items-center space-x-4 sm:justify-between sm:space-x-0">
        <div className="flex gap-6 md:gap-10">
          <Link href="/" className="flex items-center space-x-2">
            <Logo />
            <span className="hidden font-bold sm:inline-block font-headline">CineStream</span>
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
          <form onSubmit={handleSearch} className="relative w-full max-w-sm">
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
