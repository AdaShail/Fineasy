/// Defines responsive breakpoints for the application
class ResponsiveBreakpoints {
  /// Mobile breakpoint (< 768px)
  static const double mobile = 768;
  
  /// Tablet breakpoint (768-1023px)
  static const double tablet = 1024;
  
  /// Desktop breakpoint (>= 1024px)
  static const double desktop = 1024;
  
  /// Large desktop breakpoint (>= 1440px)
  static const double largeDesktop = 1440;
  
  /// Check if current width is mobile
  static bool isMobile(double width) => width < mobile;
  
  /// Check if current width is tablet
  static bool isTablet(double width) => width >= mobile && width < tablet;
  
  /// Check if current width is desktop
  static bool isDesktop(double width) => width >= desktop;
  
  /// Check if current width is large desktop
  static bool isLargeDesktop(double width) => width >= largeDesktop;
}
