/// Design Token Configuration
/// Provides configuration and metadata for the design token system
library;

/// Token system metadata
class TokenSystemMetadata {
  static const String version = '1.0.0';
  static const String lastUpdated = '2024-01-01';
  
  /// Token categories available in the system
  static const List<String> categories = [
    'colors',
    'typography',
    'spacing',
    'shadows',
    'borderRadius',
    'animations',
  ];
  
  /// Supported theme modes
  static const List<String> themeModes = [
    'light',
    'dark',
    'system',
  ];
}

/// Token validation rules
class TokenValidationRules {
  /// Minimum color contrast ratio for WCAG AA compliance
  static const double minContrastRatioNormal = 4.5;
  static const double minContrastRatioLarge = 3.0;
  
  /// Maximum animation duration (ms)
  static const int maxAnimationDuration = 500;
  
  /// Minimum touch target size (px)
  static const double minTouchTargetSize = 44.0;
  
  /// Spacing scale progression
  static const List<double> spacingScale = [
    0, 4, 8, 12, 16, 20, 24, 32, 40, 48, 64, 80, 96, 128,
  ];
  
  /// Font size scale (px)
  static const List<double> fontSizeScale = [
    12, 14, 16, 18, 20, 24, 30, 36, 48, 60,
  ];
  
  /// Elevation levels
  static const List<int> elevationLevels = [0, 1, 2, 3, 4, 5];
  
  /// Border radius values (px)
  static const List<double> borderRadiusValues = [
    0, 4, 8, 12, 16, 24, 32, 9999,
  ];
}

/// Token naming conventions
class TokenNamingConventions {
  /// Color token naming pattern
  static const String colorPattern = 
      '{category}.shade{50-900}';
  
  /// Typography token naming pattern
  static const String typographyPattern = 
      '{property}.{size/weight/height}';
  
  /// Spacing token naming pattern
  static const String spacingPattern = 
      'space{0-32}';
  
  /// Shadow token naming pattern
  static const String shadowPattern = 
      '{none|sm|base|md|lg|xl|2xl|inner}';
  
  /// Border radius token naming pattern
  static const String borderRadiusPattern = 
      '{none|sm|base|md|lg|xl|2xl|full}';
  
  /// Animation token naming pattern
  static const String animationPattern = 
      '{instant|fast|normal|slow|slower}';
}

/// Token usage guidelines
class TokenUsageGuidelines {
  /// When to use each color category
  static const Map<String, String> colorUsage = {
    'primary': 'Main brand color for primary actions and key UI elements',
    'secondary': 'Secondary brand color for supporting elements',
    'accent': 'Accent color for highlights and special emphasis',
    'neutral': 'Grayscale for text, borders, and backgrounds',
    'success': 'Positive actions and success states',
    'warning': 'Caution and warning states',
    'error': 'Error states and destructive actions',
    'info': 'Informational messages and neutral notifications',
  };
  
  /// When to use each typography style
  static const Map<String, String> typographyUsage = {
    'h1': 'Page titles and hero headings',
    'h2': 'Section headings',
    'h3': 'Subsection headings',
    'h4': 'Card titles and minor headings',
    'h5': 'Small headings and labels',
    'h6': 'Smallest headings',
    'bodyLarge': 'Emphasized body text',
    'body': 'Default body text',
    'bodySmall': 'Secondary body text',
    'caption': 'Captions and helper text',
    'label': 'Form labels and UI labels',
    'code': 'Code snippets and monospace text',
  };
  
  /// When to use each spacing value
  static const Map<String, String> spacingUsage = {
    'space1': 'Inline elements, tight spacing',
    'space2': 'Small components, compact layouts',
    'space3': 'Form field spacing',
    'space4': 'Default spacing, card padding',
    'space6': 'Section spacing, modal padding',
    'space8': 'Large spacing, page padding',
    'space12': 'Major section spacing',
    'space16': 'Extra large spacing',
  };
  
  /// When to use each shadow level
  static const Map<String, String> shadowUsage = {
    'none': 'Flat elements, no elevation',
    'sm': 'Subtle elevation, slightly raised',
    'base': 'Default cards and buttons',
    'md': 'Dropdowns and popovers',
    'lg': 'Modals and dialogs',
    'xl': 'High elevation modals',
    '2xl': 'Maximum elevation overlays',
    'inner': 'Input fields, pressed states',
  };
  
  /// When to use each animation duration
  static const Map<String, String> animationUsage = {
    'instant': 'No animation, immediate changes',
    'fast': 'Quick transitions, hover effects',
    'normal': 'Default transitions, most animations',
    'slow': 'Deliberate transitions, important changes',
    'slower': 'Very deliberate, attention-grabbing',
  };
}

/// Token accessibility requirements
class TokenAccessibilityRequirements {
  /// WCAG AA color contrast requirements
  static const String colorContrast = 
      'All text must meet 4.5:1 contrast ratio (3:1 for large text)';
  
  /// Touch target size requirements
  static const String touchTargets = 
      'All interactive elements must be at least 44x44px';
  
  /// Animation requirements
  static const String animations = 
      'Respect prefers-reduced-motion setting, keep under 500ms';
  
  /// Typography requirements
  static const String typography = 
      'Support browser zoom up to 200%, minimum 16px for mobile inputs';
  
  /// Focus indicators
  static const String focusIndicators = 
      'All interactive elements must have visible focus indicators';
}

/// Token system configuration
class TokenSystemConfig {
  /// Enable strict validation
  static const bool strictValidation = true;
  
  /// Enable accessibility checks
  static const bool accessibilityChecks = true;
  
  /// Enable theme switching
  static const bool themeSwitching = true;
  
  /// Default theme mode
  static const String defaultThemeMode = 'system';
  
  /// Enable token caching
  static const bool enableCaching = true;
  
  /// Enable development warnings
  static const bool developmentWarnings = true;
}
