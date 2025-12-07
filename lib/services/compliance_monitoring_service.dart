import 'dart:async';
import '../models/business_health_models.dart';
import 'ai_client_service.dart';
import 'business_context_service.dart';

/// Service for monitoring regulatory compliance and automating corrective actions
class ComplianceMonitoringService {
  final AIClientService _aiClient;
  final BusinessContextService _businessContext;

  // Compliance monitoring streams
  final StreamController<ComplianceStatus> _complianceController =
      StreamController.broadcast();
  final StreamController<ComplianceIssue> _issueController =
      StreamController.broadcast();
  final StreamController<RegulatoryChange> _regulatoryController =
      StreamController.broadcast();

  // Internal state
  final Map<String, ComplianceStatus> _complianceStatuses = {};
  final Map<String, RegulatoryRequirement> _requirements = {};
  final List<ComplianceIssue> _activeIssues = [];
  Timer? _monitoringTimer;

  ComplianceMonitoringService({
    required AIClientService aiClient,
    required BusinessContextService businessContext,
  }) : _aiClient = aiClient,
       _businessContext = businessContext;

  // Streams for real-time updates
  Stream<ComplianceStatus> get complianceUpdates =>
      _complianceController.stream;
  Stream<ComplianceIssue> get issues => _issueController.stream;
  Stream<RegulatoryChange> get regulatoryChanges =>
      _regulatoryController.stream;

  /// Start compliance monitoring
  Future<void> startMonitoring({
    Duration interval = const Duration(hours: 12),
  }) async {
    _monitoringTimer?.cancel();

    // Initialize regulatory requirements
    await _initializeRequirements();

    // Set up periodic monitoring
    _monitoringTimer = Timer.periodic(interval, (_) async {
      await _runComplianceCheck();
    });

    // Run initial compliance check
    await _runComplianceCheck();
  }

