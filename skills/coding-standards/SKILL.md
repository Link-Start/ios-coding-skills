---
name: coding-standards
description: Use when writing Swift code, implementing features, or creating UI components in iOS projects. Also use when encountering color/font usage, lazy var initialization, UIButton/UILabel/UIImageView patterns, UICollectionView registration, network requests, BEEProgressHUD usage, relative width calculations, gradient backgrounds, rich text with YYKit, RxSwift memory management, or MARK comment formatting. For SnapKit constraints, use /snapkit skill. For Swift 6 concurrency issues (@MainActor, deinit, @Sendable, Task), use /swift6-concurrency skill.

中文触发关键词：编码规范、代码规范、颜色使用、字体使用、lazy var、UIButton、UILabel、UIImageView、UICollectionView、网络请求、BEEProgressHUD、相对宽度、渐变色、富文本、YYKit、RxSwift、内存管理、MARK注释、命名规范、初始化顺序、fatalError。
version: 1.0.0
license: MIT
author: Link-Start <https://github.com/Link-Start>
---

# iOS 编码规范

按照 iOS 项目的编码规范进行开发。

## ⚠️ 重要提醒：写 UI 代码时必须遵循 SnapKit 规范

**当编写任何包含 UI 布局的代码时（ViewController、View、addLayout 等），必须遵循以下 SnapKit 规范**：

1. **约束顺序**：top → leading → bottom → trailing → center → width → height
2. **必须使用 `leading/trailing`，绝对不要用 `left/right`**
3. **每个约束单独一行**
4. **相对于父视图时用 `equalToSuperview()`，相对于其他视图时用 `equalTo(view.snp.xxx)`**

详细规范请使用 `/snapkit` skill。

---

## 颜色和字体

### 颜色使用
```swift
// ✅ 正确：使用项目定义的颜色函数
view.backgroundColor = UIColor_020120()
label.textColor = UIColor_FFFFFF()
button.setTitleColor(UIColor_00CBE0(), for: .normal)

// ❌ 错误：项目中不存在 UIColorHex 函数
view.backgroundColor = UIColorHex("#020120")
```

### 字体使用
```swift
// ✅ 正确：必须带 size: 参数标签
label.font = PingFangSCRegular(size: 14)
button.titleLabel?.font = PingFangSCMedium(size: 15)

// ❌ 错误：省略 size: 参数标签会导致编译错误
label.font = PingFangSCRegular(14)
```

## 命名规范

- ViewController: 名称 + VC 后缀（如 `HomePageVC`）
- 自定义 View: 描述性名称 + View 后缀
- 工具类: LS 前缀 + 用途 + Tool/Helper
- MARK 注释：**必须使用中文**

## UI 组件初始化

### lazy var 闭包内部临时变量命名
```swift
// UIView → let v
private lazy var containerView: UIView = {
    let v = UIView()
    v.backgroundColor = .clear
    return v
}()

// UILabel → var lab
private lazy var titleLabel: UILabel = {
    var lab = UILabel()
    lab.font = PingFangSCMedium(size: 15)
    lab.textColor = UIColor_FFFFFF()
    return lab
}()

// UIImageView → let imgV
private lazy var headImgV: UIImageView = {
    let imgV = UIImageView()
    imgV.contentMode = .scaleAspectFill
    return imgV
}()

// UIButton → var btn
private lazy var confirmButton: UIButton = {
    var btn = UIButton(type: .custom)
    btn.adjustsImageWhenDisabled = false
    btn.adjustsImageWhenHighlighted = false
    btn.setTitle("确定", for: .normal)
    return btn
}()
```

### UIButton 创建规范
```swift
// ✅ 正确：使用 var btn
private lazy var confirmButton: UIButton = {
    var btn = UIButton(type: .custom)
    btn.adjustsImageWhenDisabled = false
    btn.adjustsImageWhenHighlighted = false
    btn.setTitle("确定", for: .normal)
    btn.setTitleColor(UIColor_FFFFFF(), for: .normal)
    btn.titleLabel?.font = PingFangSCRegular(size: 14)
    btn.backgroundColor = UIColor_2F665C()
    btn.layer.cornerRadius = 12.5
    btn.layer.masksToBounds = true
    return btn
}()
```

