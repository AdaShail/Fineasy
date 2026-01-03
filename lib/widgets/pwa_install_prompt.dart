import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/pwa_service.dart';

/// Widget that displays a prompt to install the PWA
class PWAInstallPrompt extends StatefulWidget {
  const PWAInstallPrompt({super.key});

  @override
  State<PWAInstallPrompt> createState() => _PWAInstallPromptState();
}

class _PWAInstallPromptState extends State<PWAInstallPrompt> {
  final _pwaService = PWAService();
  bool _showPrompt = false;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _checkInstallPrompt();
    }
  }

  void _checkInstallPrompt() {
    // Check if install prompt is available
    _pwaService.installPromptAvailable.listen((available) {
      if (mounted && !_dismissed) {
        setState(() {
          _showPrompt = available;
        });
      }
    });

    // Initial check
    if (_pwaService.isInstallPromptAvailable && !_dismissed) {
      setState(() {
        _showPrompt = true;
      });
    }
  }

  Future<void> _handleInstall() async {
    final success = await _pwaService.showInstallPrompt();
    if (success && mounted) {
      setState(() {
        _showPrompt = false;
        _dismissed = true;
      });
    }
  }

  void _handleDismiss() {
    setState(() {
      _showPrompt = false;
      _dismissed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || !_showPrompt) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.download_rounded,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Install FinEasy',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Install our app for quick access and offline support',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              
              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: _handleDismiss,
                    child: const Text('Not now'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _handleInstall,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: const Text('Install'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact version of the install prompt for smaller screens
class PWAInstallBanner extends StatefulWidget {
  const PWAInstallBanner({super.key});

  @override
  State<PWAInstallBanner> createState() => _PWAInstallBannerState();
}

class _PWAInstallBannerState extends State<PWAInstallBanner> {
  final _pwaService = PWAService();
  bool _showBanner = false;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _checkInstallPrompt();
    }
  }

  void _checkInstallPrompt() {
    _pwaService.installPromptAvailable.listen((available) {
      if (mounted && !_dismissed) {
        setState(() {
          _showBanner = available;
        });
      }
    });

    if (_pwaService.isInstallPromptAvailable && !_dismissed) {
      setState(() {
        _showBanner = true;
      });
    }
  }

  Future<void> _handleInstall() async {
    final success = await _pwaService.showInstallPrompt();
    if (success && mounted) {
      setState(() {
        _showBanner = false;
        _dismissed = true;
      });
    }
  }

  void _handleDismiss() {
    setState(() {
      _showBanner = false;
      _dismissed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || !_showBanner) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Theme.of(context).colorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.download_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Install FinEasy for offline access',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          TextButton(
            onPressed: _handleInstall,
            child: const Text('Install'),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: _handleDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

/// Offline status indicator
class OfflineIndicator extends StatefulWidget {
  const OfflineIndicator({super.key});

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> {
  final _pwaService = PWAService();
  bool _isOnline = true;
  int _queuedCount = 0;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _setupListeners();
    }
  }

  void _setupListeners() {
    _pwaService.onlineStatus.listen((online) {
      if (mounted) {
        setState(() {
          _isOnline = online;
        });
      }
    });

    _pwaService.syncStatus.listen((status) {
      if (mounted) {
        setState(() {
          _queuedCount = status.queuedCount;
        });
      }
    });

    _isOnline = _pwaService.isOnline;
    _queuedCount = _pwaService.queuedOperationsCount;
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || _isOnline) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        border: Border(
          bottom: BorderSide(
            color: Colors.orange.shade300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 16,
            color: Colors.orange.shade900,
          ),
          const SizedBox(width: 8),
          Text(
            _queuedCount > 0
                ? 'Offline - $_queuedCount changes pending'
                : 'You are offline',
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange.shade900,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