  /// Stop compliance monitoring
  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
  }

  /// Initialize regulatory requirements based on business context
  Future<void> _initializeRequirements() async {
    try {
      // Note: In a real implementation, businessId would be passed from initialization
      // For now, using a placeholder businessId
      final businessId = 'default_business';
      final context = await _businessContext.getCurrentContext(businessId);

      // Extract business type from operational metrics or use default
      final businessType =
          context["operationalMetrics"]['business_type'] as String? ?? 'general';

      // Initialize requirements based on business type and location
      await _loadGSTRequirements();
      await _loadTaxRequirements();
      await _loadLaborRequirements();
      await _loadDataProtectionRequirements();
      await _loadIndustrySpecificRequirements(businessType);
    } catch (e) {
      print('Error initializing compliance requirements: $e');
    }
  }

  /// Load GST compliance requirements
  Future<void> _loadGSTRequirements() async {
    _requirements['gst'] = RegulatoryRequirement(
      id: 'gst',
      name: 'Goods and Services Tax (GST)',
      category: ComplianceCategory.tax,
      description: 'GST registration, filing, and payment requirements',
      applicability: 'Businesses with turnover > ₹20 lakhs',
      requirements: [
        'GST registration within 30 days of crossing threshold',
        'Monthly GSTR-1 filing by 11th of next month',
        'Monthly GSTR-3B filing by 20th of next month',
        'Annual GSTR-9 filing by 31st December',
        'GST payment by 20th of next month',
      ],
      penalties: {
        'late_filing': '₹200 per day (max ₹5,000)',
        'late_payment': '18% interest per annum',
        'non_registration': '10% of tax amount or ₹10,000',
      },
      deadlines: _generateGSTDeadlines(),
      lastUpdated: DateTime.now(),
    );
  }

  /// Load income tax requirements
  Future<void> _loadTaxRequirements() async {
    _requirements['income_tax'] = RegulatoryRequirement(
      id: 'income_tax',
      name: 'Income Tax',
      category: ComplianceCategory.tax,
      description: 'Income tax filing and payment requirements',
      applicability: 'All businesses with taxable income',
      requirements: [
        'ITR filing by 31st July (individuals) or 31st October (companies)',
        'Advance tax payment in quarterly installments',
        'TDS compliance for applicable transactions',
        'Audit requirements for businesses with turnover > ₹1 crore',
      ],
      penalties: {
        'late_filing': '₹5,000 (individuals) or ₹10,000 (companies)',
        'late_payment': '1% per month interest',
      },
      deadlines: _generateTaxDeadlines(),
      lastUpdated: DateTime.now(),
    );
  }

  /// Load labor law requirements
  Future<void> _loadLaborRequirements() async {
    _requirements['labor'] = RegulatoryRequirement(
      id: 'labor',
      name: 'Labor Laws',
      category: ComplianceCategory.labor,
      description: 'Employee-related compliance requirements',
      applicability: 'Businesses with employees',
      requirements: [
        'PF registration for businesses with 20+ employees',
        'ESI registration for businesses with 10+ employees',
        'Professional tax registration',
        'Minimum wage compliance',
        'Working hours and overtime regulations',
      ],
      penalties: {
        'pf_non_compliance': '₹10,000 fine + 12% interest',
        'esi_non_compliance': '₹25,000 fine',
      },
      deadlines: _generateLaborDeadlines(),
      lastUpdated: DateTime.now(),
    );
  }

  /// Load data protection requirements
  Future<void> _loadDataProtectionRequirements() async {
    _requirements['data_protection'] = RegulatoryRequirement(
      id: 'data_protection',
      name: 'Data Protection',
      category: ComplianceCategory.dataProtection,
      description: 'Data privacy and protection compliance',
      applicability: 'Businesses handling personal data',
      requirements: [
        'Privacy policy implementation',
        'Data consent management',
        'Data breach notification procedures',
        'Data retention and deletion policies',
        'Cross-border data transfer compliance',
      ],
      penalties: {
        'data_breach': 'Up to ₹15 crores or 4% of turnover',
        'non_compliance': 'Up to ₹5 crores or 2% of turnover',
      },
      deadlines: _generateDataProtectionDeadlines(),
      lastUpdated: DateTime.now(),
    );
  }

  /// Load industry-specific requirements
  Future<void> _loadIndustrySpecificRequirements(String businessType) async {
    if (businessType.toLowerCase().contains('fintech') ||
        businessType.toLowerCase().contains('financial')) {
      _requirements['rbi'] = RegulatoryRequirement(
        id: 'rbi',
        name: 'RBI Compliance',
        category: ComplianceCategory.financial,
        description: 'Reserve Bank of India regulations for financial services',
        applicability: 'Financial services businesses',
        requirements: [
          'RBI license for applicable services',
          'KYC and AML compliance',
          'Data localization requirements',
          'Audit and reporting requirements',
        ],
        penalties: {
          'non_compliance': 'License cancellation + monetary penalties',
        },
        deadlines: _generateRBIDeadlines(),
        lastUpdated: DateTime.now(),
      );
    }
  }

  /// Run comprehensive compliance check
  Future<void> _runComplianceCheck() async {
    try {
      // Note: In a real implementation, businessId would be passed from initialization
      // For now, using a placeholder businessId
      final businessId = 'default_business';
      final context = await _businessContext.getCurrentContext(businessId);

      // Check each regulatory requirement
      for (final requirement in _requirements.values) {
        final status = await _checkRequirementCompliance(requirement, context);
        _complianceStatuses[requirement.id] = status;
        _complianceController.add(status);

        // Handle any issues found
        for (final issue in status.issues) {
          if (!issue.isResolved) {
            _activeIssues.add(issue);
            _issueController.add(issue);

            // Attempt automated corrective action
            await _attemptAutomatedCorrection(issue, requirement);
          }
        }
      }

      // Monitor for regulatory changes
      await _monitorRegulatoryChanges();
    } catch (e) {
      print('Error running compliance check: $e');
    }
  }

  /// Check compliance for a specific requirement
  Future<ComplianceStatus> _checkRequirementCompliance(
    RegulatoryRequirement requirement,
    Map<String, dynamic> context,
  ) async {
    final issues = <ComplianceIssue>[];
    var level = ComplianceLevel.compliant;

    try {
      // Check different aspects based on requirement type
      switch (requirement.category) {
        case ComplianceCategory.tax:
          issues.addAll(await _checkTaxCompliance(requirement, context));
          break;
        case ComplianceCategory.labor:
          issues.addAll(await _checkLaborCompliance(requirement, context));
          break;
        case ComplianceCategory.dataProtection:
          issues.addAll(
            await _checkDataProtectionCompliance(requirement, context),
          );
          break;
        case ComplianceCategory.financial:
          issues.addAll(await _checkFinancialCompliance(requirement, context));
          break;
        case ComplianceCategory.environmental:
          issues.addAll(
            await _checkEnvironmentalCompliance(requirement, context),
          );
          break;
      }

      // Determine overall compliance level
      level = _determineComplianceLevel(issues);
    } catch (e) {
      print('Error checking compliance for ${requirement.id}: $e');
      level = ComplianceLevel.unknown;
    }

    return ComplianceStatus(
      id: '${requirement.id}_${DateTime.now().millisecondsSinceEpoch}',
      regulationType: requirement.name,
      level: level,
      description: _generateComplianceDescription(requirement, level, issues),
      issues: issues,
      requiredActions: _generateRequiredActions(issues),
      lastChecked: DateTime.now(),
      nextReview: _calculateNextReview(requirement),
      metadata: {
        'requirement_id': requirement.id,
        'total_issues': issues.length,
        'critical_issues':
            issues.where((i) => i.severity == IssueSeverity.critical).length,
      },
    );
  }

  /// Check tax compliance
  Future<List<ComplianceIssue>> _checkTaxCompliance(
    RegulatoryRequirement requirement,
    Map<String, dynamic> context,
  ) async {
    final issues = <ComplianceIssue>[];
    final financialData = context["financialState"];

    if (requirement.id == 'gst') {
      // Check GST registration
      final turnover = financialData['annualTurnover'] as double? ?? 0.0;
      final isGSTRegistered =
          context["complianceStatus"]['gst_registered'] as bool? ?? false;

      if (turnover > 2000000 && !isGSTRegistered) {
        // ₹20 lakhs threshold
        issues.add(
          ComplianceIssue(
            id: 'gst_registration_required',
            title: 'GST Registration Required',
            description:
                'Business turnover exceeds ₹20 lakhs, GST registration is mandatory',
            severity: IssueSeverity.critical,
            deadline: DateTime.now().add(const Duration(days: 30)),
            correctiveAction: 'Register for GST within 30 days',
          ),
        );
      }

      // Check GST filing deadlines
      final lastGSTFiling =
          context["complianceStatus"]['last_gst_filing'] as String?;
      if (lastGSTFiling != null) {
        final lastFilingDate = DateTime.parse(lastGSTFiling);
        final currentMonth = DateTime.now();
        final expectedFilingDate = DateTime(
          currentMonth.year,
          currentMonth.month,
          20,
        );

        if (currentMonth.isAfter(expectedFilingDate) &&
            lastFilingDate.isBefore(expectedFilingDate)) {
          issues.add(
            ComplianceIssue(
              id: 'gst_filing_overdue',
              title: 'GST Filing Overdue',
              description: 'GSTR-3B filing is overdue for current month',
              severity: IssueSeverity.high,
              deadline: expectedFilingDate,
              correctiveAction: 'File GSTR-3B immediately to avoid penalties',
            ),
          );
        }
      }
    }

    return issues;
  }

  /// Check labor compliance
  Future<List<ComplianceIssue>> _checkLaborCompliance(
    RegulatoryRequirement requirement,
    Map<String, dynamic> context,
  ) async {
    final issues = <ComplianceIssue>[];
    final employeeCount =
        context["operationalMetrics"]['employee_count'] as int? ?? 0;

    // Check PF registration
    if (employeeCount >= 20) {
      final isPFRegistered =
          context["complianceStatus"]['pf_registered'] as bool? ?? false;
      if (!isPFRegistered) {
        issues.add(
          ComplianceIssue(
            id: 'pf_registration_required',
            title: 'PF Registration Required',
            description:
                'Business has 20+ employees, PF registration is mandatory',
            severity: IssueSeverity.critical,
            deadline: DateTime.now().add(const Duration(days: 30)),
            correctiveAction: 'Register for Provident Fund',
          ),
        );
      }
    }

    // Check ESI registration
    if (employeeCount >= 10) {
      final isESIRegistered =
          context["complianceStatus"]['esi_registered'] as bool? ?? false;
      if (!isESIRegistered) {
        issues.add(
          ComplianceIssue(
            id: 'esi_registration_required',
            title: 'ESI Registration Required',
            description:
                'Business has 10+ employees, ESI registration is mandatory',
            severity: IssueSeverity.critical,
            deadline: DateTime.now().add(const Duration(days: 30)),
            correctiveAction: 'Register for Employee State Insurance',
          ),
        );
      }
    }

    return issues;
  }

  /// Check data protection compliance
  Future<List<ComplianceIssue>> _checkDataProtectionCompliance(
    RegulatoryRequirement requirement,
    Map<String, dynamic> context,
  ) async {
    final issues = <ComplianceIssue>[];

    // Check privacy policy
    final hasPrivacyPolicy =
        context["complianceStatus"]['has_privacy_policy'] as bool? ?? false;
    if (!hasPrivacyPolicy) {
      issues.add(
        ComplianceIssue(
          id: 'privacy_policy_missing',
          title: 'Privacy Policy Missing',
          description:
              'Privacy policy is required for data protection compliance',
          severity: IssueSeverity.high,
          deadline: DateTime.now().add(const Duration(days: 15)),
          correctiveAction: 'Implement comprehensive privacy policy',
        ),
      );
    }

    // Check data consent management
    final hasConsentManagement =
        context["complianceStatus"]['has_consent_management'] as bool? ?? false;
    if (!hasConsentManagement) {
      issues.add(
        ComplianceIssue(
          id: 'consent_management_missing',
          title: 'Data Consent Management Missing',
          description: 'Proper consent management system is required',
          severity: IssueSeverity.medium,
          deadline: DateTime.now().add(const Duration(days: 30)),
          correctiveAction: 'Implement data consent management system',
        ),
      );
    }

    return issues;
  }

  /// Check financial compliance
  Future<List<ComplianceIssue>> _checkFinancialCompliance(
    RegulatoryRequirement requirement,
    Map<String, dynamic> context,
  ) async {
    final issues = <ComplianceIssue>[];

    if (requirement.id == 'rbi') {
      // Check RBI license
      final hasRBILicense =
          context["complianceStatus"]['rbi_licensed'] as bool? ?? false;
      if (!hasRBILicense) {
        issues.add(
          ComplianceIssue(
            id: 'rbi_license_required',
            title: 'RBI License Required',
            description: 'RBI license is required for financial services',
            severity: IssueSeverity.critical,
            deadline: DateTime.now().add(const Duration(days: 90)),
            correctiveAction: 'Apply for appropriate RBI license',
          ),
        );
      }

      // Check KYC compliance
      final kycCompliance =
          context["complianceStatus"]['kyc_compliance_rate'] as double? ?? 0.0;
      if (kycCompliance < 95.0) {
        issues.add(
          ComplianceIssue(
            id: 'kyc_compliance_low',
            title: 'KYC Compliance Below Threshold',
            description:
                'KYC compliance rate is ${kycCompliance.toStringAsFixed(1)}%, should be >95%',
            severity: IssueSeverity.high,
            deadline: DateTime.now().add(const Duration(days: 30)),
            correctiveAction: 'Improve KYC processes and customer verification',
          ),
        );
      }
    }

    return issues;
  }

  /// Check environmental compliance
  Future<List<ComplianceIssue>> _checkEnvironmentalCompliance(
    RegulatoryRequirement requirement,
    Map<String, dynamic> context,
  ) async {
    final issues = <ComplianceIssue>[];

    // Environmental compliance checks would go here
    // This is a placeholder for businesses that need environmental compliance

    return issues;
  }

  /// Determine overall compliance level from issues
  ComplianceLevel _determineComplianceLevel(List<ComplianceIssue> issues) {
    if (issues.isEmpty) return ComplianceLevel.compliant;

    final criticalIssues =
        issues.where((i) => i.severity == IssueSeverity.critical).length;
    final highIssues =
        issues.where((i) => i.severity == IssueSeverity.high).length;

    if (criticalIssues > 0) return ComplianceLevel.nonCompliant;
    if (highIssues > 0) return ComplianceLevel.atRisk;

    return ComplianceLevel.atRisk; // Medium/low issues still put at risk
  }

  /// Generate compliance description
  String _generateComplianceDescription(
    RegulatoryRequirement requirement,
    ComplianceLevel level,
    List<ComplianceIssue> issues,
  ) {
    switch (level) {
      case ComplianceLevel.compliant:
        return '${requirement.name} compliance is up to date';
      case ComplianceLevel.atRisk:
        return '${requirement.name} compliance has ${issues.length} issues requiring attention';
      case ComplianceLevel.nonCompliant:
        return '${requirement.name} compliance has critical violations requiring immediate action';
      case ComplianceLevel.unknown:
        return '${requirement.name} compliance status could not be determined';
    }
  }

  /// Generate required actions from issues
  List<String> _generateRequiredActions(List<ComplianceIssue> issues) {
    return issues
        .where((issue) => issue.correctiveAction != null)
        .map((issue) => issue.correctiveAction!)
        .toList();
  }

  /// Calculate next review date
  DateTime _calculateNextReview(RegulatoryRequirement requirement) {
    // Different requirements have different review frequencies
    switch (requirement.category) {
      case ComplianceCategory.tax:
        return DateTime.now().add(const Duration(days: 30)); // Monthly for tax
      case ComplianceCategory.labor:
        return DateTime.now().add(
          const Duration(days: 90),
        ); // Quarterly for labor
      case ComplianceCategory.dataProtection:
        return DateTime.now().add(const Duration(days: 180)); // Semi-annually
      case ComplianceCategory.financial:
        return DateTime.now().add(
          const Duration(days: 30),
        ); // Monthly for financial
      case ComplianceCategory.environmental:
        return DateTime.now().add(const Duration(days: 365)); // Annually
    }
  }

  /// Attempt automated corrective action
  Future<void> _attemptAutomatedCorrection(
    ComplianceIssue issue,
    RegulatoryRequirement requirement,
  ) async {
    try {
      switch (issue.id) {
        case 'gst_filing_overdue':
          await _automateGSTFiling(issue);
          break;
        case 'privacy_policy_missing':
          await _generatePrivacyPolicy(issue);
          break;
        case 'consent_management_missing':
          await _setupConsentManagement(issue);
          break;
        default:
          // For issues that can't be automated, create action items
          await _createActionItem(issue, requirement);
      }
    } catch (e) {
      print('Error in automated correction for ${issue.id}: $e');
    }
  }

  /// Automate GST filing process
  Future<void> _automateGSTFiling(ComplianceIssue issue) async {
    try {
      // In a real implementation, this would:
      // 1. Gather transaction data
      // 2. Calculate GST liability
      // 3. Generate GSTR-3B form
      // 4. Submit to GST portal (with user approval)

      print('Automated GST filing initiated for issue: ${issue.id}');

      // For now, just mark as action taken
      await _logComplianceAction(
        issue.id,
        'Automated GST filing process initiated',
        ComplianceActionType.automated,
      );
    } catch (e) {
      print('Error in automated GST filing: $e');
    }
  }

  /// Generate privacy policy automatically
  Future<void> _generatePrivacyPolicy(ComplianceIssue issue) async {
    try {
      // Note: In a real implementation, businessId would be passed from initialization
      // For now, using a placeholder businessId
      final businessId = 'default_business';
      final context = await _businessContext.getCurrentContext(businessId);

      // Extract business information from context
      final businessType =
          context["operationalMetrics"]['business_type'] as String? ?? 'general';
      final services =
          context["operationalMetrics"]['services'] as String? ??
          'business services';

      final prompt = '''
      Generate a comprehensive privacy policy for a business with the following details:
      
      Business Type: $businessType
      Services: $services
      Data Collected: Customer information, transaction data, usage analytics
      
      Include sections on:
      - Data collection and usage
      - Data sharing and disclosure
      - Data security measures
      - User rights and choices
      - Contact information
      
      Make it compliant with Indian data protection laws.
      ''';

      final privacyPolicy = await _aiClient.generateResponse(prompt);

      // Save privacy policy (in real implementation, would save to database/file)
      await _logComplianceAction(
        issue.id,
        'Privacy policy generated automatically',
        ComplianceActionType.automated,
        metadata: {'policy_content': privacyPolicy},
      );
    } catch (e) {
      print('Error generating privacy policy: $e');
    }
  }

  /// Setup consent management system
  Future<void> _setupConsentManagement(ComplianceIssue issue) async {
    try {
      // In a real implementation, this would:
      // 1. Configure consent collection forms
      // 2. Set up consent tracking database
      // 3. Implement consent withdrawal mechanisms
      // 4. Create consent audit trails

      await _logComplianceAction(
        issue.id,
        'Consent management system setup initiated',
        ComplianceActionType.automated,
      );
    } catch (e) {
      print('Error setting up consent management: $e');
    }
  }

  /// Create action item for manual resolution
  Future<void> _createActionItem(
    ComplianceIssue issue,
    RegulatoryRequirement requirement,
  ) async {
    await _logComplianceAction(
      issue.id,
      'Manual action required: ${issue.correctiveAction}',
      ComplianceActionType.manual,
      metadata: {
        'requirement': requirement.name,
        'severity': issue.severity.name,
        'deadline': issue.deadline.toIso8601String(),
      },
    );
  }

  /// Monitor for regulatory changes
  Future<void> _monitorRegulatoryChanges() async {
    try {
      // In a real implementation, this would:
      // 1. Monitor government websites for updates
      // 2. Subscribe to regulatory news feeds
      // 3. Track legal databases for changes
      // 4. Use AI to analyze regulatory announcements

      // Simulate regulatory change detection
      final changes = await _simulateRegulatoryChanges();

      for (final change in changes) {
        _regulatoryController.add(change);
        await _processRegulatoryChange(change);
      }
    } catch (e) {
      print('Error monitoring regulatory changes: $e');
    }
  }

  /// Simulate regulatory changes (placeholder)
  Future<List<RegulatoryChange>> _simulateRegulatoryChanges() async {
    // This would be replaced with real regulatory monitoring
    return [];
  }

  /// Process regulatory change
  Future<void> _processRegulatoryChange(RegulatoryChange change) async {
    try {
      // Update requirements based on change
      if (_requirements.containsKey(change.regulationType)) {
        await _updateRequirement(change);
      }

      // Assess impact on current compliance
      await _assessChangeImpact(change);

      // Generate adaptation recommendations
      await _generateAdaptationPlan(change);
    } catch (e) {
      print('Error processing regulatory change: $e');
    }
  }

  /// Update requirement based on regulatory change
  Future<void> _updateRequirement(RegulatoryChange change) async {
    // Update the requirement with new information
    // This would involve parsing the change and updating relevant fields
  }

  /// Assess impact of regulatory change
  Future<void> _assessChangeImpact(RegulatoryChange change) async {
    // Note: In a real implementation, businessId would be passed from initialization
    // For now, using a placeholder businessId
    final businessId = 'default_business';
    final context = await _businessContext.getCurrentContext(businessId);

    final prompt = '''
    Assess the impact of this regulatory change on our business:
    
    Change: ${change.description}
    Effective Date: ${change.effectiveDate}
    Type: ${change.type}
    
    Current Business Context: $context
    
    Analyze:
    1. Direct impact on operations
    2. Compliance requirements changes
    3. Cost implications
    4. Timeline for adaptation
    ''';

    final impact = await _aiClient.generateResponse(prompt);

    await _logComplianceAction(
      'regulatory_change_${change.id}',
      'Impact assessment completed',
      ComplianceActionType.analysis,
      metadata: {'impact_analysis': impact},
    );
  }

  /// Generate adaptation plan for regulatory change
  Future<void> _generateAdaptationPlan(RegulatoryChange change) async {
    final prompt = '''
    Create an adaptation plan for this regulatory change:
    
    Change: ${change.description}
    Effective Date: ${change.effectiveDate}
    Impact Level: ${change.impactLevel}
    
    Generate:
    1. Step-by-step adaptation plan
    2. Timeline and milestones
    3. Resource requirements
    4. Risk mitigation strategies
    ''';

    final plan = await _aiClient.generateResponse(prompt);

    await _logComplianceAction(
      'adaptation_plan_${change.id}',
      'Adaptation plan generated',
      ComplianceActionType.planning,
      metadata: {'adaptation_plan': plan},
    );
  }

  /// Log compliance action
  Future<void> _logComplianceAction(
    String issueId,
    String action,
    ComplianceActionType type, {
    Map<String, dynamic>? metadata,
  }) async {
    // In a real implementation, this would log to database
    print('Compliance Action: $action for issue $issueId');
  }

  /// Generate compliance report
  Future<ComplianceReport> generateComplianceReport() async {
    final activeIssues = _activeIssues.where((i) => !i.isResolved).toList();
    final criticalIssues =
        activeIssues
            .where((i) => i.severity == IssueSeverity.critical)
            .toList();

    return ComplianceReport(
      generatedAt: DateTime.now(),
      overallStatus:
          criticalIssues.isEmpty
              ? ComplianceLevel.compliant
              : ComplianceLevel.nonCompliant,
      totalRequirements: _requirements.length,
      compliantRequirements:
          _complianceStatuses.values
              .where((s) => s.level == ComplianceLevel.compliant)
              .length,
      activeIssues: activeIssues.length,
      criticalIssues: criticalIssues.length,
      upcomingDeadlines: _getUpcomingDeadlines(),
      recommendations: await _generateComplianceRecommendations(),
    );
  }

  /// Get upcoming compliance deadlines
  List<ComplianceDeadline> _getUpcomingDeadlines() {
    final deadlines = <ComplianceDeadline>[];
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));

    for (final issue in _activeIssues) {
      if (!issue.isResolved && issue.deadline.isBefore(thirtyDaysFromNow)) {
        deadlines.add(
          ComplianceDeadline(
            title: issue.title,
            deadline: issue.deadline,
            severity: issue.severity,
            description: issue.description,
          ),
        );
      }
    }

    return deadlines..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  /// Generate compliance recommendations
  Future<List<String>> _generateComplianceRecommendations() async {
    final recommendations = <String>[];

    // Analyze current compliance status and generate recommendations
    final criticalIssues =
        _activeIssues
            .where((i) => i.severity == IssueSeverity.critical && !i.isResolved)
            .length;

    if (criticalIssues > 0) {
      recommendations.add(
        'Address $criticalIssues critical compliance issues immediately',
      );
    }

    recommendations.add('Set up automated compliance monitoring alerts');
    recommendations.add('Schedule regular compliance reviews');
    recommendations.add(
      'Consider hiring compliance consultant for complex requirements',
    );

    return recommendations;
  }

  /// Get compliance status for specific requirement
  ComplianceStatus? getComplianceStatus(String requirementId) {
    return _complianceStatuses[requirementId];
  }

  /// Get all active compliance issues
  List<ComplianceIssue> getActiveIssues() {
    return _activeIssues.where((i) => !i.isResolved).toList();
  }

  /// Get regulatory requirements
  Map<String, RegulatoryRequirement> getRequirements() {
    return Map.from(_requirements);
  }

  /// Generate deadline lists for different requirements
  List<DateTime> _generateGSTDeadlines() {
    final deadlines = <DateTime>[];
    final now = DateTime.now();

    // Generate next 12 months of GST deadlines (20th of each month)
    for (int i = 0; i < 12; i++) {
      final month = DateTime(now.year, now.month + i, 20);
      deadlines.add(month);
    }

    return deadlines;
  }

  List<DateTime> _generateTaxDeadlines() {
    final deadlines = <DateTime>[];
    final now = DateTime.now();

    // Annual ITR deadline (July 31st)
    deadlines.add(DateTime(now.year, 7, 31));
    if (now.month > 7) {
      deadlines.add(DateTime(now.year + 1, 7, 31));
    }

    return deadlines;
  }

  List<DateTime> _generateLaborDeadlines() {
    final deadlines = <DateTime>[];
    final now = DateTime.now();

    // Monthly PF deadlines (15th of each month)
    for (int i = 0; i < 12; i++) {
      final month = DateTime(now.year, now.month + i, 15);
      deadlines.add(month);
    }

    return deadlines;
  }

  List<DateTime> _generateDataProtectionDeadlines() {
    final deadlines = <DateTime>[];
    // Data protection typically has ongoing requirements rather than specific deadlines
    return deadlines;
  }

  List<DateTime> _generateRBIDeadlines() {
    final deadlines = <DateTime>[];
    final now = DateTime.now();

    // Quarterly reporting deadlines
    for (int i = 1; i <= 4; i++) {
      final quarter = DateTime(
        now.year,
        i * 3,
        15,
      ); // 15th of Mar, Jun, Sep, Dec
      deadlines.add(quarter);
    }

    return deadlines;
  }

  /// Dispose resources
  void dispose() {
    stopMonitoring();
    _complianceController.close();
    _issueController.close();
    _regulatoryController.close();
  }
}

