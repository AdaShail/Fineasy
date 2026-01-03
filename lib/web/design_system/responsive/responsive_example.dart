import 'package:flutter/material.dart';
import 'responsive.dart';

/// Example demonstrating the responsive system
class ResponsiveSystemExample extends StatelessWidget {
  const ResponsiveSystemExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewportProvider(
      child: MaterialApp(
        title: 'Responsive System Example',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const ResponsiveExampleScreen(),
      ),
    );
  }
}

class ResponsiveExampleScreen extends StatelessWidget {
  const ResponsiveExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive System Demo'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBreakpointInfo(context),
            const SizedBox(height: 24),
            _buildFluidTypographyExample(context),
            const SizedBox(height: 24),
            _buildResponsiveGridExample(context),
            const SizedBox(height: 24),
            _buildResponsiveVisibilityExample(context),
            const SizedBox(height: 24),
            _buildResponsiveContainerExample(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakpointInfo(BuildContext context) {
    final viewport = ViewportProvider.of(context);
    
    return ResponsiveSection(
      backgroundColor: Colors.blue[50],
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Breakpoint Information',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _infoRow('Breakpoint', viewport.currentBreakpoint.name),
          _infoRow('Width', '${viewport.width.toStringAsFixed(0)}px'),
          _infoRow('Height', '${viewport.height.toStringAsFixed(0)}px'),
          _infoRow('Columns', '${viewport.columns}'),
          _infoRow('Container Max Width', '${viewport.containerMaxWidth}px'),
          _infoRow('Container Padding', '${viewport.containerPadding}px'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _statusChip('Mobile', context.isMobile),
              _statusChip('Tablet', context.isTablet),
              _statusChip('Desktop', context.isDesktop),
              _statusChip('Wide', context.isWide),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 180,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _statusChip(String label, bool isActive) {
    return Chip(
      label: Text(label),
      backgroundColor: isActive ? Colors.green[100] : Colors.grey[200],
      avatar: Icon(
        isActive ? Icons.check_circle : Icons.circle_outlined,
        size: 16,
        color: isActive ? Colors.green : Colors.grey,
      ),
    );
  }

  Widget _buildFluidTypographyExample(BuildContext context) {
    return ResponsiveContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fluid Typography',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          FluidText.h1('Heading 1 - Scales 32-60px'),
          const SizedBox(height: 8),
          FluidText.h2('Heading 2 - Scales 28-48px'),
          const SizedBox(height: 8),
          FluidText.h3('Heading 3 - Scales 24-36px'),
          const SizedBox(height: 8),
          FluidText.body(
            'Body text scales from 14px on mobile to 16px on wide screens. '
            'This ensures optimal readability across all device sizes.',
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveGridExample(BuildContext context) {
    return ResponsiveSection(
      backgroundColor: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Responsive Grid (12 columns)',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ResponsiveGrid(
            spacing: 16,
            runSpacing: 16,
            children: [
              ResponsiveGridItem(
                mobileSpan: 12,
                tabletSpan: 6,
                desktopSpan: 4,
                wideSpan: 3,
                child: _gridCard('Card 1', Colors.blue),
              ),
              ResponsiveGridItem(
                mobileSpan: 12,
                tabletSpan: 6,
                desktopSpan: 4,
                wideSpan: 3,
                child: _gridCard('Card 2', Colors.green),
              ),
              ResponsiveGridItem(
                mobileSpan: 12,
                tabletSpan: 6,
                desktopSpan: 4,
                wideSpan: 3,
                child: _gridCard('Card 3', Colors.orange),
              ),
              ResponsiveGridItem(
                mobileSpan: 12,
                tabletSpan: 6,
                desktopSpan: 12,
                wideSpan: 3,
                child: _gridCard('Card 4', Colors.purple),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Grid adapts: 1 col (mobile) → 2 cols (tablet) → 3 cols (desktop) → 4 cols (wide)',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _gridCard(String title, Color color) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveVisibilityExample(BuildContext context) {
    return ResponsiveContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Responsive Visibility',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ResponsiveVisibility(
            visibleOnMobile: true,
            visibleOnTablet: false,
            visibleOnDesktop: false,
            visibleOnWide: false,
            child: _visibilityCard('Mobile Only', Colors.blue),
          ),
          ResponsiveVisibility(
            visibleOnMobile: false,
            visibleOnTablet: true,
            visibleOnDesktop: false,
            visibleOnWide: false,
            child: _visibilityCard('Tablet Only', Colors.green),
          ),
          ResponsiveVisibility(
            visibleOnMobile: false,
            visibleOnTablet: false,
            visibleOnDesktop: true,
            visibleOnWide: true,
            child: _visibilityCard('Desktop & Wide', Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _visibilityCard(String title, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.visibility, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveContainerExample(BuildContext context) {
    return ResponsiveSection(
      backgroundColor: Colors.amber[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Responsive Container',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.amber),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'This content is inside a ResponsiveContainer.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Max width: ${context.viewport.containerMaxWidth}px',
                ),
                Text(
                  'Padding: ${context.viewport.containerPadding}px',
                ),
                const SizedBox(height: 8),
                const Text(
                  'The container automatically adjusts its max-width and padding '
                  'based on the current breakpoint to maintain optimal content width.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Example of using responsive values
class ResponsiveValueExample extends StatelessWidget {
  const ResponsiveValueExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Get different values based on breakpoint
    final columns = context.responsiveValue(
      mobile: 1,
      tablet: 2,
      desktop: 3,
      wide: 4,
    );

    final fontSize = context.responsiveValue(
      mobile: 14.0,
      tablet: 16.0,
      desktop: 18.0,
      wide: 20.0,
    );

    return Column(
      children: [
        Text(
          'Responsive Values',
          style: TextStyle(fontSize: fontSize),
        ),
        Text('Columns: $columns'),
      ],
    );
  }
}

/// Example of using ResponsiveBuilder
class ResponsiveBuilderExample extends StatelessWidget {
  const ResponsiveBuilderExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, breakpoint) {
        switch (breakpoint.name) {
          case 'mobile':
            return const MobileLayout();
          case 'tablet':
            return const TabletLayout();
          case 'desktop':
          case 'wide':
            return const DesktopLayout();
          default:
            return const MobileLayout();
        }
      },
    );
  }
}

class MobileLayout extends StatelessWidget {
  const MobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Mobile Layout'));
  }
}

class TabletLayout extends StatelessWidget {
  const TabletLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Tablet Layout'));
  }
}

class DesktopLayout extends StatelessWidget {
  const DesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Desktop Layout'));
  }
}
