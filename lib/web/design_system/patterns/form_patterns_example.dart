import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'form_builder.dart';
import 'inline_validation.dart';
import 'form_accessibility.dart';

/// Example demonstrating form patterns and validation
class FormPatternsExample extends StatefulWidget {
  const FormPatternsExample({super.key});

  @override
  State<FormPatternsExample> createState() => _FormPatternsExampleState();
}

class _FormPatternsExampleState extends State<FormPatternsExample> {
  int _selectedExample = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Form Patterns Examples'),
      ),
      body: Row(
        children: [
          // Navigation
          NavigationRail(
            selectedIndex: _selectedExample,
            onDestinationSelected: (index) {
              setState(() {
                _selectedExample = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.build),
                label: Text('Form Builder'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.check_circle),
                label: Text('Inline Validation'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.accessibility),
                label: Text('Accessibility'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Complete Form'),
              ),
            ],
          ),
          VerticalDivider(thickness: 1, width: 1),
          // Content
          Expanded(
            child: _buildExample(),
          ),
        ],
      ),
    );
  }

  Widget _buildExample() {
    switch (_selectedExample) {
      case 0:
        return FormBuilderExample();
      case 1:
        return InlineValidationExample();
      case 2:
        return AccessibilityExample();
      case 3:
        return CompleteFormExample();
      default:
        return FormBuilderExample();
    }
  }
}

/// Example 1: Form Builder
class FormBuilderExample extends StatefulWidget {
  const FormBuilderExample({super.key});

  @override
  State<FormBuilderExample> createState() => _FormBuilderExampleState();
}

class _FormBuilderExampleState extends State<FormBuilderExample> {
  bool _isLoading = false;
  String? _successMessage;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Form Builder Example',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 8),
          Text(
            'Demonstrates the WebFormBuilder with various field types and validation.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 24),
          
          if (_successMessage != null) ...[
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 12),
                  Expanded(child: Text(_successMessage!)),
                ],
              ),
            ),
            SizedBox(height: 24),
          ],

          WebFormBuilder(
            fields: [
              FormFieldConfig(
                name: 'firstName',
                label: 'First Name',
                type: FormFieldType.text,
                required: true,
                placeholder: 'Enter your first name',
                validators: [
                  FormValidators.minLength(2),
                ],
              ),
              FormFieldConfig(
                name: 'lastName',
                label: 'Last Name',
                type: FormFieldType.text,
                required: true,
                placeholder: 'Enter your last name',
              ),
              FormFieldConfig(
                name: 'email',
                label: 'Email Address',
                type: FormFieldType.email,
                required: true,
                placeholder: 'you@example.com',
                helperText: 'We\'ll never share your email',
                validators: [FormValidators.email],
              ),
              FormFieldConfig(
                name: 'phone',
                label: 'Phone Number',
                type: FormFieldType.tel,
                placeholder: '+1 (555) 123-4567',
                validators: [FormValidators.phone],
              ),
              FormFieldConfig(
                name: 'age',
                label: 'Age',
                type: FormFieldType.number,
                required: true,
                validators: [
                  FormValidators.numeric,
                  FormValidators.min(18),
                  FormValidators.max(120),
                ],
              ),
              FormFieldConfig(
                name: 'country',
                label: 'Country',
                type: FormFieldType.select,
                required: true,
                options: [
                  FormFieldOption(label: 'United States', value: 'US'),
                  FormFieldOption(label: 'Canada', value: 'CA'),
                  FormFieldOption(label: 'United Kingdom', value: 'UK'),
                  FormFieldOption(label: 'India', value: 'IN'),
                ],
              ),
              FormFieldConfig(
                name: 'bio',
                label: 'Biography',
                type: FormFieldType.textarea,
                placeholder: 'Tell us about yourself',
                maxLength: 500,
                maxLines: 5,
              ),
              FormFieldConfig(
                name: 'newsletter',
                label: 'Subscribe to newsletter',
                type: FormFieldType.checkbox,
                initialValue: false,
              ),
            ],
            onSubmit: (values) async {
              setState(() {
                _isLoading = true;
              });

              // Simulate API call
              await Future.delayed(Duration(seconds: 2));

              setState(() {
                _isLoading = false;
                _successMessage = 'Form submitted successfully! Values: ${values.toString()}';
              });
            },
            onCancel: () {
              setState(() {
                _successMessage = null;
              });
            },
            submitLabel: 'Submit Form',
            cancelLabel: 'Reset',
            loading: _isLoading,
          ),
        ],
      ),
    );
  }
}

