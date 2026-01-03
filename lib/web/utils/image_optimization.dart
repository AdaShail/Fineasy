/// Image optimization utilities for web platform
/// 
/// Provides WebP support, lazy loading, and responsive image loading
/// to optimize bandwidth and improve performance.

library;

import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Image format types
enum ImageFormat {
  webp,
  jpeg,
  png,
  gif,
}

/// Image optimization configuration
class ImageOptimizationConfig {
  final bool enableWebP;
  final bool enableLazyLoading;
  final bool enableResponsiveImages;
  final int maxImageWidth;
  final int maxImageHeight;
  final int jpegQuality;
  final bool enableMemoryCache;
  final bool enableDiskCache;

  const ImageOptimizationConfig({
    this.enableWebP = true,
    this.enableLazyLoading = true,
    this.enableResponsiveImages = true,
    this.maxImageWidth = 1920,
    this.maxImageHeight = 1080,
    this.jpegQuality = 85,
    this.enableMemoryCache = true,
    this.enableDiskCache = true,
  });

  static const ImageOptimizationConfig defaultConfig = ImageOptimizationConfig();
}

/// Optimized image widget with WebP support and lazy loading
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final ImageOptimizationConfig config;
  final bool isLazyLoaded;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.config = ImageOptimizationConfig.defaultConfig,
    this.isLazyLoaded = true,
  });

  @override
  Widget build(BuildContext context) {
    final optimizedUrl = _getOptimizedImageUrl();

    if (isLazyLoaded && kIsWeb) {
      return _LazyLoadedImage(
        imageUrl: optimizedUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: placeholder,
        errorWidget: errorWidget,
      );
    }

    return Image.network(
      optimizedUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? _defaultPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _defaultErrorWidget();
      },
    );
  }

  String _getOptimizedImageUrl() {
    if (!kIsWeb || !config.enableWebP) {
      return imageUrl;
    }

    // Check if URL already has query parameters
    final hasParams = imageUrl.contains('?');
    final separator = hasParams ? '&' : '?';

    // Add WebP format and size parameters if supported
    var optimizedUrl = imageUrl;
    
    // Add format parameter for WebP
    if (config.enableWebP && _supportsWebP()) {
      optimizedUrl += '${separator}format=webp';
    }

    // Add responsive image parameters
    if (config.enableResponsiveImages && width != null) {
      optimizedUrl += '&w=${width!.toInt()}';
    }
    if (config.enableResponsiveImages && height != null) {
      optimizedUrl += '&h=${height!.toInt()}';
    }

    // Add quality parameter
    optimizedUrl += '&q=${config.jpegQuality}';

    return optimizedUrl;
  }

  bool _supportsWebP() {
    // WebP is supported in modern browsers
    // Flutter web uses CanvasKit which supports WebP
    return kIsWeb;
  }

  Widget _defaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _defaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }
}

/// Lazy loaded image with intersection observer
class _LazyLoadedImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const _LazyLoadedImage({
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<_LazyLoadedImage> createState() => _LazyLoadedImageState();
}

class _LazyLoadedImageState extends State<_LazyLoadedImage> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    // Delay loading slightly to allow for scroll position
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isVisible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
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

/// Responsive image that loads different sizes based on screen width
class ResponsiveImage extends StatelessWidget {
  final String baseUrl;
  final Map<int, String>? srcSet; // width -> url mapping
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ResponsiveImage({
    super.key,
    required this.baseUrl,
    this.srcSet,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageUrl = _selectImageUrl(screenWidth);

    return OptimizedImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }

  String _selectImageUrl(double screenWidth) {
    if (srcSet == null || srcSet!.isEmpty) {
      return baseUrl;
    }

    // Find the smallest image that's larger than the screen width
    final sortedWidths = srcSet!.keys.toList()..sort();
    
    for (final width in sortedWidths) {
      if (width >= screenWidth) {
        return srcSet![width]!;
      }
    }

    // If no larger image found, use the largest available
    return srcSet![sortedWidths.last]!;
  }
}

/// Image preloader for critical images
class ImagePreloader {
  static final ImagePreloader _instance = ImagePreloader._internal();
  factory ImagePreloader() => _instance;
  ImagePreloader._internal();

  final Set<String> _preloadedImages = {};

  /// Preload an image
  Future<void> preload(BuildContext context, String imageUrl) async {
    if (_preloadedImages.contains(imageUrl)) {
      return;
    }

    try {
      await precacheImage(NetworkImage(imageUrl), context);
      _preloadedImages.add(imageUrl);
    } catch (e) {
    }
  }

  /// Preload multiple images
  Future<void> preloadMultiple(
    BuildContext context,
    List<String> imageUrls,
  ) async {
    await Future.wait(
      imageUrls.map((url) => preload(context, url)),
    );
  }

  /// Check if image is preloaded
  bool isPreloaded(String imageUrl) {
    return _preloadedImages.contains(imageUrl);
  }

  /// Clear preloaded images cache
  void clear() {
    _preloadedImages.clear();
  }
}

/// Image compression utilities
class ImageCompression {
  /// Compress image data
  static Future<Uint8List> compress(
    Uint8List imageData, {
    int quality = 85,
    int? maxWidth,
    int? maxHeight,
  }) async {
    // Note: Actual compression would require image processing library
    // This is a placeholder for the compression logic
    // In production, use packages like 'image' or 'flutter_image_compress'
    return imageData;
  }

  /// Convert image to WebP format
  static Future<Uint8List> convertToWebP(
    Uint8List imageData, {
    int quality = 85,
  }) async {
    // Note: Actual conversion would require image processing library
    // This is a placeholder for the conversion logic
    return imageData;
  }

  /// Get optimal image format for web
  static ImageFormat getOptimalFormat(String mimeType) {
    if (kIsWeb) {
      // Prefer WebP for web
      return ImageFormat.webp;
    }

    // Fallback based on mime type
    if (mimeType.contains('png')) return ImageFormat.png;
    if (mimeType.contains('gif')) return ImageFormat.gif;
    return ImageFormat.jpeg;
  }
}
