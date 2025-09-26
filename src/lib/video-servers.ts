export enum VideoServerType {
  VIDEASY = 'videasy',
  VIDPLUS = 'vidplus',
  MOVIES111 = 'movies111',
  VIDSRC = 'vidsrc',
}

export interface VideoServer {
  type: VideoServerType;
  name: string;
  baseUrl: string;
  isActive: boolean;
  priority: number; // Lower number = higher priority
}

export const VIDEO_SERVERS: VideoServer[] = [
  {
    type: VideoServerType.VIDPLUS,
    name: 'VidPlus',
    baseUrl: 'https://player.vidplus.to/embed',
    isActive: true,
    priority: 1,
  },
  {
    type: VideoServerType.VIDEASY,
    name: 'VIDEASY',
    baseUrl: 'https://player.videasy.net',
    isActive: true,
    priority: 2,
  },
  {
    type: VideoServerType.MOVIES111,
    name: '111Movies',
    baseUrl: 'https://111movies.com',
    isActive: true,
    priority: 3,
  },
  {
    type: VideoServerType.VIDSRC,
    name: 'VidSrc',
    baseUrl: 'https://vidsrc.xyz',
    isActive: true,
    priority: 4,
  },
];

export function getActiveServers(): VideoServer[] {
  return VIDEO_SERVERS
    .filter(server => server.isActive)
    .sort((a, b) => a.priority - b.priority);
}

export function getServer(serverType: VideoServerType): VideoServer | undefined {
  return VIDEO_SERVERS.find(server => server.type === serverType);
}

export function buildMovieUrl(serverType: VideoServerType, mediaId: string): string {
  const server = getServer(serverType);
  if (!server) throw new Error(`Server not found: ${serverType}`);

  switch (serverType) {
    case VideoServerType.VIDPLUS:
      return `${server.baseUrl}/movie/${mediaId}`;
    case VideoServerType.VIDEASY:
      return `${server.baseUrl}/movie/${mediaId}`;
    case VideoServerType.MOVIES111:
      // Convert TMDB ID to IMDB format if needed
      const formattedId = formatIdForMovies111(mediaId);
      return `${server.baseUrl}/movie/${formattedId}`;
    case VideoServerType.VIDSRC:
      // VidSrc supports both TMDB and IMDB IDs
      return `${server.baseUrl}/embed/movie/${mediaId}`;
    default:
      throw new Error(`Unsupported server type: ${serverType}`);
  }
}

export function buildTvUrl(
  serverType: VideoServerType,
  mediaId: string,
  season: number,
  episode: number
): string {
  const server = getServer(serverType);
  if (!server) throw new Error(`Server not found: ${serverType}`);

  switch (serverType) {
    case VideoServerType.VIDPLUS:
      return `${server.baseUrl}/tv/${mediaId}/${season}/${episode}`;
    case VideoServerType.VIDEASY:
      return `${server.baseUrl}/tv/${mediaId}/${season}/${episode}`;
    case VideoServerType.MOVIES111:
      // Convert TMDB ID to IMDB format if needed
      const formattedId = formatIdForMovies111(mediaId);
      return `${server.baseUrl}/tv/${formattedId}/${season}/${episode}`;
    case VideoServerType.VIDSRC:
      // VidSrc uses different format: /embed/tv/{id}/{season}-{episode}
      return `${server.baseUrl}/embed/tv/${mediaId}/${season}-${episode}`;
    default:
      throw new Error(`Unsupported server type: ${serverType}`);
  }
}

export function buildMovieUrlWithParams(
  serverType: VideoServerType,
  mediaId: string,
  additionalParams?: Record<string, string>
): string {
  const baseUrl = buildMovieUrl(serverType, mediaId);
  
  switch (serverType) {
    case VideoServerType.VIDPLUS:
      // VidPlus doesn't use query parameters for basic embedding
      return baseUrl;
    case VideoServerType.VIDEASY:
      const params = new URLSearchParams({
        color: '8B5CF6',
        episodeSelector: 'true',
        nextEpisode: 'true',
        autoplayNextEpisode: 'true',
        autoplay: 'true',
        fullscreen: 'true',
        ...additionalParams,
      });
      return `${baseUrl}?${params.toString()}`;
    case VideoServerType.MOVIES111:
      // 111movies doesn't use query parameters
      return baseUrl;
    case VideoServerType.VIDSRC:
      // VidSrc supports subtitle and autoplay parameters
      const vidsrcParams = new URLSearchParams({
        autoplay: '1', // Enable autoplay by default
        ds_lang: 'en', // Default subtitle language
        ...additionalParams,
      });
      return `${baseUrl}?${vidsrcParams.toString()}`;
    default:
      return baseUrl;
  }
}

