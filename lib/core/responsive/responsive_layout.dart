import 'package:flutter/widgets.dart';
import 'responsive_breakpoints.dart';

/// A widget that automatically selects the appropriate layout based on screen width
/// 
/// Breakpoints:
/// - Mobile: < 768px
/// - Tablet: 768-1023px
/// - Desktop: >= 1024px
class ResponsiveLayout extends StatelessWidget {
  /// Widget to display on mobile screens (< 768px)
  final Widget mobile;
  
  /// Widget to display on tablet screens (768-1023px)
  /// If null, will use mobile layout
  final Widget? tablet;
  
  /// Widget to display on desktop screens (>= 1024px)
  final Widget desktop;
  
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        
        // Desktop layout (>= 1024px)
        if (ResponsiveBreakpoints.isDesktop(width)) {
          return desktop;
        }
        
        // Tablet layout (768-1023px)
        if (ResponsiveBreakpoints.isTablet(width)) {
          return tablet ?? mobile;
        }
        
        // Mobile layout (< 768px)
        return mobile;
      },
    );
  }
}
