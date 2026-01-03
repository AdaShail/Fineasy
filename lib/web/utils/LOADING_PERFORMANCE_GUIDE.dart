/// Loading States and Performance Optimization Guide
/// 
/// This file demonstrates how to use the loading indicators,
/// lazy loading, optimistic updates, caching, and code splitting
/// features for optimal web performance.

library;

import 'package:flutter/material.dart';
import '../design_system/components/web_loading_indicators.dart';
import 'lazy_loading_service.dart';
import 'optimistic_update_service.dart';
import 'api_cache_service.dart';
import 'code_splitting_service.dart';

/// Example 1: Using Loading Indicators
class LoadingIndicatorsExample extends StatefulWidget {
  const LoadingIndicatorsExample({super.key});

  @override
  State<LoadingIndicatorsExample> createState() => _LoadingIndicatorsExampleState();
}

class _LoadingIndicatorsExampleState extends State<LoadingIndicatorsExample> {
  bool _isLoading = false;
  double _progress = 0.0;

  Future<void> _simulateLoading() async {
    setState(() => _isLoading = true);
    
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() => _progress = i / 100);
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loading Indicators')),
      body: WebLoadingOverlay(
        isLoading: _isLoading,
        message: 'Processing...',
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Spinner variants
              const Text('Spinners:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  WebSpinner(size: SpinnerSize.small),
                  WebSpinner(size: SpinnerSize.medium),
                  WebSpinner(size: SpinnerSize.large),
                  WebSpinner(size: SpinnerSize.xlarge),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Progress bar
              const Text('Progress Bar:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              WebProgressBar(
                value: _progress,
                showPercentage: true,
              ),
              
              const SizedBox(height: 24),
              
              // Skeleton screens
              const Text('Skeleton Screens:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const SkeletonCard(height: 120),
              
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _simulateLoading,
                child: const Text('Simulate Loading'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Example 2: Lazy Loading Images and Components
class LazyLoadingExample extends StatelessWidget {
  const LazyLoadingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lazy Loading')),
      body: ListView.builder(
        itemCount: 50,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Lazy load image
                  LazyLoadImage(
                    imageUrl: 'https://picsum.photos/200/200?random=$index',
                    width: 100,
                    height: 100,
                    placeholder: Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Lazy load content
                  Expanded(
                    child: LazyLoadWidget(
                      builder: (context) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Item $index',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Description for item $index'),
                          ],
                        );
                      },
                      placeholder: const SkeletonText(height: 60),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Example 3: Optimistic Updates
class OptimisticUpdatesExample extends StatefulWidget {
  const OptimisticUpdatesExample({super.key});

  @override
  State<OptimisticUpdatesExample> createState() => _OptimisticUpdatesExampleState();
}

class _OptimisticUpdatesExampleState extends State<OptimisticUpdatesExample> {
  final _list = OptimisticList<String>(['Item 1', 'Item 2', 'Item 3']);

  @override
  void initState() {
    super.initState();
    _list.addListener((items) {
      setState(() {}); // Rebuild on changes
    });
  }

  Future<String> _simulateApiCall(String item) async {
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate 30% failure rate
    if (DateTime.now().millisecond % 10 < 3) {
      throw Exception('API call failed');
    }
    
    return item;
  }

  void _addItem() {
    final newItem = 'Item ${_list.items.length + 1}';
    
    _list.add(
      item: newItem,
      operation: () => _simulateApiCall(newItem),
      onSuccess: (item) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added: $item')),
        );
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add item. Changes reverted.'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  void _removeItem(String item) {
    _list.remove(
      item: item,
      operation: () => _simulateApiCall(item).then((_) {}),
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Removed: $item')),
        );
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to remove item. Changes reverted.'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Optimistic Updates')),
      body: ListView.builder(
        itemCount: _list.items.length,
        itemBuilder: (context, index) {
          final item = _list.items[index];
          return ListTile(
            title: Text(item),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _removeItem(item),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addItem,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _list.dispose();
    super.dispose();
  }
}

/// Example 4: API Caching
class ApiCachingExample extends StatefulWidget {
  const ApiCachingExample({super.key});

  @override
  State<ApiCachingExample> createState() => _ApiCachingExampleState();
}

class _ApiCachingExampleState extends State<ApiCachingExample> {
  final _cache = ApiCacheService();
  Map<String, dynamic>? _data;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // Register endpoints
    _cache.registerEndpoints(ApiEndpoints.all);
    
    // Load data
    _loadData();
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    setState(() => _isLoading = true);

    try {
      final data = await _cache.getOrFetch(
        endpoint: '/api/dashboard',
        queryParams: null,
        fetcher: _fetchDashboardData,
        forceRefresh: forceRefresh,
      );

      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }

  Future<Map<String, dynamic>> _fetchDashboardData() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    return {
      'revenue': 125000,
      'expenses': 75000,
      'profit': 50000,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Caching'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadData(forceRefresh: true),
          ),
        ],
      ),
      body: _isLoading
          ? const FullScreenLoader(message: 'Loading data...')
          : _data == null
              ? const Center(child: Text('No data'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildMetricCard('Revenue', '\$${_data!['revenue']}'),
                      const SizedBox(height: 16),
                      _buildMetricCard('Expenses', '\$${_data!['expenses']}'),
                      const SizedBox(height: 16),
                      _buildMetricCard('Profit', '\$${_data!['profit']}'),
                      const SizedBox(height: 16),
                      Text(
                        'Last updated: ${_data!['timestamp']}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildMetricCard(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

/// Example 5: Code Splitting
class CodeSplittingExample extends StatelessWidget {
  const CodeSplittingExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Code Splitting')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildRouteCard(
            context,
            'Reports (Lazy Loaded)',
            '/reports',
            Icons.bar_chart,
          ),
          const SizedBox(height: 16),
          _buildRouteCard(
            context,
            'Analytics (Lazy Loaded)',
            '/analytics',
            Icons.analytics,
          ),
          const SizedBox(height: 16),
          _buildRouteCard(
            context,
            'Settings (Lazy Loaded)',
            '/settings',
            Icons.settings,
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(
    BuildContext context,
    String title,
    String route,
    IconData icon,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Text('Route: $route'),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          // Navigate to lazy-loaded route
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeferredRoute(
                routeName: title,
                loader: () => _loadRoute(route),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<Widget> _loadRoute(String route) async {
    // Simulate loading deferred module
    await Future.delayed(const Duration(seconds: 1));
    
    return Scaffold(
      appBar: AppBar(title: Text('Loaded: $route')),
      body: Center(
        child: Text('This route was lazy loaded!'),
      ),
    );
  }
}

/// Main example app
class LoadingPerformanceExamplesApp extends StatelessWidget {
  const LoadingPerformanceExamplesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loading & Performance Examples',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ExamplesHome(),
    );
  }
}

class ExamplesHome extends StatelessWidget {
  const ExamplesHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loading & Performance Examples')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildExampleCard(
            context,
            'Loading Indicators',
            'Spinners, progress bars, and skeleton screens',
            Icons.hourglass_empty,
            const LoadingIndicatorsExample(),
          ),
          const SizedBox(height: 16),
          _buildExampleCard(
            context,
            'Lazy Loading',
            'Lazy load images and components',
            Icons.image,
            const LazyLoadingExample(),
          ),
          const SizedBox(height: 16),
          _buildExampleCard(
            context,
            'Optimistic Updates',
            'Instant UI updates with automatic rollback',
            Icons.flash_on,
            const OptimisticUpdatesExample(),
          ),
          const SizedBox(height: 16),
          _buildExampleCard(
            context,
            'API Caching',
            'Smart caching with automatic invalidation',
            Icons.storage,
            const ApiCachingExample(),
          ),
          const SizedBox(height: 16),
          _buildExampleCard(
            context,
            'Code Splitting',
            'Route-based code splitting and lazy loading',
            Icons.splitscreen,
            const CodeSplittingExample(),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Widget destination,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
      ),
    );
  }
}
