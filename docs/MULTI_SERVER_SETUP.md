# Multi-Server Video Player Setup

## Overview

The Movora app now supports multiple video streaming servers to provide better reliability and more content options. Users can switch between different servers if one fails or doesn't have the content they're looking for.

## Supported Servers

### 1. VIDEASY (Primary)
- **URL**: `https://player.videasy.net`
- **Movies**: `https://player.videasy.net/movie/{id}`
- **TV Shows**: `https://player.videasy.net/tv/{id}/{season}/{episode}`
- **Features**: Full player controls, episode selector, autoplay next episode
- **Priority**: 1 (highest)

### 2. 111Movies (Secondary)
- **URL**: `https://111movies.com`
- **Movies**: `https://111movies.com/movie/{id}`
- **TV Shows**: `https://111movies.com/tv/{id}/{season}/{episode}`
- **Features**: Basic streaming, IMDB ID support
- **Priority**: 2

### 3. VidSrc (Tertiary)
- **URL**: `https://vidsrc.xyz`
- **Movies**: `https://vidsrc.xyz/embed/movie/{id}`
- **TV Shows**: `https://vidsrc.xyz/embed/tv/{id}/{season}-{episode}`
- **Features**: Subtitle support, autoplay, autonext, custom subtitle URLs
- **Priority**: 3

## Implementation Details

### Flutter App (`lib/config/video_server_config.dart`)

The Flutter app uses a centralized configuration system:

```dart
enum VideoServerType {
  videasy,
  movies111,
  vidsrc,
}

class VideoServerConfig {
  static String buildMovieUrl(VideoServerType serverType, String mediaId);
  static String buildTvUrl(VideoServerType serverType, String mediaId, int season, int episode);
  static List<String> buildAllMovieUrls(String mediaId);
  static List<String> buildAllTvUrls(String mediaId, int season, int episode);
}
```

### Web App (`src/lib/video-servers.ts`)

The web app uses TypeScript interfaces and utility functions:

```typescript
export enum VideoServerType {
  VIDEASY = 'videasy',
  MOVIES111 = 'movies111',
  VIDSRC = 'vidsrc',
}

export function buildMovieUrl(serverType: VideoServerType, mediaId: string): string;
export function buildTvUrl(serverType: VideoServerType, mediaId: string, season: number, episode: number): string;
```

## User Interface

### Flutter Mobile App
- **Server Selection**: Popup menu in video player overlay
- **Server Indicator**: Shows current server in error states
- **Automatic Fallback**: Switches to next server on error
- **Manual Switching**: Users can manually select servers

### Web App
- **Server Selector**: Dropdown in video player dialog
- **Server Indicator**: Shows current server name in player
- **Automatic Fallback**: Switches to next server on error
- **Manual Switching**: Users can manually select servers

## Automatic Fallback Logic

Both platforms implement automatic fallback:

1. **Error Detection**: Monitors for network errors and player failures
2. **Server Switching**: Automatically tries the next available server
3. **User Notification**: Shows which server is being used
4. **Manual Override**: Users can still manually switch servers

## URL Format Handling

### Movie URLs
- **VIDEASY**: `https://player.videasy.net/movie/{tmdb_id}?color=8B5CF6&autoplay=true...`
- **111Movies**: `https://111movies.com/movie/{id}` (supports both TMDB and IMDB IDs)
- **VidSrc**: `https://vidsrc.xyz/embed/movie/{id}?autoplay=1&ds_lang=en`

### TV Show URLs
- **VIDEASY**: `https://player.videasy.net/tv/{tmdb_id}/{season}/{episode}?color=8B5CF6...`
- **111Movies**: `https://111movies.com/tv/{id}/{season}/{episode}`
- **VidSrc**: `https://vidsrc.xyz/embed/tv/{id}/{season}-{episode}?autoplay=1&autonext=0&ds_lang=en`

### ID Format Conversion
The system handles ID format differences:
- **TMDB IDs**: Used directly (e.g., `533535`)
- **IMDB IDs**: Used with 'tt' prefix (e.g., `tt6263850`)
- **111Movies**: Attempts to use TMDB IDs directly, falls back gracefully

## Error Handling

### Network Errors
- **ERR_FAILED**: Automatically switches to next server
- **Timeout Errors**: Retries with different server
- **CORS Issues**: Handled by proper iframe permissions

### Content Errors
- **404 Not Found**: Tries next server
- **Geographic Restrictions**: Switches to alternative server
- **Server Maintenance**: Automatic fallback

## Configuration

### Adding New Servers