/// Example 2: Inline Validation
class InlineValidationExample extends StatefulWidget {
  const InlineValidationExample({super.key});

  @override
  State<InlineValidationExample> createState() => _InlineValidationExampleState();
}

class _InlineValidationExampleState extends State<InlineValidationExample> {
  final _controller = InlineValidationController(
    trigger: ValidationTrigger.onChangeAfterBlur,
  );
  
  String _email = '';
  String _password = '';
  String _confirmPassword = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inline Validation Example',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 8),
          Text(
            'Demonstrates inline validation with different trigger modes.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 24),

          // Validation summary
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return ValidationSummary(
                errors: _controller.errors,
              );
            },
          ),
          SizedBox(height: 24),

          ValidatedField(
            fieldName: 'email',
            label: 'Email',
            placeholder: 'you@example.com',
            value: _email,
            onChanged: (value) => setState(() => _email = value),
            controller: _controller,
            required: true,
            validators: [
              (value) {
                if (value.isEmpty) return null;
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ],
            prefixIcon: Icon(Icons.email),
          ),
          SizedBox(height: 24),

          ValidatedField(
            fieldName: 'password',
            label: 'Password',
            placeholder: 'Enter password',
            value: _password,
            onChanged: (value) => setState(() => _password = value),
            controller: _controller,
            required: true,
            obscureText: true,
            validators: [
              (value) {
                if (value.isEmpty) return null;
                if (value.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                if (!value.contains(RegExp(r'[A-Z]'))) {
                  return 'Password must contain at least one uppercase letter';
                }
                if (!value.contains(RegExp(r'[0-9]'))) {
                  return 'Password must contain at least one number';
                }
                return null;
              },
            ],
            prefixIcon: Icon(Icons.lock),
          ),
          SizedBox(height: 24),

          ValidatedField(
            fieldName: 'confirmPassword',
            label: 'Confirm Password',
            placeholder: 'Re-enter password',
            value: _confirmPassword,
            onChanged: (value) => setState(() => _confirmPassword = value),
            controller: _controller,
            required: true,
            obscureText: true,
            validators: [
              (value) {
                if (value.isEmpty) return null;
                if (value != _password) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ],
            prefixIcon: Icon(Icons.lock_outline),
          ),
          SizedBox(height: 24),

          ElevatedButton(
            onPressed: () {
              if (_controller.isValid) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Form is valid!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please fix validation errors')),
                );
              }
            },
            child: Text('Validate Form'),
          ),
        ],
      ),
    );
  }
}

/// Example 3: Accessibility Features
class AccessibilityExample extends StatefulWidget {
  const AccessibilityExample({super.key});

  @override
  State<AccessibilityExample> createState() => _AccessibilityExampleState();
}

class _AccessibilityExampleState extends State<AccessibilityExample> {
  final _personalInfoKey = GlobalKey();
  final _addressKey = GlobalKey();
  final _focusManager = FormFocusManager();
  
  String _name = '';
  String _email = '';
  String _street = '';
  String _city = '';

