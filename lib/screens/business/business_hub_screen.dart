import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/supplier_provider.dart';
import '../../utils/app_theme.dart';

class BusinessHubScreen extends StatefulWidget {
  const BusinessHubScreen({super.key});

  @override
  State<BusinessHubScreen> createState() => _BusinessHubScreenState();
}

class _BusinessHubScreenState extends State<BusinessHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: NestedScrollView(
        headerSliverBuilder:
            (context, innerBoxIsScrolled) => [
              SliverAppBar(
                title: const Text('Business'),
                floating: true,
                pinned: true,
                backgroundColor: AppTheme.primaryColor,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _showSearchDialog(),
                  ),
                ],
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Customers'),
                    Tab(text: 'Suppliers'),
                  ],
                ),
              ),
            ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildCustomersTab(),
            _buildSuppliersTab(),
          ],
        ),
      ),
      floatingActionButton: _buildContextualFAB(),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildBusinessSummaryCard(),
          const SizedBox(height: 16),
          _buildQuickActionsCard(),
          const SizedBox(height: 16),
          _buildRecentActivitiesCard(),
        ],
      ),
    );
  }

  Widget _buildCustomersTab() {
    return Consumer<CustomerProvider>(
      builder: (context, customerProvider, child) {
        final customers = customerProvider.customers;

        if (customers.isEmpty) {
          return _buildEmptyState(
            icon: Icons.people_outline,
            title: 'No customers yet',
            subtitle: 'Add your first customer to get started',
            actionLabel: 'Add Customer',
            onAction: () => Navigator.pushNamed(context, '/add-customer'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: customers.length,
          itemBuilder: (context, index) {
            final customer = customers[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.withValues(alpha: 0.1),
                  child: Text(
                    customer.name.isNotEmpty
                        ? customer.name[0].toUpperCase()
                        : 'C',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                title: Text(
                  customer.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (customer.email?.isNotEmpty == true)
                      Text(customer.email!),
                    if (customer.phone?.isNotEmpty == true)
                      Text(customer.phone!),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(Icons.visibility),
                              SizedBox(width: 8),
                              Text('View Details'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'invoice',
                          child: Row(
                            children: [
                              Icon(Icons.receipt_long),
                              SizedBox(width: 8),
                              Text('Create Invoice'),
                            ],
                          ),
                        ),
                      ],
                  onSelected:
                      (value) => _handleCustomerAction(value, customer.id),
                ),
                onTap:
                    () => Navigator.pushNamed(
                      context,
                      '/customer-details',
                      arguments: customer.id,
                    ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSuppliersTab() {
    return Consumer<SupplierProvider>(
      builder: (context, supplierProvider, child) {
        final suppliers = supplierProvider.suppliers;

        if (suppliers.isEmpty) {
          return _buildEmptyState(
            icon: Icons.business_outlined,
            title: 'No suppliers yet',
            subtitle: 'Add your first supplier to get started',
            actionLabel: 'Add Supplier',
            onAction: () => Navigator.pushNamed(context, '/add-supplier'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: suppliers.length,
          itemBuilder: (context, index) {
            final supplier = suppliers[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.withValues(alpha: 0.1),
                  child: Text(
                    supplier.name.isNotEmpty
                        ? supplier.name[0].toUpperCase()
                        : 'S',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                title: Text(
                  supplier.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (supplier.email?.isNotEmpty == true)
                      Text(supplier.email!),
                    if (supplier.phone?.isNotEmpty == true)
                      Text(supplier.phone!),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(Icons.visibility),
                              SizedBox(width: 8),
                              Text('View Details'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'payment',
                          child: Row(
                            children: [
                              Icon(Icons.payment),
                              SizedBox(width: 8),
                              Text('Record Payment'),
                            ],
                          ),
                        ),
                      ],
                  onSelected:
                      (value) => _handleSupplierAction(value, supplier.id),
                ),
                onTap:
                    () => Navigator.pushNamed(
                      context,
                      '/supplier-details',
                      arguments: supplier.id,
                    ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBusinessSummaryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Business Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Customers',
                    '${Provider.of<CustomerProvider>(context).customers.length}',
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Suppliers',
                    '${Provider.of<SupplierProvider>(context).suppliers.length}',
                    Icons.business,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Add Customer',
                    Icons.person_add,
                    Colors.blue,
                    () => Navigator.pushNamed(context, '/add-customer'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Add Supplier',
                    Icons.business,
                    Colors.orange,
                    () => Navigator.pushNamed(context, '/add-supplier'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitiesCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activities',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            // TODO: Implement recent activities list
            const Center(
              child: Text(
                'Recent business activities will appear here',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(actionLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextualFAB() {
    return FloatingActionButton.extended(
      onPressed: () => _showAddMenu(),
      backgroundColor: AppTheme.primaryColor,
      icon: const Icon(Icons.add),
      label: Text(_getContextualFABLabel()),
    );
  }

  String _getContextualFABLabel() {
    switch (_tabController.index) {
      case 1:
        return 'Add Customer';
      case 2:
        return 'Add Supplier';
      default:
        return 'Quick Add';
    }
  }

  void _showAddMenu() {
    switch (_tabController.index) {
      case 1:
        Navigator.pushNamed(context, '/add-customer');
        break;
      case 2:
        Navigator.pushNamed(context, '/add-supplier');
        break;
      default:
        _showQuickAddMenu();
    }
  }

  void _showQuickAddMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Add New',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.person_add, color: Colors.blue),
                  title: const Text('Customer'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/add-customer');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.business, color: Colors.orange),
                  title: const Text('Supplier'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/add-supplier');
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  void _showSearchDialog() {
    // Implement search functionality
  }

  void _handleCustomerAction(String action, String customerId) {
    switch (action) {
      case 'view':
        Navigator.pushNamed(
          context,
          '/customer-details',
          arguments: customerId,
        );
        break;
      case 'edit':
        Navigator.pushNamed(context, '/edit-customer', arguments: customerId);
        break;
      case 'invoice':
        Navigator.pushNamed(
          context,
          '/add-invoice',
          arguments: {'customerId': customerId},
        );
        break;
    }
  }

  void _handleSupplierAction(String action, String supplierId) {
    switch (action) {
      case 'view':
        Navigator.pushNamed(
          context,
          '/supplier-details',
          arguments: supplierId,
        );
        break;
      case 'edit':
        Navigator.pushNamed(context, '/edit-supplier', arguments: supplierId);
        break;
      case 'payment':
        Navigator.pushNamed(
          context,
          '/add-payment',
          arguments: {'supplierId': supplierId},
        );
        break;
    }
  }
}
