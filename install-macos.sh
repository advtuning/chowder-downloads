#!/usr/bin/env bash
set -euo pipefail

version="0.2.0-test"
asset="Chowder-Apple-Silicon-${version}.app.tar.gz"
url="https://raw.githubusercontent.com/advtuning/chowder-downloads/main/${asset}"
sha256="321a747122bc234689ad6a5a20c23a8f214de4e702ec5f530bdc4692788c7b37"

[[ "$(uname -s)" == "Darwin" ]] || { echo "Chowder for macOS must be installed on a Mac." >&2; exit 1; }

is_apple_silicon() {
  local machine translated arm64_capable

  machine="$(uname -m)"
  [[ "$machine" == "arm64" ]] && return 0

  # A Terminal launched with Rosetta reports x86_64 even on Apple Silicon.
  # sysctl.proc_translated is Apple's supported way to identify that state;
  # hw.optional.arm64 is a hardware-capability fallback for other translated shells.
  translated="$(sysctl -in sysctl.proc_translated 2>/dev/null || true)"
  [[ "$translated" == "1" ]] && return 0

  arm64_capable="$(sysctl -n hw.optional.arm64 2>/dev/null || true)"
  [[ "$arm64_capable" == "1" ]] && return 0

  return 1
}

is_apple_silicon || { echo "This build requires an Apple Silicon Mac." >&2; exit 1; }

# Used only by the deterministic architecture checks in this repository.
[[ "${CHOWDER_ARCH_CHECK_ONLY:-0}" == "1" ]] && exit 0

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
echo "Downloading Chowder ${version}..."
curl -fL --retry 3 --output "$work/$asset" "$url"
printf '%s  %s\n' "$sha256" "$work/$asset" | shasum -a 256 -c -
tar -xzf "$work/$asset" -C "$work"

binary="$work/Chowder.app/Contents/MacOS/chowder-macos"
[[ -f "$binary" ]] || { echo "The Chowder application bundle is incomplete." >&2; exit 1; }
chmod 0755 "$binary"
file "$binary" | grep -Eq 'Mach-O 64-bit .*arm64' || { echo "The Chowder executable is not Apple Silicon." >&2; exit 1; }

install_root="${CHOWDER_INSTALL_ROOT:-$HOME/Applications}"
target="$install_root/Chowder.app"
mkdir -p "$install_root"

# This local test build is not Developer ID signed yet. Apply an ad-hoc signature only after the
# pinned archive and native architecture have been verified.
/usr/bin/codesign --force --deep --sign - "$work/Chowder.app"
/usr/bin/codesign --verify --deep --strict "$work/Chowder.app"

if [[ -e "$target" ]]; then
  mv "$target" "$install_root/Chowder.app.backup-$(date +%Y%m%d%H%M%S)"
fi
/usr/bin/ditto "$work/Chowder.app" "$target"
/usr/bin/xattr -dr com.apple.quarantine "$target" 2>/dev/null || true

echo "Chowder ${version} installed in $target."
open "$target"
