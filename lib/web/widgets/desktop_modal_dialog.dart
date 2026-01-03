import 'package:flutter/material.dart';

/// Desktop-optimized modal dialog sizes
enum DialogSize {
  small, // 400px
  medium, // 600px
  large, // 800px
  extraLarge, // 1000px
  fullScreen, // 90% of screen
}

/// Desktop-optimized modal dialog
class DesktopModalDialog extends StatelessWidget {
  final String? title;
  final Widget content;
  final List<Widget>? actions;
  final DialogSize size;
  final bool showCloseButton;
  final VoidCallback? onClose;
  final EdgeInsets? contentPadding;
  final bool dismissible;
  final Widget? leading;

  const DesktopModalDialog({
    super.key,
    this.title,
    required this.content,
    this.actions,
    this.size = DialogSize.medium,
    this.showCloseButton = true,
    this.onClose,
    this.contentPadding,
    this.dismissible = true,
    this.leading,
  });

  double _getWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    switch (size) {
      case DialogSize.small:
        return 400;
      case DialogSize.medium:
        return 600;
      case DialogSize.large:
        return 800;
      case DialogSize.extraLarge:
        return 1000;
      case DialogSize.fullScreen:
        return screenWidth * 0.9;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: _getWidth(context),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            if (title != null || showCloseButton)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: 12),
                    ],
                    if (title != null)
                      Expanded(
                        child: Text(
                          title!,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (showCloseButton)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: onClose ?? () => Navigator.of(context).pop(),
                        tooltip: 'Close',
                      ),
                  ],
                ),
              ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: contentPadding ??
                    const EdgeInsets.all(24),
                child: content,
              ),
            ),

            // Actions
            if (actions != null && actions!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                  border: Border(
                    top: BorderSide(color: theme.dividerColor),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!
                      .map((action) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: action,
                          ))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Show the dialog
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget content,
    List<Widget>? actions,
    DialogSize size = DialogSize.medium,
    bool showCloseButton = true,
    VoidCallback? onClose,
    EdgeInsets? contentPadding,
    bool dismissible = true,
    Widget? leading,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) => DesktopModalDialog(
        title: title,
        content: content,
        actions: actions,
        size: size,
        showCloseButton: showCloseButton,
        onClose: onClose,
        contentPadding: contentPadding,
        dismissible: dismissible,
        leading: leading,
      ),
    );
  }
}

/// Confirmation dialog for desktop
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Color? confirmColor;
  final IconData? icon;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.confirmColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DesktopModalDialog(
      title: title,
      size: DialogSize.small,
      leading: icon != null
          ? Icon(icon, color: confirmColor ?? theme.colorScheme.primary)
          : null,
      content: Text(
        message,
        style: theme.textTheme.bodyLarge,
      ),
      actions: [
        TextButton(
          onPressed: () {
            onCancel?.call();
            Navigator.of(context).pop(false);
          },
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm?.call();
            Navigator.of(context).pop(true);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor ?? theme.colorScheme.primary,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }

  /// Show confirmation dialog
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Color? confirmColor,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        confirmColor: confirmColor,
        icon: icon,
      ),
    );
    return result ?? false;
  }
}

/// Form dialog for desktop
class FormDialog extends StatefulWidget {
  final String title;
  final List<Widget> fields;
  final String submitText;
  final String cancelText;
  final Future<bool> Function()? onSubmit;
  final VoidCallback? onCancel;
  final GlobalKey<FormState>? formKey;
  final DialogSize size;

  const FormDialog({
    super.key,
    required this.title,
    required this.fields,
    this.submitText = 'Submit',
    this.cancelText = 'Cancel',
    this.onSubmit,
    this.onCancel,
    this.formKey,
    this.size = DialogSize.medium,
  });

  @override
  State<FormDialog> createState() => _FormDialogState();
}

class _FormDialogState extends State<FormDialog> {
  late final GlobalKey<FormState> _formKey;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _formKey = widget.formKey ?? GlobalKey<FormState>();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);

      try {
        final success = await widget.onSubmit?.call() ?? true;
        if (mounted && success) {
          Navigator.of(context).pop(true);
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DesktopModalDialog(
      title: widget.title,
      size: widget.size,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: widget.fields
              .map((field) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: field,
                  ))
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting
              ? null
              : () {
                  widget.onCancel?.call();
                  Navigator.of(context).pop(false);
                },
          child: Text(widget.cancelText),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _handleSubmit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.submitText),
        ),
      ],
    );
  }
}
