# iOS Coding Skills

一套通用的 iOS 开发规范 skill，适用于 Claude Code (claude.ai/code)。

## 包含的 Skills

| Skill | 用途 |
|-------|------|
| `/coding-standards` | iOS 编码规范（颜色、字体、命名、UI 组件、网络请求等） |
| `/snapkit` | SnapKit 约束规范 |
| `/swift6-concurrency` | Swift 6 并发安全（@MainActor、deinit、@Sendable） |
| `/xcode-errors` | Xcode 常见错误和解决方案 |
| `/xib-to-swift` | XIB 转 Swift 规范 |
| `/oc-to-swift` | OC 转 Swift 规范 |
| `/ios-permissions` | iOS 权限请求处理 |
| `/canary-test` | **金丝雀测试（自动启用）** - 检测 AI 上下文丢失，自动为项目创建 `.canary.md` 文件 |

## 安装方式

### 方式 1：通过插件市场安装（推荐）

```bash
# 安装插件
/plugin marketplace add Link-Start/ios-coding-skills

# 启用插件
/plugin enable ios-coding-skills
```

### 方式 2：手动复制 skill 文件

将 `skills/` 目录下的文件复制到你项目的 `.claude/skills/` 目录：

```bash
cp -r ~/Desktop/ios-coding-skills/skills/* /你的项目/.claude/skills/
```

### 方式 3：使用安装脚本

```bash
cd ~/Desktop/ios-coding-skills
chmod +x install.sh
./install.sh /你的项目路径
```

### 方式 4：Git Submodule

```bash
cd 你的项目
git submodule add https://github.com/Link-Start/ios-coding-skills.git .claude/skills
```

## 使用方法

安装后，在 Claude Code 中使用 `/skill-name` 命令：

```
请使用 /coding-standards 查看颜色使用规范
请使用 /snapkit 查看约束编写规范
```

## 插件结构

```
ios-coding-skills/
├── .claude-plugin/
│   └── plugin.json         # 插件配置（含金丝雀测试自动初始化）
├── skills/                 # Skill 文件
│   ├── coding-standards/
│   │   └── SKILL.md
│   ├── snapkit/
│   │   └── SKILL.md
│   ├── swift6-concurrency/
│   │   └── SKILL.md
│   ├── xib-to-swift/
│   │   └── SKILL.md
│   ├── oc-to-swift/
│   │   └── SKILL.md
│   ├── xcode-errors/
│   │   └── SKILL.md
│   ├── ios-permissions/
│   │   └── SKILL.md
│   └── canary-test/
│       └── SKILL.md        # 金丝雀测试（自动启用）
├── scripts/
│   └── init-canary.sh      # 金丝雀自动初始化脚本
├── .claude/skills/         # 旧版技能文件（兼容性）
├── install.sh              # 安装脚本
├── LICENSE                 # MIT 许可证
└── README.md               # 本文件
```

## 技能列表

### coding-standards
- 颜色和字体使用规范
- 命名规范
- UI 组件初始化
- UICollectionView 注册和使用
- 网络图片加载
- BEEProgressHUD 使用
- 网络请求规范
- 相对宽度计算
- 渐变色设置
- RxSwift 内存管理
- MARK 分组规范

### snapkit
- 约束属性编写顺序
- leading/trailing vs left/right
- 约束编写风格要点
- 约束更新规则
- updateConstraints 使用规范

### swift6-concurrency
- @MainActor 类中的 deinit
- 网络请求闭包 @Sendable 标记
- 设置 UI 必须在主线程
- 网络请求后更新 UI
- Swift 6 并发检查清单

### xib-to-swift
- 转换步骤
- 属性声明规范
- 颜色转换规则
- 字体转换规则
- 渐变背景处理
- 圆角处理

### oc-to-swift
- 网络请求写法差异
- 页面跳转和 dismiss
- 内存管理
- 类型转换
- 常见错误

### xcode-errors
- Xcode 界面问题（分屏失效、频繁崩溃）
- 常见编译错误
- CocoaPods 相关错误
- 证书和签名问题
- SwiftLint 错误
- 清理缓存步骤

### ios-permissions
- 麦克风、相机、相册权限
- 位置、推送通知权限
- 蓝牙、联系人、日历权限
- 面容 ID / 触摸 ID
- Swift 6 并发安全
- 常见错误清单

## 兼容性

- **Claude Code**: 完全兼容 ✅
- **其他 AI 工具**: 可参考内容，需格式转换

---

## 其他 AI 工具使用方法

