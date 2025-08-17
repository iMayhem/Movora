

import { MovieList } from '@/components/movies/MovieList';
import { notFound } from 'next/navigation';
import { discoverCategories } from '@/lib/discover-categories';


type DiscoverPageProps = {
  params: { slug: string };
};

export default async function DiscoverPage({ params }: DiscoverPageProps) {
  const category = discoverCategories[params.slug];

  if (!category) {
    notFound();
  }

  const movies = await category.fetcher();

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="mb-8 font-headline text-4xl font-bold text-white md:text-5xl">
        {category.title}
      </h1>
      <MovieList initialMedia={movies} showControls={false} />
    </div>
  );
}
