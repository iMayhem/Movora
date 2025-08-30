import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movora/theme/app_theme.dart';
import 'package:movora/services/update_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.backgroundColor,
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // App Header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.movie,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'MOVORA',
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your ultimate destination for movies and TV shows',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(
              color: AppTheme.surfaceColor,
              height: 32,
              thickness: 1,
            ),

            // GitHub Repository Link
            _buildDrawerItem(
              icon: Icons.code,
              title: 'View on GitHub',
              onTap: () => _openGitHubRepo(),
            ),

            // Alternative GitHub Link
            _buildDrawerItem(
              icon: Icons.open_in_new,
              title: 'GitHub (Alternative)',
              onTap: () => _openGitHubAlternative(),
            ),

            // App Update Check
            _buildDrawerItem(
              icon: Icons.system_update,
              title: 'Check for Updates',
              onTap: () => _checkForUpdates(),
            ),
          ],
        ),
      ),
    );
  }

  /// Alternative method to open GitHub
  Future<void> _openGitHubAlternative() async {
    try {
      // Try different URL formats with external application only
      final urls = [
        'https://github.com/iMayhem/Movora',
        'https://www.github.com/iMayhem/Movora',
        'https://m.github.com/iMayhem/Movora',
      ];

      for (final url in urls) {
        try {
          final uri = Uri.parse(url);
          print('Trying alternative URL: $url');

          if (await canLaunchUrl(uri)) {
            final launched = await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
            if (launched) {
              print('Alternative URL launched successfully: $url');
              return;
            }
          }
        } catch (e) {
          print('Alternative URL failed: $url - $e');
          continue;
        }
      }

      // If all URLs fail, show manual copy option
      throw Exception('All alternative URLs failed');
    } catch (e) {
      print('Alternative GitHub method failed: $e');
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('GitHub Access'),
            content: const Text(
              'Unable to open GitHub automatically. You can:\n\n'
              '1. Copy the URL and paste it in your browser\n'
              '2. Search for "iMayhem Movora" on GitHub\n'
              '3. Try the main GitHub button again',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Clipboard.setData(const ClipboardData(
                      text: 'https://github.com/iMayhem/Movora'));
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('GitHub URL copied to clipboard!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text('Copy URL'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  /// Open GitHub repository
  Future<void> _openGitHubRepo() async {
    try {
      const url = 'https://github.com/iMayhem/Movora';
      final uri = Uri.parse(url);

      print('Attempting to launch GitHub URL: $url');

      // Check if URL can be launched
      final canLaunch = await canLaunchUrl(uri);
      print('Can launch URL: $canLaunch');

      if (canLaunch) {
        // Launch with external application only
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        print('Launch result: $launched');

        if (launched) {
          return; // Success!
        }
      }

      // If external launch fails, show error with copy option
      throw Exception('External launch failed');
    } catch (e) {
      print('Error launching GitHub URL: $e');
      if (mounted) {
        // Show helpful error message with copy option
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Could not open GitHub. Tap "Copy URL" to copy the link.'),
            backgroundColor: AppTheme.destructiveColor,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Copy URL',
              textColor: Colors.white,
              onPressed: () {
                Clipboard.setData(const ClipboardData(
                    text: 'https://github.com/iMayhem/Movora'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('GitHub URL copied to clipboard!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        );
      }
    }
  }

  /// Check for app updates manually
  Future<void> _checkForUpdates() async {
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Checking for updates...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    // Check for updates
    final updateInfo = await UpdateService.checkForUpdate(context);

    if (mounted) {
      if (updateInfo != null && updateInfo.isUpdateAvailable) {
        await UpdateService.showUpdateDialog(context, updateInfo);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ You have the latest version!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.primaryColor,
        size: 24,
      ),
      title: Text(
        title,
        style: AppTheme.bodyLarge.copyWith(
          color: AppTheme.textPrimaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      tileColor: Colors.transparent,
      hoverColor: AppTheme.primaryColor.withOpacity(0.1),
      selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
    );
  }
}
