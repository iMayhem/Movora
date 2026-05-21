import { NextRequest, NextResponse } from 'next/server';
import { getMovieboxStream } from '@/lib/moviebox';

export const dynamic = 'force-dynamic';

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const title = searchParams.get('title');
    const type = searchParams.get('type') as 'movie' | 'tv' | null;
    const season = searchParams.get('season') ? Number(searchParams.get('season')) : undefined;
    const episode = searchParams.get('episode') ? Number(searchParams.get('episode')) : undefined;
    const year = searchParams.get('year') ? Number(searchParams.get('year')) : undefined;

    if (!title || !type) {
      return NextResponse.json(
        { error: 'Missing required parameters: title and type' },
        { status: 400 }
      );
    }

    if (type !== 'movie' && type !== 'tv') {
      return NextResponse.json(
        { error: 'Invalid type parameter. Must be "movie" or "tv"' },
        { status: 400 }
      );
    }

    const streamResult = await getMovieboxStream({
      title,
      type,
      season,
      episode,
      year
    });

    if (!streamResult) {
      return NextResponse.json(
        { error: 'No stream source found for the given title.' },
        { status: 404 }
      );
    }

    return NextResponse.json(streamResult);
  } catch (error) {
    console.error('Moviebox API Route error:', error);
    return NextResponse.json(
      { error: 'Internal server error while resolving stream.' },
      { status: 500 }
    );
  }
}
