import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ai_models.dart';
import '../../services/fraud_detection_service.dart';
import '../../providers/business_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/fraud_alert_widget.dart';

class FraudAlertsScreen extends StatefulWidget {
  const FraudAlertsScreen({super.key});

  @override
  State<FraudAlertsScreen> createState() => _FraudAlertsScreenState();
}

class _FraudAlertsScreenState extends State<FraudAlertsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FraudDetectionService _fraudService = FraudDetectionService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadFraudAlerts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFraudAlerts() async {
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );

    if (businessProvider.business != null) {
      await _fraudService.analyzeFraud(businessProvider.business!.id);
    }
  }

  Future<void> _refreshAlerts() async {
    await _loadFraudAlerts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fraud Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAlerts,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'clear_all':
                  _showClearAllDialog();
                  break;
                case 'settings':
                  Navigator.pushNamed(context, '/fraud-settings');
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Icon(Icons.clear_all),
                        SizedBox(width: 8),
                        Text('Clear All Alerts'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings),
                        SizedBox(width: 8),
                        Text('Fraud Settings'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'High Priority'),
            Tab(text: 'Duplicates'),
            Tab(text: 'Mismatches'),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: _fraudService,
        builder: (context, child) {
          if (_fraudService.isAnalyzing) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Analyzing transactions for fraud...'),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAllAlertsTab(),
              _buildHighPriorityAlertsTab(),
              _buildDuplicateAlertsTab(),
              _buildMismatchAlertsTab(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAllAlertsTab() {
    final alerts = _fraudService.alerts;

    if (alerts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.security,
        title: 'No Fraud Alerts',
        subtitle: 'Your transactions look secure!',
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshAlerts,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return FraudAlertWidget(
            alert: alert,
            onDismiss: () => _dismissAlert(alert.id),
            onViewDetails: () => _showAlertDetails(alert),
          );
        },
      ),
    );
  }

  Widget _buildHighPriorityAlertsTab() {
    final alerts = _fraudService.getHighPriorityAlerts();

    if (alerts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.priority_high,
        title: 'No High Priority Alerts',
        subtitle: 'No critical fraud issues detected',
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshAlerts,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return FraudAlertWidget(
            alert: alert,
            onDismiss: () => _dismissAlert(alert.id),
            onViewDetails: () => _showAlertDetails(alert),
          );
        },
      ),
    );
  }

  Widget _buildDuplicateAlertsTab() {
    final alerts =
        _fraudService.alerts
            .where(
              (alert) =>
                  alert.type == FraudType.duplicateInvoice ||
                  alert.type == FraudType.duplicateSupplierBill,
            )
            .toList();

    if (alerts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.content_copy,
        title: 'No Duplicate Alerts',
        subtitle: 'No duplicate transactions detected',
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshAlerts,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return FraudAlertWidget(
            alert: alert,
            onDismiss: () => _dismissAlert(alert.id),
            onViewDetails: () => _showAlertDetails(alert),
          );
        },
      ),
    );
  }

  Widget _buildMismatchAlertsTab() {
    final alerts =
        _fraudService.alerts
            .where(
              (alert) =>
                  alert.type == FraudType.paymentMismatch ||
                  alert.type == FraudType.suspiciousPattern,
            )
            .toList();

    if (alerts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.error_outline,
        title: 'No Mismatch Alerts',
        subtitle: 'No payment mismatches detected',
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshAlerts,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: alerts.length,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return FraudAlertWidget(
            alert: alert,
            onDismiss: () => _dismissAlert(alert.id),
            onViewDetails: () => _showAlertDetails(alert),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshAlerts,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  void _dismissAlert(String alertId) {
    _fraudService.dismissAlert(alertId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alert dismissed'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _showAlertDetails(FraudAlert alert) {
    showDialog(
      context: context,
      builder: (context) => FraudAlertDetailsDialog(alert: alert),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear All Alerts'),
            content: const Text(
              'Are you sure you want to clear all fraud alerts? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  _fraudService.clearAllAlerts();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All alerts cleared'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                ),
                child: const Text('Clear All'),
              ),
            ],
          ),
    );
  }
}
