---
description: Use when converting XIB or Storyboard files to pure Swift code, replacing Interface Builder layouts with SnapKit constraints, or migrating .xib files to programmatic UI. Also use when translating XIB color values to UIColor_XXXXX() functions, converting XIB fonts to PingFangSCXXX(size:) format, handling CAGradientLayer to kj_gradientBgColor migration, or setting up UIView initialization order (addSubViews, addLayout, addSubViewsConfig, otherConfig).

中文触发关键词：XIB转Swift、Storyboard转Swift、Interface Builder转代码、纯代码UI、xib转代码、颜色转换、字体转换、渐变色转换、CAGradientLayer、初始化顺序、addSubViews、addLayout、addSubViewsConfig、XIB迁移、移除XIB、Swift替代XIB。
---

# XIB 转 Swift 注意事项

本文档记录了 iOS 项目中将 XIB/Storyboard 文件转换为纯 Swift 代码时的注意事项和步骤。

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
// ✅ 正确的初始化顺序
override init(frame: CGRect) {
    super.init(frame: frame)
    addSubViews()       // 1. 添加子视图
    addLayout()         // 2. 设置约束
    addSubViewsConfig() // 3. 配置按钮和事件
    otherConfig()       // 4. 其他配置（圆角、边框、渐变等）
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
    fatalError("init（coder:）尚未实现.init(coder:) has not been implemented")
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
// #00CBE0  → UIColorHex("#00CBE0")      // 错误！

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
label.font = PingFangSCMedium(15)      // 编译错误

// ✅ 正确：必须带 size: 参数标签
label.font = PingFangSCRegular(size: 14)
label.font = PingFangSCMedium(size: 15)
```

## 渐变背景处理

### 使用 KJ 扩展方法（推荐）

```swift
// ✅ 使用项目扩展方法
let colors: [UIColor] = [
    UIColor_2D2C2C().withAlphaComponent(0.0),
    UIColor_2C2C2C().withAlphaComponent(0.52),
    UIColor_2A2A2B().withAlphaComponent(0.81),
    UIColor_323333().withAlphaComponent(0.9),
    UIColor_2B2D30().withAlphaComponent(1.0)
]
view.kj_gradientBgColor(withColors: colors,
                        locations: [0.0, 0.2, 0.4, 0.7, 1.0],
                        start: CGPoint(x: 0.5, y: 0),
                        end: CGPoint(x: 0.5, y: 1))

// 或使用 CGPointMake（项目常见写法）
view.kj_gradientBgColor(withColors: colors,
                        locations: [0, 0.5, 1],
                        start: CGPointMake(0.13, 0),
                        end: CGPointMake(1, 1))
```

### 不使用 CAGradientLayer

```swift
// ❌ 不要手动创建 CAGradientLayer
let gradientLayer = CAGradientLayer()
gradientLayer.colors = colors.map { $0.cgColor }
// ... 其他配置
```

## 圆角处理

### 使用 KJ 扩展方法

```swift
// ✅ 使用项目扩展方法设置部分圆角
view.ls_applyRoundedCorners(radius: 10, corners: [.bottomLeft, .bottomRight])

// ✅ 或使用更详细的方法
view.ls_applyCustomCornerMask(cornerType: .allCornersRounded(radius: 10))
```

### 直接设置 layer 属性

```swift
// ✅ 简单圆角可以直接设置
view.layer.cornerRadius = 10
view.layer.masksToBounds = true

// ✅ 边框设置
view.layer.borderWidth = 1
view.layer.borderColor = UIColor_DCE1E8().cgColor
```

## 图片资源命名

### XIB 中的图片名称

XIB 中的图片资源名称遵循格式：`模块_页面_功能_状态`

```
homepage_AI数字人_homepage_bgImg
homepage_AI数字人_我的数字人icon
homepage_AI数字人_选择数字人形象_btn_新增数字人
my_980_个人信息_会员_皇冠
my_share_分享赚钱_btn_微信好友
```

### 图片加载

```swift
// ✅ 本地图片
iconImageView.image = UIImage(named: "homepage_AI数字人_我的数字人icon")
button.setImage(UIImage(named: "btn_image"), for: .normal)

// ✅ 网络图片 - 非头像（不需要 placeholder）
headImgV.setImageURL(URL(string: model.thumb ?? ""))

// ✅ 网络图片 - 头像（需要 placeholder）
headIconImgV.setImageURL(URL(string: model.avatar ?? ""),
                         placeholder: UIImage(named: "default_head_icon"))
```

## UICollectionView 转换

### 注册和复用

```swift
// ✅ 使用项目扩展方法
collectionView.registerCellClass_ls(HomePageAIDigitalHumanSelectCell.self)
let cell: HomePageAIDigitalHumanSelectCell = collectionView.dequeueReusableCell_ls(for: indexPath)

// ❌ 不要使用系统原生方法
collectionView.register(HomePageAIDigitalHumanSelectCell.self,
                       forCellWithReuseIdentifier: "...")
let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "...",
                                               for: indexPath) as! HomePageAIDigitalHumanSelectCell
