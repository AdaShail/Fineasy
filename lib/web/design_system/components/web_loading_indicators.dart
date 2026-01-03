/// Loading indicator components for web platform
/// 
/// Provides spinner, progress bar, skeleton screens, and loading overlays
/// to indicate loading states and improve perceived performance.
/// 
/// Requirements: 8.1, 8.2, 8.6, 8.8

library;

import 'package:flutter/material.dart';
import '../tokens/design_tokens.dart';

/// Spinner size variants
enum SpinnerSize {
  small(16.0),
  medium(24.0),
  large(32.0),
  xlarge(48.0);

  final double size;
  const SpinnerSize(this.size);
}

/// Web spinner component with size variants
class WebSpinner extends StatelessWidget {
  final SpinnerSize size;
  final Color? color;
  final double? strokeWidth;

  const WebSpinner({
    super.key,
    this.size = SpinnerSize.medium,
    this.color,
    this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens.light;
    final effectiveColor = color ?? tokens.colors.primary.shade500;
    final effectiveStrokeWidth = strokeWidth ?? (size.size / 8);

    return SizedBox(
      width: size.size,
      height: size.size,
      child: CircularProgressIndicator(
        strokeWidth: effectiveStrokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(effectiveColor),
      ),
    );
  }
}

/// Progress bar component with percentage display
class WebProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final bool showPercentage;
  final BorderRadius? borderRadius;

  const WebProgressBar({
    super.key,
    required this.value,
    this.height = 8.0,
    this.backgroundColor,
    this.progressColor,
    this.showPercentage = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens.light;
    final effectiveBgColor = backgroundColor ?? tokens.colors.neutral.shade200;
    final effectiveProgressColor = progressColor ?? tokens.colors.primary.shade500;
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(tokens.borderRadius['base']!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            color: effectiveBgColor,
            borderRadius: effectiveBorderRadius,
          ),
          child: ClipRRect(
            borderRadius: effectiveBorderRadius,
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(effectiveProgressColor),
            ),
          ),
        ),
        if (showPercentage) ...[
          SizedBox(height: tokens.spacing['s2']!),
          Text(
            '${(value * 100).toInt()}%',
            style: TextStyle(
              fontSize: 12,
              color: tokens.colors.neutral.shade600,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ],
    );
  }
}

/// Skeleton screen component for loading states
class WebSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool animate;

  const WebSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.animate = true,
  });

  @override
  State<WebSkeleton> createState() => _WebSkeletonState();
}

class _WebSkeletonState extends State<WebSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens.light;
    final effectiveBorderRadius = widget.borderRadius ?? BorderRadius.circular(tokens.borderRadius['base']!);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: effectiveBorderRadius,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                tokens.colors.neutral.shade200,
                tokens.colors.neutral.shade100,
                tokens.colors.neutral.shade200,
              ],
              stops: [
                (_animation.value - 0.5).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.5).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton text line
class SkeletonText extends StatelessWidget {
  final double? width;
  final double height;

  const SkeletonText({
    super.key,
    this.width,
    this.height = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return WebSkeleton(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(4),
    );
  }
}

/// Skeleton card layout
class SkeletonCard extends StatelessWidget {
  final double? width;
  final double? height;

  const SkeletonCard({
    super.key,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens.light;

    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(tokens.spacing['s4']!),
      decoration: BoxDecoration(
        color: tokens.colors.surface.card,
        borderRadius: BorderRadius.circular(tokens.borderRadius['lg']!),
        border: Border.all(color: tokens.colors.neutral.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              WebSkeleton(
                width: 48,
                height: 48,
                borderRadius: BorderRadius.circular(tokens.borderRadius['full']!),
              ),
              SizedBox(width: tokens.spacing['s3']!),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonText(width: 120, height: 16),
                    SizedBox(height: tokens.spacing['s2']!),
                    SkeletonText(width: 80, height: 12),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing['s4']!),
          SkeletonText(height: 14),
          SizedBox(height: tokens.spacing['s2']!),
          SkeletonText(width: 200, height: 14),
          SizedBox(height: tokens.spacing['s2']!),
          SkeletonText(width: 150, height: 14),
        ],
      ),
    );
  }
}

/// Skeleton list
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsets? padding;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens.light;

    return ListView.separated(
      padding: padding,
      itemCount: itemCount,
      separatorBuilder: (context, index) => SizedBox(height: tokens.spacing['s3']!),
      itemBuilder: (context, index) {
        return SkeletonCard(height: itemHeight);
      },
    );
  }
}

/// Loading overlay component
class WebLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? overlayColor;
  final double opacity;

  const WebLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.overlayColor,
    this.opacity = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: (overlayColor ?? Colors.white).withOpacity(opacity),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const WebSpinner(size: SpinnerSize.large),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        message!,
                        style: TextStyle(
                          fontSize: 16,
                          color: DesignTokens.light.colors.neutral.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Full screen loading indicator
class FullScreenLoader extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;

  const FullScreenLoader({
    super.key,
    this.message,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens.light;

    return Scaffold(
      backgroundColor: backgroundColor ?? tokens.colors.surface.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const WebSpinner(size: SpinnerSize.xlarge),
            if (message != null) ...[
              SizedBox(height: tokens.spacing['s4']!),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 16,
                  color: tokens.colors.neutral.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Inline loading indicator for buttons
class InlineLoader extends StatelessWidget {
  final SpinnerSize size;
  final Color? color;

  const InlineLoader({
    super.key,
    this.size = SpinnerSize.small,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return WebSpinner(size: size, color: color);
  }
}

/// Loading state wrapper
class LoadingStateWrapper extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Widget? loadingWidget;
  final bool showOverlay;

  const LoadingStateWrapper({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingWidget,
    this.showOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showOverlay) {
      return WebLoadingOverlay(
        isLoading: isLoading,
        child: child,
      );
    }

    if (isLoading) {
      return loadingWidget ?? const FullScreenLoader();
    }

    return child;
  }
}

/// Skeleton table
class SkeletonTable extends StatelessWidget {
  final int rows;
  final int columns;
  final double rowHeight;

  const SkeletonTable({
    super.key,
    this.rows = 5,
    this.columns = 4,
    this.rowHeight = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens.light;

    return Column(
      children: List.generate(rows, (rowIndex) {
        return Container(
          height: rowHeight,
          padding: EdgeInsets.all(tokens.spacing['s3']!),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: tokens.colors.neutral.shade200),
            ),
          ),
          child: Row(
            children: List.generate(columns, (colIndex) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: tokens.spacing['s2']!),
                  child: SkeletonText(height: 16),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

/// Skeleton form
class SkeletonForm extends StatelessWidget {
  final int fieldCount;

  const SkeletonForm({
    super.key,
    this.fieldCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = DesignTokens.light;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(fieldCount, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: tokens.spacing['s4']!),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonText(width: 100, height: 14),
              SizedBox(height: tokens.spacing['s2']!),
              WebSkeleton(
                height: 48,
                borderRadius: BorderRadius.circular(tokens.borderRadius['base']!),
              ),
            ],
          ),
        );
      }),
    );
  }
}
