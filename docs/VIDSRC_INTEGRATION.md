# VidSrc Integration Guide

## Overview

VidSrc.xyz has been successfully integrated as the third video server in the Movora multi-server system. VidSrc offers unique features including advanced subtitle support and flexible URL parameters.

## VidSrc Server Details

### Base Configuration
- **Name**: VidSrc
- **Base URL**: `https://vidsrc.xyz`
- **Priority**: 3 (tertiary fallback)
- **Status**: Active by default

### URL Structure
VidSrc uses a different URL format compared to other servers:

#### Movies
```
https://vidsrc.xyz/embed/movie/{id}?autoplay=1&ds_lang=en
```

#### TV Shows
```
https://vidsrc.xyz/embed/tv/{id}/{season}-{episode}?autoplay=1&autonext=0&ds_lang=en
```

## Key Features

### 1. Subtitle Support
- **Default Language**: English (`ds_lang=en`)
- **ISO639 Language Codes**: Supports standard language codes (e.g., `es`, `fr`, `de`)
- **Custom Subtitle URLs**: External `.srt` or `.vtt` files with CORS support

### 2. Playback Controls
- **Autoplay**: `autoplay=1` (default enabled)
- **Auto-next Episode**: `autonext=0` (default disabled for TV shows)

### 3. ID Format Support
- **TMDB IDs**: Direct support (e.g., `385687`)
- **IMDB IDs**: Direct support (e.g., `tt5433140`)

## Implementation Examples

### Basic Usage

#### Flutter
```dart
// Basic movie URL
String url = VideoServerConfig.buildMovieUrlWithParams(
  VideoServerType.vidsrc, 
  '385687'
);

// Movie with Spanish subtitles
String url = VideoServerConfig.buildVidSrcMovieUrlWithSubtitle(
  '385687',
  subtitleLanguage: 'es'
);

// TV show with French subtitles and autonext
String url = VideoServerConfig.buildVidSrcTvUrlWithSubtitle(
  '1399',
  1,
  1,
  subtitleLanguage: 'fr',
  autonext: true
);
```

#### Web/TypeScript
```typescript
// Basic movie URL
const url = buildMovieUrlWithParams(VideoServerType.VIDSRC, '385687');

// Movie with Spanish subtitles
const url = buildVidSrcMovieUrlWithSubtitle('385687', 'es');

// TV show with French subtitles and autonext
const url = buildVidSrcTvUrlWithSubtitle('1399', 1, 1, 'fr', true);
```

### Advanced Usage with Custom Subtitles

#### Flutter
```dart
// Custom subtitle URL for movie
String url = VideoServerConfig.buildVidSrcUrlWithCustomSubtitle(
  '385687',
  null, // No season for movies
  null, // No episode for movies
  'https://example.com/subtitles.srt',
  subtitleLanguage: 'en'
);

// Custom subtitle URL for TV show
String url = VideoServerConfig.buildVidSrcUrlWithCustomSubtitle(
  '1399',
  1, // Season
  1, // Episode
  'https://example.com/episode-subtitles.vtt',
  subtitleLanguage: 'es'
);
```

#### Web/TypeScript
```typescript
// Custom subtitle URL for movie
const url = buildVidSrcUrlWithCustomSubtitle(
  '385687',
  null, // No season for movies
  null, // No episode for movies
  'https://example.com/subtitles.srt',
  'en'
);

// Custom subtitle URL for TV show
const url = buildVidSrcUrlWithCustomSubtitle(
  '1399',
  1, // Season
  1, // Episode
  'https://example.com/episode-subtitles.vtt',
  'es'
);
```

## Parameter Reference

### Standard Parameters
| Parameter | Values | Default | Description |
|-----------|--------|---------|-------------|
| `autoplay` | `1`, `0` | `1` | Enable/disable autoplay |
| `autonext` | `1`, `0` | `0` | Auto-play next episode (TV only) |
| `ds_lang` | ISO639 code | `en` | Default subtitle language |
| `sub_url` | URL-encoded URL | - | Custom subtitle file URL |

### Language Codes (ISO639)
Common language codes supported:
- `en` - English
- `es` - Spanish
- `fr` - French
- `de` - German
- `it` - Italian
- `pt` - Portuguese
- `ru` - Russian
- `ja` - Japanese
- `ko` - Korean
- `zh` - Chinese

## Integration Benefits

### 1. Enhanced Accessibility
- Multiple subtitle language options
- Custom subtitle file support
- Better international user experience

### 2. Improved Reliability
- Third fallback option for content
- Different content library than other servers
- Alternative when primary servers fail

### 3. Advanced Features
- Autonext episode control
- Fine-grained playback settings
- Flexible parameter configuration

## Error Handling

### Network Errors
- Automatic fallback to next server
- Graceful degradation if VidSrc unavailable
- User notification of server switches

### Content Errors
- Handles missing content gracefully
- Supports both TMDB and IMDB ID formats
- Proper error logging for debugging

## Testing Scenarios

### 1. Basic Functionality
- [ ] Movie playback with default settings
- [ ] TV show playback with default settings
- [ ] Server switching functionality

### 2. Subtitle Features
- [ ] Default English subtitles
- [ ] Custom language subtitles
- [ ] Custom subtitle URL loading

### 3. Parameter Testing
- [ ] Autoplay enable/disable
- [ ] Autonext enable/disable for TV shows
- [ ] Invalid language code handling

### 4. Error Scenarios
- [ ] Network failure fallback
- [ ] Invalid content ID handling
- [ ] Custom subtitle URL CORS issues

## Future Enhancements

### Planned Features
1. **User Language Preferences**: Remember user's preferred subtitle language
2. **Subtitle Quality Selection**: Multiple subtitle quality options
3. **Offline Subtitle Support**: Download subtitles for offline viewing
4. **Subtitle Synchronization**: Auto-adjust subtitle timing

### API Integration
1. **Latest Content API**: Integration with VidSrc's latest content endpoints
2. **Content Availability Check**: Verify content availability before loading
3. **Quality Selection**: Multiple video quality options

## Troubleshooting

### Common Issues
1. **Subtitles Not Loading**: Check CORS settings on subtitle URLs
2. **Content Not Found**: Verify content ID format (TMDB vs IMDB)
3. **Autoplay Not Working**: Check browser autoplay policies

### Debug Information
- Check browser console for network errors
- Verify URL parameters are correctly formatted
- Test subtitle URLs independently
- Monitor server response times

## Security Considerations

### Subtitle URLs
- Only allow HTTPS subtitle URLs
- Validate subtitle file formats
- Implement CORS policy checks
- Sanitize user-provided URLs

### Content Security
- Validate content IDs before use
- Implement rate limiting
- Monitor for malicious subtitle files
- Regular security updates


