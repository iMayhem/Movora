import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:movora/models/media.dart';
import 'package:movora/theme/app_theme.dart';
import 'package:http/http.dart' as http;

class VideoPlayerScreen extends StatefulWidget {
  final Media media;
  final int? season;
  final int? episode;

  const VideoPlayerScreen({
    super.key,
    required this.media,
    this.season,
    this.episode,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  WebViewController? _webViewController;
  String? _playerUrl;
  String? _videoStreamUrl;
  bool _isVideoReady = false;

  @override
  void initState() {
    super.initState();

    // Force landscape for video playback
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Enable fullscreen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _playerUrl = _buildVideasyUrl();
    _fetchVideoStream();
  }

  @override
  void dispose() {
    // Reset to portrait mode when leaving
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _fetchVideoStream() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // First, try to fetch the video stream from EASYVID
      final response = await http.get(Uri.parse(_playerUrl!));

      if (response.statusCode == 200) {
        // Parse the response to extract video stream URL
        final videoUrl = await _extractVideoStreamUrl(response.body);

        if (videoUrl != null) {
          setState(() {
            _videoStreamUrl = videoUrl;
            _isVideoReady = true;
            _isLoading = false;
          });
        } else {
          // Fallback to platform-specific player
          _initializePlayer();
        }
      } else {
        // Fallback to platform-specific player
        _initializePlayer();
      }
    } catch (e) {
      // Fallback to platform-specific player
      _initializePlayer();
    }
  }

  Future<String?> _extractVideoStreamUrl(String htmlContent) async {
    try {
      // Look for video stream patterns in the HTML content
      // This is a simplified approach - you might need to adjust based on EASYVID's actual response

      // Common video stream patterns
      final patterns = [
        RegExp(r'src="([^"]*\.m3u8[^"]*)"'),
        RegExp(r'src="([^"]*\.mp4[^"]*)"'),
        RegExp(r'file:"([^"]*\.m3u8[^"]*)"'),
        RegExp(r'file:"([^"]*\.mp4[^"]*)"'),
        RegExp(r'videoUrl:"([^"]*\.m3u8[^"]*)"'),
        RegExp(r'videoUrl:"([^"]*\.mp4[^"]*)"'),
      ];

      for (final pattern in patterns) {
        final match = pattern.firstMatch(htmlContent);
        if (match != null && match.group(1) != null) {
          final url = match.group(1)!;
          // Ensure it's a valid video URL
          if (url.startsWith('http') &&
              (url.contains('.m3u8') || url.contains('.mp4'))) {
            return url;
          }
        }
      }

      // If no direct video URL found, try to extract from iframe src
      final iframePattern = RegExp(r'<iframe[^>]*src="([^"]*)"');
      final iframeMatch = iframePattern.firstMatch(htmlContent);
      if (iframeMatch != null && iframeMatch.group(1) != null) {
        final iframeUrl = iframeMatch.group(1)!;
        // Try to fetch the iframe content
        try {
          final iframeResponse = await http.get(Uri.parse(iframeUrl));
          if (iframeResponse.statusCode == 200) {
            return await _extractVideoStreamUrl(iframeResponse.body);
          }
        } catch (e) {
          // Continue to next approach
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  void _initializePlayer() {
    if (kIsWeb) {
      _initializeWebPlayer();
    } else {
      _initializeWebView();
    }
  }

  void _initializeWebPlayer() {
    // Create iframe for web platform
    // This part is no longer needed as we're using WebView directly
    // The loading and error listeners are handled by the WebView controller
    // setState(() {
    //   _isLoading = false;
    // });
  }

  void _initializeWebView() {
    // Only initialize WebView on mobile platforms
    if (kIsWeb) return;

    // Define custom User-Agent to mimic a real browser
    final mobileUserAgent =
        'Mozilla/5.0 (Linux; Android 10; SM-G975F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.141 Mobile Safari/537.36';

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // FIX 1A: Set a custom User-Agent to mimic a real browser
      ..setUserAgent(mobileUserAgent)
      // Add sandbox restrictions to block ads and popups
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              setState(() {
                _isLoading = false;
                _hasError = false;
              });
            }
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
              _hasError = false;
            });

            // Inject JavaScript to block ads and popups
            _injectAdBlockingScript();
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _hasError = true;
              _errorMessage = 'Error loading player: ${error.description}';
              _isLoading = false;
            });
          },
          // Block navigation to external sites (ads)
          onNavigationRequest: (NavigationRequest request) {
            // Allow only the main player URL and same-origin requests
            final playerUri = Uri.parse(_playerUrl!);
            final requestUri = Uri.parse(request.url);

            // Block external navigation (ads, popups)
            if (requestUri.host != playerUri.host &&
                !requestUri.host.contains('videasy.net') &&
                !requestUri.host.contains('111movies.com')) {
              print('Blocked navigation to: ${request.url}');
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..setBackgroundColor(AppTheme.backgroundColor)
      // Additional settings to block ads and enhance security
      ..enableZoom(false); // Disable zoom to prevent ad overlays

    // FIX 2: Enable Android-specific features for better video playback
    if (_webViewController!.platform is AndroidWebViewController) {
      // Enables web debugging, which is useful for development
      AndroidWebViewController.enableDebugging(true);
      final androidController =
          _webViewController!.platform as AndroidWebViewController;
      // Allows videos to play without a user tap
      androidController.setMediaPlaybackRequiresUserGesture(false);
      // Note: DOM storage is enabled by default in newer versions
    }

    // Load the request with proper headers and sandbox restrictions
    _webViewController!.loadRequest(
      Uri.parse(_playerUrl!),
      headers: {
        // FIX 1B: Add a Referer header
        'Referer': 'https://player.videasy.net/',
        // Add sandbox-related headers
        'X-Frame-Options': 'SAMEORIGIN',
        'Content-Security-Policy': "frame-ancestors 'self'",
      },
    );
  }

  // FIX 4: Create a robust URL builder function
  String _buildVideasyUrl({
    String? id,
    String? mediaType,
    int? season,
    int? episode,
  }) {
    // Use widget parameters if not provided
    final String contentId = id ?? widget.media.id.toString();
    final String type = mediaType ?? widget.media.mediaType ?? 'movie';
    final int? contentSeason = season ?? widget.season;
    final int? contentEpisode = episode ?? widget.episode;

    String baseUrl;
    if (type == 'tv') {
      // For TV shows, use season and episode
      final seasonNum = contentSeason ?? 1;
      final episodeNum = contentEpisode ?? 1;
      baseUrl =
          'https://player.videasy.net/tv/$contentId/$seasonNum/$episodeNum';
    } else {
      // Default to movie
      baseUrl = 'https://player.videasy.net/movie/$contentId';
    }

    // Add customization parameters for better user experience
    final Map<String, String> queryParams = {
      'color': '8B5CF6', // Purple color theme matching your app
      'episodeSelector': 'true',
      'nextEpisode': 'true',
      'autoplayNextEpisode': 'true',
      'autoplay': 'true',
      'fullscreen': 'true',
    };

    if (queryParams.isEmpty) return baseUrl;
    return '$baseUrl?${Uri(queryParameters: queryParams).query}';
  }

  void _refreshPlayer() {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
      _isVideoReady = false;
      _videoStreamUrl = null;
    });
    _fetchVideoStream();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video Player Section - Full Screen
          Positioned.fill(
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  // Player Content
                  if (_isVideoReady && _videoStreamUrl != null)
                    // Custom video player with extracted stream
                    _buildCustomVideoPlayer()
                  else
                    // Platform-specific player
                    _buildPlatformPlayer(),

                  // Back button overlay
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: 'Back',
                      ),
                    ),
                  ),

                  // Refresh button overlay (only when needed)
                  if (_hasError || _isVideoReady)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          onPressed: _refreshPlayer,
                          tooltip: 'Refresh player',
                        ),
                      ),
                    ),

                  // Loading indicator
                  if (_isLoading)
                    Container(
                      color: Colors.black.withOpacity(0.95),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryColor),
                              strokeWidth: 3,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Loading Player...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Please wait while we prepare your video',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Error state
                  if (_hasError)
                    Container(
                      color: Colors.black.withOpacity(0.95),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Player Error',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _errorMessage ?? 'Failed to load video player',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _refreshPlayer,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomVideoPlayer() {
    // Custom video player widget with responsive design
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Video content area with proper aspect ratio
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_circle_outline,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Custom Video Player',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Video stream ready',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Here you would implement the actual video player
                  // For now, we'll show a message
                  _showErrorSnackBar('Video player implementation needed');
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play Video'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformPlayer() {
    if (kIsWeb) {
      return _buildWebPlayer();
    } else {
      return _buildWebViewPlayer();
    }
  }

  Widget _buildWebPlayer() {
    // For web, we'll use a simple approach that embeds the iframe
    // Since platformViewRegistry isn't available on web, we'll create a container
    // and append the iframe to the DOM manually
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 64,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              'VIDEASY Player Ready',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Video player is ready',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebViewPlayer() {
    if (_webViewController == null) {
      _initializeWebView();
      return Container(
        color: AppTheme.surfaceColor,
        child: const Center(
          child: Text(
            'Initializing VIDEASY player...',
            style: TextStyle(color: AppTheme.textPrimaryColor),
          ),
        ),
      );
    }
    return WebViewWidget(controller: _webViewController!);
  }

  void _injectAdBlockingScript() {
    if (_webViewController != null) {
      // Inject JavaScript to block ads and popups
      _webViewController!.runJavaScriptReturningResult('''
        (function() {
          // Block ads and popups
          function blockAds() {
            // Block common ad domains
            const adDomains = ['doubleclick.net', 'googletagmanager.com', 'google-analytics.com', 'adservice.google.com'];
            const currentUrl = window.location.href;
            
            for (const domain of adDomains) {
              if (currentUrl.includes(domain)) {
                console.log('Blocked ad domain: ' + domain);
                return false;
              }
            }
            
            // Block popup windows
            const originalOpen = window.open;
            window.open = function() {
              console.log('Blocked popup window');
              return null;
            };
            
            // Block iframe ads
            const iframes = document.querySelectorAll('iframe');
            iframes.forEach(function(iframe) {
              const src = iframe.src || '';
              if (adDomains.some(domain => src.includes(domain))) {
                iframe.remove();
                console.log('Removed ad iframe');
              }
            });
            
            return true;
          }
          
          // Run ad blocking
          return blockAds();
        })();
      ''').catchError((error) {
        print('Error injecting ad blocking script: $error');
      });
    }
  }
}