  @override
  void dispose() {
    _focusManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accessibility Features Example',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 8),
          Text(
            'Demonstrates accessible forms with skip links and proper ARIA attributes.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 24),

          AccessibleForm(
            formLabel: 'User Registration Form',
            formDescription: 'Please fill out all required fields to register',
            skipLinks: [
              FormSkipLink(
                label: 'Skip to Personal Information',
                targetId: 'personal-info',
                targetKey: _personalInfoKey,
              ),
              FormSkipLink(
                label: 'Skip to Address',
                targetId: 'address',
                targetKey: _addressKey,
              ),
            ],
            children: [
              FormSection(
                sectionKey: _personalInfoKey,
                title: 'Personal Information',
                description: 'Basic information about you',
                children: [
                  AccessibleFormField(
                    id: 'name',
                    label: 'Full Name',
                    placeholder: 'John Doe',
                    value: _name,
                    onChanged: (value) => setState(() => _name = value),
                    required: true,
                    ariaLabel: 'Full name input field',
                  ),
                  SizedBox(height: 16),
                  AccessibleFormField(
                    id: 'email',
                    label: 'Email Address',
                    placeholder: 'john@example.com',
                    value: _email,
                    onChanged: (value) => setState(() => _email = value),
                    required: true,
                    keyboardType: TextInputType.emailAddress,
                    helperText: 'We will send confirmation to this email',
                    ariaLabel: 'Email address input field',
                  ),
                ],
              ),
              SizedBox(height: 32),
              FormSection(
                sectionKey: _addressKey,
                title: 'Address',
                description: 'Your mailing address',
                children: [
                  AccessibleFormField(
                    id: 'street',
                    label: 'Street Address',
                    placeholder: '123 Main St',
                    value: _street,
                    onChanged: (value) => setState(() => _street = value),
                    required: true,
                  ),
                  SizedBox(height: 16),
                  AccessibleFormField(
                    id: 'city',
                    label: 'City',
                    placeholder: 'New York',
                    value: _city,
                    onChanged: (value) => setState(() => _city = value),
                    required: true,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Example 4: Complete Form
class CompleteFormExample extends StatefulWidget {
  const CompleteFormExample({super.key});

  @override
  State<CompleteFormExample> createState() => _CompleteFormExampleState();
}

class _CompleteFormExampleState extends State<CompleteFormExample> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Complete Form Example',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 8),
          Text(
            'A complete form combining all patterns: builder, validation, and accessibility.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 24),

          WebFormBuilder(
            fields: [
              // Personal Information
              FormFieldConfig(
                name: 'fullName',
                label: 'Full Name',
                type: FormFieldType.text,
                required: true,
                placeholder: 'John Doe',
                validators: [
                  FormValidators.minLength(3),
                ],
                icon: Icon(Icons.person),
              ),
              FormFieldConfig(
                name: 'email',
                label: 'Email Address',
                type: FormFieldType.email,
                required: true,
                placeholder: 'john@example.com',
                helperText: 'We\'ll use this for account notifications',
                validators: [FormValidators.email],
                icon: Icon(Icons.email),
              ),
              FormFieldConfig(
                name: 'phone',
                label: 'Phone Number',
                type: FormFieldType.tel,
                placeholder: '+1 (555) 123-4567',
                validators: [FormValidators.phone],
                icon: Icon(Icons.phone),
              ),
              
              // Account Settings
              FormFieldConfig(
                name: 'username',
                label: 'Username',
                type: FormFieldType.text,
                required: true,
                placeholder: 'johndoe',
                helperText: 'Choose a unique username',
                validators: [
                  FormValidators.minLength(4),
                  FormValidators.pattern(
                    RegExp(r'^[a-zA-Z0-9_]+$'),
                    'Username can only contain letters, numbers, and underscores',
                  ),
                ],
              ),
              FormFieldConfig(
                name: 'password',
                label: 'Password',
                type: FormFieldType.password,
                required: true,
                placeholder: 'Enter a strong password',
                validators: [
                  FormValidators.minLength(8),
                  (value) {
                    if (value == null || value.toString().isEmpty) return null;
                    if (!value.toString().contains(RegExp(r'[A-Z]'))) {
                      return 'Must contain at least one uppercase letter';
                    }
                    if (!value.toString().contains(RegExp(r'[0-9]'))) {
                      return 'Must contain at least one number';
                    }
                    return null;
                  },
                ],
              ),
              
              // Preferences
              FormFieldConfig(
                name: 'country',
                label: 'Country',
                type: FormFieldType.select,
                required: true,
                options: [
                  FormFieldOption(label: 'United States', value: 'US'),
                  FormFieldOption(label: 'Canada', value: 'CA'),
                  FormFieldOption(label: 'United Kingdom', value: 'UK'),
                  FormFieldOption(label: 'India', value: 'IN'),
                  FormFieldOption(label: 'Australia', value: 'AU'),
                ],
              ),
              FormFieldConfig(
                name: 'notifications',
                label: 'Receive email notifications',
                type: FormFieldType.checkbox,
                initialValue: true,
              ),
              FormFieldConfig(
                name: 'terms',
                label: 'I agree to the Terms and Conditions',
                type: FormFieldType.checkbox,
                required: true,
                validators: [
                  (value) {
                    if (value != true) {
                      return 'You must agree to the terms';
                    }
                    return null;
                  },
                ],
              ),
            ],
            onSubmit: (values) async {
              setState(() {
                _isLoading = true;
              });

              // Simulate API call
              await Future.delayed(Duration(seconds: 2));

              setState(() {
                _isLoading = false;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Account created successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            submitLabel: 'Create Account',
            loading: _isLoading,
          ),
        ],
      ),
    );
  }
}
