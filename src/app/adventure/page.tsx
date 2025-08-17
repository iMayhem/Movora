
import { FeaturedAdventure } from '@/components/movies/FeaturedAdventure';

export default async function AdventurePage() {
  return (
    <div className="container mx-auto px-4 py-8 space-y-16">
      <section>
        <h1 className="font-headline text-4xl font-bold text-white md:text-5xl mb-4">
          Adventure & Survival
        </h1>
        <p className="text-muted-foreground max-w-3xl">
          A definitive list of over 100 shows for fans of 'Man vs. Wild' and classic adventure documentaries. For those who grew up captivated by the thrill of survival and exploration on Discovery and National Geographic.
        </p>
      </section>
      
      <FeaturedAdventure />
    </div>
  );
}
