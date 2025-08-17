'use client';

import { useState, useEffect } from 'react';
import Image from 'next/image';
import { getTvShowDetails, getTvShowCredits, getSimilarTvShows } from '@/lib/tmdb';
import { Star, Calendar, Tv, PlayCircle } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { WatchLaterButton } from '@/components/movies/WatchLaterButton';
import { MovieList } from '@/components/movies/MovieList';
import { VideoPlayer } from '@/components/common/VideoPlayer';
import type { Media, TVShow, Credits } from '@/types/tmdb';

type TvShowPageProps = {
  params: { id: string };
};

export default function TvShowPage({ params }: TvShowPageProps) {
  const [show, setShow] = useState<(TVShow & { media_type: 'tv' }) | null>(null);
  const [credits, setCredits] = useState<Credits | null>(null);
  const [similarShows, setSimilarShows] = useState<Media[]>([]);
  const [isVideoPlayerOpen, setIsVideoPlayerOpen] = useState(false);

  useEffect(() => {
    const fetchTvShowData = async () => {
      const tvShowId = Number(params.id);
      const showDetails = await getTvShowDetails(tvShowId);
      setShow(showDetails);
      const showCredits = await getTvShowCredits(tvShowId);
      setCredits(showCredits);
      const similar = await getSimilarTvShows(tvShowId);
      setSimilarShows(similar);
    };

    fetchTvShowData();
  }, [params]);

  if (!show) {
    return <div>Loading...</div>;
  }

  const cast = credits?.cast.slice(0, 10) || [];

  return (
    <>
      <VideoPlayer
        isOpen={isVideoPlayerOpen}
        onClose={() => setIsVideoPlayerOpen(false)}
        mediaId={show.id}
        mediaType={show.media_type}
      />
      <div className="container mx-auto px-4 py-8 text-white">
        <div className="relative h-[30vh] md:h-[50vh] w-full">
          {show.backdrop_path && (
            <Image
              src={`https://image.tmdb.org/t/p/original${show.backdrop_path}`}
              alt={`${show.name} backdrop`}
              fill
              style={{ objectFit: 'cover' }}
              className="rounded-lg opacity-30"
              data-ai-hint="tv show backdrop"
              priority
            />
          )}
          <div className="absolute inset-0 bg-gradient-to-t from-background to-transparent"></div>
        </div>

        <div className="relative -mt-24 md:-mt-48 px-4 md:px-8 pb-12">
          <div className="flex flex-col md:flex-row gap-8">
            <div className="w-full md:w-1/3 lg:w-1/4">
              <Image
                src={show.poster_path ? `https://image.tmdb.org/t/p/w500${show.poster_path}` : "https://placehold.co/500x750.png"}
                alt={`${show.name} poster`}
                width={500}
                height={750}
                className="rounded-lg shadow-2xl"
                data-ai-hint="tv show poster"
              />
            </div>
            <div className="w-full md:w-2/3 lg:w-3/4 pt-0 md:pt-24">
              <h1 className="font-headline text-4xl md:text-6xl font-bold mb-2">{show.name}</h1>
              <p className="text-lg text-muted-foreground mb-4">{show.tagline}</p>
              <div className="flex flex-wrap items-center gap-4 mb-6">
                <div className="flex items-center gap-2">
                  <Star className="text-accent" />
                  <span>{show.vote_average.toFixed(1)} / 10</span>
                </div>
                <div className="flex items-center gap-2">
                  <Calendar className="text-accent" />
                  <span>{show.first_air_date?.substring(0, 4)}</span>
                </div>
                <div className="flex items-center gap-2">
                  <Tv className="text-accent" />
                  <span>{show.number_of_seasons} Season{show.number_of_seasons > 1 ? 's' : ''}</span>
                </div>
              </div>
              <div className="flex flex-wrap gap-2 mb-6">
                {show.genres.map(genre => (
                  <Badge key={genre.id} variant="secondary">{genre.name}</Badge>
                ))}
              </div>
              <p className="text-base leading-relaxed mb-6">{show.overview}</p>
              <div className="flex items-center gap-4">
                <Button onClick={() => setIsVideoPlayerOpen(true)} size="lg">
                  <PlayCircle className="mr-2" />
                  Watch Now
                </Button>
                <WatchLaterButton item={show} />
              </div>
            </div>
          </div>
        </div>

        <div className="px-4 md:px-8">
          <section className="mb-12">
            <h2 className="font-headline text-3xl font-bold mb-6">Top Cast</h2>
            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-6">
              {cast.map(member => (
                <div key={member.id} className="text-center">
                  <Image
                    src={member.profile_path ? `https://image.tmdb.org/t/p/w185${member.profile_path}` : "https://placehold.co/185x278.png"}
                    alt={member.name}
                    width={185}
                    height={278}
                    className="rounded-lg mb-2 mx-auto"
                    data-ai-hint="actor portrait"
                  />
                  <p className="font-semibold">{member.name}</p>
                  <p className="text-sm text-muted-foreground">{member.character}</p>
                </div>
              ))}
            </div>
          </section>

          {similarShows.length > 0 && (
            <section>
              <h2 className="font-headline text-3xl font-bold mb-6">Similar Shows</h2>
              <MovieList initialMedia={similarShows} showControls={false} />
            </section>
          )}
        </div>
      </div>
    </>
  );
}
