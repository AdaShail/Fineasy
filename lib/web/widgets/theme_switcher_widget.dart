import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/web_theme_provider.dart';
import '../../services/theme_manager_service.dart';

/// Widget for switching themes on web platform
class ThemeSwitcherWidget extends StatelessWidget {
  final bool showLabel;
  final bool compact;
  
  const ThemeSwitcherWidget({
    super.key,
    this.showLabel = true,
    this.compact = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Consumer<WebThemeProvider>(
      builder: (context, themeProvider, child) {
        if (compact) {
          return IconButton(
            icon: Icon(_getThemeIcon(themeProvider.themeMode)),
            tooltip: _getThemeLabel(themeProvider.themeMode),
            onPressed: () => themeProvider.toggleTheme(),
          );
        }
        
        return PopupMenuButton<ThemeMode>(
          icon: Icon(_getThemeIcon(themeProvider.themeMode)),
          tooltip: 'Change theme',
          onSelected: (mode) => themeProvider.setThemeMode(mode),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: ThemeMode.light,
              child: Row(
                children: [
                  const Icon(Icons.light_mode),
                  const SizedBox(width: 12),
                  const Text('Light'),
                  if (themeProvider.themeMode == ThemeMode.light)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.check, size: 16),
                    ),
                ],
              ),
            ),
            PopupMenuItem(
              value: ThemeMode.dark,
              child: Row(
                children: [
                  const Icon(Icons.dark_mode),
                  const SizedBox(width: 12),
                  const Text('Dark'),
                  if (themeProvider.themeMode == ThemeMode.dark)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.check, size: 16),
                    ),
                ],
              ),
            ),
            PopupMenuItem(
              value: ThemeMode.system,
              child: Row(
                children: [
                  const Icon(Icons.brightness_auto),
                  const SizedBox(width: 12),
                  const Text('System'),
                  if (themeProvider.themeMode == ThemeMode.system)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.check, size: 16),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
  
  IconData _getThemeIcon(ThemeMode mode) {
    return ThemeManagerService.getThemeModeIcon(mode);
  }
  
  String _getThemeLabel(ThemeMode mode) {
    return ThemeManagerService.getThemeModeName(mode);
  }
}

/// Color picker widget for theme customization
class ThemeColorPicker extends StatelessWidget {
  final String title;
  final Color currentColor;
  final ValueChanged<Color> onColorChanged;
  
  const ThemeColorPicker({
    super.key,
    required this.title,
    required this.currentColor,
    required this.onColorChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: ThemeManagerService.primaryColors.entries.map((entry) {
            final isSelected = entry.value.value == currentColor.value;
            return InkWell(
              onTap: () => onColorChanged(entry.value),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: entry.value,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Complete theme customization panel
class ThemeCustomizationPanel extends StatelessWidget {
  const ThemeCustomizationPanel({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Consumer<WebThemeProvider>(
      builder: (context, themeProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Theme Customization',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              
              // Theme mode selector
              Text(
                'Theme Mode',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode),
                    label: Text('Light'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode),
                    label: Text('Dark'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: Icon(Icons.brightness_auto),
                    label: Text('System'),
                  ),
                ],
                selected: {themeProvider.themeMode},
                onSelectionChanged: (Set<ThemeMode> modes) {
                  themeProvider.setThemeMode(modes.first);
                },
              ),
              const SizedBox(height: 32),
              
              // Primary color picker
              ThemeColorPicker(
                title: 'Primary Color',
                currentColor: themeProvider.seedColor,
                onColorChanged: (color) => themeProvider.setSeedColor(color),
              ),
              const SizedBox(height: 32),
              
              // Accent color picker
              ThemeColorPicker(
                title: 'Accent Color',
                currentColor: themeProvider.accentColor,
                onColorChanged: (color) => themeProvider.setAccentColor(color),
              ),
              const SizedBox(height: 32),
              
              // Reset button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => themeProvider.resetToDefault(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset to Default'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
