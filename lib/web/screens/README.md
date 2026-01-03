# Web Dashboard Implementation

## Overview

The web dashboard provides a responsive, multi-column layout optimized for desktop, tablet, and mobile web browsers. It automatically adapts based on screen size and provides enhanced features for larger screens.

## Features

### Responsive Layouts

- **Mobile Web (< 768px)**: Single-column layout with bottom navigation
- **Tablet (768-1023px)**: 2-column layout with collapsible sidebar
- **Desktop (>= 1024px)**: 3-column layout with persistent sidebar
- **Large Desktop (>= 1440px)**: 4-column layout with additional widgets

### Dashboard Components

#### Financial Overview Cards
- Total Balance
- Total Income
- Total Expenses
- Receivables

#### Interactive Charts
- Income vs Expenses Bar Chart (with hover tooltips)
- Cash Flow Line Chart (last 7 days)
- Real-time data updates

#### Quick Actions Panel
- Add Transaction
- Create Invoice
- Record Payment
- Add Customer

#### Pending Actions
- Overdue Invoices
- Pending Invoices
- Real-time status updates

#### Additional Widgets (Desktop)
- Top Customers by Revenue
- Invoice Status Breakdown
- Upcoming Payments (Due This Week)
- Business Insights (Averages & Metrics)

### Real-time Updates

All dashboard widgets automatically update when:
- New transactions are added
- Invoices are created or updated
- Payments are recorded
- Data is synced from other devices

### Pull-to-Refresh

All layouts support pull-to-refresh for manual data synchronization.

## Usage

### Automatic Platform Detection

The dashboard automatically detects the platform and renders the appropriate version:

```dart
// In MainNavigationScreen
if (kIsWeb) {
  return const WebDashboardScreen();
}
return const DashboardScreen(); // Mobile app
```

### Navigation Integration

The web dashboard integrates with the web navigation shell:

```dart
WebNavigationShell(
  currentRoute: '/dashboard',
  child: WebDashboardScreen(),
)
```

### Accessing from Routes

```dart
Navigator.pushNamed(context, '/');
// or
Navigator.pushNamed(context, '/dashboard');
```

## Architecture

### File Structure

```
lib/web/screens/
├── web_dashboard_screen.dart    # Main dashboard screen
└── README.md                     # This file

lib/web/widgets/
└── web_dashboard_widgets.dart    # All dashboard widgets
```

### Widget Hierarchy

```
WebDashboardScreen
├── ResponsiveLayout
│   ├── Mobile Layout (SingleChildScrollView)
│   ├── Tablet Layout (2-column Row)
│   └── Desktop Layout (3-4 column Row)
└── Dashboard Widgets
    ├── WebBusinessHeader
    ├── WebFinancialOverviewCards
    ├── WebQuickActionsPanel
    ├── WebFinancialChart
    ├── WebCashFlowChart
    ├── WebRecentTransactions
    ├── WebPendingActionsPanel
    ├── WebTopCustomersWidget
    ├── WebInvoiceStatusWidget
    ├── WebUpcomingPaymentsWidget
    └── WebBusinessInsightsWidget
```

## Customization

### Adding New Widgets

1. Create widget in `web_dashboard_widgets.dart`:

```dart
class MyNewWidget extends StatelessWidget {
  const MyNewWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: // Your widget content
      ),
    );
  }
}
```

2. Add to appropriate layout in `web_dashboard_screen.dart`:

```dart
// For desktop layout
Column(
  children: [
    const MyNewWidget(),
    const SizedBox(height: 24),
    // Other widgets...
  ],
)
```

### Modifying Layouts

Edit the layout methods in `WebDashboardScreen`:
- `_buildMobileDashboard()` - Mobile web layout
- `_buildTabletDashboard()` - Tablet layout
- `_buildDesktopDashboard()` - Desktop layout

### Styling

All widgets use consistent styling from:
- `AppTheme` - Color scheme and theme
- `AppConstants` - Currency and formatting
- Material Design 3 components

## Performance

### Optimizations

- Lazy loading of chart data
- Efficient list rendering with `ListView.builder`
- Conditional widget rendering based on screen size
- Real-time updates only for visible data
- Cached calculations for metrics

### Best Practices

- Use `const` constructors where possible
- Minimize rebuilds with `Consumer` widgets
- Implement proper `shouldRebuild` logic
- Use `ListView.separated` for better performance

## Testing

### Manual Testing Checklist

- [ ] Dashboard loads on all screen sizes
- [ ] Financial cards display correct data
- [ ] Charts render properly
- [ ] Quick actions navigate correctly
- [ ] Pull-to-refresh works
- [ ] Real-time updates reflect changes
- [ ] Responsive breakpoints work correctly
- [ ] All widgets are accessible

### Browser Compatibility

Tested on:
- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)

## Future Enhancements

- [ ] Drag-and-drop widget arrangement
- [ ] Customizable dashboard layouts
- [ ] Widget visibility preferences
- [ ] Export dashboard as PDF
- [ ] Scheduled data refresh
- [ ] Advanced filtering options
- [ ] Custom date ranges for charts
- [ ] More chart types (pie, donut, area)

## Related Documentation

- [Responsive Layout System](../../core/responsive/README.md)
- [Web Navigation](../navigation/README.md)
- [Platform Services](../../core/platform/README.md)
- [Web Widgets](../widgets/README.md)
