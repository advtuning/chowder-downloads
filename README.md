# Chowder downloads

Public test downloads for Chowder by Clarity Soft.

## Apple Silicon macOS test build

```bash
curl -fsSL https://raw.githubusercontent.com/advtuning/chowder-downloads/main/install-macos.sh | bash
```

The installer verifies Apple Silicon and downloads/verifies Chowder before changing the Mac. It then
installs Homebrew and ClamAV when required, creates the minimum `freshclam.conf`, initialises the
signature database, installs `Chowder.app` into `/Applications`, and launches it.

This is an unsigned and unnotarised test build. Public production distribution will replace it
with a Developer ID-signed and Apple-notarised package.

