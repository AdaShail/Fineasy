import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/recurring_payment_model.dart';
import '../../providers/recurring_payment_provider.dart';
import '../../providers/business_provider.dart';
import '../../utils/app_theme.dart';
import 'add_edit_recurring_payment_screen.dart';
import 'recurring_payment_detail_screen.dart';

class RecurringPaymentListScreen extends StatefulWidget {
  const RecurringPaymentListScreen({super.key});

  @override
  State<RecurringPaymentListScreen> createState() =>
      _RecurringPaymentListScreenState();
}

class _RecurringPaymentListScreenState extends State<RecurringPaymentListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );
    final recurringProvider = Provider.of<RecurringPaymentProvider>(
      context,
      listen: false,
    );

    if (businessProvider.business != null) {
      // First, process any due recurring payments to generate occurrences
      final generatedCount = await recurringProvider.processRecurringPayments(
        businessProvider.business!.id,
      );
      
      if (generatedCount > 0 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Generated $generatedCount new occurrence(s)'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      // Then load the data
      await recurringProvider.loadRecurringPayments(
        businessId: businessProvider.business!.id,
      );
      await recurringProvider.loadOccurrences(
        businessId: businessProvider.business!.id,
      );
    }
  }

  List<RecurringPaymentModel> _getFilteredPayments(
    List<RecurringPaymentModel> payments,
  ) {
    var filtered = payments;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered.where((payment) {
            return payment.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                payment.amount.toString().contains(_searchQuery);
          }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Payments'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Paused'),
            Tab(text: 'All'),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: Consumer<RecurringPaymentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.recurringPayments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading recurring payments',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search recurring payments...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              // Summary Card
              _buildSummaryCard(provider),

              const SizedBox(height: 16),

              // Payment Lists
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPaymentList(
                      _getFilteredPayments(provider.activeRecurringPayments),
                    ),
                    _buildPaymentList(
                      _getFilteredPayments(provider.pausedRecurringPayments),
                    ),
                    _buildPaymentList(
                      _getFilteredPayments(provider.recurringPayments),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addRecurringPayment,
        icon: const Icon(Icons.add),
        label: const Text('Add Recurring'),
      ),
    );
  }

  Widget _buildSummaryCard(RecurringPaymentProvider provider) {
    final activeCount = provider.activeRecurringPayments.length;
    final unpaidCount = provider.unpaidOccurrences.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            'Active',
            activeCount.toString(),
            Icons.repeat,
            AppTheme.primaryColor,
          ),
          Container(width: 1, height: 40, color: Colors.grey.shade300),
          _buildSummaryItem(
            'Unpaid',
            unpaidCount.toString(),
            Icons.pending_actions,
            AppTheme.warningColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
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
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildPaymentList(List<RecurringPaymentModel> payments) {
    if (payments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.repeat_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No recurring payments found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              'Create your first recurring payment to get started',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: payments.length,
      itemBuilder: (context, index) {
        final payment = payments[index];
        return _buildPaymentCard(payment);
      },
    );
  }

  Widget _buildPaymentCard(RecurringPaymentModel payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(payment.status).withOpacity(0.2),
          child: Icon(
            _getFrequencyIcon(payment.frequency),
            color: _getStatusColor(payment.status),
          ),
        ),
        title: Text(
          payment.description,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(payment.frequencyDescription),
            const SizedBox(height: 2),
            Text(
              '${payment.occurrencesGenerated} occurrences generated',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${payment.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            _buildStatusChip(payment.status),
          ],
        ),
        onTap: () => _viewPaymentDetail(payment),
        onLongPress: () => _showPaymentOptions(payment),
      ),
    );
  }

  Widget _buildStatusChip(RecurringPaymentStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  Color _getStatusColor(RecurringPaymentStatus status) {
    switch (status) {
      case RecurringPaymentStatus.active:
        return AppTheme.successColor;
      case RecurringPaymentStatus.paused:
        return AppTheme.warningColor;
      case RecurringPaymentStatus.cancelled:
        return AppTheme.errorColor;
      case RecurringPaymentStatus.completed:
        return Colors.blue;
    }
  }

  IconData _getFrequencyIcon(RecurringFrequency frequency) {
    switch (frequency) {
      case RecurringFrequency.daily:
        return Icons.today;
      case RecurringFrequency.weekly:
        return Icons.view_week;
      case RecurringFrequency.monthly:
        return Icons.calendar_month;
      case RecurringFrequency.yearly:
        return Icons.calendar_today;
    }
  }

  void _addRecurringPayment() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => const AddEditRecurringPaymentScreen(),
          ),
        )
        .then((_) => _loadData());
  }

  void _viewPaymentDetail(RecurringPaymentModel payment) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => RecurringPaymentDetailScreen(payment: payment),
          ),
        )
        .then((_) => _loadData());
  }

  void _showPaymentOptions(RecurringPaymentModel payment) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (payment.status == RecurringPaymentStatus.active)
                  ListTile(
                    leading: const Icon(Icons.pause),
                    title: const Text('Pause'),
                    onTap: () {
                      Navigator.pop(context);
                      _pausePayment(payment);
                    },
                  ),
                if (payment.status == RecurringPaymentStatus.paused)
                  ListTile(
                    leading: const Icon(Icons.play_arrow),
                    title: const Text('Resume'),
                    onTap: () {
                      Navigator.pop(context);
                      _resumePayment(payment);
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit'),
                  onTap: () {
                    Navigator.pop(context);
                    _editPayment(payment);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.cancel, color: AppTheme.errorColor),
                  title: const Text(
                    'Cancel',
                    style: TextStyle(color: AppTheme.errorColor),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _cancelPayment(payment);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: AppTheme.errorColor),
                  title: const Text(
                    'Delete',
                    style: TextStyle(color: AppTheme.errorColor),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _deletePayment(payment);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _editPayment(RecurringPaymentModel payment) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => AddEditRecurringPaymentScreen(payment: payment),
          ),
        )
        .then((_) => _loadData());
  }

  Future<void> _pausePayment(RecurringPaymentModel payment) async {
    final provider = Provider.of<RecurringPaymentProvider>(
      context,
      listen: false,
    );

    final success = await provider.pauseRecurringPayment(payment.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Recurring payment paused'
                : 'Failed to pause recurring payment',
          ),
        ),
      );
    }
  }

  Future<void> _resumePayment(RecurringPaymentModel payment) async {
    final provider = Provider.of<RecurringPaymentProvider>(
      context,
      listen: false,
    );

    final success = await provider.resumeRecurringPayment(payment.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Recurring payment resumed'
                : 'Failed to resume recurring payment',
          ),
        ),
      );
    }
  }

  Future<void> _cancelPayment(RecurringPaymentModel payment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel Recurring Payment'),
            content: Text(
              'Are you sure you want to cancel "${payment.description}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes, Cancel'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final provider = Provider.of<RecurringPaymentProvider>(
        context,
        listen: false,
      );

      final success = await provider.cancelRecurringPayment(payment.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Recurring payment cancelled'
                  : 'Failed to cancel recurring payment',
            ),
          ),
        );
      }
    }
  }

  Future<void> _deletePayment(RecurringPaymentModel payment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Recurring Payment'),
            content: Text(
              'Are you sure you want to delete "${payment.description}"? This will also delete all associated occurrences.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final provider = Provider.of<RecurringPaymentProvider>(
        context,
        listen: false,
      );

      final success = await provider.deleteRecurringPayment(payment.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Recurring payment deleted'
                  : 'Failed to delete recurring payment',
            ),
          ),
        );
      }
    }
  }
}
