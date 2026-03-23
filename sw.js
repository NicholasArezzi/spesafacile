const CACHE_NAME = 'spesaoggi-v2';
const STATIC_ASSETS = [
  '/',
  '/index.html',
  '/config.js',
  '/manifest.json',
  '/icon-192.png',
  '/icon-512.png',
  '/og-image.png',
  '/casa.json',
  '/products.json',
  '/recipes.json'
];

self.addEventListener('install', function(event) {
  event.waitUntil(
    caches.open(CACHE_NAME).then(function(cache) {
      return cache.addAll(STATIC_ASSETS);
    })
  );
  self.skipWaiting();
});

self.addEventListener('activate', function(event) {
  event.waitUntil(
    caches.keys().then(function(keys) {
      return Promise.all(
        keys.filter(function(key) { return key !== CACHE_NAME; })
            .map(function(key) { return caches.delete(key); })
      );
    })
  );
  self.clients.claim();
});

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

  // Cache-first per gli asset statici
  event.respondWith(
    caches.match(event.request).then(function(cached) {
      if (cached) return cached;
      return fetch(event.request).then(function(response) {
        if (!response || response.status !== 200) return response;
        var clone = response.clone();
        caches.open(CACHE_NAME).then(function(cache) {
          cache.put(event.request, clone);
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
