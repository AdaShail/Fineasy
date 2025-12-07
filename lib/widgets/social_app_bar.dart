import 'package:flutter/material.dart';

class SocialAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showSearch;
  final bool showGroups;
  final VoidCallback? onSearchTap;
  final VoidCallback? onGroupsTap;

  const SocialAppBar({
    Key? key,
    required this.title,
    this.showSearch = true,
    this.showGroups = true,
    this.onSearchTap,
    this.onGroupsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      elevation: 0,
      actions: [
        // Search icon
        if (showSearch)
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search Users & Groups',
            onPressed: onSearchTap ?? () => _navigateToSearch(context),
          ),

        // Groups icon in upper right
        if (showGroups)
          IconButton(
            icon: const Icon(Icons.group),
            tooltip: 'Groups',
            onPressed: onGroupsTap ?? () => _navigateToGroups(context),
          ),

        const SizedBox(width: 8),
      ],
    );
  }

  void _navigateToSearch(BuildContext context) {
    Navigator.pushNamed(context, '/search');
  }

  void _navigateToGroups(BuildContext context) {
    Navigator.pushNamed(context, '/groups');
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
