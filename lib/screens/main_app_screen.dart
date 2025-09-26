import 'package:flutter/material.dart';
import 'package:movora/widgets/app_drawer.dart';
import 'package:movora/screens/home_screen.dart';
import 'package:movora/screens/bollywood_screen.dart';
import 'package:movora/screens/korean_screen.dart';
import 'package:movora/screens/netflix_screen.dart';
import 'package:movora/screens/prime_screen.dart';
import 'package:movora/screens/animated_screen.dart';
import 'package:movora/theme/app_theme.dart';
import 'package:movora/services/mixpanel_service.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  // Lazy loading for screens
  final List<Widget?> _screens = List.filled(6, null);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Initialize first screen immediately
    _screens[0] = const HomeScreen();

    // Track app launch
    MixpanelService.trackAppLaunch();
    MixpanelService.trackScreenView('Main App Screen');
  }

  // Removed heavy analytics and update services for better performance

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });

    // Track category view
    final categoryNames = [
      'Hollywood',
      'Bollywood',
      'Korean',
      'Netflix',
      'Prime',
      'Animated'
    ];
    MixpanelService.trackCategoryView(categoryNames[index], 'Category');

    // Lazy load screen if not already loaded
    if (_screens[index] == null) {
      _screens[index] = _getScreenForIndex(index);
    }

    _pageController.jumpToPage(index); // Use jumpToPage for instant switching
  }

  Widget _getScreenForIndex(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const BollywoodScreen();
      case 2:
        return const KoreanScreen();
      case 3:
        return const NetflixScreen();
      case 4:
        return const PrimeScreen();
      case 5:
        return const AnimatedScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: 6,
        itemBuilder: (context, index) {
          // Lazy load screens
          if (_screens[index] == null) {
            _screens[index] = _getScreenForIndex(index);
          }
          return _screens[index]!;
        },
      ),
      drawer: const AppDrawer(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home, 'Hollywood'),
                _buildNavItem(
                    1, Icons.movie_outlined, Icons.movie, 'Bollywood'),
                _buildNavItem(
                    2, Icons.language_outlined, Icons.language, 'Korean'),
                _buildNavItem(3, Icons.tv_outlined, Icons.tv, 'Netflix'),
                _buildNavItem(
                    4, Icons.play_circle_outline, Icons.play_circle, 'Prime'),
                _buildNavItem(
                    5, Icons.animation_outlined, Icons.animation, 'Animated'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData outlineIcon, IconData filledIcon, String label) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.2)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? filledIcon : outlineIcon,
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.textSecondaryColor,
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondaryColor,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
