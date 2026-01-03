# Form Patterns and Validation

Comprehensive form patterns for the Fineasy web application, implementing WCAG 2.1 AA accessibility standards with inline validation, state management, and keyboard navigation.

## Overview

This module provides three main components:

1. **Form Builder** - Configuration-driven form creation with automatic validation
2. **Inline Validation** - Real-time validation with multiple trigger modes
3. **Form Accessibility** - WCAG-compliant forms with proper ARIA attributes and keyboard navigation

## Features

### Form Builder (`form_builder.dart`)

- ✅ Configuration-driven form creation
- ✅ Multiple field types (text, email, password, number, select, checkbox, radio, textarea, date/time)
- ✅ Built-in validation engine
- ✅ Conditional field visibility
- ✅ Form state management
- ✅ Automatic focus management
- ✅ Loading states
- ✅ Error handling

### Inline Validation (`inline_validation.dart`)

- ✅ Multiple validation triggers (onChange, onBlur, onSubmit, onChangeAfterBlur)
- ✅ Real-time validation feedback
- ✅ Visual state indicators (valid, invalid, validating)
- ✅ Validation summary component
- ✅ Field state management
- ✅ Error message display

### Form Accessibility (`form_accessibility.dart`)

- ✅ WCAG 2.1 AA compliance
- ✅ Proper label associations
- ✅ ARIA attributes for all states
- ✅ Skip links for long forms
- ✅ Focus management for errors
- ✅ Keyboard navigation support
- ✅ Screen reader announcements
- ✅ Form sections with landmarks

## Requirements Validation

This implementation validates the following requirements from the design document:

- **Requirement 4.1**: Form labels above input fields ✅
- **Requirement 4.2**: Placeholder text as examples ✅
- **Requirement 4.3**: Inline validation feedback ✅
- **Requirement 4.4**: Error messages below fields with guidance ✅
- **Requirement 4.5**: Visual indicators for field states ✅
- **Requirement 4.6**: Grouped form fields ✅
- **Requirement 4.7**: Tooltips for complex fields ✅
- **Requirement 4.8**: Required field indicators ✅
- **Requirement 4.9**: Character counts for limited fields ✅
- **Requirement 4.11**: Keyboard navigation support ✅
- **Requirement 4.12**: Error summary on submission failure ✅

## Usage

### Basic Form Builder

```dart
WebFormBuilder(
  fields: [
    FormFieldConfig(
      name: 'email',
      label: 'Email Address',
      type: FormFieldType.email,
      required: true,
      placeholder: 'you@example.com',
      validators: [FormValidators.email],
    ),
    FormFieldConfig(
      name: 'password',
      label: 'Password',
      type: FormFieldType.password,
      required: true,
      validators: [
        FormValidators.minLength(8),
      ],
    ),
  ],
  onSubmit: (values) async {
    // Handle form submission
    print('Form values: $values');
  },
  submitLabel: 'Sign In',
)
```

### Inline Validation

```dart
final controller = InlineValidationController(
  trigger: ValidationTrigger.onChangeAfterBlur,
);

ValidatedField(
  fieldName: 'email',
  label: 'Email',
  value: email,
  onChanged: (value) => setState(() => email = value),
  controller: controller,
  required: true,
  validators: [
    (value) {
      if (!value.contains('@')) {
        return 'Please enter a valid email';
      }
      return null;
    },
  ],
)
```

### Accessible Form

```dart
AccessibleForm(
  formLabel: 'Contact Form',
  formDescription: 'Please fill out all required fields',
  skipLinks: [
    FormSkipLink(
      label: 'Skip to submit button',
      targetId: 'submit',
      targetKey: submitKey,
    ),
  ],
  children: [
    AccessibleFormField(
      id: 'name',
      label: 'Full Name',
      value: name,
      onChanged: (value) => setState(() => name = value),
      required: true,
      ariaLabel: 'Full name input field',
    ),
  ],
)
```

## Field Types

### Text Input Types
- `FormFieldType.text` - Standard text input
- `FormFieldType.email` - Email input with email keyboard
- `FormFieldType.password` - Password input with obscured text
- `FormFieldType.number` - Numeric input
- `FormFieldType.tel` - Phone number input
- `FormFieldType.url` - URL input
- `FormFieldType.search` - Search input
- `FormFieldType.textarea` - Multi-line text input

### Selection Types
- `FormFieldType.select` - Dropdown selection
- `FormFieldType.checkbox` - Single checkbox
- `FormFieldType.radio` - Radio button group

### Date/Time Types
- `FormFieldType.date` - Date picker
- `FormFieldType.time` - Time picker
- `FormFieldType.dateTime` - Date and time picker

## Validation

### Built-in Validators

```dart
// Required field
FormValidators.required

// Email validation
FormValidators.email

// URL validation
FormValidators.url

// Phone number validation
FormValidators.phone

// Numeric validation
FormValidators.numeric

// Length validation
FormValidators.minLength(8)
FormValidators.maxLength(100)

// Value range validation
FormValidators.min(18)
FormValidators.max(120)

// Pattern validation
FormValidators.pattern(
  RegExp(r'^[a-zA-Z0-9]+$'),
  'Only alphanumeric characters allowed',
)

// Combine multiple validators
FormValidators.combine([
  FormValidators.required,
  FormValidators.email,
  FormValidators.minLength(5),
])
```

### Custom Validators

```dart
FormFieldValidator customValidator = (value) {
  if (value == null || value.toString().isEmpty) return null;
  
  // Your validation logic
  if (!isValid(value)) {
    return 'Custom error message';
  }
  
  return null;
};
```

