/// Lazy loading service for web platform
/// 
/// Implements intersection observer for lazy loading images and components,
/// and provides utilities for preloading critical resources.
/// 
/// Requirements: 8.3, 8.11

library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Intersection observer for lazy loading
class IntersectionObserver {
  static final IntersectionObserver _instance = IntersectionObserver._internal();
  factory IntersectionObserver() => _instance;
  IntersectionObserver._internal();

  final Map<Key, _ObserverEntry> _observers = {};
  final double _threshold = 0.1; // 10% visibility threshold
  final double _rootMargin = 200.0; // Load 200px before entering viewport

  /// Register an element for observation
  void observe({
    required Key key,
    required BuildContext context,
    required VoidCallback onIntersect,
    double? threshold,
    double? rootMargin,
  }) {
    _observers[key] = _ObserverEntry(
      context: context,
      onIntersect: onIntersect,
      threshold: threshold ?? _threshold,
      rootMargin: rootMargin ?? _rootMargin,
    );

    // Check immediately if already visible
    _checkVisibility(key);
  }

  /// Unregister an element
  void unobserve(Key key) {
    _observers.remove(key);
  }

  /// Check visibility of an element
  void _checkVisibility(Key key) {
    final entry = _observers[key];
    if (entry == null) return;

    try {
      final renderObject = entry.context.findRenderObject();
      if (renderObject == null || !renderObject.attached) return;

      if (renderObject is RenderBox) {
        final viewport = RenderAbstractViewport.of(renderObject);

        final position = renderObject.localToGlobal(Offset.zero);
        final size = renderObject.size;
        final viewportSize = viewport.paintBounds.size;

        // Check if element is within viewport (with margin)
        final isVisible = position.dy + size.height + entry.rootMargin >= 0 &&
            position.dy - entry.rootMargin <= viewportSize.height;

        if (isVisible && !entry.hasIntersected) {
          entry.hasIntersected = true;
          entry.onIntersect();
          // Auto-unobserve after intersection
          unobserve(key);
        }
      }
    } catch (e) {
    }
  }

  /// Check all registered observers
  void checkAll() {
    final keys = _observers.keys.toList();
    for (final key in keys) {
      _checkVisibility(key);
    }
  }

  /// Clear all observers
  void clear() {
    _observers.clear();
  }
}

class _ObserverEntry {
  final BuildContext context;
  final VoidCallback onIntersect;
  final double threshold;
  final double rootMargin;
  bool hasIntersected = false;

  _ObserverEntry({
    required this.context,
    required this.onIntersect,
    required this.threshold,
    required this.rootMargin,
  });
}

/// Lazy load widget with intersection observer
class LazyLoadWidget extends StatefulWidget {
  final Widget Function(BuildContext context) builder;
  final Widget? placeholder;
  final double threshold;
  final double rootMargin;

  const LazyLoadWidget({
    super.key,
    required this.builder,
    this.placeholder,
    this.threshold = 0.1,
    this.rootMargin = 200.0,
  });

  @override
  State<LazyLoadWidget> createState() => _LazyLoadWidgetState();
}

class _LazyLoadWidgetState extends State<LazyLoadWidget> {
  bool _isVisible = false;
  late Key _observerKey;

  @override
  void initState() {
    super.initState();
    _observerKey = UniqueKey();
    
    // Schedule observation after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        IntersectionObserver().observe(
          key: _observerKey,
          context: context,
          onIntersect: _onIntersect,
          threshold: widget.threshold,
          rootMargin: widget.rootMargin,
        );
      }
    });
  }

  void _onIntersect() {
    if (mounted) {
      setState(() {
        _isVisible = true;
      });
    }
  }

  @override
  void dispose() {
    IntersectionObserver().unobserve(_observerKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isVisible) {
      return widget.builder(context);
    }

    return widget.placeholder ?? const SizedBox.shrink();
  }
}

/// Lazy load image with progressive loading
class LazyLoadImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final double threshold;
  final double rootMargin;

  const LazyLoadImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.threshold = 0.1,
    this.rootMargin = 200.0,
  });

  @override
  State<LazyLoadImage> createState() => _LazyLoadImageState();
}

class _LazyLoadImageState extends State<LazyLoadImage> {
  bool _shouldLoad = false;
  late Key _observerKey;

  @override
  void initState() {
    super.initState();
    _observerKey = UniqueKey();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        IntersectionObserver().observe(
          key: _observerKey,
          context: context,
          onIntersect: () {
            if (mounted) {
              setState(() {
                _shouldLoad = true;
              });
            }
          },
          threshold: widget.threshold,
          rootMargin: widget.rootMargin,
        );
      }
    });
  }

  @override
  void dispose() {
    IntersectionObserver().unobserve(_observerKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldLoad) {
      return widget.placeholder ??
          Container(
            width: widget.width,
            height: widget.height,
            color: Colors.grey[200],
          );
    }

    return Image.network(
      widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        
        return widget.placeholder ??
            Container(
              width: widget.width,
              height: widget.height,
              color: Colors.grey[200],
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
            Container(
              width: widget.width,
              height: widget.height,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.grey),
              ),
            );
      },
    );
  }
}

/// Lazy load list with viewport-based loading
class LazyLoadList extends StatefulWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final Widget? separator;
  final EdgeInsets? padding;
  final ScrollController? controller;

  const LazyLoadList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.separator,
    this.padding,
    this.controller,
  });

  @override
  State<LazyLoadList> createState() => _LazyLoadListState();
}

class _LazyLoadListState extends State<LazyLoadList> {
  late ScrollController _controller;
  final Set<int> _loadedIndices = {};
  final int _loadAheadCount = 5;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ScrollController();
    _controller.addListener(_onScroll);
    
