
import Link from 'next/link';
import { discoverMovies, discoverTvShows } from '@/lib/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import { TrendingCarousel } from '@/components/movies/TrendingCarousel';
import { Button } from '@/components/ui/button';

const ANIMATED_MOVIE_PARAMS = {
  with_genres: '16,10751', // Animation & Family
  'certification_country': 'US',
  'certification.lte': 'PG',
};

const ANIMATED_TV_PARAMS = {
  with_genres: '16,10751',
};

const sections = [
  {
    title: 'Top Rated Animated Movies',
    slug: 'top-rated-animated',
    fetcher: () => discoverMovies({ ...ANIMATED_MOVIE_PARAMS, sort_by: 'vote_average.desc', 'vote_count.gte': '100' }, 1),
    isMovie: true,
  },
  {
    title: 'Pixar Animation Studios',
    slug: 'pixar-animated',
    fetcher: () => discoverMovies({ ...ANIMATED_MOVIE_PARAMS, with_companies: '3' }, 1),
    isMovie: true,
  },
  {
    title: 'Studio Ghibli',
    slug: 'ghibli-animated',
    fetcher: () => discoverMovies({ ...ANIMATED_MOVIE_PARAMS, with_companies: '10342' }, 1),
    isMovie: true,
  },
  {
    title: 'Recent & Upcoming Animated Movies',
    slug: 'recent-upcoming-animated',
    fetcher: () => discoverMovies({
      with_genres: '16',
      'primary_release_date.gte': '2020-01-01',
      'primary_release_date.lte': '2025-12-31',
      sort_by: 'popularity.desc'
    }, 1),
    isMovie: true,
  },
  {
    title: 'Popular Animated TV Shows',
    slug: 'popular-animated-tv',
    fetcher: () => discoverTvShows({ ...ANIMATED_TV_PARAMS, sort_by: 'popularity.desc' }, 1),
    isMovie: false,
  },
];

export default async function AnimatedPage() {
  const [trendingAnimated, ...sectionMedia] = await Promise.all([
    discoverMovies({ ...ANIMATED_MOVIE_PARAMS, sort_by: 'popularity.desc' }, 1),
    ...sections.map(section => section.fetcher()),
  ]);

  return (
    <div className="container mx-auto px-4 py-8 space-y-16">
      <section>
        <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-6 gap-4">
          <h1 className="font-headline text-4xl font-bold text-white md:text-5xl">
            World of Animation
          </h1>
        </div>
        {trendingAnimated.length > 0 ? (
          <TrendingCarousel items={trendingAnimated} />
        ) : (
          <p>Could not load trending animated movies.</p>
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
            showControls={false}
            carousel
          />
        </section>
      ))}
    </div>
  );
}
