import 'package:flutter/material.dart';

/// Bottom navigation item model
class BottomNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
  final int? badge;
  
  const BottomNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
    this.badge,
  });
}

/// Bottom navigation bar for mobile web
/// Implements Requirement 3.7
class WebBottomNav extends StatelessWidget {
  final String currentRoute;
  final Function(String) onNavigate;
  final List<BottomNavItem> items;
  
  const WebBottomNav({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
    List<BottomNavItem>? items,
  }) : items = items ?? _defaultItems;

  static const List<BottomNavItem> _defaultItems = [
    BottomNavItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      route: '/',
    ),
    BottomNavItem(
      label: 'Invoices',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      route: '/invoices',
    ),
    BottomNavItem(
      label: 'Transactions',
      icon: Icons.swap_horiz_outlined,
      activeIcon: Icons.swap_horiz,
      route: '/transactions',
    ),
    BottomNavItem(
      label: 'More',
      icon: Icons.more_horiz,
      activeIcon: Icons.more_horiz,
      route: '/more',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildNavItem(context, item, index);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, BottomNavItem item, int index) {
    final isActive = _isRouteActive(item.route);
    
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onNavigate(item.route),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      isActive ? item.activeIcon : item.icon,
                      size: 24,
                      color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      semanticLabel: item.label,
                    ),
                    
                    // Badge indicator
                    if (item.badge != null && item.badge! > 0)
                      Positioned(
                        right: -8,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            item.badge! > 9 ? '9+' : '${item.badge}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                // Active indicator
                if (isActive)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    height: 2,
                    width: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isRouteActive(String route) {
    if (route == '/') {
      return currentRoute == '/' || currentRoute.isEmpty;
    }
    return currentRoute.startsWith(route);
  }
}
