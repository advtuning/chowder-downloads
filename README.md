# Chowder downloads

Public test downloads for Chowder by Clarity Soft.

## Apple Silicon macOS test build

```bash
curl -fsSL https://raw.githubusercontent.com/advtuning/chowder-downloads/main/install-macos.sh | bash
```

The installer verifies Apple Silicon, installs Homebrew and ClamAV when required, verifies the
published Chowder archive SHA-256, installs `Chowder.app` into `/Applications`, and launches it.

This is an unsigned and unnotarised test build. Public production distribution will replace it
with a Developer ID-signed and Apple-notarised package.

