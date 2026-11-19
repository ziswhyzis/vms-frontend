#!/usr/bin/env bash
# Netlify build hook: installs the pinned Flutter SDK when the build image
# does not provide one, then produces the release web bundle.
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.50.0}"
FLUTTER_HOME="${HOME}/flutter"

if ! command -v flutter >/dev/null 2>&1; then
  if [ ! -d "${FLUTTER_HOME}" ]; then
    echo "Installing Flutter ${FLUTTER_VERSION}..."
    curl -fsSL -o /tmp/flutter.tar.xz \
      "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
    tar -xf /tmp/flutter.tar.xz -C "${HOME}"
    git config --global --add safe.directory "${FLUTTER_HOME}" || true
  fi
  export PATH="${FLUTTER_HOME}/bin:${PATH}"
fi

flutter config --enable-web
flutter pub get
flutter build web --release --dart-define=API_BASE_URL="${API_BASE_URL}"
