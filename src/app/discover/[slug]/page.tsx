import { MovieList } from '@/components/movies/MovieList';
import { notFound } from 'next/navigation';
import { discoverCategories } from '@/lib/discover-categories';

export default async function DiscoverPage({ params }: { params: { slug: string } }) {
  const { slug } = params;
  const category = discoverCategories[slug];
  if (!category) notFound();
  const movies = await category.fetcher(1);

  return (
    <div className="container mx-auto px-4 py-6">
      <h1 className="mb-6 font-headline text-3xl font-bold text-gradient">{category.title}</h1>
      <MovieList initialMedia={movies} slug={slug} />
    </div>
  );
}