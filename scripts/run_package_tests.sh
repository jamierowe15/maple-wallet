#!/usr/bin/env bash
# Runs every package's tests with coverage, then enforces the coverage gate.
# Works on macOS, Linux and Windows (Git Bash) wherever `swift` is installed.
set -euo pipefail
cd "$(dirname "$0")/.."

MIN="${MIN_COVERAGE:-70}"
GATED=" Networking Auth Accounts "
PY="$(command -v python3 || command -v python)"
failed=0

# Optional: COVERAGE_MD=path writes a Markdown table; SWIFT_TEST_FLAGS adds flags to swift test.
MD=()
if [ -n "${COVERAGE_MD:-}" ]; then
  printf '| Package | Line coverage | Lines | Gate |\n|---|---|---|---|\n' > "$COVERAGE_MD"
  MD=(--markdown "$COVERAGE_MD")
fi

for p in Core Networking Auth Accounts Transfers; do
  [ -d "Packages/$p/Tests" ] || continue
  echo "::group::swift test $p"
  # shellcheck disable=SC2086
  (cd "Packages/$p" && swift test --enable-code-coverage ${SWIFT_TEST_FLAGS:-}) || failed=1
  echo "::endgroup::"
  # shellcheck disable=SC2086
  json="$(cd "Packages/$p" && swift test --show-codecov-path ${SWIFT_TEST_FLAGS:-})"
  if [[ "$GATED" == *" $p "* ]]; then
    "$PY" scripts/check_coverage.py llvm "$json" --name "$p" --min "$MIN" "${MD[@]}" || failed=1
  else
    "$PY" scripts/check_coverage.py llvm "$json" --name "$p" --min 0 "${MD[@]}"
  fi
done
exit "$failed"
