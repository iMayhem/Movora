
import Link from 'next/link';
import { discoverTvShows } from '@/lib/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import { TrendingCarousel } from '@/components/movies/TrendingCarousel';
import { Button } from '@/components/ui/button';

const INDIAN_CARTOON_PARAMS = {
  with_genres: '16',
  with_origin_country: 'IN',
  'vote_count.gte': '5',
};

const sections = [
  {
    title: 'Top-Rated Indian Cartoons',
    slug: 'top-rated-indian-cartoons',
    fetcher: () => discoverTvShows({ ...INDIAN_CARTOON_PARAMS, sort_by: 'vote_average.desc' }, 1),
  },
  {
    title: 'Latest Indian Cartoons',
    slug: 'latest-indian-cartoons',
    fetcher: () => discoverTvShows({ ...INDIAN_CARTOON_PARAMS, sort_by: 'first_air_date.desc' }, 1),
  },
  {
    title: 'Cartoon Network',
    slug: 'cn-indian-cartoons',
    fetcher: () => discoverTvShows({ ...INDIAN_CARTOON_PARAMS, with_networks: '56' }, 1),
  },
  {
    title: 'Hungama TV',
    slug: 'hungama-indian-cartoons',
    fetcher: () => discoverTvShows({ ...INDIAN_CARTOON_PARAMS, with_networks: '318' }, 1),
  },
  {
    title: 'Pogo',
    slug: 'pogo-indian-cartoons',
    fetcher: () => discoverTvShows({ ...INDIAN_CARTOON_PARAMS, with_networks: '319' }, 1),
  },
];

export default async function IndianCartoonsPage() {
  const [popularShows, ...sectionMedia] = await Promise.all([
    discoverTvShows({ ...INDIAN_CARTOON_PARAMS, sort_by: 'popularity.desc' }, 1),
    ...sections.map(section => section.fetcher()),
  ]);

  return (
    <div className="container mx-auto px-4 py-8 space-y-16">
      <section>
        <h1 className="mb-6 font-headline text-4xl font-bold text-white md:text-5xl">
          Indian TV Cartoons
        </h1>
        {popularShows.length > 0 ? (
          <TrendingCarousel items={popularShows} />
        ) : (
          <p>Could not load popular Indian cartoons.</p>
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
