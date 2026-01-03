import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/business_model.dart';
import '../../providers/business_provider.dart';
import '../../utils/constants.dart';
import '../../utils/app_theme.dart';
import '../widgets/web_card.dart';
import '../widgets/web_form_field.dart';

/// Web-optimized business configuration screen
/// Provides enhanced business settings management for desktop
class WebBusinessConfigurationScreen extends StatefulWidget {
  const WebBusinessConfigurationScreen({super.key});

  @override
  State<WebBusinessConfigurationScreen> createState() =>
      _WebBusinessConfigurationScreenState();
}

class _WebBusinessConfigurationScreenState
    extends State<WebBusinessConfigurationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _gstController = TextEditingController();

  String _selectedCategory = AppConstants.businessCategories.first;
  String _selectedCountry = 'India';
  bool _isLoading = false;

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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Business Configuration',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasExistingBusiness
                            ? 'Update your business information'
                            : 'Complete your business setup',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveBusiness,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(hasExistingBusiness ? 'Save Changes' : 'Create Business'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Business Information
            WebCard(
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Business Information',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: WebFormField(
                          controller: _businessNameController,
                          label: 'Business Name',
                          hint: 'Enter your business name',
                          prefixIcon: const Icon(Icons.business),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your business name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Business Category',
                            prefixIcon: Icon(Icons.category),
                            border: OutlineInputBorder(),
                          ),
                          items: AppConstants.businessCategories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => _selectedCategory = value!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCountry,
                          decoration: const InputDecoration(
                            labelText: 'Country',
                            prefixIcon: Icon(Icons.flag),
                            border: OutlineInputBorder(),
                          ),
                          items: AppConstants.countries.keys.map((country) {
                            return DropdownMenuItem(
                              value: country,
                              child: Text(country),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => _selectedCountry = value!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.primaryColor),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.currency_exchange,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Currency',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${AppConstants.countries[_selectedCountry]!['currency']} (${AppConstants.countries[_selectedCountry]!['code']})',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Address Information
            WebCard(
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Address Information',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 24),
                  WebFormField(
                    controller: _addressController,
                    label: 'Address',
                    hint: 'Enter your business address',
                    prefixIcon: const Icon(Icons.location_on),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: WebFormField(
                          controller: _cityController,
                          label: 'City',
                          hint: 'Enter city',
                          prefixIcon: const Icon(Icons.location_city),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: WebFormField(
                          controller: _stateController,
                          label: 'State',
                          hint: 'Enter state',
                          prefixIcon: const Icon(Icons.map),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: WebFormField(
                          controller: _pincodeController,
                          label: 'Pincode',
                          hint: 'Enter pincode',
                          prefixIcon: const Icon(Icons.pin_drop),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tax Information
            WebCard(
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tax Information',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 24),
                  WebFormField(
                    controller: _gstController,
                    label: 'GST Number (Optional)',
                    hint: 'e.g., 22AAAAA0000A1Z5',
                    prefixIcon: const Icon(Icons.receipt_long),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveBusiness() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

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
          // Create new business
          final user = Supabase.instance.client.auth.currentUser;

          if (user == null) {
            throw Exception('User not authenticated - please sign in again');
          }

          final newBusiness = BusinessModel(
            id: '',
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
                  : 'Failed to create business';
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
        message = 'Error: ${e.toString()}';
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor:
                success ? AppTheme.successColor : AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
