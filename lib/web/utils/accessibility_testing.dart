import 'package:flutter/material.dart';
import '../services/accessibility_service.dart';

/// Utility for testing accessibility compliance
class AccessibilityTesting {
  final AccessibilityService _service = AccessibilityService();

  /// Test results
  final List<AccessibilityIssue> issues = [];

  /// Check widget tree for accessibility issues
  Future<AccessibilityReport> checkAccessibility(
    BuildContext context,
    Widget widget,
  ) async {
    issues.clear();

    // Check color contrast
    _checkColorContrast(context);

    // Check touch target sizes
    _checkTouchTargetSizes(context);

    // Check semantic labels
    _checkSemanticLabels(context);

    // Check keyboard navigation
    _checkKeyboardNavigation(context);

    return AccessibilityReport(
      totalIssues: issues.length,
      criticalIssues: issues.where((i) => i.severity == Severity.critical).length,
      warningIssues: issues.where((i) => i.severity == Severity.warning).length,
      infoIssues: issues.where((i) => i.severity == Severity.info).length,
      issues: List.unmodifiable(issues),
    );
  }

  void _checkColorContrast(BuildContext context) {
    final theme = Theme.of(context);
    
    // Check primary text contrast
    if (!_service.hasValidContrast(
      theme.textTheme.bodyLarge?.color ?? Colors.black,
      theme.scaffoldBackgroundColor,
    )) {
      issues.add(AccessibilityIssue(
        type: IssueType.colorContrast,
        severity: Severity.critical,
        message: 'Insufficient color contrast for body text',
        recommendation: 'Ensure text has at least 4.5:1 contrast ratio with background',
      ));
    }

    // Check button contrast
    if (!_service.hasValidContrast(
      theme.colorScheme.onPrimary,
      theme.colorScheme.primary,
    )) {
      issues.add(AccessibilityIssue(
        type: IssueType.colorContrast,
        severity: Severity.critical,
        message: 'Insufficient color contrast for primary buttons',
        recommendation: 'Ensure button text has at least 4.5:1 contrast ratio',
      ));
    }
  }

  void _checkTouchTargetSizes(BuildContext context) {
    // This would require widget tree traversal in a real implementation
    // For now, we'll add a general recommendation
    issues.add(AccessibilityIssue(
      type: IssueType.touchTarget,
      severity: Severity.info,
      message: 'Verify all interactive elements meet minimum size requirements',
      recommendation: 'Ensure all buttons and interactive elements are at least 44x44 pixels',
    ));
  }

  void _checkSemanticLabels(BuildContext context) {
    // This would require widget tree traversal in a real implementation
    issues.add(AccessibilityIssue(
      type: IssueType.semantics,
      severity: Severity.info,
      message: 'Verify all interactive elements have semantic labels',
      recommendation: 'Add Semantics widgets with appropriate labels to all interactive elements',
    ));
  }

  void _checkKeyboardNavigation(BuildContext context) {
    // This would require testing keyboard navigation in a real implementation
    issues.add(AccessibilityIssue(
      type: IssueType.keyboard,
      severity: Severity.info,
      message: 'Verify keyboard navigation is fully functional',
      recommendation: 'Test that all interactive elements can be accessed via keyboard',
    ));
  }

  /// Generate HTML report
  String generateHtmlReport(AccessibilityReport report) {
    final buffer = StringBuffer();
    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html lang="en">');
    buffer.writeln('<head>');
    buffer.writeln('<meta charset="UTF-8">');
    buffer.writeln('<title>Accessibility Report</title>');
    buffer.writeln('<style>');
    buffer.writeln('body { font-family: Arial, sans-serif; margin: 20px; }');
    buffer.writeln('.critical { color: #d32f2f; }');
    buffer.writeln('.warning { color: #f57c00; }');
    buffer.writeln('.info { color: #1976d2; }');
    buffer.writeln('.issue { margin: 10px 0; padding: 10px; border-left: 4px solid; }');
    buffer.writeln('</style>');
    buffer.writeln('</head>');
    buffer.writeln('<body>');
    buffer.writeln('<h1>Accessibility Report</h1>');
    buffer.writeln('<p>Total Issues: ${report.totalIssues}</p>');
    buffer.writeln('<p>Critical: ${report.criticalIssues}</p>');
    buffer.writeln('<p>Warnings: ${report.warningIssues}</p>');
    buffer.writeln('<p>Info: ${report.infoIssues}</p>');
    
    for (final issue in report.issues) {
      final severityClass = issue.severity.toString().split('.').last;
      buffer.writeln('<div class="issue $severityClass">');
      buffer.writeln('<h3>${issue.type.toString().split('.').last}</h3>');
      buffer.writeln('<p><strong>Severity:</strong> ${issue.severity.toString().split('.').last}</p>');
      buffer.writeln('<p><strong>Message:</strong> ${issue.message}</p>');
      buffer.writeln('<p><strong>Recommendation:</strong> ${issue.recommendation}</p>');
      buffer.writeln('</div>');
    }
    
    buffer.writeln('</body>');
    buffer.writeln('</html>');
    
    return buffer.toString();
  }
}

/// Accessibility issue
class AccessibilityIssue {
  final IssueType type;
  final Severity severity;
  final String message;
  final String recommendation;

  const AccessibilityIssue({
    required this.type,
    required this.severity,
    required this.message,
    required this.recommendation,
  });
}

/// Type of accessibility issue
enum IssueType {
  colorContrast,
  touchTarget,
  semantics,
  keyboard,
  focusIndicator,
  screenReader,
}

/// Severity of accessibility issue
enum Severity {
  critical,
  warning,
  info,
}

/// Accessibility report
class AccessibilityReport {
  final int totalIssues;
  final int criticalIssues;
  final int warningIssues;
  final int infoIssues;
  final List<AccessibilityIssue> issues;

  const AccessibilityReport({
    required this.totalIssues,
    required this.criticalIssues,
    required this.warningIssues,
    required this.infoIssues,
    required this.issues,
  });

  bool get hasIssues => totalIssues > 0;
  bool get hasCriticalIssues => criticalIssues > 0;
  
  double get score {
    if (totalIssues == 0) return 100.0;
    
    final criticalWeight = criticalIssues * 10;
    final warningWeight = warningIssues * 5;
    final infoWeight = infoIssues * 1;
    
    final totalWeight = criticalWeight + warningWeight + infoWeight;
    return (100 - totalWeight).clamp(0, 100).toDouble();
  }
}
