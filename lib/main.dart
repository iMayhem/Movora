import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:movora/providers/movie_provider.dart';
import 'package:movora/screens/home_screen.dart';
import 'package:movora/theme/app_theme.dart';
import 'package:movora/screens/search_screen.dart';
import 'package:movora/screens/category_screen.dart';
import 'package:movora/screens/detail_screen.dart';
import 'package:movora/screens/video_player_screen.dart';
import 'package:movora/screens/main_app_screen.dart';
import 'package:movora/models/media.dart';
import 'package:movora/services/adult_filter_service.dart';
import 'package:movora/services/image_quality_service.dart';
import 'package:movora/config/runtime_flags.dart';
import 'package:movora/services/user_analytics_service.dart';
import 'package:movora/config/performance_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Performance optimization: Configure image cache
  PaintingBinding.instance.imageCache.maximumSize =
      PerformanceConfig.imageCacheSize * 1024 * 1024;
  PaintingBinding.instance.imageCache.maximumSizeBytes =
      PerformanceConfig.imageCacheSize * 1024 * 1024;

  // Initialize adult filter service
  await AdultFilterService.initialize();

  // Initialize image quality service and sync low data flag into model bridge
  await ImageQualityService.initialize();
  RuntimeFlags.setLowData(ImageQualityService.isLowDataEnabled);

  runApp(const MovoraApp());
}

class MovoraApp extends StatelessWidget {
  const MovoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MovieProvider()),
      ],
      child: MaterialApp(
        title: 'Movora',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        // Performance optimization: Reduce unnecessary rebuilds
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              // Performance optimization: Disable unnecessary features
              accessibleNavigation: false,
              highContrast: false,
            ),
            child: child!,
          );
        },
        routes: {
          '/': (context) => const MainAppScreen(),
          '/main': (context) => const MainAppScreen(),
          '/search': (context) => const SearchScreen(),
        },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/main-app':
              return MaterialPageRoute(
                builder: (context) => const MainAppScreen(),
              );
            case '/category':
              final args = settings.arguments as Map<String, dynamic>?;
              Map<String, String> apiParams = <String, String>{};
              if (args?['apiParams'] != null) {
                try {
                  final rawParams = args!['apiParams'] as Map;
                  apiParams = rawParams.map<String, String>((key, value) =>
                      MapEntry(key.toString(), value.toString()));
                } catch (e) {
                  print('Error converting apiParams: $e');
                  apiParams = <String, String>{};
                }
              }
              return MaterialPageRoute(
                builder: (context) => CategoryScreen(
                  title: args?['title'] ?? 'Category',
                  categoryType: args?['categoryType'] ?? 'trending',
                  apiParams: apiParams,
                ),
              );
            case '/detail':
              final args = settings.arguments;
              if (args is Media) {
                return MaterialPageRoute(
                  builder: (context) => DetailScreen(
                    media: args,
                  ),
                );
              }
              return MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              );
            case '/video-player':
              final args = settings.arguments as Map<String, dynamic>?;
              return MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(
                  media: args?['media'],
                  season: args?['episode'],
                  episode: args?['episode'],
                ),
              );
            default:
              return MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              );
          }
        },
      ),
    );
  }
}
