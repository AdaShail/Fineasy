/// Animation examples demonstrating usage of animation utilities
library;

import 'package:flutter/material.dart';
import 'component_animations.dart';
import 'loading_animations.dart';
import '../design_system/tokens/animation_tokens.dart';

/// Example screen demonstrating all animation utilities
class AnimationExamplesScreen extends StatefulWidget {
  const AnimationExamplesScreen({super.key});

  @override
  State<AnimationExamplesScreen> createState() => _AnimationExamplesScreenState();
}

class _AnimationExamplesScreenState extends State<AnimationExamplesScreen>
    with TickerProviderStateMixin {
  bool _showValidationError = false;
  bool _showValidationSuccess = false;
  double _progressValue = 0.0;

  @override
  void initState() {
    super.initState();
    
    // Simulate progress
    Future.delayed(const Duration(seconds: 1), () {
      _animateProgress();
    });
  }

  void _animateProgress() {
    if (!mounted) return;
    setState(() {
      _progressValue += 0.1;
      if (_progressValue > 1.0) _progressValue = 0.0;
    });
    Future.delayed(const Duration(milliseconds: 500), _animateProgress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animation Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Button Animations',
              _buildButtonExamples(),
            ),
            const SizedBox(height: 32),
            _buildSection(
              'Loading Animations',
              _buildLoadingExamples(),
            ),
            const SizedBox(height: 32),
            _buildSection(
              'Form Validation Animations',
              _buildFormValidationExamples(),
            ),
            const SizedBox(height: 32),
            _buildSection(
              'List Item Animations',
              _buildListItemExamples(),
            ),
            const SizedBox(height: 32),
            _buildSection(
              'Progress Animations',
              _buildProgressExamples(),
            ),
            const SizedBox(height: 32),
            _buildSection(
              'Skeleton Loading',
              _buildSkeletonExamples(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        content,
      ],
    );
  }

  Widget _buildButtonExamples() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        ButtonAnimations.animatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Primary button pressed')),
            );
          },
          backgroundColor: Colors.blue,
          child: const Text(
            'Primary Button',
            style: TextStyle(color: Colors.white),
          ),
        ),
        ButtonAnimations.animatedButton(
          onPressed: () {},
          backgroundColor: Colors.green,
          child: const Text(
            'Success Button',
            style: TextStyle(color: Colors.white),
          ),
        ),
        ButtonAnimations.animatedButton(
          onPressed: null,
          child: const Text(
            'Disabled Button',
            style: TextStyle(color: Colors.white),
          ),
        ),
        ButtonAnimations.animatedButton(
          onPressed: () {},
          isLoading: true,
          backgroundColor: Colors.orange,
          child: const Text(
            'Loading Button',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingExamples() {
    return Wrap(
      spacing: 32,
      runSpacing: 32,
      children: [
        const Column(
          children: [
            BrandedLoadingSpinner(
              size: 48,
              showLabel: true,
              label: 'Loading...',
            ),
            SizedBox(height: 8),
            Text('Branded Spinner'),
          ],
        ),
        const Column(
          children: [
            BrandedLoadingSpinner(
              size: 64,
              color: Colors.green,
              strokeWidth: 6,
            ),
            SizedBox(height: 8),
            Text('Custom Color'),
          ],
        ),
        const Column(
          children: [
            SizedBox(
              width: 200,
              child: IndeterminateProgressBar(
                height: 4,
              ),
            ),
            SizedBox(height: 8),
            Text('Indeterminate Progress'),
          ],
        ),
      ],
    );
  }

  Widget _buildFormValidationExamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showValidationError = !_showValidationError;
                  _showValidationSuccess = false;
                });
              },
              child: const Text('Toggle Error'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showValidationSuccess = !_showValidationSuccess;
                  _showValidationError = false;
                });
              },
              child: const Text('Toggle Success'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FormValidationAnimations.shake(
          trigger: _showValidationError,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: _showValidationError ? Colors.red : Colors.grey,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Sample Input Field'),
                ),
                FormValidationAnimations.errorIcon(
                  show: _showValidationError,
                ),
                FormValidationAnimations.checkmark(
                  show: _showValidationSuccess,
                ),
              ],
            ),
          ),
        ),
        FormValidationAnimations.errorMessage(
          message: _showValidationError ? 'This field is required' : null,
        ),
      ],
    );
  }

  Widget _buildListItemExamples() {
    return _StaggeredListExample();
  }

  Widget _buildProgressExamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Linear Progress Bar'),
        const SizedBox(height: 8),
        AnimatedProgressBar(
          progress: _progressValue,
          height: 8,
          showPercentage: true,
        ),
        const SizedBox(height: 24),
        const Text('Circular Progress'),
        const SizedBox(height: 8),
        CircularProgressIndicatorWithPercentage(
          progress: _progressValue,
          size: 100,
          strokeWidth: 8,
        ),
      ],
    );
  }

  Widget _buildSkeletonExamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Skeleton Card'),
        const SizedBox(height: 16),
        const SkeletonCard(
          width: 400,
          height: 200,
          showAvatar: true,
          lineCount: 3,
        ),
        const SizedBox(height: 24),
        const Text('Skeleton Text Lines'),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SkeletonText(width: 300),
            SizedBox(height: 8),
            SkeletonText(width: 250),
            SizedBox(height: 8),
            SkeletonText(width: 200),
          ],
        ),
      ],
    );
  }
}

