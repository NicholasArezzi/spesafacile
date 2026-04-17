const CACHE_NAME = 'spesaoggi-v6';
const STATIC_ASSETS = [
  '/',
  '/index.html',
  '/config.js',
  '/manifest.json',
  '/icon-72.png',
  '/icon-96.png',
  '/icon-128.png',
  '/icon-144.png',
  '/icon-152.png',
  '/icon-192.png',
  '/icon-384.png',
  '/icon-512.png',
  '/icon-1024.png',
  '/og-image.png',
  '/screenshot-mobile.png',
  '/screenshot-tablet.png',
  '/privacy.html',
  '/casa.json',
  '/products.json',
  '/recipes.json',
  '/.well-known/assetlinks.json'
];

self.addEventListener('install', function(event) {
  event.waitUntil(
    caches.open(CACHE_NAME).then(function(cache) {
      return cache.addAll(STATIC_ASSETS);
    }).then(function() {
      return self.skipWaiting();
    }).catch(function(err) {
      console.warn('[SW] install cache failed:', err);
      return self.skipWaiting();
    })
  );
});

self.addEventListener('activate', function(event) {
  event.waitUntil(
    caches.keys().then(function(keys) {
      return Promise.allSettled(
        keys.filter(function(key) { return key !== CACHE_NAME; })
            .map(function(key) { return caches.delete(key); })
      );
    })
  );
  self.clients.claim();
});

// File JSON dati: network-first per ricevere sempre aggiornamenti
var DATA_FILES = ['/products.json', '/recipes.json', '/casa.json'];

self.addEventListener('fetch', function(event) {
  var url = new URL(event.request.url);

  // Non cachare chiamate API esterne
  if (url.origin !== location.origin) {
    event.respondWith(
      fetch(event.request).catch(function() {
        return new Response('', { status: 503 });
      })
    );
    return;
  }

  // Network-first per i file JSON dati (aggiornamenti immediati)
  if (DATA_FILES.indexOf(url.pathname) !== -1) {
    event.respondWith(
      fetch(event.request).then(function(response) {
        if (!response || response.status !== 200) return response;
        var clone = response.clone();
        caches.open(CACHE_NAME).then(function(cache) {
          cache.put(event.request, clone);
        }).catch(function(){});
        return response;
      }).catch(function() {
        return caches.match(event.request);
      })
    );
    return;
  }

  // Cache-first per gli altri asset statici
  event.respondWith(
    caches.match(event.request).then(function(cached) {
      if (cached) return cached;
      return fetch(event.request).then(function(response) {
        if (!response || response.status !== 200) return response;
        var clone = response.clone();
        caches.open(CACHE_NAME).then(function(cache) {
          cache.put(event.request, clone);
        }).catch(function(e) {
          console.warn('[SW] cache write failed:', e);
        });
        return response;
      }).catch(function() {
        // Fallback offline: restituisce index.html per navigazione
        if (event.request.mode === 'navigate') {
          return caches.match('/index.html');
        }
        return new Response('', { status: 503 });
      });
    })
  );
});
