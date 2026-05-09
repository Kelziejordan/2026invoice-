#!/bin/bash

set -e

echo "Creating invoice-app directory..."
mkdir -p invoice-app/icons
cd invoice-app

echo "Writing index.html..."
cat > index.html << 'EOF'
[PASTE THE FULL index.html CONTENT HERE]
EOF

echo "Writing manifest.webmanifest..."
cat > manifest.webmanifest << 'EOF'
{
  "name": "Simple Invoice Generator",
  "short_name": "Invoicer",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#4376df",
  "icons": [
    {
      "src": "icons/icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
EOF

echo "Writing service worker..."
cat > sw.js << 'EOF'
const CACHE_NAME = "invoice-pwa-v1";
const ASSETS = [
  "./",
  "./index.html",
  "./manifest.webmanifest"
];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(ASSETS))
  );
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys.filter((key) => key !== CACHE_NAME).map((key) => caches.delete(key))
      )
    )
  );
});

self.addEventListener("fetch", (event) => {
  if (event.request.method !== "GET") return;
  event.respondWith(
    caches.match(event.request).then((cached) => {
      return (
        cached ||
        fetch(event.request).catch(() => caches.match("./index.html"))
      );
    })
  );
});
EOF

echo "Creating placeholder icons..."
convert -size 192x192 xc:#4376df icons/icon-192.png
convert -size 512x512 xc:#4376df icons/icon-512.png

echo "Initializing Git repository..."
git init
git add .
git commit -m "Initial commit: Invoice Generator PWA"

echo "Done!"
echo "To push to GitHub:"
echo "  git remote add origin <YOUR_REPO_URL>"
echo "  git branch -M main"
echo "  git push -u origin main"
