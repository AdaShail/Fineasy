import 'package:flutter/material.dart';
import 'responsive.dart';

/// Example screen demonstrating responsive layout usage
/// 
/// This is a reference implementation showing how to use the responsive
/// infrastructure. This file can be removed in production.
class ExampleResponsiveScreen extends StatelessWidget {
  const ExampleResponsiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive Example'),
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(context),
        tablet: _buildTabletLayout(context),
        desktop: _buildDesktopLayout(context),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.phone_android, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Mobile Layout',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Screen width: ${MediaQuery.of(context).size.width.toStringAsFixed(0)}px',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Platform: ${PlatformDetector.isWeb ? "Web" : "Mobile"}',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.tablet_android, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Tablet Layout',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Screen width: ${MediaQuery.of(context).size.width.toStringAsFixed(0)}px',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Platform: ${PlatformDetector.isWeb ? "Web" : "Mobile"}',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Sidebar
        Container(
          width: 250,
          color: Colors.grey[200],
          child: const Center(
            child: Text('Sidebar'),
          ),
        ),
        // Main content
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.desktop_windows, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Desktop Layout',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Screen width: ${MediaQuery.of(context).size.width.toStringAsFixed(0)}px',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Platform: ${PlatformDetector.isWeb ? "Web" : "Mobile"}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Example widget demonstrating ResponsiveBuilder usage
class ExampleResponsiveBuilder extends StatelessWidget {
  const ExampleResponsiveBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, constraints) {
        // Determine number of columns based on screen size
        final columns = constraints.isDesktop
            ? 4
            : constraints.isTablet
                ? 2
                : 1;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            return Card(
              child: Center(
                child: Text('Item ${index + 1}'),
              ),
            );
          },
        );
      },
    );
  }
}
