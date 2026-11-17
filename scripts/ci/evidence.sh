#!/usr/bin/env bash
# Produces the lab's evidence on macOS: screenshots (light, dark, AX5, iPad), GIF screen
# recordings, the accessibility audit, package coverage and Instruments traces.
# Runs in the "Evidence" GitHub Actions workflow, or on your own/rented Mac.
#   scripts/ci/evidence.sh [all|shots|record|audit|coverage|traces]
# Output: ./evidence/  (images/, traces/, coverage.md, a11y-audit.md, logs)
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1
ROOT="$PWD"
OUT="$ROOT/evidence"
DD="$ROOT/.dd"
SHOTS="$HOME/maple-shots"   # UI tests write here through SIMULATOR_HOST_HOME
WHAT="${1:-all}"
mkdir -p "$OUT/images" "$OUT/traces" "$SHOTS"

log() { printf '\n==> %s\n' "$*"; }

# pick <regex>: UDID of the first available simulator whose name matches (newest iOS first)
pick() {
  xcrun simctl list devices available -j | python3 -c '
import json, re, sys
pattern = re.compile(sys.argv[1])
devices = json.load(sys.stdin)["devices"]
for runtime in sorted(devices, reverse=True):
    if ".iOS-" not in runtime:
        continue
    for device in devices[runtime]:
        if pattern.search(device["name"]):
            print(device["udid"])
            sys.exit(0)
' "$1"
}

IPHONE="$(pick '^iPhone [0-9]+$')"; [ -n "$IPHONE" ] || IPHONE="$(pick '^iPhone')"
SMALL="$(pick '^iPhone SE')"; [ -n "$SMALL" ] || SMALL="$(pick '^iPhone [0-9]+e$')"; [ -n "$SMALL" ] || SMALL="$IPHONE"
IPAD="$(pick '^iPad Pro')"; [ -n "$IPAD" ] || IPAD="$(pick '^iPad')"
log "Simulators: iPhone=$IPHONE small=$SMALL iPad=$IPAD"

boot() {
  xcrun simctl boot "$1" 2>/dev/null || true
  xcrun simctl bootstatus "$1" -b >/dev/null 2>&1 || true
  xcrun simctl status_bar "$1" override --time 9:41 --batteryState charged --batteryLevel 100 --cellularBars 4 2>/dev/null || true
}

build() {
  [ -d "$DD/Build/Products" ] && return 0
  log "Building the app and UI tests"
  [ -d MapleWallet.xcodeproj ] || xcodegen generate
  xcodebuild build-for-testing -project MapleWallet.xcodeproj -scheme MapleWallet \
    -destination 'generic/platform=iOS Simulator' -derivedDataPath "$DD" \
    CODE_SIGNING_ALLOWED=NO -quiet > "$OUT/build.log" 2>&1 \
    || { echo "Build failed: see evidence/build.log"; tail -40 "$OUT/build.log"; exit 1; }
}

# run_test <udid> <TestClass[/testMethod]> [VAR=value ...]
run_test() {
  local udid="$1" test="$2"; shift 2
  env "$@" xcodebuild test-without-building -project MapleWallet.xcodeproj -scheme MapleWallet \
    -destination "id=$udid" -derivedDataPath "$DD" -only-testing:"MapleWalletUITests/$test" \
    CODE_SIGNING_ALLOWED=NO >> "$OUT/ui-tests.log" 2>&1
}

shots() {
  build
  # shot_set <udid> <tag> <appearance> <content size>
  shot_set() {
    log "Screenshots: $2"
    boot "$1"
    xcrun simctl ui "$1" appearance "$3"
    xcrun simctl ui "$1" content_size "$4"
    run_test "$1" ScreenshotTests TEST_RUNNER_SHOTS_TAG="$2" || echo "Screenshot set $2 had failures"
    xcrun simctl ui "$1" content_size large
    xcrun simctl ui "$1" appearance light
  }
  shot_set "$IPHONE" light light large
  shot_set "$IPHONE" dark dark large
  shot_set "$SMALL" ax5 light accessibility-extra-extra-extra-large
  [ -n "$IPAD" ] && shot_set "$IPAD" ipad light large
  cp "$SHOTS"/*.png "$OUT/images/" 2>/dev/null || echo "No screenshots were produced"
}

record() {
  build
  # clip <test> <gif name>
  clip() {
    log "Recording: $2"
    boot "$IPHONE"
    local mov="$OUT/$2.mov"
    xcrun simctl io "$IPHONE" recordVideo --codec=h264 --force "$mov" > /dev/null 2>&1 &
    local recorder=$!
    sleep 3
    run_test "$IPHONE" "$1" TEST_RUNNER_DEMO_PACE=1 || echo "Recording test $1 had failures"
    sleep 1
    kill -INT "$recorder" 2>/dev/null
    wait "$recorder" 2>/dev/null
    if [ -s "$mov" ] && command -v ffmpeg > /dev/null; then
      ffmpeg -y -loglevel error -i "$mov" \
        -vf "fps=8,scale=320:-1:flags=lanczos,split[a][b];[a]palettegen=max_colors=128[p];[b][p]paletteuse" \
        -loop 0 "$OUT/images/$2.gif" || echo "GIF conversion failed for $2"
    fi
  }
  clip MainFlowUITests/testSignInOpenAccountAndSendTransfer demo
  clip DemoRecordingTests/testOfflineCache offline
  clip DemoRecordingTests/testSignInRefreshAndSignOut sso-refresh
}

audit() {
  build
  log "Accessibility audit"
  boot "$IPHONE"
  run_test "$IPHONE" AccessibilityAuditTests || echo "Audit test had failures"
  cp "$SHOTS/a11y-audit.md" "$OUT/" 2>/dev/null || echo "No audit report was produced"
}

coverage() {
  log "Package tests and coverage"
  COVERAGE_MD="$OUT/coverage.md" bash scripts/run_package_tests.sh > "$OUT/package-tests.log" 2>&1 \
    || echo "Some package tests or the coverage gate failed: see evidence/package-tests.log"
}

traces() {
  build
  local app
  app="$(find "$DD/Build/Products" -maxdepth 3 -path '*iphonesimulator*' -name 'MapleWallet.app' | head -1)"
  [ -n "$app" ] || { echo "App not found for tracing"; return; }
  boot "$IPHONE"
  xcrun simctl install "$IPHONE" "$app"
  for template in "Leaks" "Time Profiler"; do
    local slug; slug="$(echo "$template" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')"
    log "Instruments: $template"
    xcrun xctrace record --template "$template" --device "$IPHONE" --time-limit 15s \
      --output "$OUT/traces/$slug.trace" --launch -- "$app" -uiTesting \
      > "$OUT/traces/$slug.log" 2>&1 || echo "xctrace $template failed (see traces/$slug.log)"
  done
}

case "$WHAT" in
  all) coverage; shots; record; audit; traces ;;
  shots|record|audit|coverage|traces) "$WHAT" ;;
  *) echo "Usage: $0 [all|shots|record|audit|coverage|traces]"; exit 2 ;;
esac
log "Done. Evidence is in $OUT"
ls -la "$OUT" "$OUT/images" 2>/dev/null
exit 0
