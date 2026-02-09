---
name: canary-test
description: 自动为 iOS 项目启用金丝雀测试功能，用于检测 AI 上下文丢失。插件安装后自动启用，会在项目根目录创建 .canary.md 金丝雀文件，并在后续开发中监控 AI 是否仍然记得项目约定和上下文。

中文触发关键词：金丝雀、canary、上下文丢失、context loss、AI 记忆、项目约定。
version: 1.0.0
license: MIT
author: Link-Start <https://github.com/Link-Start>
auto_enable: true
---

# 金丝雀测试（Canary Testing）

## 什么是金丝雀测试？

金丝雀测试是一种用于检测 AI 上下文丢失的技术。在长时间的 AI 对话中，随着上下文窗口的接近满载，AI 可能会"遗忘"之前的指令或约定。金丝雀测试通过在项目目录中创建一个标记文件，并在后续对话中检查 AI 是否还记得这个标记，从而判断上下文是否仍然完整。

## 自动启用说明

本 skill 已设置为 `auto_enable: true`，安装 ios-coding-skills 插件后会自动启用。一旦启用，会自动为项目创建金丝雀文件。

## 金丝雀文件内容

项目根目录的 `.canary.md` 文件包含：

```markdown
# iOS 项目金丝雀测试标记

<!-- CANARY_TEST_START -->
金丝雀 ID: {自动生成的唯一ID}
创建时间: {创建时间}
项目类型: iOS 项目
<!-- CANARY_TEST_END -->

## 说明

这是一个 iOS 项目的金丝雀测试标记，用于检测 AI 是否仍然记得项目约定和上下文。

## 金丝雀 ID

当前项目的金丝雀 ID：`{金丝雀 ID}`

当你在对话中看到这个 ID 时，说明 AI 仍然记得项目的上下文。

## 项目约定（iOS Coding Skills）

本项目遵循以下 iOS 编码规范：

1. **颜色使用**：使用项目定义的 UIColor_XXXXX() 函数
2. **字体使用**：PingFangSCXXX(size:) 格式，必须带 size: 参数标签
3. **SnapKit 约束顺序**：top → leading → bottom → trailing → center → width → height
4. **必须使用 leading/trailing**，而不是 left/right
5. **RxSwift 闭包**：使用 [weak self] 和 guard let self
6. **MARK 注释**：必须使用中文
7. **Swift 6 并发**：网络请求闭包标记 @Sendable，UI 更新在主线程
8. **UICollectionView**：必须先注册 cell 再使用
9. **BEEProgressHUD**：网络请求时显示，请求结束后隐藏

## 状态指示

- 🐤 活跃：AI 仍然记得金丝雀和项目约定
- ⚠️ 丢失：AI 可能已经遗忘了上下文，需要重新提醒

## 如果 AI 遗忘了金丝雀 ID

如果 AI 在后续对话中无法正确回忆起金丝雀 ID，说明上下文可能已丢失。此时可以：

1. 重新提及项目约定：请使用 `/coding-standards` 查看完整编码规范
2. 重新加载金丝雀文件：让 AI 重新读取 `.canary.md` 文件
3. 开始新的对话会话：清理上下文，重新开始
```

## 检查金丝雀状态

你可以通过以下方式检查金丝雀状态：

### 方式 1：直接查看金丝雀文件
```bash
cat .canary.md
```

### 方式 2：通过 HUD 查看（如果已安装 my-claude-hud）
如果你安装了 My Claude HUD 插件，HUD 会自动显示金丝雀状态：
- 🐤 活跃：AI 仍然记得金丝雀
- ⚠️ 丢失：AI 可能已经遗忘了上下文

### 方式 3：让 AI 检查
在对话中询问：
```
请读取 .canary.md 文件中的金丝雀 ID，告诉我你是否还记得
```

## 手动创建金丝雀文件

如果需要手动创建金丝雀文件（例如自动创建失败）：

1. 在项目根目录创建 `.canary.md` 文件
2. 复制上面的模板内容
3. 替换 `{金丝雀 ID}` 和 `{创建时间}`

金丝雀 ID 格式：`canary_{时间戳}_{随机字符}`

示例：`canary_1770603113880_ajc86e`

## 使用建议

1. **初次使用**：安装插件后，检查项目根目录是否自动生成了 `.canary.md` 文件
2. **定期检查**：在长时间的开发会话中，定期询问 AI 是否还记得金丝雀 ID
3. **上下文丢失时**：如果 AI 遗忘了金丝雀 ID，重新使用 `/coding-standards` 等技能提醒项目约定
4. **团队协作**：将 `.canary.md` 文件添加到版本控制，让团队成员都了解项目约定

## 与 My Claude HUD 集成

如果你同时使用了 My Claude HUD 插件，金丝雀测试会自动集成到 HUD 状态栏中，提供实时监控。

## 技术原理

金丝雀测试通过以下方式工作：

1. **创建标记**：在项目中创建包含唯一 ID 的标记文件
2. **定期检查**：HUD 或 AI 定期检查是否还记得金丝雀 ID
3. **状态判断**：根据是否能回忆起 ID 判断上下文是否完整
4. **及时提醒**：在上下文丢失时及时提醒开发者

## 相关资源

- My Claude HUD: https://github.com/Link-Start/my-claude-hud
- iOS Coding Skills 完整文档: `/coding-standards`
- SnapKit 约束规范: `/snapkit`
- Swift 6 并发安全: `/swift6-concurrency`

## 常见问题

### Q: 金丝雀文件会影响项目吗？
A: 不会。`.canary.md` 只是一个标记文件，不会被编译到应用中。

### Q: 需要手动维护金丝雀文件吗？
A: 不需要。一旦创建，金丝雀文件会自动工作。

### Q: 可以禁用金丝雀测试吗？
A: 可以。删除 `.canary.md` 文件即可，或在 My Claude HUD 配置中禁用。

### Q: 金丝雀 ID 被遗忘怎么办？
A: 使用 `/coding-standards` 重新加载项目约定，或让 AI 重新读取 `.canary.md` 文件。

## 版本历史

- **1.0.0** (2025-02-09)
  - 初始版本
  - 支持自动启用
  - 集成 iOS 编码规范
  - 支持与 My Claude HUD 集成
