
'use client';

import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { Home } from 'lucide-react';

export default function NotFound() {
  return (
    <div className="flex flex-col items-center justify-center min-h-[calc(100vh-200px)] text-center px-4">
        <h1 className="text-8xl font-bold font-headline text-primary">404</h1>
        <h2 className="text-3xl font-semibold mt-4">Page Not Found</h2>
        <p className="text-muted-foreground mt-2 max-w-md">
            Oops! The page you are looking for does not exist. It might have been moved or deleted.
        </p>
        <Button asChild className="mt-8">
            <Link href="/">
                <Home className="mr-2" />
                Go Back Home
            </Link>
        </Button>
    </div>
  )
}
