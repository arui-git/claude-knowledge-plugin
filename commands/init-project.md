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

### 7. 检查并自动安装 Hook

检查以下 Hook 是否已安装，未安装则自动安装：

**a) Git Hooks（目标仓库根目录下执行）**

```bash
# 检查 post-commit hook 是否已安装
grep -qF "knowledge-sync-post-commit" .git/hooks/post-commit 2>/dev/null || bash ${PLUGIN_ROOT}/hooks/post-commit.sh install

# 检查 post-merge hook 是否已安装
grep -qF "knowledge-sync-post-merge" .git/hooks/post-merge 2>/dev/null || bash ${PLUGIN_ROOT}/hooks/post-merge.sh install
```

**b) SessionStart Hook（项目 `.claude/settings.json`）**

检查项目的 `.claude/settings.json` 是否已配置 SessionStart hook。
未配置则合并 `hooks/session-start-knowledge.json` 的内容。

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
