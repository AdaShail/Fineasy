import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'web_sidebar.dart';

/// Mobile navigation drawer with swipe-to-close gesture
/// Implements Requirements 3.3, 3.6
class WebMobileDrawer extends StatefulWidget {
  final String currentRoute;
  final Function(String) onNavigate;
  final VoidCallback onClose;
  
  const WebMobileDrawer({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
    required this.onClose,
  });

  @override
  State<WebMobileDrawer> createState() => _WebMobileDrawerState();
}

class _WebMobileDrawerState extends State<WebMobileDrawer> {
  final FocusNode _drawerFocusNode = FocusNode();
  double _dragOffset = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    // Request focus when drawer opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _drawerFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _drawerFocusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      // Close drawer on Escape key
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        widget.onClose();
      }
    }
  }

  void _handleDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _dragOffset = 0.0;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      // Only allow dragging to the left (closing direction)
      _dragOffset = (_dragOffset + details.primaryDelta!).clamp(-280.0, 0.0);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
    });
    
    // If dragged more than 50% or with sufficient velocity, close the drawer
    if (_dragOffset < -140 || details.primaryVelocity! < -500) {
      widget.onClose();
    } else {
      // Snap back to open position
      setState(() {
        _dragOffset = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: _drawerFocusNode,
      onKey: _handleKeyEvent,
      child: Stack(
        children: [
          // Backdrop overlay
          GestureDetector(
            onTap: widget.onClose,
            child: AnimatedOpacity(
              opacity: _isDragging ? (1.0 + _dragOffset / 280).clamp(0.0, 1.0) : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                color: Colors.black54,
              ),
            ),
          ),
          
          // Drawer content
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onHorizontalDragStart: _handleDragStart,
              onHorizontalDragUpdate: _handleDragUpdate,
              onHorizontalDragEnd: _handleDragEnd,
              child: AnimatedContainer(
                duration: _isDragging ? Duration.zero : const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                transform: Matrix4.translationValues(_dragOffset, 0, 0),
                child: Material(
                  elevation: 16,
                  child: Container(
                    width: 280,
                    height: double.infinity,
                    color: Theme.of(context).colorScheme.surface,
                    child: Column(
                      children: [
                        // Drawer header with close button
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Theme.of(context).dividerColor,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.account_balance,
                                size: 32,
                                color: Theme.of(context).colorScheme.primary,
                              ),
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
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: widget.onClose,
                                tooltip: 'Close navigation menu',
                              ),
                            ],
                          ),
                        ),
                        
                        // Navigation items using WebSidebar
                        Expanded(
                          child: WebSidebar(
                            currentRoute: widget.currentRoute,
                            onNavigate: (route) {
                              widget.onNavigate(route);
                              widget.onClose();
                            },
                          ),
                        ),
                        
                        // Swipe indicator
                        Container(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.swipe_left,
                                size: 16,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Swipe left to close',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Hamburger menu button for mobile
class HamburgerMenuButton extends StatelessWidget {
  final VoidCallback onPressed;
  
  const HamburgerMenuButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.menu),
      onPressed: onPressed,
      tooltip: 'Open navigation menu',
    );
  }
}
