/// Design token system for spacing
/// Provides a consistent mathematical progression for spacing values
library;

/// Spacing scale tokens with mathematical progression
class SpacingTokens {
  /// 0px - No spacing
  static const double space0 = 0.0;

  /// 4px - Smallest spacing unit
  static const double space1 = 4.0;

  /// 8px - Small spacing
  static const double space2 = 8.0;

  /// 12px - Medium-small spacing
  static const double space3 = 12.0;

  /// 16px - Base spacing unit
  static const double space4 = 16.0;

  /// 20px - Medium spacing
  static const double space5 = 20.0;

  /// 24px - Medium-large spacing
  static const double space6 = 24.0;

  /// 32px - Large spacing
  static const double space8 = 32.0;

  /// 40px - Extra large spacing
  static const double space10 = 40.0;

  /// 48px - 2X large spacing
  static const double space12 = 48.0;

  /// 64px - 3X large spacing
  static const double space16 = 64.0;

  /// 80px - 4X large spacing
  static const double space20 = 80.0;

  /// 96px - 5X large spacing
  static const double space24 = 96.0;

  /// 128px - Maximum spacing
  static const double space32 = 128.0;

  /// Get spacing value by index
  static double getSpace(int index) {
    switch (index) {
      case 0:
        return space0;
      case 1:
        return space1;
      case 2:
        return space2;
      case 3:
        return space3;
      case 4:
        return space4;
      case 5:
        return space5;
      case 6:
        return space6;
      case 8:
        return space8;
      case 10:
        return space10;
      case 12:
        return space12;
      case 16:
        return space16;
      case 20:
        return space20;
      case 24:
        return space24;
      case 32:
        return space32;
      default:
        return space4; // Default to base spacing
    }
  }

  /// Get spacing value by name
  static double getSpaceByName(String name) {
    switch (name.toLowerCase()) {
      case 'none':
      case '0':
        return space0;
      case 'xs':
      case '1':
        return space1;
      case 'sm':
      case '2':
        return space2;
      case 'md':
      case '3':
        return space3;
      case 'base':
      case '4':
        return space4;
      case '5':
        return space5;
      case 'lg':
      case '6':
        return space6;
      case 'xl':
      case '8':
        return space8;
      case '2xl':
      case '10':
        return space10;
      case '3xl':
      case '12':
        return space12;
      case '4xl':
      case '16':
        return space16;
      case '5xl':
      case '20':
        return space20;
      case '6xl':
      case '24':
        return space24;
      case '7xl':
      case '32':
        return space32;
      default:
        return space4;
    }
  }

  /// All spacing values as a map
  static const Map<String, double> all = {
    '0': space0,
    '1': space1,
    '2': space2,
    '3': space3,
    '4': space4,
    '5': space5,
    '6': space6,
    '8': space8,
    '10': space10,
    '12': space12,
    '16': space16,
    '20': space20,
    '24': space24,
    '32': space32,
  };
}

/// Semantic spacing tokens for common use cases
class SemanticSpacing {
  /// Spacing between inline elements (4px)
  static const double inline = SpacingTokens.space1;

  /// Spacing between small components (8px)
  static const double compact = SpacingTokens.space2;

  /// Default spacing between elements (16px)
  static const double normal = SpacingTokens.space4;

  /// Spacing between sections (24px)
  static const double section = SpacingTokens.space6;

  /// Spacing between major sections (48px)
  static const double major = SpacingTokens.space12;

  /// Page padding on mobile (16px)
  static const double pagePaddingMobile = SpacingTokens.space4;

  /// Page padding on tablet (24px)
  static const double pagePaddingTablet = SpacingTokens.space6;

  /// Page padding on desktop (32px)
  static const double pagePaddingDesktop = SpacingTokens.space8;

  /// Card padding (16px)
  static const double cardPadding = SpacingTokens.space4;

  /// Modal padding (24px)
  static const double modalPadding = SpacingTokens.space6;

  /// Form field spacing (12px)
  static const double formFieldSpacing = SpacingTokens.space3;

  /// Button padding horizontal (16px)
  static const double buttonPaddingHorizontal = SpacingTokens.space4;

  /// Button padding vertical (8px)
  static const double buttonPaddingVertical = SpacingTokens.space2;
}
