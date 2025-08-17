
import Link from 'next/link';
import { discoverMovies, discoverTvShows } from '@/lib/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import { Button } from '@/components/ui/button';

const INDIAN_ANIMATION_MOVIE_PARAMS = {
  with_genres: '16',
  with_original_language: 'hi',
  region: 'IN',
  sort_by: 'popularity.desc',
};

const INDIAN_ANIMATION_TV_PARAMS = {
  with_genres: '16',
  with_original_language: 'hi',
  region: 'IN',
  sort_by: 'popularity.desc',
};

const movieSections = [
  {
    title: 'Popular Indian Animated Movies',
    slug: 'popular-indian-animated-movies',
    fetcher: () => discoverMovies(INDIAN_ANIMATION_MOVIE_PARAMS, 5),
  },
  {
    title: 'Top Rated Indian Animated Movies',
    slug: 'top-rated-indian-animated-movies',
    fetcher: () => discoverMovies({ ...INDIAN_ANIMATION_MOVIE_PARAMS, sort_by: 'vote_average.desc', 'vote_count.gte': 5 }, 5),
  },
];

const tvSections = [
  {
    title: 'Popular Indian Animated TV Shows',
    slug: 'popular-indian-animated-tv',
    fetcher: () => discoverTvShows(INDIAN_ANIMATION_TV_PARAMS, 5),
  },
  {
    title: 'Top Rated Indian Animated TV Shows',
    slug: 'top-rated-indian-animated-tv',
    fetcher: () => discoverTvShows({ ...INDIAN_ANIMATION_TV_PARAMS, sort_by: 'vote_average.desc', 'vote_count.gte': 2 }, 5),
  },
];

export default async function IndianCartoonsPage() {
  const [
    popularMovies,
    topRatedMovies,
  ] = await Promise.all(movieSections.map(section => section.fetcher()));
  
  const [
      popularTv,
      topRatedTv,
  ] = await Promise.all(tvSections.map(section => section.fetcher()));

  const sectionMovieData = [popularMovies, topRatedMovies];
  const sectionTvData = [popularTv, topRatedTv];

  return (
    <div className="container mx-auto px-4 py-8 space-y-16">
      <section>
        <h1 className="font-headline text-4xl font-bold text-white md:text-5xl mb-8">
          Indian Cartoons
        </h1>
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
            initialMedia={sectionMovieData[index]}
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
            initialMedia={sectionTvData[index]}
            showControls={false}
            carousel
          />
        </section>
      ))}
    </div>
  );
}
