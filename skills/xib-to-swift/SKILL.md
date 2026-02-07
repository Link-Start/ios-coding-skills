---
name: xib-to-swift
description: Use when converting XIB or Storyboard files to pure Swift code, replacing Interface Builder layouts with SnapKit constraints, or migrating .xib files to programmatic UI. Also use when translating XIB color values to UIColor_XXXXX() functions, converting XIB fonts to PingFangSCXXX(size:) format, handling CAGradientLayer to kj_gradientBgColor migration, or setting up UIView initialization order (addSubViews, addLayout, addSubViewsConfig, otherConfig).

中文触发关键词：XIB转Swift、Storyboard转Swift、Interface Builder转代码、纯代码UI、xib转代码、颜色转换、字体转换、渐变色转换、CAGradientLayer、初始化顺序、addSubViews、addLayout、addSubViewsConfig、XIB迁移、移除XIB、Swift替代XIB。
version: 1.0.0
license: MIT
author: Link-Start <https://github.com/Link-Start>
---

# XIB 转 Swift 注意事项

本文档记录了将 XIB/Storyboard 文件转换为纯 Swift 代码时的注意事项和步骤。

## 转换步骤

### 1. 分析 XIB 结构

首先仔细阅读 XIB 文件，理解：
- 视图层级结构
- 约束关系
- 属性设置（字体、颜色、圆角等）
- 连接的 IBOutlet 和 IBAction

### 2. 创建 Swift 文件

按照项目命名规范创建对应的 Swift 文件：
- ViewController: `NameVC.swift`
- View: `NameView.swift`
- CollectionViewCell: `NameCell.swift`

### 3. 按顺序实现初始化方法

```swift
override init(frame: CGRect) {
    super.init(frame: frame)
    addSubViews()       // 1. 添加子视图
    addLayout()         // 2. 设置约束
    addSubViewsConfig() // 3. 配置按钮和事件
    otherConfig()       // 4. 其他配置
}

// 支持 storyboard/xib（如果需要）
required init?(coder: NSCoder) {
    super.init(coder: coder)
    addSubViews()
    addLayout()
    addSubViewsConfig()
    otherConfig()
}

// 不支持 storyboard/xib（纯代码）
required init?(coder: NSCoder) {
    fatalError("init（coder:）尚未实现")
}
```

## 属性声明规范

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
    lab.text = "标题"
    return lab
}()

// UIImageView → let imgV
private lazy var headImgV: UIImageView = {
    let imgV = UIImageView()
    imgV.contentMode = .scaleAspectFill
    imgV.clipsToBounds = true
    return imgV
}()

// UIButton → var btn
private lazy var confirmButton: UIButton = {
    var btn = UIButton(type: .custom)
    btn.adjustsImageWhenDisabled = false
    btn.adjustsImageWhenHighlighted = false
    btn.setTitle("确定", for: .normal)
    btn.setTitleColor(UIColor_FFFFFF(), for: .normal)
    btn.titleLabel?.font = PingFangSCRegular(size: 14)
    return btn
}()
```

## 颜色转换规则

### XIB 中的颜色转换为代码

```swift
// ❌ XIB 中显示的颜色值，不要使用 UIColorHex
// #FFFFFF  → UIColorHex("#FFFFFF")     // 错误！项目中不存在此函数

// ✅ 正确的转换方式
// #FFFFFF  → UIColor_FFFFFF()
// #00CBE0  → UIColor_00CBE0()
// #D1D6D9  → UIColor_D1D6D9()
// #DCE1E8  → UIColor_DCE1E8()
// #020120  → UIColor_020120()
```

### 添加缺失的颜色定义

如果需要的颜色在 `ColorMacroSwift.swift` 中不存在，按以下格式添加：

```swift
// 在 ConfigSwift/ColorMacroSwift.swift 中添加
func UIColor_XXXXXX() -> UIColor {
    return UIColor.kj_color(withHexString: "#XXXXXX")
}
```

## 字体转换规则

```swift
// ❌ 错误：省略 size: 参数标签
label.font = PingFangSCRegular(14)    // 编译错误

// ✅ 正确：必须带 size: 参数标签
label.font = PingFangSCRegular(size: 14)
```

## 渐变背景处理

### 使用 KJ 扩展方法（推荐）

```swift
// ✅ 使用项目扩展方法
let colors: [UIColor] = [
    UIColor_2D2C2C().withAlphaComponent(0.0),
    UIColor_2C2C2C().withAlphaComponent(0.52)
]
view.kj_gradientBgColor(withColors: colors,
                        locations: [0.0, 0.2, 0.4],
                        start: CGPoint(x: 0.5, y: 0),
                        end: CGPoint(x: 0.5, y: 1))

// ⚠️ Swift 6 并发要求：必须在主线程执行
DispatchQueue.main.async { [weak self] in
    guard let self = self else { return }
    self.view.kj_gradientBgColor(withColors: colors, ...)
}
```

## 圆角处理

### 使用 KJ 扩展方法

```swift
// ✅ 使用项目扩展方法设置部分圆角
view.ls_applyRoundedCorners(radius: 10, corners: [.bottomLeft, .bottomRight])

// ✅ 简单圆角可以直接设置
view.layer.cornerRadius = 10
view.layer.masksToBounds = true
view.layer.borderWidth = 1
view.layer.borderColor = UIColor_DCE1E8().cgColor
```

## 转换检查清单

转换完成后，检查以下项目：

- [ ] 所有颜色使用 `UIColor_XXXXX()` 函数
- [ ] 所有字体使用 `PingFangSCXXX(size:)` 格式
- [ ] 所有 MARK 注释使用中文
- [ ] UIButton 使用 `var btn` 并设置 adjusts 属性
- [ ] 渐变色使用 `kj_gradientBgColor` 方法
- [ ] UICollectionView 使用 `registerCellClass_ls` 和 `dequeueReusableCell_ls`
- [ ] 闭包回调使用 `[weak self]` 和 `guard let self`

---

**详细的 SnapKit 约束规范请使用 `/snapkit` skill。**
