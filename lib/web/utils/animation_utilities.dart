/// Animation utilities for web UX
/// Provides hooks, transition utilities, spring animations, and queue management
library;

import 'dart:math' show sqrt, exp, cos;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../design_system/tokens/animation_tokens.dart';

/// Animation hook for managing animation controllers with timing control
class AnimationHook {
  final TickerProvider vsync;
  final Duration duration;
  final Curve curve;
  late final AnimationController controller;
  late final Animation<double> animation;

  AnimationHook({
    required this.vsync,
    Duration? duration,
    Curve? curve,
  })  : duration = duration ?? AnimationDurationTokens.normal,
        curve = curve ?? AnimationEasingTokens.easeOut {
    controller = AnimationController(
      vsync: vsync,
      duration: this.duration,
    );
    animation = CurvedAnimation(
      parent: controller,
      curve: this.curve,
    );
  }

  /// Start the animation forward
  void forward() => controller.forward();

  /// Start the animation in reverse
  void reverse() => controller.reverse();

  /// Reset the animation to the beginning
  void reset() => controller.reset();

  /// Stop the animation
  void stop() => controller.stop();

  /// Animate to a specific value
  void animateTo(double value) => controller.animateTo(value);

  /// Dispose the controller
  void dispose() => controller.dispose();

  /// Get the current value
  double get value => animation.value;

  /// Check if animation is running
  bool get isAnimating => controller.isAnimating;

  /// Check if animation is completed
  bool get isCompleted => controller.isCompleted;

  /// Check if animation is dismissed
  bool get isDismissed => controller.isDismissed;
}

/// Transition utilities for common animation patterns
class TransitionUtilities {
  /// Fade transition builder
  static Widget fade({
    required Animation<double> animation,
    required Widget child,
    Curve? curve,
  }) {
    final curvedAnimation = curve != null
        ? CurvedAnimation(parent: animation, curve: curve)
        : animation;

    return FadeTransition(
      opacity: curvedAnimation,
      child: child,
    );
  }

  /// Scale transition builder
  static Widget scale({
    required Animation<double> animation,
    required Widget child,
    Curve? curve,
    Alignment alignment = Alignment.center,
  }) {
    final curvedAnimation = curve != null
        ? CurvedAnimation(parent: animation, curve: curve)
        : animation;

    return ScaleTransition(
      scale: curvedAnimation,
      alignment: alignment,
      child: child,
    );
  }

  /// Slide transition builder
  static Widget slide({
    required Animation<double> animation,
    required Widget child,
    Offset begin = const Offset(0, 1),
    Offset end = Offset.zero,
    Curve? curve,
  }) {
    final curvedAnimation = curve != null
        ? CurvedAnimation(parent: animation, curve: curve)
        : animation;

    return SlideTransition(
      position: Tween<Offset>(begin: begin, end: end).animate(curvedAnimation),
      child: child,
    );
  }

  /// Rotation transition builder
  static Widget rotate({
    required Animation<double> animation,
    required Widget child,
    Curve? curve,
    Alignment alignment = Alignment.center,
  }) {
    final curvedAnimation = curve != null
        ? CurvedAnimation(parent: animation, curve: curve)
        : animation;

    return RotationTransition(
      turns: curvedAnimation,
      alignment: alignment,
      child: child,
    );
  }

  /// Size transition builder
  static Widget size({
    required Animation<double> animation,
    required Widget child,
    Curve? curve,
    Axis axis = Axis.vertical,
    double axisAlignment = 0.0,
  }) {
    final curvedAnimation = curve != null
        ? CurvedAnimation(parent: animation, curve: curve)
        : animation;

    return SizeTransition(
      sizeFactor: curvedAnimation,
      axis: axis,
      axisAlignment: axisAlignment,
      child: child,
    );
  }

  /// Combined fade and scale transition
  static Widget fadeScale({
    required Animation<double> animation,
    required Widget child,
    Curve? curve,
    double scaleBegin = 0.8,
  }) {
    final curvedAnimation = curve != null
        ? CurvedAnimation(parent: animation, curve: curve)
        : animation;

    return FadeTransition(
      opacity: curvedAnimation,
      child: ScaleTransition(
        scale: Tween<double>(begin: scaleBegin, end: 1.0).animate(curvedAnimation),
        child: child,
      ),
    );
  }

  /// Combined fade and slide transition
  static Widget fadeSlide({
    required Animation<double> animation,
    required Widget child,
    Offset begin = const Offset(0, 0.2),
    Curve? curve,
  }) {
    final curvedAnimation = curve != null
        ? CurvedAnimation(parent: animation, curve: curve)
        : animation;

    return FadeTransition(
      opacity: curvedAnimation,
      child: SlideTransition(
        position: Tween<Offset>(begin: begin, end: Offset.zero).animate(curvedAnimation),
        child: child,
      ),
    );
  }
}

/// Spring animation support with customizable physics
class SpringAnimation {
  final TickerProvider vsync;
  late final AnimationController controller;
  late final Animation<double> animation;

  SpringAnimation({
    required this.vsync,
    double mass = 1.0,
    double stiffness = 100.0,
    double damping = 10.0,
  }) {
    controller = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 500),
    );

    final spring = SpringDescription(
      mass: mass,
      stiffness: stiffness,
      damping: damping,
    );

    animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: SpringCurve(spring),
      ),
    );
  }

  /// Start the spring animation
  void start() => controller.forward(from: 0.0);

  /// Dispose the controller
  void dispose() => controller.dispose();

  /// Get the current value
  double get value => animation.value;
}

