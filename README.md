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

## 安装

### 方式 1：手动复制

将 `.claude/skills/` 目录下的文件复制到你项目的 `.claude/skills/` 目录：

```bash
cp -r ~/Desktop/ios-coding-skills/.claude/skills/* /你的项目/.claude/skills/
```

### 方式 2：使用安装脚本

```bash
cd ~/Desktop/ios-coding-skills
chmod +x install.sh
./install.sh /你的项目路径
```

### 方式 3：Git Submodule（推荐）

```bash
cd 你的项目
git submodule add https://github.com/你的用户名/ios-coding-skills.git .claude/skills
```

## 使用方法

安装后，在 Claude Code 中使用 `/skill-name` 命令：

```
请使用 /coding-standards 查看颜色使用规范
请使用 /snapkit 查看约束编写规范
```

## 技能列表

### coding-standards.md
- 颜色和字体使用规范
- 命名规范
- UI 组件初始化
- UICollectionView 注册和使用
- 网络图片加载
- BEEProgressHUD 使用
- 网络请求规范
- 相对宽度计算
- 渐变色设置
- 富文本设置
- RxSwift 内存管理
- MARK 分组规范

### snapkit.md
- 约束属性编写顺序
- leading/trailing vs left/right
- 约束编写风格要点
- 约束更新规则
- updateConstraints 使用规范

### swift6-concurrency.md
- @MainActor 类中的 deinit
- 网络请求闭包 @Sendable 标记
- 设置 UI 必须在主线程
- 网络请求后更新 UI
- Swift 6 并发检查清单

### xib-to-swift.md
- 转换步骤
- 属性声明规范
- 颜色转换规则
- 字体转换规则
- 渐变背景处理
- 圆角处理
- 相对宽度计算

### oc-to-swift.md
- 网络请求写法差异
- 页面跳转和 dismiss
- 内存管理
- 类型转换
- 常见错误

### xcode-errors.md
- Xcode 界面问题（分屏失效、频繁崩溃）
- 常见编译错误
- CocoaPods 相关错误
- 证书和签名问题
- SwiftLint 错误
- 清理缓存步骤

### ios-permissions.md
- 麦克风、相机、相册权限
- 位置、推送通知权限
- 蓝牙、联系人、日历权限
- 面容 ID / 触摸 ID
- Swift 6 并发安全
- 常见错误清单

## 项目结构

```
ios-coding-skills/
├── .claude/
│   └── skills/              # Skill 文件
│       ├── coding-standards.md
│       ├── snapkit.md
│       ├── swift6-concurrency.md
│       ├── xib-to-swift.md
│       ├── oc-to-swift.md
│       ├── xcode-errors.md
│       └── ios-permissions.md
├── install.sh               # 安装脚本
├── LICENSE                  # MIT 许可证
└── README.md                # 本文件
```

## 兼容性

- **Claude Code**: 完全兼容 ✅
- **其他 AI 工具**: 可参考内容，需格式转换

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License

## 相关资源

- [Claude Code 文档](https://claude.ai/code)
- [SnapKit 文档](http://snapkit.io/docs/)
- [Swift 6 并发](https://www.swift.org/documentation/concurrency/)
