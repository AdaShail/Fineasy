import 'package:flutter/widgets.dart';
import 'responsive_config.dart';

/// Fluid typography system that scales smoothly between breakpoints
class FluidTypography {
  /// Calculate fluid font size between two breakpoints
  static double fluidSize({
    required double currentWidth,
    required double minWidth,
    required double maxWidth,
    required double minSize,
    required double maxSize,
  }) {
    // Clamp width to min/max range
    final clampedWidth = currentWidth.clamp(minWidth, maxWidth);
    
    // Calculate the ratio of current width within the range
    final ratio = (clampedWidth - minWidth) / (maxWidth - minWidth);
    
    // Interpolate between min and max sizes
    return minSize + (maxSize - minSize) * ratio;
  }

  /// Get fluid font size for heading 1
  static double h1(double viewportWidth) {
    return fluidSize(
      currentWidth: viewportWidth,
      minWidth: ResponsiveConfig.mobile.minWidth,
      maxWidth: ResponsiveConfig.wide.minWidth,
      minSize: 32,
      maxSize: 60,
    );
  }

  /// Get fluid font size for heading 2
  static double h2(double viewportWidth) {
    return fluidSize(
      currentWidth: viewportWidth,
      minWidth: ResponsiveConfig.mobile.minWidth,
      maxWidth: ResponsiveConfig.wide.minWidth,
      minSize: 28,
      maxSize: 48,
    );
  }

  /// Get fluid font size for heading 3
  static double h3(double viewportWidth) {
    return fluidSize(
      currentWidth: viewportWidth,
      minWidth: ResponsiveConfig.mobile.minWidth,
      maxWidth: ResponsiveConfig.wide.minWidth,
      minSize: 24,
      maxSize: 36,
    );
  }

  /// Get fluid font size for heading 4
  static double h4(double viewportWidth) {
    return fluidSize(
      currentWidth: viewportWidth,
      minWidth: ResponsiveConfig.mobile.minWidth,
      maxWidth: ResponsiveConfig.wide.minWidth,
      minSize: 20,
      maxSize: 30,
    );
  }

  /// Get fluid font size for heading 5
  static double h5(double viewportWidth) {
    return fluidSize(
      currentWidth: viewportWidth,
      minWidth: ResponsiveConfig.mobile.minWidth,
      maxWidth: ResponsiveConfig.wide.minWidth,
      minSize: 18,
      maxSize: 24,
    );
  }

  /// Get fluid font size for heading 6
  static double h6(double viewportWidth) {
    return fluidSize(
      currentWidth: viewportWidth,
      minWidth: ResponsiveConfig.mobile.minWidth,
      maxWidth: ResponsiveConfig.wide.minWidth,
      minSize: 16,
      maxSize: 20,
    );
  }

  /// Get fluid font size for body text
  static double body(double viewportWidth) {
    return fluidSize(
      currentWidth: viewportWidth,
      minWidth: ResponsiveConfig.mobile.minWidth,
      maxWidth: ResponsiveConfig.wide.minWidth,
      minSize: 14,
      maxSize: 16,
    );
  }

  /// Get fluid font size for body large text
  static double bodyLarge(double viewportWidth) {
    return fluidSize(
      currentWidth: viewportWidth,
      minWidth: ResponsiveConfig.mobile.minWidth,
      maxWidth: ResponsiveConfig.wide.minWidth,
      minSize: 16,
      maxSize: 18,
    );
  }

  /// Get fluid font size for body small text
  static double bodySmall(double viewportWidth) {
    return fluidSize(
      currentWidth: viewportWidth,
      minWidth: ResponsiveConfig.mobile.minWidth,
      maxWidth: ResponsiveConfig.wide.minWidth,
      minSize: 12,
      maxSize: 14,
    );
  }

  /// Get fluid font size for caption text
  static double caption(double viewportWidth) {
    return fluidSize(
      currentWidth: viewportWidth,
      minWidth: ResponsiveConfig.mobile.minWidth,
      maxWidth: ResponsiveConfig.wide.minWidth,
      minSize: 11,
      maxSize: 12,
    );
  }

  /// Get fluid line height based on font size
  static double lineHeight(double fontSize) {
    // Larger text needs tighter line height
    if (fontSize >= 32) return 1.2;
    if (fontSize >= 24) return 1.3;
    if (fontSize >= 16) return 1.5;
    return 1.6;
  }

  /// Get fluid letter spacing based on font size
  static double letterSpacing(double fontSize) {
    // Larger text needs tighter letter spacing
    if (fontSize >= 32) return -0.5;
    if (fontSize >= 24) return -0.25;
    if (fontSize >= 16) return 0;
    return 0.15;
  }
}