/// Custom spring curve implementation
class SpringCurve extends Curve {
  final SpringDescription spring;

  const SpringCurve(this.spring);

  @override
  double transformInternal(double t) {
    return _springMotion(t, spring);
  }

  double _springMotion(double time, SpringDescription spring) {
    final double dampingRatio = spring.damping / (2.0 * sqrt(spring.mass * spring.stiffness));
    final double angularFreq = sqrt(spring.stiffness / spring.mass);

    if (dampingRatio < 1.0) {
      // Under-damped
      final double dampedFreq = angularFreq * sqrt(1.0 - dampingRatio * dampingRatio);
      final double envelope = exp(-dampingRatio * angularFreq * time);
      return 1.0 - envelope * cos(dampedFreq * time);
    } else if (dampingRatio == 1.0) {
      // Critically damped
      final double envelope = exp(-angularFreq * time);
      return 1.0 - envelope * (1.0 + angularFreq * time);
    } else {
      // Over-damped
      final double r1 = -angularFreq * (dampingRatio + sqrt(dampingRatio * dampingRatio - 1.0));
      final double r2 = -angularFreq * (dampingRatio - sqrt(dampingRatio * dampingRatio - 1.0));
      final double c1 = 1.0 / (r1 - r2);
      final double c2 = -c1;
      return 1.0 - (c1 * exp(r1 * time) + c2 * exp(r2 * time));
    }
  }
}

/// Animation queue item
class AnimationQueueItem {
  final String id;
  final VoidCallback animation;
  final Duration delay;
  final VoidCallback? onComplete;

  AnimationQueueItem({
    required this.id,
    required this.animation,
    this.delay = Duration.zero,
    this.onComplete,
  });
}

/// Animation queue manager for sequencing animations
class AnimationQueueManager {
  final List<AnimationQueueItem> _queue = [];
  bool _isProcessing = false;

  /// Add an animation to the queue
  void enqueue(AnimationQueueItem item) {
    _queue.add(item);
    if (!_isProcessing) {
      _processQueue();
    }
  }

  /// Add multiple animations to the queue
  void enqueueAll(List<AnimationQueueItem> items) {
    _queue.addAll(items);
    if (!_isProcessing) {
      _processQueue();
    }
  }

  /// Clear the queue
  void clear() {
    _queue.clear();
  }

  /// Check if queue is empty
  bool get isEmpty => _queue.isEmpty;

  /// Get queue length
  int get length => _queue.length;

  /// Process the queue sequentially
  Future<void> _processQueue() async {
    if (_isProcessing || _queue.isEmpty) return;

    _isProcessing = true;

    while (_queue.isNotEmpty) {
      final item = _queue.removeAt(0);

      // Wait for delay
      if (item.delay > Duration.zero) {
        await Future.delayed(item.delay);
      }

      // Execute animation
      item.animation();

      // Call completion callback
      item.onComplete?.call();

      // Small delay between animations
      await Future.delayed(const Duration(milliseconds: 50));
    }

    _isProcessing = false;
  }

  /// Execute animations in parallel
  Future<void> executeParallel(List<AnimationQueueItem> items) async {
    await Future.wait(
      items.map((item) async {
        if (item.delay > Duration.zero) {
          await Future.delayed(item.delay);
        }
        item.animation();
        item.onComplete?.call();
      }),
    );
  }
}

/// Staggered animation helper
class StaggeredAnimationHelper {
  final TickerProvider vsync;
  final Duration totalDuration;
  final int itemCount;
  late final AnimationController controller;
  late final List<Animation<double>> animations;

  StaggeredAnimationHelper({
    required this.vsync,
    required this.totalDuration,
    required this.itemCount,
    Curve curve = Curves.easeOut,
  }) {
    controller = AnimationController(
      vsync: vsync,
      duration: totalDuration,
    );

    animations = List.generate(itemCount, (index) {
      final start = (index / itemCount);
      final end = ((index + 1) / itemCount).clamp(0.0, 1.0);

      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: curve),
        ),
      );
    });
  }

  /// Start the staggered animation
  void start() => controller.forward(from: 0.0);

  /// Reverse the staggered animation
  void reverse() => controller.reverse();

  /// Reset the animation
  void reset() => controller.reset();

  /// Dispose the controller
  void dispose() => controller.dispose();

  /// Get animation for specific index
  Animation<double> getAnimation(int index) {
    return animations[index];
  }
}

/// Reduced motion detector
class ReducedMotionDetector {
  /// Check if user prefers reduced motion
  static bool prefersReducedMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }

  /// Get duration based on reduced motion preference
  static Duration getDuration(BuildContext context, Duration normalDuration) {
    return prefersReducedMotion(context) ? Duration.zero : normalDuration;
  }

  /// Get curve based on reduced motion preference
  static Curve getCurve(BuildContext context, Curve normalCurve) {
    return prefersReducedMotion(context) ? Curves.linear : normalCurve;
  }
}

/// Animation builder widget with reduced motion support
class WebAnimatedBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, Animation<double> animation) builder;
  final Duration duration;
  final Curve curve;
  final bool autoStart;

  const WebAnimatedBuilder({
    super.key,
    required this.builder,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
    this.autoStart = true,
  });

  @override
  State<WebAnimatedBuilder> createState() => _WebAnimatedBuilderState();
}

class _WebAnimatedBuilderState extends State<WebAnimatedBuilder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    if (widget.autoStart) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = ReducedMotionDetector.getDuration(context, widget.duration);
    if (duration == Duration.zero) {
      _controller.value = 1.0;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => widget.builder(context, _animation),
    );
  }
}
