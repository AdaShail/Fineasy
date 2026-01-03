# Progressive Web App (PWA) Configuration

This directory contains documentation and utilities for FinEasy's Progressive Web App capabilities.

## Overview

FinEasy is configured as a Progressive Web App (PWA), providing:

- **Offline Functionality**: Continue working without internet connection
- **Installable**: Add to home screen like a native app
- **Fast Loading**: Cached assets for instant loading
- **Background Sync**: Automatic data sync when connection returns
- **Push Notifications**: Stay updated with business events

## Components

### 1. Web Manifest (`web/manifest.json`)

Defines the PWA metadata:
- App name and description
- Icons (192x192, 512x512, maskable)
- Theme colors
- Display mode (standalone)
- App shortcuts (Dashboard, Create Invoice, Quick Transaction)
- Categories and language settings

### 2. Service Worker (`web/sw.js`)

Handles offline functionality:
- **Caching Strategy**: Cache-first for assets, network-first for API calls
- **Offline Fallback**: Shows offline.html when no connection
- **Background Sync**: Queues operations and syncs when online
- **Cache Management**: Automatic cleanup of old caches
- **Push Notifications**: Handles push notification events

### 3. Offline Page (`web/offline.html`)

Beautiful offline fallback page that:
- Informs users they're offline
- Shows connection status
- Provides retry functionality
- Lists available offline features
- Auto-reloads when connection returns

### 4. PWA Service (`lib/services/pwa_service.dart`)

Flutter service for PWA management:
- Install prompt handling
- Offline queue management
- Online/offline status monitoring
- Background sync coordination
- Service worker communication

### 5. UI Components (`lib/widgets/pwa_install_prompt.dart`)

Flutter widgets for PWA features:
- **PWAInstallPrompt**: Full install prompt with description
- **PWAInstallBanner**: Compact banner for mobile
- **OfflineIndicator**: Shows offline status and pending syncs

## Usage

### Initialize PWA Service

In your app initialization:

```dart
import 'package:fineasy/services/pwa_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize PWA service
  if (kIsWeb) {
    await PWAService().initialize();
  }
  
  runApp(MyApp());
}
```

### Show Install Prompt

Add to your main screen:

```dart
import 'package:fineasy/widgets/pwa_install_prompt.dart';

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        // Show install prompt at top
        PWAInstallPrompt(),
        
        // Or use compact banner
        PWAInstallBanner(),
        
        // Your content
        Expanded(child: YourContent()),
      ],
    ),
  );
}
```

### Show Offline Indicator

Add to your app bar or top of screen:

```dart
import 'package:fineasy/widgets/pwa_install_prompt.dart';

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        OfflineIndicator(),
        Expanded(child: YourContent()),
      ],
    ),
  );
}
```

### Queue Operations for Offline Sync

When making API calls that might fail offline:

```dart
import 'package:fineasy/services/pwa_service.dart';

Future<void> createInvoice(Invoice invoice) async {
  try {
    // Try to create invoice
    await api.createInvoice(invoice);
  } catch (e) {
    // If offline, queue for later sync
    if (!PWAService().isOnline) {
      await PWAService().queueOperation(
        QueuedOperation(
          id: uuid.v4(),
          type: 'create_invoice',
          url: '/api/invoices',
          method: 'POST',
          body: jsonEncode(invoice.toJson()),
        ),
      );
      
      // Show user that operation is queued
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invoice queued for sync')),
      );
    }
  }
}
```

### Listen to Online/Offline Status

```dart
import 'package:fineasy/services/pwa_service.dart';

@override
void initState() {
  super.initState();
  
  PWAService().onlineStatus.listen((isOnline) {
    if (isOnline) {
      print('Connection restored');
      // Refresh data
    } else {
      print('Connection lost');
      // Show offline UI
    }
  });
}
```

### Monitor Sync Status

```dart
import 'package:fineasy/services/pwa_service.dart';

@override
void initState() {
  super.initState();
  
  PWAService().syncStatus.listen((status) {
    print('Queued operations: ${status.queuedCount}');
    print('Last sync: ${status.lastSyncTime}');
    
    if (status.syncedCount != null) {
      print('Synced ${status.syncedCount} operations');
    }
  });
}
```

