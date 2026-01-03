import 'package:flutter/material.dart';

/// Position of the side panel
enum SidePanelPosition {
  left,
  right,
}

/// Side panel widget for desktop-optimized detail views
class SidePanel extends StatefulWidget {
  final Widget child;
  final double width;
  final SidePanelPosition position;
  final bool isOpen;
  final VoidCallback? onClose;
  final String? title;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool showCloseButton;
  final bool resizable;
  final double minWidth;
  final double maxWidth;

  const SidePanel({
    super.key,
    required this.child,
    this.width = 400,
    this.position = SidePanelPosition.right,
    this.isOpen = true,
    this.onClose,
    this.title,
    this.actions,
    this.backgroundColor,
    this.showCloseButton = true,
    this.resizable = false,
    this.minWidth = 300,
    this.maxWidth = 800,
  });

  @override
  State<SidePanel> createState() => _SidePanelState();
}

class _SidePanelState extends State<SidePanel> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double _currentWidth;

  @override
  void initState() {
    super.initState();
    _currentWidth = widget.width;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (widget.isOpen) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(SidePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen != oldWidget.isOpen) {
      if (widget.isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: _currentWidth * _animation.value,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: widget.position == SidePanelPosition.right
                    ? const Offset(-2, 0)
                    : const Offset(2, 0),
              ),
            ],
          ),
          child: _animation.value > 0.5 ? child : null,
        );
      },
      child: Row(
        children: [
          // Resize handle
          if (widget.resizable && widget.position == SidePanelPosition.right)
            _buildResizeHandle(),

          // Panel content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                if (widget.title != null || widget.showCloseButton)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant,
                      border: Border(
                        bottom: BorderSide(color: theme.dividerColor),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (widget.title != null)
                          Expanded(
                            child: Text(
                              widget.title!,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (widget.actions != null) ...widget.actions!,
                        if (widget.showCloseButton && widget.onClose != null)
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: widget.onClose,
                            tooltip: 'Close panel',
                          ),
                      ],
                    ),
                  ),

                // Content
                Expanded(
                  child: widget.child,
                ),
              ],
            ),
          ),

          // Resize handle
          if (widget.resizable && widget.position == SidePanelPosition.left)
            _buildResizeHandle(),
        ],
      ),
    );
  }

  Widget _buildResizeHandle() {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            if (widget.position == SidePanelPosition.right) {
              _currentWidth = (_currentWidth - details.delta.dx)
                  .clamp(widget.minWidth, widget.maxWidth);
            } else {
              _currentWidth = (_currentWidth + details.delta.dx)
                  .clamp(widget.minWidth, widget.maxWidth);
            }
          });
        },
        child: Container(
          width: 8,
          color: Colors.transparent,
          child: Center(
            child: Container(
              width: 2,
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// Layout with main content and optional side panel
class SidePanelLayout extends StatelessWidget {
  final Widget mainContent;
  final Widget? sidePanel;
  final bool showSidePanel;
  final SidePanelPosition sidePanelPosition;
  final double sidePanelWidth;
  final VoidCallback? onCloseSidePanel;

  const SidePanelLayout({
    super.key,
    required this.mainContent,
    this.sidePanel,
    this.showSidePanel = false,
    this.sidePanelPosition = SidePanelPosition.right,
    this.sidePanelWidth = 400,
    this.onCloseSidePanel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left side panel
        if (showSidePanel &&
            sidePanel != null &&
            sidePanelPosition == SidePanelPosition.left)
          SidePanel(
            width: sidePanelWidth,
            position: SidePanelPosition.left,
            isOpen: showSidePanel,
            onClose: onCloseSidePanel,
            child: sidePanel!,
          ),

        // Main content
        Expanded(child: mainContent),

        // Right side panel
        if (showSidePanel &&
            sidePanel != null &&
            sidePanelPosition == SidePanelPosition.right)
          SidePanel(
            width: sidePanelWidth,
            position: SidePanelPosition.right,
            isOpen: showSidePanel,
            onClose: onCloseSidePanel,
            child: sidePanel!,
          ),
      ],
    );
  }
}

/// Split view with resizable divider
class SplitView extends StatefulWidget {
  final Widget left;
  final Widget right;
  final double initialLeftWidth;
  final double minLeftWidth;
  final double minRightWidth;
  final Axis direction;

  const SplitView({
    super.key,
    required this.left,
    required this.right,
    this.initialLeftWidth = 300,
    this.minLeftWidth = 200,
    this.minRightWidth = 200,
    this.direction = Axis.horizontal,
  });

  @override
  State<SplitView> createState() => _SplitViewState();
}

class _SplitViewState extends State<SplitView> {
  late double _leftWidth;

  @override
  void initState() {
    super.initState();
    _leftWidth = widget.initialLeftWidth;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.direction == Axis.horizontal) {
      return Row(
        children: [
          SizedBox(
            width: _leftWidth,
            child: widget.left,
          ),
          _buildDivider(),
          Expanded(child: widget.right),
        ],
      );
    } else {
      return Column(
        children: [
          SizedBox(
            height: _leftWidth,
            child: widget.left,
          ),
          _buildDivider(),
          Expanded(child: widget.right),
        ],
      );
    }
  }

  Widget _buildDivider() {
    final isHorizontal = widget.direction == Axis.horizontal;
    
    return MouseRegion(
      cursor: isHorizontal
          ? SystemMouseCursors.resizeColumn
          : SystemMouseCursors.resizeRow,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            final delta = isHorizontal ? details.delta.dx : details.delta.dy;
            final maxWidth = (isHorizontal
                    ? MediaQuery.of(context).size.width
                    : MediaQuery.of(context).size.height) -
                widget.minRightWidth;
            
            _leftWidth = (_leftWidth + delta)
                .clamp(widget.minLeftWidth, maxWidth);
          });
        },
        child: Container(
          width: isHorizontal ? 8 : null,
          height: isHorizontal ? null : 8,
          color: Colors.transparent,
          child: Center(
            child: Container(
              width: isHorizontal ? 2 : null,
              height: isHorizontal ? null : 2,
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
      ),
    );
  }
}
