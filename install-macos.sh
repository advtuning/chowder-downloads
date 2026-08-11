#!/usr/bin/env bash
set -euo pipefail

version="0.1.3-test"
asset="chowder-osx-arm64-${version}.app.tar.gz"
url="https://github.com/advtuning/chowder-downloads/releases/download/v${version}/${asset}"
sha256="bd70eb02cc8b9c75d512b572c538fc3b128fd6647ddd60cf3476d21d05ce58ad"

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
