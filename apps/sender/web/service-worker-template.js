'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

self.addEventListener("install", (event) => {
  self.skipWaiting();
  console.log("[event] install");
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", (event) => {
  console.log("[event] activate");
  event.waitUntil(
    (async () => {
      await clients.claim(); // Forces new SW to take over all clients immediately
      const cache = await caches.open(CACHE_NAME);

      // Cache all resources first
      await cache.addAll(
        RESOURCES.map((path) => new Request(path, { 'cache': 'reload' }))
      );

      // After caching all resources, fetch version.json and store in manifest
      try {
        const versionRequest = await fetch("version.json", { cache: "no-store" });
        if (versionRequest.ok) {
          const versionData = await versionRequest.json();

          // Store version in manifest
          const manifestCache = await caches.open(MANIFEST);
          await manifestCache.put("manifest", new Response(JSON.stringify({
            version: versionData.version
          }), { headers: { "Content-Type": "application/json" } }));

          console.log("[Service Worker] Initial version stored:", versionData.version);
        }
      } catch (error) {
        console.warn("[Service Worker] Failed to fetch initial version.json:", error);
      }
    })()
  );
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }

  const origin = self.location.origin;
  let key = event.request.url.substring(origin.length + 1);

  // Redirect URLs to the index.html
  if (key.indexOf('?') !== -1) {
    key = key.split('?')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }

  // ✅ Special case for version.json (Network First)
  if (key === "version.json") {
    event.respondWith(
      (async () => {
        try {
          const networkResponse = await fetch(event.request);
          const cache = await caches.open(CACHE_NAME);
          await cache.put(event.request, networkResponse.clone()); // Cache the latest version.json
          return networkResponse;
        } catch (error) {
          // If fetch fails, try fetching the cached version **ignoring query params**
          const cache = await caches.open(CACHE_NAME);
          const cachedResponse = await cache.match("version.json", { ignoreSearch: true });
          if (cachedResponse) {
            console.log("[Service Worker] Serving cached version.json");
            return cachedResponse;
          }
          console.warn("[Service Worker] No cached version.json found, returning empty {}");
          return new Response("{}", { headers: { "Content-Type": "application/json" } });
        }
      })()
    );
    return;
  }

  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES.includes(key)) {
    return;
  }

  event.respondWith(
    (async () => {
      const cache = await caches.open(CACHE_NAME);
      const cachedResponse = await cache.match(event.request, { ignoreSearch: true });

      if (cachedResponse) {
        return cachedResponse;
      }

      try {
        const networkResponse = await fetch(event.request);
        if (networkResponse && Boolean(networkResponse.ok)) {
          await cache.put(event.request, networkResponse.clone());
        }
        return networkResponse;
      } catch (error) {
        if (event.request.destination === 'document') {
          return await caches.match('index.html');
        }
        throw error; // Rethrow if we can't handle it
      }
    })()
  );
});

self.addEventListener('message', (event) => {
  if (event.data.type == 'reload') {
    console.log("[event] message");
    (async () => {
      await downloadOffline();
      checkForUpdates();
    })();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  const contentCache = await caches.open(CACHE_NAME);

  for (const path of RESOURCES) {
    try {
      // Check if the resource is already in the cache
      const existingResponse = await contentCache.match(path);
      if (existingResponse) {
        continue; // Skip this resource if it's already cached
      }

      // Fetch and cache the resource if it's not already cached
      const request = new Request(path, { cache: "reload" });
      const response = await fetch(request);
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      await contentCache.put(request, response.clone());
    } catch (error) {
      console.error(`[Service Worker] Failed to cache ${path}:`, error);
    }
  }
}

async function checkForUpdates() {
  try {
    const manifestCache = await caches.open(MANIFEST);
    const manifest = await manifestCache.match("manifest");

    let oldVersion = null;
    let newVersion = null;

    // Fetch latest version.json
    try {
      const versionRequest = await fetch("version.json", { cache: "no-store" });
      if (versionRequest.ok) {
        newVersion = await versionRequest.json();
      }
    } catch (error) {
      console.warn("[Service Worker] Failed to fetch version.json:", error);
      return
    }

    if (manifest) {
      const oldManifest = await manifest.json();
      oldVersion = oldManifest.version || null;
    }

    console.log(`Old version: ${oldVersion}, New version: ${newVersion?.version}`);

    if (oldVersion === newVersion?.version) {
      return;
    }

    console.log("New version detected! Updating cache...");

    // Download all resources first, then replace the cache
    const tempCache = await caches.open(TEMP);

    // Pre-download all resources to temp cache
    await Promise.all(RESOURCES.map(async (path) => {
      try {
        const request = new Request(path, { cache: "reload" });
        const response = await fetch(request);
        if (response.ok) {
          await tempCache.put(request, response.clone());
        }
      } catch (error) {
        console.error(`[Service Worker] Failed to fetch resource: ${path}`, error);
      }
    }));

    // Delete the main cache and recreate it
    await caches.delete(CACHE_NAME);
    const mainCache = await caches.open(CACHE_NAME);

    // Copy all resources from temp to main cache
    for (const request of await tempCache.keys()) {
      const response = await tempCache.match(request);
      if (response) {
        await mainCache.put(request, response);
      }
    }

    // Clean up the temp cache
    await caches.delete(TEMP);

    // Update the manifest with the new version
    await manifestCache.put("manifest", new Response(JSON.stringify({
      version: newVersion.version
    }), { headers: { "Content-Type": "application/json" } }));

    console.log("Updated to version:", newVersion.version);
  } catch (err) {
    console.error("Failed to update service worker:", err);
  }
}

/* ASSETS_PLACEHOLDER */