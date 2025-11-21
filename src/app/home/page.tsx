'use client';

import { Button } from '@/components/ui/button';
import Link from 'next/link';
import { MovieList } from '@/components/movies/MovieList';
import type { Media } from '@/types/tmdb';
import { useEffect, useState } from 'react';
import { fetchFeaturedHollywood, fetchFeaturedKorean, fetchFeaturedBollywood, fetchFeaturedAnimated, fetchMedia, allShows, fetchCartoonsByChannel } from '@/lib/featured-media';

function FeaturedHollywoodSection({ showMore = false }: { showMore?: boolean }) {
    const [featuredMedia, setFeaturedMedia] = useState<Media[]>([]);
    useEffect(() => {
        const fetch = async () => { const media = await fetchFeaturedHollywood(); setFeaturedMedia(media); };
        fetch();
    }, []);
    return (
        <section>
            <div className="flex justify-between items-center mb-6">
                <h2 className="font-headline text-3xl font-bold text-gradient">Featured Hollywood</h2>
                {showMore && <Link href="/discover/featured-hollywood"><Button variant="outline">More</Button></Link>}
            </div>
            <MovieList initialMedia={featuredMedia} slug="featured-hollywood" carousel={showMore} />
        </section>
    );
}

function FeaturedKoreanSection({ showMore = false }: { showMore?: boolean }) {
    const [featuredMedia, setFeaturedMedia] = useState<Media[]>([]);
    useEffect(() => {
        const fetch = async () => { const media = await fetchFeaturedKorean(); setFeaturedMedia(media); };
        fetch();
    }, []);
    return (
        <section>
            <div className="flex justify-between items-center mb-6">
                <h2 className="font-headline text-3xl font-bold text-gradient">Featured Korean</h2>
                {showMore && <Link href="/discover/featured-korean"><Button variant="outline">More</Button></Link>}
            </div>
            <MovieList initialMedia={featuredMedia} carousel={showMore} />
        </section>
    );
}

function FeaturedBollywoodSection({ showMore = false }: { showMore?: boolean }) {
    const [featuredMedia, setFeaturedMedia] = useState<Media[]>([]);
    useEffect(() => {
        const fetch = async () => { const media = await fetchFeaturedBollywood(); setFeaturedMedia(media); };
        fetch();
    }, []);
    return (
        <section>
            <div className="flex justify-between items-center mb-6">
                <h2 className="font-headline text-3xl font-bold text-gradient">Featured Bollywood</h2>
                {showMore && <Link href="/discover/featured-bollywood"><Button variant="outline">More</Button></Link>}
            </div>
            <MovieList initialMedia={featuredMedia} carousel={showMore} />
        </section>
    );
}

function FeaturedAnimatedSection({ showMore = false }: { showMore?: boolean }) {
    const [featuredMedia, setFeaturedMedia] = useState<Media[]>([]);
    useEffect(() => {
        const fetch = async () => { const media = await fetchFeaturedAnimated(); setFeaturedMedia(media); };
        fetch();
    }, []);
    return (
        <section>
            <div className="flex justify-between items-center mb-6">
                <h2 className="font-headline text-3xl font-bold text-gradient">Featured Animated</h2>
                {showMore && <Link href="/discover/featured-animated"><Button variant="outline">More</Button></Link>}
            </div>
            <MovieList initialMedia={featuredMedia} carousel={showMore} />
        </section>
    );
}

const adventureSections = [
    { title: 'The Survivalists', slug: 'survival-docs', titles: allShows.survivalists },
    { title: 'Adventurers & Explorers', slug: 'explorer-docs', titles: allShows.adventurers },
];

function FeaturedAdventureSection({ showMore = false }: { showMore?: boolean }) {
    const [allSectionMedia, setAllSectionMedia] = useState<Media[][]>([]);
    useEffect(() => {
        const fetchAll = async () => {
            const media = await Promise.all(adventureSections.map(section => fetchMedia(section.titles)));
            setAllSectionMedia(media);
        };
        fetchAll();
    }, []);
    return (
        <>
            {adventureSections.map((section, index) => (
                <section key={section.slug}>
                    <div className="flex justify-between items-center mb-4">
                        <h2 className="font-headline text-2xl font-bold text-gradient">{section.title}</h2>
                        {showMore && <Link href={`/discover/${section.slug}`}><Button variant="outline">More</Button></Link>}
                    </div>
                    <MovieList initialMedia={allSectionMedia[index] || []} slug={section.slug} carousel />
                </section>
            ))}
        </>
    );
}

const cartoonSectionsList = [
    { title: 'Cartoon Network', slug: 'cartoons-cn', channel: 'cartoon-network' as const },
    { title: 'Pogo', slug: 'cartoons-pogo', channel: 'pogo' as const },
    { title: 'Nickelodeon', slug: 'cartoons-nick', channel: 'nick' as const },
];

function FeaturedCartoonsSection({ showMore = false }: { showMore?: boolean }) {
    const [allSectionMedia, setAllSectionMedia] = useState<Media[][]>([]);
    useEffect(() => {
        const fetchAll = async () => {
            const media = await Promise.all(cartoonSectionsList.map(section => fetchCartoonsByChannel(section.channel)));
            setAllSectionMedia(media);
        };
        fetchAll();
    }, []);
    return (
        <>
            {cartoonSectionsList.map((section, index) => (
                <section key={section.slug}>
                    <div className="flex justify-between items-center mb-4">
                        <h2 className="font-headline text-2xl font-bold text-gradient">{section.title}</h2>
                        {showMore && <Link href={`/discover/${section.slug}`}><Button variant="outline">More</Button></Link>}
                    </div>
                    <MovieList initialMedia={allSectionMedia[index] || []} slug={section.slug} carousel />
                </section>
            ))}
        </>
    );
}

export default function HomePage() {
  return (
    <div className="bg-background text-foreground min-h-screen">
      <main className="container mx-auto py-10 px-4 space-y-16">
            <FeaturedHollywoodSection showMore />
            <FeaturedBollywoodSection showMore />
            <FeaturedKoreanSection showMore />
            <FeaturedAnimatedSection showMore />
            <FeaturedAdventureSection showMore />
            <FeaturedCartoonsSection showMore />
      </main>
    </div>
  );
}