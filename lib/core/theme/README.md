# Responsive Theme System

A comprehensive responsive theme system that adapts typography, spacing, colors, and component styles based on screen size and theme mode.

## Features

- **Responsive Typography**: Text scales automatically based on screen size
- **Adaptive Spacing**: Padding, margins, and gaps adjust for different devices
- **Responsive Color Schemes**: Colors optimized for light and dark modes
- **Theme Switching**: Easy switching between light, dark, and system themes
- **Web Integration**: Seamless integration with web platform

## Components

### 1. Responsive Typography (`responsive_typography.dart`)

Provides text styles that scale based on screen width:

```dart
import 'package:fineasy/core/theme/responsive_typography.dart';

// Get responsive text theme
final textTheme = ResponsiveTypography.getTextTheme(
  MediaQuery.of(context).size.width,
  isDark: Theme.of(context).brightness == Brightness.dark,
);

// Use specific styles
final headingStyle = ResponsiveTypography.getHeadingStyle(
  MediaQuery.of(context).size.width,
  isDark: false,
);
```

**Typography Scale:**
- Mobile (< 768px): 0.9x scale
- Tablet (768-1023px): 1.0x scale
- Desktop (1024-1439px): 1.05x scale
- Large Desktop (>= 1440px): 1.15x scale

### 2. Adaptive Spacing (`adaptive_spacing.dart`)

Provides responsive spacing values:

```dart
import 'package:fineasy/core/theme/adaptive_spacing.dart';

final width = MediaQuery.of(context).size.width;

// Get padding
final padding = AdaptiveSpacing.getPadding(width, size: SpacingSize.medium);

// Get border radius
final radius = AdaptiveSpacing.getBorderRadius(width, size: RadiusSize.medium);

// Get icon size
final iconSize = AdaptiveSpacing.getIconSize(width, size: IconSize.large);

// Get elevation
final elevation = AdaptiveSpacing.getElevation(width, level: ElevationLevel.medium);

// Get grid columns
final columns = AdaptiveSpacing.getGridColumns(width);
```

**Spacing Sizes:**
- `tiny`: 4px (scaled)
- `small`: 8px (scaled)
- `medium`: 16px (scaled)
- `large`: 24px (scaled)
- `extraLarge`: 32px (scaled)
- `huge`: 48px (scaled)

### 3. Responsive Color Scheme (`responsive_color_scheme.dart`)

Provides color schemes optimized for different themes:

```dart
import 'package:fineasy/core/theme/responsive_color_scheme.dart';

final width = MediaQuery.of(context).size.width;

// Get color scheme
final lightScheme = ResponsiveColorScheme.getLightColorScheme(Colors.blue, width);
final darkScheme = ResponsiveColorScheme.getDarkColorScheme(Colors.blue, width);

// Get financial colors
final financialColors = ResponsiveColorScheme.getFinancialColors(isDark);

// Get status colors
final statusColors = ResponsiveColorScheme.getStatusColors(isDark);

// Get chart colors
final chartColors = ResponsiveColorScheme.getChartColors(isDark);
```

### 4. Responsive Theme Data (`responsive_theme_data.dart`)

Complete theme data that combines all responsive elements:

```dart
import 'package:fineasy/core/theme/responsive_theme_data.dart';

final width = MediaQuery.of(context).size.width;

// Get complete themes
final lightTheme = ResponsiveThemeData.getLightTheme(
  Colors.blue,
  width,
  accentColor: Colors.orange,
);

final darkTheme = ResponsiveThemeData.getDarkTheme(
  Colors.blue,
  width,
  accentColor: Colors.orange,
);
```

## Web Integration

### Web Theme Provider

Use the `WebThemeProvider` to manage theme state on web:

```dart
import 'package:provider/provider.dart';
import 'package:fineasy/web/providers/web_theme_provider.dart';

// In your app initialization
MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (_) => WebThemeProvider()..initialize(),
    ),
  ],
  child: MyApp(),
);

// In MaterialApp
Consumer<WebThemeProvider>(
  builder: (context, themeProvider, child) {
    return MaterialApp(
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      // ...
    );
  },
);
```

