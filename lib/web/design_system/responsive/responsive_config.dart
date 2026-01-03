/// Responsive breakpoint configuration
class Breakpoint {
  final String name;
  final double minWidth;
  final double? maxWidth;
  final int columns;
  final double containerMaxWidth;
  final double containerPadding;

  const Breakpoint({
    required this.name,
    required this.minWidth,
    this.maxWidth,
    required this.columns,
    required this.containerMaxWidth,
    required this.containerPadding,
  });

  bool matches(double width) {
    if (maxWidth != null) {
      return width >= minWidth && width < maxWidth!;
    }
    return width >= minWidth;
  }
}

/// Responsive configuration for the application
class ResponsiveConfig {
  /// Mobile breakpoint (320px-767px)
  static const Breakpoint mobile = Breakpoint(
    name: 'mobile',
    minWidth: 320,
    maxWidth: 768,
    columns: 1,
    containerMaxWidth: 767,
    containerPadding: 16,
  );

  /// Tablet breakpoint (768px-1023px)
  static const Breakpoint tablet = Breakpoint(
    name: 'tablet',
    minWidth: 768,
    maxWidth: 1024,
    columns: 2,
    containerMaxWidth: 1023,
    containerPadding: 24,
  );

  /// Desktop breakpoint (1024px-1439px)
  static const Breakpoint desktop = Breakpoint(
    name: 'desktop',
    minWidth: 1024,
    maxWidth: 1440,
    columns: 3,
    containerMaxWidth: 1439,
    containerPadding: 32,
  );

  /// Wide desktop breakpoint (1440px+)
  static const Breakpoint wide = Breakpoint(
    name: 'wide',
    minWidth: 1440,
    columns: 4,
    containerMaxWidth: 1440,
    containerPadding: 48,
  );

  /// All breakpoints in order
  static const List<Breakpoint> breakpoints = [
    mobile,
    tablet,
    desktop,
    wide,
  ];

  /// Get the current breakpoint for a given width
  static Breakpoint getBreakpoint(double width) {
    for (final breakpoint in breakpoints.reversed) {
      if (breakpoint.matches(width)) {
        return breakpoint;
      }
    }
    return mobile;
  }

  /// Check if width is mobile
  static bool isMobile(double width) => width < tablet.minWidth;

  /// Check if width is tablet
  static bool isTablet(double width) => tablet.matches(width);

  /// Check if width is desktop
  static bool isDesktop(double width) => desktop.matches(width);

  /// Check if width is wide desktop
  static bool isWide(double width) => wide.matches(width);

  /// Check if width is desktop or wider
  static bool isDesktopOrWider(double width) => width >= desktop.minWidth;

  /// Check if width is tablet or wider
  static bool isTabletOrWider(double width) => width >= tablet.minWidth;
}
