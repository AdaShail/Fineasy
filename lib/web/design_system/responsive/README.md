# Responsive System

A comprehensive responsive system for the Fineasy web application that provides breakpoint management, viewport detection, fluid typography, responsive containers, images, and a 12-column grid system.

## Features

- ✅ **Responsive Breakpoints**: Mobile (320-767px), Tablet (768-1023px), Desktop (1024-1439px), Wide (1440px+)
- ✅ **Viewport Detection Service**: Real-time viewport tracking with change notifications
- ✅ **Responsive Layout Utilities**: Helper functions and widgets for responsive layouts
- ✅ **Fluid Typography**: Smoothly scaling typography between breakpoints
- ✅ **Responsive Containers**: Containers with adaptive max-widths and padding
- ✅ **Responsive Images**: Images that load appropriate sizes based on viewport
- ✅ **12-Column Grid System**: Flexible grid with responsive column spans

## Quick Start

### 1. Wrap your app with ViewportProvider

```dart
import 'package:fineasy/web/design_system/responsive/responsive.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewportProvider(
      child: MaterialApp(
        home: MyHomePage(),
      ),
    );
  }
}
```

### 2. Use responsive utilities

```dart
import 'package:fineasy/web/design_system/responsive/responsive.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access viewport information
    final viewport = ViewportService.of(context);
    
    // Or use context extension
    if (context.isMobile) {
      return MobileLayout();
    } else if (context.isDesktop) {
      return DesktopLayout();
    }
    
    // Get responsive values
    final columns = context.responsiveValue(
      mobile: 1,
      tablet: 2,
      desktop: 3,
      wide: 4,
    );
    
    return GridView.count(
      crossAxisCount: columns,
      children: [...],
    );
  }
}
```

## Components

### ResponsiveConfig

Defines breakpoints and provides utility methods:

```dart
// Check breakpoints
if (ResponsiveConfig.isMobile(width)) { ... }
if (ResponsiveConfig.isTablet(width)) { ... }
if (ResponsiveConfig.isDesktop(width)) { ... }
if (ResponsiveConfig.isWide(width)) { ... }

// Get current breakpoint
final breakpoint = ResponsiveConfig.getBreakpoint(width);
print(breakpoint.name); // 'mobile', 'tablet', 'desktop', or 'wide'
print(breakpoint.columns); // Number of columns for this breakpoint
print(breakpoint.containerMaxWidth); // Max width for containers
print(breakpoint.containerPadding); // Padding for containers
```

### ViewportService

Service for tracking viewport dimensions:

```dart
final viewport = ViewportService.of(context);

// Current dimensions
print(viewport.width);
print(viewport.height);

// Current breakpoint
print(viewport.currentBreakpoint.name);

// Convenience checks
if (viewport.isMobile) { ... }
if (viewport.isTablet) { ... }
if (viewport.isDesktop) { ... }
if (viewport.isWide) { ... }
if (viewport.isDesktopOrWider) { ... }
if (viewport.isTabletOrWider) { ... }

// Breakpoint properties
print(viewport.columns); // Number of columns
print(viewport.containerMaxWidth); // Max width
print(viewport.containerPadding); // Padding
```

### ResponsiveBuilder

Build different layouts based on breakpoint:

```dart
ResponsiveBuilder(
  builder: (context, breakpoint) {
    switch (breakpoint.name) {
      case 'mobile':
        return MobileLayout();
      case 'tablet':
        return TabletLayout();
      case 'desktop':
      case 'wide':
        return DesktopLayout();
      default:
        return MobileLayout();
    }
  },
)
```

### ResponsiveVisibility

Show/hide widgets based on breakpoint:

```dart
// Show only on desktop and wide
ResponsiveVisibility(
  visibleOnMobile: false,
  visibleOnTablet: false,
  visibleOnDesktop: true,
  visibleOnWide: true,
  child: DesktopOnlyFeature(),
)

// Show on mobile, hide on larger screens
ResponsiveVisibility(
  visibleOnMobile: true,
  visibleOnTablet: false,
  visibleOnDesktop: false,
  visibleOnWide: false,
  replacement: DesktopAlternative(), // Optional replacement
  child: MobileOnlyFeature(),
)
```

### Context Extensions

Convenient extensions on BuildContext:

