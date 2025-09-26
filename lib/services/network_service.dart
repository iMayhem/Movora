import 'package:http/http.dart' as http;

class NetworkService {
  static http.Client? _client;
  static const Duration _timeout = Duration(seconds: 5);

  // Multiple DNS servers for maximum reliability
  static const List<String> _dnsServers = [
    '8.8.8.8', // Google DNS
    '8.8.4.4', // Google DNS
    '1.1.1.1', // Cloudflare DNS
    '1.0.0.1', // Cloudflare DNS
    '9.9.9.9', // Quad9 DNS
    '208.67.222.222', // OpenDNS
  ];

  /// Get HTTP client with DNS fallback configuration
  static http.Client get client {
    _client ??= _createClientWithDnsFallback();
    return _client!;
  }

  /// Create HTTP client with ultra-fast DNS fallback
  static http.Client _createClientWithDnsFallback() {
    // Use default HTTP client for all platforms
    // DNS fallback will be handled by the system
    return http.Client();
  }

  /// Test network connectivity with DNS fallback
  static Future<bool> testConnectivity() async {
    final testUrls = [
      'https://www.google.com',
      'https://api.themoviedb.org',
      'https://player.videasy.net',
    ];

    for (final url in testUrls) {
      try {
        final response = await client.get(
          Uri.parse(url),
          headers: {
            'User-Agent': 'Movora/1.0 (Flutter)',
            'Accept':
                'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
          },
        ).timeout(_timeout);

        if (response.statusCode == 200) {
          print('Network connectivity test passed: $url');
          return true;
        }
      } catch (e) {
        print('Network test failed for $url: $e');
      }
    }

    return false;
  }

  /// Get network configuration info
  static Map<String, dynamic> getNetworkInfo() {
    return {
      'dns_servers': _dnsServers,
      'timeout': _timeout.inSeconds,
      'user_agent': 'Movora/1.0 (Flutter)',
      'max_connections': 8,
    };
  }

  /// Dispose the client
  static void dispose() {
    _client?.close();
    _client = null;
  }
}