```

## 富文本设置

### 使用 YYKit 扩展方法

```swift
// ✅ 使用 YYKit 扩展方法设置富文本
func setPriceAttr(originalStr: String) {
    let attr = NSMutableAttributedString(string: originalStr)
    attr.font = PingFangSCMedium(size: 45)

    // 使用 YYKit 扩展方法设置不同部分的样式
    attr.setFont(PingFangSCRegular(size: 28),
                 range: originalStr.ls_rangeOfString("¥"))
    attr.setFont(PingFangSCRegular(size: 17),
                 range: originalStr.ls_rangeOfString("/年"))
    attr.setColor(UIColor_DAF6E7(),
                  range: originalStr.ls_rangeOfString("/年"))

    priceLabel.attributedText = attr
}
```

## UILabel 撑开父视图设置

### 设置内容优先级

如果 label 需要撑开背景父视图（高度根据内容自适应）：

```swift
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

## MARK 注释规范

### 所有 MARK 必须使用中文

```swift
// ✅ 正确：使用中文 MARK
class MyViewController: UIViewController {

    // MARK: - 属性

    // MARK: - 生命周期

    // MARK: - 设置

    // MARK: - 数据

    // MARK: - 按钮事件

    // MARK: - 公开方法

    // MARK: - 私有方法
}

// ❌ 错误：使用英文 MARK
// MARK: - Properties
// MARK: - Lifecycle
```

## 相对宽度计算

### 使用正确的函数

```swift
// ✅ 向上取整（常用）- 使用 kLS_relative_width_ceil
let cell_h = kLS_relative_width_ceil(230)

// ✅ 向下取整 - 使用 kLS_relative_width_floor
let h = kLS_relative_width_floor(100)

// ⚠️ kLS_relative_width 等同于 kLS_relative_width_ceil（向上取整）
// 但建议明确使用 kLS_relative_width_ceil 使意图更清晰
let h = kLS_relative_width(230)  // 等同于 kLS_relative_width_ceil(230)
```

### 定义说明

| 函数 | 说明 | 取整方式 |
|------|------|----------|
| `kLS_relative_width_ceil` | 向上取整的宽度适配 | ceil(x) * ratio |
| `kLS_relative_width_floor` | 向下取整的宽度适配 | floor(x) * ratio |
| `kLS_relative_width` | 直接适配（等同于_ceil）| ceil(x) * ratio |

## 转换检查清单

转换完成后，检查以下项目：

- [ ] 所有颜色使用 `UIColor_XXXXX()` 函数
- [ ] 所有字体使用 `PingFangSCXXX(size:)` 格式
- [ ] 所有 MARK 注释使用中文
- [ ] UIButton 使用 `var btn` 并设置 `adjustsImageWhenDisabled/Highlighted`
- [ ] UIImageView 使用 `imgV` 变量名
- [ ] UILabel 使用 `lab` 变量名
- [ ] 渐变色使用 `kj_gradientBgColor` 方法
- [ ] 圆角使用 `ls_applyRoundedCorners` 或 layer 属性
- [ ] UICollectionView 使用 `registerCellClass_ls` 和 `dequeueReusableCell_ls`
- [ ] 闭包回调使用 `[weak self]` 和 `guard let self`
- [ ] fatalError 使用项目统一格式
- [ ] 相对宽度明确使用 `kLS_relative_width_ceil` 或 `kLS_relative_width_floor`

---

## SnapKit 约束编写规范

**详细的 SnapKit 约束规范请使用 `/snapkit` skill。**

核心要点：
- 严格按照 XIB 中的约束、宽高、颜色、字体去转换
- 约束顺序：top → leading → bottom → trailing → center → width → height
- 必须使用 `leading/trailing` 而不是 `left/right`
- `updateConstraints` 只能更新在 `makeConstraints` 中设置过的约束

转换约束时，对照 XIB 检查：

- [ ] 约束值是否与 XIB 一致（offset、width、height）
- [ ] 约束关系是否与 XIB 一致（相对于哪个视图）
- [ ] 约束优先级是否与 XIB 一致（equalTo / greaterThanOrEqualTo / lessThanOrEqualTo）
- [ ] 约束顺序是否遵循 上→左→下→右→中心→宽→高
- [ ] 没有添加 XIB 中不存在的约束
- [ ] 没有遗漏 XIB 中的约束
