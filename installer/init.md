---
name: init
description: 一键初始化 claude-knowledge-plugin 到当前项目
---

# /installer/init

一键初始化知识库插件。

## 执行步骤

### 1. 检测当前环境

```bash
# 确认在 Git 仓库中
git rev-parse --is-inside-work-tree

# 确认 .claude 目录
ls -la .claude/ 2>/dev/null || mkdir -p .claude
```

### 2. 询问知识库路径

向用户展示选项：

**选项 A: 本地单项目模式**

```
知识库路径: <当前项目>/knowledge/
适用: 单项目，不需要团队共享
```

**选项 B: 本地多项目模式**

```
知识库路径: <用户指定路径>/knowledge/
适用: 多项目共享知识库，本地管理
```

**选项 C: 团队共享模式（Git 仓库）**

```
知识库路径: <克隆到的路径>/knowledge/
Git 仓库: <用户提供 URL>
适用: 团队协作，知识库版本控制
```

### 3. 创建知识库目录

```bash
KNOWLEDGE_PATH="<用户选择的路径>"

mkdir -p "$KNOWLEDGE_PATH"/{projects,systems,architecture,adr,runbooks}
```

### 4. 生成索引

从模板复制 `index.md` 到知识库根目录：

```bash
cp templates/knowledge-layout/index.md "$KNOWLEDGE_PATH/index.md"
```

替换 `{YYYY-MM-DD}` 为当前日期。

### 5. 安装 Skill 模块

将三个 Skill 复制到项目的 `.claude/skills/` 下：

```bash
mkdir -p .claude/skills

cp -r skills/knowledge-manager .claude/skills/
cp -r skills/adr-manager .claude/skills/
cp -r skills/repo-analyzer .claude/skills/
```

### 6. 合并 CLAUDE.md 配置

读取项目的 CLAUDE.md（如不存在则创建），将知识库配置追加到末尾：

```
## 知识库配置

知识库目录: <knowledge-path>

### 已接入项目

<!-- 由 /import-repo 自动维护 -->

### 知识库维护规则

- 代码是事实来源，知识库是编译产物
- 优先增量更新，不全文重写
- ADR 不可删除，只能标记状态变更
```

### 7. 可选: 安装 Git Hook

询问用户是否安装 Git Hook：

```bash
# 在目标仓库根目录执行
bash <plugin-path>/hooks/post-commit.sh install
bash <plugin-path>/hooks/post-merge.sh install
```

### 8. 可选: 初始化 Git

如果知识库不在已有 Git 仓库中：

```bash
cd "$KNOWLEDGE_PATH/.."
git init
git add knowledge/
git commit -m "init knowledge base"
```

### 9. 可选: 首次项目扫描

询问用户是否立即执行首次扫描：

```
知识库已初始化。是否立即扫描当前项目？
  → /import-repo <当前项目路径>
```

## 输出

初始化完成后报告：

```
claude-knowledge-plugin 初始化完成。

知识库: <knowledge-path>
模式: <单项目/多项目/团队共享>

已安装:
  ✓ .claude/skills/knowledge-manager/SKILL.md
  ✓ .claude/skills/adr-manager/SKILL.md
  ✓ .claude/skills/repo-analyzer/SKILL.md
  ✓ knowledge/index.md (索引)
  ✓ CLAUDE.md (知识库配置已追加)

可选:
  ○ Git Hook (post-commit / post-merge)
  ○ 首次项目扫描 (/import-repo)

下一步:
  /import-repo <项目路径>  接入第一个项目
```
