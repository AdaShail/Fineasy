# Platform Service Abstraction Layer

This directory contains the platform abstraction layer that provides a unified interface for operations that differ between web and mobile platforms.

## Overview

The platform service abstraction allows the application to run seamlessly on both web and mobile platforms by providing platform-specific implementations of common operations like file handling, sharing, clipboard access, and URL management.

## Architecture

```
┌─────────────────────────────────────┐
│      Application Code               │
│  (Platform-agnostic business logic) │
└─────────────┬───────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│     PlatformService Interface       │
│   (Abstract contract for all ops)   │
└─────────────┬───────────────────────┘
              │
      ┌───────┴────────┐
      ▼                ▼
┌──────────────┐  ┌──────────────┐
│    Web       │  │   Mobile     │
│ Platform     │  │  Platform    │
│  Service     │  │   Service    │
└──────────────┘  └──────────────┘
```

## Components

### 1. PlatformService (Abstract Interface)

Defines the contract for all platform-specific operations:

- `shareContent()` - Share text/content
- `downloadFile()` - Download/save files
- `openUrl()` - Open URLs
- `copyToClipboard()` - Copy text to clipboard
- `getFromClipboard()` - Read from clipboard
- `isFeatureAvailable()` - Check feature availability
- `getStoragePath()` - Get storage directory (mobile only)
- `hasInternetConnection()` - Check connectivity

### 2. WebPlatformService

Web-specific implementation using browser APIs:

- Uses `dart:html` for DOM manipulation
- Implements file downloads via Blob URLs
- Uses Clipboard API for copy/paste
- Opens URLs in new tabs
- Supports Web Share API when available

### 3. MobilePlatformService

Mobile-specific implementation using native APIs:

- Uses `share_plus` for native sharing
- Uses `path_provider` for file system access
- Uses `url_launcher` for opening URLs
- Uses Flutter's `Clipboard` for copy/paste
- Supports in-app browser views

### 4. PlatformDetector

Utility for detecting platform and device characteristics:

- `isWeb` - Check if running on web
- `isMobile` - Check if running on mobile
- `isDesktop()` - Check if desktop-sized screen
- `isTablet()` - Check if tablet-sized screen
- `getDeviceType()` - Get device type from screen width

### 5. PlatformServiceFactory

Factory for creating the appropriate service instance:

- Singleton pattern for service instance
- Conditional imports for platform-specific code
- Testable with dependency injection support

## Usage Examples

### Basic Usage

```dart
import 'package:fineasy/core/platform/platform.dart';

// Get the platform service
final platformService = PlatformServiceFactory.instance;

// Share content
await platformService.shareContent(
  'Check out this invoice!',
  subject: 'Invoice #123',
);

// Download a file
await platformService.downloadFile(
  pdfBytes,
  'invoice_123.pdf',
  mimeType: 'application/pdf',
);

// Open a URL
await platformService.openUrl(
  'https://example.com',
  inApp: true,
);

// Copy to clipboard
await platformService.copyToClipboard('Payment link: https://...');
```

### Platform Detection

```dart
import 'package:fineasy/core/platform/platform.dart';

// Check platform
if (PlatformDetector.isWeb) {
  // Web-specific UI
  return WebDashboard();
} else {
  // Mobile-specific UI
  return MobileDashboard();
}

// Check device type
final deviceType = PlatformDetector.getDeviceType(screenWidth);
switch (deviceType) {
  case DeviceType.mobile:
    return MobileLayout();
  case DeviceType.tablet:
    return TabletLayout();
  case DeviceType.desktop:
    return DesktopLayout();
}
```

### Feature Availability

```dart
import 'package:fineasy/core/platform/platform.dart';

final platformService = PlatformServiceFactory.instance;

// Check if native share is available
if (platformService.isFeatureAvailable(PlatformFeature.nativeShare)) {
  // Show share button
  IconButton(
    icon: Icon(Icons.share),
    onPressed: () => platformService.shareContent(content),
  );
}

// Check if service worker is available (PWA)
if (platformService.isFeatureAvailable(PlatformFeature.serviceWorker)) {
  // Enable offline mode
  await enableOfflineMode();
}
```

### Conditional Service Injection

```dart
import 'package:fineasy/core/platform/platform.dart';
import 'package:provider/provider.dart';

// In your app initialization
MultiProvider(
  providers: [
    Provider<PlatformService>(
      create: (_) => PlatformServiceFactory.instance,
    ),
    // Other providers...
  ],
  child: MyApp(),
);

// In your widgets
class InvoiceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final platformService = context.read<PlatformService>();
    
    return ElevatedButton(
      onPressed: () async {
        final pdf = await generateInvoicePdf();
        await platformService.downloadFile(
          pdf,
          'invoice.pdf',
          mimeType: 'application/pdf',
        );
      },
      child: Text('Download Invoice'),
    );
  }
}
```

## Testing

The platform service abstraction is designed to be testable:

```dart
import 'package:fineasy/core/platform/platform.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockPlatformService extends Mock implements PlatformService {}

void main() {
  setUp(() {
    // Set a mock instance for testing
    final mockService = MockPlatformService();
    PlatformServiceFactory.setInstance(mockService);
  });
  
  tearDown(() {
    // Reset after tests
    PlatformServiceFactory.reset();
  });
  
  test('should share content', () async {
    final service = PlatformServiceFactory.instance;
    when(service.shareContent(any)).thenAnswer((_) async {});
    
    await service.shareContent('Test content');
    
    verify(service.shareContent('Test content')).called(1);
  });
}
```

## Dependencies

### Web Platform
- `dart:html` - Browser DOM APIs
- `dart:js` - JavaScript interop

### Mobile Platform
- `share_plus` - Native sharing
- `path_provider` - File system access
- `url_launcher` - URL handling
- `flutter/services` - Clipboard access

## Best Practices

1. **Always use the factory**: Get service instances through `PlatformServiceFactory.instance`
2. **Check feature availability**: Use `isFeatureAvailable()` before using optional features
3. **Handle errors gracefully**: All methods may throw exceptions
4. **Test with mocks**: Use dependency injection for testing
5. **Keep platform-agnostic**: Business logic should not depend on platform details

## Future Enhancements

- Add support for native desktop platforms (Windows, macOS, Linux)
- Implement platform-specific analytics
- Add biometric authentication abstraction
- Support for platform-specific storage encryption
- Enhanced offline capabilities for web (IndexedDB)
