#还是半成品

# claude-knowledge-plugin

Claude Code 插件 — 开发知识库全生命周期管理系统。

自动扫描 Git 仓库代码，生成项目知识、架构文档、ADR，维护技术知识库，支持多项目接入和团队共享。

## 快速开始

### 方式一：通过 Marketplace 安装（推荐）

```bash
# Claude code 官方推荐设置环境变量，强制所有插件源的克隆使用 HTTPS
export CLAUDE_CODE_PLUGIN_PREFER_HTTPS=true

# 在Claude code中执行以下命令
# 添加插件市场
/plugin marketplace add arui-git/claude-knowledge-plugin

# 安装插件
/plugin install claude-knowledge-plugin@knowledge-tools
```

安装完成后，在任意项目中即可使用所有命令和 Skill。

### 方式二：本地安装

```bash
# 1. 将插件仓库克隆到本地
git clone https://github.com/arui-git/claude-knowledge-plugin.git

# 2. 使用本地路径添加市场
/plugin marketplace add /path/to/claude-knowledge-plugin
```

## 使用流程

接收一个新项目时的完整流程：

### Step 1: 初始化知识库

```
/claude-knowledge-plugin:init-project
```

Agent 会自动：
- 检测当前项目是否已有知识库（如有则直接使用）
- 引导选择知识库路径（当前项目 / 独立目录 / 克隆远程仓库）
- 创建目录结构和索引
- **强制安装所有 Hook**（SessionStart、post-commit、post-merge），无需手动配置
- 询问是否立即执行首次项目扫描

### Step 2: 接入项目

```
/claude-knowledge-plugin:import-repo
```

默认接入**当前项目**，也可指定路径：

```
/claude-knowledge-plugin:import-repo /path/to/project
```

自动执行 6 阶段分析：
1. **项目发现** — 扫描 Git 仓库、配置文件、目录结构
2. **知识生成** — 按模板输出项目知识文档
3. **知识关联** — 对比现有知识库，建立交叉引用
4. **知识沉淀** — 发现新技术/架构，创建对应文档
5. **ADR 维护** — 识别架构决策，创建 ADR 记录
6. **索引更新** — 刷新 index.md

### Step 3: 手动同步

```
/claude-knowledge-plugin:sync-project
```

默认同步**当前项目**（自动匹配当前目录）。也可指定项目名称或同步全部：

```
/claude-knowledge-plugin:sync-project <project-name>
/claude-knowledge-plugin:sync-project --all
```

基于 Git diff 增量更新，只修改变更部分。

### Step 4: 自动同步（push 后）

当 Agent 执行 `git push` 后，自动触发知识库增量同步，无需手动操作。

## 日常使用

安装后可在对话中直接用自然语言触发 Skill：

| 你说 | 触发的 Skill | 动作 |
|------|-------------|------|
| "分析项目 xxx" | repo-analyzer | 完整仓库扫描 |
| "接入项目 xxx" | repo-analyzer | 导入新仓库 |
| "更新知识库" | knowledge-manager | 增量同步 |
| "同步文档" | knowledge-manager | 更新文档 |
| "生成ADR" | adr-manager | 创建架构决策记录 |
| "架构决策" | adr-manager | ADR 管理 |

## 主动知识搜索（自动）

插件安装后，Claude 会**主动搜索知识库**，无需用户手动触发：

1. **SessionStart Hook** — 每次会话启动时，自动注入 `knowledge/index.md` 到上下文，Claude 始终知道知识库有什么
2. **knowledge-search Skill** — 当用户问题涉及项目技术栈、架构、依赖、决策历史时，Claude 自动搜索 `knowledge/` 目录获取详情

## 核心能力

| Skill | 触发词 | 说明 |
|-------|--------|------|
| **claude-knowledge-plugin:knowledge-manager** | 更新知识库、同步文档、维护开发文档 | 知识库全生命周期管理 |
| **claude-knowledge-plugin:adr-manager** | 生成ADR、架构决策 | 架构决策记录管理 |
| **claude-knowledge-plugin:repo-analyzer** | 接入项目、分析项目、分析仓库、阅读代码库 | Git 仓库扫描与项目知识生成 |
| **claude-knowledge-plugin:knowledge-search** | 自动触发（不可手动调用） | Claude 主动搜索知识库 |

## 用户命令

| 命令 | 说明 |
|------|------|
| `/claude-knowledge-plugin:init-project` | 初始化知识库，自动检测已有知识库，自动安装 Hook |
| `/claude-knowledge-plugin:import-repo [path]` | 接入项目（默认当前项目），完整分析并生成知识文档 |
| `/claude-knowledge-plugin:sync-project [name]` | 增量同步项目知识（默认当前项目，`--all` 同步全部） |

## 目录结构

```
claude-knowledge-plugin/
├── .claude-plugin/
│   ├── plugin.json              # 插件清单
│   └── marketplace.json         # 市场配置
├── skills/                      # 核心能力模块
│   ├── knowledge-manager/       # 知识库生命周期管理
│   ├── adr-manager/             # ADR 管理
│   ├── repo-analyzer/           # 仓库分析器
│   └── knowledge-search/        # 主动知识搜索（Claude 自动调用）
├── commands/                    # 用户入口命令
│   ├── init-project.md
│   ├── sync-project.md
│   └── import-repo.md
├── templates/                   # 模板文件
│   ├── CLAUDE.md                # 项目配置模板（含自动同步规则）
│   └── knowledge-layout/        # 知识库目录结构模板
├── hooks/                       # Hooks
│   ├── post-commit.sh           # Git post-commit（自动安装）
│   ├── post-merge.sh            # Git post-merge（自动安装）
│   ├── session-start-knowledge.sh  # SessionStart 知识库注入（自动安装）
│   └── session-start-knowledge.json # Hook 配置示例
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

## 维护原则

- **代码是事实来源** — 知识库内容可追溯到代码
- **知识库是编译产物** — 通过分析流程生成，不手动编辑
- **ADR 不可删除** — 历史决策永久保留
- **优先增量更新** — 已有文档只更新变更部分
- **建立交叉引用** — 文档间通过相对路径链接
- **push 自动同步** — Agent push 后自动触发知识库增量更新

## 许可证

MIT
