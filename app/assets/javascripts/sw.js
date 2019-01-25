const CURRENT_CACHE = '<%= Gitlab.version %>_<%= Gitlab.revision %>';

// eslint-disable-next-line no-restricted-globals
self.addEventListener('install', event => {
  event.waitUntil(caches.open(CURRENT_CACHE).then(cache => cache.addAll(['/-/offline'])));
});

// eslint-disable-next-line no-restricted-globals
self.addEventListener('activate', event => {
  event.waitUntil(
    caches
      .keys()
      .then(cacheNames =>
        Promise.all(
          cacheNames.map(cache =>
            cache !== CURRENT_CACHE ? caches.delete(cache) : Promise.resolve(),
          ),
        ),
      ),
  );
});

// eslint-disable-next-line no-restricted-globals
self.addEventListener('fetch', event => {
  const { request } = event;

  // We only want to intercept the GET requests for now
  if (request.method === 'GET') {
    event.respondWith(
      fetch(request).catch(() => (request.mode === 'navigate' ? caches.match('/-/offline') : null)),
    );
  }
});
