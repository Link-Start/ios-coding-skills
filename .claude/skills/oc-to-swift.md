---
description: Use when converting Objective-C code to Swift, porting .m/.h files to Swift, migrating OC implementations, or translating Objective-C syntax. Also use when encountering differences between OC and Swift network request patterns (trailing closures vs labeled closures), OC macros in Swift context (pushVC, dismissCurrentVc), weak self patterns, type conversions, or Swift-specific closures and memory management.
---

# OC 转 Swift 注意事项

本文档记录了 iOS 项目中 Objective-C 代码转换为 Swift 代码时的关键差异和正确写法。

## 网络请求写法差异（重要）

### Swift 写法（项目强制要求）

```swift
// ✅ 正确：Swift 尾随闭包写法
BEEProgressHUD.share().showProgress(withMessage: "加载中", graceTime: 0.2)

OPNetClient.getAIDigitalHumanList(withPage: 1, limit: 10) { [weak self] response in
    guard let self = self else {return}

    let dict = response as! [String: Any]
    let model = dict.kj.model(AIDigitalHumanListDataModel.self)

    // 处理成功 - 不需要手动 dismiss

} failure: {[weak self] error in
    guard let self = self else {return}

    // 处理失败 - 不需要手动 dismiss
    // 如果有占位图，需要刷新占位图
    self.collectionView.reloadEmptyDataSet()
}
```

### OC 写法（对比参考）

```objc
// ❌ 这是 OC 的写法，Swift 中不要使用
[OPNetClient getAIDigitalHumanListWithPage:1 limit:10 complete:^(id response) {
    // 处理成功
} failure:^(NSError *error) {
    // 处理失败
}];
```

### 关键区别

| 特性 | Swift 写法 | OC 写法 |
|------|-----------|---------|
| 方法名 | `getAIDigitalHumanList` | `getAIDigitalHumanListWithPage` |
| 闭包方式 | 尾随闭包 | 带标签闭包 |
| complete | 不需要 | `complete: ` |
| failure | `} failure: {[weak self] error in` | `}, failure: ` |

## 页面跳转和dismiss

### Swift 原生写法

```swift
// ✅ push 跳转
navigationController?.pushViewController(vc, animated: true)

// ✅ modal 跳转
present(vc, animated: true)

// ✅ dismiss 当前页面
dismiss(animated: true)

// ✅ pop 返回
navigationController?.popViewController(animated: true)
```

### OC 宏定义（不要在 Swift 中使用）

```objc
// ❌ 这些是 OC 宏定义，Swift 中不存在
pushVC(vc);           // OC 宏
presentVC(vc);        // OC 宏
dismissCurrentVc(self); // OC 宏
```

## 内存管理

### Swift 闭包模式

```swift
// ✅ 正确：所有闭包都要用 weak self 和 guard let
buttonAction = { [weak self] in
    guard let self = self else { return }
    self.doSomething()
}

// ✅ 网络请求 - success 和 failure 都需要
OPNetClient.getData { [weak self] response in
    guard let self = self else { return }
    self.handleSuccess(response)
} failure: { [weak self] error in
    guard let self = self else { return }
    self.handleError(error)
}
```

### OC Weak-Strong Dance

```objc
// OC 写法对比
__weak typeof(self) weakSelf = self;
self.completionBlock = ^{
    __strong typeof(weakSelf) strongSelf = weakSelf;
    if (!strongSelf) return;
    [strongSelf doSomething];
};
```

## 类型转换

```swift
// ✅ Swift 安全转换
if let dict = response as? [String: Any],
   let model = dict.kj.model(DataModel.self) {
    // 处理模型
}

// ❌ 避免强制转换（除非确定类型）
let dict = response as! [String: Any]  // 仅在确定类型时使用
```

## 集合操作

```swift
// Swift 数组操作
let dataArray: [Model] = []

// 检查空
if dataArray.isEmpty { }

// 遍历
for item in dataArray { }

// 索引访问
let item = dataArray[index]
```

## 枚举使用

```swift
// ✅ Swift 枚举使用点语法
btn.setTitleColor(UIColor_FFFFFF(), for: .normal)
view.contentMode = .scaleAspectFill

// ❌ 不要省略枚举类型（部分情况）
btn.setTitleColor(UIColor_FFFFFF(), for: UIControl.State.normal) // 冗长
```

## Selector 写法

```swift
// ✅ Swift selector
button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)

@objc private func buttonAction(_ sender: UIButton) {
    // 处理点击
}
```

## 字符串处理

```swift
// ✅ Swift 字符串插值
let message = "用户\(name)登录成功"

// ✅ Swift 字符串操作
let text = "Hello"
let uppercased = text.uppercased()
let isEmpty = text.isEmpty
```

## 初始化模式

```swift
// ✅ Swift 闭包初始化
private lazy var label: UILabel = {
    let lab = UILabel()
    lab.font = PingFangSCRegular(size: 14)
    lab.textColor = UIColor_FFFFFF()
    return lab
}()

// ❌ 不要这样写
private lazy var label: UILabel = {
    let lab = UILabel()
    lab.font = PingFangSCRegular(14)  // 错误：缺少 size: 标签
    lab.textColor = .white            // 错误：应使用 UIColor_FFFFFF()
    return lab
}()
```

## 常见错误

1. **网络请求使用 OC 风格的带标签闭包**
   ```swift
   // ❌ 错误
   OPNetClient.getData(success: { }, failure: { })

   // ✅ 正确
   OPNetClient.getData { } failure: { }
   ```

2. **使用 OC 宏定义**
   ```swift
   // ❌ 错误：这些宏在 Swift 中不存在
   pushVC(vc)
   dismissCurrentVc(self)

   // ✅ 正确：使用 Swift 原生写法
   navigationController?.pushViewController(vc, animated: true)
   dismiss(animated: true)
   ```

3. **忘记 weak self**
   ```swift
   // ❌ 错误：可能内存泄漏
   OPNetClient.getData { response in
       self.handleSuccess(response)  // 强引用 self
   }

   // ✅ 正确
   OPNetClient.getData { [weak self] response in
       guard let self = self else { return }
       self.handleSuccess(response)
   }
   ```
