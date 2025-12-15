# Keyden

[中文](README.zh-CN.md)

A clean and elegant macOS menu bar TOTP authenticator.

![macOS](https://img.shields.io/badge/macOS-12.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## Screenshots

<p align="center">
  <img src="docs/screenshot-light.png" width="340" alt="Light Mode" />
  <img src="docs/screenshot-dark.png" width="340" alt="Dark Mode" />
</p>

## Features

- 🔐 **Secure Storage** - TOTP secrets stored in macOS Keychain with encryption
- 📋 **One-Click Copy** - Click to copy verification codes instantly
- 📷 **QR Code Support** - Scan QR codes or export tokens as QR images
- 📥 **Batch Import** - Import multiple accounts via clipboard or input field
- ☁️ **GitHub Gist Sync** - Optional sync via private GitHub Gist
- 💾 **Offline First** - Works without internet, all data encrypted locally
- 🎨 **Theme Support** - Light/Dark mode, follows system preference
- 🌍 **Multi-Language** - English and Simplified Chinese
- 📌 **Pin & Reorder** - Pin frequently used accounts, drag to reorder
- 🔄 **Import/Export** - Backup and restore your tokens easily
- 🚀 **Launch at Login** - Start automatically with your Mac

## Supported Algorithms

- SHA1 (default)
- SHA256
- SHA512

## Installation

Download the latest DMG from [Releases](https://github.com/tasselx/Keyden/releases):

| File | Architecture | Description |
|------|--------------|-------------|
| `Keyden-x.x.x-universal.dmg` | Universal | Recommended (Intel + Apple Silicon) |
| `Keyden-x.x.x-arm64.dmg` | Apple Silicon | For M1/M2/M3 Macs |
| `Keyden-x.x.x-x86_64.dmg` | Intel | For Intel Macs |

Open the DMG and drag Keyden to Applications.

## Usage

1. Launch Keyden - icon appears in menu bar
2. Click "+" to add TOTP accounts (scan QR or enter manually)
3. Click any code to copy to clipboard
4. Right-click for more options (pin, delete, export QR)

### GitHub Gist Sync

1. Go to Settings → Sync
2. Create a [GitHub Personal Access Token](https://github.com/settings/tokens) with `gist` scope
3. Enter your token and enable sync
4. Your tokens will be synced to a private Gist

## Build from Source

Requirements:
- macOS 12.0+
- Xcode 15.0+

```bash
git clone https://github.com/tasselx/Keyden.git
cd Keyden

# Build universal app
make build

# Create DMG installer
make dmg

# Or build for specific architecture
make build-arm      # Apple Silicon only
make build-intel    # Intel only
make build-all      # Universal

# Clean build artifacts
make clean
```

## Tech Stack

- SwiftUI + AppKit
- CryptoKit (TOTP generation)
- Keychain Services (secure storage)
- Vision Framework (QR code scanning)

## Donate

If you find Keyden helpful, consider buying me a coffee ☕

<p align="center">
  <img src="assets/alipay.png" width="200" alt="Alipay" />
  <img src="assets/wepay.png" width="200" alt="WeChat Pay" />
</p>

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=tasselx/Keyden&type=Date)](https://star-history.com/#tasselx/Keyden&Date)

## License

MIT License - see [LICENSE](LICENSE)
