
import { FeaturedCartoons } from '@/components/movies/FeaturedCartoons';

export default async function CartoonsPage() {
  return (
    <div className="container mx-auto px-4 py-6 space-y-10">
      <FeaturedCartoons />
    </div>
  );
}
