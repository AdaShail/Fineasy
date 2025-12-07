import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:contacts_service/contacts_service.dart';
import 'package:flutter_contacts/flutter_contacts.dart'; //
import 'package:permission_handler/permission_handler.dart';
import '../../models/supplier_model.dart';
import '../../providers/supplier_provider.dart';
import '../../providers/business_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import 'package:uuid/uuid.dart';

class AddEditSupplierScreen extends StatefulWidget {
  final SupplierModel? supplier;

  const AddEditSupplierScreen({super.key, this.supplier});

  @override
  State<AddEditSupplierScreen> createState() => _AddEditSupplierScreenState();
}

class _AddEditSupplierScreenState extends State<AddEditSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _gstController = TextEditingController();
  final _balanceController = TextEditingController();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.supplier != null;

    if (_isEditing) {
      final supplier = widget.supplier!;
      _nameController.text = supplier.name;
      _phoneController.text = supplier.phone ?? '';
      _emailController.text = supplier.email ?? '';
      _addressController.text = supplier.address ?? '';
      _gstController.text = supplier.gstNumber ?? '';
      _balanceController.text = supplier.balance.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _gstController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  Future<void> _importFromContacts() async {
    final permission = await Permission.contacts.request();
    if (permission != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contacts permission is required to import contacts'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
      ); // changed
      if (contacts.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No contacts found'),
              backgroundColor: AppTheme.warningColor,
            ),
          );
        }
        return;
      }

      final selectedContact = await showDialog<Contact>(
        context: context,
        builder: (context) => _ContactPickerDialog(contacts: contacts),
      );

      if (selectedContact != null) {
        setState(() {
          _nameController.text = selectedContact.displayName;
          if (selectedContact.phones.isNotEmpty) {
            _phoneController.text = selectedContact.phones.first.number;
          }
          if (selectedContact.emails.isNotEmpty) {
            _emailController.text = selectedContact.emails.first.address;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to import contacts: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _saveSupplier() async {
    if (!_formKey.currentState!.validate()) return;

    final supplierProvider = Provider.of<SupplierProvider>(
      context,
      listen: false,
    );
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );

    if (businessProvider.business == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Business information not found'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final supplier = SupplierModel(
      id: _isEditing ? widget.supplier!.id : const Uuid().v4(),
      businessId: businessProvider.business!.id,
      userId: businessProvider.business!.userId,
      name: _nameController.text.trim(),
      phone:
          _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
      email:
          _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
      address:
          _addressController.text.trim().isEmpty
              ? null
              : _addressController.text.trim(),
      gstNumber:
          _gstController.text.trim().isEmpty
              ? null
              : _gstController.text.trim(),
      balance: double.tryParse(_balanceController.text) ?? 0.0,
      lastTransactionDate:
          _isEditing ? widget.supplier!.lastTransactionDate : null,
      createdAt: _isEditing ? widget.supplier!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    bool success;
    if (_isEditing) {
      success = await supplierProvider.updateSupplier(supplier);
    } else {
      success = await supplierProvider.addSupplier(supplier);
    }

    if (success && mounted) {
      Navigator.of(context).pop(supplier);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Supplier updated successfully'
                : 'Supplier added successfully',
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(supplierProvider.error ?? 'Failed to save supplier'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Supplier' : 'Add Supplier'),
        actions: [
          if (!_isEditing && AppConstants.enableContactIntegration)
            IconButton(
              icon: const Icon(Icons.contacts),
              onPressed: _importFromContacts,
              tooltip: 'Import from Contacts',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_isEditing && AppConstants.enableContactIntegration)
                Card(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.contacts,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Import from Contacts',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              const Text(
                                'Quickly add supplier details from your phone contacts',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: _importFromContacts,
                          child: const Text('Import'),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Supplier Name *',
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter supplier name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _gstController,
                decoration: const InputDecoration(
                  labelText: 'GST Number',
                  prefixIcon: Icon(Icons.receipt_long),
                  hintText: 'e.g., 22AAAAA0000A1Z5',
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _balanceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Opening Balance',
                  prefixIcon: const Icon(Icons.account_balance_wallet),
                  prefixText: AppConstants.defaultCurrency,
                  helperText:
                      'Positive: You owe supplier, Negative: Supplier owes you',
                ),
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              Consumer<SupplierProvider>(
                builder: (context, supplierProvider, child) {
                  return ElevatedButton(
                    onPressed:
                        supplierProvider.isLoading ? null : _saveSupplier,
                    child:
                        supplierProvider.isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Text(
                              _isEditing ? 'Update Supplier' : 'Add Supplier',
                            ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Contact Picker Dialog with Search
class _ContactPickerDialog extends StatefulWidget {
  final List<Contact> contacts;

  const _ContactPickerDialog({required this.contacts});

  @override
  State<_ContactPickerDialog> createState() => _ContactPickerDialogState();
}

class _ContactPickerDialogState extends State<_ContactPickerDialog> {
  final _searchController = TextEditingController();
  List<Contact> _filteredContacts = [];

  @override
  void initState() {
    super.initState();
    _filteredContacts = widget.contacts;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterContacts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = widget.contacts;
      } else {
        _filteredContacts =
            widget.contacts.where((contact) {
              final name = contact.displayName.toLowerCase();
              final phone =
                  contact.phones.isNotEmpty
                      ? contact.phones.first.number.replaceAll(
                        RegExp(r'[^\d]'),
                        '',
                      )
                      : '';
              final searchQuery = query.toLowerCase();
              final searchDigits = query.replaceAll(RegExp(r'[^\d]'), '');

              return name.contains(searchQuery) || phone.contains(searchDigits);
            }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Contact'),
      content: SizedBox(
        width: double.maxFinite,
        height: 500,
        child: Column(
          children: [
            // Search Field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or phone...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterContacts('');
                          },
                        )
                        : null,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: _filterContacts,
            ),
            const SizedBox(height: 16),

            // Results Count
            if (_searchController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${_filteredContacts.length} contact(s) found',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),

            // Contact List
            Expanded(
              child:
                  _filteredContacts.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No contacts found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try a different search term',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        itemCount: _filteredContacts.length,
                        itemBuilder: (context, index) {
                          final contact = _filteredContacts[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.primaryColor,
                              child: Text(
                                contact.displayName.isNotEmpty
                                    ? contact.displayName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              contact.displayName.isNotEmpty
                                  ? contact.displayName
                                  : 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (contact.phones.isNotEmpty)
                                  Row(
                                    children: [
                                      const Icon(Icons.phone, size: 14),
                                      const SizedBox(width: 4),
                                      Text(contact.phones.first.number),
                                    ],
                                  ),
                                if (contact.emails.isNotEmpty)
                                  Row(
                                    children: [
                                      const Icon(Icons.email, size: 14),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          contact.emails.first.address,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            onTap: () => Navigator.of(context).pop(contact),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