```dart
// Viewport checks
if (context.isMobile) { ... }
if (context.isTablet) { ... }
if (context.isDesktop) { ... }
if (context.isWide) { ... }
if (context.isDesktopOrWider) { ... }
if (context.isTabletOrWider) { ... }

// Get breakpoint
final breakpoint = context.breakpoint;

// Get responsive value
final value = context.responsiveValue(
  mobile: 1,
  tablet: 2,
  desktop: 3,
  wide: 4,
);
```

### Fluid Typography

Typography that scales smoothly between breakpoints:

```dart
// Using FluidText widgets
FluidText.h1('Large Heading')
FluidText.h2('Medium Heading')
FluidText.h3('Small Heading')
FluidText.body('Body text')

// Using FluidTextStyle
Text(
  'Custom text',
  style: FluidTextStyle.h1(viewportWidth),
)

// Manual calculation
final fontSize = FluidTypography.h1(viewportWidth);
final lineHeight = FluidTypography.lineHeight(fontSize);
final letterSpacing = FluidTypography.letterSpacing(fontSize);
```

Font sizes scale between breakpoints:
- H1: 32px (mobile) → 60px (wide)
- H2: 28px (mobile) → 48px (wide)
- H3: 24px (mobile) → 36px (wide)
- Body: 14px (mobile) → 16px (wide)

### ResponsiveContainer

Container with responsive max-width and padding:

```dart
// Basic container
ResponsiveContainer(
  child: MyContent(),
)

// Custom max-width
ResponsiveContainer(
  customMaxWidth: 800,
  child: MyContent(),
)

// Without padding
ResponsiveContainer(
  applyPadding: false,
  child: MyContent(),
)

// Custom padding
ResponsiveContainer(
  customPadding: EdgeInsets.all(24),
  child: MyContent(),
)
```

### ResponsiveSection

Full-width section with responsive inner container:

```dart
ResponsiveSection(
  backgroundColor: Colors.grey[100],
  child: MyContent(),
)

// Full-width content (no max-width constraint)
ResponsiveSection(
  fullWidth: true,
  child: MyContent(),
)
```

### ResponsivePadding

Padding that adapts to breakpoint:

```dart
// All sides
ResponsivePadding(
  child: MyWidget(),
)

// Horizontal only
ResponsivePadding.horizontal(
  child: MyWidget(),
)

// Vertical only
ResponsivePadding.vertical(
  child: MyWidget(),
)

// With multiplier
ResponsivePadding(
  multiplier: 2.0, // Double the default padding
  child: MyWidget(),
)
```

### ResponsiveSpacing

Spacing that adapts to breakpoint:

```dart
Column(
  children: [
    Widget1(),
    ResponsiveSpacing(), // Vertical spacing
    Widget2(),
  ],
)

Row(
  children: [
    Widget1(),
    ResponsiveSpacing.horizontal(), // Horizontal spacing
    Widget2(),
  ],
)

// With multiplier
ResponsiveSpacing(multiplier: 2.0)
```

### ResponsiveImage

Images that load appropriate sizes:

```dart
// With different URLs for each breakpoint
ResponsiveImage(
  baseUrl: 'https://example.com/image.jpg',
  mobileUrl: 'https://example.com/image-mobile.jpg',
  tabletUrl: 'https://example.com/image-tablet.jpg',
  desktopUrl: 'https://example.com/image-desktop.jpg',
  wideUrl: 'https://example.com/image-wide.jpg',
  fit: BoxFit.cover,
)

// With aspect ratio
ResponsiveAspectImage(
  baseUrl: 'https://example.com/image.jpg',
  aspectRatio: 16 / 9,
)

// Generate responsive URLs
final urls = ResponsiveImageUtils.generateResponsiveUrls(
  'https://example.com/image.jpg',
);
```

### ResponsiveGrid

12-column grid system:

```dart
ResponsiveGrid(
  spacing: 16,
  runSpacing: 16,
  children: [
    ResponsiveGridItem(
      mobileSpan: 12,    // Full width on mobile
      tabletSpan: 6,     // Half width on tablet
      desktopSpan: 4,    // Third width on desktop
      wideSpan: 3,       // Quarter width on wide
      child: MyWidget(),
    ),
    ResponsiveGridItem(
      mobileSpan: 12,
      tabletSpan: 6,
      desktopSpan: 8,
      child: MyWidget(),
    ),
  ],
)
```

### ResponsiveAutoGrid

Automatic grid with column count:

