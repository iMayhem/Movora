'use client';

import { Header } from '@/components/common/Header';
import { Footer } from '@/components/common/Footer';
import { usePathname } from 'next/navigation';
import { useState } from 'react';
import { MobileDebugger } from '@/components/debug/MobileDebugger';
import { cn } from '@/lib/utils';

export function MainLayout({ children }: { children: React.ReactNode }) {
    const pathname = usePathname();
    const isLandingPage = pathname === '/';
    const isWatchPage = pathname?.startsWith('/watch');
    const [isMobileMode, setIsMobileMode] = useState(false);

    return (
        <div className="relative min-h-screen flex flex-col bg-background text-foreground">
            <div 
                className={cn(
                    "flex-1 flex flex-col transition-all duration-300 ease-in-out mx-auto w-full",
                    isMobileMode ? "max-w-[375px] border-x border-white/10 shadow-2xl bg-black" : "max-w-full"
                )}
            >
                {!isLandingPage && !isWatchPage && <Header />}
                <main className="flex-1">{children}</main>
                {!isLandingPage && !isWatchPage && <Footer />}
            </div>
            
            {/* Temporary Debug Button */}
            <MobileDebugger isMobileMode={isMobileMode} toggleMobileMode={() => setIsMobileMode(!isMobileMode)} />
        </div>
    );
}