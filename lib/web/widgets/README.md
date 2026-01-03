# Web UI Components

Enhanced UI components optimized for web platform with desktop-first features.

## Components

### 1. WebDataTable

Advanced data table with sorting, filtering, pagination, and selection.

**Features:**
- Column sorting (ascending/descending)
- Search/filter functionality
- Pagination with configurable rows per page
- Row selection (single/multi)
- Custom cell rendering
- Responsive column visibility
- Export actions support

**Usage:**
```dart
import 'package:fineasy/web/widgets/web_components.dart';

WebDataTable<Invoice>(
  data: invoices,
  columns: [
    WebDataColumn(
      label: 'Invoice #',
      field: 'number',
      valueGetter: (invoice) => invoice.invoiceNumber,
    ),
    WebDataColumn(
      label: 'Customer',
      field: 'customer',
      valueGetter: (invoice) => invoice.customerName,
    ),
    WebDataColumn(
      label: 'Amount',
      field: 'amount',
      valueGetter: (invoice) => '₹${invoice.totalAmount}',
      cellBuilder: (invoice) => Text(
        '₹${invoice.totalAmount}',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
  ],
  onRowTap: (invoice) => _viewInvoice(invoice),
  selectable: true,
  onSelectionChanged: (selected) => _handleSelection(selected),
  searchHint: 'Search invoices...',
  rowsPerPage: 20,
)
```

### 2. WebCard

Enhanced card widget with hover effects, expandable content, and actions.

**Features:**
- Smooth hover animations
- Expandable/collapsible content
- Action buttons
- Status indicators
- Leading/trailing widgets
- Customizable styling

**Usage:**
```dart
import 'package:fineasy/web/widgets/web_components.dart';

WebCard(
  title: Text('Financial Overview'),
  subtitle: Text('Last updated: 2 hours ago'),
  leading: Icon(Icons.analytics, size: 40),
  statusIndicator: WebCardStatusIndicator(
    label: 'Active',
    color: Colors.green,
    icon: Icons.check_circle,
  ),
  content: Column(
    children: [
      Text('Total Revenue: ₹1,50,000'),
      Text('Pending: ₹25,000'),
    ],
  ),
  actions: [
    TextButton(
      onPressed: () => _viewDetails(),
      child: Text('View Details'),
    ),
    ElevatedButton(
      onPressed: () => _export(),
      child: Text('Export'),
    ),
  ],
  expandable: true,
  onTap: () => _handleCardTap(),
)
```

### 3. WebFormField

Enhanced form field with validation, character count, and helper text.

**Features:**
- Inline validation with error messages
- Character counter
- Helper text
- Password visibility toggle
- Custom input formatters
- Focus state management
- Built-in validators

**Usage:**
```dart
import 'package:fineasy/web/widgets/web_components.dart';

WebFormField(
  label: 'Email Address',
  hint: 'Enter your email',
  helperText: 'We\'ll never share your email',
  keyboardType: TextInputType.emailAddress,
  validator: WebFormValidators.combine([
    WebFormValidators.required,
    WebFormValidators.email,
  ]),
  onChanged: (value) => _handleEmailChange(value),
  prefixIcon: Icon(Icons.email),
)

// Password field
WebFormField(
  label: 'Password',
  obscureText: true,
  validator: WebFormValidators.combine([
    WebFormValidators.required,
    WebFormValidators.minLength(8),
  ]),
  maxLength: 20,
  showCharacterCount: true,
)
```

**Available Validators:**
- `WebFormValidators.required` - Field is required
- `WebFormValidators.email` - Valid email format
- `WebFormValidators.minLength(int)` - Minimum length
- `WebFormValidators.maxLength(int)` - Maximum length
- `WebFormValidators.numeric` - Numeric values only
- `WebFormValidators.min(double)` - Minimum numeric value
- `WebFormValidators.max(double)` - Maximum numeric value
- `WebFormValidators.combine(List)` - Combine multiple validators

### 4. WebDatePicker

Calendar-based date picker with quick select options.

