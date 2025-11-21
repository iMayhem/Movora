import Link from 'next/link';
import { discoverMovies, discoverTvShows } from '@/lib/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import { Button } from '@/components/ui/button';
import { fetchFeaturedAnimated } from '@/lib/featured-media';

const sections = [
  { title: 'Top Rated Animated Movies', slug: 'top-rated-animated', fetcher: () => discoverMovies({ with_genres: '16', sort_by: 'vote_average.desc', 'vote_count.gte': '100' }, 1) },
  { title: 'Recent Animated Movies', slug: 'recent-animated', fetcher: () => discoverMovies({ with_genres: '16', 'primary_release_date.gte': '2020-01-01', sort_by: 'popularity.desc' }, 1) },
  { title: 'Popular Animated TV Shows', slug: 'popular-animated-tv', fetcher: () => discoverTvShows({ with_genres: '16,10751', sort_by: 'popularity.desc' }, 1) },
];

async function FeaturedAnimated() {
    const featuredMedia = await fetchFeaturedAnimated();
    return (
        <section>
            <div className="flex justify-between items-center mb-6">
                <h2 className="font-headline text-3xl font-bold text-gradient">Featured Animated</h2>
                <Link href="/discover/featured-animated"><Button variant="outline">More</Button></Link>
            </div>
            <MovieList initialMedia={featuredMedia} carousel={true} />
        </section>
    );
}

export default async function AnimatedPage() {
  const sectionMedia = await Promise.all(sections.map(section => section.fetcher()));
  return (
    <div className="container mx-auto px-4 py-6 space-y-10">
      <FeaturedAnimated />
      {sections.map((section, index) => (
        <section key={section.slug}>
          <div className="flex justify-between items-center mb-4">
            <h2 className="font-headline text-2xl font-bold text-gradient">{section.title}</h2>
            <Link href={`/discover/${section.slug}`}><Button variant="outline">More</Button></Link>
          </div>
          <MovieList initialMedia={sectionMedia[index] || []} slug={section.slug} carousel />
        </section>
      ))}
    </div>
  );
}