# Design Token System

This directory contains the complete design token system for the Fineasy web application. Design tokens are the visual design atoms of the design system — specifically, they are named entities that store visual design attributes.

## Overview

The design token system provides:

- **Color Tokens**: Complete color palettes with light and dark theme variants
- **Typography Tokens**: Font families, sizes, weights, line heights, and letter spacing
- **Spacing Tokens**: Consistent mathematical progression for spacing values
- **Shadow Tokens**: Elevation levels using shadows and z-index values
- **Border Radius Tokens**: Consistent border radius values for components
- **Animation Tokens**: Timing functions and durations for transitions

## File Structure

```
tokens/
├── color_tokens.dart          # Color palette and theme variants
├── typography_tokens.dart     # Typography scale and text styles
├── spacing_tokens.dart        # Spacing scale with mathematical progression
├── shadow_tokens.dart         # Shadow and elevation definitions
├── border_radius_tokens.dart  # Border radius values
├── animation_tokens.dart      # Animation timing and easing
├── design_tokens.dart         # Main export and utilities
└── README.md                  # This file
```

## Usage

### Importing Tokens

```dart
import 'package:fineasy/web/design_system/tokens/design_tokens.dart';
```

### Using Color Tokens

```dart
// Access light theme colors
final primaryColor = LightColorTokens.primary.shade500;
final successColor = LightColorTokens.success.shade500;

// Access dark theme colors
final darkPrimaryColor = DarkColorTokens.primary.shade500;

// Access via design tokens
final tokens = DesignTokens.light;
final cardColor = tokens.colors.surface.card;
```

### Using Typography Tokens

```dart
// Use predefined text styles
Text(
  'Heading',
  style: TextStylePresets.h1(color: Colors.black),
);

// Access font sizes
final fontSize = FontSizeTokens.xl;

// Access font weights
final fontWeight = FontWeightTokens.bold;
```

### Using Spacing Tokens

```dart
// Use spacing values
Container(
  padding: EdgeInsets.all(SpacingTokens.space4),
  margin: EdgeInsets.symmetric(
    horizontal: SpacingTokens.space6,
    vertical: SpacingTokens.space3,
  ),
);

// Use semantic spacing
Container(
  padding: EdgeInsets.all(SemanticSpacing.cardPadding),
);

// Use spacing utilities
SizedBox(height: SpacingTokens.space4);
```

### Using Shadow Tokens

```dart
// Apply shadows to containers
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    boxShadow: ShadowTokens.md,
  ),
);

// Use elevation
Material(
  elevation: ElevationTokens.level3,
  child: Container(...),
);
```

### Using Border Radius Tokens

```dart
// Apply border radius
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(BorderRadiusTokens.base),
  ),
);

// Use semantic border radius
Container(
  decoration: BoxDecoration(
    borderRadius: SemanticBorderRadius.get('card'),
  ),
);
```

### Using Animation Tokens

```dart
// Create animated transitions
AnimatedContainer(
  duration: AnimationDurationTokens.normal,
  curve: AnimationEasingTokens.easeOut,
  // ... other properties
);

// Use semantic animations
AnimatedContainer(
  duration: SemanticAnimations.buttonHover,
  curve: SemanticAnimations.buttonHoverCurve,
  // ... other properties
);
```

### Using Context Extensions

```dart
// Access tokens via BuildContext
Widget build(BuildContext context) {
  return Container(
    color: context.colors.primary.shade500,
    padding: EdgeInsets.all(context.spacing('4')),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(context.borderRadius('base')),
      boxShadow: context.shadow('md'),
    ),
  );
}
```

## Token Categories

### Color Tokens

- **Primary**: Main brand color (blue)
- **Secondary**: Secondary brand color (purple)
- **Accent**: Accent color (green)
- **Neutral**: Grayscale from white to black
- **Semantic**: Success, warning, error, info colors
- **Surface**: Background, foreground, card, overlay, elevated

Each color family has shades from 50 (lightest) to 900 (darkest).

### Typography Tokens

- **Font Families**: Sans (Inter), Serif (Merriweather), Mono (JetBrains Mono)
- **Font Sizes**: xs (12px) to 6xl (60px)
- **Font Weights**: Light (300) to Extrabold (800)
- **Line Heights**: None (1.0) to Loose (2.0)
- **Letter Spacing**: Tighter (-0.05em) to Widest (0.1em)

### Spacing Tokens

Mathematical progression: 0, 4, 8, 12, 16, 20, 24, 32, 40, 48, 64, 80, 96, 128px

### Shadow Tokens

Elevation levels: none, sm, base, md, lg, xl, 2xl, inner

### Border Radius Tokens

Values: none (0), sm (4px), base (8px), md (12px), lg (16px), xl (24px), 2xl (32px), full (9999px)

### Animation Tokens

- **Durations**: instant (0ms), fast (150ms), normal (300ms), slow (500ms), slower (700ms)
- **Easing**: linear, easeIn, easeOut, easeInOut, spring, decelerate, accelerate, fastOutSlowIn

## Theme Support

The design token system supports both light and dark themes:

```dart
// Get tokens for current theme
final tokens = context.tokens;

// Explicitly use light theme
final lightTokens = DesignTokens.light;

// Explicitly use dark theme
final darkTokens = DesignTokens.dark;
```

## Best Practices

1. **Always use tokens**: Never hardcode colors, sizes, or spacing values
2. **Use semantic tokens**: Prefer semantic tokens (e.g., `SemanticSpacing.cardPadding`) over raw values
3. **Consistent naming**: Follow the established naming conventions
4. **Theme awareness**: Always consider both light and dark themes
5. **Accessibility**: Ensure color contrast meets WCAG AA standards (4.5:1 for normal text)

## Validation Requirements

Per the design document, the token system must satisfy:

- **Property 1**: Complete color palette with all required categories and shade ranges
- **Property 2**: Complete typography configuration with all required properties

## Adding New Tokens

When adding new tokens:

1. Add the token value to the appropriate file
2. Update the export in `design_tokens.dart` if needed
3. Add documentation to this README
4. Ensure both light and dark theme variants are provided
5. Test with actual components

## References

- Design Document: `.kiro/specs/web-ux-specifications/design.md`
- Requirements: `.kiro/specs/web-ux-specifications/requirements.md`
- Tasks: `.kiro/specs/web-ux-specifications/tasks.md`
