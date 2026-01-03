/// Example usage of the design token system
/// This file demonstrates how to use design tokens in components
library;

import 'package:flutter/material.dart';
import 'design_tokens.dart';

/// Example button component using design tokens
class TokenizedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const TokenizedButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) {
    // Get tokens from context
    final colors = context.colors;
    
    return Material(
      color: isPrimary 
          ? colors.primary.shade500 
          : colors.secondary.shade500,
      borderRadius: BorderRadius.circular(
        SemanticBorderRadius.button,
      ),
      elevation: ElevationTokens.level2,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(
          SemanticBorderRadius.button,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: SemanticSpacing.buttonPaddingHorizontal,
            vertical: SemanticSpacing.buttonPaddingVertical,
          ),
          child: Text(
            label,
            style: TextStylePresets.label(
              color: colors.neutral.shade0,
            ),
          ),
        ),
      ),
    );
  }
}

/// Example card component using design tokens
class TokenizedCard extends StatelessWidget {
  final Widget child;
  final bool elevated;

  const TokenizedCard({
    super.key,
    required this.child,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return Container(
      padding: EdgeInsets.all(SemanticSpacing.cardPadding),
      decoration: BoxDecoration(
        color: elevated 
            ? colors.surface.elevated 
            : colors.surface.card,
        borderRadius: BorderRadius.circular(
          SemanticBorderRadius.card,
        ),
        boxShadow: elevated 
            ? ShadowTokens.md 
            : ShadowTokens.base,
      ),
      child: child,
    );
  }
}

/// Example input field using design tokens
class TokenizedInput extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? errorText;

  const TokenizedInput({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasError = errorText != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: TextStylePresets.label(
            color: colors.neutral.shade700,
          ),
        ),
        
        SizedBox(height: SpacingTokens.space2),
        
        // Input field
        Container(
          decoration: BoxDecoration(
            color: colors.surface.card,
            borderRadius: BorderRadius.circular(
              SemanticBorderRadius.input,
            ),
            border: Border.all(
              color: hasError 
                  ? colors.semantic.error.shade500 
                  : colors.neutral.shade300,
              width: BorderWidthTokens.thin,
            ),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStylePresets.body(
                color: colors.neutral.shade400,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: SpacingTokens.space4,
                vertical: SpacingTokens.space3,
              ),
            ),
            style: TextStylePresets.body(
              color: colors.neutral.shade900,
            ),
          ),
        ),
        
        // Error message
        if (hasError) ...[
          SizedBox(height: SpacingTokens.space1),
          Text(
            errorText!,
            style: TextStylePresets.caption(
              color: colors.semantic.error.shade500,
            ),
          ),
        ],
      ],
    );
  }
}

/// Example animated container using design tokens
class TokenizedAnimatedContainer extends StatefulWidget {
  final Widget child;

  const TokenizedAnimatedContainer({
    super.key,
    required this.child,
  });

  @override
  State<TokenizedAnimatedContainer> createState() => 
      _TokenizedAnimatedContainerState();
}

class _TokenizedAnimatedContainerState 
    extends State<TokenizedAnimatedContainer> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: SemanticAnimations.buttonHover,
        curve: SemanticAnimations.buttonHoverCurve,
        padding: EdgeInsets.all(SpacingTokens.space4),
        decoration: BoxDecoration(
          color: _isHovered 
              ? colors.primary.shade50 
              : colors.surface.card,
          borderRadius: BorderRadius.circular(
            BorderRadiusTokens.base,
          ),
          boxShadow: _isHovered 
              ? ShadowTokens.md 
              : ShadowTokens.sm,
        ),
        child: widget.child,
      ),
    );
  }
}

/// Example screen demonstrating token usage
class TokenUsageExampleScreen extends StatelessWidget {
  const TokenUsageExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return Scaffold(
      backgroundColor: colors.surface.background,
      appBar: AppBar(
        title: Text(
          'Design Token Examples',
          style: TextStylePresets.h5(
            color: colors.neutral.shade0,
          ),
        ),
        backgroundColor: colors.primary.shade500,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          SemanticSpacing.pagePaddingDesktop,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading
            Text(
              'Typography Examples',
              style: TextStylePresets.h2(
                color: colors.neutral.shade900,
              ),
            ),
            
            SizedBox(height: SpacingTokens.space6),
            
            // Typography samples
            Text(
              'Heading 1',
              style: TextStylePresets.h1(
                color: colors.neutral.shade900,
              ),
            ),
            Text(
              'Heading 2',
              style: TextStylePresets.h2(
                color: colors.neutral.shade900,
              ),
            ),
            Text(
              'Body text with normal weight',
              style: TextStylePresets.body(
                color: colors.neutral.shade700,
              ),
            ),
            Text(
              'Caption text',
              style: TextStylePresets.caption(
                color: colors.neutral.shade500,
              ),
            ),
            
            SizedBox(height: SpacingTokens.space12),
            
            // Button examples
            Text(
              'Button Examples',
              style: TextStylePresets.h3(
                color: colors.neutral.shade900,
              ),
            ),
            
            SizedBox(height: SpacingTokens.space4),
            
            Row(
              children: [
                TokenizedButton(
                  label: 'Primary Button',
                  onPressed: () {},
                ),
                SizedBox(width: SpacingTokens.space4),
                TokenizedButton(
                  label: 'Secondary Button',
                  isPrimary: false,
                  onPressed: () {},
                ),
              ],
            ),
            
            SizedBox(height: SpacingTokens.space12),
            
            // Card examples
            Text(
              'Card Examples',
              style: TextStylePresets.h3(
                color: colors.neutral.shade900,
              ),
            ),
            
            SizedBox(height: SpacingTokens.space4),
            
            TokenizedCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Card Title',
                    style: TextStylePresets.h5(
                      color: colors.neutral.shade900,
                    ),
                  ),
                  SizedBox(height: SpacingTokens.space2),
                  Text(
                    'This is a card using design tokens for consistent styling.',
                    style: TextStylePresets.body(
                      color: colors.neutral.shade700,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: SpacingTokens.space12),
            
            // Input examples
            Text(
              'Input Examples',
              style: TextStylePresets.h3(
                color: colors.neutral.shade900,
              ),
            ),
            
            SizedBox(height: SpacingTokens.space4),
            
            const TokenizedInput(
              label: 'Email Address',
              hint: 'Enter your email',
            ),
            
            SizedBox(height: SpacingTokens.space4),
            
            const TokenizedInput(
              label: 'Password',
              hint: 'Enter your password',
              errorText: 'Password must be at least 8 characters',
            ),
            
            SizedBox(height: SpacingTokens.space12),
            
            // Animated container example
            Text(
              'Hover Animation Example',
              style: TextStylePresets.h3(
                color: colors.neutral.shade900,
              ),
            ),
            
            SizedBox(height: SpacingTokens.space4),
            
            TokenizedAnimatedContainer(
              child: Text(
                'Hover over me!',
                style: TextStylePresets.body(
                  color: colors.neutral.shade900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
