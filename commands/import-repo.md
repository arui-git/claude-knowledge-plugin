---
name: claude-knowledge-plugin:import-repo
description: 接入新 Git 仓库，完整分析并生成全套知识文档
---

# /import-repo

接入新的 Git 仓库，执行完整的 6 阶段分析流程。

## 参数

- `path`（必需）— Git 仓库的本地路径

## 前置条件

知识库已初始化（`/init-project` 已执行）。若未初始化，先引导用户初始化。

## 执行步骤

### Phase 1: 项目发现

1. **确认 Git 仓库**
   ```bash
   git -C <path> rev-parse --is-inside-work-tree
   ```

2. **获取基础信息**
   - 项目名称（目录名或 remote URL）
   - Git remote URL
   - HEAD commit hash
   - 总提交数

3. **扫描技术栈**
   - 检测配置文件（pom.xml / package.json / go.mod / ...）
   - 识别语言、框架、数据库、中间件
   - 提取版本信息

4. **分析模块结构**
   - 目录布局（maxdepth 4）
   - 包/模块划分
   - 入口文件

5. **提取依赖**
   - 直接依赖及版本
   - 内部依赖
   - 外部服务依赖

6. **分析 Git 历史**
   - 最近 20 条提交（变更方向）
   - 活跃文件 Top 30（核心模块）
   - 贡献者
   - 版本标签

7. **识别服务边界**
   - 微服务/单体判断
   - API 定义（OpenAPI/Protobuf）
   - 消息队列配置
   - 服务注册/发现

### Phase 2: 项目知识生成

使用项目模板生成 `knowledge/projects/<project-name>.md`。

必须包含：
- 项目简介
- 技术栈详情
- 模块结构 & 职责
- 核心业务流程（至少描述 2-3 条关键路径）
- 外部依赖
- 风险点
- 关联知识链接
- 元信息（时间、commit、路径）

### Phase 3: 知识关联

读取现有知识库，建立交叉引用：

```
遍历 knowledge/systems/*.md     → 匹配项目使用的技术
遍历 knowledge/architecture/*.md → 匹配项目采用的架构
遍历 knowledge/adr/*.md          → 匹配项目涉及的决策
遍历 knowledge/projects/*.md     → 匹配项目间依赖
```

在项目文档中添加关联链接，在被引用文档中添加反向链接。

### Phase 4: 知识沉淀

发现新技术（`knowledge/systems/` 中不存在）：
- 使用系统模板创建文档
- 记录核心特性、配置要点、在项目中的使用

发现新架构模式（`knowledge/architecture/` 中不存在）：
- 使用架构模板创建文档
- 记录模式图解、适用场景、项目中的实现

### Phase 5: ADR 维护

分析 Git 历史中的架构变化：

```bash
git log --all --grep="migrate\|switch\|replace\|refactor\|redesign" --oneline
git log --all -- pom.xml package.json go.mod Dockerfile docker-compose.yml --oneline
```

发现架构决策时：
1. 收集决策信息（上下文、备选方案、理由）
2. 触发 `adr-manager` 创建 ADR
3. 建立到项目文档的关联

### Phase 6: 索引更新

更新 `knowledge/index.md`：
- 项目索引：添加新项目条目
- 技术索引：添加新技术条目或更新使用项目列表
- 架构索引：添加新架构条目或更新使用项目列表
- ADR 索引：添加新 ADR 条目

## 输出

完成后报告生成文件清单和关联更新：

```
项目 <name> 接入完成。

生成文件:
  knowledge/projects/<name>.md            (项目知识)
  knowledge/systems/<tech-a>.md           (新增技术知识)
  knowledge/systems/<tech-b>.md           (新增技术知识)
  knowledge/architecture/<pattern>.md     (新增架构知识)
  knowledge/adr/ADR-NNN-<title>.md        (新增 ADR)

关联更新:
  knowledge/systems/<existing>.md         (添加使用项目)
  knowledge/architecture/<existing>.md    (添加实现案例)
  knowledge/projects/<related>.md         (添加项目依赖)
  knowledge/index.md                      (索引更新)

总计: +5 新文件, +4 关联更新
```