#### Flutter App
1. Add new server type to `VideoServerType` enum
2. Add server configuration to `_servers` list in `VideoServerConfig`
3. Implement URL building logic in `buildMovieUrl`/`buildTvUrl`
4. Update navigation delegate to allow new domains

#### Web App
1. Add new server type to `VideoServerType` enum
2. Add server configuration to `VIDEO_SERVERS` array
3. Implement URL building logic in `buildMovieUrl`/`buildTvUrl`
4. Update iframe permissions if needed

### Server Priority
Servers are ordered by priority (lower number = higher priority):
1. **Priority 1**: VIDEASY (primary)
2. **Priority 2**: 111Movies (fallback)
3. **Priority 3**: VidSrc (tertiary with subtitle support)

## VidSrc-Specific Features

VidSrc offers advanced features not available in other servers:

### Subtitle Support
- **Default Language**: English (`ds_lang=en`)
- **Custom Languages**: Support for ISO639 language codes
- **Custom Subtitle URLs**: External `.srt` or `.vtt` files with CORS support

### Helper Functions

#### Flutter
```dart
// Movie with subtitle
String url = VideoServerConfig.buildVidSrcMovieUrlWithSubtitle(
  mediaId, 
  subtitleLanguage: 'es'
);

// TV show with subtitle and autonext
String url = VideoServerConfig.buildVidSrcTvUrlWithSubtitle(
  mediaId, 
  season, 
  episode,
  subtitleLanguage: 'fr',
  autonext: true
);

// Custom subtitle URL
String url = VideoServerConfig.buildVidSrcUrlWithCustomSubtitle(
  mediaId,
  season,
  episode,
  'https://example.com/subtitle.srt',
  subtitleLanguage: 'en'
);
```

#### Web/TypeScript
```typescript
// Movie with subtitle
const url = buildVidSrcMovieUrlWithSubtitle(mediaId, 'es');

// TV show with subtitle and autonext
const url = buildVidSrcTvUrlWithSubtitle(mediaId, season, episode, 'fr', true);

// Custom subtitle URL
const url = buildVidSrcUrlWithCustomSubtitle(
  mediaId,
  season,
  episode,
  'https://example.com/subtitle.srt',
  'en'
);
```

### VidSrc Parameters
- **autoplay**: `1` or `0` (default: `1`)
- **autonext**: `1` or `0` (default: `0`)
- **ds_lang**: ISO639 language code (e.g., `en`, `es`, `fr`)
- **sub_url**: URL-encoded subtitle file URL

### Enabling/Disabling Servers
Set `isActive: false` in server configuration to disable a server without removing it from the code.

## Testing

### Manual Testing
1. **Server Switching**: Test manual server selection
2. **Automatic Fallback**: Simulate network errors
3. **Content Availability**: Test with different movies/shows
4. **Cross-Platform**: Verify both Flutter and web work

### Error Scenarios
1. **Network Disconnection**: Should switch to next server
2. **Server Downtime**: Should handle gracefully
3. **Invalid Content IDs**: Should show appropriate errors
4. **Geographic Restrictions**: Should try alternative servers

## Performance Considerations

### Caching
- Server configurations are cached in memory
- URL building is optimized for performance
- No unnecessary API calls for server switching

### Network Efficiency
- Only loads one server at a time
- Automatic fallback prevents unnecessary retries
- Proper error handling reduces bandwidth usage

## Future Enhancements

### Planned Features
1. **Server Health Monitoring**: Check server status before loading
2. **User Preferences**: Remember preferred server per user
3. **Content Availability API**: Check which servers have specific content
4. **Quality Selection**: Allow users to choose video quality per server
5. **Analytics**: Track server usage and performance metrics

### Additional Servers
- **Netflix Proxy**: For Netflix content (if available)
- **Disney+ Proxy**: For Disney+ content (if available)
- **Amazon Prime**: For Prime Video content (if available)

## Troubleshooting

### Common Issues
1. **Server Not Loading**: Check network connectivity and server status
2. **Content Not Available**: Try different server or check content ID format
3. **Automatic Fallback Not Working**: Verify server configuration and error handling

### Debug Information
- Check browser console for network errors
- Monitor Flutter logs for WebView errors
- Verify server URLs are correctly formatted
- Test with different content IDs

## Security Considerations

### Domain Allowlists
- Only allowlisted domains can be used for video streaming
- External domains are blocked by navigation delegates
- CORS policies are properly configured

### Content Security
- Iframe sandbox restrictions prevent malicious content
- Server validation ensures only trusted sources
- Error handling prevents information leakage
