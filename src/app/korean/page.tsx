
import Link from 'next/link';
import { discoverMovies, discoverTvShows } from '@/lib/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import { TrendingCarousel } from '@/components/movies/TrendingCarousel';
import { Button } from '@/components/ui/button';

const KOREAN_PARAMS = {
  with_original_language: 'ko',
  region: 'KR',
  include_adult: 'false',
};

const movieSections = [
  {
    title: 'Latest Korean Releases',
    slug: 'latest-korean-movies',
    params: { ...KOREAN_PARAMS, sort_by: 'primary_release_date.desc', 'vote_count.gte': 10 },
  },
  {
    title: 'Top-Rated Korean Movies',
    slug: 'top-rated-korean-movies',
    params: { ...KOREAN_PARAMS, sort_by: 'vote_average.desc', 'vote_count.gte': 50 },
  },
  {
    title: 'Korean Action Movies',
    slug: 'action-korean-movies',
    params: { ...KOREAN_PARAMS, with_genres: '28' },
  },
  {
    title: 'Korean Thrillers',
    slug: 'thriller-korean-movies',
    params: { ...KOREAN_PARAMS, with_genres: '53' },
  },
];

const tvSections = [
  {
    title: 'Popular Korean TV Shows',
    slug: 'popular-korean-tv',
    params: { ...KOREAN_PARAMS, sort_by: 'popularity.desc' },
  },
  {
    title: 'Top-Rated Korean TV Shows',
    slug: 'top-rated-korean-tv',
    params: { ...KOREAN_PARAMS, sort_by: 'vote_average.desc', 'vote_count.gte': 20 },
  }
];

export default async function KoreanPage() {
  const [
    trendingKorean, 
    ...sectionMovies
  ] = await Promise.all([
    discoverMovies({ ...KOREAN_PARAMS, sort_by: 'popularity.desc' }, 3),
    ...movieSections.map(section => discoverMovies(section.params, 3)),
  ]);

  const sectionTvShows = await Promise.all(tvSections.map(section => discoverTvShows(section.params, 3)))

  return (
    <div className="container mx-auto px-4 py-8 space-y-16">
      <section>
        <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-6 gap-4">
            <h1 className="font-headline text-4xl font-bold text-white md:text-5xl">
              Korean Wave
            </h1>
        </div>
        {trendingKorean.length > 0 ? (
          <TrendingCarousel items={trendingKorean} />
        ) : (
          <p>Could not load trending Korean content.</p>
        )}
      </section>

      {movieSections.map((section, index) => (
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

      {tvSections.map((section, index) => (
        <section key={section.slug}>
        <div className="flex justify-between items-center mb-6">
            <h2 className="font-headline text-3xl font-bold">{section.title}</h2>
            <Link href={`/discover/${section.slug}`}>
              <Button variant="outline">More</Button>
            </Link>
        </div>
        <MovieList
            initialMedia={sectionTvShows[index]}
            showControls={false}
            carousel
        />
        </section>
      ))}
    </div>
  );
}
