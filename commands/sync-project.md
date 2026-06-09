---
name: claude-knowledge-plugin:sync-project
description: 增量同步项目知识，基于 Git diff 分析变更并更新知识文档
---

# /sync-project

增量同步已接入项目的知识文档。

## 参数

- `name`（可选）— 项目名称。不提供时同步所有已接入项目。

## 执行步骤

### 1. 定位项目知识文档

```
knowledge/projects/<name>.md
```

如果未指定 name，扫描 `knowledge/projects/` 下所有 `.md` 文件。

### 2. 读取上次分析状态

从项目知识文档的元信息中提取 `last_analyzed_commit`。

### 3. 分析 Git 变更

```bash
# 获取新提交
git -C <project-path> log <last_commit>..HEAD --oneline

# 获取变更文件统计
git -C <project-path> diff <last_commit>..HEAD --stat

# 获取变更文件列表（分类）
git -C <project-path> diff <last_commit>..HEAD --name-only
```

### 4. 分类变更

| 变更类型 | 匹配规则 | 更新章节 |
|----------|----------|----------|
| 无变更 | 0 commits | 跳过 |
| 仅文档 | `*.md`, `*.txt`, `docs/` | 不更新 |
| 配置文件 | `pom.xml`, `package.json`, `go.mod`, `Dockerfile` | 技术栈/依赖 |
| 源码结构 | 新增/删除目录 | 模块结构 |
| 依赖变更 | `pom.xml`, `requirements.txt`, `go.mod` | 外部依赖 |
| 架构变更 | refactor/migrate/replace 关键词提交 | 全量检查 + 触发 ADR |

### 5. 增量更新文档

只修改受影响的章节：
- 读取现有文档内容
- 替换变更章节的内容
- 保留未变更章节不变
- 更新元信息（时间戳、commit hash）

### 6. 检查知识沉淀需求

新增依赖 → 检查 `knowledge/systems/` 是否有对应技术文档
新增架构特征 → 检查 `knowledge/architecture/` 是否有对应模式文档
缺失则创建。

### 7. 检查 ADR 需求

分析变更中是否包含架构决策：
```bash
git log <last_commit>..HEAD --grep="migrate\|switch\|replace\|refactor\|redesign" --oneline
```

发现时触发 `adr-manager`。

### 8. 更新索引

刷新 `knowledge/index.md` 中受影响的条目。

## 输出

```
项目 <name> 同步完成:

变更分析:
  新提交: 12
  变更文件: 34
  分类: 配置变更(3) + 源码变更(28) + 文档(3)

知识更新:
  更新 projects/<name>.md (依赖章节、模块结构章节)
  新增 systems/<new-tech>.md
  新增 adr/ADR-NNN-<title>.md

索引已更新。
```

## 批量同步

不指定 name 时，遍历所有已接入项目，逐一执行增量同步。输出汇总报告。
