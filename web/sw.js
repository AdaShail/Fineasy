// FinEasy Service Worker
// Provides offline functionality, caching, and background sync

const CACHE_NAME = 'fineasy-v1';
const RUNTIME_CACHE = 'fineasy-runtime-v1';
const DATA_CACHE = 'fineasy-data-v1';

// Assets to cache on install
const PRECACHE_ASSETS = [
  '/',
  '/index.html',
  '/manifest.json',
  '/favicon.png',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
  '/offline.html',
];

// Install event - cache essential assets
self.addEventListener('install', (event) => {
  console.log('[ServiceWorker] Install');
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      console.log('[ServiceWorker] Pre-caching offline page and assets');
      return cache.addAll(PRECACHE_ASSETS).catch((error) => {
        console.error('[ServiceWorker] Pre-cache failed:', error);
        // Continue even if some assets fail to cache
        return Promise.resolve();
      });
    })
  );
  self.skipWaiting();
});

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
  console.log('[ServiceWorker] Activate');
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME && 
              cacheName !== RUNTIME_CACHE && 
              cacheName !== DATA_CACHE) {
            console.log('[ServiceWorker] Removing old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
  self.clients.claim();
});

// Fetch event - serve from cache, fallback to network
self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // Skip cross-origin requests
  if (url.origin !== location.origin) {
    return;
  }

  // Handle API requests differently
  if (url.pathname.includes('/api/') || url.pathname.includes('supabase')) {
    event.respondWith(networkFirstStrategy(request));
    return;
  }

  // Handle navigation requests
  if (request.mode === 'navigate') {
    event.respondWith(
      fetch(request)
        .catch(() => {
          return caches.match('/offline.html');
        })
    );
    return;
  }

  // Handle other requests with cache-first strategy
  event.respondWith(cacheFirstStrategy(request));
});

// Cache-first strategy: try cache, fallback to network
async function cacheFirstStrategy(request) {
  const cache = await caches.open(RUNTIME_CACHE);
  const cachedResponse = await cache.match(request);
  
  if (cachedResponse) {
    return cachedResponse;
  }

  try {
    const networkResponse = await fetch(request);
    
    // Cache successful responses
    if (networkResponse.ok) {
      cache.put(request, networkResponse.clone());
    }
    
    return networkResponse;
  } catch (error) {
    console.error('[ServiceWorker] Fetch failed:', error);
    
    // Return offline page for navigation requests
    if (request.mode === 'navigate') {
      return caches.match('/offline.html');
    }
    
    throw error;
  }
}

// Network-first strategy: try network, fallback to cache
async function networkFirstStrategy(request) {
  const cache = await caches.open(DATA_CACHE);
  
  try {
    const networkResponse = await fetch(request);
    
    // Cache successful API responses
    if (networkResponse.ok) {
      cache.put(request, networkResponse.clone());
    }
    
    return networkResponse;
  } catch (error) {
    console.log('[ServiceWorker] Network request failed, trying cache:', error);
    const cachedResponse = await cache.match(request);
    
    if (cachedResponse) {
      return cachedResponse;
    }
    
    throw error;
  }
}

// Background sync for queued operations
self.addEventListener('sync', (event) => {
  console.log('[ServiceWorker] Background sync:', event.tag);
  
  if (event.tag === 'sync-data') {
    event.waitUntil(syncQueuedData());
  }
});

// Sync queued data when connection is restored
async function syncQueuedData() {
  try {
    // Get queued operations from IndexedDB or cache
    const queuedOperations = await getQueuedOperations();
    
    if (queuedOperations.length === 0) {
      console.log('[ServiceWorker] No queued operations to sync');
      return;
    }

    console.log(`[ServiceWorker] Syncing ${queuedOperations.length} queued operations`);
    
    // Process each queued operation
    for (const operation of queuedOperations) {
      try {
        await fetch(operation.url, {
          method: operation.method,
          headers: operation.headers,
          body: operation.body,
        });
        
        // Remove from queue after successful sync
        await removeFromQueue(operation.id);
      } catch (error) {
        console.error('[ServiceWorker] Failed to sync operation:', error);
      }
    }
    
    // Notify clients that sync is complete
    const clients = await self.clients.matchAll();
    clients.forEach((client) => {
      client.postMessage({
        type: 'SYNC_COMPLETE',
        count: queuedOperations.length,
      });
    });
  } catch (error) {
    console.error('[ServiceWorker] Background sync failed:', error);
  }
}

// Helper function to get queued operations
async function getQueuedOperations() {
  // This would typically read from IndexedDB
  // For now, return empty array
  return [];
}

// Helper function to remove operation from queue
async function removeFromQueue(operationId) {
  // This would typically remove from IndexedDB
  console.log('[ServiceWorker] Removed operation from queue:', operationId);
}

// Handle messages from clients
self.addEventListener('message', (event) => {
  console.log('[ServiceWorker] Message received:', event.data);
  
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
  
  if (event.data && event.data.type === 'QUEUE_OPERATION') {
    // Queue operation for background sync
    queueOperation(event.data.operation).then(() => {
      event.ports[0].postMessage({ success: true });
    });
  }
  
  if (event.data && event.data.type === 'CLEAR_CACHE') {
    clearAllCaches().then(() => {
      event.ports[0].postMessage({ success: true });
    });
  }
});

// Queue an operation for later sync
async function queueOperation(operation) {
  // This would typically write to IndexedDB
  console.log('[ServiceWorker] Queued operation:', operation);
  
  // Register for background sync
  if ('sync' in self.registration) {
    await self.registration.sync.register('sync-data');
  }
}

// Clear all caches
async function clearAllCaches() {
  const cacheNames = await caches.keys();
  await Promise.all(cacheNames.map((name) => caches.delete(name)));
  console.log('[ServiceWorker] All caches cleared');
}

// Push notification handler
self.addEventListener('push', (event) => {
  console.log('[ServiceWorker] Push notification received');
  
  const options = {
    body: event.data ? event.data.text() : 'New notification from FinEasy',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    vibrate: [200, 100, 200],
    data: {
      dateOfArrival: Date.now(),
      primaryKey: 1,
    },
    actions: [
      {
        action: 'explore',
        title: 'View',
      },
      {
        action: 'close',
        title: 'Close',
      },
    ],
  };

  event.waitUntil(
    self.registration.showNotification('FinEasy', options)
  );
});

// Notification click handler
self.addEventListener('notificationclick', (event) => {
  console.log('[ServiceWorker] Notification click:', event.action);
  event.notification.close();

  if (event.action === 'explore') {
    event.waitUntil(
      clients.openWindow('/')
    );
  }
});

console.log('[ServiceWorker] Loaded');
