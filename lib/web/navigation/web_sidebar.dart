import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Navigation item model
class NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;
  final List<NavItem>? children;
  final int? badge;
  
  const NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
    this.children,
    this.badge,
  });
}

/// Web sidebar navigation for desktop and tablet drawer
/// Implements Requirements 3.2, 3.5, 3.6
class WebSidebar extends StatefulWidget {
  final String currentRoute;
  final Function(String) onNavigate;
  final bool collapsed;
  final VoidCallback? onToggleCollapse;
  
  const WebSidebar({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
    this.collapsed = false,
    this.onToggleCollapse,
  });

  @override
  State<WebSidebar> createState() => _WebSidebarState();
}

class _WebSidebarState extends State<WebSidebar> with SingleTickerProviderStateMixin {
  late AnimationController _collapseController;
  late Animation<double> _collapseAnimation;
  final Map<String, bool> _expandedItems = {};
  int _focusedIndex = -1;
  final FocusNode _sidebarFocusNode = FocusNode();

  static final List<NavItem> _navItems = [
    NavItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      route: '/',
    ),
    NavItem(
      label: 'Invoices',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      route: '/invoices',
      children: [
        NavItem(
          label: 'All Invoices',
          icon: Icons.list_outlined,
          activeIcon: Icons.list,
          route: '/invoices',
        ),
        NavItem(
          label: 'Create Invoice',
          icon: Icons.add_outlined,
          activeIcon: Icons.add,
          route: '/invoices/create',
        ),
      ],
    ),
    NavItem(
      label: 'Customers',
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      route: '/customers',
    ),
    NavItem(
      label: 'Suppliers',
      icon: Icons.business_outlined,
      activeIcon: Icons.business,
      route: '/suppliers',
    ),
    NavItem(
      label: 'Transactions',
      icon: Icons.swap_horiz_outlined,
      activeIcon: Icons.swap_horiz,
      route: '/transactions',
    ),
    NavItem(
      label: 'Payments',
      icon: Icons.payment_outlined,
      activeIcon: Icons.payment,
      route: '/payments',
    ),
    NavItem(
      label: 'Receivables',
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet,
      route: '/receivables',
    ),
    NavItem(
      label: 'Recurring Payments',
      icon: Icons.repeat_outlined,
      activeIcon: Icons.repeat,
      route: '/recurring-payments',
    ),
    NavItem(
      label: 'Reports',
      icon: Icons.assessment_outlined,
      activeIcon: Icons.assessment,
      route: '/reports',
    ),
    NavItem(
      label: 'AI Autopilot',
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome,
      route: '/autopilot',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _collapseController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _collapseAnimation = Tween<double>(begin: 280, end: 72).animate(
      CurvedAnimation(
        parent: _collapseController,
        curve: Curves.easeInOut,
      ),
    );
    
    if (widget.collapsed) {
      _collapseController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(WebSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.collapsed != oldWidget.collapsed) {
      if (widget.collapsed) {
        _collapseController.forward();
      } else {
        _collapseController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _collapseController.dispose();
    _sidebarFocusNode.dispose();
    super.dispose();
  }

  void _handleKeyboardNavigation(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;
    
    final flatItems = _getFlatItemsList();
    
    // Arrow Down - move to next item
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _focusedIndex = (_focusedIndex + 1) % flatItems.length;
      });
    }
    
    // Arrow Up - move to previous item
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _focusedIndex = (_focusedIndex - 1 + flatItems.length) % flatItems.length;
      });
    }
    
    // Enter - navigate to focused item
    if (event.logicalKey == LogicalKeyboardKey.enter && _focusedIndex >= 0) {
      final item = flatItems[_focusedIndex];
      if (item.children != null && item.children!.isNotEmpty) {
        _toggleExpanded(item.route);
      } else {
        widget.onNavigate(item.route);
      }
    }
    
    // Arrow Right - expand if has children
    if (event.logicalKey == LogicalKeyboardKey.arrowRight && _focusedIndex >= 0) {
      final item = flatItems[_focusedIndex];
      if (item.children != null && item.children!.isNotEmpty) {
        setState(() {
          _expandedItems[item.route] = true;
        });
      }
    }
    
    // Arrow Left - collapse if expanded
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft && _focusedIndex >= 0) {
      final item = flatItems[_focusedIndex];
      if (_expandedItems[item.route] == true) {
        setState(() {
          _expandedItems[item.route] = false;
        });
      }
    }
  }

  List<NavItem> _getFlatItemsList() {
    final List<NavItem> flatList = [];
    for (final item in _navItems) {
      flatList.add(item);
      if (_expandedItems[item.route] == true && item.children != null) {
        flatList.addAll(item.children!);
      }
    }
    return flatList;
  }

  void _toggleExpanded(String route) {
    setState(() {
      _expandedItems[route] = !(_expandedItems[route] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _sidebarFocusNode,
      onKey: _handleKeyboardNavigation,
      child: AnimatedBuilder(
        animation: _collapseAnimation,
        builder: (context, child) {
          final isCollapsed = _collapseAnimation.value < 150;
          
          return Container(
            width: _collapseAnimation.value,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // Sidebar header
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      if (!isCollapsed) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'FinEasy',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                      if (widget.onToggleCollapse != null)
                        IconButton(
                          icon: Icon(
                            isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                            size: 20,
                          ),
                          onPressed: widget.onToggleCollapse,
                          tooltip: isCollapsed ? 'Expand sidebar' : 'Collapse sidebar',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                ),
                
                const Divider(height: 1),
                
                // Navigation items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: _navItems.asMap().entries.map((entry) {
                      return _buildNavItem(
                        context,
                        entry.value,
                        isCollapsed,
                        entry.key,
                      );
                    }).toList(),
                  ),
                ),
                
                const Divider(height: 1),
                
                // Footer actions
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildNavItem(
                        context,
                        const NavItem(
                          label: 'Settings',
                          icon: Icons.settings_outlined,
                          activeIcon: Icons.settings,
                          route: '/settings',
                        ),
                        isCollapsed,
                        -1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    NavItem item,
    bool isCollapsed,
    int index,
  ) {
    final isActive = widget.currentRoute == item.route ||
        (item.route != '/' && widget.currentRoute.startsWith(item.route));
    final isExpanded = _expandedItems[item.route] ?? false;
    final hasChildren = item.children != null && item.children!.isNotEmpty;
    final isFocused = _focusedIndex == index;
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: Tooltip(
            message: isCollapsed ? item.label : '',
            child: Material(
              color: isActive
                ? Theme.of(context).colorScheme.primaryContainer
                : isFocused
                    ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5)
                    : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () {
                  if (hasChildren) {
                    _toggleExpanded(item.route);
                  } else {
                    widget.onNavigate(item.route);
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        isActive ? item.activeIcon : item.icon,
                        color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                        size: 24,
                        semanticLabel: item.label,
                      ),
                      if (!isCollapsed) ...[
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                              color: isActive
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (item.badge != null && item.badge! > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item.badge! > 99 ? '99+' : '${item.badge}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (hasChildren)
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              size: 20,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Child items
        if (hasChildren && isExpanded && !isCollapsed)
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Column(
              children: item.children!.map((child) {
                return Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: _buildNavItem(context, child, false, -1),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
