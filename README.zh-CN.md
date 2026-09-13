<p align="center">
  <img src="assets/AppIcon.png" width="128" alt="Keyden" />
</p>

<h1 align="center">Keyden</h1>

<p align="center">
  简洁优雅的 macOS 菜单栏 TOTP 双因素认证器
</p>

<p align="center">
  <a href="README.md">English</a> · 中文
</p>

<p align="center">
  <img src="https://img.shields.io/badge/macOS-12.0+-blue" alt="macOS" />
  <img src="https://img.shields.io/badge/Swift-5.9-orange" alt="Swift" />
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License" />
  <a href="https://github.com/tasselx/Keyden/releases"><img src="https://img.shields.io/github/v/release/tasselx/Keyden" alt="Release" /></a>
</p>

<p align="center">
  <img src="docs/screenshot-light.png" width="340" alt="浅色模式" />
  &nbsp;&nbsp;
  <img src="docs/screenshot-dark.png" width="340" alt="深色模式" />
</p>

---

## ✨ 功能特性

| 功能 | 描述 |
|:---:|:---|
| 🔐 | **安全存储** - TOTP 密钥加密存储在 macOS Keychain |
| 📋 | **一键复制** - 点击即可复制验证码 |
| 📷 | **二维码支持** - 扫描二维码添加账户，支持导出二维码图片 |
| 📥 | **批量导入** - 支持通过剪贴板或输入框批量导入多个账户 |
| 🔄 | **Google Authenticator 迁移** - 支持通过迁移二维码或链接从 Google Authenticator 导入账户 |
| ☁️ | **GitHub Gist 同步** - 可选通过私有 GitHub Gist 同步 |
| 💾 | **离线优先** - 无需联网，数据本地加密存储 |
| � | **主题言支持** - 明暗模式，跟随系统偏好设置 |
| 🌍 | **多语言** - 支持英文、简体中文、繁体中文、日语 |
| � | ***置顶与排序** - 置顶常用账户，拖拽调整顺序 |
| 📂 | **分组视图** - 按发行商分组显示账户，方便管理 |
| ⌨️ | **全局快捷键** - 自定义快捷键快速打开菜单（默认：⌘⇧K） |
| 🖥️ | **命令行工具** - 支持脚本和自动化调用 |
| 🔄 | **导入/导出** - 轻松备份和恢复令牌 |
| 🚀 | **开机启动** - 支持随 Mac 自动启动 |

---

## 📦 安装

### Homebrew（推荐）

```bash
brew install --cask tasselx/tap/keyden
```

### 手动下载

