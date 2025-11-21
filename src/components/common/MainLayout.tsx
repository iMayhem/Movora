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