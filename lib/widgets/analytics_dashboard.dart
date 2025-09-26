import 'package:flutter/material.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:movora/theme/app_theme.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard> {
  bool _isLoading = true;
  Map<String, dynamic> _analyticsData = {};

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get basic analytics data
      // final analytics = FirebaseAnalytics.instance; // This variable is unused, but the class is imported.

      // Note: Firebase Analytics data is typically viewed in the Firebase Console
      // This widget provides a basic interface for viewing some metrics

      setState(() {
        _analyticsData = {
          'app_name': 'Movora',
          'platform': 'Flutter',
          'version': '1.0.0',
          'note': 'Mock analytics for web compatibility',
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _analyticsData = {
          'error': 'Failed to load analytics: $e',
        };
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        title: const Text(
          'Analytics Dashboard',
          style: TextStyle(
            color: AppTheme.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withValues(alpha: 0.1),
                          AppTheme.primaryColor.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.analytics,
                          size: 48,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'App Analytics',
                          style: AppTheme.headlineMedium.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Track your app usage and user engagement',
                          style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Analytics Info
                  Text(
                    'Analytics Information',
                    style: AppTheme.headlineSmall.copyWith(
                      color: AppTheme.textPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // App Details
                  _buildInfoCard(
                    title: 'App Details',
                    icon: Icons.info,
                    children: [
                      _buildInfoRow(
                          'App Name', _analyticsData['app_name'] ?? 'N/A'),
                      _buildInfoRow(
                          'Platform', _analyticsData['platform'] ?? 'N/A'),
                      _buildInfoRow(
                          'Version', _analyticsData['version'] ?? 'N/A'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Firebase Console Link
                  _buildInfoCard(
                    title: 'Detailed Analytics',
                    icon: Icons.link,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'View comprehensive analytics in the Firebase Console',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () {
                                // You can add a link to your Firebase Console here
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Open Firebase Console to view detailed analytics'),
                                    backgroundColor: AppTheme.primaryColor,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.open_in_new),
                              label: const Text('Open Firebase Console'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // What's Tracked
                  _buildInfoCard(
                    title: 'What We Track',
                    icon: Icons.track_changes,
                    children: [
                      _buildInfoRow(
                          'User Sign-ins', 'Anonymous and Google sign-ins'),
                      _buildInfoRow(
                          'Screen Views', 'All app screens and navigation'),
                      _buildInfoRow('Content Interactions',
                          'Movie/TV show views and interactions'),
                      _buildInfoRow(
                          'Search Queries', 'User search terms and patterns'),
                      _buildInfoRow(
                          'App Sessions', 'Start and end of app usage'),
                      _buildInfoRow('Feature Usage',
                          'Which app features are most popular'),
                      _buildInfoRow(
                          'Error Tracking', 'App crashes and error events'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Privacy Note
                  _buildInfoCard(
                    title: 'Privacy & Data',
                    icon: Icons.privacy_tip,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'We only collect anonymous usage data to improve your app experience. '
                          'No personal information is tracked or stored.',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.surfaceColor.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.textPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
