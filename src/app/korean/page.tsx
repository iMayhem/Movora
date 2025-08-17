
import Link from 'next/link';
import { discoverMovies, discoverTvShows } from '@/lib/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import { Button } from '@/components/ui/button';
import { FeaturedKorean } from '@/components/movies/FeaturedKorean';

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
  const sectionMovies = await Promise.all(
    movieSections.map(section => discoverMovies(section.params, 6)),
  );

  const sectionTvShows = await Promise.all(tvSections.map(section => discoverTvShows(section.params, 6)))

  return (
    <div className="container mx-auto px-4 py-6 space-y-10">
        <FeaturedKorean showMore />
      {movieSections.map((section, index) => (
        <section key={section.slug}>
          <div className="flex justify-between items-center mb-4">
            <h2 className="font-headline text-2xl font-bold">{section.title}</h2>
            <Link href={`/discover/${section.slug}`}>
              <Button variant="outline">More</Button>
            </Link>
          </div>
          <MovieList
            initialMedia={sectionMovies[index]}
            
            carousel
          />
        </section>
      ))}

      {tvSections.map((section, index) => (
        <section key={section.slug}>
        <div className="flex justify-between items-center mb-4">
            <h2 className="font-headline text-2xl font-bold">{section.title}</h2>
            <Link href={`/discover/${section.slug}`}>
              <Button variant="outline">More</Button>
            </Link>
        </div>
        <MovieList
            initialMedia={sectionTvShows[index]}
            
            carousel
        />
        </section>
      ))}
    </div>
  );
}
