import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateService {
  // GitHub repository configuration
  // TODO: UPDATE THESE VALUES WITH YOUR ACTUAL GITHUB INFORMATION
  static const String _githubRawUrl = 'https://raw.githubusercontent.com';
  static const String _username =
      'your-username'; // ⚠️ REPLACE: Your GitHub username
  static const String _repoName =
      'movora-apk'; // ⚠️ REPLACE: Your repository name
  static const String _branch =
      'main'; // ⚠️ REPLACE: Your branch name (usually 'main' or 'master')

  // Update check configuration
  static const Duration _updateCheckInterval = Duration(hours: 24);
  static const String _lastUpdateCheckKey = 'last_update_check';

  /// Check if an update is available
  static Future<UpdateInfo?> checkForUpdate(BuildContext context) async {
    try {
      // Check if we should skip update check (rate limiting)
      if (await _shouldSkipUpdateCheck()) {
        return null;
      }

      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // Fetch latest version info from GitHub
      const versionUrl =
          '$_githubRawUrl/$_username/$_repoName/$_branch/version.json';
      final response = await http.get(Uri.parse(versionUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['latestVersion'] as String;
        final apkUrl = data['apkUrl'] as String;
        final changelog =
            data['changelog'] as String? ?? 'Bug fixes and improvements';

        // Check if update is available
        if (_isNewerVersion(latestVersion, currentVersion)) {
          // Mark that we checked for updates
          await _markUpdateCheckComplete();

          return UpdateInfo(
            currentVersion: currentVersion,
            latestVersion: latestVersion,
            apkUrl: apkUrl,
            changelog: changelog,
            isUpdateAvailable: true,
          );
        }
      }

      // Mark that we checked for updates
      await _markUpdateCheckComplete();

      return null;
    } catch (e) {
      debugPrint('UpdateService: Error checking for updates: $e');
      return null;
    }
  }

  /// Show update dialog if update is available
  static Future<void> showUpdateDialog(
      BuildContext context, UpdateInfo updateInfo) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.system_update, color: Colors.blue),
            SizedBox(width: 8),
            Text('Update Available'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A new version of Movora is available!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Current Version: ${updateInfo.currentVersion}'),
            Text('Latest Version: ${updateInfo.latestVersion}'),
            const SizedBox(height: 16),
            const Text(
              'What\'s New:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(updateInfo.changelog),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Later'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.download),
            label: const Text('Update Now'),
            onPressed: () async {
              Navigator.pop(context);
              await _launchUpdate(updateInfo.apkUrl);
            },
          ),
        ],
      ),
    );
  }

  /// Launch the update URL
  static Future<void> _launchUpdate(String apkUrl) async {
    try {
      final uri = Uri.parse(apkUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw Exception('Could not launch $apkUrl');
      }
    } catch (e) {
      debugPrint('UpdateService: Error launching update: $e');
    }
  }

  /// Check if we should skip update check (rate limiting)
  static Future<bool> _shouldSkipUpdateCheck() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getString(_lastUpdateCheckKey);

      if (lastCheck != null) {
        final lastCheckTime = DateTime.parse(lastCheck);
        final now = DateTime.now();
        return now.difference(lastCheckTime) < _updateCheckInterval;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Mark update check as complete
  static Future<void> _markUpdateCheckComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _lastUpdateCheckKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('UpdateService: Error marking update check: $e');
    }
  }

  /// Compare version strings to determine if one is newer
  static bool _isNewerVersion(String newVersion, String currentVersion) {
    try {
      final newParts = newVersion.split('.').map(int.parse).toList();
      final currentParts = currentVersion.split('.').map(int.parse).toList();

      // Pad with zeros if needed
      while (newParts.length < currentParts.length) {
        newParts.add(0);
      }
      while (currentParts.length < newParts.length) {
        currentParts.add(0);
      }

      for (int i = 0; i < newParts.length; i++) {
        if (newParts[i] > currentParts[i]) return true;
        if (newParts[i] < currentParts[i]) return false;
      }

      return false; // Versions are equal
    } catch (e) {
      debugPrint('UpdateService: Error comparing versions: $e');
      return false;
    }
  }
}

/// Data class for update information
class UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String apkUrl;
  final String changelog;
  final bool isUpdateAvailable;

  UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.apkUrl,
    required this.changelog,
    required this.isUpdateAvailable,
  });
}
