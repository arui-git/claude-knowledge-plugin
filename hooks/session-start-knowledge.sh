#!/usr/bin/env bash
#
# SessionStart hook: 自动注入知识库索引到 Claude 上下文
#
# 每次 Claude Code 启动会话时执行，读取 knowledge/index.md 并注入为 additionalContext。
# Claude 因此始终知道知识库中有哪些项目、技术、架构和 ADR。
#
# 安装方式: 在 .claude/settings.json 中配置 hooks.SessionStart
#

set -euo pipefail

# 查找知识库目录
KNOWLEDGE_DIR=""

# 1. 当前项目根目录下
if [ -f "knowledge/index.md" ]; then
    KNOWLEDGE_DIR="knowledge"
fi

# 2. 未找到则跳过
if [ -z "$KNOWLEDGE_DIR" ]; then
    exit 0
fi

# 读取索引文件
INDEX_CONTENT=$(cat "$KNOWLEDGE_DIR/index.md" 2>/dev/null || echo "")

if [ -z "$INDEX_CONTENT" ]; then
    exit 0
fi

# 统计知识库规模
PROJECT_COUNT=$(find "$KNOWLEDGE_DIR/projects" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
SYSTEM_COUNT=$(find "$KNOWLEDGE_DIR/systems" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
ARCH_COUNT=$(find "$KNOWLEDGE_DIR/architecture" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
ADR_COUNT=$(find "$KNOWLEDGE_DIR/adr" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

# 构建上下文
CONTEXT="[knowledge-search] 知识库已加载 (${PROJECT_COUNT} 项目, ${SYSTEM_COUNT} 技术, ${ARCH_COUNT} 架构, ${ADR_COUNT} ADR)。
当用户问题涉及项目技术栈、架构、依赖、决策历史时，主动搜索 knowledge/ 目录获取相关知识。

知识库索引:
${INDEX_CONTENT}"

# 输出为 SessionStart additionalContext
# 使用 JSON 格式
python3 -c "
import json, sys
ctx = sys.stdin.read().strip()
print(json.dumps({
    'hookSpecificOutput': {
        'hookEventName': 'SessionStart',
        'additionalContext': ctx
    }
}))
" <<< "$CONTEXT" 2>/dev/null || echo "$CONTEXT"
