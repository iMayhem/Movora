
import Link from 'next/link';
import { discoverMovies, discoverTvShows } from '@/lib/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import { Button } from '@/components/ui/button';
import { TrendingCarousel } from '@/components/movies/TrendingCarousel';

const DOCUMENTARY_PARAMS = {
  with_genres: '99',
};

const sections = [
  {
    title: 'Top-Rated Documentaries',
    slug: 'top-rated-documentaries',
    fetcher: () => discoverMovies({ ...DOCUMENTARY_PARAMS, sort_by: 'vote_average.desc', 'vote_count.gte': '100' }, 1),
    isMovie: true,
  },
  {
    title: 'Recent Documentaries',
    slug: 'recent-documentaries',
    fetcher: () => discoverMovies({ ...DOCUMENTARY_PARAMS, 'primary_release_date.gte': '2022-01-01', sort_by: 'popularity.desc' }, 1),
    isMovie: true,
  },
  {
    title: 'Biographical Documentaries',
    slug: 'bio-documentaries',
    fetcher: () => discoverMovies({ with_keywords: '9844' }, 1), // keyword for biography
    isMovie: true,
  },
  {
    title: 'Netflix Original Documentaries',
    slug: 'netflix-documentaries',
    fetcher: () => discoverMovies({ ...DOCUMENTARY_PARAMS, with_watch_providers: '8', watch_region: 'US' }, 1),
    isMovie: true,
  },
  {
    title: 'Prime Video Documentaries',
    slug: 'prime-documentaries',
    fetcher: () => discoverMovies({ ...DOCUMENTARY_PARAMS, with_watch_providers: '9', watch_region: 'US' }, 1),
    isMovie: true,
  },
  {
    title: 'Popular Docuseries',
    slug: 'popular-docuseries',
    fetcher: () => discoverTvShows({ ...DOCUMENTARY_PARAMS, sort_by: 'popularity.desc' }, 1),
    isMovie: false,
  },
];

export default async function DocumentariesPage() {
  const [trendingDocs, ...sectionMedia] = await Promise.all([
    discoverMovies({ ...DOCUMENTARY_PARAMS, sort_by: 'popularity.desc' }, 1),
    ...sections.map(section => section.fetcher()),
  ]);

  return (
    <div className="container mx-auto px-4 py-8 space-y-16">
      <section>
        <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-6 gap-4">
          <h1 className="font-headline text-4xl font-bold text-white md:text-5xl">
            Documentaries
          </h1>
        </div>
        
        {trendingDocs.length > 0 ? (
          <TrendingCarousel items={trendingDocs} />
        ) : (
          <p>Could not load trending documentaries.</p>
        )}
      </section>

      {sections.map((section, index) => (
        <section key={section.slug}>
          <div className="flex justify-between items-center mb-6">
            <h2 className="font-headline text-3xl font-bold">{section.title}</h2>
            <Link href={`/discover/${section.slug}`}>
              <Button variant="outline">More</Button>
            </Link>
          </div>
          <MovieList
            initialMedia={sectionMedia[index]}
            
            carousel
          />
        </section>
      ))}
    </div>
  );
}
