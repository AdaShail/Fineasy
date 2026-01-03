import 'package:flutter/widgets.dart';

/// A widget that provides constraints for custom responsive logic
/// 
/// This widget gives you full control over how your UI responds to different
/// screen sizes by providing the current constraints in the builder function.
class ResponsiveBuilder extends StatelessWidget {
  /// Builder function that receives context and constraints
  final Widget Function(BuildContext context, BoxConstraints constraints) builder;
  
  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return builder(context, constraints);
      },
    );
  }
}

/// Extension on BoxConstraints for responsive utilities
extension ResponsiveConstraints on BoxConstraints {
  /// Check if constraints represent mobile size (< 768px)
  bool get isMobile => maxWidth < 768;
  
  /// Check if constraints represent tablet size (768-1023px)
  bool get isTablet => maxWidth >= 768 && maxWidth < 1024;
  
  /// Check if constraints represent desktop size (>= 1024px)
  bool get isDesktop => maxWidth >= 1024;
  
  /// Check if constraints represent large desktop size (>= 1440px)
  bool get isLargeDesktop => maxWidth >= 1440;
}
