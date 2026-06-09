#!/usr/bin/env bash
#
# post-merge hook: 知识库自动同步（merge/pull 后）
#
# 安装方式:
#   bash hooks/post-merge.sh install
#
# 卸载方式:
#   bash hooks/post-merge.sh uninstall
#
# 功能: 每次 git pull (merge) 后自动触发知识库增量同步提示
#

set -euo pipefail

HOOK_NAME="knowledge-sync-post-merge"
HOOK_TARGET=".git/hooks/post-merge"
PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MARKER="# >>> ${HOOK_NAME} >>>"

action="${1:-}"

install_hook() {
    if [ ! -d ".git" ]; then
        echo "Error: not a git repository. Run from repo root."
        exit 1
    fi

    if [ -f "$HOOK_TARGET" ] && grep -qF "$MARKER" "$HOOK_TARGET" 2>/dev/null; then
        echo "Hook already installed."
        return 0
    fi

    cat >> "$HOOK_TARGET" <<HOOK_EOF

$MARKER
# Auto-sync knowledge base after merge/pull
# Trigger: claude-code /sync-project when available
echo "[knowledge-plugin] Merge detected. Run '/sync-project' to sync knowledge base."
$MARKER
HOOK_EOF

    chmod +x "$HOOK_TARGET"
    echo "Hook installed: $HOOK_TARGET"
}

uninstall_hook() {
    if [ ! -f "$HOOK_TARGET" ]; then
        echo "No post-merge hook found."
        return 0
    fi

    if grep -qF "$MARKER" "$HOOK_TARGET" 2>/dev/null; then
        sed -i "/$MARKER/,/$MARKER/d" "$HOOK_TARGET"
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
        echo "  install   - Install post-merge hook in current git repo"
        echo "  uninstall - Remove post-merge hook from current git repo"
        exit 1
        ;;
esac
