---
description: Use when writing SnapKit constraints, Auto Layout code, makeConstraints, updateConstraints, remakeConstraints, or working with view layout/positioning. Also use when encountering constraint-related code, leading/trailing vs left/right, or setting up UI constraints with snp.

中文触发关键词：SnapKit约束、布局约束、AutoLayout、makeConstraints、updateConstraints、remakeConstraints、约束报错、约束崩溃、布局错误、leading/trailing、left/right、UI布局、视图定位、分屏约束、约束冲突。
---

# SnapKit 约束规范

按照 iOS 项目的 SnapKit 约束编码规范进行开发。

## ⚠️ 最重要规则（强制要求）

**使用 `updateConstraints` 更新约束时，必须先在 `makeConstraints` 中设置过该约束，否则必崩溃！**

```swift
// ❌ 错误：更新从未设置过的约束 → 崩溃
// Fatal error: Updated constraint could not find existing matching constraint to update
placeholderView.snp.updateConstraints { make in
    make.width.equalTo(labelWidth)  // 崩溃！之前没有设置过 width
}

// ✅ 正确：先设置初始约束，再更新
placeholderView.snp.makeConstraints { make in
    make.center.equalToSuperview()
    make.height.equalTo(50)
    make.width.equalTo(100)  // 设置初始宽度约束
}

// 之后可以安全更新
placeholderView.snp.updateConstraints { make in
    make.width.equalTo(newWidth)  // ✅ 正常工作
}
```

**核心原则**：
1. `makeConstraints` - 创建新约束（第一次设置）
2. `updateConstraints` - 更新已有约束（必须之前设置过）
3. `remakeConstraints` - 清除所有约束并重新创建

---

## 约束属性编写顺序（强制要求）

**必须按照以下顺序编写约束**：

1. **上** - `top`
2. **左** - `leading`（不是 left）
3. **下** - `bottom`
4. **右** - `trailing`（不是 right）
5. **中心** - `center` / `centerX` / `centerY`
6. **宽** - `width`
7. **高** - `height`

### 正确示例

```swift
// ✅ 正确：按照 上→左→下→右→中心→宽→高 的顺序
iconImageView.snp.makeConstraints { make in
    make.top.equalTo(titleLabel.snp.bottom).offset(8)
    make.leading.equalToSuperview().offset(15)
    make.bottom.lessThanOrEqualToSuperview().offset(-15)
    make.trailing.equalToSuperview().offset(-15)
    make.centerX.equalToSuperview()
    make.width.height.equalTo(50)
}
```

### 错误示例

```swift
// ❌ 错误：顺序混乱
iconImageView.snp.makeConstraints { make in
    make.width.height.equalTo(50)        // 宽高应该在最后
    make.top.equalToSuperview().offset(8)
    make.centerX.equalToSuperview()     // center 应该在上下左右之后
}

// ❌ 错误：使用 left/right 而不是 leading/trailing
view.snp.makeConstraints { make in
    make.left.equalToSuperview()        // 应该用 leading
    make.right.equalToSuperview()       // 应该用 trailing
}
```

## 必须使用 leading/trailing 而不是 left/right

### 为什么？

| 属性 | 说明 |
|------|------|
| `left/right` | 绝对方向，始终指向屏幕的左/右侧 |
| `leading/trailing` | 相对方向，根据语言方向自动调整 |

**好处**：
- 支持从右到左（RTL）语言（如阿拉伯语、希伯来语）
- 符合 Apple 国际化最佳实践
- 项目编码规范强制要求

### 示例

```swift
// ✅ 正确：使用 leading/trailing
titleLabel.snp.makeConstraints { make in
    make.leading.equalToSuperview().offset(12)
    make.trailing.equalToSuperview().offset(-12)
}

// ❌ 错误：使用 left/right
titleLabel.snp.makeConstraints { make in
    make.left.equalToSuperview().offset(12)
    make.right.equalToSuperview().offset(-12)
}
```

## 约束编写风格要点

### 相对于父视图 vs 相对于其他视图

```swift
// ✅ 相对于父视图时，使用 equalToSuperview()
make.top.equalToSuperview().offset(10)
make.leading.equalToSuperview().offset(12)

// ✅ 相对于其他视图时，使用 equalTo(view.snp.xxx)
make.top.equalTo(titleLabel.snp.bottom).offset(8)
make.leading.equalTo(titleLabel.snp.trailing).offset(12)

// ❌ 错误：相对于父视图却用 equalTo(self.xxx)
make.top.equalTo(self.snp.top).offset(10)  // 不推荐，应使用 equalToSuperview()

// ❌ 错误：相对于其他视图却用 equalToSuperview()
make.top.equalToSuperview().offset(8)  // 如果想相对于 titleLabel 就错了
```

### 其他风格要点

```swift
// ✅ 每个约束单独一行，清晰易读
make.top.equalToSuperview().offset(10)
make.leading.equalToSuperview().offset(12)
make.bottom.equalToSuperview().offset(-10)
make.trailing.equalToSuperview().offset(-12)
make.height.equalTo(50)

// ✅ 使用 .offset() 设置间距
make.top.equalToSuperview().offset(10)

// ✅ 宽高相同时可以合并
make.width.height.equalTo(50)
```

## 约束更新规则（重要）

### updateConstraints 使用规范

```swift
// ❌ 错误：使用 updateConstraints 更新从未设置过的约束会导致崩溃
// Fatal error: Updated constraint could not find existing matching constraint to update
bar.snp.updateConstraints { make in
    make.height.equalTo(newHeight)  // 崩溃！之前没有设置过 height
}

// ✅ 正确：先在 makeConstraints 中设置初始约束，再使用 updateConstraints 更新
bar.snp.makeConstraints { make in
    make.top.equalToSuperview()
    make.width.equalTo(50)
    make.height.equalTo(baseHeight)  // 设置初始高度约束
}

// 之后可以安全更新
bar.snp.updateConstraints { make in
    make.height.equalTo(newHeight)  // ✅ 正常工作
}
```

### 标准约束写法

```swift
private func setupConstraints() {
    titleLabel.snp.makeConstraints { make in
        make.leading.equalToSuperview().offset(12)
        make.centerY.equalToSuperview()
    }

    confirmButton.snp.makeConstraints { make in
        make.trailing.equalToSuperview().offset(-12)
        make.centerY.equalToSuperview()
        make.height.equalTo(30)
    }
}

// ✅ 复杂约束使用 updateConstraints
private func updateTitleConstraints() {
    titleView.snp.updateConstraints { make in
        make.height.equalTo(isExpanded ? 200 : 100)
    }
}
```

## 完整示例：ViewController 中的约束

```swift
class MyViewController: UIViewController {

    private lazy var containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    private lazy var titleLabel: UILabel = {
        var lab = UILabel()
        lab.font = PingFangSCMedium(size: 15)
        lab.textColor = UIColor_FFFFFF()
        return lab
    }()

    private func addLayout() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.height.equalTo(20)
        }

        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.height.equalTo(30)
        }
    }
}
```

## 检查清单

写完 SnapKit 约束后，检查以下项目：

- [ ] 约束顺序是否正确：top → leading → bottom → trailing → center → width → height
- [ ] 是否使用 `leading/trailing` 而不是 `left/right`
- [ ] 每个约束是否单独一行
- [ ] 是否使用 `equalToSuperview()` 而不是 `equalTo(view)`
- [ ] `updateConstraints` 中的约束是否在 `makeConstraints` 中设置过