```dart
ResponsiveAutoGrid(
  mobileColumns: 1,
  tabletColumns: 2,
  desktopColumns: 3,
  wideColumns: 4,
  spacing: 16,
  runSpacing: 16,
  childAspectRatio: 1.5,
  children: [
    Card1(),
    Card2(),
    Card3(),
  ],
)
```

### ResponsiveWrap

Wrap layout with responsive spacing:

```dart
ResponsiveWrap(
  spacing: 8,
  runSpacing: 8,
  children: [
    Chip(label: Text('Tag 1')),
    Chip(label: Text('Tag 2')),
    Chip(label: Text('Tag 3')),
  ],
)
```

## Breakpoint Reference

| Breakpoint | Min Width | Max Width | Columns | Container Max | Padding |
|------------|-----------|-----------|---------|---------------|---------|
| Mobile     | 320px     | 767px     | 1       | 767px         | 16px    |
| Tablet     | 768px     | 1023px    | 2       | 1023px        | 24px    |
| Desktop    | 1024px    | 1439px    | 3       | 1439px        | 32px    |
| Wide       | 1440px    | ∞         | 4       | 1440px        | 48px    |

## Best Practices

1. **Always wrap your app with ViewportProvider** at the root level
2. **Use context extensions** for cleaner code: `context.isMobile` instead of `ViewportService.of(context).isMobile`
3. **Use ResponsiveContainer** for content sections to maintain consistent max-widths
4. **Use FluidText** for headings to ensure smooth scaling
5. **Use ResponsiveGrid** for complex layouts that need precise control
6. **Use ResponsiveAutoGrid** for simple card grids
7. **Test at all breakpoints**: 320px, 768px, 1024px, 1440px, and 1920px

## Examples

### Example 1: Responsive Dashboard

```dart
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FluidText.h1('Dashboard'),
          ResponsiveSpacing(multiplier: 2),
          ResponsiveAutoGrid(
            mobileColumns: 1,
            tabletColumns: 2,
            desktopColumns: 3,
            wideColumns: 4,
            children: [
              MetricCard(title: 'Revenue', value: '\$12,345'),
              MetricCard(title: 'Customers', value: '1,234'),
              MetricCard(title: 'Orders', value: '567'),
              MetricCard(title: 'Growth', value: '+23%'),
            ],
          ),
        ],
      ),
    );
  }
}
```

### Example 2: Responsive Form

```dart
class ResponsiveForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      customMaxWidth: 800,
      child: ResponsiveGrid(
        children: [
          ResponsiveGridItem(
            mobileSpan: 12,
            tabletSpan: 6,
            child: TextField(decoration: InputDecoration(labelText: 'First Name')),
          ),
          ResponsiveGridItem(
            mobileSpan: 12,
            tabletSpan: 6,
            child: TextField(decoration: InputDecoration(labelText: 'Last Name')),
          ),
          ResponsiveGridItem(
            mobileSpan: 12,
            child: TextField(decoration: InputDecoration(labelText: 'Email')),
          ),
        ],
      ),
    );
  }
}
```

### Example 3: Responsive Navigation

```dart
class ResponsiveNavigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, breakpoint) {
        if (breakpoint.name == 'mobile') {
          return MobileBottomNav();
        } else {
          return Row(
            children: [
              if (breakpoint.name != 'tablet')
                SidebarNav(),
              Expanded(child: MainContent()),
            ],
          );
        }
      },
    );
  }
}
```

## Requirements Validation

This implementation satisfies the following requirements:

- ✅ **Requirement 2.1**: Responsive breakpoints defined (mobile, tablet, desktop, wide)
- ✅ **Requirement 2.2**: Layout, typography, spacing, and components adjust based on viewport
- ✅ **Requirement 2.3**: Fluid typography scaling between breakpoints
- ✅ **Requirement 2.4**: Container max-widths and padding defined for each breakpoint
- ✅ **Requirement 2.5**: Column layouts for different screen sizes
- ✅ **Requirement 2.8**: Responsive images with appropriate sizes for viewports

## Testing

Test your responsive layouts at these key widths:
- 320px (small mobile)
- 375px (standard mobile)
- 768px (tablet)
- 1024px (desktop)
- 1440px (wide desktop)
- 1920px (full HD)

Use browser dev tools to test responsive behavior and ensure smooth transitions between breakpoints.