/// Example of staggered list animation
class _StaggeredListExample extends StatefulWidget {
  @override
  State<_StaggeredListExample> createState() => _StaggeredListExampleState();
}

class _StaggeredListExampleState extends State<_StaggeredListExample>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<String> _items = [
    'Item 1',
    'Item 2',
    'Item 3',
    'Item 4',
    'Item 5',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: () {
            _controller.reset();
            _controller.forward();
          },
          child: const Text('Replay Animation'),
        ),
        const SizedBox(height: 16),
        ...List.generate(_items.length, (index) {
          final start = (index * 0.1).clamp(0.0, 1.0);
          final end = ((index + 1) * 0.1 + 0.5).clamp(0.0, 1.0);

          final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Interval(start, end, curve: Curves.easeOut),
            ),
          );

          return ListItemAnimations.slideIn(
            animation: animation,
            direction: SlideDirection.left,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(_items[index]),
            ),
          );
        }),
      ],
    );
  }
}

/// Example of animated hover container
class AnimatedHoverContainerExample extends StatelessWidget {
  const AnimatedHoverContainerExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        AnimatedHoverContainer(
          backgroundColor: Colors.white,
          hoverColor: Colors.blue.shade50,
          elevation: 2,
          hoverElevation: 8,
          padding: const EdgeInsets.all(24),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Card tapped')),
            );
          },
          child: const Column(
            children: [
              Icon(Icons.star, size: 48, color: Colors.blue),
              SizedBox(height: 8),
              Text('Hover Me'),
            ],
          ),
        ),
        AnimatedHoverContainer(
          backgroundColor: Colors.white,
          hoverColor: Colors.green.shade50,
          elevation: 2,
          hoverElevation: 8,
          padding: const EdgeInsets.all(24),
          onTap: () {},
          child: const Column(
            children: [
              Icon(Icons.favorite, size: 48, color: Colors.red),
              SizedBox(height: 8),
              Text('Interactive Card'),
            ],
          ),
        ),
      ],
    );
  }
}

/// Example of page transitions
class PageTransitionExample extends StatelessWidget {
  const PageTransitionExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) {
                  return PageTransitionAnimations.fadeSlide(
                    animation: animation,
                    child: const _SamplePage(title: 'Fade Slide'),
                    direction: SlideDirection.right,
                  );
                },
                transitionDuration: SemanticAnimations.pageTransition,
              ),
            );
          },
          child: const Text('Fade Slide Transition'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) {
                  return PageTransitionAnimations.scale(
                    animation: animation,
                    child: const _SamplePage(title: 'Scale'),
                  );
                },
                transitionDuration: SemanticAnimations.pageTransition,
              ),
            );
          },
          child: const Text('Scale Transition'),
        ),
      ],
    );
  }
}

class _SamplePage extends StatelessWidget {
  final String title;

  const _SamplePage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$title Transition'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'This page used $title transition',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
