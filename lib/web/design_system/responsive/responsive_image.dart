import 'package:flutter/material.dart';
import 'responsive_config.dart';

/// Responsive image that loads appropriate size based on viewport
class ResponsiveImage extends StatelessWidget {
  final String baseUrl;
  final String? mobileUrl;
  final String? tabletUrl;
  final String? desktopUrl;
  final String? wideUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ResponsiveImage({
    super.key,
    required this.baseUrl,
    this.mobileUrl,
    this.tabletUrl,
    this.desktopUrl,
    this.wideUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  String _getImageUrl(double viewportWidth) {
    if (viewportWidth >= ResponsiveConfig.wide.minWidth && wideUrl != null) {
      return wideUrl!;
    }
    if (viewportWidth >= ResponsiveConfig.desktop.minWidth && desktopUrl != null) {
      return desktopUrl!;
    }
    if (viewportWidth >= ResponsiveConfig.tablet.minWidth && tabletUrl != null) {
      return tabletUrl!;
    }
    if (mobileUrl != null) {
      return mobileUrl!;
    }
    return baseUrl;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageUrl = _getImageUrl(constraints.maxWidth);
        
        return Image.network(
          imageUrl,
          width: width,
          height: height,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return placeholder ?? 
                Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
          },
          errorBuilder: (context, error, stackTrace) {
            return errorWidget ?? 
                Container(
                  width: width,
                  height: height,
                  color: const Color(0xFFE0E0E0),
                  child: const Icon(Icons.error_outline),
                );
          },
        );
      },
    );
  }
}

/// Responsive image with aspect ratio
class ResponsiveAspectImage extends StatelessWidget {
  final String baseUrl;
  final String? mobileUrl;
  final String? tabletUrl;
  final String? desktopUrl;
  final String? wideUrl;
  final double aspectRatio;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ResponsiveAspectImage({
    super.key,
    required this.baseUrl,
    this.mobileUrl,
    this.tabletUrl,
    this.desktopUrl,
    this.wideUrl,
    this.aspectRatio = 16 / 9,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ResponsiveImage(
        baseUrl: baseUrl,
        mobileUrl: mobileUrl,
        tabletUrl: tabletUrl,
        desktopUrl: desktopUrl,
        wideUrl: wideUrl,
        fit: fit,
        placeholder: placeholder,
        errorWidget: errorWidget,
      ),
    );
  }
}

/// Utility for generating responsive image URLs
class ResponsiveImageUtils {
  /// Generate image URL with width parameter
  static String withWidth(String baseUrl, int width) {
    final uri = Uri.parse(baseUrl);
    final params = Map<String, String>.from(uri.queryParameters);
    params['w'] = width.toString();
    
    return uri.replace(queryParameters: params).toString();
  }

  /// Generate image URL with height parameter
  static String withHeight(String baseUrl, int height) {
    final uri = Uri.parse(baseUrl);
    final params = Map<String, String>.from(uri.queryParameters);
    params['h'] = height.toString();
    
    return uri.replace(queryParameters: params).toString();
  }

  /// Generate image URL with dimensions
  static String withDimensions(String baseUrl, int width, int height) {
    final uri = Uri.parse(baseUrl);
    final params = Map<String, String>.from(uri.queryParameters);
    params['w'] = width.toString();
    params['h'] = height.toString();
    
    return uri.replace(queryParameters: params).toString();
  }

  /// Generate responsive image URLs for all breakpoints
  static Map<String, String> generateResponsiveUrls(String baseUrl) {
    return {
      'mobile': withWidth(baseUrl, 768),
      'tablet': withWidth(baseUrl, 1024),
      'desktop': withWidth(baseUrl, 1440),
      'wide': withWidth(baseUrl, 1920),
    };
  }
}
