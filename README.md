# Chowder downloads

Public test downloads for the Chowder malware-scanning GUI by Clarity Soft. These are prerelease
evaluation builds. They are not production releases.

## Windows x64 portable GUI (`0.1.4-test`)

Download and launch the self-extracting portable EXE from PowerShell:

```powershell
Invoke-WebRequest 'https://github.com/advtuning/chowder-downloads/releases/download/v0.1.4-test/Chowder-Standard-Portable-0.1.4-test-win-x64.exe' -OutFile 'Chowder-Standard-Portable-0.1.4-test-win-x64.exe'; .\Chowder-Standard-Portable-0.1.4-test-win-x64.exe
```

Or download, extract, and launch the portable ZIP:

```powershell
Invoke-WebRequest 'https://github.com/advtuning/chowder-downloads/releases/download/v0.1.4-test/Chowder-Standard-Portable-0.1.4-test-win-x64.zip' -OutFile 'Chowder-Standard-Portable-0.1.4-test-win-x64.zip'; Expand-Archive '.\Chowder-Standard-Portable-0.1.4-test-win-x64.zip' -DestinationPath '.\Chowder-Standard-Portable'; Start-Process '.\Chowder-Standard-Portable\Chowder\Chowder.exe'
```

Published SHA-256 values:

```text
e841cd639f5595d86a92424296dfdcb2e4aaf1dc8772fe4b29b03e38cba2faab  Chowder-Standard-Portable-0.1.4-test-win-x64.exe
d88555fd9e6958acc1532a988892922116c0217bf0f56e083a8e7350c2980454  Chowder-Standard-Portable-0.1.4-test-win-x64.zip
```

The downloadable `.sha256` sidecars are on the [0.1.4 test release page](https://github.com/advtuning/chowder-downloads/releases/tag/v0.1.4-test).

This is the free Chowder Standard desktop GUI. It stores its data beside the application and does
not install a Windows service. The official ClamAV engine must be installed separately. Both test
formats are unsigned, so Windows may show a reputation warning.

## Ubuntu and Debian GUI (`0.1.4-test`)

The signed APT repository provides the `0.1.4-test` GUI for amd64 and arm64 and installs ClamAV as
a package dependency:

```bash
curl -fsSL https://advtuning.github.io/chowder-apt/install.sh | bash
```

This installs the native Chowder desktop GUI, not only the ClamAV command-line tools. The package
also supplies the scheduled definition-update integration used by Chowder.

## RPM-family Linux GUI (`0.1.4-test`)

Download, verify, and install the x64 RPM:

```bash
curl -fLO https://github.com/advtuning/chowder-downloads/releases/download/v0.1.4-test/chowder-linux-x64-0.1.4-test.rpm -fLO https://github.com/advtuning/chowder-downloads/releases/download/v0.1.4-test/chowder-linux-x64-0.1.4-test.rpm.sha256 && sha256sum -c chowder-linux-x64-0.1.4-test.rpm.sha256 && sudo dnf install ./chowder-linux-x64-0.1.4-test.rpm
```

Use this one-liner on arm64:

```bash
curl -fLO https://github.com/advtuning/chowder-downloads/releases/download/v0.1.4-test/chowder-linux-arm64-0.1.4-test.rpm -fLO https://github.com/advtuning/chowder-downloads/releases/download/v0.1.4-test/chowder-linux-arm64-0.1.4-test.rpm.sha256 && sha256sum -c chowder-linux-arm64-0.1.4-test.rpm.sha256 && sudo dnf install ./chowder-linux-arm64-0.1.4-test.rpm
```

Published SHA-256 values:

```text
d6f0facd7e8d5801bf3a576de60820e46f67905e9b8e8b1ad30a89cf01571ade  chowder-linux-x64-0.1.4-test.rpm
7ea9740fb72acf85ada5ad73fa9de7df2ea3b21bb269970c5cb1e79ea9ce3498  chowder-linux-arm64-0.1.4-test.rpm
```

These RPM test packages are not signed and are not distributed through a signed RPM repository.
Their package dependencies install ClamAV. Native RPM-family and physical arm64 validation remain
release gates; publication here does not claim those gates have passed.

## Apple Silicon macOS GUI (`0.2.0-test`)

```bash
curl -fsSL https://raw.githubusercontent.com/advtuning/chowder-downloads/main/install-macos.sh | bash
```

The single installer accepts native Apple Silicon terminals and terminals running under Rosetta on
Apple Silicon; it rejects Intel-only Macs. It downloads and verifies the dedicated
`Chowder.Mac.App` bundle, installs or reuses native Homebrew and ClamAV, downloads current malware
definitions into Chowder's managed database, performs a harmless real scan, installs the GUI into
`~/Applications`, applies a local ad-hoc test signature, and launches it. It fails unless the GUI,
engine and definitions are all ready.

The archive's published [SHA-256 sidecar](https://raw.githubusercontent.com/advtuning/chowder-downloads/main/Chowder-Apple-Silicon-0.2.0-test.app.tar.gz.sha256)
uses the same checksum enforced by the installer.

This exact public installer and archive were verified on a physical Apple Silicon iMac: checksum,
installation into `~/Applications/Chowder.app`, ad-hoc signature verification, launch and a live
native `chowder-macos` process all passed. This is still an unsigned and unnotarised test build;
public production distribution will replace it with a Developer ID-signed and Apple-notarised
package.
