# claude-knowledge-plugin

Claude Code 插件 — 开发知识库全生命周期管理系统。

自动扫描 Git 仓库代码，生成项目知识、架构文档、ADR，维护技术知识库，支持多项目接入和团队共享。

## 快速开始

### 方式一：一键初始化（推荐）

在 Claude Code 中执行：

```
/installer/init
```

按提示选择知识库路径，插件自动完成所有配置。

### 方式二：手动安装

1. 将 `skills/` 目录复制到项目的 `.claude/skills/` 下
2. 将 `templates/` 中需要的模板复制到项目根目录
3. 在项目 `.claude/settings.json` 中注册 hooks（可选）

## 核心能力

| Skill | 触发词 | 说明 |
|-------|--------|------|
| **knowledge-manager** | 更新知识库、同步文档、维护开发文档 | 知识库全生命周期管理 |
| **adr-manager** | 生成ADR、架构决策 | 架构决策记录管理 |
| **repo-analyzer** | 接入项目、分析项目、分析仓库、阅读代码库 | Git 仓库扫描与项目知识生成 |

## 用户命令

| 命令 | 说明 |
|------|------|
| `/init-project` | 初始化知识库，创建目录结构和索引 |
| `/sync-project` | 增量同步项目知识（基于 Git diff） |
| `/import-repo` | 接入新仓库，完整分析并生成知识文档 |

## 目录结构

```
claude-knowledge-plugin/
├── skills/                     # 核心能力模块
│   ├── knowledge-manager/      # 知识库生命周期管理
│   │   └── SKILL.md
│   ├── adr-manager/            # ADR 管理
│   │   └── SKILL.md
│   └── repo-analyzer/          # 仓库分析器
│       └── SKILL.md
├── commands/                   # 用户入口流程
│   ├── init-project.md
│   ├── sync-project.md
│   └── import-repo.md
├── templates/                  # 模板文件
│   ├── CLAUDE.md               # 项目 CLAUDE.md 模板
│   └── knowledge-layout/       # 知识库目录结构模板
│       ├── projects/
│       ├── systems/
│       ├── architecture/
│       ├── adr/
│       ├── runbooks/
│       └── index.md
├── hooks/                      # Git Hooks（可选）
│   ├── post-commit.sh
│   └── post-merge.sh
├── installer/                  # 安装器
│   └── init.md
└── README.md
```

## 知识库输出结构

插件在目标目录生成以下结构：

```
knowledge/
├── projects/        # 项目知识（每个项目一个 .md）
├── systems/         # 技术/系统知识
├── architecture/    # 架构模式文档
├── adr/             # 架构决策记录（ADR-NNN.md）
├── runbooks/        # 运维手册
└── index.md         # 总索引
```

## 工作流程

```
/import-repo <path>
    │
    ├─ Phase 1: 项目发现（扫描 Git 仓库、配置文件、目录结构）
    ├─ Phase 2: 知识生成（按模板输出项目文档）
    ├─ Phase 3: 知识关联（对比现有知识库，建立交叉引用）
    ├─ Phase 4: 知识沉淀（发现新技术/架构，创建对应文档）
    ├─ Phase 5: ADR 维护（识别架构决策，创建 ADR 记录）
    └─ Phase 6: 索引更新（刷新 index.md）
```

## 维护原则

- **代码是事实来源** — 知识库内容可追溯到代码
- **知识库是编译产物** — 通过分析流程生成，不手动编辑
- **ADR 不可删除** — 历史决策永久保留
- **优先增量更新** — 已有文档只更新变更部分
- **建立交叉引用** — 文档间通过相对路径链接

## Git Hook 自动同步（可选）

安装后，`post-commit` 和 `post-merge` hook 可自动触发知识库增量同步：

```bash
# 安装 hook（在目标仓库根目录执行）
bash hooks/post-commit.sh install
```

## 许可证

MIT
