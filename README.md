# Chowder downloads

Public test downloads for Chowder by Clarity Soft.

## Windows x64 portable GUI (`0.1.4-test`)

Download either the [self-extracting EXE](https://github.com/advtuning/chowder-downloads/releases/download/v0.1.4-test/Chowder-Standard-Portable-0.1.4-test-win-x64.exe) or the [portable ZIP](https://github.com/advtuning/chowder-downloads/releases/download/v0.1.4-test/Chowder-Standard-Portable-0.1.4-test-win-x64.zip). The adjacent `.sha256` files are available on the [release page](https://github.com/advtuning/chowder-downloads/releases/tag/v0.1.4-test).

This is the free Chowder Standard desktop GUI. It stores its data beside the application and does
not install a Windows service. The official ClamAV engine must be installed separately. These test
binaries are unsigned, so Windows may show a reputation warning.

## Ubuntu and Debian GUI (`0.1.4-test`)

The signed APT repository installs Chowder and declares ClamAV as a package dependency:

```bash
curl -fsSL https://advtuning.github.io/chowder-apt/install.sh | bash
```

This installs the native Chowder desktop GUI, not only the ClamAV command-line tools. The package
also supplies the scheduled definition-update integration used by Chowder.

## RPM-family Linux GUI (`0.1.4-test`)

Download the matching [x64 or arm64 RPM and checksum](https://github.com/advtuning/chowder-downloads/releases/tag/v0.1.4-test), verify the checksum, then install the local package with your distribution's package manager. For example:

```bash
sha256sum -c chowder-linux-x64-0.1.4-test.rpm.sha256
sudo dnf install ./chowder-linux-x64-0.1.4-test.rpm
```

Use `chowder-linux-arm64-0.1.4-test.rpm` on arm64. These RPM test packages are not signed and are
not yet distributed through a signed RPM repository. Their package dependencies install ClamAV.

## Apple Silicon macOS test build (`0.1.3-test`)

```bash
curl -fsSL https://raw.githubusercontent.com/advtuning/chowder-downloads/main/install-macos.sh | bash
```

The installer verifies Apple Silicon and downloads/verifies Chowder before changing the Mac. It then
installs Homebrew and ClamAV when required, creates the minimum `freshclam.conf`, initialises the
signature database, installs `Chowder.app` into `/Applications`, and launches it.

The archive's independently verifiable [SHA-256 sidecar](https://raw.githubusercontent.com/advtuning/chowder-downloads/main/chowder-osx-arm64-0.1.3-test.app.tar.gz.sha256)
uses the same checksum enforced by the installer.

This is an unsigned and unnotarised test build. Public production distribution will replace it
with a Developer ID-signed and Apple-notarised package.

