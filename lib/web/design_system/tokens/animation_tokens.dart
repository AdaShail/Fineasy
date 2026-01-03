/// Design token system for animations
/// Provides timing and easing tokens for consistent animations
library;

import 'package:flutter/animation.dart';

/// Animation duration tokens
class AnimationDurationTokens {
  /// Instant (0ms) - No animation
  static const Duration instant = Duration.zero;

  /// Fast (150ms) - Quick transitions
  static const Duration fast = Duration(milliseconds: 150);

  /// Normal (300ms) - Default transitions
  static const Duration normal = Duration(milliseconds: 300);

  /// Slow (500ms) - Deliberate transitions
  static const Duration slow = Duration(milliseconds: 500);

  /// Slower (700ms) - Very deliberate transitions
  static const Duration slower = Duration(milliseconds: 700);

  /// Get duration by name
  static Duration getDuration(String name) {
    switch (name.toLowerCase()) {
      case 'instant':
        return instant;
      case 'fast':
        return fast;
      case 'normal':
        return normal;
      case 'slow':
        return slow;
      case 'slower':
        return slower;
      default:
        return normal;
    }
  }

  /// Get duration in milliseconds
  static int getDurationMs(String name) {
    return getDuration(name).inMilliseconds;
  }

  /// All duration values as a map
  static const Map<String, Duration> all = {
    'instant': instant,
    'fast': fast,
    'normal': normal,
    'slow': slow,
    'slower': slower,
  };
}

/// Animation easing (curve) tokens
class AnimationEasingTokens {
  /// Linear easing - Constant speed
  static const Curve linear = Curves.linear;

  /// Ease in - Slow start, fast end
  static const Curve easeIn = Curves.easeIn;

  /// Ease out - Fast start, slow end (recommended for entrances)
  static const Curve easeOut = Curves.easeOut;

  /// Ease in-out - Slow start and end
  static const Curve easeInOut = Curves.easeInOut;

  /// Spring - Natural bouncy motion
  static const Curve spring = Curves.elasticOut;

  /// Decelerate - Fast to slow (Material Design standard)
  static const Curve decelerate = Curves.decelerate;

  /// Accelerate - Slow to fast
  static const Curve accelerate = Curves.easeInOut;

  /// Fast out slow in - Material Design emphasized
  static const Curve fastOutSlowIn = Curves.fastOutSlowIn;

  /// Get curve by name
  static Curve getCurve(String name) {
    switch (name.toLowerCase()) {
      case 'linear':
        return linear;
      case 'easein':
        return easeIn;
      case 'easeout':
        return easeOut;
      case 'easeinout':
        return easeInOut;
      case 'spring':
        return spring;
      case 'decelerate':
        return decelerate;
      case 'accelerate':
        return accelerate;
      case 'fastoutslowIn':
        return fastOutSlowIn;
      default:
        return easeOut;
    }
  }

  /// All easing values as a map
  static const Map<String, Curve> all = {
    'linear': linear,
    'easeIn': easeIn,
    'easeOut': easeOut,
    'easeInOut': easeInOut,
    'spring': spring,
    'decelerate': decelerate,
    'accelerate': accelerate,
    'fastOutSlowIn': fastOutSlowIn,
  };
}

/// Semantic animation tokens for common use cases
class SemanticAnimations {
  /// Button hover animation
  static const Duration buttonHover = AnimationDurationTokens.fast;
  static const Curve buttonHoverCurve = AnimationEasingTokens.easeOut;

  /// Button press animation
  static const Duration buttonPress = AnimationDurationTokens.fast;
  static const Curve buttonPressCurve = AnimationEasingTokens.easeIn;

  /// Modal entrance animation
  static const Duration modalEntrance = AnimationDurationTokens.normal;
  static const Curve modalEntranceCurve = AnimationEasingTokens.easeOut;

  /// Modal exit animation
  static const Duration modalExit = AnimationDurationTokens.fast;
  static const Curve modalExitCurve = AnimationEasingTokens.easeIn;

