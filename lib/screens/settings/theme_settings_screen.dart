import 'package:flutter/material.dart';
import '../../services/theme_manager_service.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  ThemeMode _selectedThemeMode = ThemeMode.system;
  Color _selectedPrimaryColor = Colors.blue;
  Color _selectedAccentColor = Colors.orange;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    final themeMode = await ThemeManagerService.getThemeMode();
    final primaryColor = await ThemeManagerService.getPrimaryColor();
    final accentColor = await ThemeManagerService.getAccentColor();

    setState(() {
      _selectedThemeMode = themeMode;
      _selectedPrimaryColor = primaryColor;
      _selectedAccentColor = accentColor;
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
          content: Text('Theme mode changed to ${ThemeManagerService.getThemeModeName(mode)}'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Notify app to rebuild with new theme
      Navigator.pop(context, true);
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
          backgroundColor: Colors.green,
        ),
      );
      
      // Notify app to rebuild with new theme
      Navigator.pop(context, true);
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
            backgroundColor: Colors.green,
          ),
        );
        
        // Notify app to rebuild with new theme
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Theme Settings'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetToDefault,
            tooltip: 'Reset to Default',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Mode Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        ThemeManagerService.getThemeModeIcon(_selectedThemeMode),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Theme Mode',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...ThemeManagerService.themeModes.map((mode) {
                    return RadioListTile<ThemeMode>(
                      title: Text(ThemeManagerService.getThemeModeName(mode)),
                      subtitle: Text(_getThemeModeDescription(mode)),
                      value: mode,
                      groupValue: _selectedThemeMode,
                      onChanged: (value) {
                        if (value != null) {
                          _saveThemeMode(value);
                        }
                      },
                      secondary: Icon(ThemeManagerService.getThemeModeIcon(mode)),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),

          // Primary Color Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.palette,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Primary Color',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: ThemeManagerService.primaryColors.entries.map((entry) {
                      final isSelected = entry.value.value == _selectedPrimaryColor.value;
                      return InkWell(
                        onTap: () => _savePrimaryColor(entry.value),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: entry.value,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: entry.value.withOpacity(0.5),
                                      blurRadius: 8,
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
                                  size: 32,
                                ),
                              const SizedBox(height: 4),
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Preview Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.preview,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Preview',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _selectedPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _selectedPrimaryColor),
                    ),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedPrimaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Primary Button'),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedAccentColor,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Accent Button'),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _selectedPrimaryColor,
                          ),
                          child: const Text('Outlined Button'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Reset Button
          OutlinedButton.icon(
            onPressed: _resetToDefault,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset to Default Theme'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeModeDescription(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Always use light theme';
      case ThemeMode.dark:
        return 'Always use dark theme';
      case ThemeMode.system:
        return 'Follow system settings';
    }
  }
}