    // Load initial items
    _loadInitialItems();
  }

  void _loadInitialItems() {
    for (int i = 0; i < _loadAheadCount && i < widget.itemCount; i++) {
      _loadedIndices.add(i);
    }
  }

  void _onScroll() {
    // Calculate visible range
    final position = _controller.position;
    final viewportHeight = position.viewportDimension;
    final scrollOffset = position.pixels;
    
    // Estimate item height (simplified)
    final estimatedItemHeight = 100.0;
    final firstVisibleIndex = (scrollOffset / estimatedItemHeight).floor();
    final lastVisibleIndex = ((scrollOffset + viewportHeight) / estimatedItemHeight).ceil();
    
    // Load items in visible range plus ahead
    setState(() {
      for (int i = firstVisibleIndex; 
           i <= lastVisibleIndex + _loadAheadCount && i < widget.itemCount; 
           i++) {
        _loadedIndices.add(i);
      }
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: _controller,
      padding: widget.padding,
      itemCount: widget.itemCount,
      separatorBuilder: (context, index) => widget.separator ?? const SizedBox.shrink(),
      itemBuilder: (context, index) {
        if (_loadedIndices.contains(index)) {
          return widget.itemBuilder(context, index);
        }
        
        // Placeholder for unloaded items
        return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
      },
    );
  }
}

/// Resource preloader for critical resources
class ResourcePreloader {
  static final ResourcePreloader _instance = ResourcePreloader._internal();
  factory ResourcePreloader() => _instance;
  ResourcePreloader._internal();

  final Map<String, Future<dynamic>> _preloadedResources = {};
  final Set<String> _criticalResources = {};

  /// Mark resource as critical
  void markCritical(String resourceId) {
    _criticalResources.add(resourceId);
  }

  /// Preload a resource
  Future<T> preload<T>(String resourceId, Future<T> Function() loader) async {
    if (_preloadedResources.containsKey(resourceId)) {
      return _preloadedResources[resourceId] as Future<T>;
    }

    final future = loader();
    _preloadedResources[resourceId] = future;
    
    // Wait for critical resources
    if (_criticalResources.contains(resourceId)) {
      await future;
    }
    
    return future;
  }

  /// Get preloaded resource
  Future<T>? get<T>(String resourceId) {
    return _preloadedResources[resourceId] as Future<T>?;
  }

  /// Check if resource is preloaded
  bool isPreloaded(String resourceId) {
    return _preloadedResources.containsKey(resourceId);
  }

  /// Preload multiple resources
  Future<void> preloadMultiple(Map<String, Future<dynamic> Function()> loaders) async {
    final futures = loaders.entries.map((entry) {
      return preload(entry.key, entry.value);
    });
    
    await Future.wait(futures);
  }

  /// Clear preloaded resources
  void clear() {
    _preloadedResources.clear();
    _criticalResources.clear();
  }

  /// Clear specific resource
  void clearResource(String resourceId) {
    _preloadedResources.remove(resourceId);
    _criticalResources.remove(resourceId);
  }
}

/// Lazy component loader with caching
class LazyComponentLoader<T extends Widget> {
  final Future<T> Function() _loader;
  Future<T>? _cachedFuture;
  bool _isLoading = false;

  LazyComponentLoader(this._loader);

  /// Load component
  Future<T> load() {
    if (_cachedFuture != null) {
      return _cachedFuture!;
    }

    if (_isLoading) {
      // Wait for current load to complete
      return _cachedFuture!;
    }

    _isLoading = true;
    _cachedFuture = _loader().then((component) {
      _isLoading = false;
      return component;
    }).catchError((error) {
      _isLoading = false;
      _cachedFuture = null;
      throw error;
    });

    return _cachedFuture!;
  }

  /// Check if component is loaded
  bool get isLoaded => _cachedFuture != null;

  /// Clear cached component
  void clear() {
    _cachedFuture = null;
    _isLoading = false;
  }
}

/// Lazy load wrapper for non-critical components
class LazyComponent extends StatefulWidget {
  final Future<Widget> Function() loader;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool preload;

  const LazyComponent({
    super.key,
    required this.loader,
    this.placeholder,
    this.errorWidget,
    this.preload = false,
  });

  @override
  State<LazyComponent> createState() => _LazyComponentState();
}

class _LazyComponentState extends State<LazyComponent> {
  late Future<Widget> _loadFuture;

  @override
  void initState() {
    super.initState();
    if (widget.preload) {
      _loadFuture = widget.loader();
    } else {
      // Delay loading until after first frame
      _loadFuture = Future.delayed(
        const Duration(milliseconds: 100),
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
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(height: 8),
                    Text('Error: ${snapshot.error}'),
                  ],
                ),
              );
        }

        if (snapshot.hasData) {
          return snapshot.data!;
        }

        return widget.placeholder ?? const Center(child: CircularProgressIndicator());
      },
    );
  }
}

/// Preload utilities for critical resources
class PreloadUtilities {
  /// Preload images
  static Future<void> preloadImages(
    BuildContext context,
    List<String> imageUrls,
  ) async {
    final futures = imageUrls.map((url) {
      return precacheImage(NetworkImage(url), context);
    });
    
    await Future.wait(futures);
  }

  /// Preload fonts
  static Future<void> preloadFonts(List<String> fontFamilies) async {
    // Font preloading is handled by Flutter automatically
    // This is a placeholder for custom font loading logic
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Preload data
  static Future<T> preloadData<T>(
    String key,
    Future<T> Function() fetcher,
  ) async {
    return ResourcePreloader().preload(key, fetcher);
  }
}