  /// Page transition animation
  static const Duration pageTransition = AnimationDurationTokens.normal;
  static const Curve pageTransitionCurve = AnimationEasingTokens.fastOutSlowIn;

  /// Dropdown animation
  static const Duration dropdown = AnimationDurationTokens.fast;
  static const Curve dropdownCurve = AnimationEasingTokens.easeOut;

  /// Tooltip animation
  static const Duration tooltip = AnimationDurationTokens.fast;
  static const Curve tooltipCurve = AnimationEasingTokens.easeOut;

  /// Toast entrance animation
  static const Duration toastEntrance = AnimationDurationTokens.normal;
  static const Curve toastEntranceCurve = AnimationEasingTokens.spring;

  /// Toast exit animation
  static const Duration toastExit = AnimationDurationTokens.fast;
  static const Curve toastExitCurve = AnimationEasingTokens.easeIn;

  /// List item animation
  static const Duration listItem = AnimationDurationTokens.fast;
  static const Curve listItemCurve = AnimationEasingTokens.easeOut;

  /// Form validation animation (shake)
  static const Duration formValidation = AnimationDurationTokens.normal;
  static const Curve formValidationCurve = AnimationEasingTokens.spring;

  /// Loading spinner animation
  static const Duration loadingSpinner = Duration(milliseconds: 1000);
  static const Curve loadingSpinnerCurve = AnimationEasingTokens.linear;

  /// Skeleton screen animation
  static const Duration skeleton = Duration(milliseconds: 1500);
  static const Curve skeletonCurve = AnimationEasingTokens.linear;
}

/// Animation configuration helper
class AnimationConfig {
  final Duration duration;
  final Curve curve;

  const AnimationConfig({
    required this.duration,
    required this.curve,
  });

  /// Create animation config from semantic name
  static AnimationConfig fromSemantic(String name) {
    switch (name.toLowerCase()) {
      case 'buttonhover':
        return const AnimationConfig(
          duration: SemanticAnimations.buttonHover,
          curve: SemanticAnimations.buttonHoverCurve,
        );
      case 'buttonpress':
        return const AnimationConfig(
          duration: SemanticAnimations.buttonPress,
          curve: SemanticAnimations.buttonPressCurve,
        );
      case 'modalentrance':
        return const AnimationConfig(
          duration: SemanticAnimations.modalEntrance,
          curve: SemanticAnimations.modalEntranceCurve,
        );
      case 'modalexit':
        return const AnimationConfig(
          duration: SemanticAnimations.modalExit,
          curve: SemanticAnimations.modalExitCurve,
        );
      case 'pagetransition':
        return const AnimationConfig(
          duration: SemanticAnimations.pageTransition,
          curve: SemanticAnimations.pageTransitionCurve,
        );
      case 'dropdown':
        return const AnimationConfig(
          duration: SemanticAnimations.dropdown,
          curve: SemanticAnimations.dropdownCurve,
        );
      case 'tooltip':
        return const AnimationConfig(
          duration: SemanticAnimations.tooltip,
          curve: SemanticAnimations.tooltipCurve,
        );
      case 'toastentrance':
        return const AnimationConfig(
          duration: SemanticAnimations.toastEntrance,
          curve: SemanticAnimations.toastEntranceCurve,
        );
      case 'toastexit':
        return const AnimationConfig(
          duration: SemanticAnimations.toastExit,
          curve: SemanticAnimations.toastExitCurve,
        );
      case 'listitem':
        return const AnimationConfig(
          duration: SemanticAnimations.listItem,
          curve: SemanticAnimations.listItemCurve,
        );
      case 'formvalidation':
        return const AnimationConfig(
          duration: SemanticAnimations.formValidation,
          curve: SemanticAnimations.formValidationCurve,
        );
      default:
        return const AnimationConfig(
          duration: AnimationDurationTokens.normal,
          curve: AnimationEasingTokens.easeOut,
        );
    }
  }
}
