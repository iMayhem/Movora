import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:flutter/foundation.dart';

class MixpanelService {
  static Mixpanel? _mixpanel;
  static const String _projectToken = '0fb0cfaf9cdd73de9fcb6112b5338aa3';

  /// Initialize Mixpanel
  static Future<void> initialize() async {
    try {
      _mixpanel =
          await Mixpanel.init(_projectToken, trackAutomaticEvents: true);
      if (kDebugMode) {
        print('Mixpanel initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Mixpanel: $e');
      }
    }
  }

  /// Track screen views
  static void trackScreenView(String screenName,
      {Map<String, dynamic>? properties}) {
    try {
      _mixpanel?.track('Screen View', properties: {
        'Screen Name': screenName,
        ...?properties,
      });
      if (kDebugMode) {
        print('Tracked screen view: $screenName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error tracking screen view: $e');
      }
    }
  }

  /// Track video plays
  static void trackVideoPlay({
    required String mediaType,
    required String mediaTitle,
    required int? mediaId,
    String? season,
    String? episode,
  }) {
    try {
      _mixpanel?.track('Video Play', properties: {
        'Media Type': mediaType,
        'Media Title': mediaTitle,
        'Media ID': mediaId,
        if (season != null) 'Season': season,
        if (episode != null) 'Episode': episode,
        'Timestamp': DateTime.now().toIso8601String(),
      });
      if (kDebugMode) {
        print('Tracked video play: $mediaTitle');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error tracking video play: $e');
      }
    }
  }

  /// Track search queries
  static void trackSearch(String query, int resultCount) {
    try {
      _mixpanel?.track('Search', properties: {
        'Query': query,
        'Result Count': resultCount,
        'Timestamp': DateTime.now().toIso8601String(),
      });
      if (kDebugMode) {
        print('Tracked search: $query');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error tracking search: $e');
      }
    }
  }

  /// Track category views
  static void trackCategoryView(String categoryName, String contentType) {
    try {
      _mixpanel?.track('Category View', properties: {
        'Category': categoryName,
        'Content Type': contentType,
        'Timestamp': DateTime.now().toIso8601String(),
      });
      if (kDebugMode) {
        print('Tracked category view: $categoryName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error tracking category view: $e');
      }
    }
  }

  /// Track app launches
  static void trackAppLaunch() {
    try {
      _mixpanel?.track('App Launch', properties: {
        'Timestamp': DateTime.now().toIso8601String(),
      });
      if (kDebugMode) {
        print('Tracked app launch');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error tracking app launch: $e');
      }
    }
  }

  /// Track user engagement
  static void trackEngagement(String action,
      {Map<String, dynamic>? properties}) {
    try {
      _mixpanel?.track('User Engagement', properties: {
        'Action': action,
        'Timestamp': DateTime.now().toIso8601String(),
        ...?properties,
      });
      if (kDebugMode) {
        print('Tracked engagement: $action');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error tracking engagement: $e');
      }
    }
  }

  /// Set user properties
  static void setUserProperties(Map<String, dynamic> properties) {
    try {
      // Set each property individually
      properties.forEach((key, value) {
        _mixpanel?.getPeople().set(key, value);
      });
      if (kDebugMode) {
        print('Set user properties: $properties');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error setting user properties: $e');
      }
    }
  }

  /// Track custom events
  static void trackEvent(String eventName, {Map<String, dynamic>? properties}) {
    try {
      _mixpanel?.track(eventName, properties: {
        'Timestamp': DateTime.now().toIso8601String(),
        ...?properties,
      });
      if (kDebugMode) {
        print('Tracked custom event: $eventName');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error tracking custom event: $e');
      }
    }
  }

  /// Flush events (useful for ensuring events are sent)
  static void flush() {
    try {
      _mixpanel?.flush();
      if (kDebugMode) {
        print('Mixpanel events flushed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error flushing Mixpanel: $e');
      }
    }
  }
}
