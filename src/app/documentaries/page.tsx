import Link from 'next/link';
import { discoverMovies, discoverTvShows } from '@/lib/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import { Button } from '@/components/ui/button';

const sections = [
  { title: 'Top-Rated Documentaries', slug: 'top-rated-documentaries', fetcher: () => discoverMovies({ with_genres: '99', sort_by: 'vote_average.desc', 'vote_count.gte': '100' }, 1) },
  { title: 'Recent Documentaries', slug: 'recent-documentaries', fetcher: () => discoverMovies({ with_genres: '99', 'primary_release_date.gte': '2022-01-01', sort_by: 'popularity.desc' }, 1) },
  { title: 'Popular Docuseries', slug: 'popular-docuseries', fetcher: () => discoverTvShows({ with_genres: '99', sort_by: 'popularity.desc', 'vote_count.gte': '50' }, 1) },
];

export default async function DocumentariesPage() {
  const sectionMedia = await Promise.all(sections.map(section => section.fetcher()));
  return (
    <div className="container mx-auto px-4 py-6 space-y-10">
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