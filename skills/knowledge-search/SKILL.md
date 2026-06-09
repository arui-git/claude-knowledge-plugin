---
name: claude-knowledge-plugin:knowledge-search
description: 主动搜索当前项目的知识库（knowledge/目录），在回答涉及项目技术栈、架构、依赖、决策历史的问题时自动加载相关知识
user-invocable: false
allowed-tools: Grep Read Glob Bash
---

# Knowledge Search

## 职责

在回答用户问题前，主动搜索 `knowledge/` 目录下相关知识文档，将结果作为上下文补充到回答中。

## 何时触发

当用户问题涉及以下内容时，主动加载本 Skill：

- 项目的技术栈、框架、依赖
- 项目的模块结构、代码组织
- 架构模式、设计决策
- ADR（架构决策记录）
- 某个技术组件的使用方式
- 项目间关系、依赖
- 历史变更原因

## 搜索流程

### Step 1: 定位知识库目录

```
知识库目录: knowledge/
位置: 当前项目根目录下
```

如果 `knowledge/` 目录不存在，跳过搜索，正常回答。

### Step 2: 根据问题类型搜索

使用 Grep 和 Read 工具搜索知识库：

**项目相关**:
```
搜索 knowledge/projects/*.md
```

**技术相关**:
```
搜索 knowledge/systems/*.md
```

**架构相关**:
```
搜索 knowledge/architecture/*.md
```

**ADR 相关**:
```
搜索 knowledge/adr/*.md
```

**全局搜索**:
```
grep 关键词 knowledge/ 目录下所有 .md 文件
```

### Step 3: 提取相关知识

读取匹配的文档，提取与用户问题直接相关的章节。

### Step 4: 融入回答

将搜索到的知识作为回答的背景信息：
- 引用具体文档路径（如 `knowledge/projects/xxx.md`）
- 标注"根据知识库记录"
- 如果知识库记录与当前代码不一致，以代码为准，并建议更新知识库

## 搜索策略

| 问题类型 | 搜索目标 | 搜索方式 |
|----------|----------|----------|
| "这个项目用什么技术" | projects/*.md 技术栈章节 | Grep 关键词 |
| "这个架构为什么这么设计" | adr/*.md | Read 对应 ADR |
| "XX技术怎么配置的" | systems/*.md | Grep 技术名称 |
| "模块A和B什么关系" | projects/*.md 模块结构 | Read 项目文档 |
| "有没有用过XX模式" | architecture/*.md | Grep 模式名称 |
| "两个项目有什么依赖" | projects/*.md 关联知识 | Read 多个项目文档 |

## 输出格式

搜索到相关知识时，在回答中自然融入：

```
根据知识库记录（knowledge/projects/xxx.md）：
- 技术栈：...
- 模块结构：...

[你的分析和建议]
```

搜索不到相关知识时：
- 正常回答
- 不提及知识库搜索
- 如果问题适合沉淀为知识，建议用户执行 `/claude-knowledge-plugin:import-repo`

## 注意事项

- 知识库内容可能过时，以代码为事实来源
- 搜索结果仅作为辅助上下文，不替代代码分析
- 不要把知识库原文大段复制到回答中，提取关键信息即可
- 如果索引（knowledge/index.md）已在上下文中，直接根据索引定位文档
