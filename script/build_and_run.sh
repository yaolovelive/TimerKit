#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT="$ROOT_DIR/Apps/Tact.xcodeproj"
DERIVED_DATA="$ROOT_DIR/DerivedData"
SCHEME="Tact"
CONFIGURATION="Debug"
APP_NAME="macOS"
APP_PATH="$DERIVED_DATA/Build/Products/$CONFIGURATION/$APP_NAME.app"

usage() {
  cat <<'USAGE'
Usage: script/build_and_run.sh [--run] [--verify]

Builds the macOS Tact target with project-local DerivedData.

Options:
  --run      Launch the freshly built app after building.
  --verify   Verify the app process is running after launch.
USAGE
}

should_run=0
should_verify=0

for arg in "$@"; do
  case "$arg" in
    --run)
      should_run=1
      ;;
    --verify)
      should_run=1
      should_verify=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if pgrep -x "$APP_NAME" >/dev/null 2>&1; then
  osascript -e "tell application \"$APP_NAME\" to quit" >/dev/null 2>&1 || true
  sleep 1
fi

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -destination "platform=macOS" \
  -derivedDataPath "$DERIVED_DATA" \
  build

if [[ "$should_run" -eq 1 ]]; then
  /usr/bin/open -n "$APP_PATH"
fi

if [[ "$should_verify" -eq 1 ]]; then
  sleep 2
  pgrep -x "$APP_NAME" >/dev/null
fi
