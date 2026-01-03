import 'package:flutter/material.dart';
import 'responsive_typography.dart';
import 'responsive_color_scheme.dart';
import 'adaptive_spacing.dart';
import '../responsive/responsive_breakpoints.dart';

/// Responsive theme data that adapts based on screen size
class ResponsiveThemeData {
  /// Get responsive light theme
  static ThemeData getLightTheme(
    Color seedColor,
    double width, {
    Color? accentColor,
  }) {
    final colorScheme = ResponsiveColorScheme.getLightColorScheme(seedColor, width);
    final textTheme = ResponsiveTypography.getTextTheme(width, isDark: false);
    final spacing = _getSpacingValues(width);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: textTheme,
      
      // AppBar theme
      appBarTheme: AppBarTheme(
        elevation: AdaptiveSpacing.getElevation(width, level: ElevationLevel.none),
        centerTitle: !ResponsiveBreakpoints.isDesktop(width),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        elevation: AdaptiveSpacing.getElevation(width, level: ElevationLevel.low),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AdaptiveSpacing.getBorderRadius(width, size: RadiusSize.medium),
          ),
        ),
        margin: EdgeInsets.all(spacing.cardMargin),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AdaptiveSpacing.getBorderRadius(width, size: RadiusSize.small),
          ),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacing.inputHorizontalPadding,
          vertical: spacing.inputVerticalPadding,
        ),
      ),
      
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: AdaptiveSpacing.getElevation(width, level: ElevationLevel.low),
          padding: EdgeInsets.symmetric(
            horizontal: spacing.buttonHorizontalPadding,
            vertical: spacing.buttonVerticalPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AdaptiveSpacing.getBorderRadius(width, size: RadiusSize.small),
            ),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.buttonHorizontalPadding,
            vertical: spacing.buttonVerticalPadding,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.buttonHorizontalPadding,
            vertical: spacing.buttonVerticalPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AdaptiveSpacing.getBorderRadius(width, size: RadiusSize.small),
            ),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      
      // FAB theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor ?? colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
        elevation: AdaptiveSpacing.getElevation(width, level: ElevationLevel.medium),
      ),
      
      // Dialog theme
      dialogTheme: DialogThemeData(
        elevation: AdaptiveSpacing.getElevation(width, level: ElevationLevel.high),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AdaptiveSpacing.getBorderRadius(width, size: RadiusSize.large),
          ),
        ),
      ),
      
      // Bottom sheet theme
      bottomSheetTheme: BottomSheetThemeData(
        elevation: AdaptiveSpacing.getElevation(width, level: ElevationLevel.high),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
              AdaptiveSpacing.getBorderRadius(width, size: RadiusSize.large),
            ),
          ),
        ),
      ),
      
      // Chip theme
      chipTheme: ChipThemeData(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.chipHorizontalPadding,
          vertical: spacing.chipVerticalPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AdaptiveSpacing.getBorderRadius(width, size: RadiusSize.extraLarge),
          ),
        ),
      ),
      
      // List tile theme
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacing.listTileHorizontalPadding,
          vertical: spacing.listTileVerticalPadding,
        ),
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        space: spacing.dividerSpace,
        thickness: 1,
      ),
    );
  }
  
  /// Get responsive dark theme
  static ThemeData getDarkTheme(
    Color seedColor,
    double width, {
    Color? accentColor,
  }) {
    final colorScheme = ResponsiveColorScheme.getDarkColorScheme(seedColor, width);
    final textTheme = ResponsiveTypography.getTextTheme(width, isDark: true);
    final spacing = _getSpacingValues(width);
    
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textTheme,
      
      // AppBar theme
      appBarTheme: AppBarTheme(
        elevation: AdaptiveSpacing.getElevation(width, level: ElevationLevel.none),
        centerTitle: !ResponsiveBreakpoints.isDesktop(width),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        elevation: AdaptiveSpacing.getElevation(width, level: ElevationLevel.low),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AdaptiveSpacing.getBorderRadius(width, size: RadiusSize.medium),
          ),
        ),
        margin: EdgeInsets.all(spacing.cardMargin),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AdaptiveSpacing.getBorderRadius(width, size: RadiusSize.small),
          ),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacing.inputHorizontalPadding,
          vertical: spacing.inputVerticalPadding,
        ),
      ),
      
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: AdaptiveSpacing.getElevation(width, level: ElevationLevel.low),
          padding: EdgeInsets.symmetric(
            horizontal: spacing.buttonHorizontalPadding,
            vertical: spacing.buttonVerticalPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AdaptiveSpacing.getBorderRadius(width, size: RadiusSize.small),
            ),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.buttonHorizontalPadding,
            vertical: spacing.buttonVerticalPadding,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.buttonHorizontalPadding,
            vertical: spacing.buttonVerticalPadding,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AdaptiveSpacing.getBorderRadius(width, size: RadiusSize.small),
            ),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      
      // FAB theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor ?? colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
        elevation: AdaptiveSpacing.getElevation(width, level: ElevationLevel.medium),
      ),
      
      // Dialog theme
      dialogTheme: DialogThemeData(
        elevation: AdaptiveSpacing.getElevation(width, level: ElevationLevel.high),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AdaptiveSpacing.getBorderRadius(width, size: RadiusSize.large),
          ),
        ),
      ),
      
      // Bottom sheet theme
      bottomSheetTheme: BottomSheetThemeData(
        elevation: AdaptiveSpacing.getElevation(width, level: ElevationLevel.high),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
              AdaptiveSpacing.getBorderRadius(width, size: RadiusSize.large),
            ),
          ),
        ),
      ),
      
      // Chip theme
      chipTheme: ChipThemeData(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.chipHorizontalPadding,
          vertical: spacing.chipVerticalPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AdaptiveSpacing.getBorderRadius(width, size: RadiusSize.extraLarge),
          ),
        ),
      ),
      
      // List tile theme
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacing.listTileHorizontalPadding,
          vertical: spacing.listTileVerticalPadding,
        ),
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        space: spacing.dividerSpace,
        thickness: 1,
      ),
    );
  }
  
  /// Get spacing values based on screen width
  static _SpacingValues _getSpacingValues(double width) {
    return _SpacingValues(
      cardMargin: AdaptiveSpacing.getPadding(width, size: SpacingSize.small),
      inputHorizontalPadding: AdaptiveSpacing.getPadding(width, size: SpacingSize.medium),
      inputVerticalPadding: AdaptiveSpacing.getPadding(width, size: SpacingSize.small),
      buttonHorizontalPadding: AdaptiveSpacing.getPadding(width, size: SpacingSize.large),
      buttonVerticalPadding: AdaptiveSpacing.getPadding(width, size: SpacingSize.small),
      chipHorizontalPadding: AdaptiveSpacing.getPadding(width, size: SpacingSize.small),
      chipVerticalPadding: AdaptiveSpacing.getPadding(width, size: SpacingSize.tiny),
      listTileHorizontalPadding: AdaptiveSpacing.getPadding(width, size: SpacingSize.medium),
      listTileVerticalPadding: AdaptiveSpacing.getPadding(width, size: SpacingSize.small),
      dividerSpace: AdaptiveSpacing.getPadding(width, size: SpacingSize.medium),
    );
  }
}

/// Internal class to hold spacing values
class _SpacingValues {
  final double cardMargin;
  final double inputHorizontalPadding;
  final double inputVerticalPadding;
  final double buttonHorizontalPadding;
  final double buttonVerticalPadding;
  final double chipHorizontalPadding;
  final double chipVerticalPadding;
  final double listTileHorizontalPadding;
  final double listTileVerticalPadding;
  final double dividerSpace;
  
  _SpacingValues({
    required this.cardMargin,
    required this.inputHorizontalPadding,
    required this.inputVerticalPadding,
    required this.buttonHorizontalPadding,
    required this.buttonVerticalPadding,
    required this.chipHorizontalPadding,
    required this.chipVerticalPadding,
    required this.listTileHorizontalPadding,
    required this.listTileVerticalPadding,
    required this.dividerSpace,
  });
}
