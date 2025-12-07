import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/customer_model.dart';
import '../../providers/customer_provider.dart';
import '../../providers/business_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class AddEditCustomerScreen extends StatefulWidget {
  final CustomerModel? customer;

  const AddEditCustomerScreen({super.key, this.customer});

  @override
  State<AddEditCustomerScreen> createState() => _AddEditCustomerScreenState();
}

class _AddEditCustomerScreenState extends State<AddEditCustomerScreen> {
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
    _isEditing = widget.customer != null;

    if (_isEditing) {
      final customer = widget.customer!;
      _nameController.text = customer.name;
      _phoneController.text = customer.phone ?? '';
      _emailController.text = customer.email ?? '';
      _addressController.text = customer.address ?? '';
      _gstController.text = customer.gstNumber ?? '';
      _balanceController.text = customer.balance.toString();
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

  // Future<void> _importFromContacts() async {
  //   final permission = await Permission.contacts.request();
  //   if (permission != PermissionStatus.granted) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Contacts permission is required to import contacts'),
  //           backgroundColor: AppTheme.errorColor,
  //         ),
  //       );
  //     }
  //     return;
  //   }

  //   try {
  //     final contacts = await FlutterContacts.getContacts(withProperties: true);
  //     if (contacts.isEmpty) {
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(
  //             content: Text('No contacts found'),
  //             backgroundColor: AppTheme.warningColor,
  //           ),
  //         );
  //       }
  //       return;
  //     }

  //     final selectedContact = await showDialog<Contact>(
  //       context: context,
  //       builder:
  //           (context) => AlertDialog(
  //             title: const Text('Select Contact'),
  //             content: SizedBox(
  //               width: double.maxFinite,
  //               height: 400,
  //               child: ListView.builder(
  //                 itemCount: contacts.length,
  //                 itemBuilder: (context, index) {
  //                   final contact = contacts[index];
  //                   return ListTile(
  //                     leading: CircleAvatar(
  //                       child: Text(
  //                         contact.displayName?.substring(0, 1).toUpperCase() ?:
  //                             '?',
  //                       ),
  //                     ),
  //                     title: Text(contact.displayName ?? 'Unknown'),
  //                     subtitle: Text(
  //                       contact.phones?.isNotEmpty == true
  //                           ? contact.phones!.first.value ?? ''
  //                           : 'No phone number',
  //                     ),
  //                     onTap: () => Navigator.of(context).pop(contact),
  //                   );
  //                 },
  //               ),
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.of(context).pop(),
  //                 child: const Text('Cancel'),
  //               ),
  //             ],
  //           ),
  //     );

  //     if (selectedContact != null) {
  //       setState(() {
  //         _nameController.text = selectedContact.displayName ?? '';
  //         if (selectedContact.phones?.isNotEmpty == true) {
  //           _phoneController.text = selectedContact.phones!.first.value ?? '';
  //         }
  //         if (selectedContact.emails?.isNotEmpty == true) {
  //           _emailController.text = selectedContact.emails!.first.value ?? '';
  //         }
  //       });
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Failed to import contacts: $e'),
  //           backgroundColor: AppTheme.errorColor,
  //         ),
  //       );
  //     }
  //   }
  // }
  Future<void> _importFromContacts() async {
    // Request permission (flutter_contacts has built-in, but we keep consistency)
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
      final contacts = await FlutterContacts.getContacts(withProperties: true);
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

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    final customerProvider = Provider.of<CustomerProvider>(
      context,
      listen: false,
    );
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );

    if (businessProvider.business == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Business information not found'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final customer = CustomerModel(
      id: _isEditing ? widget.customer!.id : const Uuid().v4(),
      businessId: businessProvider.business!.id,
      userId:
          businessProvider.business!.userId, // REQUIRED: Added missing userId
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
          _isEditing ? widget.customer!.lastTransactionDate : null,
      createdAt: _isEditing ? widget.customer!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    bool success;
    if (_isEditing) {
      success = await customerProvider.updateCustomer(customer);
    } else {
      success = await customerProvider.addCustomer(customer);
    }

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop(customer);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Customer updated successfully'
                : 'Customer added successfully',
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(customerProvider.error ?? 'Failed to save customer'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Customer' : 'Add Customer'),
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
                                'Quickly add customer details from your phone contacts',
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
                  labelText: 'Customer Name *',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter customer name';
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
                      'Positive: Customer owes you, Negative: You owe customer',
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

              Consumer<CustomerProvider>(
                builder: (context, customerProvider, child) {
                  return ElevatedButton(
                    onPressed:
                        customerProvider.isLoading ? null : _saveCustomer,
                    child:
                        customerProvider.isLoading
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
                              _isEditing ? 'Update Customer' : 'Add Customer',
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