/// Text style that scales fluidly with viewport
class FluidTextStyle extends TextStyle {
  FluidTextStyle.h1(double viewportWidth)
      : super(
          fontSize: FluidTypography.h1(viewportWidth),
          height: FluidTypography.lineHeight(FluidTypography.h1(viewportWidth)),
          letterSpacing: FluidTypography.letterSpacing(FluidTypography.h1(viewportWidth)),
          fontWeight: FontWeight.bold,
        );

  FluidTextStyle.h2(double viewportWidth)
      : super(
          fontSize: FluidTypography.h2(viewportWidth),
          height: FluidTypography.lineHeight(FluidTypography.h2(viewportWidth)),
          letterSpacing: FluidTypography.letterSpacing(FluidTypography.h2(viewportWidth)),
          fontWeight: FontWeight.bold,
        );

  FluidTextStyle.h3(double viewportWidth)
      : super(
          fontSize: FluidTypography.h3(viewportWidth),
          height: FluidTypography.lineHeight(FluidTypography.h3(viewportWidth)),
          letterSpacing: FluidTypography.letterSpacing(FluidTypography.h3(viewportWidth)),
          fontWeight: FontWeight.w600,
        );

  FluidTextStyle.h4(double viewportWidth)
      : super(
          fontSize: FluidTypography.h4(viewportWidth),
          height: FluidTypography.lineHeight(FluidTypography.h4(viewportWidth)),
          letterSpacing: FluidTypography.letterSpacing(FluidTypography.h4(viewportWidth)),
          fontWeight: FontWeight.w600,
        );

  FluidTextStyle.h5(double viewportWidth)
      : super(
          fontSize: FluidTypography.h5(viewportWidth),
          height: FluidTypography.lineHeight(FluidTypography.h5(viewportWidth)),
          letterSpacing: FluidTypography.letterSpacing(FluidTypography.h5(viewportWidth)),
          fontWeight: FontWeight.w500,
        );

  FluidTextStyle.h6(double viewportWidth)
      : super(
          fontSize: FluidTypography.h6(viewportWidth),
          height: FluidTypography.lineHeight(FluidTypography.h6(viewportWidth)),
          letterSpacing: FluidTypography.letterSpacing(FluidTypography.h6(viewportWidth)),
          fontWeight: FontWeight.w500,
        );

  FluidTextStyle.body(double viewportWidth)
      : super(
          fontSize: FluidTypography.body(viewportWidth),
          height: FluidTypography.lineHeight(FluidTypography.body(viewportWidth)),
          letterSpacing: FluidTypography.letterSpacing(FluidTypography.body(viewportWidth)),
          fontWeight: FontWeight.normal,
        );

  FluidTextStyle.bodyLarge(double viewportWidth)
      : super(
          fontSize: FluidTypography.bodyLarge(viewportWidth),
          height: FluidTypography.lineHeight(FluidTypography.bodyLarge(viewportWidth)),
          letterSpacing: FluidTypography.letterSpacing(FluidTypography.bodyLarge(viewportWidth)),
          fontWeight: FontWeight.normal,
        );

  FluidTextStyle.bodySmall(double viewportWidth)
      : super(
          fontSize: FluidTypography.bodySmall(viewportWidth),
          height: FluidTypography.lineHeight(FluidTypography.bodySmall(viewportWidth)),
          letterSpacing: FluidTypography.letterSpacing(FluidTypography.bodySmall(viewportWidth)),
          fontWeight: FontWeight.normal,
        );

  FluidTextStyle.caption(double viewportWidth)
      : super(
          fontSize: FluidTypography.caption(viewportWidth),
          height: FluidTypography.lineHeight(FluidTypography.caption(viewportWidth)),
          letterSpacing: FluidTypography.letterSpacing(FluidTypography.caption(viewportWidth)),
          fontWeight: FontWeight.normal,
        );
}

/// Widget that provides fluid text styling
class FluidText extends StatelessWidget {
  final String text;
  final FluidTextStyle Function(double) styleBuilder;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const FluidText(
    this.text, {
    super.key,
    required this.styleBuilder,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  factory FluidText.h1(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return FluidText(
      text,
      key: key,
      styleBuilder: (width) => FluidTextStyle.h1(width),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory FluidText.h2(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return FluidText(
      text,
      key: key,
      styleBuilder: (width) => FluidTextStyle.h2(width),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory FluidText.h3(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return FluidText(
      text,
      key: key,
      styleBuilder: (width) => FluidTextStyle.h3(width),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  factory FluidText.body(
    String text, {
    Key? key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return FluidText(
      text,
      key: key,
      styleBuilder: (width) => FluidTextStyle.body(width),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Text(
          text,
          style: styleBuilder(constraints.maxWidth),
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}
