---
description: Use when encountering Xcode errors, build failures, compilation errors, linker errors, CocoaPods issues, SwiftLint errors, code signing problems, certificate errors, provisioning profile issues, Xcode UI issues like Assistant Editor not working, split screen not opening, or any project build/setup errors in iOS projects. Also use when pod install fails, dependencies have conflicts, Xcode Assistant Editor is broken, or when Xcode shows red error indicators.

中文触发关键词：Xcode报错、编译错误、链接错误、运行时错误、分屏打不开、Assistant Editor不工作、Xcode崩溃、Xcode卡顿、代码签名错误、证书错误、Provisioning Profile错误、CocoaPods错误、pod install失败、SwiftLint错误、派生数据损坏、DerivedData、Xcode清理缓存、项目配置问题、bundle id冲突、描述文件错误。
---

# Xcode 常见错误和解决方案

本文档提供 iOS 项目中常见的 Xcode 错误和解决方案。

---

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
- 只显示单个编辑器界面
- Option + 点击文件也无法打开分屏

**原因**：
`UserInterfaceState.xcuserstate` 文件损坏，文件大小异常膨胀（正常几十KB，损坏后可达数MB）。

**排查步骤**：
```bash
# 检查文件大小
ls -lh XiaoYueYun.xcworkspace/xcuserdata/$(whoami).xcuserdatad/UserInterfaceState.xcuserstate
```

正常大小应该 < 100KB。如果超过 1MB，说明文件损坏。

**解决方案**：
```bash
# 删除损坏的文件（Xcode 会自动重新生成）
rm XiaoYueYun.xcworkspace/xcuserdata/$(whoami).xcuserdatad/UserInterfaceState.xcuserstate

# 或者同时删除 project 和 workspace 中的文件
rm XiaoYueYun.xcworkspace/xcuserdata/$(whoami).xcuserdatad/UserInterfaceState.xcuserstate
rm XiaoYueYun.xcodeproj/project.xcworkspace/xcuserdata/$(whoami).xcuserdatad/UserInterfaceState.xcuserstate
```

**重要**：删除后**必须重启 Xcode**，会自动重新生成正常的文件。

**相关文件**：
- `.xcworkspace/xcuserdata/<username>/UserInterfaceState.xcuserstate`
- `.xcodeproj/project.xcworkspace/xcuserdata/<username>/UserInterfaceState.xcuserstate`

**注意**：这些文件在 `.gitignore` 中，不会被 git 跟踪。

---

### 问题 2：代码预览窗（Quick Open）异常

**症状**：`Cmd + Shift + O` 快速打开文件时，预览窗口显示异常或无响应。

**临时解决**：
- 重启 Xcode
- 清理派生数据：`rm -rf ~/Library/Developer/Xcode/DerivedData`

---

### 问题 3：Xcode 频繁崩溃

**常见原因**：
- 派生数据损坏
- 系统缓存问题
- UserInterfaceState 文件损坏

**解决方案**：
```bash
# 1. 清理派生数据
rm -rf ~/Library/Developer/Xcode/DerivedData

# 2. 清理系统缓存
rm -rf ~/Library/Caches/com.apple.dt.Xcode

# 3. 删除 UserInterfaceState 文件
rm -rf XiaoYueYun.xcworkspace/xcuserdata/$(whoami).xcuserdatad/UserInterfaceState.xcuserstate

# 4. 重启 Xcode
```

---

### 问题 4：Xcode 卡顿

**解决方案**：
1. 关闭不必要的 Navigator（`Cmd + 0-8`）
2. 清理派生数据
3. 关闭不必要的 Assistant Editor

---

## 🔴 常见编译错误

### 错误 1：SnapKit 约束崩溃

**错误信息**：
```
Fatal error: Updated constraint could not find existing matching constraint to update
```

**原因**：使用 `updateConstraints` 更新从未在 `makeConstraints` 中设置过的约束

**解决方案**：
```swift
// ❌ 错误：直接更新未设置的约束
bar.snp.updateConstraints { make in
    make.height.equalTo(newHeight)  // 崩溃！
}

// ✅ 正确：先在 makeConstraints 中设置初始值
bar.snp.makeConstraints { make in
    make.height.equalTo(baseHeight)  // 设置初始值
}

// 之后可以安全更新
bar.snp.updateConstraints { make in
    make.height.equalTo(newHeight)
}
```

**详细说明**：使用 `/snapkit` skill

---

### 错误 2：Swift 6 并发错误

**错误信息**：
```
Main actor-isolated property 'xxx' cannot be mutated from a non-isolated deinit
Capture of 'self' with non-Sendable type in a @Sendable closure
```

**原因**：
- `deinit` 访问 @MainActor 属性
- 闭包未标记 `@Sendable`

**解决方案**：
```swift
// ❌ 错误：deinit 访问 MainActor 属性
@MainActor
class MyViewController: UIViewController {
    deinit {
        self.waveformView.stopAnimation()  // 错误！
    }
}

// ✅ 正确：使用 nonisolated deinit
@MainActor
class MyViewController: UIViewController {
    nonisolated deinit {
        // 资源清理在 viewWillDisappear 中完成
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        waveformView.stopAnimation()
    }
}
```

