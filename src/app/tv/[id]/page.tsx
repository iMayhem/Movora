import Image from 'next/image';
import { getTvShowDetails, getSimilarTvShows } from '@/lib/tmdb';
import { Star, Calendar, Tv } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { MovieList } from '@/components/movies/MovieList';
import { EpisodeSelector } from '@/components/tv/EpisodeSelector';
import { Suspense } from 'react';
import { Skeleton } from '@/components/ui/skeleton';

async function SimilarShows({ tvShowId }: { tvShowId: number }) {
    const similarShows = await getSimilarTvShows(tvShowId);
    if (similarShows.length === 0) return null;
    return (
        <section className="mt-12">
            <h2 className="font-headline text-2xl font-bold mb-4 text-gradient">Similar Shows</h2>
            <MovieList initialMedia={similarShows} carousel />
        </section>
    )
}

export default async function TvShowPage({ params: { id } }: { params: { id: string } }) {
  const tvShowId = Number(id);
  const show = await getTvShowDetails(tvShowId);
  if (!show) return <div className="container py-10 text-center">TV show not found.</div>;
  const seasons = show?.seasons?.filter(s => s.season_number > 0) || [];

  return (
    <div className="min-h-screen">
      <div className="relative h-[50vh] w-full">
        {show.backdrop_path && (
          <Image src={`https://image.tmdb.org/t/p/original${show.backdrop_path}`} alt={show.name} fill className="object-cover opacity-30" priority />
        )}
        <div className="absolute inset-0 bg-gradient-to-t from-background to-transparent"></div>
      </div>

      <div className="container mx-auto px-4 relative -mt-32 z-10">
        <div className="flex flex-col md:flex-row gap-8">
          <div className="w-full md:w-1/3 lg:w-1/4 shrink-0">
            <Image src={show.poster_path ? `https://image.tmdb.org/t/p/w500${show.poster_path}` : "https://placehold.co/500x750.png"} alt={show.name} width={500} height={750} className="rounded-xl shadow-2xl border border-white/10" priority />
          </div>
          <div className="w-full pt-4 md:pt-32">
            <h1 className="text-4xl md:text-6xl font-bold mb-2 text-gradient">{show.name}</h1>
            <p className="text-lg text-muted-foreground mb-6 italic">{show.tagline}</p>
            <div className="flex flex-wrap gap-4 mb-8">
              <div className="flex items-center gap-2 bg-white/5 px-3 py-1 rounded-full border border-white/10"><Star className="w-4 h-4 text-yellow-500" /> {show.vote_average.toFixed(1)}</div>
              <div className="flex items-center gap-2 bg-white/5 px-3 py-1 rounded-full border border-white/10"><Calendar className="w-4 h-4 text-primary" /> {show.first_air_date?.substring(0, 4)}</div>
              <div className="flex items-center gap-2 bg-white/5 px-3 py-1 rounded-full border border-white/10"><Tv className="w-4 h-4 text-primary" /> {show.number_of_seasons} Seasons</div>
            </div>
            <div className="flex flex-wrap gap-2 mb-8">{show.genres.map(g => <Badge key={g.id} variant="secondary" className="bg-primary/20 hover:bg-primary/30 text-primary-foreground border-none">{g.name}</Badge>)}</div>
            <p className="text-lg leading-relaxed mb-8 text-gray-300">{show.overview}</p>
            <EpisodeSelector tvId={tvShowId} seasons={seasons} />
          </div>
        </div>
        <Suspense fallback={<Skeleton className="h-64 w-full mt-10" />}><SimilarShows tvShowId={tvShowId} /></Suspense>
      </div>
    </div>
  );
}