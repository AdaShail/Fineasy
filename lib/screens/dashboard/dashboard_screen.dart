import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/invoice_provider.dart';
// import '../../providers/insights_provider.dart';
import '../../services/fraud_detection_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/fraud_alert_widget.dart';
import '../auth/login_screen.dart';
import '../fraud/fraud_alerts_screen.dart';
import '../reports/reports_screen.dart';
import '../customers/add_edit_customer_screen.dart';
import '../suppliers/add_edit_supplier_screen.dart';
import '../settings/settings_screen.dart';
import '../profile/profile_screen.dart';
import '../payments/payment_management_screen.dart';
import '../onboarding/business_setup_screen.dart';
import 'analytics_tab.dart';
import 'receivables_tab.dart' as dashboardtabs;
import 'payables_tab.dart' as payments;
import '../more/more_hub_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final FraudDetectionService _fraudService = FraudDetectionService();

  final List<Widget> _tabs = [
    const AnalyticsTab(),
    const dashboardtabs.ReceivablesTab(),
    const payments.PayablesTab(),
    const MoreHubScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );
    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );
    final customerProvider = Provider.of<CustomerProvider>(
      context,
      listen: false,
    );
    final supplierProvider = Provider.of<SupplierProvider>(
      context,
      listen: false,
    );
    final invoiceProvider = Provider.of<InvoiceProvider>(
      context,
      listen: false,
    );

    if (authProvider.user != null) {
      // Load business data
      await businessProvider.loadBusiness(authProvider.user!.id);

      if (businessProvider.business != null &&
          businessProvider.business!.id.isNotEmpty) {
        // Validate business ID format (should be a valid UUID)
        final businessId = businessProvider.business!.id;
        final uuidRegex = RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        );

        if (uuidRegex.hasMatch(businessId)) {
          // Load all related data including invoices
          await Future.wait([
            transactionProvider.loadTransactions(businessId),
            customerProvider.loadCustomers(businessId),
            supplierProvider.loadSuppliers(businessId),
            invoiceProvider.loadInvoices(businessId),
          ]);

          // Initialize and load fraud detection
          await _fraudService.initialize();
          await _fraudService.analyzeFraud(businessId);
        } else {
          // Invalid business ID, clear and redirect to setup
          businessProvider.clearBusiness();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Invalid business data detected. Please set up your business again.',
                ),
                backgroundColor: Colors.orange,
              ),
            );
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const BusinessSetupScreen()),
            );
          }
        }
      } else {
        // No business found, redirect to business setup
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const BusinessSetupScreen()),
          );
        }
      }
    }
  }

  void _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fineasy'),
        actions: [
          // Connection Status Indicator
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: const Icon(
              Icons.wifi,
              color: AppTheme.successColor,
              size: 20,
            ),
          ),

          // Payment Management Button
          IconButton(
            icon: const Icon(Icons.payment),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PaymentManagementScreen(),
                ),
              );
            },
            tooltip: 'Payment Management',
          ),

          // Reports Button
          IconButton(
            icon: const Icon(Icons.assessment),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ReportsScreen()));
            },
            tooltip: 'Reports',
          ),

          // Profile Menu
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'add_customer':
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AddEditCustomerScreen(),
                    ),
                  );
                  break;
                case 'add_supplier':
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AddEditSupplierScreen(),
                    ),
                  );
                  break;
                case 'profile':
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                  break;
                case 'settings':
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                  break;
                case 'logout':
                  _handleLogout();
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'add_customer',
                    child: Row(
                      children: [
                        Icon(Icons.person_add),
                        SizedBox(width: 8),
                        Text('Add Customer'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'add_supplier',
                    child: Row(
                      children: [
                        Icon(Icons.business),
                        SizedBox(width: 8),
                        Text('Add Supplier'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person_outlined),
                        SizedBox(width: 8),
                        Text('Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings_outlined),
                        SizedBox(width: 8),
                        Text('Settings'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: AppTheme.errorColor),
                        SizedBox(width: 8),
                        Text(
                          'Logout',
                          style: TextStyle(color: AppTheme.errorColor),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Fraud Alert Banner
          ListenableBuilder(
            listenable: _fraudService,
            builder: (context, child) {
              return FraudAlertBanner(
                alerts: _fraudService.alerts,
                onViewAll: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const FraudAlertsScreen(),
                    ),
                  );
                },
              );
            },
          ),
          // Main content
          Expanded(child: _tabs[_currentIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Receivables',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment_outlined),
            activeIcon: Icon(Icons.payment),
            label: 'Payables',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz_outlined),
            activeIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Invoice Management Button
          FloatingActionButton(
            heroTag: "invoice_fab",
            onPressed: () {
              Navigator.pushNamed(context, '/invoices');
            },
            backgroundColor: Colors.deepPurple,
            tooltip: 'Manage Invoices',
            child: const Icon(Icons.receipt_long),
          ),
          const SizedBox(height: 8),
          // AI Invoice Creation Button
          FloatingActionButton(
            heroTag: "nlp_invoice_fab",
            onPressed: () {
              Navigator.pushNamed(context, '/nlp-invoice');
            },
            backgroundColor: Colors.green,
            tooltip: 'Create Invoice with AI',
            child: const Icon(Icons.auto_awesome),
          ),
        ],
      ),
    );
  }

  // Removed: Quick add transaction feature
  // void _showAddTransactionDialog() { ... }
}