**详细说明**：使用 `/swift6-concurrency` skill

---

### 错误 3：颜色/字体函数不存在

**错误信息**：
```
Cannot find 'UIColorHex' in scope
Cannot find 'PingFangSCRegular' in scope
```

**原因**：使用了项目中不存在的函数

**解决方案**：
```swift
// ❌ 错误：项目中不存在这些函数
view.backgroundColor = UIColorHex("#020120")
label.font = PingFangSCRegular(14)

// ✅ 正确：使用项目定义的函数
view.backgroundColor = UIColor_020120()
label.font = PingFangSCRegular(size: 14)
```

**详细说明**：使用 `/coding-standards` skill

---

### 错误 4：缺少头文件

**错误信息**：
```
'XXX-Swift.h' file not found
Could not build module 'XXX'
```

**原因**：
- Objective-C 和 Swift 桥接问题
- 缺少 import

**解决方案**：
```swift
// ✅ 确保在需要的文件中 import
#if SWIFT_PACKAGE
import XXX
#else
import XXX_Swift
#endif
```

---

### 错误 5：类型转换错误

**错误信息**：
```
Could not cast value of type 'NSDictionary' to 'NSArray'
```

**解决方案**：
```swift
// ❌ 强制转换（不安全）
let array = response as! [String]

// ✅ 安全转换
if let dict = response as? [String: Any] {
    // 处理字典
}
```

---

## 🔧 CocoaPods 相关错误

### 错误 1：pod install 失败

**错误信息**：
```
[!] Unable to find a specification for `XXX`
```

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

### 错误 2：依赖冲突

**错误信息**：
```
[!] There are multiple dependencies with different names for the same module
```

**解决方案**：
```bash
# 检查 Podfile 中的版本冲突
# 确保使用 .xcworkspace 而不是 .xcodeproj
open XiaoYueYun.xcworkspace
```

---

### 错误 3：Swift 版本不匹配

**错误信息**：
```
The Swift pod `XXX` requires a higher deployment target
```

**解决方案**：
在 Podfile 中设置统一的部署目标：
```ruby
platform :ios, '13.0'  # 项目使用 iOS 13+
```

---

## 📱 证书和签名问题

### 错误 1：Code Signing 错误

**错误信息**：
```
No signing certificate "iOS Development" found
Provisioning profile doesn't include signing certificate
```

**解决方案**：
1. 打开 Xcode → Project → Signing & Capabilities
2. 选择正确的 Team
3. 确保 Bundle Identifier 唯一
4. 在 Apple Developer 生成新的 Provisioning Profile

---

### 错误 2：Bundle ID 冲突

**错误信息**：
```
The application's Bundle Identifier is already in use
```

**解决方案**：
1. 修改 Bundle Identifier（添加唯一后缀）
2. 或删除 Apple Developer 中的旧 App ID

---

## 🧹 SwiftLint 错误

### 错误 1：SwiftLint 警告

**错误信息**：
```
Line Length Violation: Line should be 120 characters or less
Force Cast Violation: Force casts should be avoided
```

**解决方案**：
```bash
# 自动修复可以修复的问题
swiftlint --autocorrect

# 检查但不自动修复
swiftlint
```

**注意**：项目的 SwiftLint 配置较为宽松，大多数规则已禁用。

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
open XiaoYueYun.xcworkspace

# ❌ 不要使用
open XiaoYueYun.xcodeproj
```

---

### 问题 2：架构设置错误

**错误信息**：
```
Building for iOS Simulator, but the linked framework 'XXX' was built for iOS
```

**解决方案**：
1. Project → Build Settings → Architectures
2. 设置 Excluded Architectures 为 `arm64` (for Simulator)

---

## 🔍 调试技巧

### 1. 查看完整错误信息

```bash
# 使用 xcodebuild 查看完整编译日志
xcodebuild -workspace XiaoYueYun.xcworkspace \
           -scheme XiaoYueYun \
           -configuration Debug \
           clean build 2>&1 | tee build.log
```

### 2. 清理并重新编译

```bash
# 在 Xcode 中
# 1. Product → Clean Build Folder (Cmd + Shift + K)
# 2. 关闭 Xcode
# 3. 删除 DerivedData
# 4. 重新打开 Xcode
# 5. 重新编译
```

---

## 📞 获取帮助

如果以上方案都无法解决问题：

1. **记录完整错误信息**：截图或复制错误文本
2. **检查最近修改**：是否刚添加了新代码或依赖
3. **查看相关 skill**：使用 `/snapkit`、`/swift6-concurrency`、`/coding-standards`

---

## 🎯 错误快速索引

| 错误关键词 | 可能原因 | 解决方案 |
|-----------|---------|---------|
| `Updated constraint could not find` | SnapKit 约束错误 | `/snapkit` skill |
| `Main actor-isolated` | Swift 6 并发错误 | `/swift6-concurrency` skill |
| `UIColorHex` | 颜色函数错误 | `/coding-standards` skill |
| `pod install` | CocoaPods 错误 | 清理缓存重新安装 |
| `Code Signing` | 证书问题 | 检查 Team 和 Profile |
| `Provisioning profile` | 描述文件问题 | 重新生成 Profile |
