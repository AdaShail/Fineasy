import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../screens/search/search_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/notifications/notifications_screen.dart';
import '../../screens/auth/login_screen.dart';

/// Navigation item for top navigation bar
class TopNavItem {
  final String label;
  final String route;
  final IconData? icon;
  
  const TopNavItem({
    required this.label,
    required this.route,
    this.icon,
  });
}

/// Web-optimized app bar with search, profile, and notifications
/// Implements Requirements 3.1, 3.5, 3.6
class WebAppBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuPressed;
  final bool showMenuButton;
  final String currentRoute;
  final List<TopNavItem> primaryNavItems;
  
  const WebAppBar({
    super.key,
    this.onMenuPressed,
    this.showMenuButton = false,
    required this.currentRoute,
    this.primaryNavItems = const [
      TopNavItem(label: 'Dashboard', route: '/'),
      TopNavItem(label: 'Invoices', route: '/invoices'),
      TopNavItem(label: 'Customers', route: '/customers'),
      TopNavItem(label: 'Reports', route: '/reports'),
    ],
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  State<WebAppBar> createState() => _WebAppBarState();
}

class _WebAppBarState extends State<WebAppBar> {
  final FocusNode _searchFocusNode = FocusNode();
  int _focusedNavIndex = -1;

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleKeyboardNavigation(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;
    
    // Handle Tab navigation through nav items
    if (event.logicalKey == LogicalKeyboardKey.tab) {
      setState(() {
        if (event.isShiftPressed) {
          _focusedNavIndex = (_focusedNavIndex - 1) % widget.primaryNavItems.length;
        } else {
          _focusedNavIndex = (_focusedNavIndex + 1) % widget.primaryNavItems.length;
        }
      });
    }
    
    // Handle Enter to navigate
    if (event.logicalKey == LogicalKeyboardKey.enter && _focusedNavIndex >= 0) {
      final item = widget.primaryNavItems[_focusedNavIndex];
      Navigator.of(context).pushNamed(item.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: _handleKeyboardNavigation,
      child: AppBar(
        elevation: 1,
        toolbarHeight: 64,
        leading: widget.showMenuButton && widget.onMenuPressed != null
          ? IconButton(
              icon: const Icon(Icons.menu),
              onPressed: widget.onMenuPressed,
              tooltip: 'Open navigation menu',
            )
          : null,
        title: Row(
          children: [
            // Logo/Brand
            InkWell(
              onTap: () => Navigator.of(context).pushNamed('/'),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_balance,
                      size: 28,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'FinEasy',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Primary navigation links (desktop only)
            if (isDesktop) ...[
              const SizedBox(width: 32),
              ...widget.primaryNavItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isActive = widget.currentRoute == item.route ||
                    (item.route != '/' && widget.currentRoute.startsWith(item.route));
                final isFocused = _focusedNavIndex == index;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pushNamed(item.route),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isActive
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: isFocused
                              ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (item.icon != null) ...[
                              Icon(
                                item.icon,
                                size: 20,
                                color: isActive
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                                color: isActive
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
            
            const Spacer(),
            
            // Search bar (desktop/tablet only)
            if (screenWidth >= 768)
              Container(
                constraints: const BoxConstraints(maxWidth: 400),
                width: isDesktop ? 400 : 250,
                child: TextField(
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SearchScreen(),
                      ),
                    );
                  },
                  readOnly: true,
                ),
              ),
            
            const SizedBox(width: 16),
          ],
        ),
        actions: [
          // Search icon (mobile only)
          if (screenWidth < 768)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SearchScreen(),
                  ),
                );
              },
              tooltip: 'Open search',
            ),
          
          // Notifications
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                },
                tooltip: notificationProvider.unreadNotificationsCount > 0
                    ? '${notificationProvider.unreadNotificationsCount} unread notifications'
                    : 'Notifications',
              ),
              if (notificationProvider.unreadNotificationsCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      notificationProvider.unreadNotificationsCount > 9
                        ? '9+'
                        : '${notificationProvider.unreadNotificationsCount}',
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
          
          const SizedBox(width: 8),
          
          // Profile menu
          PopupMenuButton<String>(
            offset: const Offset(0, 56),
            tooltip: 'User menu',
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      authProvider.user != null && 
                      authProvider.user!.email.isNotEmpty
                        ? authProvider.user!.email.substring(0, 1).toUpperCase()
                        : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isDesktop && authProvider.user?.email != null)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (authProvider.user?.email ?? '').split('@').first,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
            onSelected: (value) async {
              switch (value) {
                case 'profile':
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ProfileScreen(),
                    ),
                  );
                  break;
                case 'settings':
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                  break;
                case 'logout':
                  await authProvider.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline),
                    SizedBox(width: 12),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
