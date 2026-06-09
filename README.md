# claude-knowledge-plugin

Claude Code 插件 — 开发知识库全生命周期管理系统。

自动扫描 Git 仓库代码，生成项目知识、架构文档、ADR，维护技术知识库，支持多项目接入和团队共享。

## 快速开始

### 方式一：通过 Marketplace 安装（推荐）

```bash
# 添加插件市场
/plugin marketplace add arui-git/claude-knowledge-plugin

# 安装插件
/plugin install claude-knowledge-plugin@knowledge-tools
```

安装完成后，在任意项目中即可使用所有命令和 Skill。

### 方式二：手动安装

1. 将 `skills/` 目录复制到项目的 `.claude/skills/` 下
2. 将 `templates/` 中需要的模板复制到项目根目录
3. 在项目 `.claude/settings.json` 中注册 hooks（可选）

## 使用流程

### Step 1: 初始化知识库

```
/claude-knowledge-plugin:init-project
```

按提示选择知识库路径：
- 当前项目目录下 `knowledge/`（单项目）
- 指定独立目录（多项目共享）
- 克隆已有 Git 仓库（团队共享）

### Step 2: 接入项目

```
/claude-knowledge-plugin:import-repo /path/to/your/project
```

自动执行 6 阶段分析：
1. **项目发现** — 扫描 Git 仓库、配置文件、目录结构
2. **知识生成** — 按模板输出项目知识文档
3. **知识关联** — 对比现有知识库，建立交叉引用
4. **知识沉淀** — 发现新技术/架构，创建对应文档
5. **ADR 维护** — 识别架构决策，创建 ADR 记录
6. **索引更新** — 刷新 index.md

### Step 3: 增量同步

项目代码变更后，同步更新知识库：

```
/claude-knowledge-plugin:sync-project [project-name]
```

不指定名称则同步所有已接入项目。基于 Git diff 增量更新，只修改变更部分。

### 日常使用

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

安装 Hook 配置：

```bash
# 将 hooks 配置合并到项目的 .claude/settings.json
# 参考 hooks/session-start-knowledge.json
```

或在 `.claude/settings.json` 中手动添加：

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash ${CLAUDE_PROJECT_DIR}/.claude/hooks/session-start-knowledge.sh"
          }
        ]
      }
    ]
  }
}
```

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
| `/claude-knowledge-plugin:init-project` | 初始化知识库，创建目录结构和索引 |
| `/claude-knowledge-plugin:sync-project` | 增量同步项目知识（基于 Git diff） |
| `/claude-knowledge-plugin:import-repo` | 接入新仓库，完整分析并生成知识文档 |

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
│   ├── CLAUDE.md                # 项目配置模板
│   └── knowledge-layout/        # 知识库目录结构模板
├── hooks/                       # Hooks
│   ├── post-commit.sh           # Git post-commit（可选）
│   ├── post-merge.sh            # Git post-merge（可选）
│   ├── session-start-knowledge.sh  # SessionStart 知识库注入
│   └── session-start-knowledge.json # Hook 配置示例
├── installer/                   # 安装器
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

## 维护原则

- **代码是事实来源** — 知识库内容可追溯到代码
- **知识库是编译产物** — 通过分析流程生成，不手动编辑
- **ADR 不可删除** — 历史决策永久保留
- **优先增量更新** — 已有文档只更新变更部分
- **建立交叉引用** — 文档间通过相对路径链接

## Git Hook 自动同步（可选）

```bash
# 安装 hook（在目标仓库根目录执行）
bash hooks/post-commit.sh install
bash hooks/post-merge.sh install

# 卸载
bash hooks/post-commit.sh uninstall
bash hooks/post-merge.sh uninstall
```

## 许可证

MIT
