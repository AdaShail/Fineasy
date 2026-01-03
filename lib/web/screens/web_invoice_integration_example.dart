import 'package:flutter/material.dart';
import 'web_invoice_management_screen.dart';
import '../../core/platform/platform_detector.dart';

/// Example integration of web invoice management screen
/// This shows how to integrate the web invoice screen into your app navigation
class WebInvoiceIntegrationExample extends StatelessWidget {
  const WebInvoiceIntegrationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Management'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Check if we're on a desktop-sized screen
          if (PlatformDetector.isDesktop(constraints.maxWidth)) {
            // Show web-optimized invoice management
            return const WebInvoiceManagementScreen();
          } else {
            // Show message for mobile users
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.desktop_windows,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Desktop View Required',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'The advanced invoice management interface is optimized for desktop screens.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Navigate to mobile invoice list
                        Navigator.pushNamed(context, '/invoices/mobile');
                      },
                      child: const Text('Use Mobile View'),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

/// Example: Adding to app router
/// 
/// In your app_router.dart or main navigation:
/// 
/// ```dart
/// case '/invoices/web':
///   return const WebInvoiceManagementScreen();
/// 
/// case '/invoices':
///   // Auto-detect and route to appropriate view
///   return const WebInvoiceIntegrationExample();
/// ```

/// Example: Adding to web navigation sidebar
/// 
/// In your web_sidebar.dart:
/// 
/// ```dart
/// ListTile(
///   leading: const Icon(Icons.receipt_long),
///   title: const Text('Invoices'),
///   selected: currentRoute == '/invoices',
///   onTap: () {
///     Navigator.pushNamed(context, '/invoices');
///   },
/// ),
/// ```

/// Example: Direct navigation from anywhere
/// 
/// ```dart
/// // Navigate to web invoice management
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const WebInvoiceManagementScreen(),
///   ),
/// );
/// ```
