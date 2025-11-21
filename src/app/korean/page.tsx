import Link from 'next/link';
import { discoverMovies, discoverTvShows } from '@/lib/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import { Button } from '@/components/ui/button';
import { fetchFeaturedKorean } from '@/lib/featured-media';

const KOREAN_PARAMS = { with_original_language: 'ko', region: 'KR', include_adult: 'false' };
const movieSections = [
  { title: 'Latest Korean Releases', slug: 'latest-korean-movies', params: { ...KOREAN_PARAMS, sort_by: 'primary_release_date.desc', 'vote_count.gte': '25' } },
  { title: 'Top-Rated Korean Movies', slug: 'top-rated-korean-movies', params: { ...KOREAN_PARAMS, sort_by: 'vote_average.desc', 'vote_count.gte': '50' } },
];
const tvSections = [
  { title: 'Popular Korean TV Shows', slug: 'popular-korean-tv', params: { ...KOREAN_PARAMS, sort_by: 'popularity.desc', 'vote_count.gte': '20' } },
];

async function FeaturedKorean() {
    const featuredMedia = await fetchFeaturedKorean();
    return (
        <section>
            <div className="flex justify-between items-center mb-6">
                <h2 className="font-headline text-3xl font-bold text-gradient">Featured Korean Cinema</h2>
                <Link href="/discover/featured-korean"><Button variant="outline">More</Button></Link>
            </div>
            <MovieList initialMedia={featuredMedia} carousel={true} />
        </section>
    );
}

export default async function KoreanPage() {
  const sectionMovies = await Promise.all(movieSections.map(section => discoverMovies(section.params, 1)));
  const sectionTvShows = await Promise.all(tvSections.map(section => discoverTvShows(section.params, 1)));

  return (
    <div className="container mx-auto px-4 py-6 space-y-10">
        <FeaturedKorean />
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