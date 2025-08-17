import Link from 'next/link';
import { discoverMovies } from '@/lib/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import { TrendingCarousel } from '@/components/movies/TrendingCarousel';
import { Button } from '@/components/ui/button';

const CURRENT_YEAR = new Date().getFullYear();

const TOP_RATED_PARAMS = {
  'vote_count.gte': 500,
  'sort_by': 'vote_average.desc',
};

const sections = [
  {
    title: 'Popular This Year',
    slug: 'popular-this-year-imdb',
    params: { 'vote_count.gte': '250', 'primary_release_year': String(CURRENT_YEAR) },
  },
  {
    title: 'Top Rated Action',
    slug: 'top-rated-action-imdb',
    params: { ...TOP_RATED_PARAMS, with_genres: '28' },
  },
  {
    title: 'Top Rated Drama',
    slug: 'top-rated-drama-imdb',
    params: { ...TOP_RATED_PARAMS, with_genres: '18' },
  },
  {
    title: 'Top Rated Sci-Fi & Fantasy',
    slug: 'top-rated-scifi-imdb',
    params: { ...TOP_RATED_PARAMS, with_genres: '878,14' },
  },
];

export default async function TopImdbPage() {
  const [topRated, ...sectionMovies] = await Promise.all([
    discoverMovies({ ...TOP_RATED_PARAMS }, 1),
    ...sections.map(section => discoverMovies(section.params, 1)),
  ]);

  return (
    <div className="container mx-auto px-4 py-8 space-y-16">
      <section>
        <h1 className="mb-6 font-headline text-4xl font-bold text-white md:text-5xl">
          Top IMDB Picks
        </h1>
        {topRated.length > 0 ? (
          <TrendingCarousel items={topRated} />
        ) : (
          <p>Could not load trending movies.</p>
        )}
      </section>

      <section>
        <div className="flex justify-between items-center mb-6">
          <h2 className="font-headline text-3xl font-bold">Top Rated of All Time</h2>
          <Link href="/discover/top-rated-imdb">
            <Button variant="outline">More</Button>
          </Link>
        </div>
        <MovieList
          initialMedia={topRated}
          showControls={false}
          carousel
        />
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
            initialMedia={sectionMovies[index]}
            showControls={false}
            carousel
          />
        </section>
      ))}
    </div>
  );
}
