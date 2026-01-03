import 'package:flutter/widgets.dart';
import 'responsive_config.dart';

/// 12-column responsive grid system
class ResponsiveGrid extends StatelessWidget {
  final List<ResponsiveGridItem> children;
  final double spacing;
  final double runSpacing;
  final CrossAxisAlignment crossAxisAlignment;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final breakpoint = ResponsiveConfig.getBreakpoint(constraints.maxWidth);
        final availableWidth = constraints.maxWidth;
        
        // Calculate column width (12 columns)
        final totalSpacing = spacing * 11; // 11 gaps between 12 columns
        final columnWidth = (availableWidth - totalSpacing) / 12;

        // Group items into rows
        final rows = <List<ResponsiveGridItem>>[];
        var currentRow = <ResponsiveGridItem>[];
        var currentRowSpan = 0;

        for (final child in children) {
          final span = child.getSpan(breakpoint.name);
          
          if (currentRowSpan + span > 12) {
            // Start new row
            if (currentRow.isNotEmpty) {
              rows.add(currentRow);
            }
            currentRow = [child];
            currentRowSpan = span;
          } else {
            currentRow.add(child);
            currentRowSpan += span;
          }
        }
        
        if (currentRow.isNotEmpty) {
          rows.add(currentRow);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows.map((row) {
            return Padding(
              padding: EdgeInsets.only(bottom: runSpacing),
              child: Row(
                crossAxisAlignment: crossAxisAlignment,
                children: _buildRowChildren(row, columnWidth, spacing, breakpoint.name),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  List<Widget> _buildRowChildren(
    List<ResponsiveGridItem> items,
    double columnWidth,
    double spacing,
    String breakpointName,
  ) {
    final widgets = <Widget>[];
    
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final span = item.getSpan(breakpointName);
      final width = (columnWidth * span) + (spacing * (span - 1));
      
      widgets.add(
        SizedBox(
          width: width,
          child: item.child,
        ),
      );
      
      // Add spacing between items (but not after last item)
      if (i < items.length - 1) {
        widgets.add(SizedBox(width: spacing));
      }
    }
    
    return widgets;
  }
}

/// Grid item with responsive column spans
class ResponsiveGridItem {
  final Widget child;
  final int mobileSpan;
  final int? tabletSpan;
  final int? desktopSpan;
  final int? wideSpan;

  const ResponsiveGridItem({
    required this.child,
    this.mobileSpan = 12,
    this.tabletSpan,
    this.desktopSpan,
    this.wideSpan,
  }) : assert(mobileSpan >= 1 && mobileSpan <= 12);

  int getSpan(String breakpointName) {
    switch (breakpointName) {
      case 'wide':
        return wideSpan ?? desktopSpan ?? tabletSpan ?? mobileSpan;
      case 'desktop':
        return desktopSpan ?? tabletSpan ?? mobileSpan;
      case 'tablet':
        return tabletSpan ?? mobileSpan;
      case 'mobile':
      default:
        return mobileSpan;
    }
  }
}

/// Simple responsive grid with automatic column count
class ResponsiveAutoGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final int? wideColumns;
  final double? childAspectRatio;

  const ResponsiveAutoGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.wideColumns,
    this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final breakpoint = ResponsiveConfig.getBreakpoint(constraints.maxWidth);
        
        int columns;
        switch (breakpoint.name) {
          case 'wide':
            columns = wideColumns ?? 4;
            break;
          case 'desktop':
            columns = desktopColumns ?? 3;
            break;
          case 'tablet':
            columns = tabletColumns ?? 2;
            break;
          case 'mobile':
          default:
            columns = mobileColumns ?? 1;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: childAspectRatio ?? 1.0,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

/// Responsive wrap layout
class ResponsiveWrap extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final WrapAlignment alignment;
  final WrapCrossAlignment crossAxisAlignment;

  const ResponsiveWrap({
    super.key,
    required this.children,
    this.spacing = 8,
    this.runSpacing = 8,
    this.alignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final breakpoint = ResponsiveConfig.getBreakpoint(constraints.maxWidth);
        
        // Adjust spacing based on breakpoint
        double actualSpacing = spacing;
        double actualRunSpacing = runSpacing;
        
        if (breakpoint.name == 'mobile') {
          actualSpacing = spacing * 0.75;
          actualRunSpacing = runSpacing * 0.75;
        } else if (breakpoint.name == 'wide') {
          actualSpacing = spacing * 1.25;
          actualRunSpacing = runSpacing * 1.25;
        }

        return Wrap(
          spacing: actualSpacing,
          runSpacing: actualRunSpacing,
          alignment: alignment,
          crossAxisAlignment: crossAxisAlignment,
          children: children,
        );
      },
    );
  }
}
