import 'package:flutter/material.dart';
import 'web_toast.dart';

/// Toast notification data
class ToastData {
  final String id;
  final WebToastType type;
  final String message;
  final String? description;
  final int duration;
  final WebToastAction? action;

  ToastData({
    required this.id,
    required this.type,
    required this.message,
    this.description,
    this.duration = 5000,
    this.action,
  });
}

/// Web Toast Service
/// 
/// A service for programmatically displaying and managing toast notifications.
/// Maintains a queue of toasts and handles their lifecycle.
/// 
/// Example:
/// ```dart
/// final toastService = WebToastService();
/// 
/// toastService.showSuccess(
///   message: 'Changes saved',
///   description: 'Your changes have been saved successfully',
/// );
/// 
/// toastService.showError(
///   message: 'Failed to save',
///   description: 'Please try again',
/// );
/// ```
class WebToastService extends ChangeNotifier {
  final List<ToastData> _toasts = [];
  int _nextId = 0;

  List<ToastData> get toasts => List.unmodifiable(_toasts);

  /// Show a toast notification
  String show({
    required WebToastType type,
    required String message,
    String? description,
    int? duration,
    WebToastAction? action,
  }) {
    final id = 'toast-${_nextId++}';
    
    // Determine duration based on type if not specified
    int effectiveDuration = duration ?? _getDefaultDuration(type);

    final toast = ToastData(
      id: id,
      type: type,
      message: message,
      description: description,
      duration: effectiveDuration,
      action: action,
    );

    _toasts.add(toast);
    notifyListeners();

    return id;
  }

  /// Show a success toast
  String showSuccess({
    required String message,
    String? description,
    int? duration,
    WebToastAction? action,
  }) {
    return show(
      type: WebToastType.success,
      message: message,
      description: description,
      duration: duration,
      action: action,
    );
  }

  /// Show an error toast (persists until manually dismissed)
  String showError({
    required String message,
    String? description,
    WebToastAction? action,
  }) {
    return show(
      type: WebToastType.error,
      message: message,
      description: description,
      duration: 0, // Error toasts don't auto-dismiss
      action: action,
    );
  }

  /// Show a warning toast
  String showWarning({
    required String message,
    String? description,
    int? duration,
    WebToastAction? action,
  }) {
    return show(
      type: WebToastType.warning,
      message: message,
      description: description,
      duration: duration,
      action: action,
    );
  }

  /// Show an info toast
  String showInfo({
    required String message,
    String? description,
    int? duration,
    WebToastAction? action,
  }) {
    return show(
      type: WebToastType.info,
      message: message,
      description: description,
      duration: duration,
      action: action,
    );
  }

  /// Dismiss a specific toast by ID
  void dismiss(String id) {
    _toasts.removeWhere((toast) => toast.id == id);
    notifyListeners();
  }

  /// Dismiss all toasts
  void dismissAll() {
    _toasts.clear();
    notifyListeners();
  }

  int _getDefaultDuration(WebToastType type) {
    switch (type) {
      case WebToastType.success:
      case WebToastType.info:
        return 5000; // 5 seconds
      case WebToastType.warning:
        return 6000; // 6 seconds
      case WebToastType.error:
        return 0; // Manual dismiss only
    }
  }
}

/// Toast Container Widget
/// 
/// A widget that displays toasts from the WebToastService.
/// Should be placed at the root of your app to display toasts globally.
/// 
/// Example:
/// ```dart
/// MaterialApp(
///   home: WebToastContainer(
///     toastService: toastService,
///     child: YourApp(),
///   ),
/// )
/// ```
class WebToastContainer extends StatelessWidget {
  final WebToastService toastService;
  final Widget child;
  final Alignment alignment;

  const WebToastContainer({
    Key? key,
    required this.toastService,
    required this.child,
    this.alignment = Alignment.topRight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: Align(
            alignment: alignment,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AnimatedBuilder(
                animation: toastService,
                builder: (context, _) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: toastService.toasts.map((toast) {
                      return WebToast(
                        key: ValueKey(toast.id),
                        id: toast.id,
                        type: toast.type,
                        message: toast.message,
                        description: toast.description,
                        duration: toast.duration,
                        action: toast.action,
                        onDismiss: toastService.dismiss,
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
