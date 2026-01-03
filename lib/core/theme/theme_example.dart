import 'package:flutter/material.dart';
import 'responsive_typography.dart';
import 'adaptive_spacing.dart';
import 'responsive_color_scheme.dart';

/// Example screen demonstrating responsive theme system
class ThemeExampleScreen extends StatelessWidget {
  const ThemeExampleScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Responsive Theme Example'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          AdaptiveSpacing.getPadding(width, size: SpacingSize.large),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypographySection(width, isDark),
            SizedBox(height: AdaptiveSpacing.getGap(width, size: SpacingSize.huge)),
            _buildSpacingSection(width),
            SizedBox(height: AdaptiveSpacing.getGap(width, size: SpacingSize.huge)),
            _buildColorSection(isDark, context),
            SizedBox(height: AdaptiveSpacing.getGap(width, size: SpacingSize.huge)),
            _buildComponentSection(width, context),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTypographySection(double width, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Typography',
          style: ResponsiveTypography.getHeadingStyle(width, isDark: isDark),
        ),
        SizedBox(height: AdaptiveSpacing.getGap(width)),
        Text(
          'Display Large',
          style: ResponsiveTypography.getTextTheme(width, isDark: isDark).displayLarge,
        ),
        Text(
          'Headline Medium',
          style: ResponsiveTypography.getTextTheme(width, isDark: isDark).headlineMedium,
        ),
        Text(
          'Title Large',
          style: ResponsiveTypography.getTextTheme(width, isDark: isDark).titleLarge,
        ),
        Text(
          'Body Large - This is body text that scales responsively',
          style: ResponsiveTypography.getTextTheme(width, isDark: isDark).bodyLarge,
        ),
        Text(
          'Body Small - Smaller body text',
          style: ResponsiveTypography.getTextTheme(width, isDark: isDark).bodySmall,
        ),
      ],
    );
  }
  
  Widget _buildSpacingSection(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adaptive Spacing',
          style: ResponsiveTypography.getHeadingStyle(width),
        ),
        SizedBox(height: AdaptiveSpacing.getGap(width)),
        Wrap(
          spacing: AdaptiveSpacing.getGap(width, size: SpacingSize.small),
          runSpacing: AdaptiveSpacing.getGap(width, size: SpacingSize.small),
          children: [
            _buildSpacingChip(width, 'Tiny', SpacingSize.tiny),
            _buildSpacingChip(width, 'Small', SpacingSize.small),
            _buildSpacingChip(width, 'Medium', SpacingSize.medium),
            _buildSpacingChip(width, 'Large', SpacingSize.large),
            _buildSpacingChip(width, 'Extra Large', SpacingSize.extraLarge),
          ],
        ),
      ],
    );
  }
  
  Widget _buildSpacingChip(double width, String label, SpacingSize size) {
    final padding = AdaptiveSpacing.getPadding(width, size: size);
    return Chip(
      label: Text('$label (${padding.toStringAsFixed(1)}px)'),
    );
  }
  
  Widget _buildColorSection(bool isDark, BuildContext context) {
    final financialColors = ResponsiveColorScheme.getFinancialColors(isDark);
    final statusColors = ResponsiveColorScheme.getStatusColors(isDark);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Semantic Colors',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Text('Financial Colors:', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildColorChip('Profit', financialColors.profit),
            _buildColorChip('Loss', financialColors.loss),
            _buildColorChip('Pending', financialColors.pending),
            _buildColorChip('Paid', financialColors.paid),
            _buildColorChip('Overdue', financialColors.overdue),
          ],
        ),
        const SizedBox(height: 16),
        Text('Status Colors:', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildColorChip('Success', statusColors.success),
            _buildColorChip('Warning', statusColors.warning),
            _buildColorChip('Error', statusColors.error),
            _buildColorChip('Info', statusColors.info),
          ],
        ),
      ],
    );
  }
  
  Widget _buildColorChip(String label, Color color) {
    return Chip(
      label: Text(label),
      backgroundColor: color,
      labelStyle: const TextStyle(color: Colors.white),
    );
  }
  
  Widget _buildComponentSection(double width, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Responsive Components',
          style: ResponsiveTypography.getHeadingStyle(width),
        ),
        SizedBox(height: AdaptiveSpacing.getGap(width)),
        
        // Buttons
        Wrap(
          spacing: AdaptiveSpacing.getGap(width, size: SpacingSize.small),
          runSpacing: AdaptiveSpacing.getGap(width, size: SpacingSize.small),
          children: [
            ElevatedButton(
              onPressed: () {},
              child: const Text('Elevated Button'),
            ),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Outlined Button'),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Text Button'),
            ),
          ],
        ),
        SizedBox(height: AdaptiveSpacing.getGap(width)),
        
        // Card
        Card(
          child: Padding(
            padding: EdgeInsets.all(
              AdaptiveSpacing.getPadding(width, size: SpacingSize.medium),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Responsive Card',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: AdaptiveSpacing.getGap(width, size: SpacingSize.small)),
                Text(
                  'This card has responsive padding and border radius',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: AdaptiveSpacing.getGap(width)),
        
        // Text field
        TextField(
          decoration: const InputDecoration(
            labelText: 'Responsive Text Field',
            hintText: 'Enter text here',
          ),
        ),
      ],
    );
  }
}

/// Example of using responsive theme in a custom widget
class ResponsiveFinancialCard extends StatelessWidget {
  final String title;
  final double amount;
  final bool isProfit;
  
  const ResponsiveFinancialCard({
    super.key,
    required this.title,
    required this.amount,
    required this.isProfit,
  });
  
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final financialColors = ResponsiveColorScheme.getFinancialColors(isDark);
    
    return Card(
      elevation: AdaptiveSpacing.getElevation(width, level: ElevationLevel.low),
      child: Padding(
        padding: EdgeInsets.all(
          AdaptiveSpacing.getPadding(width, size: SpacingSize.large),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: ResponsiveTypography.getCaptionStyle(width, isDark: isDark),
            ),
            SizedBox(height: AdaptiveSpacing.getGap(width, size: SpacingSize.small)),
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: ResponsiveTypography.getHeadingStyle(width, isDark: isDark).copyWith(
                color: isProfit ? financialColors.profit : financialColors.loss,
              ),
            ),
            SizedBox(height: AdaptiveSpacing.getGap(width, size: SpacingSize.tiny)),
            Row(
              children: [
                Icon(
                  isProfit ? Icons.trending_up : Icons.trending_down,
                  size: AdaptiveSpacing.getIconSize(width, size: IconSize.small),
                  color: isProfit ? financialColors.profit : financialColors.loss,
                ),
                SizedBox(width: AdaptiveSpacing.getGap(width, size: SpacingSize.tiny)),
                Text(
                  isProfit ? 'Profit' : 'Loss',
                  style: ResponsiveTypography.getCaptionStyle(width, isDark: isDark).copyWith(
                    color: isProfit ? financialColors.profit : financialColors.loss,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Example of responsive grid layout
class ResponsiveGridExample extends StatelessWidget {
  const ResponsiveGridExample({super.key});
  
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns = AdaptiveSpacing.getGridColumns(width);
    
    return GridView.builder(
      padding: EdgeInsets.all(
        AdaptiveSpacing.getPadding(width, size: SpacingSize.medium),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: AdaptiveSpacing.getGap(width),
        mainAxisSpacing: AdaptiveSpacing.getGap(width),
        childAspectRatio: 1.5,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        return ResponsiveFinancialCard(
          title: 'Item ${index + 1}',
          amount: (index + 1) * 1000.0,
          isProfit: index % 2 == 0,
        );
      },
    );
  }
}
