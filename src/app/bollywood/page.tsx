import Link from 'next/link';
import { discoverMovies, discoverTvShows } from '@/lib/tmdb';
import { MovieList } from '@/components/movies/MovieList';
import { Button } from '@/components/ui/button';
import { fetchFeaturedBollywood } from '@/lib/featured-media';

// REMOVED region: 'IN' to allow global bollywood releases and lowered vote counts
const BOLLYWOOD_BASE_PARAMS = { with_original_language: 'hi' };
const BOLLYWOOD_PARAMS = { ...BOLLYWOOD_BASE_PARAMS, 'vote_count.gte': '10' };

const sections = [
  { 
    title: 'Latest Releases', 
    slug: 'latest-bollywood', 
    params: { 
        ...BOLLYWOOD_BASE_PARAMS, 
        sort_by: 'primary_release_date.desc', 
        'primary_release_date.lte': new Date().toISOString().split('T')[0],
        'vote_count.gte': '5' 
    } 
  },
  { 
    title: 'Top-Rated Classics', 
    slug: 'classics-bollywood', 
    params: { 
        ...BOLLYWOOD_PARAMS, 
        'primary_release_date.lte': '2000-12-31', 
        sort_by: 'vote_average.desc' 
    } 
  },
  { 
    title: 'Action Packed', 
    slug: 'action-bollywood', 
    params: { ...BOLLYWOOD_PARAMS, with_genres: '28' } 
  },
  { 
    title: 'Romantic Flicks', 
    slug: 'romance-bollywood', 
    params: { ...BOLLYWOOD_PARAMS, with_genres: '10749' } 
  },
];

async function FeaturedBollywood() {
  const featuredMedia = await fetchFeaturedBollywood();
  return (
      <section>
          <div className="flex justify-between items-center mb-6">
              <h2 className="font-headline text-3xl font-bold text-gradient">Featured Bollywood</h2>
              <Link href="/discover/featured-bollywood"><Button variant="outline">More</Button></Link>
          </div>
          <MovieList initialMedia={featuredMedia} carousel={true} />
      </section>
  );
}

export default async function BollywoodPage() {
  const sectionMovies = await Promise.all(sections.map(section => discoverMovies(section.params, 1)));
  return (
    <div className="container mx-auto px-4 py-6 space-y-10">
      <FeaturedBollywood />
      {sections.map((section, index) => (
        <section key={section.slug}>
          <div className="flex justify-between items-center mb-4">
            <h2 className="font-headline text-2xl font-bold text-gradient">{section.title}</h2>
            <Link href={`/discover/${section.slug}`}><Button variant="outline">More</Button></Link>
          </div>
          <MovieList initialMedia={sectionMovies[index] || []} slug={section.slug} carousel />
        </section>
      ))}
    </div>
  );
}