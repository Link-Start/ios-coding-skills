#!/bin/bash

# 金丝雀测试自动初始化脚本
# 由 ios-coding-skills 插件安装时自动调用

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 项目目录（从参数传入，或使用当前目录）
PROJECT_DIR="${1:-$(pwd)}"
CANARY_FILE="$PROJECT_DIR/.canary.md"

# 检查是否已存在金丝雀文件
if [ -f "$CANARY_FILE" ]; then
    echo -e "${YELLOW}⚠️  金丝雀文件已存在: $CANARY_FILE${NC}"
    echo -e "${GREEN}✓ 跳过创建${NC}"
    exit 0
fi

# 生成金丝雀 ID
CANARY_ID="canary_$(date +%s)_$(cat /dev/urandom | LC_ALL=C tr -dc 'a-z0-9' | head -c 6)"
CREATE_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# 创建金丝雀文件
cat > "$CANARY_FILE" << EOF
# iOS 项目金丝雀测试标记

<!-- CANARY_TEST_START -->
金丝雀 ID: $CANARY_ID
创建时间: $CREATE_TIME
项目类型: iOS 项目
<!-- CANARY_TEST_END -->

## 说明

这是一个 iOS 项目的金丝雀测试标记，用于检测 AI 是否仍然记得项目约定和上下文。

## 金丝雀 ID

当前项目的金丝雀 ID：\`$CANARY_ID\`

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

1. 重新提及项目约定：请使用 \`/coding-standards\` 查看完整编码规范
2. 重新加载金丝雀文件：让 AI 重新读取 \`.canary.md\` 文件
3. 开始新的对话会话：清理上下文，重新开始

## 快捷命令

- 查看金丝雀状态：\`cat .canary.md\`
- 重新加载项目约定：使用 \`/coding-standards\` skill
- 查看 SnapKit 规范：使用 \`/snapkit\` skill
- 查看 Swift 6 并发：使用 \`/swift6-concurrency\` skill

---

**提示**：本文件由 ios-coding-skills 插件自动创建。如需禁用金丝雀测试，请删除此文件。
EOF

echo -e "${GREEN}✓ 金丝雀文件已创建${NC}"
echo -e "${GREEN}  文件路径: $CANARY_FILE${NC}"
echo -e "${GREEN}  金丝雀 ID: $CANARY_ID${NC}"
echo ""
echo -e "${YELLOW}💡 提示：${NC}"
echo -e "  - 金丝雀文件用于检测 AI 上下文丢失"
echo -e "  - AI 会记住金丝雀 ID 以保持项目约定"
echo -e "  - 如需禁用，请删除 .canary.md 文件"

exit 0