// Additional model classes

class RegulatoryRequirement {
  final String id;
  final String name;
  final ComplianceCategory category;
  final String description;
  final String applicability;
  final List<String> requirements;
  final Map<String, String> penalties;
  final List<DateTime> deadlines;
  final DateTime lastUpdated;

  RegulatoryRequirement({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.applicability,
    required this.requirements,
    required this.penalties,
    required this.deadlines,
    required this.lastUpdated,
  });
}

class RegulatoryChange {
  final String id;
  final String regulationType;
  final String title;
  final String description;
  final ChangeType type;
  final ImpactLevel impactLevel;
  final DateTime effectiveDate;
  final DateTime announcedDate;
  final String source;
  final Map<String, dynamic> metadata;

  RegulatoryChange({
    required this.id,
    required this.regulationType,
    required this.title,
    required this.description,
    required this.type,
    required this.impactLevel,
    required this.effectiveDate,
    required this.announcedDate,
    required this.source,
    required this.metadata,
  });
}

class ComplianceReport {
  final DateTime generatedAt;
  final ComplianceLevel overallStatus;
  final int totalRequirements;
  final int compliantRequirements;
  final int activeIssues;
  final int criticalIssues;
  final List<ComplianceDeadline> upcomingDeadlines;
  final List<String> recommendations;

  ComplianceReport({
    required this.generatedAt,
    required this.overallStatus,
    required this.totalRequirements,
    required this.compliantRequirements,
    required this.activeIssues,
    required this.criticalIssues,
    required this.upcomingDeadlines,
    required this.recommendations,
  });
}

class ComplianceDeadline {
  final String title;
  final DateTime deadline;
  final IssueSeverity severity;
  final String description;

  ComplianceDeadline({
    required this.title,
    required this.deadline,
    required this.severity,
    required this.description,
  });
}

// Enums

enum ComplianceCategory { tax, labor, dataProtection, financial, environmental }

enum ComplianceActionType { automated, manual, analysis, planning }

enum ChangeType { newRequirement, modification, repeal, clarification }

enum ImpactLevel { low, medium, high, critical }
