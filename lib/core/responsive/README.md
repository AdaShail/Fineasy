# Responsive Infrastructure

This directory contains the responsive infrastructure for the FinEasy web platform expansion.

## Breakpoints

The application uses the following responsive breakpoints:

- **Mobile**: < 768px
- **Tablet**: 768-1023px
- **Desktop**: >= 1024px
- **Large Desktop**: >= 1440px

## Components

### ResponsiveLayout

Automatically selects the appropriate layout based on screen width.

```dart
import 'package:fineasy/core/responsive/responsive.dart';

ResponsiveLayout(
  mobile: MobileLayout(),
  tablet: TabletLayout(), // Optional, falls back to mobile if not provided
  desktop: DesktopLayout(),
)
```

### ResponsiveBuilder

Provides constraints for custom responsive logic.

```dart
import 'package:fineasy/core/responsive/responsive.dart';

ResponsiveBuilder(
  builder: (context, constraints) {
    if (constraints.isDesktop) {
      return DesktopView();
    } else if (constraints.isTablet) {
      return TabletView();
    } else {
      return MobileView();
    }
  },
)
```

### PlatformDetector

Detects platform and screen size.

```dart
import 'package:fineasy/core/responsive/responsive.dart';

// Check if running on web
if (PlatformDetector.isWeb) {
  // Web-specific code
}

// Check screen size
if (PlatformDetector.isDesktopScreen(context)) {
  // Desktop-specific UI
}

// Get device type
final deviceType = PlatformDetector.getDeviceType(context);
```

### ResponsiveBreakpoints

Defines and checks breakpoints.

```dart
import 'package:fineasy/core/responsive/responsive.dart';

final width = MediaQuery.of(context).size.width;

if (ResponsiveBreakpoints.isMobile(width)) {
  // Mobile layout
} else if (ResponsiveBreakpoints.isTablet(width)) {
  // Tablet layout
} else {
  // Desktop layout
}
```

## Usage Examples

### Example 1: Simple Responsive Screen

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      desktop: _buildDesktopLayout(),
    );
  }
  
  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Mobile-specific layout
      ],
    );
  }
  
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Desktop-specific layout with sidebar
      ],
    );
  }
}
```

### Example 2: Custom Responsive Logic

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, constraints) {
        final columns = constraints.isDesktop ? 3 : 
                       constraints.isTablet ? 2 : 1;
        
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
          ),
          itemBuilder: (context, index) => MyCard(),
        );
      },
    );
  }
}
```

### Example 3: Platform-Specific Features

```dart
class MyFeature extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (PlatformDetector.isWeb) {
      return WebOptimizedFeature();
    } else {
      return MobileOptimizedFeature();
    }
  }
}
```

## Best Practices

1. **Use ResponsiveLayout for major layout changes**: When you need completely different layouts for mobile and desktop.

2. **Use ResponsiveBuilder for fine-grained control**: When you need to adjust specific properties based on screen size.

3. **Use PlatformDetector for platform-specific features**: When you need to conditionally enable features based on platform.

4. **Avoid hardcoding breakpoints**: Always use the constants from ResponsiveBreakpoints.

5. **Test at all breakpoints**: Ensure your UI works correctly at mobile (320px, 375px), tablet (768px), and desktop (1024px, 1440px) sizes.

## Folder Structure

The codebase is organized into platform-specific directories:

- `lib/web/`: Web-optimized screens, widgets, layouts, and utilities
- `lib/mobile/`: Mobile-optimized screens and widgets
- `lib/shared/`: Platform-agnostic code (providers, services, models)
- `lib/core/`: Core utilities including responsive infrastructure
