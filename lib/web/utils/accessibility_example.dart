import 'package:flutter/material.dart';
import 'accessibility_preferences.dart';
import 'focus_management.dart';
import 'screen_reader_support.dart';
import '../services/accessibility_service.dart';

/// Example screen demonstrating accessibility features
class AccessibilityExampleScreen extends StatefulWidget {
  const AccessibilityExampleScreen({super.key});

  @override
  State<AccessibilityExampleScreen> createState() => _AccessibilityExampleScreenState();
}

class _AccessibilityExampleScreenState extends State<AccessibilityExampleScreen>
    with
        TickerProviderStateMixin,
        FocusManagementMixin,
        ScreenReaderAnnouncementMixin,
        AccessibilityPreferencesMixin {
  final _accessibilityService = AccessibilityService();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _showModal = false;
  late FocusNode _modalFocusNode;

  @override
  void initState() {
    super.initState();
    _modalFocusNode = FocusNode();
    registerFocusNode(_modalFocusNode);

    // Announce page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      announceNavigation('Accessibility Example Screen');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SemanticStructure.heading(
          text: 'Accessibility Features',
          level: 1,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Skip Links
              _buildSkipLinks(),
              const SizedBox(height: 24),

              // WCAG Compliance Section
              _buildWCAGSection(),
              const SizedBox(height: 24),

              // Focus Management Section
              _buildFocusSection(),
              const SizedBox(height: 24),

              // Screen Reader Section
              _buildScreenReaderSection(),
              const SizedBox(height: 24),

              // Accessibility Preferences Section
              _buildPreferencesSection(),
              const SizedBox(height: 24),

              // Accessible Form Example
              _buildAccessibleForm(),
              const SizedBox(height: 24),

              // Modal Example
              _buildModalExample(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipLinks() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SemanticStructure.heading(
              text: 'Skip Links',
              level: 2,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('Skip links help keyboard users bypass repetitive content.'),
            const SizedBox(height: 16),
            SkipLinksContainer(
              links: [
                SkipLinkData(
                  label: 'Skip to main content',
                  onPressed: () {
                    announceSuccess('Skipped to main content');
                  },
                ),
                SkipLinkData(
                  label: 'Skip to navigation',
                  onPressed: () {
                    announceSuccess('Skipped to navigation');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWCAGSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SemanticStructure.heading(
              text: 'WCAG Compliance',
              level: 2,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('Check color contrast and other WCAG requirements.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final report = _accessibilityService.runWCAGComplianceCheck(context);
                announceComplete('WCAG compliance check');
                _showComplianceReport(report);
              },
              child: const Text('Run WCAG Compliance Check'),
            ),
            const SizedBox(height: 16),
            _buildColorContrastExample(),
          ],
        ),
      ),
    );
  }

  Widget _buildColorContrastExample() {
    final goodContrast = _accessibilityService.hasValidContrast(
      Colors.black,
      Colors.white,
    );
    final badContrast = !_accessibilityService.hasValidContrast(
      Colors.grey.shade400,
      Colors.white,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Color Contrast Examples:'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.white,
          child: Text(
            'Good Contrast (Black on White) ${goodContrast ? '✓' : '✗'}',
            style: const TextStyle(color: Colors.black),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.white,
          child: Text(
            'Poor Contrast (Grey on White) ${badContrast ? '✗' : '✓'}',
            style: TextStyle(color: Colors.grey.shade400),
          ),
        ),
      ],
    );
  }

  Widget _buildFocusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SemanticStructure.heading(
              text: 'Focus Management',
              level: 2,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('Visible focus indicators and keyboard navigation.'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                EnhancedFocusIndicator(
                  child: ElevatedButton(
                    onPressed: () {
                      announceSuccess('Button 1 pressed');
                    },
                    child: const Text('Button 1'),
                  ),
                ),
                EnhancedFocusIndicator(
                  child: ElevatedButton(
                    onPressed: () {
                      announceSuccess('Button 2 pressed');
                    },
                    child: const Text('Button 2'),
                  ),
                ),
                EnhancedFocusIndicator(
                  child: ElevatedButton(
                    onPressed: () {
                      announceSuccess('Button 3 pressed');
                    },
                    child: const Text('Button 3'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenReaderSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SemanticStructure.heading(
              text: 'Screen Reader Support',
              level: 2,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('Semantic HTML and ARIA live regions.'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AccessibleButton(
                  semanticLabel: 'Announce success message',
                  tooltip: 'Click to hear a success announcement',
                  onPressed: () {
                    announceSuccess('Operation completed successfully');
                  },
                  child: const Text('Announce Success'),
                ),
                AccessibleButton(
                  semanticLabel: 'Announce error message',
                  tooltip: 'Click to hear an error announcement',
                  onPressed: () {
                    announceError('An error occurred');
                  },
                  child: const Text('Announce Error'),
                ),
                AccessibleButton(
                  semanticLabel: 'Announce loading',
                  tooltip: 'Click to hear a loading announcement',
                  onPressed: () {
                    announceLoading('data');
                  },
                  child: const Text('Announce Loading'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAccessibleImageExample(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessibleImageExample() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Accessible Image Example:'),
        const SizedBox(height: 8),
        AccessibleImage(
          image: const AssetImage('assets/example.png'),
          altText: 'Example image showing accessibility features',
          width: 200,
          height: 150,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            AccessibleIcon(
              icon: Icons.check_circle,
              label: 'Success icon',
              color: Colors.green,
            ),
            const SizedBox(width: 8),
            AccessibleIcon(
              icon: Icons.error,
              label: 'Error icon',
              color: Colors.red,
            ),
            const SizedBox(width: 8),
            AccessibleIcon(
              icon: Icons.info,
              label: 'Information icon',
              color: Colors.blue,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SemanticStructure.heading(
              text: 'Accessibility Preferences',
              level: 2,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('Customize your accessibility experience.'),
            const SizedBox(height: 16),
            const AccessibilitySettingsPanel(),
            const SizedBox(height: 16),
            _buildAnimationExample(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationExample() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Animation Example (respects reduced motion):'),
        const SizedBox(height: 8),
        ReducedMotionWidget(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: Container(
              width: 100,
              height: 100,
              color: Colors.blue,
              child: const Center(
                child: Text(
                  'Animated',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          reducedChild: Container(
            width: 100,
            height: 100,
            color: Colors.blue,
            child: const Center(
              child: Text(
                'Static',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccessibleForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SemanticStructure.heading(
                text: 'Accessible Form',
                level: 2,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text('Form with proper labels and validation.'),
              const SizedBox(height: 16),
              AccessibleTextField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'Enter your email',
                required: true,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              AccessibleCheckbox(
                value: true,
                onChanged: (value) {},
                label: 'I agree to the terms and conditions',
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    announceSuccess('Form submitted successfully');
                  } else {
                    announceError('Please fix form errors');
                  }
                },
                child: const Text('Submit Form'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalExample() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SemanticStructure.heading(
              text: 'Modal with Focus Trap',
              level: 2,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('Modal that traps focus and returns it on close.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                storeFocus();
                setState(() {
                  _showModal = true;
                });
                announceSuccess('Modal opened');
              },
              child: const Text('Open Modal'),
            ),
            if (_showModal)
              FocusReturnScope(
                child: FocusTrap(
                  focusNode: _modalFocusNode,
                  child: Dialog(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('This is a modal with focus trap'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _showModal = false;
                              });
                              restoreFocus();
                              announceSuccess('Modal closed');
                            },
                            child: const Text('Close Modal'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showComplianceReport(WCAGComplianceReport report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('WCAG Compliance Report'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Compliance Level: ${report.complianceLevel.name.toUpperCase()}'),
              Text('Passed Checks: ${report.passedChecks}'),
              Text('Violations: ${report.violations.length}'),
              Text('Compliance: ${report.compliancePercentage.toStringAsFixed(1)}%'),
              const SizedBox(height: 16),
              if (report.violations.isNotEmpty) ...[
                const Text('Violations:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...report.violations.map((v) => Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('• ${v.message} (${v.wcagCriterion})'),
                    )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
