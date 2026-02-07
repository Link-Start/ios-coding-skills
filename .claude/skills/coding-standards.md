---
description: Use when writing Swift code, implementing features, or creating UI components in iOS projects. Also use when encountering color/font usage, lazy var initialization, UIButton/UILabel/UIImageView patterns, UICollectionView registration, network requests, BEEProgressHUD usage, relative width calculations, gradient backgrounds, rich text with YYKit, RxSwift memory management, or MARK comment formatting. For SnapKit constraints, use /snapkit skill. For Swift 6 concurrency issues (@MainActor, deinit, @Sendable, Task), use /swift6-concurrency skill.

中文触发关键词：编码规范、代码规范、颜色使用、字体使用、lazy var、UIButton、UILabel、UIImageView、UICollectionView、网络请求、BEEProgressHUD、相对宽度、渐变色、富文本、YYKit、RxSwift、内存管理、MARK注释、命名规范、初始化顺序、fatalError。
---

# iOS 编码规范

按照 iOS 项目的编码规范进行开发。

## ⚠️ 重要提醒：写 UI 代码时必须遵循 SnapKit 规范

**当编写任何包含 UI 布局的代码时（ViewController、View、addLayout 等），必须遵循以下 SnapKit 规范**：

1. **约束顺序**：top → leading → bottom → trailing → center → width → height
2. **必须使用 `leading/trailing`，绝对不要用 `left/right`**
3. **每个约束单独一行**
4. **相对于父视图时用 `equalToSuperview()`，相对于其他视图时用 `equalTo(view.snp.xxx)`**

详细规范请参考：SnapKit 约束规范在 `CLAUDE.md` 的 SnapKit 约束编写风格部分

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
    fatalError("init（coder:）尚未实现.init(coder:) has not been implemented")
}
```

### fatalError 编码习惯
```swift
// ✅ 项目常用的 fatalError 写法（中英文混合）
fatalError("init（coder:）尚未实现.init(coder:) has not been implemented")

// ✅ 简化的中文写法
fatalError("init（coder:）尚未实现")
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

// 注意：model.thumb 是字符串，需要先用 URL(string:) 转换
```

## BEEProgressHUD 使用

```swift
// ✅ 普通加载提示 - 网络请求方法中已封装 dismiss，不需要手动调用
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

OPNetClient.getAIDigitalHumanList(withPage: 1, limit: 10) { [weak self] response in
    guard let self = self else {return}

    let dict = response as! [String: Any]
    let model = dict.kj.model(DataModel.self)

    // 处理成功（不需要手动 dismiss）

} failure: {[weak self] error in
    guard let self = self else {return}

    // 处理失败（不需要手动 dismiss）
    // 如果有占位图，需要刷新占位图
    // self.collectionView.reloadEmptyDataSet()
}
```

### 关键区别
| 特性 | Swift 写法 | OC 写法 |
|------|-----------|---------|
| 方法名 | `getAIDigitalHumanList` | `getAIDigitalHumanListWithPage` |
| 闭包方式 | 尾随闭包 | 带标签闭包 |
| complete | 不需要 | `complete: ` |
| failure | `} failure: {[weak self] error in}` | `}, failure: ` |

## 相对宽度计算

```swift
// ✅ 正确：使用 kLS_relative_width（小写 w，Swift 闭包属性）
let h = kLS_relative_width(230)  // 已包含 ceil 向上取整

// ❌ 错误：OC 宏定义
let h = kLS_relative_Width(230)  // OC 中的宏定义，Swift 中不存在
```

## 渐变色设置

### 使用项目扩展方法（强制要求）

```swift
// ✅ 使用项目扩展方法
let colors: [UIColor] = [
    UIColor_2D2C2C().withAlphaComponent(0.0),
    UIColor_2C2C2C().withAlphaComponent(0.52)
]
view.kj_gradientBgColor(withColors: colors, locations: [0, 0.5, 1], start: CGPoint(x: 0.5, y: 0), end: CGPoint(x: 0.5, y: 1))

// 或使用 CGPointMake（项目常见写法）
view.kj_gradientBgColor(withColors: colors, locations: [0, 0.5, 1], start: CGPointMake(0.13, 0), end: CGPointMake(1, 1))
```

### Swift 6 并发要求（强制要求）

**设置渐变色必须在主线程执行，这是 Swift 6 的强制要求。详细的 Swift 6 并发规范请使用 `/swift6-concurrency` skill。**

## UILabel 撑开父视图时的设置

```swift
// ✅ 如果 label 需要撑开背景父视图（高度根据内容自适应）
lazy var tagLabel: UILabel = {
    var lab = UILabel()
    lab.font = PingFangSCRegular(size: 10)
    lab.textColor = UIColor_F9FEFF()
    lab.textAlignment = .center
    lab.text = "新"

    lab.backgroundColor = UIColor_F21F14()

    // 设置竖直方向优先级 - 必须！
    lab.setContentHuggingPriority(.required, for: .vertical)           // 抗拉伸
    lab.setContentCompressionResistancePriority(.required, for: .vertical)  // 抗压缩
    return lab
}()
```

## 富文本设置

```swift
// ✅ 使用 YYKit 扩展方法（项目统一写法）
func setPriceAttr(originalStr: String) {
    let attr = NSMutableAttributedString(string: originalStr)
    attr.font = PingFangSCMedium(size: 45)

    // 使用 YYKit 扩展方法设置不同部分的样式
    attr.setFont(PingFangSCRegular(size: 28), range: originalStr.ls_rangeOfString("¥"))
    attr.setFont(PingFangSCRegular(size: 17), range: originalStr.ls_rangeOfString("/年"))
    attr.setColor(UIColor_DAF6E7(), range: originalStr.ls_rangeOfString("/年"))

    priceLabel.attributedText = attr
}
```

## 常用工具方法和常量

### 屏幕尺寸
```swift
kLS_ScreenWidth          // 屏幕宽度
kLS_ScreenHeight         // 屏幕高度
kLS_TopHeight            // 顶部高度（状态栏 + 导航栏）
kSafeAreaBottom          // 底部安全区域高度
kLS_TabBarHeight         // TabBar 高度
```

### 全局方法
```swift
// 页面跳转
pushVC(viewController)              // push 跳转
presentVC(viewController)           // modal 跳转
jumpTabBarIndex(2)                  // 跳转到指定 Tab

// 视图扩展
view.ls_applyRoundedCorners(radius: 10, corners: [.bottomLeft, .bottomRight])
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

### @MainActor 类中的 deinit（强制要求）

**`deinit` 不在 MainActor 隔离范围内，不能直接访问 MainActor 属性或调用 MainActor 方法。详细的 Swift 6 并发规范请使用 `/swift6-concurrency` skill。**

核心原则：
1. `deinit` 不能访问 `@MainActor` 类的属性和方法
2. 使用 `nonisolated deinit` 标记
3. 资源清理工作放在 `viewWillDisappear` 或 `viewDidDisappear` 中

**注意**：SnapKit 约束规范已移至 `/snapkit` skill，请使用 `/snapkit` 命令查看。