## Validation Triggers

### onChange
Validates on every keystroke:
```dart
ValidationTrigger.onChange
```

### onBlur
Validates when field loses focus:
```dart
ValidationTrigger.onBlur
```

### onSubmit
Validates only on form submission:
```dart
ValidationTrigger.onSubmit
```

### onChangeAfterBlur
Validates on change, but only after first blur:
```dart
ValidationTrigger.onChangeAfterBlur
```

## Conditional Fields

Show/hide fields based on other field values:

```dart
FormFieldConfig(
  name: 'otherCountry',
  label: 'Please specify',
  type: FormFieldType.text,
  dependsOn: 'country', // Shows only if country has a value
),

// Or use custom visibility condition
FormFieldConfig(
  name: 'companyName',
  label: 'Company Name',
  type: FormFieldType.text,
  visibilityCondition: (formValues) {
    return formValues['accountType'] == 'business';
  },
),
```

## Accessibility Features

### Label Associations
All fields have proper label associations using semantic HTML and ARIA attributes.

### ARIA Attributes
- `aria-label` - Descriptive labels for screen readers
- `aria-describedby` - Links to helper text and error messages
- `aria-required` - Indicates required fields
- `aria-invalid` - Indicates validation errors
- `aria-live` - Announces dynamic changes

### Keyboard Navigation
- **Tab** - Move to next field
- **Shift+Tab** - Move to previous field
- **Enter** - Submit form (when on submit button)
- **Escape** - Cancel/clear form

### Skip Links
Allow keyboard users to skip to specific form sections:

```dart
FormSkipLink(
  label: 'Skip to payment information',
  targetId: 'payment',
  targetKey: paymentSectionKey,
)
```

### Focus Management
Automatically focuses the first error field when validation fails:

```dart
final focusManager = FormFocusManager();

// Register fields
focusManager.registerField('email', emailFocusNode, emailKey);

// Focus first error
focusManager.focusFirstError(['email', 'password']);
```

## Form State Management

### Form Values
Access current form values:
```dart
final values = formState.values;
print('Email: ${values['email']}');
```

### Validation State
Check if form is valid:
```dart
if (controller.isValid) {
  // Submit form
}
```

### Error Messages
Get all error messages:
```dart
final errors = controller.errors;
// { 'email': 'Invalid email', 'password': 'Too short' }
```

## Visual States

Fields display different visual states:

1. **Default** - Normal state
2. **Focus** - Blue border when focused
3. **Valid** - Green checkmark when valid
4. **Invalid** - Red border with error icon
5. **Disabled** - Gray background, not interactive
6. **Validating** - Loading spinner (for async validation)

## Best Practices

### 1. Use Appropriate Field Types
Choose the correct field type for better mobile keyboard support:
```dart
FormFieldType.email  // Shows @ key on mobile
FormFieldType.tel    // Shows numeric keypad
FormFieldType.number // Shows number keyboard
```

### 2. Provide Helper Text
Guide users with helpful information:
```dart
helperText: 'Password must be at least 8 characters'
```

### 3. Use Validation Triggers Wisely
- Use `onBlur` for most fields (less intrusive)
- Use `onChange` for real-time feedback (password strength)
- Use `onChangeAfterBlur` for balance between the two

### 4. Group Related Fields
Use form sections to organize long forms:
```dart
FormSection(
  title: 'Personal Information',
  children: [
    // Related fields
  ],
)
```

### 5. Implement Skip Links
For long forms, provide skip links:
```dart
skipLinks: [
  FormSkipLink(label: 'Skip to section 2', ...),
]
```

### 6. Focus First Error
Always focus the first error field on validation failure:
```dart
focusManager.focusFirstError(errorFields);
```

## Testing

### Unit Tests
Test individual validators:
```dart
test('email validator rejects invalid emails', () {
  expect(FormValidators.email('invalid'), isNotNull);
  expect(FormValidators.email('valid@email.com'), isNull);
});
```

### Widget Tests
Test form interactions:
```dart
testWidgets('form shows error on invalid input', (tester) async {
  await tester.pumpWidget(MyForm());
  await tester.enterText(find.byType(TextField), 'invalid');
  await tester.pump();
  expect(find.text('Invalid input'), findsOneWidget);
});
```

### Accessibility Tests
Test keyboard navigation and screen reader support:
```dart
testWidgets('form is keyboard navigable', (tester) async {
  await tester.pumpWidget(MyForm());
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  // Verify focus moved to next field
});
```

## Examples

See `form_patterns_example.dart` for complete working examples of:
- Basic form builder
- Inline validation
- Accessible forms
- Complete registration form

## Performance Considerations

1. **Debounce Validation** - For expensive validators, debounce onChange validation
2. **Lazy Loading** - Load form sections on demand for very long forms
3. **Memoization** - Cache validation results when possible
4. **Virtual Scrolling** - Use virtual scrolling for forms with many fields

## Browser Support

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## Related Components

- `web_input.dart` - Base input component
- `web_button.dart` - Submit/cancel buttons
- `web_modal.dart` - Forms in modals
- `web_toast.dart` - Success/error notifications

## Contributing

When adding new form features:
1. Ensure WCAG 2.1 AA compliance
2. Add proper ARIA attributes
3. Support keyboard navigation
4. Include validation examples
5. Update this README
6. Add tests

## License

Copyright © 2024 Fineasy. All rights reserved.
