import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../core/responsive/responsive_breakpoints.dart';
import 'web_app_bar.dart';
import 'web_sidebar.dart';
import 'web_bottom_nav.dart';
import 'web_mobile_drawer.dart';
import 'web_breadcrumb.dart';

/// Web navigation shell that provides responsive navigation
/// - Desktop: Persistent sidebar with collapsible option
/// - Tablet: Collapsible drawer
/// - Mobile Web: Bottom navigation bar with drawer
class WebNavigationShell extends StatefulWidget {
  final Widget child;
  final String currentRoute;
  final bool showBreadcrumbs;
  
  const WebNavigationShell({
    super.key,
    required this.child,
    required this.currentRoute,
    this.showBreadcrumbs = true,
  });

  @override
  State<WebNavigationShell> createState() => _WebNavigationShellState();
}

class _WebNavigationShellState extends State<WebNavigationShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _sidebarCollapsed = false;
  bool _drawerOpen = false;
  
  @override
  Widget build(BuildContext context) {
    // Only use web navigation on web platform
    if (!kIsWeb) {
      return widget.child;
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = ResponsiveBreakpoints.isDesktop(width);
        final isTablet = ResponsiveBreakpoints.isTablet(width);
        final isMobile = ResponsiveBreakpoints.isMobile(width);
        
        return Scaffold(
          key: _scaffoldKey,
          appBar: WebAppBar(
            currentRoute: widget.currentRoute,
            onMenuPressed: (isTablet || isMobile) 
              ? () {
                  setState(() {
                    _drawerOpen = true;
                  });
                }
              : null,
            showMenuButton: isTablet || isMobile,
          ),
          body: Stack(
            children: [
              Row(
                children: [
                  // Persistent sidebar for desktop
                  if (isDesktop)
                    WebSidebar(
                      currentRoute: widget.currentRoute,
                      onNavigate: (route) {
                        Navigator.of(context).pushNamed(route);
                      },
                      collapsed: _sidebarCollapsed,
                      onToggleCollapse: () {
                        setState(() {
                          _sidebarCollapsed = !_sidebarCollapsed;
                        });
                      },
                    ),
                  
                  // Main content area
                  Expanded(
                    child: Column(
                      children: [
                        // Breadcrumb navigation
                        if (widget.showBreadcrumbs && !isMobile)
                          WebBreadcrumb(
                            items: generateBreadcrumbsFromRoute(widget.currentRoute),
                            onNavigate: (route) {
                              Navigator.of(context).pushNamed(route);
                            },
                          ),
                        
                        // Page content
                        Expanded(
                          child: widget.child,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Mobile drawer overlay
              if (_drawerOpen && (isTablet || isMobile))
                WebMobileDrawer(
                  currentRoute: widget.currentRoute,
                  onNavigate: (route) {
                    Navigator.of(context).pushNamed(route);
                  },
                  onClose: () {
                    setState(() {
                      _drawerOpen = false;
                    });
                  },
                ),
            ],
          ),
          bottomNavigationBar: isMobile
            ? WebBottomNav(
                currentRoute: widget.currentRoute,
                onNavigate: (route) {
                  Navigator.of(context).pushNamed(route);
                },
              )
            : null,
        );
      },
    );
  }
}
