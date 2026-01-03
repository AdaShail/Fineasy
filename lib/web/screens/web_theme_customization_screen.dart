import 'package:flutter/material.dart';
import '../../services/theme_manager_service.dart';
import '../../utils/app_theme.dart';
import '../widgets/web_card.dart';

/// Web-optimized theme customization interface
/// Provides enhanced theme controls for desktop users
class WebThemeCustomizationScreen extends StatefulWidget {
  const WebThemeCustomizationScreen({super.key});

  @override
  State<WebThemeCustomizationScreen> createState() =>
      _WebThemeCustomizationScreenState();
}

class _WebThemeCustomizationScreenState
    extends State<WebThemeCustomizationScreen> {
  ThemeMode _selectedThemeMode = ThemeMode.system;
  Color _selectedPrimaryColor = Colors.blue;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    final themeMode = await ThemeManagerService.getThemeMode();
    final primaryColor = await ThemeManagerService.getPrimaryColor();

    setState(() {
      _selectedThemeMode = themeMode;
      _selectedPrimaryColor = primaryColor;
      _isLoading = false;
    });
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    await ThemeManagerService.setThemeMode(mode);
    setState(() {
      _selectedThemeMode = mode;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Theme mode changed to ${ThemeManagerService.getThemeModeName(mode)}',
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _savePrimaryColor(Color color) async {
    await ThemeManagerService.setPrimaryColor(color);
    setState(() {
      _selectedPrimaryColor = color;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primary color updated'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _resetToDefault() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Theme'),
        content: const Text('Are you sure you want to reset to default theme?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ThemeManagerService.resetToDefault();
      await _loadCurrentSettings();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Theme reset to default'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme Customization',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Customize the appearance of your application',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: _resetToDefault,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset to Default'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Theme Mode Section
          WebCard(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      ThemeManagerService.getThemeModeIcon(_selectedThemeMode),
                      color: AppTheme.primaryColor,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Theme Mode',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Choose how the app should appear',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 24),
                Row(
                  children: ThemeManagerService.themeModes.map((mode) {
                    final isSelected = _selectedThemeMode == mode;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _buildThemeModeCard(mode, isSelected),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Primary Color Section
          WebCard(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.palette,
                      color: AppTheme.primaryColor,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Primary Color',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select your preferred primary color',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: ThemeManagerService.primaryColors.entries.map((entry) {
                    final isSelected = entry.value.value == _selectedPrimaryColor.value;
                    return _buildColorOption(entry.key, entry.value, isSelected);
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Preview Section
          WebCard(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.preview,
                      color: AppTheme.primaryColor,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Preview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'See how your theme looks',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: _selectedPrimaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _selectedPrimaryColor),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.add),
                              label: const Text('Primary Button'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedPrimaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.edit),
                              label: const Text('Outlined Button'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _selectedPrimaryColor,
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.check_circle,
                            color: _selectedPrimaryColor,
                          ),
                          title: const Text('Sample List Item'),
                          subtitle: const Text('This is how list items will look'),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            color: _selectedPrimaryColor,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeCard(ThemeMode mode, bool isSelected) {
    return InkWell(
      onTap: () => _saveThemeMode(mode),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              ThemeManagerService.getThemeModeIcon(mode),
              size: 48,
              color: isSelected ? AppTheme.primaryColor : Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              ThemeManagerService.getThemeModeName(mode),
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppTheme.primaryColor : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getThemeModeDescription(mode),
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(String name, Color color, bool isSelected) {
    return InkWell(
      onTap: () => _savePrimaryColor(color),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 4,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 40,
              ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeModeDescription(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Always light';
      case ThemeMode.dark:
        return 'Always dark';
      case ThemeMode.system:
        return 'Follow system';
    }
  }
}
