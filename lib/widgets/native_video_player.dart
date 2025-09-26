import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:movora/models/media.dart';
import 'package:movora/services/vidplus_service.dart';
import 'package:movora/services/mixpanel_service.dart';

/// VidPlus Video Player Widget
///
/// Simple WebView wrapper for VidPlus player
class NativeVideoPlayer extends StatefulWidget {
  final Media media;
  final int? season;
  final int? episode;

  const NativeVideoPlayer({
    super.key,
    required this.media,
    this.season,
    this.episode,
  });

  @override
  State<NativeVideoPlayer> createState() => _NativeVideoPlayerState();
}

class _NativeVideoPlayerState extends State<NativeVideoPlayer> {
  WebViewController? _webViewController;
  String? _vidPlusUrl;

  @override
  void initState() {
    super.initState();

    MixpanelService.trackScreenView('VidPlus Player Screen', properties: {
      'Media Type': widget.media.mediaType ?? 'unknown',
      'Media Title': widget.media.displayTitle,
      'Media ID': widget.media.id,
      'Season': widget.season,
      'Episode': widget.episode,
    });

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _generateVidPlusUrl();

    // Only initialize WebView on mobile platforms
    if (!kIsWeb) {
      _initializeWebView();
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _generateVidPlusUrl() {
    if (!VidPlusService.isValidTmdbId(widget.media.id)) {
      _vidPlusUrl = null;
      return;
    }

    if (widget.media.mediaType == 'tv' &&
        widget.season != null &&
        widget.episode != null) {
      if (!VidPlusService.isValidSeasonEpisode(widget.season, widget.episode)) {
        _vidPlusUrl = null;
        return;
      }
      _vidPlusUrl = VidPlusService.buildTvUrl(
        widget.media.id!,
        widget.season!,
        widget.episode!,
      );
    } else {
      _vidPlusUrl = VidPlusService.buildMovieUrl(widget.media.id!);
    }
    print('🎬 Generated VidPlus URL: $_vidPlusUrl');
  }

  void _initializeWebView() {
    if (_vidPlusUrl == null) {
      return;
    }

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..enableZoom(false)
      ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 10; SM-G973F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('📱 Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('✅ Page finished loading: $url');
            _injectVideoEnhancementScript();
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ WebView Error: ${error.description} (${error.errorCode})');
            _handleWebViewError(error);
          },
          onNavigationRequest: (NavigationRequest request) {
            print('🌐 Navigation request: ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_vidPlusUrl!));

    if (_webViewController!.platform is AndroidWebViewController) {
      final androidController =
          _webViewController!.platform as AndroidWebViewController;
      androidController.setMediaPlaybackRequiresUserGesture(false);
      androidController.setOnShowFileSelector(_androidFileSelector);
    }
  }

  void _injectVideoEnhancementScript() {
    const script = '''
      (function() {
        console.log('🎬 Injecting video enhancement script');
        
        // Find all video elements
        const videos = document.querySelectorAll('video');
        console.log('Found ' + videos.length + ' video elements');
        
        videos.forEach((video, index) => {
          console.log('Enhancing video ' + index);
          
          // Set video properties for better playback
          video.preload = 'metadata';
          video.crossOrigin = 'anonymous';
          video.playsInline = true;
          
          // Handle seeking errors
          video.addEventListener('error', function(e) {
            console.error('Video error:', e);
            if (e.target.error && e.target.error.code === 3) {
              console.log('Seeking error detected, attempting recovery');
              setTimeout(() => {
                video.load();
              }, 1000);
            }
          });
          
          // Handle stalled playback
          video.addEventListener('stalled', function() {
            console.log('Video stalled, attempting recovery');
            setTimeout(() => {
              video.load();
            }, 2000);
          });
          
          // Handle network errors
          video.addEventListener('loadstart', function() {
            console.log('Video load started');
          });
          
          video.addEventListener('canplay', function() {
            console.log('Video can play');
          });
        });
        
        // Monitor for dynamically added videos
        const observer = new MutationObserver(function(mutations) {
          mutations.forEach(function(mutation) {
            mutation.addedNodes.forEach(function(node) {
              if (node.nodeType === 1 && node.tagName === 'VIDEO') {
                console.log('New video element detected');
                node.preload = 'metadata';
                node.crossOrigin = 'anonymous';
                node.playsInline = true;
              }
            });
          });
        });
        
        observer.observe(document.body, {
          childList: true,
          subtree: true
        });
      })();
    ''';

    _webViewController?.runJavaScript(script);
  }

  void _handleWebViewError(WebResourceError error) {
    print('❌ WebView Error Details:');
    print('  Description: ${error.description}');
    print('  Error Code: ${error.errorCode}');
    print('  Error Type: ${error.errorType}');

    // Handle specific error types
    switch (error.errorCode) {
      case -2: // ERROR_HOST_LOOKUP
        print('Network error: Host lookup failed');
        break;
      case -6: // ERROR_CONNECT
        print('Network error: Connection failed');
        break;
      case -8: // ERROR_TIMEOUT
        print('Network error: Timeout');
        break;
      case -14: // ERROR_FAILED
        print('Network error: Generic failure');
        break;
      default:
        print('Unknown error code: ${error.errorCode}');
    }
  }

  Future<List<String>> _androidFileSelector(FileSelectorParams params) async {
    return [];
  }

  @override
  Widget build(BuildContext context) {
    if (_vidPlusUrl == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 20),
              Text(
                'Invalid Video ID or details for ${widget.media.displayTitle}',
                style: const TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    // Handle web platform
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_circle_outline,
                  color: Colors.white, size: 80),
              const SizedBox(height: 16),
              const Text(
                'VidPlus Player',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Playing: ${widget.media.displayTitle}',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Video player not available on web',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please use the mobile app to watch videos',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    // Mobile platform - use WebView
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: _webViewController == null
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : WebViewWidget(controller: _webViewController!),
          ),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
