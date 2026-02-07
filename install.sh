#!/bin/bash

# iOS Coding Skills 安装脚本
# 用法: ./install.sh /你的项目路径

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查参数
if [ -z "$1" ]; then
    echo -e "${RED}错误: 请指定项目路径${NC}"
    echo "用法: $0 /你的项目路径"
    echo "示例: $0 ~/Desktop/MyiOSProject"
    exit 1
fi

PROJECT_PATH="$1"
SKILL_SRC="$(pwd)/.claude/skills"
SKILL_DEST="$PROJECT_PATH/.claude/skills"

# 检查源目录
if [ ! -d "$SKILL_SRC" ]; then
    echo -e "${RED}错误: 找不到 skills 源目录${NC}"
    echo "请确保在 ios-coding-skills 根目录运行此脚本"
    exit 1
fi

# 检查目标目录
if [ ! -d "$PROJECT_PATH" ]; then
    echo -e "${RED}错误: 项目路径不存在: $PROJECT_PATH${NC}"
    exit 1
fi

# 创建目标目录
echo -e "${YELLOW}正在创建 .claude/skills 目录...${NC}"
mkdir -p "$SKILL_DEST"

# 复制文件
echo -e "${YELLOW}正在复制 skill 文件...${NC}"
cp -r "$SKILL_SRC"/* "$SKILL_DEST/"

# 检查是否成功
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 安装完成！${NC}"
    echo ""
    echo "已安装的 skills:"
    ls -1 "$SKILL_DEST" | sed 's/^/  - /'
    echo ""
    echo "在 Claude Code 中使用方法:"
    echo "  /coding-standards  - 查看编码规范"
    echo "  /snapkit           - 查看约束规范"
    echo "  /swift6-concurrency - 查看并发规范"
else
    echo -e "${RED}❌ 安装失败${NC}"
    exit 1
fi
