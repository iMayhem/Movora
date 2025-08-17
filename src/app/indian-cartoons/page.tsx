
import { FeaturedIndianCartoons } from '@/components/movies/FeaturedIndianCartoons';

export default async function IndianCartoonsPage() {
  return (
    <div className="container mx-auto px-4 py-8 space-y-16">
      <section>
        <h1 className="font-headline text-4xl font-bold text-white md:text-5xl mb-8">
          Indian Cartoons
        </h1>
        <p className="text-muted-foreground max-w-3xl">
          A comprehensive list of popular shows that have aired on major Indian kids' television channels like Hungama, Disney XD, Disney Channel, Nickelodeon, Cartoon Network, and Pogo.
        </p>
      </section>
      
      <FeaturedIndianCartoons />
    </div>
  );
}
