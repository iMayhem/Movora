class VidPlusService {
  static const String _baseUrl = 'https://player.vidplus.to/embed';

  /// Generate VidPlus movie URL
  static String buildMovieUrl(int tmdbId) {
    return '$_baseUrl/movie/$tmdbId';
  }

  /// Generate VidPlus TV show URL
  static String buildTvUrl(int tmdbId, int season, int episode) {
    return '$_baseUrl/tv/$tmdbId/$season/$episode';
  }

  /// Generate VidPlus anime URL
  static String buildAnimeUrl(int anilistId, int episodeNumber,
      {bool dub = false}) {
    return '$_baseUrl/anime/$anilistId/$episodeNumber?dub=${dub ? 'true' : 'false'}';
  }

  /// Build complete iframe HTML for VidPlus player
  static String buildIframeHtml({
    required String src,
    bool allowFullscreen = true,
    bool allowAutoplay = true,
    bool allowPictureInPicture = true,
    Map<String, String>? additionalAttributes,
  }) {
    final attributes = <String, String>{
      'src': src,
      'frameborder': '0',
      'allowfullscreen': allowFullscreen ? 'true' : 'false',
      'allow': _buildAllowAttribute(allowAutoplay, allowPictureInPicture),
      'webkitallowfullscreen': 'true',
      'mozallowfullscreen': 'true',
      'style': '''
        width: 100%;
        height: 100%;
        border: none;
        background: #000;
        position: absolute;
        top: 0;
        left: 0;
      ''',
      ...?additionalAttributes,
    };

    final attributeString =
        attributes.entries.map((e) => '${e.key}="${e.value}"').join(' ');

    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>VidPlus Player</title>
        <style>
          * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
          }
          
          body {
            background: #000;
            overflow: hidden;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
          }
          
          .player-container {
            position: relative;
            width: 100vw;
            height: 100vh;
            background: #000;
          }
          
          .loading {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: #fff;
            text-align: center;
            z-index: 10;
          }
          
          .spinner {
            width: 40px;
            height: 40px;
            border: 3px solid #333;
            border-top: 3px solid #fff;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin: 0 auto 20px;
          }
          
          @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
          }
          
          .error {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: #ff4444;
            text-align: center;
            z-index: 10;
          }
          
          .retry-btn {
            background: #007bff;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            margin-top: 10px;
          }
          
          .retry-btn:hover {
            background: #0056b3;
          }
        </style>
      </head>
      <body>
        <div class="player-container">
          <div class="loading" id="loading">
            <div class="spinner"></div>
            <div>Loading VidPlus Player...</div>
          </div>
          <div class="error" id="error" style="display: none;">
            <div>Failed to load video player</div>
            <button class="retry-btn" onclick="retryLoad()">Retry</button>
          </div>
          <iframe 
            $attributeString
            onload="hideLoading()"
            onerror="showError()"
            id="player">
          </iframe>
        </div>
        
        <script>
          function hideLoading() {
            const loading = document.getElementById('loading');
            if (loading) {
              loading.style.display = 'none';
            }
          }
          
          function showError() {
            const loading = document.getElementById('loading');
            const error = document.getElementById('error');
            if (loading) loading.style.display = 'none';
            if (error) error.style.display = 'block';
          }
          
          function retryLoad() {
            const loading = document.getElementById('loading');
            const error = document.getElementById('error');
            const iframe = document.getElementById('player');
            
            if (loading) loading.style.display = 'block';
            if (error) error.style.display = 'none';
            if (iframe) {
              iframe.src = iframe.src;
            }
          }
          
          // Prevent context menu
          document.addEventListener('contextmenu', function(e) {
            e.preventDefault();
          });
          
          // Prevent text selection
          document.addEventListener('selectstart', function(e) {
            e.preventDefault();
          });
          
          // Handle fullscreen changes
          document.addEventListener('fullscreenchange', function() {
            console.log('Fullscreen changed');
          });
          
          // Auto-hide loading after 10 seconds
          setTimeout(function() {
            hideLoading();
          }, 10000);
        </script>
      </body>
      </html>
    ''';
  }

  /// Build allow attribute for iframe
  static String _buildAllowAttribute(bool autoplay, bool pictureInPicture) {
    final permissions = <String>[
      'fullscreen',
      if (autoplay) 'autoplay',
      if (pictureInPicture) 'picture-in-picture',
    ];
    return permissions.join('; ');
  }

  /// Generate complete HTML page for VidPlus player
  static String buildMoviePlayerHtml(int tmdbId) {
    final url = buildMovieUrl(tmdbId);
    return buildIframeHtml(src: url);
  }

  /// Generate complete HTML page for VidPlus TV player
  static String buildTvPlayerHtml(int tmdbId, int season, int episode) {
    final url = buildTvUrl(tmdbId, season, episode);
    return buildIframeHtml(src: url);
  }

  /// Generate complete HTML page for VidPlus anime player
  static String buildAnimePlayerHtml(int anilistId, int episodeNumber,
      {bool dub = false}) {
    final url = buildAnimeUrl(anilistId, episodeNumber, dub: dub);
    return buildIframeHtml(src: url);
  }

  /// Validate TMDB ID
  static bool isValidTmdbId(int? id) {
    return id != null && id > 0;
  }

  /// Validate season and episode numbers
  static bool isValidSeasonEpisode(int? season, int? episode) {
    return season != null && season > 0 && episode != null && episode > 0;
  }

  /// Get player info for debugging
  static Map<String, dynamic> getPlayerInfo({
    required int tmdbId,
    String? mediaType,
    int? season,
    int? episode,
  }) {
    String url;
    String type;

    if (mediaType == 'tv' && season != null && episode != null) {
      url = buildTvUrl(tmdbId, season, episode);
      type = 'TV Show';
    } else {
      url = buildMovieUrl(tmdbId);
      type = 'Movie';
    }

    return {
      'tmdbId': tmdbId,
      'type': type,
      'url': url,
      'season': season,
      'episode': episode,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
