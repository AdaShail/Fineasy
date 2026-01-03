import 'package:flutter/material.dart';

/// Enhanced card widget with hover effects and actions for web
class WebCard extends StatefulWidget {
  final Widget? title;
  final Widget? subtitle;
  final Widget? content;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool expandable;
  final bool initiallyExpanded;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final bool showHoverEffect;
  final Widget? statusIndicator;

  const WebCard({
    super.key,
    this.title,
    this.subtitle,
    this.content,
    this.actions,
    this.leading,
    this.trailing,
    this.onTap,
    this.expandable = false,
    this.initiallyExpanded = false,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.showHoverEffect = true,
    this.statusIndicator,
  });

  @override
  State<WebCard> createState() => _WebCardState();
}

class _WebCardState extends State<WebCard> {
  bool _isHovered = false;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultElevation = widget.elevation ?? 1.0;
    final hoverElevation = widget.showHoverEffect ? defaultElevation + 4.0 : defaultElevation;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: widget.margin ?? const EdgeInsets.all(8.0),
        child: Material(
          elevation: _isHovered ? hoverElevation : defaultElevation,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
          color: widget.backgroundColor ?? theme.cardColor,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
            child: Container(
              padding: widget.padding ?? const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  if (widget.title != null || widget.leading != null || widget.trailing != null)
                    Row(
                      children: [
                        if (widget.leading != null) ...[
                          widget.leading!,
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.title != null)
                                DefaultTextStyle(
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ) ?? const TextStyle(),
                                  child: widget.title!,
                                ),
                              if (widget.subtitle != null) ...[
                                const SizedBox(height: 4),
                                DefaultTextStyle(
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                                  ) ?? const TextStyle(),
                                  child: widget.subtitle!,
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (widget.statusIndicator != null) ...[
                          const SizedBox(width: 12),
                          widget.statusIndicator!,
                        ],
                        if (widget.trailing != null) ...[
                          const SizedBox(width: 12),
                          widget.trailing!,
                        ],
                        if (widget.expandable)
                          Semantics(
                            label: _isExpanded ? 'Collapse card' : 'Expand card',
                            button: true,
                            child: IconButton(
                              icon: AnimatedRotation(
                                turns: _isExpanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: const Icon(Icons.expand_more),
                              ),
                              tooltip: _isExpanded ? 'Collapse' : 'Expand',
                              onPressed: () => setState(() => _isExpanded = !_isExpanded),
                            ),
                          ),
                      ],
                    ),

                  // Content
                  if (widget.content != null && (!widget.expandable || _isExpanded)) ...[
                    if (widget.title != null || widget.leading != null)
                      const SizedBox(height: 16),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      child: widget.content!,
                    ),
                  ],

                  // Actions
                  if (widget.actions != null && widget.actions!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        for (int i = 0; i < widget.actions!.length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          widget.actions![i],
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Status indicator widget for WebCard
class WebCardStatusIndicator extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const WebCardStatusIndicator({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Status: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
