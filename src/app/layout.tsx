import type { Metadata } from 'next';
import './globals.css';
import { Space_Grotesk } from 'next/font/google';
import { Toaster } from '@/components/ui/toaster';
import { MainLayout } from '@/components/common/MainLayout';
import { cn } from '@/lib/utils';
import { Analytics } from '@vercel/analytics/react';
import ProgressBarProvider from '@/components/common/ProgressBarProvider';
import { LoaderProvider } from '@/components/common/LoaderProvider';

const spaceGrotesk = Space_Grotesk({ subsets: ['latin'], variable: '--font-space-grotesk' });

export const metadata: Metadata = {
  title: 'Movora',
  description: 'Your ultimate destination for movies and TV shows.',
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="dark">
      <body className={cn('min-h-screen bg-background font-body antialiased', spaceGrotesk.variable)}>
        <ProgressBarProvider>
          <LoaderProvider>
            <MainLayout>
              {children}
            </MainLayout>
            <Toaster />
            <Analytics />
          </LoaderProvider>
        </ProgressBarProvider>
      </body>
    </html>
  );
}