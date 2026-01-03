import 'package:flutter/material.dart';
import '../services/network_connectivity_service.dart';

/// Widget that displays an offline indicator when network is unavailable
class OfflineIndicator extends StatefulWidget {
  final Widget child;
  final bool showBanner;
  final Color? bannerColor;
  final String? customMessage;

  const OfflineIndicator({
    super.key,
    required this.child,
    this.showBanner = true,
    this.bannerColor,
    this.customMessage,
  });

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> with SingleTickerProviderStateMixin {
  final _connectivityService = NetworkConnectivityService();
  bool _isOnline = true;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _isOnline = _connectivityService.isOnline;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _connectivityService.connectivityStream.listen((isOnline) {
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
          if (!isOnline) {
            _animationController.forward();
          } else {
            _animationController.reverse();
          }
        });
      }
    });

    if (!_isOnline) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showBanner) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        if (!_isOnline)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(_animation),
              child: _buildOfflineBanner(context),
            ),
          ),
      ],
    );
  }

  Widget _buildOfflineBanner(BuildContext context) {
    return Material(
      color: widget.bannerColor ?? Colors.red.shade700,
      elevation: 4,
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(
                Icons.cloud_off,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.customMessage ?? 'No internet connection',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await _connectivityService.checkConnectivity();
                },
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact offline indicator for smaller spaces
class CompactOfflineIndicator extends StatelessWidget {
  final NetworkConnectivityService _connectivityService = NetworkConnectivityService();

  CompactOfflineIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _connectivityService.connectivityStream,
      initialData: _connectivityService.isOnline,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;

        if (isOnline) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.shade700,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.cloud_off,
                color: Colors.white,
                size: 14,
              ),
              SizedBox(width: 4),
              Text(
                'Offline',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Connection status widget with detailed information
class ConnectionStatusWidget extends StatelessWidget {
  final NetworkConnectivityService _connectivityService = NetworkConnectivityService();

  ConnectionStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _connectivityService.connectivityStream,
      initialData: _connectivityService.isOnline,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      isOnline ? Icons.cloud_done : Icons.cloud_off,
                      color: isOnline ? Colors.green : Colors.red,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isOnline ? 'Connected' : 'Offline',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            isOnline
                                ? 'Your connection is active'
                                : 'No internet connection available',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (!isOnline) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Some features may be limited while offline. Your changes will sync when connection is restored.',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await _connectivityService.checkConnectivity();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Check Connection'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
