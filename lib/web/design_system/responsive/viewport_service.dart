import 'package:flutter/widgets.dart';
import 'responsive_config.dart';

/// Service for detecting and managing viewport information
class ViewportService extends ChangeNotifier {
  double _width = 0;
  double _height = 0;
  Breakpoint _currentBreakpoint = ResponsiveConfig.mobile;

  /// Current viewport width
  double get width => _width;

  /// Current viewport height
  double get height => _height;

  /// Current breakpoint
  Breakpoint get currentBreakpoint => _currentBreakpoint;

  /// Check if current viewport is mobile
  bool get isMobile => ResponsiveConfig.isMobile(_width);

  /// Check if current viewport is tablet
  bool get isTablet => ResponsiveConfig.isTablet(_width);

  /// Check if current viewport is desktop
  bool get isDesktop => ResponsiveConfig.isDesktop(_width);

  /// Check if current viewport is wide desktop
  bool get isWide => ResponsiveConfig.isWide(_width);

  /// Check if current viewport is desktop or wider
  bool get isDesktopOrWider => ResponsiveConfig.isDesktopOrWider(_width);

  /// Check if current viewport is tablet or wider
  bool get isTabletOrWider => ResponsiveConfig.isTabletOrWider(_width);

  /// Update viewport dimensions
  void updateDimensions(double width, double height) {
    if (_width != width || _height != height) {
      _width = width;
      _height = height;
      
      final newBreakpoint = ResponsiveConfig.getBreakpoint(width);
      if (newBreakpoint.name != _currentBreakpoint.name) {
        _currentBreakpoint = newBreakpoint;
      }
      
      notifyListeners();
    }
  }

  /// Get number of columns for current breakpoint
  int get columns => _currentBreakpoint.columns;

  /// Get container max width for current breakpoint
  double get containerMaxWidth => _currentBreakpoint.containerMaxWidth;

  /// Get container padding for current breakpoint
  double get containerPadding => _currentBreakpoint.containerPadding;
}

/// Widget that provides viewport information to descendants
class ViewportProvider extends StatefulWidget {
  final Widget child;

  const ViewportProvider({
    super.key,
    required this.child,
  });

  @override
  State<ViewportProvider> createState() => _ViewportProviderState();

  /// Get the ViewportService from context
  static ViewportService of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<_InheritedViewportProvider>();
    assert(provider != null, 'No ViewportProvider found in context');
    return provider!.service;
  }

  /// Try to get the ViewportService from context (returns null if not found)
  static ViewportService? maybeOf(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<_InheritedViewportProvider>();
    return provider?.service;
  }
}

class _ViewportProviderState extends State<ViewportProvider> {
  final ViewportService _service = ViewportService();

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _service.updateDimensions(
            constraints.maxWidth,
            constraints.maxHeight,
          );
        });

        return _InheritedViewportProvider(
          service: _service,
          child: widget.child,
        );
      },
    );
  }
}

class _InheritedViewportProvider extends InheritedWidget {
  final ViewportService service;

  const _InheritedViewportProvider({
    required this.service,
    required super.child,
  });

  @override
  bool updateShouldNotify(_InheritedViewportProvider oldWidget) {
    return service != oldWidget.service;
  }
}
