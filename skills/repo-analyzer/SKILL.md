---
name: claude-knowledge-plugin:repo-analyzer
description: Git 仓库扫描与项目知识生成 — 技术栈识别、模块分析、依赖提取、Git 历史挖掘
triggers:
  - 接入项目
  - 分析项目
  - 分析仓库
  - 阅读代码库
  - 建立项目知识
  - 项目梳理
---

# Repo Analyzer

## 职责

扫描 Git 仓库，提取结构化知识，生成项目知识文档。

## 分析流程

### Phase 1: 项目发现

#### 1.1 确认项目基础信息

```bash
# 确认 Git 仓库
git -C <path> rev-parse --is-inside-work-tree

# 获取项目名
basename <path>

# 获取远程地址
git -C <path> remote get-url origin 2>/dev/null
```

#### 1.2 识别技术栈

扫描配置文件：

| 文件 | 技术栈 |
|------|--------|
| `package.json` | Node.js / JavaScript / TypeScript |
| `tsconfig.json` | TypeScript |
| `pom.xml` | Java / Maven |
| `build.gradle` / `build.gradle.kts` | Java / Gradle |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `pyproject.toml` / `setup.py` / `requirements.txt` | Python |
| `Gemfile` | Ruby |
| `*.csproj` / `*.sln` | .NET / C# |
| `composer.json` | PHP |
| `Makefile` / `CMakeLists.txt` | C / C++ |
| `Dockerfile` | 容器化 |
| `docker-compose.yml` | 多服务编排 |
| `.github/workflows/` | GitHub Actions |
| `Jenkinsfile` | Jenkins |

#### 1.3 分析模块结构

```bash
# 目录结构（限制深度，排除 node_modules/vendor/.git）
find <path> -maxdepth 4 -type d | grep -v node_modules | grep -v .git | grep -v vendor
```

#### 1.4 提取依赖信息

根据技术栈读取对应配置文件，提取：
- 直接依赖及版本
- 内部依赖（公司/组织内部库）
- 框架和中间件

#### 1.5 分析 Git 历史

```bash
# 近期提交（变更方向）
git log --oneline -20

# 活跃文件（核心模块）
git log --format="" --name-only | sort | uniq -c | sort -rn | head -30

# 贡献者
git shortlog -sn

# 版本标签
git tag --sort=-version:refname | head -10
```

### Phase 2: 项目知识生成

使用项目模板（`templates/knowledge-layout/projects/project-template.md`）生成文档。

输出到：`knowledge/projects/<project-name>.md`

文档必须包含：
- [x] 项目简介（业务目的、领域）
- [x] 技术栈详情（语言、框架、数据库、中间件）
- [x] 模块结构 & 职责划分
- [x] 核心业务流程（关键路径描述）
- [x] 外部依赖关系
- [x] 风险点 & 技术债
- [x] 关联知识链接
- [x] 元信息（时间、commit hash、路径）

### Phase 3: 知识关联

读取现有知识库：
```
knowledge/systems/*.md
knowledge/architecture/*.md
knowledge/adr/*.md
knowledge/projects/*.md
```

建立交叉引用：
- 项目使用了哪些技术 → 链接到 systems/
- 项目采用了哪些架构 → 链接到 architecture/
- 项目涉及哪些决策 → 链接到 adr/
- 项目间依赖 → 链接到 projects/

### Phase 4: 知识沉淀

发现新技术 → 使用系统模板创建 `knowledge/systems/<tech>.md`
发现新架构 → 使用架构模板创建 `knowledge/architecture/<pattern>.md`

### Phase 5: ADR 检查

分析 Git 历史中的架构变化：
```bash
git log --all --grep="migrate\|switch\|replace\|refactor\|redesign" --oneline
git log --all -- pom.xml package.json go.mod Dockerfile --oneline
```

发现架构决策时，触发 `adr-manager` 创建 ADR。

### Phase 6: 索引更新

更新 `knowledge/index.md`，在对应索引表中添加新条目。

## 服务边界识别

识别微服务/单体架构：
- 多个独立服务目录 → 微服务
- Docker Compose 服务定义 → 编排
- OpenAPI/Swagger/Protobuf → API 定义
- 消息队列配置 → 异步通信
- 服务注册/发现配置 → 服务治理

## 技术栈深度分析

对 Java 项目额外分析：
- Spring Boot starter 依赖 → 组件清单
- MyBatis mapper XML → 数据访问层
- 自定义 Filter/Interceptor → 请求处理链
- 配置类（@Configuration）→ 模块配置

对前端项目额外分析：
- 路由定义 → 页面结构
- 状态管理 → 数据流
- 组件目录 → UI 模块
- API 层 → 后端接口依赖

## 关联 Skill

- `knowledge-manager` — 知识沉淀后触发索引更新
- `adr-manager` — 发现架构决策时触发 ADR 创建
