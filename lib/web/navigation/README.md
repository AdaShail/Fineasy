# Web Navigation Patterns

This directory contains the complete navigation system for the FinEasy web application, implementing Requirements 3.1-3.7 from the Web UX Specifications.

## Overview

The navigation system provides a responsive, accessible, and intuitive navigation experience across all device sizes:

- **Desktop (1024px+)**: Persistent sidebar with collapsible option + top navigation bar
- **Tablet (768px-1023px)**: Collapsible drawer + top navigation bar
- **Mobile (<768px)**: Bottom navigation bar + hamburger menu drawer

## Components

### 1. WebAppBar (`web_app_bar.dart`)

**Implements**: Requirements 3.1, 3.5, 3.6

The top navigation bar provides:
- Logo/brand with home link
- Primary navigation links (desktop only)
- Global search
- Notifications with badge
- User profile menu
- Responsive behavior (hide/show elements based on screen size)
- Full keyboard navigation support (Tab, Enter)
- Active item highlighting

**Usage**:
```dart
WebAppBar(
  currentRoute: '/invoices',
  onMenuPressed: () => openDrawer(),
  showMenuButton: true,
  primaryNavItems: [
    TopNavItem(label: 'Dashboard', route: '/'),
    TopNavItem(label: 'Invoices', route: '/invoices'),
    TopNavItem(label: 'Customers', route: '/customers'),
    TopNavItem(label: 'Reports', route: '/reports'),
  ],
)
```

### 2. WebSidebar (`web_sidebar.dart`)

**Implements**: Requirements 3.2, 3.5, 3.6

The sidebar navigation provides:
- Collapsible sidebar with animation
- Hierarchical menu structure support
- Expand/collapse animations for nested items
- Keyboard navigation (Arrow keys, Enter)
- Active item highlighting
- Badge support for notifications
- Tooltip support when collapsed

**Usage**:
```dart
WebSidebar(
  currentRoute: '/invoices',
  onNavigate: (route) => Navigator.pushNamed(context, route),
  collapsed: false,
  onToggleCollapse: () => setState(() => collapsed = !collapsed),
)
```

### 3. WebMobileDrawer (`web_mobile_drawer.dart`)

**Implements**: Requirements 3.3, 3.6

The mobile drawer provides:
- Hamburger menu button
- Slide-out drawer navigation
- Backdrop overlay
- Swipe-to-close gesture
- Keyboard support (Escape to close)
- Smooth animations

**Usage**:
```dart
WebMobileDrawer(
  currentRoute: '/invoices',
  onNavigate: (route) => Navigator.pushNamed(context, route),
  onClose: () => setState(() => drawerOpen = false),
)
```

### 4. WebBreadcrumb (`web_breadcrumb.dart`)

**Implements**: Requirement 3.4

The breadcrumb navigation provides:
- Hierarchical path display
- Click navigation to parent levels
- Responsive truncation for long paths
- Icon support for items
- Automatic generation from routes

**Usage**:
```dart
WebBreadcrumb(
  items: generateBreadcrumbsFromRoute('/invoices/123/edit'),
  onNavigate: (route) => Navigator.pushNamed(context, route),
  maxVisibleItems: 4,
)
```

**Helper Function**:
```dart
final breadcrumbs = generateBreadcrumbsFromRoute('/invoices/123/edit');
// Returns: [Dashboard, Invoices, 123, Edit]
```

### 5. WebBottomNav (`web_bottom_nav.dart`)

**Implements**: Requirement 3.7

The bottom navigation bar provides:
- Bottom tab bar for mobile
- Primary action items (Dashboard, Invoices, Transactions, More)
- Active tab highlighting
- Badge support for notifications
- Smooth transitions

**Usage**:
```dart
WebBottomNav(
  currentRoute: '/invoices',
  onNavigate: (route) => Navigator.pushNamed(context, route),
  items: [
    BottomNavItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      route: '/',
      badge: 3, // Optional notification badge
    ),
    // ... more items
  ],
)
```

### 6. WebNavigationShell (`web_navigation_shell.dart`)