### 初始化顺序
```swift
override init(frame: CGRect) {
    super.init(frame: frame)
    addSubViews()       // 1. 添加子视图
    addLayout()         // 2. 设置约束
    addSubViewsConfig() // 3. 配置按钮和事件
}

// 支持 storyboard/xib
required init?(coder: NSCoder) {
    super.init(coder: coder)
    addSubViews()
    addLayout()
    addSubViewsConfig()
}

// 不支持 storyboard/xib（纯代码）
required init?(coder: NSCoder) {
    fatalError("init（coder:）尚未实现")
}
```

## UICollectionView 注册和使用

```swift
// ✅ 正确：使用项目扩展方法
collectionView.registerCellClass_ls(HomePageAIDigitalHumanSelectCell.self)
let cell: HomePageAIDigitalHumanSelectCell = collectionView.dequeueReusableCell_ls(for: indexPath)

// ❌ 错误：不要使用系统原生方法
collectionView.register(HomePageAIDigitalHumanSelectCell.self, forCellWithReuseIdentifier: "...")
let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "...", for: indexPath) as! HomePageAIDigitalHumanSelectCell
```

## 网络图片加载

```swift
// ✅ 非头像图片 - 不需要 placeholder
headImgV.setImageURL(URL(string: model.thumb ?? ""))

// ✅ 头像图片 - 需要 placeholder
headIconImgV.setImageURL(URL(string: model.avatar ?? ""), placeholder: UIImage(named: "default_head_icon"))
```

## BEEProgressHUD 使用

```swift
// ✅ 普通加载提示 - 网络请求方法中已封装 dismiss
BEEProgressHUD.share().showProgress(withMessage: "加载中")
BEEProgressHUD.share().showProgress(withMessage: "加载中", graceTime: 0.2)

// ✅ Other 加载提示 - 必须手动 dismiss
BEEProgressHUD.share().showOtherLoadingProgress()
// ... 网络请求 ...
BEEProgressHUD.share().dismissOtherLoadingProgress()

// ✅ 独立提示（自动消失）
BEEProgressHUD.share().showSuccess(withMessage: "成功")
BEEProgressHUD.share().showFail(withMessage: "失败")
```

## 网络请求规范

### Swift 写法（强制要求）
```swift
// ✅ Swift 尾随闭包写法（项目强制要求）
BEEProgressHUD.share().showProgress(withMessage: "加载中", graceTime: 0.2)

OPNetClient.getData(success: { [weak self] response in
    guard let self = self else {return}
    // 处理成功（不需要手动 dismiss）
}, failure: {[weak self] error in
    guard let self = self else {return}
    // 处理失败（不需要手动 dismiss）
})
```

## 相对宽度计算

```swift
// ✅ 正确：使用 kLS_relative_width（小写 w）
let h = kLS_relative_width(230)

// ❌ 错误：OC 宏定义
let h = kLS_relative_Width(230)
```

## 渐变色设置

```swift
// ✅ 使用项目扩展方法
let colors: [UIColor] = [
    UIColor_2D2C2C().withAlphaComponent(0.0),
    UIColor_2C2C2C().withAlphaComponent(0.52)
]
view.kj_gradientBgColor(withColors: colors, locations: [0, 0.5, 1], start: CGPoint(x: 0.5, y: 0), end: CGPoint(x: 0.5, y: 1))

// ⚠️ Swift 6 并发要求：必须在主线程执行
DispatchQueue.main.async { [weak self] in
    guard let self = self else { return }
    self.view.kj_gradientBgColor(withColors: colors, ...)
}
```

## RxSwift 内存管理

```swift
// ✅ 正确：使用 weak self 和 guard let
LSRxSwiftBridge.ls_bindButtonTap(self.bottomBtn) { [weak self] in
    guard let self = self else { return }
    self.doSomething()
}
```

## MARK 分组规范（中文）

所有 MARK 注释必须使用中文：

```swift
class MyViewController: UIViewController {
    // MARK: - 属性
    // MARK: - 生命周期
    // MARK: - 设置
    // MARK: - 数据
    // MARK: - 按钮事件
    // MARK: - 公开方法
    // MARK: - 私有方法
}
```

## 相关技能

- SnapKit 约束规范：使用 `/snapkit` skill
- Swift 6 并发规范：使用 `/swift6-concurrency` skill
- XIB 转 Swift：使用 `/xib-to-swift` skill
- Xcode 错误处理：使用 `/xcode-errors` skill
