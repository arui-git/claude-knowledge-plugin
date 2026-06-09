---
name: claude-knowledge-plugin:init-project
description: 初始化知识库目录结构、索引和配置
---

# /init-project

初始化开发知识库。

## 执行步骤

### 1. 询问知识库路径

向用户确认知识库存放位置：

- **选项 A**: 当前项目根目录下创建 `knowledge/`（单项目模式）
- **选项 B**: 指定独立目录（多项目共享模式）
- **选项 C**: 克隆已有的知识库 Git 仓库（团队共享模式）

如果用户选择选项 C，执行：

```bash
git clone <knowledge-repo-url> <target-path>
```

### 2. 创建目录结构

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

### 3. 生成索引文件

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

### 4. 复制模板文件

将插件 `templates/knowledge-layout/` 下的模板复制到知识库目录。

### 5. 初始化 Git（可选）

如果知识库目录不是已有的 Git 仓库：

```bash
cd <knowledge-path>
git init
git add .
git commit -m "init knowledge base"
```

### 6. 注册到项目配置

在当前项目的 `.claude/` 目录下记录知识库路径（如通过 CLAUDE.md 或 memory）。

向用户确认是否：
- 安装 Git Hook（post-commit 自动同步）
- 立即执行首次项目扫描（/import-repo）

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