**Features:**
- Calendar popup dialog
- Quick date shortcuts (Today, Yesterday, etc.)
- Date range constraints
- Custom date formatting
- Clear button
- Keyboard navigation support

**Usage:**
```dart
import 'package:fineasy/web/widgets/web_components.dart';
import 'package:intl/intl.dart';

WebDatePicker(
  label: 'Invoice Date',
  hint: 'Select date',
  initialDate: DateTime.now(),
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
  dateFormat: DateFormat('dd/MM/yyyy'),
  showQuickSelects: true,
  required: true,
  onChanged: (date) => _handleDateChange(date),
  validator: (date) {
    if (date == null) return 'Date is required';
    if (date.isAfter(DateTime.now())) {
      return 'Date cannot be in the future';
    }
    return null;
  },
)
```

### 5. WebDropdown

Advanced dropdown with search and multi-select capabilities.

**Features:**
- Searchable options
- Multi-select mode
- Custom option rendering
- Subtitle support
- Leading icons
- Disabled options
- Keyboard navigation

**Usage:**
```dart
import 'package:fineasy/web/widgets/web_components.dart';

// Single select
WebDropdown<String>(
  label: 'Payment Status',
  hint: 'Select status',
  options: [
    WebDropdownOption(
      value: 'paid',
      label: 'Paid',
      leading: Icon(Icons.check_circle, color: Colors.green),
    ),
    WebDropdownOption(
      value: 'pending',
      label: 'Pending',
      leading: Icon(Icons.pending, color: Colors.orange),
    ),
    WebDropdownOption(
      value: 'overdue',
      label: 'Overdue',
      leading: Icon(Icons.error, color: Colors.red),
    ),
  ],
  value: selectedStatus,
  onChanged: (value) => _handleStatusChange(value),
  searchable: true,
  required: true,
)

// Multi-select
WebDropdown<String>(
  label: 'Categories',
  hint: 'Select categories',
  options: categories.map((cat) => WebDropdownOption(
    value: cat.id,
    label: cat.name,
    subtitle: cat.description,
  )).toList(),
  values: selectedCategories,
  onMultiChanged: (values) => _handleCategoriesChange(values),
  multiSelect: true,
  searchable: true,
  searchHint: 'Search categories...',
)
```

## Integration with Existing App

These components are designed to work seamlessly with the existing FinEasy app:

1. **Import the components:**
```dart
import 'package:fineasy/web/widgets/web_components.dart';
```

2. **Use with responsive layouts:**
```dart
import 'package:fineasy/core/responsive/responsive_layout.dart';

ResponsiveLayout(
  mobile: MobileInvoiceList(),
  desktop: WebDataTable<Invoice>(...),
)
```

3. **Combine with platform detection:**
```dart
import 'package:flutter/foundation.dart' show kIsWeb;

if (kIsWeb) {
  return WebCard(...);
} else {
  return Card(...);
}
```

## Styling

All components respect the app's theme and can be customized:

```dart
WebCard(
  backgroundColor: theme.cardColor,
  elevation: 2.0,
  borderRadius: BorderRadius.circular(16),
  padding: EdgeInsets.all(24),
)
```

## Accessibility

All components include:
- Keyboard navigation support
- Screen reader compatibility
- Focus indicators
- ARIA-like semantics
- High contrast support

## Performance

Components are optimized for web:
- Efficient rendering with const constructors
- Lazy loading for large datasets
- Virtual scrolling in data tables
- Debounced search inputs
- Minimal rebuilds

## Browser Support

Tested and optimized for:
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## Examples

See `lib/web/widgets/example_usage.dart` for complete working examples.

## Requirements Validation

These components satisfy the following requirements from the web platform expansion spec:

- **Requirement 2.2**: Advanced desktop UI patterns (data tables, filters, pagination)
- **Requirement 2.3**: Interactive elements with visual feedback
- **Requirement 6.1**: Keyboard shortcuts and enhanced input methods
- **Requirement 6.2**: Enhanced form controls (date pickers, autocomplete)
