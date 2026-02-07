---
name: xcode-errors
description: Use when encountering Xcode errors, build failures, compilation errors, linker errors, CocoaPods issues, SwiftLint errors, code signing problems, certificate errors, provisioning profile issues, Xcode UI issues like Assistant Editor not working, split screen not opening, or any project build/setup errors in iOS projects. Also use when pod install fails, dependencies have conflicts, Xcode Assistant Editor is broken, or when Xcode shows red error indicators.

中文触发关键词：Xcode报错、编译错误、链接错误、运行时错误、分屏打不开、Assistant Editor不工作、Xcode崩溃、Xcode卡顿、代码签名错误、证书错误、Provisioning Profile错误、CocoaPods错误、pod install失败、SwiftLint错误、派生数据损坏、DerivedData、Xcode清理缓存、项目配置问题、bundle id冲突、描述文件错误。
version: 1.0.0
license: MIT
author: Link-Start <https://github.com/Link-Start>
---

# Xcode 常见错误和解决方案

## 📋 快速诊断

**遇到 Xcode 错误时，按以下步骤排查**：

1. **检查错误类型**：编译错误、链接错误、运行时错误、UI 问题？
2. **查看错误信息**：完整读取错误描述和堆栈
3. **检查最近修改**：是否刚添加了新代码或依赖？
4. **清理缓存**：`Cmd + Shift + K` 清理构建缓存

---

## 🖥️ Xcode 界面问题

### 问题 1：分屏功能失效（Assistant Editor 不工作）

**症状**：
- Xcode 的 Assistant Editor（分屏）功能无法使用
- 点击分屏按钮（右上角三个圆圈图标）无反应
- Option + 点击文件也无法打开分屏

**原因**：
`UserInterfaceState.xcuserstate` 文件损坏，文件大小异常膨胀（正常几十KB，损坏后可达数MB）。

**排查步骤**：
```bash
# 检查文件大小
ls -lh *.xcworkspace/xcuserdata/$(whoami).xcuserdatad/UserInterfaceState.xcuserstate
```

正常大小应该 < 100KB。如果超过 1MB，说明文件损坏。

**解决方案**：
```bash
# 删除损坏的文件（Xcode 会自动重新生成）
rm *.xcworkspace/xcuserdata/$(whoami).xcuserdatad/UserInterfaceState.xcuserstate
rm *.xcodeproj/project.xcworkspace/xcuserdata/$(whoami).xcuserdatad/UserInterfaceState.xcuserstate
```

**重要**：删除后**必须重启 Xcode**。

---

### 问题 3：Xcode 频繁崩溃

**解决方案**：
```bash
# 1. 清理派生数据
rm -rf ~/Library/Developer/Xcode/DerivedData

# 2. 清理系统缓存
rm -rf ~/Library/Caches/com.apple.dt.Xcode

# 3. 删除 UserInterfaceState 文件
rm -rf *.xcworkspace/xcuserdata/$(whoami).xcuserdatad/UserInterfaceState.xcuserstate

# 4. 重启 Xcode
```

---

## 🔴 常见编译错误

### 错误 1：SnapKit 约束崩溃

**错误信息**：
```
Fatal error: Updated constraint could not find existing matching constraint to update
```

**原因**：使用 `updateConstraints` 更新从未在 `makeConstraints` 中设置过的约束

**详细说明**：使用 `/snapkit` skill

---

### 错误 2：Swift 6 并发错误

**错误信息**：
```
Main actor-isolated property 'xxx' cannot be mutated from a non-isolated deinit
Capture of 'self' with non-Sendable type in a @Sendable closure
```

**详细说明**：使用 `/swift6-concurrency` skill

---

### 错误 3：颜色/字体函数不存在

**错误信息**：
```
Cannot find 'UIColorHex' in scope
Cannot find 'PingFangSCRegular' in scope
```

**详细说明**：使用 `/coding-standards` skill

---

## 🔧 CocoaPods 相关错误

### 错误 1：pod install 失败

**解决方案**：
```bash
# 1. 清理 CocoaPods 缓存
pod cache clean --all

# 2. 删除 Pods 目录和 Podfile.lock
rm -rf Pods Podfile.lock

# 3. 更新 CocoaPods 仓库
pod repo update

# 4. 重新安装
pod install
```

---

## 🔄 清理缓存步骤

**遇到奇怪的错误时，按顺序执行**：

```bash
# 1. Xcode 清理
# 在 Xcode 中：Product → Clean Build Folder (Cmd + Shift + K)

# 2. 删除 DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# 3. 清理 CocoaPods
pod deintegrate
rm -rf Pods Podfile.lock
pod install

# 4. 重启 Xcode
```

---

## 📦 项目配置问题

### 问题 1：使用 .xcodeproj 而不是 .xcworkspace

**错误**：
```
Could not find module 'XXX' for target 'XXX'
```

**解决方案**：
```bash
# ⚠️ 必须使用 .xcworkspace（CocoaPods 要求）
open *.xcworkspace

# ❌ 不要使用
open *.xcodeproj
```

---

## 🎯 错误快速索引

| 错误关键词 | 可能原因 | 解决方案 |
|-----------|---------|---------|
| `Updated constraint could not find` | SnapKit 约束错误 | `/snapkit` skill |
| `Main actor-isolated` | Swift 6 并发错误 | `/swift6-concurrency` skill |
| `UIColorHex` | 颜色函数错误 | `/coding-standards` skill |
| `pod install` | CocoaPods 错误 | 清理缓存重新安装 |
| `Code Signing` | 证书问题 | 检查 Team 和 Profile |
