'use client';

import { Button } from '@/components/ui/button';
import { ArrowDown, Clapperboard, Download, Layers, Tv, WifiOff, Play } from 'lucide-react';
import Link from 'next/link';
import { Footer } from '@/components/common/Footer';

const features = [
  {
    icon: <Clapperboard className="h-8 w-8 text-primary" />,
    title: 'Vast Library',
    description: 'Thousands of movies and TV shows. From Hollywood blockbusters to indie gems.',
  },
  {
    icon: <Layers className="h-8 w-8 text-primary" />,
    title: 'Curated Collections',
    description: 'Hand-picked lists for every mood. Spend less time searching, more time watching.',
  },
  {
    icon: <WifiOff className="h-8 w-8 text-primary" />,
    title: 'Offline Ready',
    description: 'Download content to your device and watch anywhere, anytime, without data.',
  },
  {
    icon: <Tv className="h-8 w-8 text-primary" />,
    title: 'Cross-Platform',
    description: 'Seamlessly sync your progress between your phone, tablet, and desktop.',
  },
];

export default function LandingPage() {
  const androidAppLink = "https://github.com/iMayhem/Movora/releases/latest/download/app-release.apk";

  return (
    <div className="bg-background text-foreground min-h-screen flex flex-col">
      <main className="flex-1">
        {/* Hero Section */}
        <section className="relative h-screen flex items-center justify-center text-center overflow-hidden">
            {/* Background Video / Image with stronger overlay */}
            <div className="absolute inset-0 z-0">
                 <div className="absolute inset-0 bg-gradient-to-b from-background/30 via-background/80 to-background z-10"></div>
                 <div className="absolute inset-0 bg-black/40 z-0"></div>
                <video
                    autoPlay
                    loop
                    muted
                    playsInline
                    className="w-full h-full object-cover opacity-40 scale-105"
                    poster="https://image.tmdb.org/t/p/original/h3V5w85cw9Fud3hT2Av23h3y3D.jpg"
                >
                    <source src="https://firebasestorage.googleapis.com/v0/b/cinestream-gr4ey.appspot.com/o/marvel.mp4?alt=media&token=8fa9280b-9366-4d92-a721-a5b67e0766a2" type="video/mp4" />
                </video>
            </div>

          <div className="relative z-20 container mx-auto px-4 max-w-4xl">
            <div className="mb-6 inline-flex items-center gap-2 px-3 py-1 rounded-full border border-white/10 bg-white/5 backdrop-blur-sm text-sm font-medium text-primary-foreground animate-fade-in">
                <span className="relative flex h-2 w-2">
                  <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-primary opacity-75"></span>
                  <span className="relative inline-flex rounded-full h-2 w-2 bg-primary"></span>
                </span>
                Streaming Now
            </div>
            <h1 className="text-5xl md:text-7xl font-extrabold tracking-tight mb-6 text-gradient leading-tight animate-fade-in" style={{animationDelay: '100ms'}}>
              Your Ultimate <br className="hidden md:block" /> Movie Universe
            </h1>
            <p className="text-lg md:text-xl text-muted-foreground mb-10 max-w-2xl mx-auto leading-relaxed animate-fade-in" style={{animationDelay: '200ms'}}>
              Discover limitless entertainment. No subscriptions, no barriers. Just pure cinema at your fingertips.
            </p>
            
            <div className="flex flex-col sm:flex-row gap-4 justify-center animate-fade-in" style={{animationDelay: '300ms'}}>
              <Button asChild size="lg" className="h-12 px-8 text-base shadow-lg shadow-primary/20 hover:shadow-primary/40 transition-all duration-300 rounded-full">
                <a href={androidAppLink}>
                  <Download className="mr-2 h-5 w-5" />
                  Get for Android
                </a>
              </Button>
              <Button asChild size="lg" variant="outline" className="h-12 px-8 text-base bg-white/5 border-white/10 hover:bg-white/10 backdrop-blur-sm rounded-full">
                <Link href="/home">
                  <Play className="mr-2 h-5 w-5 fill-current" />
                  Start Watching
                </Link>
              </Button>
            </div>
          </div>
          
          <div className="absolute bottom-10 left-1/2 -translate-x-1/2 z-20 animate-bounce opacity-50">
            <ArrowDown className="h-6 w-6 text-white" />
          </div>
        </section>

        {/* Features Section */}
        <section id="features" className="py-24 bg-background relative">
          <div className="container mx-auto px-4">
            <div className="text-center mb-16">
              <h2 className="text-3xl md:text-4xl font-bold mb-4">Designed for Movie Lovers</h2>
              <p className="text-muted-foreground max-w-2xl mx-auto">
                Experience a platform built for speed, quality, and ease of use.
              </p>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
              {features.map((feature, index) => (
                <div 
                    key={index} 
                    className="glass-card p-8 rounded-2xl hover:bg-white/10 transition-colors duration-300 text-center group"
                >
                  <div className="flex justify-center items-center h-16 w-16 mx-auto mb-6 bg-primary/10 rounded-2xl group-hover:scale-110 transition-transform duration-300">
                    {feature.icon}
                  </div>
                  <h3 className="text-xl font-bold mb-3">{feature.title}</h3>
                  <p className="text-muted-foreground leading-relaxed text-sm">{feature.description}</p>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* CTA Section */}
        <section className="py-24 relative overflow-hidden">
            <div className="absolute inset-0 bg-primary/5"></div>
            <div className="container mx-auto px-4 text-center relative z-10">
                <h2 className="text-4xl md:text-5xl font-bold mb-6 tracking-tight">Ready to Dive In?</h2>
                <p className="text-muted-foreground text-lg mb-10 max-w-lg mx-auto">
                Join thousands of users watching their favorite content on Movora.
                </p>
                <Button asChild size="lg" className="h-14 px-10 text-lg rounded-full shadow-2xl shadow-primary/20 hover:scale-105 transition-transform">
                <a href={androidAppLink}>
                    <Download className="mr-2 h-6 w-6" />
                    Download App Now
                </a>
                </Button>
            </div>
        </section>
      </main>
      <Footer />
    </div>
  );
}