'use client';

import { Suspense } from 'react';
import { Header } from '@/components/common/Header';
import { Footer } from '@/components/common/Footer';

function HeaderFallback() {
    return <header className="sticky top-0 z-50 w-full border-b border-border/40 bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60 h-16"></header>
}

export function MainLayout({ children }: { children: React.ReactNode }) {
    return (
        <div className="relative flex min-h-screen flex-col">
            <Suspense fallback={<HeaderFallback />}>
              <Header />
            </Suspense>
            <main className="flex-1">{children}</main>
            <Footer />
        </div>
    );
}
