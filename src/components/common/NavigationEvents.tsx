'use client';

import { useEffect, useState } from 'react';
import { usePathname, useSearchParams } from 'next/navigation';
import { PageLoader } from './PageLoader';

export function NavigationEvents() {
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    setLoading(false);
  }, [pathname, searchParams]);
  
  // This is a bit of a hack to show the loader on navigation.
  // We're adding a global click listener to set loading to true.
  // The effect above will then set it to false when the new page loads.
  useEffect(() => {
    const handleLinkClick = (e: MouseEvent) => {
        // Check if the click is on a link or a child of a link
        const target = e.target as HTMLElement;
        const anchor = target.closest('a');
        
        if (anchor && anchor.href && anchor.target !== '_blank') {
            const currentUrl = new URL(window.location.href);
            const nextUrl = new URL(anchor.href);
            
            // Only show loader for internal navigation
            if (currentUrl.origin === nextUrl.origin) {
                // If the path and search are the same, don't show the loader
                if (currentUrl.pathname !== nextUrl.pathname || currentUrl.search !== nextUrl.search) {
                    setLoading(true);
                }
            }
        }
    };
    
    document.addEventListener('click', handleLinkClick);

    return () => {
        document.removeEventListener('click', handleLinkClick);
    }
  }, []);

  return loading ? <PageLoader /> : null;
}
