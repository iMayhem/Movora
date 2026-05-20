'use client';

import { SimklWatchlistSection } from '@/components/common/SimklWatchlistSection';
import { PersonalizedDashboard } from '@/components/common/PersonalizedDashboard';

export default function HomePage() {
  return (
    <div className="bg-background text-foreground min-h-screen">
      <main className="container mx-auto py-10 px-4 space-y-16">
            <SimklWatchlistSection />
            <PersonalizedDashboard />
      </main>
    </div>
  );
}