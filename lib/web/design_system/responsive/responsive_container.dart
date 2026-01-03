import 'package:flutter/widgets.dart';
import 'responsive_config.dart';

/// Container that adapts its max-width and padding based on breakpoint
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final bool applyPadding;
  final bool constrainWidth;
  final EdgeInsets? customPadding;
  final double? customMaxWidth;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.applyPadding = true,
    this.constrainWidth = true,
    this.customPadding,
    this.customMaxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final breakpoint = ResponsiveConfig.getBreakpoint(constraints.maxWidth);
        
        final maxWidth = customMaxWidth ?? 
            (constrainWidth ? breakpoint.containerMaxWidth : double.infinity);
        
        final padding = customPadding ?? 
            (applyPadding 
                ? EdgeInsets.symmetric(horizontal: breakpoint.containerPadding)
                : EdgeInsets.zero);

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Section container with responsive padding and max-width
class ResponsiveSection extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final bool fullWidth;

  const ResponsiveSection({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: backgroundColor,
      child: fullWidth
          ? Padding(
              padding: padding ?? EdgeInsets.zero,
              child: child,
            )
          : ResponsiveContainer(
              customPadding: padding,
              child: child,
            ),
    );
  }
}

/// Responsive padding widget
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final bool horizontal;
  final bool vertical;
  final double? multiplier;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.horizontal = true,
    this.vertical = true,
    this.multiplier,
  });

  const ResponsivePadding.horizontal({
    super.key,
    required this.child,
    this.multiplier,
  })  : horizontal = true,
        vertical = false;

  const ResponsivePadding.vertical({
    super.key,
    required this.child,
    this.multiplier,
  })  : horizontal = false,
        vertical = true;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final breakpoint = ResponsiveConfig.getBreakpoint(constraints.maxWidth);
        final basePadding = breakpoint.containerPadding;
        final actualPadding = multiplier != null 
            ? basePadding * multiplier! 
            : basePadding;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontal ? actualPadding : 0,
            vertical: vertical ? actualPadding : 0,
          ),
          child: child,
        );
      },
    );
  }
}

/// Responsive spacing widget
class ResponsiveSpacing extends StatelessWidget {
  final double? multiplier;
  final bool horizontal;

  const ResponsiveSpacing({
    super.key,
    this.multiplier,
  }) : horizontal = false;

  const ResponsiveSpacing.horizontal({
    super.key,
    this.multiplier,
  }) : horizontal = true;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final breakpoint = ResponsiveConfig.getBreakpoint(constraints.maxWidth);
        final baseSpacing = breakpoint.containerPadding / 2;
        final actualSpacing = multiplier != null 
            ? baseSpacing * multiplier! 
            : baseSpacing;

        return SizedBox(
          width: horizontal ? actualSpacing : 0,
          height: horizontal ? 0 : actualSpacing,
        );
      },
    );
  }
}
