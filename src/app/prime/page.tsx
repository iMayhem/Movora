import Link from 'next/link';
import { discoverMovies, discoverTvShows } from '@/lib/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import { Button } from '@/components/ui/button';

const PRIME_PARAMS = { watch_region: 'US', with_watch_monetization_types: 'flatrate', with_watch_providers: '9', 'vote_count.gte': '100' };
const movieSections = [
  { title: 'Top Rated on Prime', slug: 'top-rated-prime', params: { ...PRIME_PARAMS, sort_by: 'vote_average.desc', 'vote_count.gte': '300' } },
  { title: 'Action & Adventure', slug: 'action-prime', params: { ...PRIME_PARAMS, with_genres: '28' } },
];
const tvSections = [
    { title: 'Popular TV Shows on Prime', slug: 'popular-tv-prime', params: { ...PRIME_PARAMS, sort_by: 'popularity.desc' } },
];

export default async function PrimePage() {
    const sectionMovies = await Promise.all(movieSections.map(section => discoverMovies(section.params, 1)));
    const sectionTvShows = await Promise.all(tvSections.map(section => discoverTvShows(section.params, 1)));
    return (
    <div className="container mx-auto px-4 py-6 space-y-10">
      {movieSections.map((section, index) => (
        <section key={section.slug}>
          <div className="flex justify-between items-center mb-4">
            <h2 className="font-headline text-2xl font-bold text-gradient">{section.title}</h2>
            <Link href={`/discover/${section.slug}`}><Button variant="outline">More</Button></Link>
          </div>
          <MovieList initialMedia={sectionMovies[index] || []} slug={section.slug} carousel />
        </section>
      ))}
        {tvSections.map((section, index) => (
            <section key={section.slug}>
            <div className="flex justify-between items-center mb-4">
                <h2 className="font-headline text-2xl font-bold text-gradient">{section.title}</h2>
                <Link href={`/discover/${section.slug}`}><Button variant="outline">More</Button></Link>
            </div>
            <MovieList initialMedia={sectionTvShows[index] || []} slug={section.slug} carousel />
            </section>
        ))}
    </div>
  );
}