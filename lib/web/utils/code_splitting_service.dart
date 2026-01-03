/// Code splitting service for web platform
/// 
/// Implements route-based code splitting and dynamic imports
/// to reduce initial bundle size and improve load times.
/// 
/// Requirements: 8.10, 20.6

library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Deferred loading status
enum DeferredLoadStatus {
  notLoaded,
  loading,
  loaded,
  error,
}

/// Deferred module loader
class DeferredModuleLoader<T> {
  final String moduleName;
  final Future<T> Function() loader;
  
  DeferredLoadStatus _status = DeferredLoadStatus.notLoaded;
  T? _loadedModule;
  Object? _error;
  Future<T>? _loadingFuture;

  DeferredModuleLoader({
    required this.moduleName,
    required this.loader,
  });

  /// Get current status
  DeferredLoadStatus get status => _status;

  /// Get loaded module
  T? get module => _loadedModule;

  /// Get error if any
  Object? get error => _error;

  /// Load module
  Future<T> load() async {
    // Return cached module if already loaded
    if (_status == DeferredLoadStatus.loaded && _loadedModule != null) {
      return _loadedModule!;
    }

    // Return existing loading future if already loading
    if (_status == DeferredLoadStatus.loading && _loadingFuture != null) {
      return _loadingFuture!;
    }

    // Start loading
    _status = DeferredLoadStatus.loading;
    _loadingFuture = _loadModule();

    return _loadingFuture!;
  }

  Future<T> _loadModule() async {
    try {
      final module = await loader();
      
      _loadedModule = module;
      _status = DeferredLoadStatus.loaded;
      _error = null;
      
      return module;
    } catch (error) {
      _status = DeferredLoadStatus.error;
      _error = error;
      _loadingFuture = null;
      
      rethrow;
    }
  }

  /// Preload module
  Future<void> preload() async {
    if (_status == DeferredLoadStatus.notLoaded) {
      try {
        await load();
      } catch (e) {
        // Ignore preload errors
      }
    }
  }

  /// Unload module (clear cache)
  void unload() {
    _loadedModule = null;
    _status = DeferredLoadStatus.notLoaded;
    _loadingFuture = null;
    _error = null;
  }
}

/// Code splitting manager
class CodeSplittingManager {
  static final CodeSplittingManager _instance = CodeSplittingManager._internal();
  factory CodeSplittingManager() => _instance;
  CodeSplittingManager._internal();

  final Map<String, DeferredModuleLoader> _modules = {};
  final Set<String> _criticalModules = {};
  final Set<String> _preloadedModules = {};

  /// Register a deferred module
  void registerModule<T>(
    String moduleName,
    Future<T> Function() loader, {
    bool isCritical = false,
  }) {
    _modules[moduleName] = DeferredModuleLoader<T>(
      moduleName: moduleName,
      loader: loader,
    );

    if (isCritical) {
      _criticalModules.add(moduleName);
    }
  }

  /// Load a module
  Future<T> loadModule<T>(String moduleName) async {
    final loader = _modules[moduleName];
    if (loader == null) {
      throw ArgumentError('Module not registered: $moduleName');
    }

    return await loader.load() as T;
  }

  /// Preload a module
  Future<void> preloadModule(String moduleName) async {
    if (_preloadedModules.contains(moduleName)) {
      return; // Already preloaded
    }

    final loader = _modules[moduleName];
    if (loader == null) {
      return;
    }

    await loader.preload();
    _preloadedModules.add(moduleName);
  }

  /// Preload critical modules
  Future<void> preloadCriticalModules() async {
    final futures = _criticalModules.map((moduleName) {
      return preloadModule(moduleName);
    });

    await Future.wait(futures);
  }

  /// Preload multiple modules
  Future<void> preloadModules(List<String> moduleNames) async {
    final futures = moduleNames.map((moduleName) {
      return preloadModule(moduleName);
    });

    await Future.wait(futures);
  }

  /// Check if module is loaded
  bool isModuleLoaded(String moduleName) {
    final loader = _modules[moduleName];
    return loader?.status == DeferredLoadStatus.loaded;
  }

  /// Get module status
  DeferredLoadStatus? getModuleStatus(String moduleName) {
    return _modules[moduleName]?.status;
  }

  /// Unload module
  void unloadModule(String moduleName) {
    _modules[moduleName]?.unload();
    _preloadedModules.remove(moduleName);
  }

  /// Unload all non-critical modules
  void unloadNonCriticalModules() {
    for (final entry in _modules.entries) {
      if (!_criticalModules.contains(entry.key)) {
        entry.value.unload();
        _preloadedModules.remove(entry.key);
      }
    }
  }

  /// Get statistics
  Map<String, dynamic> getStats() {
    final loaded = _modules.values
        .where((loader) => loader.status == DeferredLoadStatus.loaded)
        .length;
    
    final loading = _modules.values
        .where((loader) => loader.status == DeferredLoadStatus.loading)
        .length;
    
    final errors = _modules.values
        .where((loader) => loader.status == DeferredLoadStatus.error)
        .length;

    return {
      'totalModules': _modules.length,
      'loadedModules': loaded,
      'loadingModules': loading,
      'errorModules': errors,
      'criticalModules': _criticalModules.length,
      'preloadedModules': _preloadedModules.length,
    };
  }
}

/// Deferred route loader
class DeferredRoute extends StatefulWidget {
  final String routeName;
  final Future<Widget> Function() loader;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool preload;