从 [Releases](https://github.com/tasselx/Keyden/releases) 下载最新 DMG

## ⚠️ 常见问题

### 截图权限问题

由于没有付费开发者账号签名，每次安装新版本后，macOS 可能无法正确识别应用的截图权限。

**解决方法：**

1. 打开「系统设置」→「隐私与安全性」→「屏幕录制」
2. 找到 Keyden，点击「-」移除授权
3. 重新打开 Keyden，系统会再次请求权限
4. 点击「+」添加 Keyden 并授权

### 钥匙串访问授权提示

安装新版本后，macOS 可能会提示需要授权钥匙串访问。这是正常现象，因为每次更新后应用签名会发生变化。

**解决方法：**

在弹出提示时点击「始终允许」或「允许」即可。您的 TOTP 密钥安全存储在 macOS 钥匙串中，更新后数据不会丢失。

### 提示"Keyden 已损坏，无法打开"

由于应用未经过 Apple 公证，macOS Gatekeeper 可能会阻止运行并显示"已损坏"的错误提示。

**解决方法：**

打开终端，运行以下命令：

```bash
xattr -cr /Applications/Keyden.app
```

这会移除隔离属性，之后应用即可正常运行。

---

## 🚀 使用

1. 启动 Keyden - 图标出现在菜单栏
2. 点击「+」添加 TOTP 账户（扫描二维码或手动输入）
3. 点击验证码即可复制到剪贴板
4. 右键点击可查看更多选项（置顶、删除、导出二维码）

### 命令行工具 (CLI)

Keyden 内置命令行工具，支持脚本和自动化操作。

**安装方式：**

- **一键安装**：右键点击任意账户 → "复制 CLI 命令" → 如未安装会提示一键安装
- **设置安装**：设置 → 通用 → CLI 工具 → 安装
- **手动安装**：CLI 内置于应用中，路径为 `Keyden.app/Contents/Resources/CLI/keyden`

```bash
# 使用方法
keyden get GitHub                    # 获取 GitHub 的验证码
keyden get GitHub:user@example.com   # 指定账户（issuer:account 格式）
keyden get GitHub user@example.com   # 同上（空格分隔）
keyden list                          # 列出所有账户及验证码
keyden search google                 # 搜索账户
keyden help                          # 显示帮助

# 在脚本中使用
CODE=$(keyden get GitHub)
echo "验证码是: $CODE"

# 自动填写示例（复制到剪贴板）
keyden get GitHub | pbcopy
```

> 💡 **提示**：当同一发行商下有多个账户时（如多个 GitHub 账户），使用 `issuer:account` 格式指定具体账户。

### GitHub Gist 同步

1. 进入设置 → 同步
2. 创建 [GitHub Personal Access Token](https://github.com/settings/tokens)，勾选 `gist` 权限
3. 输入 Token 并启用同步
4. 令牌将同步到私有 Gist

---

## 🔗 主流平台两步验证设置

<details>
<summary><b>🌐 社交与通讯</b></summary>

| 平台 | 设置链接 |
|:---|:---|
| 🔵 Google | [安全设置](https://myaccount.google.com/signinoptions/two-step-verification) |
| 📘 Facebook | [安全设置](https://www.facebook.com/settings?tab=security) |
| 🐦 X (Twitter) | [账户安全](https://twitter.com/settings/account/login_verification) |
| 📸 Instagram | [安全设置](https://www.instagram.com/accounts/two_factor_authentication/) |
| 🎮 Discord | [账户设置](https://discord.com/channels/@me) → 用户设置 → 我的账户 |
| 🐦 Reddit | [账户设置](https://www.reddit.com/settings/privacy) |
| 💬 Slack | 工作区设置 → 账户设置 → 两步验证 |

</details>

<details>
<summary><b>💻 开发者工具</b></summary>

| 平台 | 设置链接 |
|:---|:---|
| 🐙 GitHub | [两步验证](https://github.com/settings/two_factor_authentication/setup/intro) |
| 🦊 GitLab | [账户安全](https://gitlab.com/-/profile/two_factor_auth) |
| 🪣 Bitbucket | [账户安全](https://bitbucket.org/account/settings/two-step-verification/manage) |
| 🐳 Docker Hub | [账户安全](https://hub.docker.com/settings/security) |
| 📦 npm | [账户设置](https://www.npmjs.com/settings/~/tfa) |

</details>

<details>
<summary><b>☁️ 云服务</b></summary>

| 平台 | 设置链接 |
|:---|:---|
| ☁️ AWS | [IAM 安全](https://console.aws.amazon.com/iam/home#/security_credentials) |
| ☁️ Azure | [安全信息](https://mysignins.microsoft.com/security-info) |
| ☁️ Google Cloud | [安全设置](https://myaccount.google.com/signinoptions/two-step-verification) |
| ☁️ DigitalOcean | [账户安全](https://cloud.digitalocean.com/account/security) |
| ☁️ 阿里云 | [安全设置](https://account.console.aliyun.com/#/secure) |
| ☁️ 腾讯云 | [安全设置](https://console.cloud.tencent.com/developer/security) |
| 🔷 Cloudflare | [账户安全](https://dash.cloudflare.com/profile/authentication) |

</details>

<details>
<summary><b>🎮 游戏平台</b></summary>

| 平台 | 设置链接 |
|:---|:---|
| 🎮 Steam | [Steam Guard](https://store.steampowered.com/twofactor/manage) |
| 🎮 Epic Games | [账户安全](https://www.epicgames.com/account/password) |

</details>

<details>
<summary><b>💰 金融与支付</b></summary>

| 平台 | 设置链接 |
|:---|:---|
| 💰 PayPal | [安全设置](https://www.paypal.com/myaccount/settings/security) |
| 💰 Coinbase | [安全设置](https://www.coinbase.com/settings/security) |
| 💰 Binance | [安全设置](https://www.binance.com/en/my/security) |

</details>

<details>
<summary><b>🔐 密码管理器</b></summary>

| 平台 | 设置链接 |
|:---|:---|
| 🔐 1Password | [账户设置](https://my.1password.com/profile) |
| 🔐 Bitwarden | [账户设置](https://vault.bitwarden.com/#/settings/security/two-factor) |

</details>

<details>
<summary><b>📱 其他服务</b></summary>

| 平台 | 设置链接 |
|:---|:---|
| 🟦 微软 | [安全选项](https://account.live.com/proofs/manage/additional) |
| 🍎 Apple | [账户安全](https://appleid.apple.com/account/manage) |
| 🟠 亚马逊 | [两步验证](https://www.amazon.com/a/settings/approval) |
| 📦 Dropbox | [安全设置](https://www.dropbox.com/account/security) |
| 💼 领英 | [两步验证](https://www.linkedin.com/psettings/two-step-verification) |
| 📧 ProtonMail | [账户设置](https://account.proton.me/u/0/mail/account-password) |
| 🎵 Spotify | [账户安全](https://www.spotify.com/account/security/) |
| 🛒 Shopify | [账户安全](https://accounts.shopify.com/security) |
| 📝 Notion | [账户设置](https://www.notion.so/my-account) → 安全 |
| 🎨 Figma | [账户设置](https://www.figma.com/settings) |

</details>

> 💡 **提示**: 对于未列出的平台，两步验证设置通常位于 **账户设置 → 安全** 或 **隐私与安全** 中。

---

## 🛠 从源码构建

**环境要求：** macOS 12.0+ / Xcode 15.0+

```bash
git clone https://github.com/tasselx/Keyden.git
cd Keyden

make build      # 构建通用版应用
make dmg        # 创建 DMG 安装包
make clean      # 清理构建产物
```

<details>
<summary>更多构建选项</summary>

```bash
make build-arm      # 仅 Apple Silicon
make build-intel    # 仅 Intel
make build-all      # 通用
```

</details>

---

## 🧰 技术栈

- **SwiftUI + AppKit** - 原生 macOS 界面
- **CryptoKit** - TOTP 生成
- **Keychain Services** - 安全存储
- **Vision Framework** - 二维码扫描

---

## ☕ 捐赠

如果 Keyden 对你有帮助，欢迎请我喝杯咖啡 ☕

您的赞助可以帮助我购买 Apple 开发者账号，届时应用将获得正式签名和公证，不再出现"已损坏"的提示。

<p align="center">
  <img src="assets/alipay.png" width="180" alt="支付宝" />
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="assets/wepay.png" width="180" alt="微信支付" />
</p>

---

## 🎯 作者的其他项目

| 应用 | 描述 |
|:---|:---|
| [LanShare-Mac](https://github.com/tasselx/LanShare-Mac) | 简洁高效的 macOS 局域网文件共享工具 |

---

## ⭐ Star History

<a href="https://github.com/starcat-app/Starcat" target="_blank" rel="noopener noreferrer">
  <picture data-starcat-star-history>
    <source
      media="(prefers-color-scheme: dark)"
      srcset="https://history.starcat.ink/embed/v1/repos/tasselx/Keyden/star-history.svg?theme=dark&amp;locale=en">
    <img
      alt="starcat-app/Starcat Star History"
      src="https://history.starcat.ink/embed/v1/repos/tasselx/Keyden/star-history.svg?theme=light&amp;locale=en">
  </picture>
</a>



<p align="center">
  <sub>MIT License © <a href="https://github.com/tasselx">tasselx</a></sub>
</p>