export function buildTvUrlWithParams(
  serverType: VideoServerType,
  mediaId: string,
  season: number,
  episode: number,
  additionalParams?: Record<string, string>
): string {
  const baseUrl = buildTvUrl(serverType, mediaId, season, episode);
  
  switch (serverType) {
    case VideoServerType.VIDPLUS:
      // VidPlus doesn't use query parameters for basic embedding
      return baseUrl;
    case VideoServerType.VIDEASY:
      const params = new URLSearchParams({
        color: '8B5CF6',
        episodeSelector: 'true',
        nextEpisode: 'true',
        autoplayNextEpisode: 'true',
        autoplay: 'true',
        fullscreen: 'true',
        ...additionalParams,
      });
      return `${baseUrl}?${params.toString()}`;
    case VideoServerType.MOVIES111:
      // 111movies doesn't use query parameters
      return baseUrl;
    case VideoServerType.VIDSRC:
      // VidSrc supports subtitle, autoplay, and autonext parameters
      const vidsrcParams = new URLSearchParams({
        autoplay: '1', // Enable autoplay by default
        autonext: '0', // Disable autonext by default
        ds_lang: 'en', // Default subtitle language
        ...additionalParams,
      });
      return `${baseUrl}?${vidsrcParams.toString()}`;
    default:
      return baseUrl;
  }
}

function formatIdForMovies111(mediaId: string): string {
  // 111movies expects IMDB IDs with 'tt' prefix
  // If it's already an IMDB ID, return as is
  if (mediaId.startsWith('tt')) {
    return mediaId;
  }
  
  // For TMDB IDs, we need to convert them to IMDB format
  // This is a simplified approach - in a real app, you'd need to
  // fetch the IMDB ID from TMDB API using the TMDB ID
  // For now, we'll try to use the TMDB ID as is and let the server handle it
  return mediaId;
}

export function buildAllMovieUrls(mediaId: string): string[] {
  return getActiveServers()
    .map(server => {
      try {
        return buildMovieUrlWithParams(server.type, mediaId);
      } catch (error) {
        console.error(`Error building URL for ${server.name}:`, error);
        return '';
      }
    })
    .filter(url => url.length > 0);
}

export function buildAllTvUrls(mediaId: string, season: number, episode: number): string[] {
  return getActiveServers()
    .map(server => {
      try {
        return buildTvUrlWithParams(server.type, mediaId, season, episode);
      } catch (error) {
        console.error(`Error building URL for ${server.name}:`, error);
        return '';
      }
    })
    .filter(url => url.length > 0);
}

// VidSrc-specific helper functions
export function buildVidSrcMovieUrlWithSubtitle(mediaId: string, subtitleLanguage?: string): string {
  const params: Record<string, string> = {
    autoplay: '1',
  };
  
  if (subtitleLanguage) {
    params.ds_lang = subtitleLanguage;
  }
  
  return buildMovieUrlWithParams(VideoServerType.VIDSRC, mediaId, params);
}

export function buildVidSrcTvUrlWithSubtitle(
  mediaId: string,
  season: number,
  episode: number,
  subtitleLanguage?: string,
  autonext = false
): string {
  const params: Record<string, string> = {
    autoplay: '1',
    autonext: autonext ? '1' : '0',
  };
  
  if (subtitleLanguage) {
    params.ds_lang = subtitleLanguage;
  }
  
  return buildTvUrlWithParams(VideoServerType.VIDSRC, mediaId, season, episode, params);
}

export function buildVidSrcUrlWithCustomSubtitle(
  mediaId: string,
  season: number | null,
  episode: number | null,
  subtitleUrl: string,
  subtitleLanguage?: string
): string {
  const params: Record<string, string> = {
    autoplay: '1',
    sub_url: subtitleUrl,
  };
  
  if (subtitleLanguage) {
    params.ds_lang = subtitleLanguage;
  }

  if (season !== null && episode !== null) {
    return buildTvUrlWithParams(VideoServerType.VIDSRC, mediaId, season, episode, params);
  } else {
    return buildMovieUrlWithParams(VideoServerType.VIDSRC, mediaId, params);
  }
}