### Theme Switcher Widget

Add theme switching UI:

```dart
import 'package:fineasy/web/widgets/theme_switcher_widget.dart';

// Compact icon button
ThemeSwitcherWidget(compact: true)

// Full menu
ThemeSwitcherWidget()

// Complete customization panel
ThemeCustomizationPanel()
```

## Usage Examples

### Example 1: Responsive Card

```dart
Widget build(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  
  return Card(
    margin: EdgeInsets.all(
      AdaptiveSpacing.getPadding(width, size: SpacingSize.medium),
    ),
    child: Padding(
      padding: EdgeInsets.all(
        AdaptiveSpacing.getPadding(width, size: SpacingSize.large),
      ),
      child: Column(
        children: [
          Text(
            'Heading',
            style: ResponsiveTypography.getHeadingStyle(width),
          ),
          SizedBox(height: AdaptiveSpacing.getGap(width)),
          Text(
            'Body text',
            style: ResponsiveTypography.getBodyStyle(width),
          ),
        ],
      ),
    ),
  );
}
```

### Example 2: Responsive Grid

```dart
Widget build(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  final columns = AdaptiveSpacing.getGridColumns(width);
  
  return GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      crossAxisSpacing: AdaptiveSpacing.getGap(width),
      mainAxisSpacing: AdaptiveSpacing.getGap(width),
    ),
    itemBuilder: (context, index) => YourWidget(),
  );
}
```

### Example 3: Financial Data Display

```dart
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final colors = ResponsiveColorScheme.getFinancialColors(isDark);
  
  return Row(
    children: [
      Text(
        'Profit: ₹1000',
        style: TextStyle(color: colors.profit),
      ),
      Text(
        'Loss: ₹500',
        style: TextStyle(color: colors.loss),
      ),
    ],
  );
}
```

### Example 4: Responsive Layout with Theme

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('My Screen'),
        actions: [
          ThemeSwitcherWidget(compact: true),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(
          AdaptiveSpacing.getPadding(width, size: SpacingSize.large),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome',
              style: ResponsiveTypography.getHeadingStyle(width, isDark: isDark),
            ),
            SizedBox(height: AdaptiveSpacing.getGap(width)),
            Text(
              'This is responsive content',
              style: ResponsiveTypography.getBodyStyle(width, isDark: isDark),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Breakpoints

The system uses the following breakpoints:

- **Mobile**: < 768px
- **Tablet**: 768px - 1023px
- **Desktop**: 1024px - 1439px
- **Large Desktop**: >= 1440px

## Theme Modes

Three theme modes are supported:

1. **Light**: Always use light theme
2. **Dark**: Always use dark theme
3. **System**: Follow system preference

## Best Practices

1. **Always use responsive values**: Use `AdaptiveSpacing` and `ResponsiveTypography` instead of hardcoded values
2. **Update on resize**: Call `themeProvider.updateScreenWidth()` when screen size changes
3. **Use semantic colors**: Use `FinancialColors` and `StatusColors` for consistent color usage
4. **Test all breakpoints**: Test your UI at mobile, tablet, and desktop sizes
5. **Support both themes**: Ensure your UI works in both light and dark modes

## Performance Considerations

- Theme changes trigger full rebuilds, so minimize unnecessary theme updates
- Use `const` constructors where possible
- Cache responsive values if they're used multiple times in the same build

## Migration from Old Theme

If you're migrating from the old theme system:

1. Replace `ThemeManagerService.getLightTheme()` with `ResponsiveThemeData.getLightTheme()`
2. Add screen width parameter to theme calls
3. Replace hardcoded spacing with `AdaptiveSpacing` calls
4. Use `WebThemeProvider` instead of direct `ThemeManagerService` calls on web

## Requirements Validation

This implementation satisfies:
- **Requirement 2.1**: Modern, visually appealing interface with responsive design
- **Requirement 2.5**: Consistent design language and branding across all pages
