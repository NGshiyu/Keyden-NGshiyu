# Changelog / 更新日志

## v1.0.8 (2026-01-08)

### ⚠️ Breaking Change / 破坏性变更

**Bundle Identifier Changed / 包名已变更**

- Old / 旧: `com.tassel.Keyden`
- New / 新: `com.keyden.app`

> **Note**: Please uninstall the old version and install the new version directly. Your data is stored in Keychain and will be preserved.
>
> **注意**：请卸载旧版本后直接安装新版本。您的数据存储在钥匙串中，不会丢失。

---

### 🚀 Performance Optimization / 性能优化

#### Timer Management Refactoring / 定时器管理重构

- **Single Timer Architecture**: Replaced individual timers per token with a centralized `TOTPTimerService` singleton
- **单一定时器架构**：用集中式的 `TOTPTimerService` 单例替代每个 token 的独立定时器

- **Smart Code Generation**: TOTP codes are now only regenerated at 30-second boundaries instead of every second
- **智能代码生成**：TOTP 代码现在仅在 30 秒边界时重新生成，而非每秒计算

- **Panel Visibility Control**: Timer completely stops when the menu panel is hidden
- **面板可见性控制**：当菜单面板隐藏时，定时器完全停止

#### View Layer Optimization / 视图层优化

- **Isolated Timer Updates**: Added `TokenRowWrapper` to isolate timer updates, preventing entire view tree rebuilds
- **隔离定时器更新**：新增 `TokenRowWrapper` 隔离定时器更新，防止整个视图树重建

- **Conditional State Updates**: Only update view state when values actually change
- **条件状态更新**：仅在值实际变化时更新视图状态

- **Removed Continuous Animation**: Removed the 1-second linear animation from progress rings
- **移除连续动画**：移除进度环的 1 秒线性动画

#### CPU Usage Improvement / CPU 占用改善

| Scenario / 场景 | Before / 优化前 | After / 优化后 |
|-----------------|-----------------|----------------|
| Panel hidden / 面板隐藏 | ~5-10% | **~0%** |
| Panel visible (10 tokens) / 面板显示 (10个账号) | ~15-30% | **<2%** |

---

### 📝 Technical Details / 技术细节

**New Files / 新增文件:**
- `Keyden/Services/TOTPTimerService.swift` - Centralized timer management / 集中式定时器管理

**Modified Files / 修改文件:**
- `MenuBarContentView.swift` - Added TokenRowWrapper, removed per-row timers / 新增 TokenRowWrapper，移除每行独立定时器
- `MenuBarController.swift` - Added panel visibility notifications / 新增面板可见性通知
- `AddTokenView.swift` - Optimized TokenPreviewCard timer / 优化 TokenPreviewCard 定时器

---

### 📦 Installation / 安装

1. Download the latest `.dmg` from [Releases](https://github.com/tasselx/Keyden/releases)
2. Drag `Keyden.app` to Applications folder (replace old version if prompted)
3. Launch Keyden - your existing accounts will be automatically loaded from Keychain

1. 从 [Releases](https://github.com/tasselx/Keyden/releases) 下载最新的 `.dmg` 文件
2. 将 `Keyden.app` 拖到应用程序文件夹（如果提示则替换旧版本）
3. 启动 Keyden - 您现有的账号将自动从钥匙串加载
