# Claude Code 插件开发指南

本文档记录了将纯技能集合转换为可安装 Claude Code 插件的完整过程，供开发其他插件时参考。

---

## 目录

1. [背景](#背景)
2. [插件 vs 技能的区别](#插件-vs-技能的区别)
3. [查询过程](#查询过程)
4. [参考方案](#参考方案)
5. [具体实现步骤](#具体实现步骤)
6. [验证方法](#验证方法)
7. [常见问题](#常见问题)
8. [参考资料](#参考资料)

---

## 背景

### 初始状态

`ios-coding-skills` 原本是一个纯技能集合，用户需要手动复制 `.md` 文件到项目的 `.claude/skills/` 目录才能使用。

### 问题

用户发现 **Claude HUD** 插件可以通过 `/plugin marketplace add jarrodwatts/claude-hud` 直接安装，而 ios-coding-skills 只能手复制文件。

### 目标

将 ios-coding-skills 转换为可通过插件市场安装的插件格式。

---

## 插件 vs 技能的区别

### 技能 (Skill)

| 特性 | 说明 |
|------|------|
| 格式 | 纯 `.md` 文件 |
| 结构 | YAML front matter + Markdown 内容 |
| 位置 | `.claude/skills/*.md` 或 `skills/skill-name/SKILL.md` |
| 安装方式 | 手动复制文件 |
| 能力 | 仅提供文本指导给 AI |

### 插件 (Plugin)

| 特性 | 说明 |
|------|------|
| 格式 | npm 包 + 可选的可执行代码 |
| 结构 | `.claude-plugin/plugin.json` + `skills/` + `commands/` + `agents/` |
| 位置 | 通过插件市场安装到 `~/.claude/plugins/cache/` |
| 安装方式 | `/plugin marketplace add username/repo` |
| 能力 | 可包含技能、命令、代理、可执行代码 |

### 关键发现

**插件可以包含纯技能，不需要可执行代码！**

这意味着：
- 任何技能集合都可以转换为插件
- 不需要写 TypeScript/JavaScript 代码
- 只需要正确的目录结构和 `plugin.json`

---

## 查询过程

### 1. 查看 Claude HUD 插件结构

```bash
# 查看插件目录结构
mcp__zread__get_repo_structure("jarrodwatts/claude-hud")

# 查看 plugin.json 格式
cat ~/.claude/plugins/cache/claude-hud/*/plugin.json
```

**发现**：
- Claude HUD 有 `package.json`（因为是 npm 包）
- 有 `src/` 目录（可执行代码）
- 有 `commands/` 目录（命令）
- **但没有 `skills/` 目录**（这是关键区别）

### 2. 查看本地已安装插件

```bash
# 查看本地插件目录
ls -la ~/.claude/plugins/cache/

# 查看 code-review 插件结构
ls -la ~/.claude/plugins/cache/claude-plugins-official/code-review/*/
```

**发现**：
- code-review 插件只有 `commands/` 目录，没有 `skills/`

### 3. 搜索社区插件示例

使用 Web 搜索找到：`jeremylongshore/claude-code-plugins-plus-skills`

**发现**：
- 这个仓库包含 **270+ 插件** 和 **739 个技能**
- 插件可以同时包含 `skills/`、`commands/`、`agents/` 目录

### 4. 查看技能文件格式

```bash
# 查看示例技能
mcp__zread__read_file("plugins/examples/pi-pathfinder/skills/pi-pathfinder/SKILL.md")
```

**关键发现**：
- 技能文件名必须是 **`SKILL.md`**（大写）
- 目录结构：`skills/skill-name/SKILL.md`
- Front matter 必须包含 `name` 和 `version` 字段

---

## 参考方案

### 官方插件结构

根据 [anthropics/claude-code](https://github.com/anthropics/claude-code) 的文档：

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json         # 插件元数据（必需）
├── skills/                 # 技能目录（可选）
│   └── skill-name/
│       └── SKILL.md        # 技能文件（大写）
├── commands/               # 命令目录（可选）
│   └── command-name.md
├── agents/                 # 代理目录（可选）
│   └── agent-name.md
└── package.json            # npm 配置（可选，有可执行代码时需要）
```

### plugin.json 格式

```json
{
  "name": "plugin-name",
  "description": "插件描述",
  "version": "1.0.0",
  "author": {
    "name": "作者名",
    "url": "https://github.com/username"
  },
  "homepage": "https://github.com/username/repo",
  "repository": "https://github.com/username/repo",
  "license": "MIT",
  "keywords": ["keyword1", "keyword2"]
}
```

### SKILL.md 格式

```markdown
---
name: skill-name
description: 技能描述
version: 1.0.0
license: MIT
author: 作者名 <url>
---

# 技能标题

技能内容...
```

---

## 具体实现步骤

### 步骤 1：创建插件目录结构

```bash
cd ~/Desktop/ios-coding-skills

# 创建必需的目录
mkdir -p .claude-plugin
mkdir -p skills
```

### 步骤 2：创建 plugin.json

```bash
cat > .claude-plugin/plugin.json << 'EOF'
{
  "name": "ios-coding-skills",
  "description": "通用 iOS 开发规范 skill 集合",
  "version": "1.0.0",
  "author": {
    "name": "Link-Start",
    "url": "https://github.com/Link-Start"
  },
  "homepage": "https://github.com/Link-Start/ios-coding-skills",
  "repository": "https://github.com/Link-Start/ios-coding-skills",
  "license": "MIT",
  "keywords": ["ios", "swift", "coding-standards"]
}
EOF
```

### 步骤 3：转换技能文件

对于每个 `.md` 技能文件：

1. **创建技能目录**：
```bash
mkdir -p skills/coding-standards
```

2. **创建 SKILL.md**（注意文件名大写）：
```bash
cat > skills/coding-standards/SKILL.md << 'EOF'
---
name: coding-standards
description: 技能描述...
version: 1.0.0
license: MIT
author: Link-Start <https://github.com/Link-Start>
---

# 技能标题

技能内容...
EOF
```

**关键点**：
- 文件名必须是 `SKILL.md`（大写）
- Front matter 必须包含 `name` 和 `version`
- 保留原有的 `description` 和中文触发关键词

### 步骤 4：批量创建所有技能

```bash
# 为每个技能创建目录
cd skills
mkdir -p coding-standards snapkit swift6-concurrency xib-to-swift oc-to-swift xcode-errors ios-permissions

# 为每个技能创建 SKILL.md 文件
# （使用 heredoc 或直接写入）
```

### 步骤 5：更新 README.md

添加插件安装方式：

```markdown
## 安装方式

### 方式 1：通过插件市场安装（推荐）

```bash
# 安装插件
/plugin marketplace add Link-Start/ios-coding-skills

# 启用插件
/plugin enable ios-coding-skills
```

### 方式 2：手动复制 skill 文件
...
```

### 步骤 6：提交到 Git

```bash
cd ~/Desktop/ios-coding-skills

# 添加所有文件
git add .

# 提交
git commit -m "feat: 转换为插件格式"

# 推送
git push
```

---

## 验证方法

### 1. 验证插件格式

```bash
cd ~/Desktop/ios-coding-skills
claude plugin validate .
```

期望输出：
```
Validating plugin manifest: .../plugin.json
✔ Validation passed
```

### 2. 验证技能文件

```bash
# 检查目录结构
ls -la skills/

# 检查每个技能的 front matter
for dir in skills/*/; do
  skill=$(basename "$dir")
  echo "=== $skill ==="
  head -5 "$dir/SKILL.md"
done
```

### 3. 测试插件安装

```bash
# 安装插件
/plugin marketplace add Link-Start/ios-coding-skills

# 查看已安装插件
/plugin list

# 测试技能
/coding-standards
```

---

## 常见问题

### Q1: 技能文件名必须是 SKILL.md 吗？

**A**: 是的，必须是大写的 `SKILL.md`。小写的 `skill.md` 不会被识别。

### Q2: 可以同时有可执行代码和技能吗？

**A**: 可以。如果需要可执行代码，需要：
- 添加 `package.json`
- 添加 `src/` 目录
- 编译到 `dist/` 目录

参考 [claude-hud](https://github.com/jarrodwatts/claude-hud) 的结构。

### Q3: plugin.json 中的哪些字段是必需的？

**A**: 最小必需字段：
```json
{
  "name": "plugin-name",
  "description": "插件描述"
}
```

推荐添加：
- `version`
- `author`
- `license`
- `homepage`
- `repository`

### Q4: 技能的 front matter 需要哪些字段？

**A**: 最小必需字段：
```yaml
---
name: skill-name
description: 技能描述
---
```

推荐添加：
- `version`
- `license`
- `author`

### Q5: 如何调试插件？

**A**:
1. 使用 `claude plugin validate .` 验证格式
2. 查看本地插件缓存：`~/.claude/plugins/cache/`
3. 使用 `/plugin list` 查看已安装插件
4. 使用 `/plugin enable/disable` 启用/禁用插件

---

## 参考资料

### 官方资源

- [Claude Code GitHub](https://github.com/anthropics/claude-code)
- [Claude Plugins Official](https://github.com/anthropics/claude-plugins-official)

### 社区示例

- [jeremylongshore/claude-code-plugins-plus-skills](https://github.com/jeremylongshore/claude-code-plugins-plus-skills) - 270+ 插件示例
- [jarrodwatts/claude-hud](https://github.com/jarrodwatts/claude-hud) - 包含可执行代码的插件示例
- [Link-Start/ios-coding-skills](https://github.com/Link-Start/ios-coding-skills) - 纯技能插件示例

### 文档

- [Claude Code 文档](https://claude.ai/code)
- [Claude Code Skills Hub](https://claudecodeplugins.io/)
- [iOS 编码规范教程（中文）](https://www.cnblogs.com/elesos/p/19530055)

---

## 快速模板

### 最小插件模板

```bash
# 1. 创建目录
mkdir my-plugin && cd my-plugin
mkdir -p .claude-plugin skills/my-skill

# 2. 创建 plugin.json
cat > .claude-plugin/plugin.json << 'EOF'
{
  "name": "my-plugin",
  "description": "My plugin description"
}
EOF

# 3. 创建 SKILL.md
cat > skills/my-skill/SKILL.md << 'EOF'
---
name: my-skill
description: My skill description
version: 1.0.0
---

# My Skill

This is my skill content.
EOF

# 4. 初始化 Git
git init
git add .
git commit -m "Initial commit"

# 5. 创建 GitHub 仓库并推送
gh repo create my-plugin --public --source=. --push
```

### 安装测试

```bash
# 在另一个项目中测试
/plugin marketplace add username/my-plugin
/my-skill
```

---

## 更新日志

| 日期 | 变更 |
|------|------|
| 2026-02-07 | 初始版本，记录 ios-coding-skills 转换过程 |
| | |

---

## 贡献

如果你在开发插件时有新的发现或改进，欢迎提交 PR 更新本文档。