## Service Worker Caching Strategy

### Cache-First (Static Assets)
- HTML, CSS, JavaScript files
- Images and icons
- Fonts
- Manifest

### Network-First (API Calls)
- Supabase API requests
- Real-time data
- User-specific content

### Offline Fallback
- Navigation requests → offline.html
- Failed requests → cached version if available

## Testing PWA Features

### Test Offline Functionality

1. Open DevTools → Network tab
2. Select "Offline" from throttling dropdown
3. Reload page → should show offline.html
4. Navigate app → should work with cached data

### Test Install Prompt

1. Open in Chrome/Edge (desktop or mobile)
2. Look for install prompt in address bar
3. Or use DevTools → Application → Manifest → "Add to home screen"

### Test Service Worker

1. Open DevTools → Application → Service Workers
2. Check registration status
3. View cached files in Cache Storage
4. Test "Update on reload" and "Bypass for network"

### Test Background Sync

1. Go offline
2. Perform actions (create invoice, etc.)
3. Go back online
4. Check that operations sync automatically

## Browser Support

### Full PWA Support
- Chrome 67+ (Desktop & Mobile)
- Edge 79+
- Samsung Internet 8.2+
- Opera 54+

### Partial Support
- Safari 11.1+ (iOS/macOS) - No background sync
- Firefox 79+ - No install prompt

### Fallback
- All modern browsers work as regular web app
- PWA features gracefully degrade

## Deployment Checklist

- [ ] Verify manifest.json is accessible at `/manifest.json`
- [ ] Verify sw.js is accessible at `/sw.js`
- [ ] Verify offline.html is accessible at `/offline.html`
- [ ] All icons are present in `/icons/` directory
- [ ] HTTPS is enabled (required for PWA)
- [ ] Service worker registers successfully
- [ ] Install prompt appears on supported browsers
- [ ] Offline functionality works
- [ ] Background sync works when connection returns

## Troubleshooting

### Install Prompt Not Showing

- Check that app is served over HTTPS
- Verify manifest.json is valid
- Check that service worker is registered
- Ensure app meets PWA criteria (has icons, name, etc.)
- Try clearing browser cache and reloading

### Service Worker Not Registering

- Check browser console for errors
- Verify sw.js path is correct
- Ensure HTTPS is enabled
- Check that service worker scope is correct

### Offline Mode Not Working

- Verify service worker is active
- Check cache storage in DevTools
- Ensure offline.html exists
- Test with DevTools offline mode

### Background Sync Not Working

- Background sync requires HTTPS
- Not supported in all browsers (Safari, Firefox)
- Check service worker registration
- Verify sync event is registered

## Performance Optimization

### Reduce Cache Size
- Only cache essential assets
- Set cache expiration times
- Clean up old caches on activate

### Optimize Service Worker
- Use efficient caching strategies
- Minimize service worker code
- Avoid blocking operations

### Improve Load Time
- Precache critical assets
- Use cache-first for static content
- Implement lazy loading

## Security Considerations

- Service workers only work over HTTPS
- Validate all cached data
- Implement proper authentication
- Clear sensitive data on logout
- Use secure headers

## Future Enhancements

- [ ] Implement IndexedDB for offline data storage
- [ ] Add periodic background sync
- [ ] Implement push notifications
- [ ] Add app shortcuts for common actions
- [ ] Implement share target API
- [ ] Add file handling capabilities
- [ ] Implement badging API for notifications

## Resources

- [MDN PWA Guide](https://developer.mozilla.org/en-US/docs/Web/Progressive_web_apps)
- [Google PWA Checklist](https://web.dev/pwa-checklist/)
- [Service Worker API](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API)
- [Web App Manifest](https://developer.mozilla.org/en-US/docs/Web/Manifest)
- [Background Sync API](https://developer.mozilla.org/en-US/docs/Web/API/Background_Synchronization_API)