// Removed: AddTransactionSheet widget - quick add transaction feature removed
/*
class AddTransactionSheet extends StatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _transactionType = 'income';
  String _paymentMode = 'cash';

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add Transaction',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Transaction Type
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _transactionType = 'income'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              _transactionType == 'income'
                                  ? AppTheme.primaryColor
                                  : Colors.grey.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color:
                            _transactionType == 'income'
                                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                                : Colors.transparent,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _transactionType == 'income'
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color:
                                _transactionType == 'income'
                                    ? AppTheme.primaryColor
                                    : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          const Text('Income'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _transactionType = 'expense'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              _transactionType == 'expense'
                                  ? AppTheme.primaryColor
                                  : Colors.grey.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color:
                            _transactionType == 'expense'
                                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                                : Colors.transparent,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _transactionType == 'expense'
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color:
                                _transactionType == 'expense'
                                    ? AppTheme.primaryColor
                                    : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          const Text('Expense'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Amount
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: AppConstants.defaultCurrency,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter description';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Payment Mode
            DropdownButtonFormField<String>(
              initialValue: _paymentMode,
              decoration: const InputDecoration(labelText: 'Payment Mode'),
              items: const [
                DropdownMenuItem(value: 'cash', child: Text('Cash')),
                DropdownMenuItem(value: 'card', child: Text('Card')),
                DropdownMenuItem(value: 'upi', child: Text('UPI')),
                DropdownMenuItem(
                  value: 'netBanking',
                  child: Text('Net Banking'),
                ),
                DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
                DropdownMenuItem(
                  value: 'bankTransfer',
                  child: Text('Bank Transfer'),
                ),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (value) => setState(() => _paymentMode = value!),
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleAddTransaction,
                    child: const Text('Add'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PaymentMode _getPaymentModeEnum(String paymentMode) {
    switch (paymentMode) {
      case 'cash':
        return PaymentMode.cash;
      case 'card':
        return PaymentMode.card;
      case 'upi':
        return PaymentMode.upi;
      case 'netBanking':
        return PaymentMode.netBanking;
      case 'cheque':
        return PaymentMode.cheque;
      case 'bankTransfer':
        return PaymentMode.bankTransfer;
      case 'other':
        return PaymentMode.other;
      default:
        return PaymentMode.other;
    }
  }

  void _handleAddTransaction() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final businessProvider = Provider.of<BusinessProvider>(
        context,
        listen: false,
      );
      final transactionProvider = Provider.of<TransactionProvider>(
        context,
        listen: false,
      );

      if (authProvider.user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not authenticated. Please login again.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      if (businessProvider.business == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Business not found. Please setup your business first.',
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      final transaction = TransactionModel(
        id: const Uuid().v4(),
        businessId: businessProvider.business!.id,
        userId: authProvider.user!.id, // REQUIRED: Added missing userId
        amount: double.parse(_amountController.text),
        description: _descriptionController.text.trim(),
        type:
            _transactionType == 'income'
                ? TransactionType.income
                : TransactionType.expense,
        paymentMode: _getPaymentModeEnum(_paymentMode),
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await transactionProvider.addTransaction(transaction);

      if (mounted) {
        Navigator.of(context).pop();

        if (success) {
          // Force refresh of transaction provider to ensure real-time updates
          final businessId = businessProvider.business!.id;
          await transactionProvider.refreshTransactions(businessId);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Transaction added successfully!'
                  : 'Failed to add transaction',
            ),
            backgroundColor:
                success ? AppTheme.successColor : AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
*/
//
