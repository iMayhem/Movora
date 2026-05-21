import { MovieboxSession, search, getMovieStreamUrl, getEpisodeStreamUrl } from 'moviebox-js-sdk';

const session = new MovieboxSession({
  host: 'h5.aoneroom.com',
  mirrorHosts: ['h5.aoneroom.com', 'movieboxapp.in'],
  fetch: (url, init) => {
    const proxyUrl = 'https://proxy.moovie.fun/';
    const originalUrl = url.toString();
    const proxiedUrl = `${proxyUrl}${originalUrl}`;
    
    // Preserve the original aoneroom.com URL as Referer so the API returns streams.
    // If we pass the proxy URL as Referer, aoneroom.com returns hasResource:false.
    const headers = new Headers(init?.headers);
    const existingReferer = headers.get('referer') || headers.get('Referer');
    if (existingReferer && existingReferer.startsWith(proxyUrl)) {
      // Strip the proxy prefix to recover the real aoneroom.com referer
      headers.set('referer', existingReferer.replace(proxyUrl, ''));
    } else if (!existingReferer) {
      // Default to aoneroom.com as origin referer
      headers.set('referer', 'https://h5.aoneroom.com');
    }
    
    return fetch(proxiedUrl, { ...init, headers });
  }
});

export interface MovieboxStreamResponse {
  streamUrl: string | null;
  subtitles: { label: string; src: string; lang: string }[];
  options: { label: string; url: string }[];
}

export async function getMovieboxStream(params: {
  title: string;
  type: 'movie' | 'tv';
  season?: number;
  episode?: number;
  year?: number;
}): Promise<MovieboxStreamResponse | null> {
  try {
    const searchFilter = params.type === 'movie' ? 'movie' : 'tv';
    
    // 1. Search for the title
    const searchResults = await search(session, {
      query: params.title,
      type: searchFilter,
      page: 1,
      perPage: 10
    });
    
    if (!searchResults.results || searchResults.results.length === 0) {
      console.log(`Moviebox: No results found for "${params.title}"`);
      return null;
    }
    
    // 2. Select best match (by year if movie, or fallback to first)
    let matched = searchResults.results[0];
    if (params.type === 'movie' && params.year) {
      const yearMatch = searchResults.results.find(
        r => r.releaseYear === params.year
      );
      if (yearMatch) matched = yearMatch;
    }
    
    // Use detailPath from search result
    const detailPath = matched.raw?.detailPath || matched.pageUrl;
    if (!detailPath) {
      console.log('Moviebox: No detail path found on match');
      return null;
    }
    
    console.log(`Moviebox: Matched "${matched.title}" with path "${detailPath}"`);
    
    // 3. Resolve Stream URL
    let streamResult;
    if (params.type === 'movie') {
      streamResult = await getMovieStreamUrl(session, {
        detailPath: detailPath,
        quality: 'best'
      });
    } else {
      streamResult = await getEpisodeStreamUrl(session, {
        detailPath: detailPath,
        season: params.season || 1,
        episode: params.episode || 1,
        quality: 'best'
      });
    }
    
    if (!streamResult) {
      console.log('Moviebox: No streaming resource found');
      return null;
    }
    
    // 4. Format Subtitles
    const subtitles = (streamResult.captions || []).map(c => ({
      label: c.language || 'English',
      src: c.url,
      lang: c.languageCode || 'en'
    }));
    
    // 5. Format Stream Options
    const options = (streamResult.options || []).map(opt => ({
      label: `${opt.quality || opt.resolution}p`,
      url: opt.url
    }));
    
    return {
      streamUrl: streamResult.stream?.url || null,
      subtitles,
      options
    };
  } catch (error) {
    console.error('Error fetching Moviebox stream:', error);
    return null;
  }
}
