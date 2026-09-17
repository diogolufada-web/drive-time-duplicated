#!/usr/bin/env bash
# Drive Time — script para Mac (TestFlight / App Store)
# Uso: ./scripts/mac_ios_build.sh prep|run|ipa|doctor

set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

cmd="${1:-prep}"

echo "==> Drive Time iOS build (Mac)"
echo "    Root: $ROOT"
echo "    Version: $(grep '^version:' pubspec.yaml | awk '{print $2}')"

doctor() {
  flutter doctor -v
  xcodebuild -version
  pod --version
}

prep() {
  flutter pub get
  cd ios
  pod install
  cd ..
  echo ""
  echo "OK. Abre Xcode:"
  echo "  open ios/Runner.xcworkspace"
  echo ""
  echo "Signing: Runner → Signing & Capabilities → Team + pt.drivetime.app"
}

run_release() {
  prep
  flutter devices
  echo "A instalar no dispositivo ligado (release)..."
  flutter run --release
}

ipa() {
  prep
  flutter build ipa --release
  echo ""
  echo "IPA gerado em: $ROOT/build/ios/ipa/"
  ls -la "$ROOT/build/ios/ipa/" 2>/dev/null || true
  echo ""
  echo "Upload: Xcode Organizer ou app Transporter (Mac App Store)"
}

case "$cmd" in
  doctor) doctor ;;
  prep)   prep ;;
  run)    run_release ;;
  ipa)    ipa ;;
  *)
    echo "Comandos: doctor | prep | run | ipa"
    exit 1
    ;;
esac
