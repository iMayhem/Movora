import 'package:flutter/material.dart';
import 'package:movora/theme/app_theme.dart';
import 'package:movora/services/adult_filter_service.dart';
import 'package:movora/services/intense_cache_service.dart';
import 'package:movora/config/image_cache_config.dart';
import 'package:provider/provider.dart';
import 'package:movora/providers/movie_provider.dart';
import 'package:movora/services/image_quality_service.dart';
import 'package:movora/config/runtime_flags.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isAdultFilterEnabled = true;
  bool _isIntenseCachingEnabled = false;
  bool _isLowDataEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    await AdultFilterService.initialize();
    await ImageQualityService.initialize();
    setState(() {
      _isAdultFilterEnabled = AdultFilterService.isFilterEnabled;
      _isIntenseCachingEnabled =
          false; // Default to false, will be updated based on service state
      _isLowDataEnabled = ImageQualityService.isLowDataEnabled;
    });
  }

  Future<void> _toggleAdultFilter(bool value) async {
    await AdultFilterService.setFilterEnabled(value);
    setState(() {
      _isAdultFilterEnabled = value;
    });

    // Refresh the adult content filter across all loaded data
    if (mounted) {
      try {
        await context.read<MovieProvider>().refreshAdultContentFilter();
      } catch (e) {
        print('Error refreshing adult content filter: $e');
      }
    }

    // Notify the app that the filter has changed
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? '🔒 Adult content filter enabled'
                : '⚠️ Adult content filter disabled',
          ),
          backgroundColor:
              value ? AppTheme.primaryColor : AppTheme.destructiveColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _toggleLowData(bool value) async {
    await ImageQualityService.setLowDataEnabled(value);
    setState(() {
      _isLowDataEnabled = value;
    });

    // Update bridge so model URL getters switch sizes immediately
    RuntimeFlags.setLowData(value);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value
              ? '🪄 Low data mode ON (smaller images)'
              : '🖼️ Low data mode OFF (standard images)'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    }
  }

  Future<void> _toggleIntenseCaching(bool value) async {
    if (value) {
      IntenseCacheService().initialize();
    } else {
      IntenseCacheService().clearIntenseCache();
    }
    setState(() {
      _isIntenseCachingEnabled = value;
    });

    // Notify the app that the caching mode has changed
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? '🚀 Intense caching enabled' : '⚡ Standard caching mode',
          ),
          backgroundColor: AppTheme.primaryColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _clearAllCaches() async {
    IntenseCacheService().clearIntenseCache();
    ImageCacheConfig.clearCache();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🗑️ All caches cleared'),
          backgroundColor: AppTheme.primaryColor,
          duration: Duration(seconds: 2),
        ),
      );
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
          'Settings',
          style: TextStyle(
            color: AppTheme.textPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content Filter Section
              _buildSectionHeader('Content Filtering', Icons.shield),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 24),
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
                          _isAdultFilterEnabled
                              ? Icons.shield
                              : Icons.shield_outlined,
                          color: _isAdultFilterEnabled
                              ? AppTheme.primaryColor
                              : AppTheme.textSecondaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Adult Content Filter',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textPrimaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Filter out adult content to maintain family-friendly viewing',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _isAdultFilterEnabled
                                ? 'Family Mode'
                                : 'Adult Mode',
                            style: AppTheme.bodyMedium.copyWith(
                              color: _isAdultFilterEnabled
                                  ? AppTheme.primaryColor
                                  : AppTheme.destructiveColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Switch(
                          value: _isAdultFilterEnabled,
                          onChanged: _toggleAdultFilter,
                          activeColor: AppTheme.primaryColor,
                          activeTrackColor:
                              AppTheme.primaryColor.withOpacity(0.3),
                          inactiveThumbColor: AppTheme.textSecondaryColor,
                          inactiveTrackColor:
                              AppTheme.surfaceColor.withOpacity(0.5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Caching Section
              _buildSectionHeader('Performance & Caching', Icons.speed),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 24),
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
                    // Low Data Mode
                    Row(
                      children: [
                        Icon(
                          _isLowDataEnabled ? Icons.data_saver_on : Icons.image,
                          color: _isLowDataEnabled
                              ? AppTheme.primaryColor
                              : AppTheme.textSecondaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Low Data Mode (Smaller Images)',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textPrimaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: _isLowDataEnabled,
                          onChanged: _toggleLowData,
                          activeColor: AppTheme.primaryColor,
                          activeTrackColor:
                              AppTheme.primaryColor.withOpacity(0.3),
                          inactiveThumbColor: AppTheme.textSecondaryColor,
                          inactiveTrackColor:
                              AppTheme.surfaceColor.withOpacity(0.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          _isIntenseCachingEnabled
                              ? Icons.rocket_launch
                              : Icons.speed,
                          color: _isIntenseCachingEnabled
                              ? AppTheme.primaryColor
                              : AppTheme.textSecondaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Intense Caching Mode',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textPrimaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enable aggressive caching for faster image loading and better performance',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _isIntenseCachingEnabled ? 'Enabled' : 'Disabled',
                            style: AppTheme.bodyMedium.copyWith(
                              color: _isIntenseCachingEnabled
                                  ? AppTheme.primaryColor
                                  : AppTheme.textSecondaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Switch(
                          value: _isIntenseCachingEnabled,
                          onChanged: _toggleIntenseCaching,
                          activeColor: AppTheme.primaryColor,
                          activeTrackColor:
                              AppTheme.primaryColor.withOpacity(0.3),
                          inactiveThumbColor: AppTheme.textSecondaryColor,
                          inactiveTrackColor:
                              AppTheme.surfaceColor.withOpacity(0.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _clearAllCaches,
                        icon: const Icon(Icons.delete_sweep, size: 18),
                        label: const Text('Clear All Caches'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.destructiveColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // App Info Section
              _buildSectionHeader('App Information', Icons.info),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 24),
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
                    _buildInfoRow('App Version', '1.0.0'),
                    const SizedBox(height: 12),
                    _buildInfoRow('Build Number', '1'),
                    const SizedBox(height: 12),
                    _buildInfoRow('Platform', 'Android'),
                    const SizedBox(height: 12),
                    _buildInfoRow('Developer', 'Movora Team'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.textPrimaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
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
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
