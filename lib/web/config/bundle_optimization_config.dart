/// Bundle optimization configuration for web builds
/// 
/// Provides configuration and utilities for minimizing bundle size,
/// implementing code splitting, and optimizing asset loading.

library;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Bundle optimization configuration
class BundleOptimizationConfig {
  /// Enable code splitting
  final bool enableCodeSplitting;

  /// Enable tree shaking
  final bool enableTreeShaking;

  /// Enable minification
  final bool enableMinification;

  /// Enable source maps
  final bool enableSourceMaps;

  /// Target bundle size in KB
  final int targetBundleSizeKb;

  /// Maximum initial bundle size in KB
  final int maxInitialBundleSizeKb;

  /// Enable lazy loading for routes
  final bool enableLazyRoutes;

  /// Enable asset optimization
  final bool enableAssetOptimization;

  const BundleOptimizationConfig({
    this.enableCodeSplitting = true,
    this.enableTreeShaking = true,
    this.enableMinification = true,
    this.enableSourceMaps = false,
    this.targetBundleSizeKb = 2048, // 2MB
    this.maxInitialBundleSizeKb = 512, // 512KB
    this.enableLazyRoutes = true,
    this.enableAssetOptimization = true,
  });

  /// Production configuration
  static const BundleOptimizationConfig production = BundleOptimizationConfig(
    enableCodeSplitting: true,
    enableTreeShaking: true,
    enableMinification: true,
    enableSourceMaps: false,
    targetBundleSizeKb: 2048,
    maxInitialBundleSizeKb: 512,
    enableLazyRoutes: true,
    enableAssetOptimization: true,
  );

  /// Development configuration
  static const BundleOptimizationConfig development = BundleOptimizationConfig(
    enableCodeSplitting: false,
    enableTreeShaking: false,
    enableMinification: false,
    enableSourceMaps: true,
    targetBundleSizeKb: 10240, // 10MB
    maxInitialBundleSizeKb: 5120, // 5MB
    enableLazyRoutes: false,
    enableAssetOptimization: false,
  );
}

/// Asset loading strategy
enum AssetLoadingStrategy {
  /// Load all assets immediately
  immediate,

  /// Load assets on demand
  lazy,

  /// Preload critical assets, lazy load others
  hybrid,
}

/// Asset optimization configuration
class AssetOptimizationConfig {
  /// Loading strategy
  final AssetLoadingStrategy strategy;

  /// Compress images
  final bool compressImages;

  /// Convert images to WebP
  final bool convertToWebP;

  /// Image quality (0-100)
  final int imageQuality;

  /// Enable responsive images
  final bool enableResponsiveImages;

  /// Lazy load images
  final bool lazyLoadImages;

  /// Preload critical images
  final List<String> criticalImages;

  const AssetOptimizationConfig({
    this.strategy = AssetLoadingStrategy.hybrid,
    this.compressImages = true,
    this.convertToWebP = true,
    this.imageQuality = 85,
    this.enableResponsiveImages = true,
    this.lazyLoadImages = true,
    this.criticalImages = const [],
  });

  /// Production configuration
  static const AssetOptimizationConfig production = AssetOptimizationConfig(
    strategy: AssetLoadingStrategy.hybrid,
    compressImages: true,
    convertToWebP: true,
    imageQuality: 85,
    enableResponsiveImages: true,
    lazyLoadImages: true,
  );

  /// Development configuration
  static const AssetOptimizationConfig development = AssetOptimizationConfig(
    strategy: AssetLoadingStrategy.immediate,
    compressImages: false,
    convertToWebP: false,
    imageQuality: 100,
    enableResponsiveImages: false,
    lazyLoadImages: false,
  );
}

/// Code splitting configuration
class CodeSplittingConfig {
  /// Routes to split into separate bundles
  final Set<String> splitRoutes;

  /// Minimum bundle size for splitting (KB)
  final int minBundleSizeKb;

  /// Maximum number of bundles
  final int maxBundles;

  /// Preload critical routes
  final Set<String> preloadRoutes;

  const CodeSplittingConfig({
    this.splitRoutes = const {},
    this.minBundleSizeKb = 100,
    this.maxBundles = 10,
    this.preloadRoutes = const {},
  });

  /// Default configuration
  static const CodeSplittingConfig defaultConfig = CodeSplittingConfig(
    splitRoutes: {
      '/reports',
      '/analytics',
      '/settings',
      '/autopilot',
    },
    minBundleSizeKb: 100,
    maxBundles: 10,
    preloadRoutes: {
      '/',
      '/dashboard',
    },
  );
}

/// Dependency optimization
class DependencyOptimization {
  /// List of heavy dependencies that should be lazy loaded
  static const Set<String> lazyDependencies = {
    'fl_chart', // Charts library
    'pdf', // PDF generation
    'syncfusion_flutter_pdf', // PDF processing
  };

  /// List of critical dependencies that should be in main bundle
  static const Set<String> criticalDependencies = {
    'flutter',
    'provider',
    'supabase_flutter',
  };

  /// Check if dependency should be lazy loaded
  static bool shouldLazyLoad(String dependency) {
    return lazyDependencies.contains(dependency);
  }

  /// Check if dependency is critical
  static bool isCritical(String dependency) {
    return criticalDependencies.contains(dependency);
  }
}

