import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/business_provider.dart';
import '../../models/business_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/constants.dart';
import '../dashboard/dashboard_screen.dart';
import 'package:uuid/uuid.dart';

class BusinessSetupScreen extends StatefulWidget {
  const BusinessSetupScreen({super.key});

  @override
  State<BusinessSetupScreen> createState() => _BusinessSetupScreenState();
}

class _BusinessSetupScreenState extends State<BusinessSetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form controllers
  final _businessNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _gstController = TextEditingController();

  String _selectedCategory = AppConstants.businessCategories.first;
  String _selectedCountry = 'India';

  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  @override
  void dispose() {
    _businessNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _gstController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      if (_formKeys[_currentPage].currentState!.validate()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _completeBusiness();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeBusiness() async {
    if (!_formKeys[_currentPage].currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final businessProvider = Provider.of<BusinessProvider>(
      context,
      listen: false,
    );

    if (authProvider.user == null) return;

    final currencyInfo = AppConstants.countries[_selectedCountry]!;

    final business = BusinessModel(
      id: const Uuid().v4(),
      userId: authProvider.user!.id,
      name: _businessNameController.text.trim(),
      category: _selectedCategory,
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
      country: _selectedCountry,
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

    final success = await businessProvider.createBusiness(business);

    if (success && mounted) {
      // Ensure the business is loaded in the provider
      await businessProvider.loadBusiness(authProvider.user!.id);

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
        (route) => false,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(businessProvider.error ?? 'Failed to create business'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading:
            _currentPage > 0
                ? IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppTheme.primaryTextColor,
                  ),
                  onPressed: _previousPage,
                )
                : null,
        title: Text(
          'Business Setup',
          style: const TextStyle(color: AppTheme.primaryTextColor),
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: List.generate(3, (index) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                          index <= _currentPage
                              ? AppTheme.primaryColor
                              : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Page Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              children: [
                _buildBasicInfoPage(),
                _buildLocationPage(),
                _buildFinalizePage(),
              ],
            ),
          ),

          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousPage,
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 16),
                Expanded(
                  child: Consumer<BusinessProvider>(
                    builder: (context, businessProvider, child) {
                      return ElevatedButton(
                        onPressed:
                            businessProvider.isLoading ? null : _nextPage,
                        child:
                            businessProvider.isLoading
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
                                  _currentPage < 2 ? 'Next' : 'Complete Setup',
                                ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKeys[0],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Let\'s start with your business basics',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 32),

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
              onChanged: (value) => setState(() => _selectedCategory = value!),
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

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your currency will be set to ${AppConstants.countries[_selectedCountry]!['currency']} (${AppConstants.countries[_selectedCountry]!['code']})',
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
    );
  }

  Widget _buildLocationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKeys[1],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Business Location',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your business address (optional)',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 32),

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
          ],
        ),
      ),
    );
  }

  Widget _buildFinalizePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKeys[2],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Review & Complete',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Review your business information',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 32),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildReviewItem(
                      'Business Name',
                      _businessNameController.text,
                    ),
                    _buildReviewItem('Category', _selectedCategory),
                    _buildReviewItem('Country', _selectedCountry),
                    if (_addressController.text.isNotEmpty)
                      _buildReviewItem('Address', _addressController.text),
                    if (_cityController.text.isNotEmpty)
                      _buildReviewItem('City', _cityController.text),
                    if (_stateController.text.isNotEmpty)
                      _buildReviewItem('State', _stateController.text),
                    if (_pincodeController.text.isNotEmpty)
                      _buildReviewItem('Pincode', _pincodeController.text),
                    if (_gstController.text.isNotEmpty)
                      _buildReviewItem('GST Number', _gstController.text),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppTheme.successColor,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You\'re all set! Click "Complete Setup" to start managing your business.',
                      style: TextStyle(
                        color: AppTheme.successColor,
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
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppTheme.primaryTextColor),
            ),
          ),
        ],
      ),
    );
  }
}
