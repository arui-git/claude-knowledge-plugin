---
name: claude-knowledge-plugin:init-project
description: 初始化知识库目录结构、索引和配置
---

# /init-project

初始化开发知识库。

## 执行步骤

### 1. 检测已有知识库

先检测当前项目及上级目录是否已有 `knowledge/` 目录：

```bash
# 检查当前项目下
ls knowledge/index.md 2>/dev/null

# 检查上级目录（多项目共享模式）
ls ../knowledge/index.md 2>/dev/null
```

如果找到已有知识库，询问用户：
- **使用已有知识库** — 直接注册到当前项目
- **重新初始化** — 创建新知识库

### 2. 询问知识库路径

如果未找到已有知识库，向用户确认知识库存放位置：

- **选项 A**: 当前项目根目录下创建 `knowledge/`（单项目模式）
- **选项 B**: 指定独立目录（多项目共享模式）
- **选项 C**: 克隆已有的知识库 Git 仓库（团队共享模式）

如果用户选择选项 C，执行：

```bash
git clone <knowledge-repo-url> <target-path>
```

### 3. 创建目录结构

在目标路径下创建：

```
knowledge/
├── projects/
├── systems/
├── architecture/
├── adr/
├── runbooks/
└── index.md
```

```bash
mkdir -p <knowledge-path>/{projects,systems,architecture,adr,runbooks}
```

### 4. 生成索引文件

创建 `knowledge/index.md`：

```markdown
# 知识库索引

> 最后更新: {YYYY-MM-DD}
>
> 本索引由 knowledge-manager 自动维护。

## 项目索引

| 项目 | 描述 | 文档 |
|------|------|------|

## 技术索引

| 技术 | 使用项目 | 文档 |
|------|----------|------|

## 架构索引

| 模式 | 使用项目 | 文档 |
|------|----------|------|

## ADR 索引

| 编号 | 标题 | 状态 | 日期 |
|------|------|------|------|
```

### 5. 复制模板文件

将插件 `templates/knowledge-layout/` 下的模板复制到知识库目录。

### 6. 初始化 Git（可选）

如果知识库目录不是已有的 Git 仓库：

```bash
cd <knowledge-path>
git init
git add .
git commit -m "init knowledge base"
```

### 7. 强制安装 Hook（必须执行，不要跳过）

**此步骤必须执行，不询问用户。** 直接执行以下操作：

**a) Git Hooks**

在目标仓库根目录下执行以下命令（使用 Bash 工具）：

```bash
# 安装 post-commit hook（知识库同步提醒）
# 先找到插件安装路径，通常在 ~/.claude/plugins/cache/ 下搜索 claude-knowledge-plugin
PLUGIN_HOOK_DIR=$(find ~/.claude/plugins/cache -path "*/claude-knowledge-plugin/hooks" -type d 2>/dev/null | head -1)

if [ -n "$PLUGIN_HOOK_DIR" ]; then
    bash "$PLUGIN_HOOK_DIR/post-commit.sh" install
    bash "$PLUGIN_HOOK_DIR/post-merge.sh" install
else
    # 备选：直接写入 hook 内容
    MARKER="# >>> knowledge-sync-post-commit >>>"
    if [ -f .git/hooks/post-commit ] && grep -qF "$MARKER" .git/hooks/post-commit 2>/dev/null; then
        echo "post-commit hook already installed"
    else
        cat >> .git/hooks/post-commit <<'HOOK_EOF'

# >>> knowledge-sync-post-commit >>>
# Auto-sync knowledge base after commit
echo "[knowledge-plugin] Commit detected. Run '/claude-knowledge-plugin:sync-project' to sync knowledge base."
# >>> knowledge-sync-post-commit >>>
HOOK_EOF
        chmod +x .git/hooks/post-commit
        echo "post-commit hook installed"
    fi

    MARKER2="# >>> knowledge-sync-post-merge >>>"
    if [ -f .git/hooks/post-merge ] && grep -qF "$MARKER2" .git/hooks/post-merge 2>/dev/null; then
        echo "post-merge hook already installed"
    else
        cat >> .git/hooks/post-merge <<'HOOK_EOF'

# >>> knowledge-sync-post-merge >>>
# Auto-sync knowledge base after merge/pull
echo "[knowledge-plugin] Merge detected. Run '/claude-knowledge-plugin:sync-project' to sync knowledge base."
# >>> knowledge-sync-post-merge >>>
HOOK_EOF
        chmod +x .git/hooks/post-merge
        echo "post-merge hook installed"
    fi
fi
```

**b) SessionStart Hook**

直接修改项目的 `.claude/settings.json`，合并以下内容（如文件不存在则创建）：

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash -c 'if [ -f \"${CLAUDE_PROJECT_DIR}/knowledge/index.md\" ]; then cat \"${CLAUDE_PROJECT_DIR}/knowledge/index.md\"; fi'"
          }
        ]
      }
    ]
  }
}
```

使用 Read 工具读取现有 `.claude/settings.json`，用 Edit 工具合并 hooks 配置。不要覆盖已有配置，只添加缺失的 SessionStart hook。

### 8. 注册到项目配置

在当前项目的 `.claude/` 目录下或 CLAUDE.md 中记录知识库路径。

### 9. 询问首次扫描

向用户确认是否立即执行首次项目扫描（`/import-repo`）。

## 输出

初始化完成后报告：

```
知识库已初始化: <knowledge-path>

目录结构:
  knowledge/projects/     (0 个项目)
  knowledge/systems/      (0 个技术)
  knowledge/architecture/ (0 个架构)
  knowledge/adr/          (0 个 ADR)
  knowledge/runbooks/     (0 个手册)
  knowledge/index.md      (索引已创建)

下一步:
  /import-repo <项目路径>  接入第一个项目
```
