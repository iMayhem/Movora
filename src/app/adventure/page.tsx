import { fetchMedia, allShows } from '@/lib/featured-media';
import { MovieList } from '@/components/movies/MovieList';
import { Button } from '@/components/ui/button';
import Link from 'next/link';

const sections = [
    { title: 'The Survivalists', slug: 'survival-docs', titles: allShows.survivalists },
    { title: 'Adventurers & Explorers', slug: 'explorer-docs', titles: allShows.adventurers },
    { title: 'Wild Kingdom', slug: 'wildlife-docs', titles: allShows['wild-kingdom'] },
    { title: 'The Competition', slug: 'competition-docs', titles: allShows.competition },
    { title: 'Deep Dives', slug: 'expedition-docs', titles: allShows.expeditions },
]

export default async function AdventurePage() {
    const allSectionMedia = await Promise.all(sections.map(section => fetchMedia(section.titles)));
    return (
        <div className="container mx-auto px-4 py-6 space-y-10">
            {sections.map((section, index) => (
                <section key={section.slug}>
                    <div className="flex justify-between items-center mb-4">
                        <h2 className="font-headline text-2xl font-bold text-gradient">{section.title}</h2>
                        <Link href={`/discover/${section.slug}`}><Button variant="outline">More</Button></Link>
                    </div>
                    <MovieList initialMedia={allSectionMedia[index] || []} slug={section.slug} carousel />
                </section>
            ))}
        </div>
    );
}