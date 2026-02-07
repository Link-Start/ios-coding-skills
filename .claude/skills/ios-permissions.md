# iOS 权限请求统一处理指南

本 skill 提供 iOS 所有常见权限的完整处理方案，确保兼容性和 Swift 6 并发安全。

---

## 🎯 使用场景

**触发条件**：当代码涉及以下任何权限请求时，必须参考本指南：
- 麦克风 `NSMicrophoneUsageDescription`
- 相机 `NSCameraUsageDescription`
- 相册 `NSPhotoLibraryUsageDescription` / `NSPhotoLibraryAddUsageDescription`
- 位置 `NSLocationWhenInUseUsageDescription`
- 推送通知
- 联系人 `NSContactsUsageDescription`
- 日历 `NSCalendarsUsageDescription`
- 提醒事项 `NSRemindersUsageDescription`
- 蓝牙 `NSBluetoothAlwaysUsageDescription`
- 语音识别 `NSSpeechRecognitionUsageDescription`
- Siri `NSSiriUsageDescription`
- 健康数据 `NSHealthShareUsageDescription` / `NSHealthUpdateUsageDescription`
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

### 4. 位置权限

```swift
import CoreLocation

/// 请求位置权限（使用时）
private func requestLocationPermission(completion: @escaping @Sendable (Bool) -> Void) {
    let manager = CLLocationManager()
    manager.requestWhenInUseAuthorization()
    // 代理回调在 CLLocationManagerDelegate 中处理
}

// MARK: - CLLocationManagerDelegate
extension YourViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async { [weak self] in
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                // 权限已授予
                self?.handleLocationGranted()
            }
        }
    }
}
```

### 5. 推送通知权限

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

### 6. 蓝牙权限（iOS 13+）

```swift
import CoreBluetooth

/// 请求蓝牙权限
func requestBluetoothPermission(completion: @escaping @Sendable (Bool) -> Void) {
    if #available(iOS 13.1, *) {
        let manager = CBCentralManager(delegate: nil, queue: nil)
        completion(manager.state == .poweredOn)
    } else {
        // iOS 13.1 以下需要手动请求
        completion(true)
    }
}
```

### 7. 联系人权限（iOS 9+）

```swift
import Contacts

/// 请求联系人权限
func requestContactsPermission(completion: @escaping @Sendable (Bool) -> Void) {
    CNContactStore().requestAccess(for: .contacts) { granted, error in
        if let error = error {
            print("联系人权限请求失败: \(error)")
        }
        DispatchQueue.main.async {
            completion(granted)
        }
    }
}
```

### 8. 日历权限

```swift
import EventKit

/// 请求日历权限
func requestCalendarPermission(completion: @escaping @Sendable (Bool) -> Void) {
    let store = EKEventStore()
    store.requestAccess(to: .event) { granted, error in
        if let error = error {
            print("日历权限请求失败: \(error)")
        }
        DispatchQueue.main.async {
            completion(granted)
        }
    }
}
```

### 9. 面容 ID / 触摸 ID

```swift
import LocalAuthentication

/// 请求生物识别权限
func requestBiometricPermission(completion: @escaping @Sendable (Bool, Error?) -> Void) {
    let context = LAContext()
    var error: NSError?

    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "需要验证身份") { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    } else {
        DispatchQueue.main.async {
            completion(false, error)
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
// ❌ 错误 1：使用实例方法
AVAudioApplication.shared.requestRecordPermission { ... }

// ❌ 错误 2：使用旧方法名
AVAudioApplication.requestRecordPermissionWithCompletionHandler { ... }

// ✅ 正确
if #available(iOS 17.0, *) {
    AVAudioApplication.requestRecordPermission { granted in ... }
} else {
    AVAudioSession.sharedInstance().requestRecordPermission { granted in ... }
}
```

### 错误 4：Info.plist 缺少权限描述

```xml
<!-- ❌ 缺少权限描述会导致崩溃或无法弹出权限弹窗 -->

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

<key>NSSpeechRecognitionUsageDescription</key>
<string>需要使用语音识别</string>

<key>NSFaceIDUsageDescription</key>
<string>需要使用面容 ID 验证身份</string>
```

