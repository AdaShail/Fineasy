import 'package:flutter/material.dart';

/// Breadcrumb item model
class BreadcrumbItem {
  final String label;
  final String? route;
  final IconData? icon;
  
  const BreadcrumbItem({
    required this.label,
    this.route,
    this.icon,
  });
}

/// Breadcrumb navigation component
/// Implements Requirement 3.4
class WebBreadcrumb extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final Function(String)? onNavigate;
  final int maxVisibleItems;
  
  const WebBreadcrumb({
    super.key,
    required this.items,
    this.onNavigate,
    this.maxVisibleItems = 4,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    // Responsive truncation for long paths
    final visibleItems = _getVisibleItems(isMobile);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _buildBreadcrumbItems(context, visibleItems),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<BreadcrumbItem> _getVisibleItems(bool isMobile) {
    if (items.length <= maxVisibleItems) {
      return items;
    }
    
    // On mobile, show only first and last items with ellipsis
    if (isMobile && items.length > 2) {
      return [
        items.first,
        const BreadcrumbItem(label: '...'),
        items.last,
      ];
    }
    
    // On desktop, show first, ellipsis, and last few items
    final visibleCount = maxVisibleItems - 2; // Reserve space for first and ellipsis
    return [
      items.first,
      const BreadcrumbItem(label: '...'),
      ...items.sublist(items.length - visibleCount),
    ];
  }

  List<Widget> _buildBreadcrumbItems(
    BuildContext context,
    List<BreadcrumbItem> visibleItems,
  ) {
    final List<Widget> widgets = [];
    
    for (int i = 0; i < visibleItems.length; i++) {
      final item = visibleItems[i];
      final isLast = i == visibleItems.length - 1;
      final isEllipsis = item.label == '...';
      
      // Add breadcrumb item
      widgets.add(_buildBreadcrumbItem(context, item, isLast, isEllipsis));
      
      // Add separator (except for last item)
      if (!isLast) {
        widgets.add(_buildSeparator(context));
      }
    }
    
    return widgets;
  }

  Widget _buildBreadcrumbItem(
    BuildContext context,
    BreadcrumbItem item,
    bool isLast,
    bool isEllipsis,
  ) {
    final textStyle = TextStyle(
      fontSize: 14,
      fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
      color: isLast
          ? Theme.of(context).colorScheme.onSurface
          : Theme.of(context).colorScheme.primary,
    );
    
    // Ellipsis item (not clickable)
    if (isEllipsis) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          item.label,
          style: textStyle.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      );
    }
    
    // Last item (current page, not clickable)
    if (isLast || item.route == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.icon != null) ...[
              Icon(
                item.icon,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                item.label,
                style: textStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                semanticsLabel: 'Current page: ${item.label}',
              ),
            ),
          ],
        ),
      );
    }
    
    // Clickable breadcrumb item
    return InkWell(
      onTap: () {
        if (onNavigate != null && item.route != null) {
          onNavigate!(item.route!);
        }
      },
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.icon != null) ...[
              Icon(
                item.icon,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                item.label,
                style: textStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                semanticsLabel: 'Navigate to ${item.label}',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeparator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Icon(
        Icons.chevron_right,
        size: 16,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
      ),
    );
  }
}

/// Helper function to generate breadcrumbs from route
List<BreadcrumbItem> generateBreadcrumbsFromRoute(String route) {
  if (route == '/' || route.isEmpty) {
    return [
      const BreadcrumbItem(
        label: 'Dashboard',
        route: '/',
        icon: Icons.home,
      ),
    ];
  }
  
  final segments = route.split('/').where((s) => s.isNotEmpty).toList();
  final breadcrumbs = <BreadcrumbItem>[
    const BreadcrumbItem(
      label: 'Dashboard',
      route: '/',
      icon: Icons.home,
    ),
  ];
  
  String currentPath = '';
  for (int i = 0; i < segments.length; i++) {
    currentPath += '/${segments[i]}';
    final isLast = i == segments.length - 1;
    
    breadcrumbs.add(
      BreadcrumbItem(
        label: _formatSegmentLabel(segments[i]),
        route: isLast ? null : currentPath,
      ),
    );
  }
  
  return breadcrumbs;
}

String _formatSegmentLabel(String segment) {
  // Convert kebab-case or snake_case to Title Case
  return segment
      .replaceAll('-', ' ')
      .replaceAll('_', ' ')
      .split(' ')
      .map((word) => word.isEmpty
          ? ''
          : word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join(' ');
}
