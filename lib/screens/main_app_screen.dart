import 'package:flutter/material.dart';
import 'package:movora/services/user_analytics_service.dart';
import 'package:movora/services/update_service.dart';
import 'package:movora/widgets/app_drawer.dart';
import 'package:movora/screens/home_screen.dart';
import 'package:movora/screens/bollywood_screen.dart';
import 'package:movora/screens/korean_screen.dart';
import 'package:movora/screens/netflix_screen.dart';
import 'package:movora/screens/prime_screen.dart';
import 'package:movora/screens/animated_screen.dart';
import 'package:movora/theme/app_theme.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _trackScreenView();
    _trackFeatureUsage();

    // Check for app updates
    _checkForUpdates();
  }

  void _trackScreenView() {
    UserAnalyticsService.trackScreenView(
      screenName: 'main_app',
      screenClass: 'MainAppScreen',
    );
  }

  void _trackFeatureUsage() {
    UserAnalyticsService.trackFeatureUsage(
      featureName: 'main_app_navigation',
      category: 'navigation',
    );
  }

  /// Check for app updates
  Future<void> _checkForUpdates() async {
    // Delay to ensure the app is fully loaded
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      final updateInfo = await UpdateService.checkForUpdate(context);
      if (updateInfo != null && updateInfo.isUpdateAvailable) {
        await UpdateService.showUpdateDialog(context, updateInfo);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // Track tab navigation
    final tabNames = [
      'home',
      'bollywood',
      'korean',
      'netflix',
      'prime',
      'animated'
    ];
    if (index < tabNames.length) {
      UserAnalyticsService.trackFeatureUsage(
        featureName: 'tab_navigation',
        category: 'navigation',
        additionalParams: {
          'tab_name': tabNames[index],
          'tab_index': index,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          HomeScreen(),
          BollywoodScreen(),
          KoreanScreen(),
          NetflixScreen(),
          PrimeScreen(),
          AnimatedScreen(),
        ],
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: AppTheme.surfaceColor,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondaryColor,
        selectedLabelStyle: AppTheme.labelMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTheme.labelMedium,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.movie),
            label: 'Bollywood',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.language),
            label: 'Korean',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tv),
            label: 'Netflix',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle),
            label: 'Prime',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.animation),
            label: 'Animated',
          ),
        ],
      ),
    );
  }
}
