# Web Design System Components

A comprehensive library of reusable UI components for the Fineasy web application. All components implement WCAG 2.1 AA accessibility standards with proper ARIA attributes, keyboard navigation, and screen reader support.

## Components

### WebButton

A versatile button component with multiple variants, sizes, and states.

**Features:**
- 5 variants: primary, secondary, outline, ghost, danger
- 3 sizes: sm, md, lg
- Loading and disabled states
- Icon support with left/right positioning
- Full keyboard accessibility
- Hover, focus, and pressed states

**Example:**
```dart
WebButton(
  variant: WebButtonVariant.primary,
  size: WebButtonSize.md,
  icon: Icon(Icons.save),
  onPressed: () => saveChanges(),
  child: Text('Save Changes'),
)
```

### WebInput

A comprehensive input component with validation and error states.

**Features:**
- Multiple input types (text, email, password, number, etc.)
- Label, placeholder, and helper text
- Inline error messages
- Character count for limited fields
- Icon support with left/right positioning
- Full keyboard navigation
- ARIA attributes for accessibility

**Example:**
```dart
WebInput(
  label: 'Email Address',
  type: TextInputType.emailAddress,
  value: email,
  onChanged: (value) => setState(() => email = value),
  error: emailError,
  required: true,
  icon: Icon(Icons.email),
)
```

### WebModal

A modal dialog with focus management and multiple close mechanisms.

**Features:**
- 5 size variants: sm, md, lg, xl, full
- Semi-transparent backdrop
- Focus trap functionality
- Multiple close mechanisms (X button, Cancel, Escape, backdrop click)
- Scroll prevention when open
- Entrance/exit animations
- Focus return to triggering element

**Example:**
```dart
WebModal(
  isOpen: showModal,
  onClose: () => setState(() => showModal = false),
  title: 'Confirm Action',
  size: WebModalSize.md,
  child: Text('Are you sure you want to proceed?'),
  footer: Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      WebButton(
        variant: WebButtonVariant.outline,
        onPressed: () => setState(() => showModal = false),
        child: Text('Cancel'),
      ),
      SizedBox(width: 8),
      WebButton(
        variant: WebButtonVariant.primary,
        onPressed: confirmAction,
        child: Text('Confirm'),
      ),
    ],
  ),
)
```

### WebTable

A data table with sorting, filtering, selection, and pagination.

**Features:**
- Sortable columns with visual indicators
- Row selection with checkboxes
- Pagination support
- Loading skeletons
- Empty state support
- Responsive behavior
- Hover states
- Custom cell rendering

**Example:**
```dart
WebTable<User>(
  columns: [
    WebTableColumn(
      key: 'name',
      header: 'Name',
      accessor: (user) => Text(user.name),
      sortable: true,
    ),
    WebTableColumn(
      key: 'email',
      header: 'Email',
      accessor: (user) => Text(user.email),
      sortable: true,
    ),
    WebTableColumn(
      key: 'status',
      header: 'Status',
      accessor: (user) => StatusBadge(user.status),
    ),
  ],
  data: users,
  loading: isLoading,
  selectable: true,
  onSort: (key, direction) => sortUsers(key, direction),
  onRowClick: (user) => viewUserDetails(user),
  pagination: WebTablePagination(
    currentPage: currentPage,
    totalPages: totalPages,
    pageSize: 20,
    onPageChange: (page) => loadPage(page),
  ),
)
```

### WebToast

A toast notification system with auto-dismiss and manual dismiss options.

**Features:**
- 4 types: success, error, warning, info
- Auto-dismiss for success/info (4-6 seconds)
- Manual dismiss for errors
- Action button support
- Toast queue management
- Entrance/exit animations
- ARIA live regions for screen readers

**Example:**
```dart
// Using the toast service
final toastService = WebToastService();

// Show success toast
toastService.showSuccess(
  message: 'Changes saved successfully',
  description: 'Your invoice has been updated',
);

// Show error toast (persists until dismissed)
toastService.showError(
  message: 'Failed to save changes',
  description: 'Please check your connection and try again',
  action: WebToastAction(
    label: 'Retry',
    onClick: () => retryOperation(),
  ),
);

// Show warning toast
toastService.showWarning(
  message: 'Unsaved changes',
  description: 'You have unsaved changes that will be lost',
);

// Show info toast
toastService.showInfo(
  message: 'New feature available',
  description: 'Check out our new reporting dashboard',
);
```

**Setup:**
Wrap your app with `WebToastContainer`:

```dart
MaterialApp(
  home: WebToastContainer(
    toastService: toastService,
    child: YourApp(),
  ),
)
```

## Accessibility

All components follow WCAG 2.1 AA standards:

- **Keyboard Navigation**: All interactive elements are keyboard accessible
- **Focus Management**: Visible focus indicators and proper focus order
- **ARIA Attributes**: Proper labels, roles, and properties
- **Screen Reader Support**: Semantic HTML and ARIA live regions
- **Color Contrast**: Minimum 4.5:1 for normal text, 3:1 for large text
- **Touch Targets**: Minimum 44x44px on mobile devices

## Design Tokens

All components use design tokens from the token system:

- Colors (primary, secondary, semantic, neutral, surface)
- Typography (font families, sizes, weights, line heights)
- Spacing (consistent scale from 4px to 96px)
- Shadows (elevation levels 0-5)
- Border radius (sm, base, md, lg, xl, full)
- Animations (duration and easing functions)

## Browser Support

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## Testing

All components include:
- Unit tests for rendering and interactions
- Property-based tests for universal properties
- Accessibility tests with axe-core
- Visual regression tests

## Contributing

When adding new components:

1. Follow the existing component structure
2. Implement full accessibility support
3. Use design tokens for all styling
4. Add comprehensive documentation
5. Write unit and property tests
6. Test with keyboard and screen readers
