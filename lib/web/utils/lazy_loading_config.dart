/// Lazy loading configuration for web performance optimization
/// 
/// Implements code splitting and deferred loading for heavy features
/// to reduce initial bundle size and improve load times.

library;

import 'package:flutter/material.dart';

/// Lazy loading wrapper for heavy screens
class LazyLoadScreen extends StatefulWidget {
  final Future<Widget> Function() loader;
  final Widget? placeholder;
  final Widget? errorWidget;

  const LazyLoadScreen({
    super.key,
    required this.loader,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<LazyLoadScreen> createState() => _LazyLoadScreenState();
}

class _LazyLoadScreenState extends State<LazyLoadScreen> {
  late Future<Widget> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = widget.loader();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return widget.errorWidget ??
              Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Failed to load: ${snapshot.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _loadFuture = widget.loader();
                          });
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
        }

        if (snapshot.hasData) {
          return snapshot.data!;
        }

        return widget.placeholder ??
            const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
      },
    );
  }
}

/// Preload manager for critical resources
class PreloadManager {
  static final PreloadManager _instance = PreloadManager._internal();
  factory PreloadManager() => _instance;
  PreloadManager._internal();

  final Map<String, Future<dynamic>> _preloadedResources = {};
  final Set<String> _loadedRoutes = {};

  /// Preload a resource
  Future<T> preload<T>(String key, Future<T> Function() loader) async {
    if (_preloadedResources.containsKey(key)) {
      return _preloadedResources[key] as Future<T>;
    }

    final future = loader();
    _preloadedResources[key] = future;
    return future;
  }

  /// Get preloaded resource
  Future<T>? getPreloaded<T>(String key) {
    return _preloadedResources[key] as Future<T>?;
  }

  /// Mark route as loaded
  void markRouteLoaded(String route) {
    _loadedRoutes.add(route);
  }

  /// Check if route is loaded
  bool isRouteLoaded(String route) {
    return _loadedRoutes.contains(route);
  }

  /// Clear preloaded resources
  void clear() {
    _preloadedResources.clear();
    _loadedRoutes.clear();
  }

  /// Clear specific resource
  void clearResource(String key) {
    _preloadedResources.remove(key);
  }
}

/// Deferred widget loader with caching
class DeferredWidgetLoader<T extends Widget> {
  final Future<T> Function() _loader;
  Future<T>? _cachedFuture;

  DeferredWidgetLoader(this._loader);

  Future<T> load() {
    _cachedFuture ??= _loader();
    return _cachedFuture!;
  }

  void clear() {
    _cachedFuture = null;
  }
}

/// Route-based code splitting configuration
class RouteSplitConfig {
  /// Routes that should be loaded immediately
  static const Set<String> criticalRoutes = {
    '/',
    '/login',
    '/dashboard',
  };

  /// Routes that can be lazy loaded
  static const Set<String> deferredRoutes = {
    '/reports',
    '/analytics',
    '/settings',
    '/autopilot',
    '/invoices',
    '/customers',
    '/suppliers',
    '/transactions',
    '/payments',
    '/receivables',
    '/recurring-payments',
  };

  /// Check if route should be lazy loaded
  static bool shouldLazyLoad(String route) {
    return deferredRoutes.contains(route) && !criticalRoutes.contains(route);
  }
}

/// Lazy image loader with progressive loading
class LazyImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enableMemoryCache;

  const LazyImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
    this.enableMemoryCache = true,
  });

  @override
  State<LazyImage> createState() => _LazyImageState();
}

class _LazyImageState extends State<LazyImage> {
  @override
  Widget build(BuildContext context) {
    return Image.network(
      widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        
        return widget.placeholder ??
            SizedBox(
              width: widget.width,
              height: widget.height,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) {
        return widget.errorWidget ??
            SizedBox(
              width: widget.width,
              height: widget.height,
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.grey),
              ),
            );
      },
    );
  }
}
