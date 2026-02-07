---
name: ios-permissions
description: Use when requesting iOS permissions like microphone, camera, photo library, location, push notifications, contacts, calendar, Bluetooth, Face ID/Touch ID, or when adding NSXXXUsageDescription keys to Info.plist. Also use when encountering permission-related crashes, Swift 6 concurrency warnings with permission closures, or iOS 17+ AVAudioApplication API changes for microphone access.

中文触发关键词：权限请求、麦克风权限、相机权限、相册权限、位置权限、推送通知、蓝牙权限、联系人权限、日历权限、Face ID、Touch ID、Info.plist权限、NSMicrophoneUsageDescription、NSCameraUsageDescription、权限被拒、Swift6并发权限、AVAudioApplication、AVAudioSession。
version: 1.0.0
license: MIT
author: Link-Start <https://github.com/Link-Start>
---

# iOS 权限请求统一处理指南

本 skill 提供 iOS 所有常见权限的完整处理方案，确保兼容性和 Swift 6 并发安全。

## 🎯 使用场景

**触发条件**：当代码涉及以下任何权限请求时，必须参考本指南：
- 麦克风 `NSMicrophoneUsageDescription`
- 相机 `NSCameraUsageDescription`
- 相册 `NSPhotoLibraryUsageDescription` / `NSPhotoLibraryAddUsageDescription`
- 位置 `NSLocationWhenInUseUsageDescription`
- 推送通知
- 联系人 `NSContactsUsageDescription`
- 日历 `NSCalendarsUsageDescription`
- 蓝牙 `NSBluetoothAlwaysUsageDescription`
- 面容 ID `NSFaceIDUsageDescription`

---

## 📋 权限请求模板

### 1. 麦克风权限（iOS 17+ 兼容）

```swift
/// 请求麦克风权限
private func requestMicrophonePermission(completion: @escaping @Sendable (Bool) -> Void) {
    if #available(iOS 17.0, *) {
        // iOS 17+ 使用 AVAudioApplication（静态方法）
        AVAudioApplication.requestRecordPermission { granted in
            completion(granted)
        }
    } else {
        // iOS 17 以下使用 AVAudioSession
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            completion(granted)
        }
    }
}
```

### 2. 相机权限

```swift
/// 请求相机权限（所有 iOS 版本统一）
private func requestCameraPermission(completion: @escaping @Sendable (Bool) -> Void) {
    AVCaptureDevice.requestAccess(for: .video) { granted in
        completion(granted)
    }
}
```

### 3. 相册权限（读取 + 写入）

```swift
import Photos

/// 请求相册读取权限
private func requestPhotoLibraryPermission(completion: @escaping @Sendable (Bool) -> Void) {
    PHPhotoLibrary.requestAuthorization { status in
        DispatchQueue.main.async {
            completion(status == .authorized)
        }
    }
}

/// 请求相册写入权限（iOS 14+）
@available(iOS 14.0, *)
private func requestPhotoLibraryAddPermission(completion: @escaping @Sendable (Bool) -> Void) {
    PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
        DispatchQueue.main.async {
            completion(status == .authorized)
        }
    }
}
```

### 4. 推送通知权限

```swift
import UserNotifications

/// 请求推送通知权限
private func requestNotificationPermission(completion: @escaping @Sendable (Bool) -> Void) {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if let error = error {
            print("推送权限请求失败: \(error)")
        }
        DispatchQueue.main.async {
            completion(granted)
        }
    }
}
```

---

## ⚠️ 常见错误清单

### 错误 1：闭包未标记 @Sendable（Swift 6 必须）

```swift
// ❌ 错误
private func requestPermission(completion: @escaping (Bool) -> Void) { ... }

// ✅ 正确
private func requestPermission(completion: @escaping @Sendable (Bool) -> Void) { ... }
```

### 错误 2：权限回调中使用 Task { @MainActor in }

```swift
// ❌ 错误：可能导致崩溃，特别是首次请求时
AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
    guard let self = self else { return }
    Task { @MainActor in  // 崩溃风险！
        if granted {
            self.doSomething()
        }
    }
}

// ✅ 正确：使用 DispatchQueue.main.async
AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
    guard let self = self else { return }
    DispatchQueue.main.async {
        if granted {
            self.doSomething()
        }
    }
}
```

### 错误 3：iOS 17+ 麦克风权限使用错误 API

```swift
// ❌ 错误：使用实例方法
AVAudioApplication.shared.requestRecordPermission { ... }

// ✅ 正确
if #available(iOS 17.0, *) {
    AVAudioApplication.requestRecordPermission { granted in ... }
} else {
    AVAudioSession.sharedInstance().requestRecordPermission { granted in ... }
}
```

### 错误 4：Info.plist 缺少权限描述

```xml
<!-- ✅ 必须添加所有使用的权限描述 -->
<key>NSMicrophoneUsageDescription</key>
<string>需要使用麦克风进行录音</string>

<key>NSCameraUsageDescription</key>
<string>需要使用相机拍摄视频</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>需要访问相册选择照片</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>需要保存照片到相册</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>需要获取您的位置信息</string>

<key>NSContactsUsageDescription</key>
<string>需要访问联系人</string>

<key>NSCalendarsUsageDescription</key>
<string>需要访问日历</string>

<key>NSBluetoothAlwaysUsageDescription</key>
<string>需要使用蓝牙连接设备</string>

<key>NSFaceIDUsageDescription</key>
<string>需要使用面容 ID 验证身份</string>
```

---

## 🎯 快速检查清单

在提交权限相关代码前，确保：

- [ ] Info.plist 已添加对应的 `NSXXXUsageDescription`
- [ ] 闭包参数标记了 `@Sendable`
- [ ] UI 更新使用 `DispatchQueue.main.async`
- [ ] iOS 17+ 使用了正确的 API（特别是麦克风权限）
- [ ] 模拟器有特殊处理（如需要）
- [ ] 权限被拒有友好提示和引导跳转设置
