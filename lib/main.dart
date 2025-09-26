import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:movora/providers/movie_provider.dart';
import 'package:movora/screens/home_screen.dart';
import 'package:movora/theme/app_theme.dart';
import 'package:movora/screens/search_screen.dart';
import 'package:movora/screens/category_screen.dart';
import 'package:movora/screens/detail_screen.dart';
import 'package:movora/widgets/native_video_player.dart';
import 'package:movora/screens/main_app_screen.dart';
import 'package:movora/models/media.dart';
import 'package:movora/services/network_service.dart';
import 'package:movora/services/mixpanel_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  PaintingBinding.instance.imageCache.maximumSize = 20; // Reduced from 50
  PaintingBinding.instance.imageCache.maximumSizeBytes =
      20 * 1024 * 1024; // Reduced from 50MB
  NetworkService.client;
  await MixpanelService.initialize();
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
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              accessibleNavigation: false,
              highContrast: false,
              disableAnimations: true,
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
          MaterialPageRoute createRoute(Widget page) {
            return MaterialPageRoute(
              builder: (context) => page,
            );
          }

          switch (settings.name) {
            case '/main-app':
              return createRoute(const MainAppScreen());
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
              return createRoute(CategoryScreen(
                title: args?['title'] ?? 'Category',
                categoryType: args?['categoryType'] ?? 'popular',
                apiParams: apiParams,
              ));
            case '/detail':
              final args = settings.arguments;
              if (args is Media) {
                return createRoute(DetailScreen(media: args));
              }
              return createRoute(const HomeScreen());
            case '/video-player':
              final args = settings.arguments as Map<String, dynamic>?;
              return createRoute(NativeVideoPlayer(
                media: args?['media'],
                season: args?['season'],
                episode: args?['episode'],
              ));
            default:
              return createRoute(const HomeScreen());
          }
        },
      ),
    );
  }
}
