'use client';

import { Smartphone, Monitor } from 'lucide-react';
import { Button } from '@/components/ui/button';

type MobileDebuggerProps = {
    isMobileMode: boolean;
    toggleMobileMode: () => void;
};

export function MobileDebugger({ isMobileMode, toggleMobileMode }: MobileDebuggerProps) {
    return (
        <Button 
            onClick={toggleMobileMode}
            className="fixed bottom-4 right-4 z-[9999] rounded-full w-12 h-12 shadow-2xl border border-white/20 bg-primary text-white hover:bg-primary/90 hover:scale-110 transition-all"
            title={isMobileMode ? "Switch to Desktop View" : "Switch to Mobile View"}
        >
            {isMobileMode ? <Monitor className="w-5 h-5" /> : <Smartphone className="w-5 h-5" />}
        </Button>
    );
}