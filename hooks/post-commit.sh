#!/usr/bin/env bash
#
# post-commit hook: 知识库自动同步
#
# 安装方式:
#   bash hooks/post-commit.sh install
#
# 卸载方式:
#   bash hooks/post-commit.sh uninstall
#
# 功能: 每次 git commit 后自动触发知识库增量同步提示
#

set -euo pipefail

HOOK_NAME="knowledge-sync-post-commit"
HOOK_TARGET=".git/hooks/post-commit"
PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MARKER="# >>> ${HOOK_NAME} >>>"

action="${1:-}"

install_hook() {
    if [ ! -d ".git" ]; then
        echo "Error: not a git repository. Run from repo root."
        exit 1
    fi

    # 检查是否已安装
    if [ -f "$HOOK_TARGET" ] && grep -qF "$MARKER" "$HOOK_TARGET" 2>/dev/null; then
        echo "Hook already installed."
        return 0
    fi

    # 写入 hook 内容
    cat >> "$HOOK_TARGET" <<HOOK_EOF

$MARKER
# Auto-sync knowledge base after commit
# Trigger: claude-code /sync-project when available
echo "[knowledge-plugin] Commit detected. Run '/sync-project' to sync knowledge base."
$MARKER
HOOK_EOF

    chmod +x "$HOOK_TARGET"
    echo "Hook installed: $HOOK_TARGET"
}

uninstall_hook() {
    if [ ! -f "$HOOK_TARGET" ]; then
        echo "No post-commit hook found."
        return 0
    fi

    # 移除标记之间的内容
    if grep -qF "$MARKER" "$HOOK_TARGET" 2>/dev/null; then
        # 使用 sed 移除标记块
        sed -i "/$MARKER/,/$MARKER/d" "$HOOK_TARGET"
        # 清理空行
        sed -i '/^$/N;/^\n$/d' "$HOOK_TARGET"
        echo "Hook uninstalled."
    else
        echo "Knowledge hook not found in $HOOK_TARGET"
    fi
}

case "$action" in
    install)
        install_hook
        ;;
    uninstall)
        uninstall_hook
        ;;
    *)
        echo "Usage: $0 {install|uninstall}"
        echo ""
        echo "  install   - Install post-commit hook in current git repo"
        echo "  uninstall - Remove post-commit hook from current git repo"
        exit 1
        ;;
esac
