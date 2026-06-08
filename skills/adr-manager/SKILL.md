---
name: adr-manager
description: 架构决策记录管理 — ADR 创建、编号、生命周期、关联维护
triggers:
  - 生成ADR
  - 架构决策
  - 记录决策
  - ADR
---

# ADR Manager

## 职责

管理架构决策记录（Architecture Decision Record）的全生命周期。

## 前置条件

知识库已初始化，`knowledge/adr/` 目录存在。

## ADR 生命周期

```
Proposed → Accepted → [Superseded | Deprecated]
                ↓
            Rejected
```

| 状态 | 含义 |
|------|------|
| Proposed | 已提出，待讨论 |
| Accepted | 已采纳 |
| Rejected | 已否决 |
| Superseded | 已被新 ADR 取代 |
| Deprecated | 已废弃 |

## 编号规则

- 格式：`ADR-NNN`
- 从 001 开始递增，不跳号不重用
- 通过扫描 `knowledge/adr/` 目录确定下一个编号

```bash
# 获取下一个编号
ls knowledge/adr/ADR-*.md 2>/dev/null | sort -r | head -1
# 提取编号 + 1
```

## 文件命名

```
knowledge/adr/ADR-NNN-<short-title>.md
```

短标题使用小写英文，连字符分隔。例如：`ADR-001-kafka-mode-introduction.md`。

## 触发条件

自动触发场景：
- 技术选型变更（数据库、框架、中间件替换）
- 架构模式变更（单体→微服务、同步→异步）
- 通信协议变更（REST→gRPC、HTTP→Kafka）
- 部署策略变更（VM→容器、单节点→集群）
- 引入新的基础设施组件
- 用户主动要求"生成ADR"

## 创建流程

1. **收集决策信息** — 决策内容、背景、备选方案、理由、影响、风险
2. **确定编号** — 扫描目录获取下一个可用编号
3. **使用模板创建** — 按 `templates/knowledge-layout/adr/ADR-template.md` 格式
4. **建立关联** — 在相关项目/技术/架构文档中引用 ADR
5. **更新索引** — 在 `knowledge/index.md` 的 ADR 索引中添加条目
6. **处理 Supersede** — 如替代旧 ADR，更新旧 ADR 状态和链接

## ADR 必填字段

- **状态**: Proposed/Accepted/Rejected/Superseded/Deprecated
- **日期**: YYYY-MM-DD
- **上下文**: 为什么需要做这个决策
- **决策**: 具体决定内容
- **备选方案**: 至少 2 个备选，含优缺点和选择/拒绝理由
- **影响**: 正面和负面影响
- **风险**: 概率 × 影响 × 缓解措施
- **关联**: 相关项目、技术、架构文档链接

## 更新规则

- 不删除历史 ADR
- 可以更新状态（如 Accepted → Superseded）
- 可以在 Consequences 章节追加实际结果
- 被 Supersede 时，旧 ADR 添加指向新 ADR 的链接

## 关联 Skill

- `repo-analyzer` — 项目接入时发现架构决策点
- `knowledge-manager` — ADR 索引维护和交叉引用
