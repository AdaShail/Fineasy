import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/business_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/invoice_provider.dart';
import '../widgets/web_dashboard_widgets.dart';
import '../navigation/web_sidebar.dart';
import '../navigation/web_app_bar.dart';
import '../../screens/dashboard/dashboard_screen.dart';

// Import all web screens for navigation
import 'web_invoice_management_screen.dart';
import 'web_customer_management_screen.dart';
import 'web_supplier_management_screen.dart';
import 'web_transaction_hub_screen.dart';
import 'web_payment_management_screen.dart';
import 'web_receivables_management_screen.dart';
import 'web_recurring_payments_screen.dart';
import 'web_reports_analytics_screen.dart';
import 'web_autopilot_screen.dart';
import 'web_settings_screen.dart';
import 'web_analytics_dashboard_screen.dart';

/// Web-optimized dashboard screen with responsive multi-column layout
/// Falls back to mobile dashboard on non-web platforms
class WebDashboardScreen extends StatefulWidget {
  const WebDashboardScreen({super.key});

  @override
  State<WebDashboardScreen> createState() => _WebDashboardScreenState();
}

class _WebDashboardScreenState extends State<WebDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentRoute = '/dashboard';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    
    if (authProvider.user != null) {
      await businessProvider.loadBusiness(authProvider.user!.id);
      
      if (!mounted) return;
      
      if (businessProvider.business != null) {
        final businessId = businessProvider.business!.id;
        
        // Load all data in parallel
        if (mounted) {
          await Future.wait([
            Provider.of<TransactionProvider>(context, listen: false).loadTransactions(businessId),
            Provider.of<CustomerProvider>(context, listen: false).loadCustomers(businessId),
            Provider.of<SupplierProvider>(context, listen: false).loadSuppliers(businessId),
            Provider.of<InvoiceProvider>(context, listen: false).loadInvoices(businessId),
          ]);
        }
      }
    }
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    
    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    
    if (businessProvider.business != null) {
      final businessId = businessProvider.business!.id;
      
      if (mounted) {
        await Future.wait([
          Provider.of<TransactionProvider>(context, listen: false).refreshTransactions(businessId),
          Provider.of<InvoiceProvider>(context, listen: false).refreshInvoices(businessId),
          Provider.of<CustomerProvider>(context, listen: false).loadCustomers(businessId),
          Provider.of<SupplierProvider>(context, listen: false).loadSuppliers(businessId),
        ]);
      }
    }
  }

  Widget _getScreenForRoute(String route) {
    switch (route) {
      case '/':
      case '/dashboard':
        return _buildDashboardContent();
      case '/invoices':
      case '/invoices/create':
        return const WebInvoiceManagementScreen();
      case '/customers':
        return const WebCustomerManagementScreen();
      case '/suppliers':
        return const WebSupplierManagementScreen();
      case '/transactions':
        return const WebTransactionHubScreen();
      case '/payments':
        return const WebPaymentManagementScreen();
      case '/receivables':
        return const WebReceivablesManagementScreen();
      case '/recurring-payments':
        return const WebRecurringPaymentsScreen();
      case '/reports':
        return const WebReportsAnalyticsScreen();
      case '/autopilot':
        return const WebAutopilotScreen();
      case '/settings':
        return const WebSettingsScreen();
      case '/analytics':
        return const WebAnalyticsDashboardScreen();
      default:
        return _buildDashboardContent();
    }
  }

  void _navigateToScreen(String route) {
    setState(() {
      _currentRoute = route;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use mobile dashboard for non-web platforms
    if (!kIsWeb) {
      return const DashboardScreen();
    }

    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1024;

    return Scaffold(
      key: _scaffoldKey,
      appBar: WebAppBar(
        currentRoute: _currentRoute,
        onMenuPressed: !isDesktop
            ? () => _scaffoldKey.currentState?.openDrawer()
            : null,
        showMenuButton: !isDesktop,
      ),
      drawer: !isDesktop
          ? Drawer(
              child: WebSidebar(
                currentRoute: _currentRoute,
                onNavigate: (route) {
                  _navigateToScreen(route);
                  Navigator.of(context).pop();
                },
                collapsed: false,
              ),
            )
          : null,
      body: Row(
        children: [
          if (isDesktop)
            WebSidebar(
              currentRoute: _currentRoute,
              onNavigate: _navigateToScreen,
              collapsed: false,
            ),
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: _getScreenForRoute(_currentRoute),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 900;
        
        if (isDesktop) {
          return _buildDesktopDashboard();
        } else if (isTablet) {
          return _buildTabletDashboard();
        } else {
          return _buildMobileDashboard();
        }
      },
    );
  }

  // Mobile web layout - single column
  Widget _buildMobileDashboard() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            WebBusinessHeader(),
            SizedBox(height: 16),
            WebFinancialOverviewCards(),
            SizedBox(height: 16),
            WebQuickActionsPanel(),
            SizedBox(height: 16),
            WebFinancialChart(),
            SizedBox(height: 16),
            WebRecentTransactions(),
          ],
        ),
      ),
    );
  }

  // Tablet layout - 2 columns
  Widget _buildTabletDashboard() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WebBusinessHeader(),
            const SizedBox(height: 24),
            const WebFinancialOverviewCards(),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: const [
                      WebFinancialChart(),
                      SizedBox(height: 24),
                      WebRecentTransactions(),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: const [
                      WebQuickActionsPanel(),
                      SizedBox(height: 24),
                      WebPendingActionsPanel(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Desktop layout - 3 columns with expandable widgets
  Widget _buildDesktopDashboard() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WebBusinessHeader(),
            const SizedBox(height: 32),
            
            // Financial overview cards - always full width
            const WebFinancialOverviewCards(),
            const SizedBox(height: 32),
            
            // Main content area - 3 columns
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column - Charts and analytics (50%)
                Expanded(
                  flex: 5,
                  child: Column(
                    children: const [
                      WebFinancialChart(isExpanded: true),
                      SizedBox(height: 24),
                      WebCashFlowChart(),
                      SizedBox(height: 24),
                      WebRecentTransactions(maxItems: 8),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                
                // Right column - Quick actions and insights (50%)
                Expanded(
                  flex: 4,
                  child: Column(
                    children: const [
                      WebQuickActionsPanel(),
                      SizedBox(height: 24),
                      WebPendingActionsPanel(),
                      SizedBox(height: 24),
                      WebTopCustomersWidget(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
