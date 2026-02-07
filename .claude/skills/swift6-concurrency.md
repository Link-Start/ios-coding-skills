---
description: Use when writing Swift code in iOS projects. Also use when encountering @MainActor classes, deinit, nonisolated, Task {}, DispatchQueue.main.async, @Sendable closures, actor isolation, Swift 6 concurrency warnings, Swift 6 concurrency errors, or setting UI/gradient colors from background threads. Essential for iOS development with Swift 6 strict concurrency.

中文触发关键词：Swift6并发、Swift 6并发、@MainActor、deinit错误、nonisolated、Task{}、DispatchQueue.main.async、@Sendable、actor隔离、并发警告、并发错误、线程安全、UI线程、主线程更新UI、闭包并发、Sendable类型。
---

# Swift 6 并发安全规范

## ⚠️ 最重要规则

### 1. @MainActor 类中的 deinit

**`deinit` 不在 MainActor 隔离范围内，不能直接访问 MainActor 属性或调用 MainActor 方法**

```swift
@MainActor
class MyViewController: UIViewController {

    // ❌ 错误：deinit 访问 MainActor 属性 → 编译错误
    deinit {
        self.waveformView.stopAnimation()  // 错误！
        self.stopRecording()  // 错误！
    }

    // ✅ 正确：使用 nonisolated deinit
    nonisolated deinit {
        // deinit 不在 MainActor 隔离范围内
        // 主要清理工作已在 viewWillDisappear 中完成
        print("MyViewController 已释放")
    }

    // ✅ 正确：在 viewWillDisappear 中处理清理工作
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // 停止录音
        if currentState == .recording {
            stopRecording()
        }

        // 停止动画
        waveformView.stopAnimation()
    }
}
```

**核心原则**：
1. `deinit` 不能访问 `@MainActor` 类的属性和方法
2. 使用 `nonisolated deinit` 标记
3. 资源清理工作放在 `viewWillDisappear` 或 `viewDidDisappear` 中

### 2. 网络请求闭包必须标记 @Sendable

**闭包参数需要添加 `@Sendable` 标记，避免并发警告**

```swift
// ✅ 正确：闭包参数标记 @Sendable
func fetchData(completion: @Sendable @escaping (Result<Data, Error>) -> Void) {
    // 网络请求...
}

// ✅ 正确：在回调闭包中使用 @Sendable
typealias SuccessBlock = @Sendable ([String: Any]) -> Void
typealias FailureBlock = @Sendable (Error) -> Void

class OPNetClient {
    static func getData(success: @Sendable @escaping SuccessBlock,
                       failure: @Sendable @escaping FailureBlock) {
        // 网络请求实现...
    }
}
```

### 3. 设置 UI 必须在主线程

**UI 更新（包括渐变色）必须在主线程执行**

```swift
// ✅ 正确：使用 DispatchQueue.main.async
DispatchQueue.main.async { [weak self] in
    guard let self = self else { return }

    // 设置渐变色
    let colors: [UIColor] = [
        UIColor_2D2C2C().withAlphaComponent(0.0),
        UIColor_2C2C2C().withAlphaComponent(0.52),
        UIColor_2A2A2B().withAlphaComponent(0.81)
    ]
    self.gradientView.kj_gradientBgColor(withColors: colors,
                                        locations: [0.0, 0.2, 0.4],
                                        start: CGPoint(x: 0.5, y: 0),
                                        end: CGPoint(x: 0.5, y: 1))
}

// ❌ 错误：Task { @MainActor in } 可能导致时序问题
Task { @MainActor in
    // 这种写法可能导致时序问题
    self.gradientView.kj_gradientBgColor(...)
}

// ❌ 错误：在非主线程设置 UI
DispatchQueue.global().async {
    self.view.kj_gradientBgColor(...)  // 错误！可能崩溃
}
```

### 4. 网络请求后更新 UI

```swift
// ✅ 正确：网络请求完成后，在主线程更新 UI
OPNetClient.getData(success: { [weak self] response in
    guard let self = self else { return }

    DispatchQueue.main.async {
        // 在主线程设置渐变色
        let colors: [UIColor] = [
            UIColor_2D2C2C().withAlphaComponent(0.0),
            UIColor_2C2C2C().withAlphaComponent(0.52)
        ]
        self.headerView.kj_gradientBgColor(withColors: colors, ...)
    }

}, failure: { [weak self] error in
    guard let self = self else { return }
    // 失败处理
})
```

---

## 常见错误和解决方案

### 错误 1：deinit 访问 MainActor 属性

**错误信息**：
```
Main actor-isolated property 'xxx' cannot be mutated from a non-isolated deinit
```

**解决方案**：
1. 添加 `nonisolated` 关键字
2. 将清理逻辑移到 `viewWillDisappear`

### 错误 2：闭包未标记 @Sendable

**错误信息**：
```
Capture of 'self' with non-Sendable type 'xxx' in a @Sendable closure
```

**解决方案**：
```swift
// 在闭包参数类型前添加 @Sendable
func someFunction(completion: @Sendable @escaping () -> Void) {
    // ...
}
```

### 错误 3：在非主线程更新 UI

**症状**：
- UI 更新不生效
- 偶发性崩溃
- Swift 6 并发警告

**解决方案**：
```swift
DispatchQueue.main.async { [weak self] in
    guard let self = self else { return }
    // UI 更新代码
}
```

### 错误 4：Task { @MainActor in } 导致崩溃

**症状**：
- 使用 `Task { @MainActor in }` 时偶尔崩溃
- 动画或渐变色设置不生效

**原因**：
- Task 的执行时机不确定
- 可能与视图生命周期冲突

**解决方案**：
```swift
// 使用 DispatchQueue.main.async 替代 Task { @MainActor in }
DispatchQueue.main.async { [weak self] in
    guard let self = self else { return }
    // UI 代码
}
```

---

## Swift 6 并发检查清单

写完代码后检查：

- [ ] @MainActor 类使用 `nonisolated deinit`
- [ ] 闭包参数标记 `@Sendable`
- [ ] UI 操作在主线程（使用 `DispatchQueue.main.async`）
- [ ] 渐变色设置在主线程
- [ ] 网络请求闭包使用 `[weak self]`
- [ ] 避免在非主线程直接访问 UI 属性

---

## 相关资源

- SnapKit 约束规范：使用 `/snapkit` skill
- 编码规范：使用 `/coding-standards` skill
- XIB 转 Swift：使用 `/xib-to-swift` skill