  const DeferredRoute({
    super.key,
    required this.routeName,
    required this.loader,
    this.placeholder,
    this.errorWidget,
    this.preload = false,
  });

  @override
  State<DeferredRoute> createState() => _DeferredRouteState();
}

class _DeferredRouteState extends State<DeferredRoute> {
  late Future<Widget> _loadFuture;

  @override
  void initState() {
    super.initState();
    
    if (widget.preload) {
      // Start loading immediately
      _loadFuture = widget.loader();
    } else {
      // Delay loading slightly to prioritize critical content
      _loadFuture = Future.delayed(
        const Duration(milliseconds: 50),
        widget.loader,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return widget.errorWidget ??
              Scaffold(
                appBar: AppBar(
                  title: Text('Error loading ${widget.routeName}'),
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Failed to load route: ${snapshot.error}'),
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
            Scaffold(
              appBar: AppBar(
                title: Text('Loading ${widget.routeName}...'),
              ),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
      },
    );
  }
}

/// Loading boundary for code-split components
class LoadingBoundary extends StatelessWidget {
  final Widget child;
  final Widget? loadingWidget;
  final Widget? errorWidget;

  const LoadingBoundary({
    super.key,
    required this.child,
    this.loadingWidget,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// Route-based code splitting configuration
class RouteSplitConfiguration {
  /// Critical routes that should load immediately
  static const Set<String> criticalRoutes = {
    '/',
    '/login',
    '/dashboard',
  };

  /// Routes that should be preloaded on idle
  static const Set<String> preloadRoutes = {
    '/invoices',
    '/customers',
    '/transactions',
  };

  /// Routes that should be lazy loaded
  static const Set<String> lazyRoutes = {
    '/reports',
    '/analytics',
    '/settings',
    '/autopilot',
    '/suppliers',
    '/payments',
    '/receivables',
    '/recurring-payments',
  };

  /// Check if route should be lazy loaded
  static bool shouldLazyLoad(String route) {
    return lazyRoutes.contains(route) && !criticalRoutes.contains(route);
  }

  /// Check if route should be preloaded
  static bool shouldPreload(String route) {
    return preloadRoutes.contains(route);
  }

  /// Check if route is critical
  static bool isCritical(String route) {
    return criticalRoutes.contains(route);
  }
}

/// Dynamic import helper
class DynamicImportHelper {
  /// Import module dynamically
  static Future<T> import<T>(
    String moduleName,
    Future<T> Function() importer,
  ) async {
    final manager = CodeSplittingManager();
    
    // Register if not already registered
    if (manager.getModuleStatus(moduleName) == null) {
      manager.registerModule(moduleName, importer);
    }

    return await manager.loadModule<T>(moduleName);
  }

  /// Import with retry
  static Future<T> importWithRetry<T>(
    String moduleName,
    Future<T> Function() importer, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
  }) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        return await import(moduleName, importer);
      } catch (error) {
        attempts++;
        
        if (attempts >= maxRetries) {
          rethrow;
        }
        
        await Future.delayed(retryDelay);
      }
    }

    throw Exception('Failed to import $moduleName after $maxRetries attempts');
  }
}

/// Bundle size monitor
class BundleSizeMonitor {
  static final BundleSizeMonitor _instance = BundleSizeMonitor._internal();
  factory BundleSizeMonitor() => _instance;
  BundleSizeMonitor._internal();

  final Map<String, int> _moduleSizes = {};
  int _totalBundleSize = 0;

  /// Record module size
  void recordModuleSize(String moduleName, int sizeInBytes) {
    _moduleSizes[moduleName] = sizeInBytes;
    _totalBundleSize = _moduleSizes.values.fold(0, (sum, size) => sum + size);
  }

  /// Get module size
  int? getModuleSize(String moduleName) {
    return _moduleSizes[moduleName];
  }

  /// Get total bundle size
  int get totalBundleSize => _totalBundleSize;

  /// Get size statistics
  Map<String, dynamic> getStats() {
    final sortedModules = _moduleSizes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'totalSize': _totalBundleSize,
      'totalSizeKB': (_totalBundleSize / 1024).toStringAsFixed(2),
      'moduleCount': _moduleSizes.length,
      'largestModules': sortedModules.take(5).map((e) => {
        'name': e.key,
        'size': e.value,
        'sizeKB': (e.value / 1024).toStringAsFixed(2),
      }).toList(),
    };
  }

  /// Check if bundle size is within target
  bool isWithinTarget({int targetKB = 200}) {
    final currentKB = _totalBundleSize / 1024;
    return currentKB <= targetKB;
  }
}

/// Preload strategy
class PreloadStrategy {
  static final CodeSplittingManager _manager = CodeSplittingManager();

  /// Preload on idle
  static void preloadOnIdle(List<String> moduleNames) {
    // Wait for idle time before preloading
    Future.delayed(const Duration(seconds: 2), () {
      _manager.preloadModules(moduleNames);
    });
  }

  /// Preload on hover (for navigation items)
  static void preloadOnHover(String moduleName) {
    _manager.preloadModule(moduleName);
  }

  /// Preload based on user behavior
  static void preloadPredictive(List<String> likelyNextRoutes) {
    // Preload routes user is likely to visit next
    Future.delayed(const Duration(milliseconds: 500), () {
      _manager.preloadModules(likelyNextRoutes);
    });
  }
}
