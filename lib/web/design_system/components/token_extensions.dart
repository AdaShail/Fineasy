import 'package:flutter/material.dart';
import '../tokens/design_tokens.dart';
import '../tokens/typography_tokens.dart';

/// Extension to add convenient token access methods to DesignTokens
extension DesignTokensExtension on DesignTokens {
  /// Spacing shortcuts with convenient property access
  SpacingShortcuts get space => SpacingShortcuts(this);
  
  /// Typography shortcuts with convenient text style access
  TypographyShortcuts get text => TypographyShortcuts(this);
  
  /// Animation shortcuts with convenient duration and curve access
  AnimationShortcuts get anim => AnimationShortcuts(this);
  
  /// Border radius shortcuts
  BorderRadiusShortcuts get radius => BorderRadiusShortcuts(this);
}

/// Spacing shortcuts for easier access
class SpacingShortcuts {
  final DesignTokens tokens;
  
  SpacingShortcuts(this.tokens);
  
  double get s0 => tokens.spacing['0']!;
  double get s1 => tokens.spacing['1']!;
  double get s2 => tokens.spacing['2']!;
  double get s3 => tokens.spacing['3']!;
  double get s4 => tokens.spacing['4']!;
  double get s5 => tokens.spacing['5']!;
  double get s6 => tokens.spacing['6']!;
  double get s8 => tokens.spacing['8']!;
  double get s10 => tokens.spacing['10']!;
  double get s12 => tokens.spacing['12']!;
  double get s16 => tokens.spacing['16']!;
  double get s20 => tokens.spacing['20']!;
  double get s24 => tokens.spacing['24']!;
  double get s32 => tokens.spacing['32']!;
}

/// Typography shortcuts for easier access
class TypographyShortcuts {
  final DesignTokens tokens;
  
  TypographyShortcuts(this.tokens);
  
  TextStyle get h1 => TextStylePresets.h1();
  TextStyle get h2 => TextStylePresets.h2();
  TextStyle get h3 => TextStylePresets.h3();
  TextStyle get h4 => TextStylePresets.h4();
  TextStyle get h5 => TextStylePresets.h5();
  TextStyle get h6 => TextStylePresets.h6();
  TextStyle get bodyLg => TextStylePresets.bodyLarge();
  TextStyle get bodyMd => TextStylePresets.body();
  TextStyle get bodySm => TextStylePresets.bodySmall();
  TextStyle get caption => TextStylePresets.caption();
  TextStyle get label => TextStylePresets.label();
  TextStyle get code => TextStylePresets.code();
}

/// Animation shortcuts for easier access
class AnimationShortcuts {
  final DesignTokens tokens;
  
  AnimationShortcuts(this.tokens);
  
  DurationShortcuts get duration => DurationShortcuts(tokens);
  CurveShortcuts get easing => CurveShortcuts(tokens);
}

class DurationShortcuts {
  final DesignTokens tokens;
  
  DurationShortcuts(this.tokens);
  
  Duration get instant => tokens.animationDuration['instant']!;
  Duration get fast => tokens.animationDuration['fast']!;
  Duration get normal => tokens.animationDuration['normal']!;
  Duration get slow => tokens.animationDuration['slow']!;
  Duration get slower => tokens.animationDuration['slower']!;
}

class CurveShortcuts {
  final DesignTokens tokens;
  
  CurveShortcuts(this.tokens);
  
  Curve get linear => tokens.animationEasing['linear']!;
  Curve get easeIn => tokens.animationEasing['easeIn']!;
  Curve get easeOut => tokens.animationEasing['easeOut']!;
  Curve get easeInOut => tokens.animationEasing['easeInOut']!;
}

/// Extension to add convenient color access methods to ColorTokens
extension ColorTokensExtension on ColorTokens {
  /// Get semantic colors
  ColorShades get success => semantic.success;
  ColorShades get warning => semantic.warning;
  ColorShades get error => semantic.error;
  ColorShades get info => semantic.info;
}

/// Extension to add convenient shade access methods to ColorShades
extension ColorShadesExtension on ColorShades {
  Color get s50 => shade50;
  Color get s100 => shade100;
  Color get s200 => shade200;
  Color get s300 => shade300;
  Color get s400 => shade400;
  Color get s500 => shade500;
  Color get s600 => shade600;
  Color get s700 => shade700;
  Color get s800 => shade800;
  Color get s900 => shade900;
}

/// Extension to add convenient shade access methods to NeutralColors
extension NeutralColorsExtension on NeutralColors {
  Color get s0 => shade0;
  Color get s50 => shade50;
  Color get s100 => shade100;
  Color get s200 => shade200;
  Color get s300 => shade300;
  Color get s400 => shade400;
  Color get s500 => shade500;
  Color get s600 => shade600;
  Color get s700 => shade700;
  Color get s800 => shade800;
  Color get s900 => shade900;
  Color get s1000 => shade1000;
}

/// Extension to add convenient font weight access methods to TypographyTokens
extension TypographyTokensExtension on TypographyTokens {
  FontWeightShortcuts get fontWeight => FontWeightShortcuts(this);
}

class FontWeightShortcuts {
  final TypographyTokens tokens;
  
  FontWeightShortcuts(this.tokens);
  
  FontWeight get light => tokens.fontWeight['light']!;
  FontWeight get normal => tokens.fontWeight['normal']!;
  FontWeight get medium => tokens.fontWeight['medium']!;
  FontWeight get semibold => tokens.fontWeight['semibold']!;
  FontWeight get bold => tokens.fontWeight['bold']!;
  FontWeight get extrabold => tokens.fontWeight['extrabold']!;
}

/// Extension to add convenient border radius access methods
extension BorderRadiusMapExtension on Map<String, double> {
  double get sm => this['sm']!;
  double get base => this['base']!;
  double get md => this['md']!;
  double get lg => this['lg']!;
  double get xl => this['xl']!;
  double get full => this['full']!;
}

/// Extension to add convenient border radius access to DesignTokens
extension DesignTokensBorderRadiusExtension on DesignTokens {
  BorderRadiusShortcuts get borderRadiusShortcuts => BorderRadiusShortcuts(this);
}

class BorderRadiusShortcuts {
  final DesignTokens tokens;
  
  BorderRadiusShortcuts(this.tokens);
  
  double get sm => tokens.borderRadius['sm']!;
  double get base => tokens.borderRadius['base']!;
  double get md => tokens.borderRadius['md']!;
  double get lg => tokens.borderRadius['lg']!;
  double get xl => tokens.borderRadius['xl']!;
  double get full => tokens.borderRadius['full']!;
}