### 错误 5：权限回调不在主线程更新 UI

```swift
// ❌ 错误：直接在回调中更新 UI（可能在后台线程）
PHPhotoLibrary.requestAuthorization { status in
    if status == .authorized {
        self.updateUI()  // 崩溃风险！
    }
}

// ✅ 正确：确保在主线程更新 UI
PHPhotoLibrary.requestAuthorization { status in
    DispatchQueue.main.async { [weak self] in
        if status == .authorized {
            self?.updateUI()
        }
    }
}
```

---

## 📝 通用权限请求模式

所有权限请求都应遵循这个模式：

```swift
/// 通用权限请求模板
private func requestSomePermission(completion: @escaping @Sendable (Bool) -> Void) {
    // 1. 检查是否是模拟器（可选，根据需求）
    if kLS_isSimulator() {
        // 模拟器处理：直接返回或跳过
        completion(true)
        return
    }

    // 2. 版本兼容性检查（如需要）
    if #available(iOS 17.0, *) {
        // iOS 17+ 的 API
        NewAPI.requestPermission { granted in
            completion(granted)
        }
    } else {
        // 旧版本 API
        OldAPI.requestPermission { granted in
            completion(granted)
        }
    }

    // 3. 在调用处确保 UI 更新在主线程
    requestSomePermission { [weak self] granted in
        guard let self = self else { return }
        DispatchQueue.main.async {
            if granted {
                self.handlePermissionGranted()
            } else {
                BEEProgressHUD.share().showFail(withMessage: "需要相关权限")
            }
        }
    }
}
```

---

## 🔍 检测当前权限状态

```swift
import AVFoundation

/// 检查麦克风权限状态
func checkMicrophonePermission() -> Bool {
    if #available(iOS 17.0, *) {
        return AVAudioApplication.shared.recordPermission == .granted
    } else {
        return AVAudioSession.sharedInstance().recordPermission == .granted
    }
}

/// 检查相机权限状态
func checkCameraPermission() -> Bool {
    return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
}

/// 检查相册权限状态
func checkPhotoLibraryPermission() -> Bool {
    return PHPhotoLibrary.authorizationStatus() == .authorized
}
```

---

## 🚀 权限被拒后的处理

```swift
private func handlePermissionDenied() {
    let alert = UIAlertController(
        title: "需要权限",
        message: "请在设置中开启相关权限",
        preferredStyle: .alert
    )

    alert.addAction(UIAlertAction(title: "取消", style: .cancel))
    alert.addAction(UIAlertAction(title: "去设置", style: .default) { _ in
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    })

    present(alert, animated: true)
}
```

---

## 📊 权限状态枚举参考

```swift
// 相机权限状态
AVCaptureDevice.AuthorizationStatus:
- notDetermined    // 未询问（首次）
- authorized       // 已授权
- denied          // 已拒绝
- restricted      // 受限制（家长控制等）

// 相册权限状态
PHAuthorizationStatus:
- notDetermined   // 未询问
- restricted      // 受限制
- denied          // 已拒绝
- authorized      // 已授权
- limited         // 有限访问（iOS 14+）

// 位置权限状态
CLAuthorizationStatus:
- notDetermined   // 未询问
- restricted      // 受限制
- denied          // 已拒绝
- authorizedAlways    // 始终授权
- authorizedWhenInUse // 使用时授权
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

---

## 🔄 自动更新记录

当遇到新的权限相关问题时，请更新本 skill 并记录：

| 日期 | 权限类型 | 问题描述 | 解决方案 |
|------|---------|---------|---------|
| 2025-02-06 | 麦克风 | iOS 17+ API 变化，`AVAudioSession` → `AVAudioApplication` | 使用 `if #available(iOS 17.0, *)` 版本兼容 |
| 2025-02-06 | 所有权限 | Swift 6 并发警告 `Capture of 'completion' with non-Sendable type` | 闭包参数添加 `@Sendable` 标记 |
| 2025-02-06 | 所有权限 | 模拟器首次请求权限时崩溃（使用 `Task { @MainActor in }`） | 改用 `DispatchQueue.main.async` |
