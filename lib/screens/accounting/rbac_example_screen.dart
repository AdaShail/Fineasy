import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/accounting/rbac_models.dart';
import '../../providers/accounting_rbac_provider.dart';
import '../../providers/auth_provider.dart';

/// Example screen demonstrating RBAC integration
class RBACExampleScreen extends StatefulWidget {
  const RBACExampleScreen({super.key});

  @override
  State<RBACExampleScreen> createState() => _RBACExampleScreenState();
}

class _RBACExampleScreenState extends State<RBACExampleScreen> {
  @override
  void initState() {
    super.initState();
    _initializeRBAC();
  }

  Future<void> _initializeRBAC() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final rbacProvider = Provider.of<AccountingRBACProvider>(
      context,
      listen: false,
    );

    if (authProvider.user != null) {
      await rbacProvider.initialize(
        authProvider.user!.id,
        'business123', // Replace with actual business ID
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accounting RBAC Example')),
      body: Consumer<AccountingRBACProvider>(
        builder: (context, rbacProvider, child) {
          if (rbacProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (rbacProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${rbacProvider.error}'),
                  ElevatedButton(
                    onPressed: _initializeRBAC,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final userRole = rbacProvider.currentUserRole;
          if (userRole == null) {
            return const Center(child: Text('No role assigned'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRoleCard(rbacProvider, userRole),
                const SizedBox(height: 24),
                _buildPermissionsCard(userRole),
                const SizedBox(height: 24),
                _buildActionsCard(rbacProvider, userRole),
                const SizedBox(height: 24),
                if (rbacProvider.canViewAuditTrail())
                  _buildAuditLogsCard(rbacProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoleCard(
    AccountingRBACProvider rbacProvider,
    AccountingUserRole userRole,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Role', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              rbacProvider.getRoleDisplayName(userRole.role),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Assigned: ${_formatDate(userRole.assignedAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (userRole.expiresAt != null)
              Text(
                'Expires: ${_formatDate(userRole.expiresAt!)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.orange),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionsCard(AccountingUserRole userRole) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Permissions (${userRole.permissions.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...userRole.permissions.map((permission) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getPermissionDisplayName(permission),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard(
    AccountingRBACProvider rbacProvider,
    AccountingUserRole userRole,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildActionButton(
              'View Accounts',
              Icons.account_balance,
              userRole.permissions.contains(AccountingPermission.viewAccounts),
              () => _showMessage('Viewing accounts...'),
            ),
            _buildActionButton(
              'Create Journal Entry',
              Icons.add,
              userRole.permissions.contains(
                AccountingPermission.createJournalEntries,
              ),
              () => _showMessage('Creating journal entry...'),
            ),
            _buildActionButton(
              'Post Journal Entry',
              Icons.publish,
              userRole.permissions.contains(
                AccountingPermission.postJournalEntries,
              ),
              () => _showMessage('Posting journal entry...'),
            ),
            _buildActionButton(
              'View Financial Reports',
              Icons.assessment,
              userRole.permissions.contains(
                AccountingPermission.viewFinancialReports,
              ),
              () => _showMessage('Viewing financial reports...'),
            ),
            _buildActionButton(
              'File GST Returns',
              Icons.receipt_long,
              userRole.permissions.contains(
                AccountingPermission.fileGSTReturns,
              ),
              () => _showMessage('Filing GST returns...'),
            ),
            _buildActionButton(
              'Manage Users',
              Icons.people,
              userRole.permissions.contains(AccountingPermission.manageUsers),
              () => _showMessage('Managing users...'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    bool hasPermission,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: hasPermission ? onPressed : null,
          icon: Icon(icon),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(16),
          ),
        ),
      ),
    );
  }

  Widget _buildAuditLogsCard(AccountingRBACProvider rbacProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Audit Logs',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (rbacProvider.recentAuditLogs.isEmpty)
              const Text('No audit logs yet')
            else
              ...rbacProvider.recentAuditLogs.take(10).map((log) {
                return ListTile(
                  leading: Icon(
                    log.granted ? Icons.check_circle : Icons.cancel,
                    color: log.granted ? Colors.green : Colors.red,
                  ),
                  title: Text(log.action),
                  subtitle: Text(
                    '${log.resourceType}: ${log.resourceId}\n${_formatDate(log.timestamp)}',
                  ),
                  trailing:
                      log.granted
                          ? const Text(
                            'Granted',
                            style: TextStyle(color: Colors.green),
                          )
                          : const Text(
                            'Denied',
                            style: TextStyle(color: Colors.red),
                          ),
                );
              }),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  String _getPermissionDisplayName(AccountingPermission permission) {
    final name = permission.toString().split('.').last;
    return name
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Permission gate widget - shows child only if user has permission
class PermissionGate extends StatelessWidget {
  final AccountingPermission permission;
  final Widget child;
  final Widget? fallback;

  const PermissionGate({
    super.key,
    required this.permission,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountingRBACProvider>(
      builder: (context, rbacProvider, _) {
        final hasPermission =
            rbacProvider.currentUserRole?.permissions.contains(permission) ??
            false;

        if (hasPermission) {
          return child;
        }
        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}

/// Example usage of PermissionGate
class AccountingActionButtons extends StatelessWidget {
  const AccountingActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PermissionGate(
          permission: AccountingPermission.createAccounts,
          child: ElevatedButton(
            onPressed: () {
              // Create account logic
            },
            child: const Text('Create Account'),
          ),
        ),
        PermissionGate(
          permission: AccountingPermission.postJournalEntries,
          child: ElevatedButton(
            onPressed: () {
              // Post journal entry logic
            },
            child: const Text('Post Entry'),
          ),
          fallback: const Text(
            'You do not have permission to post entries',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        PermissionGate(
          permission: AccountingPermission.deleteAccounts,
          child: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Delete account logic
            },
          ),
        ),
      ],
    );
  }
}