本仓库的技能文件使用 Claude Code 特定的 YAML front matter 格式，其他 AI 工具不能直接使用。但你可以参考以下方式复用内容：

### Cursor（推荐）

在项目根目录创建 `.cursorrules` 文件：

```rules
# iOS 编码规范

- 颜色使用：使用项目定义的 UIColor_XXXXX() 函数
- 字体使用：PingFangSCXXX(size:) 格式，必须带 size: 参数标签
- SnapKit 约束顺序：top → leading → bottom → trailing → center → width → height
- 必须使用 leading/trailing 而不是 left/right
- RxSwift 闭包：使用 [weak self] 和 guard let self
- MARK 注释：必须使用中文
```

### 转换为其他格式

| 目标工具 | 转换方式 |
|---------|---------|
| Cursor | 复制内容到 `.cursorrules` |
| Continue | 转换为 `config.json` 规则 |
| Codeium | 复制内容到项目文档 |
| 其他 AI | 直接复制相关规范内容到对话 |

---

## 插件开发

如果你想开发类似的 Claude Code 插件，请参考 [PLUGIN_DEVELOPMENT_GUIDE.md](PLUGIN_DEVELOPMENT_GUIDE.md) 文档。

该文档包含：
- 插件 vs 技能的区别
- 查询过程和参考方案
- 具体实现步骤
- 验证方法和常见问题
- 快速模板和参考资料

快速开始：
```bash
# 验证插件格式
claude plugin validate .

# 查看已安装插件
/plugin list
```

---

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License

## 相关资源

- [Claude Code 文档](https://claude.ai/code)
- [Claude Code 插件开发文档](https://github.com/anthropics/claude-code)
- [SnapKit 文档](http://snapkit.io/docs/)
- [Swift 6 并发](https://www.swift.org/documentation/concurrency/)

---

## 🐤 金丝雀测试功能（自动启用）

### 什么是金丝雀测试？

金丝雀测试是一种用于检测 AI 上下文丢失的技术。在长时间的 AI 对话中，AI 可能会"遗忘"之前的指令或约定。金丝雀测试通过创建一个标记文件，监控 AI 是否还记得项目约定。

### 自动启用

本插件内置金丝雀测试功能，安装后会自动：

1. ✅ 在项目根目录创建 `.canary.md` 金丝雀文件
2. ✅ 金丝雀文件包含唯一 ID 和项目约定
3. ✅ AI 会记住金丝雀 ID 以保持上下文
4. ✅ 可通过 HUD 或手动检查金丝雀状态

### 金丝雀文件内容

项目根目录的 `.canary.md` 文件包含：

- **金丝雀 ID**：唯一标识符，用于检测 AI 是否还记得
- **项目约定**：iOS 编码规范的摘要
- **状态说明**：活跃/丢失状态的定义
- **恢复方法**：上下文丢失时的处理方法

### 使用方法

#### 检查金丝雀状态

```bash
# 查看金丝雀文件
cat .canary.md

# 让 AI 检查
在对话中询问："请读取 .canary.md 文件中的金丝雀 ID"
```

#### 如果 AI 遗忘了金丝雀 ID

1. 使用 `/coding-standards` 重新加载项目约定
2. 让 AI 重新读取 `.canary.md` 文件
3. 开始新的对话会话

#### 禁用金丝雀测试

```bash
# 删除金丝雀文件
rm .canary.md
```

### 与 My Claude HUD 集成

如果你同时使用了 [My Claude HUD](https://github.com/Link-Start/my-claude-hud) 插件，金丝雀测试会自动集成到 HUD 状态栏中：

```
Canary: 🐤 活跃 (ajc86e...) <1m
```

### 技术原理

1. **创建标记**：安装插件时自动创建包含唯一 ID 的标记文件
2. **记忆保持**：AI 通过记住金丝雀 ID 保持项目约定
3. **状态检测**：定期检查 AI 是否还记得金丝雀 ID
4. **及时提醒**：在上下文丢失时及时提醒开发者

### 常见问题

**Q: 金丝雀文件会影响项目吗？**
A: 不会。`.canary.md` 只是一个标记文件，不会被编译到应用中。

**Q: 需要手动维护吗？**
A: 不需要。一旦创建，金丝雀文件会自动工作。

**Q: 可以禁用吗？**
A: 可以。删除 `.canary.md` 文件即可。

**Q: 金丝雀 ID 被遗忘怎么办？**
A: 使用 `/coding-standards` 重新加载项目约定。

---
