# CLAUDE.md — 知识库项目模板

> 将此内容合并到项目的 CLAUDE.md 中，启用知识库管理能力。

## 知识库配置

### 知识库路径

<!-- 单项目模式: 知识库在当前项目根目录下 -->
知识库目录: `knowledge/`

<!-- 多项目模式: 知识库在独立目录或独立仓库 -->
<!-- 知识库目录: /path/to/shared-knowledge/ -->

### 已接入项目

<!-- 由 /import-repo 自动维护 -->
<!-- - project-a: /path/to/project-a -->

### 知识库维护规则

- 代码是事实来源，知识库是编译产物
- 优先增量更新，不全文重写
- ADR 不可删除，只能标记状态变更
- 每个知识条目标注最后更新时间和数据来源
- 文档间保持双向链接

### 自动同步规则

当执行 `git push` 后，自动执行 `/sync-project` 将变更同步到知识库。无需用户手动触发。

## 可用命令

- `/init-project` — 初始化知识库
- `/import-repo <path>` — 接入新项目
- `/sync-project [name]` — 增量同步项目知识

## 可用 Skill

- **knowledge-manager** — 知识库生命周期管理（触发词: 更新知识库、同步文档）
- **adr-manager** — ADR 管理（触发词: 生成ADR、架构决策）
- **repo-analyzer** — 仓库分析（触发词: 接入项目、分析项目）
