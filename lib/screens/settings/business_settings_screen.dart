import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/business_model.dart';
import '../../providers/business_provider.dart';
import '../../utils/constants.dart';
import '../../utils/app_theme.dart';

class BusinessSettingsScreen extends StatefulWidget {
  const BusinessSettingsScreen({super.key});

  @override
  State<BusinessSettingsScreen> createState() => _BusinessSettingsScreenState();
}

class _BusinessSettingsScreenState extends State<BusinessSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _gstController = TextEditingController();

  String _selectedCategory = AppConstants.businessCategories.first;
  String _selectedCountry = 'India';

  @override
  void initState() {
    super.initState();
    _loadBusinessData();
  }

  void _loadBusinessData() {
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );
    final business = businessProvider.business;

    if (business != null) {
      _businessNameController.text = business.name;
      _selectedCategory = business.category;
      _selectedCountry = business.country;
      _addressController.text = business.address ?? '';
      _cityController.text = business.city ?? '';
      _stateController.text = business.state ?? '';
      _pincodeController.text = business.pincode ?? '';
      _gstController.text = business.gstNumber ?? '';
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _gstController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final businessProvider = Provider.of<BusinessProvider>(context);
    final hasExistingBusiness = businessProvider.business != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          hasExistingBusiness ? 'Business Settings' : 'Setup Business',
        ),
        actions: [
          TextButton(
            onPressed: _saveBusiness,
            child: Text(hasExistingBusiness ? 'Save' : 'Create'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add helpful header text
              Consumer<BusinessProvider>(
                builder: (context, businessProvider, child) {
                  final hasExistingBusiness = businessProvider.business != null;
                  return Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color:
                          hasExistingBusiness
                              ? AppTheme.primaryColor.withValues(alpha: 0.1)
                              : AppTheme.warningColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          hasExistingBusiness ? Icons.edit : Icons.add_business,
                          color:
                              hasExistingBusiness
                                  ? AppTheme.primaryColor
                                  : AppTheme.warningColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            hasExistingBusiness
                                ? 'Update your business information below'
                                : 'Complete your business setup to start using the app',
                            style: TextStyle(
                              color:
                                  hasExistingBusiness
                                      ? AppTheme.primaryColor
                                      : AppTheme.warningColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const Text(
                'Business Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _businessNameController,
                decoration: const InputDecoration(
                  labelText: 'Business Name *',
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your business name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Business Category *',
                  prefixIcon: Icon(Icons.category),
                ),
                items:
                    AppConstants.businessCategories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged:
                    (value) => setState(() => _selectedCategory = value!),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: _selectedCountry,
                decoration: const InputDecoration(
                  labelText: 'Country *',
                  prefixIcon: Icon(Icons.flag),
                ),
                items:
                    AppConstants.countries.keys.map((country) {
                      return DropdownMenuItem(
                        value: country,
                        child: Text(country),
                      );
                    }).toList(),
                onChanged: (value) => setState(() => _selectedCountry = value!),
              ),
              const SizedBox(height: 24),

              const Text(
                'Address Information',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(
                        labelText: 'State',
                        prefixIcon: Icon(Icons.map),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Pincode',
                  prefixIcon: Icon(Icons.pin_drop),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _gstController,
                decoration: const InputDecoration(
                  labelText: 'GST Number (Optional)',
                  prefixIcon: Icon(Icons.receipt_long),
                  hintText: 'e.g., 22AAAAA0000A1Z5',
                ),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Currency: ${AppConstants.countries[_selectedCountry]!['currency']} (${AppConstants.countries[_selectedCountry]!['code']})',
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveBusiness() async {
    if (_formKey.currentState!.validate()) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final businessProvider = Provider.of<BusinessProvider>(
        context,
        listen: false,
      );
      final currentBusiness = businessProvider.business;
      final currencyInfo = AppConstants.countries[_selectedCountry]!;

      bool success = false;
      String message = '';

      try {
        if (currentBusiness == null) {
          // Create new business - get current user ID from Supabase
          final user = Supabase.instance.client.auth.currentUser;

          if (user == null) {
            throw Exception('User not authenticated - please sign in again');
          }

          final newBusiness = BusinessModel(
            id: '', // Will be generated by the service
            userId: user.id,
            name: _businessNameController.text.trim(),
            category: _selectedCategory,
            country: _selectedCountry,
            address:
                _addressController.text.trim().isEmpty
                    ? null
                    : _addressController.text.trim(),
            city:
                _cityController.text.trim().isEmpty
                    ? null
                    : _cityController.text.trim(),
            state:
                _stateController.text.trim().isEmpty
                    ? null
                    : _stateController.text.trim(),
            pincode:
                _pincodeController.text.trim().isEmpty
                    ? null
                    : _pincodeController.text.trim(),
            gstNumber:
                _gstController.text.trim().isEmpty
                    ? null
                    : _gstController.text.trim(),
            currency: currencyInfo['code']!,
            currencySymbol: currencyInfo['currency']!,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          success = await businessProvider.createBusiness(newBusiness);

          message =
              success
                  ? 'Business created successfully!'
                  : 'Failed to create business - check console for details';
        } else {
          // Update existing business
          final updatedBusiness = currentBusiness.copyWith(
            name: _businessNameController.text.trim(),
            category: _selectedCategory,
            country: _selectedCountry,
            address:
                _addressController.text.trim().isEmpty
                    ? null
                    : _addressController.text.trim(),
            city:
                _cityController.text.trim().isEmpty
                    ? null
                    : _cityController.text.trim(),
            state:
                _stateController.text.trim().isEmpty
                    ? null
                    : _stateController.text.trim(),
            pincode:
                _pincodeController.text.trim().isEmpty
                    ? null
                    : _pincodeController.text.trim(),
            gstNumber:
                _gstController.text.trim().isEmpty
                    ? null
                    : _gstController.text.trim(),
            currency: currencyInfo['code']!,
            currencySymbol: currencyInfo['currency']!,
            updatedAt: DateTime.now(),
          );

          success = await businessProvider.updateBusiness(updatedBusiness);
          message =
              success
                  ? 'Business updated successfully!'
                  : 'Failed to update business';
        }
      } catch (e) {
        success = false;

        // Provide specific error messages
        if (e.toString().contains('row-level security')) {
          message =
              'Database permission error. Please run the database fixes in Supabase.';
        } else if (e.toString().contains('not authenticated')) {
          message = 'Please sign out and sign in again.';
        } else if (e.toString().contains('duplicate key')) {
          message = 'Business already exists for this user.';
        } else {
          message = 'Error: ${e.toString()}';
        }
      }

      // Hide loading indicator
      if (mounted) {
        Navigator.of(context).pop();

        // Show result message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor:
                success ? AppTheme.successColor : AppTheme.errorColor,
          ),
        );

        if (success) {
          // Navigate back to home or previous screen
          Navigator.of(context).pop();
        }
      }
    }
  }
}
