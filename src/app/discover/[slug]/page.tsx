

import { MovieList } from '@/components/movies/MovieList';
import { notFound } from 'next/navigation';
import { discoverCategories } from '@/lib/discover-categories';


type DiscoverPageProps = {
  params: { slug: string };
};

export default async function DiscoverPage({ params: { slug } }: DiscoverPageProps) {
  const category = discoverCategories[slug];

  if (!category) {
    notFound();
  }

  const movies = await category.fetcher();

  return (
    <div className="container mx-auto px-4 py-6">
      <h1 className="mb-6 font-headline text-3xl font-bold text-white md:text-4xl">
        {category.title}
      </h1>
      <MovieList initialMedia={movies} />
    </div>
  );
}
