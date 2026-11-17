#!/usr/bin/env bash
# One command from fresh clone to running app (macOS).
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew is required: https://brew.sh" >&2
  exit 1
fi
for tool in xcodegen swiftlint; do
  brew list "$tool" >/dev/null 2>&1 || brew install "$tool"
done

xcodegen generate
echo "Project generated. Opening Xcode: pick an iPhone simulator and press Cmd+R."
open MapleWallet.xcodeproj