/// Build optimization recommendations
class BuildOptimizationRecommendations {
  /// Get build command for optimal web build
  static String getOptimalBuildCommand({
    bool isProduction = true,
    bool enableSourceMaps = false,
  }) {
    final flags = <String>[
      'flutter build web',
      '--release',
      '--web-renderer canvaskit',
      '--dart-define=FLUTTER_WEB_USE_SKIA=true',
    ];

    if (enableSourceMaps) {
      flags.add('--source-maps');
    }

    if (isProduction) {
      flags.addAll([
        '--tree-shake-icons',
        '--no-pub',
      ]);
    }

    return flags.join(' ');
  }

  /// Get recommended pubspec.yaml optimizations
  static Map<String, dynamic> getPubspecOptimizations() {
    return {
      'flutter': {
        'uses-material-design': true,
        'assets': [
          // Only include necessary assets
          '.env',
        ],
        // Remove unused fonts
        'fonts': [],
      },
    };
  }

  /// Get recommended analysis_options.yaml settings
  static Map<String, dynamic> getAnalysisOptions() {
    return {
      'analyzer': {
        'exclude': [
          'build/**',
          '**/*.g.dart',
          '**/*.freezed.dart',
        ],
        'strong-mode': {
          'implicit-casts': false,
          'implicit-dynamic': false,
        },
      },
      'linter': {
        'rules': [
          'avoid_print',
          'prefer_const_constructors',
          'prefer_const_literals_to_create_immutables',
          'unnecessary_const',
          'unnecessary_new',
        ],
      },
    };
  }
}

/// Bundle size analyzer
class BundleSizeAnalyzer {
  /// Estimated sizes of major dependencies (KB)
  static const Map<String, int> dependencySizes = {
    'flutter': 500,
    'provider': 50,
    'supabase_flutter': 200,
    'fl_chart': 300,
    'pdf': 400,
    'syncfusion_flutter_pdf': 500,
    'firebase_core': 150,
    'firebase_auth': 200,
  };

  /// Calculate estimated bundle size
  static int calculateEstimatedSize(List<String> dependencies) {
    return dependencies.fold<int>(
      0,
      (sum, dep) => sum + (dependencySizes[dep] ?? 0),
    );
  }

  /// Get optimization suggestions
  static List<String> getOptimizationSuggestions(
    int currentSizeKb,
    int targetSizeKb,
  ) {
    final suggestions = <String>[];

    if (currentSizeKb > targetSizeKb) {
      final excessKb = currentSizeKb - targetSizeKb;
      suggestions.add(
        'Bundle size ($currentSizeKb KB) exceeds target ($targetSizeKb KB) by $excessKb KB',
      );

      suggestions.addAll([
        'Enable code splitting for heavy routes',
        'Lazy load non-critical dependencies',
        'Remove unused dependencies',
        'Optimize images and assets',
        'Enable tree shaking',
        'Use deferred imports for heavy features',
      ]);
    }

    return suggestions;
  }
}

/// Performance budget
class PerformanceBudget {
  /// Maximum initial load time (seconds)
  final double maxInitialLoadTime;

  /// Maximum time to interactive (seconds)
  final double maxTimeToInteractive;

  /// Maximum first contentful paint (seconds)
  final double maxFirstContentfulPaint;

  /// Maximum bundle size (KB)
  final int maxBundleSizeKb;

  /// Maximum image size (KB)
  final int maxImageSizeKb;

  const PerformanceBudget({
    this.maxInitialLoadTime = 3.0,
    this.maxTimeToInteractive = 5.0,
    this.maxFirstContentfulPaint = 1.5,
    this.maxBundleSizeKb = 2048,
    this.maxImageSizeKb = 500,
  });

  /// Production budget
  static const PerformanceBudget production = PerformanceBudget(
    maxInitialLoadTime: 3.0,
    maxTimeToInteractive: 5.0,
    maxFirstContentfulPaint: 1.5,
    maxBundleSizeKb: 2048,
    maxImageSizeKb: 500,
  );

  /// Development budget (more lenient)
  static const PerformanceBudget development = PerformanceBudget(
    maxInitialLoadTime: 10.0,
    maxTimeToInteractive: 15.0,
    maxFirstContentfulPaint: 5.0,
    maxBundleSizeKb: 10240,
    maxImageSizeKb: 2048,
  );

  /// Check if metrics meet budget
  bool meetsLoadTimeBudget(double actualSeconds) {
    return actualSeconds <= maxInitialLoadTime;
  }

  bool meetsInteractiveBudget(double actualSeconds) {
    return actualSeconds <= maxTimeToInteractive;
  }

  bool meetsFCPBudget(double actualSeconds) {
    return actualSeconds <= maxFirstContentfulPaint;
  }

  bool meetsBundleSizeBudget(int actualKb) {
    return actualKb <= maxBundleSizeKb;
  }

  bool meetsImageSizeBudget(int actualKb) {
    return actualKb <= maxImageSizeKb;
  }
}

/// Web optimization utilities
class WebOptimizationUtils {
  /// Check if running on web
  static bool get isWeb => kIsWeb;

  /// Get current environment
  static String get environment {
    const bool isProduction = bool.fromEnvironment('dart.vm.product');
    return isProduction ? 'production' : 'development';
  }

  /// Get appropriate configuration for current environment
  static BundleOptimizationConfig getBundleConfig() {
    return environment == 'production'
        ? BundleOptimizationConfig.production
        : BundleOptimizationConfig.development;
  }

  /// Get appropriate asset configuration for current environment
  static AssetOptimizationConfig getAssetConfig() {
    return environment == 'production'
        ? AssetOptimizationConfig.production
        : AssetOptimizationConfig.development;
  }

  /// Get appropriate performance budget for current environment
  static PerformanceBudget getPerformanceBudget() {
    return environment == 'production'
        ? PerformanceBudget.production
        : PerformanceBudget.development;
  }
}
