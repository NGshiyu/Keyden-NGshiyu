# Keyden

[English](README.md)

简洁优雅的 macOS 菜单栏 TOTP 双因素认证器。

![macOS](https://img.shields.io/badge/macOS-12.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## 截图

<p align="center">
  <img src="docs/screenshot-light.png" width="340" alt="浅色模式" />
  <img src="docs/screenshot-dark.png" width="340" alt="深色模式" />
</p>

## 功能特性

- 🔐 **安全存储** - TOTP 密钥加密存储在 macOS Keychain
- 📋 **一键复制** - 点击即可复制验证码
- 📷 **二维码支持** - 扫描二维码添加账户，支持导出二维码图片
- 📥 **批量导入** - 支持通过剪贴板或输入框批量导入多个账户
- ☁️ **GitHub Gist 同步** - 可选通过私有 GitHub Gist 同步
- 💾 **离线优先** - 无需联网，数据本地加密存储
- 🎨 **主题支持** - 明暗模式，跟随系统偏好设置
- 🌍 **多语言** - 支持英文和简体中文
- 📌 **置顶与排序** - 置顶常用账户，拖拽调整顺序
- 🔄 **导入/导出** - 轻松备份和恢复令牌
- 🚀 **开机启动** - 支持随 Mac 自动启动

## 支持的算法

- SHA1（默认）
- SHA256
- SHA512

## 安装

从 [Releases](https://github.com/tasselx/Keyden/releases) 下载最新 DMG：

| 文件 | 架构 | 说明 |
|------|------|------|
| `Keyden-x.x.x-universal.dmg` | 通用版 | 推荐（Intel + Apple Silicon） |
| `Keyden-x.x.x-arm64.dmg` | Apple Silicon | 适用于 M1/M2/M3 Mac |
| `Keyden-x.x.x-x86_64.dmg` | Intel | 适用于 Intel Mac |

打开 DMG，将 Keyden 拖入「应用程序」文件夹。

## 使用

1. 启动 Keyden - 图标出现在菜单栏
2. 点击「+」添加 TOTP 账户（扫描二维码或手动输入）
3. 点击验证码即可复制到剪贴板
4. 右键点击可查看更多选项（置顶、删除、导出二维码）

### GitHub Gist 同步

1. 进入设置 → 同步
2. 创建 [GitHub Personal Access Token](https://github.com/settings/tokens)，勾选 `gist` 权限
3. 输入 Token 并启用同步
4. 令牌将同步到私有 Gist

## 从源码构建

环境要求：
- macOS 12.0+
- Xcode 15.0+

```bash
git clone https://github.com/tasselx/Keyden.git
cd Keyden

# 构建通用版应用
make build

# 创建 DMG 安装包
make dmg

# 或构建特定架构版本
make build-arm      # 仅 Apple Silicon
make build-intel    # 仅 Intel
make build-all      # 通用

# 清理构建产物
make clean
```

## 技术栈

- SwiftUI + AppKit
- CryptoKit（TOTP 生成）
- Keychain Services（安全存储）
- Vision Framework（二维码扫描）

## 捐赠

如果 Keyden 对你有帮助，欢迎请我喝杯咖啡 ☕

<p align="center">
  <img src="assets/alipay.png" width="200" alt="支付宝" />
  <img src="assets/wepay.png" width="200" alt="微信支付" />
</p>

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=tasselx/Keyden&type=Date)](https://star-history.com/#tasselx/Keyden&Date)

## 许可证

MIT 许可证 - 详见 [LICENSE](LICENSE)