The navigation shell orchestrates all navigation components and provides:
- Automatic responsive layout switching
- Sidebar collapse state management
- Drawer open/close state management
- Breadcrumb integration
- Consistent navigation across the app

**Usage**:
```dart
WebNavigationShell(
  currentRoute: '/invoices',
  showBreadcrumbs: true,
  child: YourPageContent(),
)
```

## Features

### Keyboard Navigation

All navigation components support full keyboard accessibility:

- **Tab**: Navigate between items
- **Shift+Tab**: Navigate backwards
- **Enter**: Activate focused item
- **Escape**: Close drawer/modal
- **Arrow Keys**: Navigate in sidebar (Up/Down, Left/Right for expand/collapse)

### Responsive Behavior

The navigation system automatically adapts to screen size:

| Screen Size | Navigation Type | Features |
|-------------|----------------|----------|
| Desktop (1024px+) | Persistent Sidebar + Top Bar | Full navigation, collapsible sidebar, breadcrumbs |
| Tablet (768-1023px) | Drawer + Top Bar | Hamburger menu, breadcrumbs |
| Mobile (<768px) | Bottom Nav + Drawer | Bottom tabs, hamburger menu, no breadcrumbs |

### Active Item Highlighting

Navigation items are automatically highlighted based on the current route:
- Primary color for active items
- Bold font weight for active items
- Bottom border indicator (top nav)
- Background color (sidebar)

### Badge Support

Display notification counts on navigation items:
```dart
NavItem(
  label: 'Invoices',
  icon: Icons.receipt_long_outlined,
  activeIcon: Icons.receipt_long,
  route: '/invoices',
  badge: 5, // Shows "5" badge
)
```

### Hierarchical Navigation

The sidebar supports nested navigation items:
```dart
NavItem(
  label: 'Invoices',
  icon: Icons.receipt_long_outlined,
  activeIcon: Icons.receipt_long,
  route: '/invoices',
  children: [
    NavItem(label: 'All Invoices', route: '/invoices'),
    NavItem(label: 'Create Invoice', route: '/invoices/create'),
  ],
)
```

## Accessibility

All navigation components follow WCAG 2.1 AA guidelines:

- ✅ Keyboard navigation support
- ✅ Focus indicators
- ✅ ARIA labels and roles
- ✅ Screen reader support
- ✅ Sufficient color contrast
- ✅ Touch target sizes (44x44px minimum on mobile)

## Customization

### Styling

Navigation components use the app's theme for consistent styling:
- `Theme.of(context).colorScheme.primary` - Active items
- `Theme.of(context).colorScheme.surface` - Backgrounds
- `Theme.of(context).colorScheme.onSurface` - Text/icons

### Navigation Items

Customize navigation items by modifying the `_navItems` list in `WebSidebar`:

```dart
static final List<NavItem> _navItems = [
  NavItem(
    label: 'Your Feature',
    icon: Icons.your_icon_outlined,
    activeIcon: Icons.your_icon,
    route: '/your-route',
  ),
];
```

### Breadcrumb Formatting

Customize breadcrumb label formatting by modifying `_formatSegmentLabel` in `web_breadcrumb.dart`.

## Testing

The navigation system has been tested for:
- ✅ Responsive behavior across all breakpoints
- ✅ Keyboard navigation
- ✅ Touch gestures (swipe-to-close)
- ✅ Active item highlighting
- ✅ Badge display
- ✅ Hierarchical navigation
- ✅ Breadcrumb generation

## Performance

The navigation system is optimized for performance:
- Lazy loading of drawer content
- Efficient state management
- Smooth animations (300ms duration)
- Minimal re-renders

## Browser Support

Tested and working on:
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## Future Enhancements

Potential improvements for future iterations:
- [ ] Persistent navigation state across sessions
- [ ] Customizable navigation item order
- [ ] Search within navigation
- [ ] Recent/favorite items
- [ ] Navigation analytics
- [ ] Gesture customization

## Related Documentation

- [Web UX Specifications](../../../.kiro/specs/web-ux-specifications/requirements.md)
- [Design System Tokens](../design_system/tokens/README.md)
- [Responsive Breakpoints](../../core/responsive/README.md)
