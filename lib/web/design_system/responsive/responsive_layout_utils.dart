import 'package:flutter/widgets.dart';
import 'responsive_config.dart';
import 'viewport_service.dart';

/// Utility class for responsive layout helpers
class ResponsiveLayoutUtils {
  /// Get responsive value based on current breakpoint
  static T value<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
    T? wide,
  }) {
    final viewport = ViewportProvider.of(context);
    
    if (viewport.isWide && wide != null) {
      return wide;
    }
    if (viewport.isDesktop && desktop != null) {
      return desktop;
    }
    if (viewport.isTablet && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  /// Get responsive padding based on current breakpoint
  static EdgeInsets padding(BuildContext context) {
    final viewport = ViewportProvider.of(context);
    final padding = viewport.containerPadding;
    return EdgeInsets.all(padding);
  }

  /// Get responsive horizontal padding
  static EdgeInsets horizontalPadding(BuildContext context) {
    final viewport = ViewportProvider.of(context);
    final padding = viewport.containerPadding;
    return EdgeInsets.symmetric(horizontal: padding);
  }

  /// Get responsive vertical padding
  static EdgeInsets verticalPadding(BuildContext context) {
    final viewport = ViewportProvider.of(context);
    final padding = viewport.containerPadding;
    return EdgeInsets.symmetric(vertical: padding);
  }

  /// Get number of columns for grid layout
  static int columns(BuildContext context) {
    final viewport = ViewportProvider.of(context);
    return viewport.columns;
  }

  /// Get spacing between grid items
  static double spacing(BuildContext context) {
    final viewport = ViewportProvider.of(context);
    if (viewport.isWide) return 24;
    if (viewport.isDesktop) return 20;
    if (viewport.isTablet) return 16;
    return 12;
  }

  /// Calculate responsive font size with scaling
  static double fontSize(BuildContext context, double baseSize) {
    final viewport = ViewportProvider.of(context);
    if (viewport.isWide) return baseSize * 1.1;
    if (viewport.isDesktop) return baseSize;
    if (viewport.isTablet) return baseSize * 0.95;
    return baseSize * 0.9;
  }
}

/// Widget that builds different layouts based on breakpoint
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, Breakpoint breakpoint) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final breakpoint = ResponsiveConfig.getBreakpoint(constraints.maxWidth);
        return builder(context, breakpoint);
      },
    );
  }
}

/// Widget that conditionally shows content based on breakpoint
class ResponsiveVisibility extends StatelessWidget {
  final Widget child;
  final bool visibleOnMobile;
  final bool visibleOnTablet;
  final bool visibleOnDesktop;
  final bool visibleOnWide;
  final Widget? replacement;

  const ResponsiveVisibility({
    super.key,
    required this.child,
    this.visibleOnMobile = true,
    this.visibleOnTablet = true,
    this.visibleOnDesktop = true,
    this.visibleOnWide = true,
    this.replacement,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, breakpoint) {
        bool isVisible = false;
        
        switch (breakpoint.name) {
          case 'mobile':
            isVisible = visibleOnMobile;
            break;
          case 'tablet':
            isVisible = visibleOnTablet;
            break;
          case 'desktop':
            isVisible = visibleOnDesktop;
            break;
          case 'wide':
            isVisible = visibleOnWide;
            break;
        }

        if (isVisible) {
          return child;
        }
        
        return replacement ?? const SizedBox.shrink();
      },
    );
  }
}

/// Extension on BuildContext for easy responsive access
extension ResponsiveContext on BuildContext {
  /// Get viewport service
  ViewportService get viewport => ViewportProvider.of(this);

  /// Check if mobile
  bool get isMobile => viewport.isMobile;

  /// Check if tablet
  bool get isTablet => viewport.isTablet;

  /// Check if desktop
  bool get isDesktop => viewport.isDesktop;

  /// Check if wide
  bool get isWide => viewport.isWide;

  /// Check if desktop or wider
  bool get isDesktopOrWider => viewport.isDesktopOrWider;

  /// Check if tablet or wider
  bool get isTabletOrWider => viewport.isTabletOrWider;

  /// Get current breakpoint
  Breakpoint get breakpoint => viewport.currentBreakpoint;

  /// Get responsive value
  T responsiveValue<T>({
    required T mobile,
    T? tablet,
    T? desktop,
    T? wide,
  }) {
    return ResponsiveLayoutUtils.value(
      context: this,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
      wide: wide,
    );
  }
}
