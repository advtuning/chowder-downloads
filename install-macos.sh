#!/usr/bin/env bash
set -euo pipefail

version="0.1.0-test"
asset="chowder-osx-arm64-${version}.app.tar.gz"
url="https://github.com/advtuning/chowder-downloads/releases/download/v${version}/${asset}"
sha256="9a7d4e5bd7918c5d720d2a68eae9bf5d8aca0e81c682127f717b93605b146a9c"

[[ "$(uname -s)" == "Darwin" ]] || { echo "Chowder for macOS must be installed on a Mac." >&2; exit 1; }
[[ "$(uname -m)" == "arm64" ]] || { echo "This build requires an Apple Silicon Mac." >&2; exit 1; }

# Verify Chowder before installing prerequisites so a missing release cannot leave
# the Mac with a partial ClamAV-only installation.
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
echo "Downloading Chowder ${version}..."
curl -fL --retry 3 --output "$work/$asset" "$url"
printf '%s  %s\n' "$sha256" "$work/$asset" | shasum -a 256 -c -
tar -xzf "$work/$asset" -C "$work"

binary="$work/Chowder.app/Contents/MacOS/chowder-gui"
[[ -x "$binary" ]] || { echo "The Chowder application bundle is incomplete." >&2; exit 1; }
file "$binary" | grep -q 'Mach-O 64-bit arm64' || { echo "The Chowder executable is not Apple Silicon." >&2; exit 1; }

if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if ! brew list --versions clamav >/dev/null 2>&1; then
  echo "Installing ClamAV..."
  brew install clamav
fi

# Homebrew installs sample configuration but does not initialise the signature database.
brew_prefix="$(brew --prefix)"
clamav_conf_dir="$brew_prefix/etc/clamav"
freshclam_conf="$clamav_conf_dir/freshclam.conf"
freshclam_sample="$clamav_conf_dir/freshclam.conf.sample"
database_dir="$brew_prefix/var/lib/clamav"
mkdir -p "$clamav_conf_dir" "$database_dir"
if [[ ! -f "$freshclam_conf" ]]; then
  [[ -f "$freshclam_sample" ]] || { echo "ClamAV freshclam sample configuration was not installed." >&2; exit 1; }
  cp "$freshclam_sample" "$freshclam_conf"
  sed -i '' '/^[[:space:]]*Example[[:space:]]*$/d' "$freshclam_conf"
fi
if grep -Eq '^[[:space:]]*DatabaseDirectory[[:space:]]+' "$freshclam_conf"; then
  sed -i '' "s#^[[:space:]]*DatabaseDirectory[[:space:]].*#DatabaseDirectory $database_dir#" "$freshclam_conf"
else
  printf '\nDatabaseDirectory %s\n' "$database_dir" >> "$freshclam_conf"
fi
echo "Initialising ClamAV signatures..."
"$brew_prefix/bin/freshclam" --config-file="$freshclam_conf"

echo "Installing Chowder in /Applications..."
sudo rm -rf /Applications/Chowder.app
sudo ditto "$work/Chowder.app" /Applications/Chowder.app

# This test build is not yet Developer ID signed/notarised. Remove only the quarantine
# attribute applied to this exact verified archive so Gatekeeper permits local testing.
sudo xattr -dr com.apple.quarantine /Applications/Chowder.app 2>/dev/null || true

echo "Chowder ${version} installed successfully."
open /Applications/Chowder.app
