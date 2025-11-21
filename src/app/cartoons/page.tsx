import { MovieList } from '@/components/movies/MovieList';
import { Button } from '@/components/ui/button';
import { fetchCartoonsByChannel } from '@/lib/featured-media';
import Link from 'next/link';

const sections = [
    { title: 'Cartoon Network', slug: 'cartoons-cn', channel: 'cartoon-network' as const },
    { title: 'Pogo', slug: 'cartoons-pogo', channel: 'pogo' as const },
    { title: 'Nickelodeon', slug: 'cartoons-nick', channel: 'nick' as const },
    { title: 'Disney', slug: 'cartoons-disney', channel: 'disney' as const },
];

export default async function CartoonsPage() {
    const allSectionMedia = await Promise.all(sections.map(section => fetchCartoonsByChannel(section.channel)));
    return (
        <div className="container mx-auto px-4 py-6 space-y-10">
            {sections.map((section, index) => (
                <section key={section.slug}>
                    <div className="flex justify-between items-center mb-4">
                        <h2 className="font-headline text-2xl font-bold text-gradient">{section.title}</h2>
                        <Link href={`/discover/${section.slug}`}><Button variant="outline">More</Button></Link>
                    </div>
                    <MovieList initialMedia={allSectionMedia[index]} slug={section.slug} carousel />
                </section>
            ))}
        </div>
    );
}