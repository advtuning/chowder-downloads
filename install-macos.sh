#!/usr/bin/env bash
set -euo pipefail

version="0.1.0-test"
asset="chowder-osx-arm64-${version}.app.tar.gz"
url="https://github.com/advtuning/chowder-downloads/releases/download/v${version}/${asset}"
sha256="3c36e6ffa5b91f8682fd0fe56989d8127ef99f7aa3e691d103a91fc1c39e5a58"

[[ "$(uname -s)" == "Darwin" ]] || { echo "Chowder for macOS must be installed on a Mac." >&2; exit 1; }
[[ "$(uname -m)" == "arm64" ]] || { echo "This build requires an Apple Silicon Mac." >&2; exit 1; }

if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if ! brew list --versions clamav >/dev/null 2>&1; then
  echo "Installing ClamAV..."
  brew install clamav
fi

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
echo "Downloading Chowder ${version}..."
curl -fL --retry 3 --output "$work/$asset" "$url"
printf '%s  %s\n' "$sha256" "$work/$asset" | shasum -a 256 -c -
tar -xzf "$work/$asset" -C "$work"

binary="$work/Chowder.app/Contents/MacOS/chowder-gui"
[[ -x "$binary" ]] || { echo "The Chowder application bundle is incomplete." >&2; exit 1; }
file "$binary" | grep -q 'Mach-O 64-bit arm64' || { echo "The Chowder executable is not Apple Silicon." >&2; exit 1; }

echo "Installing Chowder in /Applications..."
sudo rm -rf /Applications/Chowder.app
sudo ditto "$work/Chowder.app" /Applications/Chowder.app

# This test build is not yet Developer ID signed/notarised. Remove only the quarantine
# attribute applied to this exact verified archive so Gatekeeper permits local testing.
sudo xattr -dr com.apple.quarantine /Applications/Chowder.app 2>/dev/null || true

echo "Chowder ${version} installed successfully."
open /Applications/Chowder.app

