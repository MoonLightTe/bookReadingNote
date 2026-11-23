# 读书笔记库开发与维护规范 (DEVELOPMENT.md)

本文档是 `bookReadingNote` 知识库的架构规范与 AI 协作基石。任何结构变更、模板修改或自动化脚本更新均须与本文档保持同步。

---

## 1. 核心设计哲学 (First Principles & KISS)

1. **输入阻力最小化**：阅读思考第一，格式排版第二。阅读时的随手草稿丢入 `reading/drafts/`，无需在阅读时纠结目录层级。
2. **两级扁平分类**：正式书籍归档于 `books/<category>/<book-name>/`，分类仅限一层大领域（tech, thinking, management, humanities 等），避免深层目录陷阱。
3. **分章精读与导读中枢**：
   - 严肃/大部头专著：采用独立书籍目录，分章记为 `ch0X-xxx.md`，由目录下的 `README.md` 担任总结与导读中枢。
   - 通识/轻量书：支持单文件快速记录。
4. **思维导图与原文资产作为常驻单一事实源**：
   - 持续更新的思维导图位于书籍目录（`mindmap.xmind`），绝不作为一次性草稿归档或切片。
   - **全书原文支持 (Full-Text References)**：支持在 `books/<category>/<book-name>/references/` 下存放整本书电子书或长文本。当存在原文时，Agent 将自动开启【原文感知前瞻模式】，结合后文伏笔与当前阅读进度，在 `guide.md` 动态提出更具穿透力的建设性思考题。常见大文件格式已在 `.gitignore` 过滤。

---

## 2. 目录结构规范 (Project Structure)

```text
bookReadingNote/
├── .gemini/
│   └── skills/
│       ├── reading-coach/              # 深度阅读领读与主题研讨教练（读前/读中/跨书引导）
│       │   └── SKILL.md
│       ├── note-archiver/              # 自动化归档、领域梳理与原件存底（多书批量分流）
│       │   └── SKILL.md
│       ├── mastery-planner/            # 🎯 硬核学习架构师（DAG依赖图、工时微步、费曼门禁与状态机）
│       │   ├── SKILL.md
│       │   └── references/design-spec.md # 架构决策规范原件 (Rationale & Trade-offs)
│       └── nyx/                        # 🌌 深度思考与提示语路由总督（45件精炼法宝矩阵、辨证引路与全域接力）
│           ├── SKILL.md
│           └── references/             # 7 大场景法宝原文（一字不改强约束库）
├── .agents/
│   └── skills/                         # ZCode 原生 Skill 发现目录（与 .gemini/skills 保持双向镜像同步）
├── .templates/                         # 标准化模板
│   ├── chapter-template.md             # 章节精读模板
│   ├── book-summary-template.md        # 全书导读中枢模板 (guide.md)
│   └── topic-synthesis-template.md     # 跨书主题研讨卡片模板
├── reading/                            # 🚀 纯粹临时输入缓冲区（归档后彻底清空，Inbox Zero）
├── books/                              # 📚 正式书籍库（按宽泛领域平铺，自治内聚）
│   ├── tech/                           # 技术、工程、架构（含导读 guide.md、思维导图、references/与章节）
│   ├── thinking/                       # 思维模型、认知、方法论
│   ├── management/                     # 管理、商业、组织协作
│   └── humanities/                     # 人文、社科、历史哲学
├── topics/                             # 🌐 领域全景与主题阅读研讨区 (Syntopical Reading)
│   ├── README.md                       # 全局领域标签拓扑矩阵
│   └── quotes-matrix.md                # 💎 灵感金句与认知索引矩阵 (场景化检索与调用)
├── learning-tasks/                     # 🛠️ 硬核工程与造轮子实战任务库（读写结合、代码落地，自治内聚 study-state.yaml）
│   ├── learnhub-engine/                # 🔍 LearnHub 核心引擎轻量造轮子实战（原子切片、向量与 RRF 检索、Diff 写入确认）
│   ├── webgl-fps-engine/               # 🎮 Web 3D 游戏引擎开发实战（5大阶段分章打卡，解耦并发 DAG）
│   ├── presenter-drills/               # 🎙️ 表达与讲书人刻意练习任务库 (MVP打卡卡片)
│   └── video-security-lab/             # 🛡️ 视频加密与防盗录攻防实战任务库（三阶红蓝对抗天梯）
├── archive/                            # 🗄️ 归档留痕库
│   └── raw-notes/                      # 原始草稿存底（按 YYYY-MM 归档，不可逆防丢）
├── assets/                             # 全局静态图床/附件
├── DEVELOPMENT.md                      # 系统架构、维护规范与 Skill 进化指南
└── README.md                           # 全库总看板（正在阅读、待读、已读归档）
```

---

## 3. 元数据规范 (YAML Frontmatter)

所有正式归档的章节与总结文档必须包含标准 Frontmatter：

### 章节笔记 (`ch0X-xxx.md`)
```yaml
---
book: "书名"
chapter: "章节序号或名称"
category: "tech | thinking | management | humanities"
date: 2026-11-10
status: "draft | reviewed"
tags:
  - 核心概念1
  - 核心概念2
---
```

### 全书总结 (`README.md`)
```yaml
---
title: "书名"
author: "原作者"
category: "tech"
status: "reading | finished | abandoned"
rating: "★★★★★"
started: 2026-11-01
finished: null
mindmap: "./mindmap.xmind" # 若有持续更新的导图
tags:
  - 架构
  - 分布式
---
```

---

## 3.1 Mermaid 图表工业级兼容规范 (Mermaid Guidelines)

为确保图表在所有 Markdown 预览器（VS Code、GitHub、Obsidian、Typora、网页端）中 100% 毫秒级稳定渲染，杜绝解析崩溃，全库遵循以下硬性准则：

1. **禁用实验性语法 (STRICTLY PROHIBITED)**：
   - **严禁使用 `mindmap`**：对空格缩进极其神经质，且中英文括号 `( )` 会与节点形状关键字严重冲突，导致解析崩溃；
   - **严禁使用 `gitGraph`** 等冷门图表。
2. **全库工业标准类型 (PREFERRED TYPES)**：
   - **树状与知识结构**：统一使用 `graph LR` 或 `flowchart LR`（从左至右自然展开）；
   - **业务流程与阶段推进**：统一使用 `graph TD` 或 `flowchart TD`（从上至下）；
   - **生命周期与状态机**：统一使用 `stateDiagram-v2`。
3. **节点防御包裹铁律 (DEFENSIVE QUOTING)**：
   - **所有节点内容必须用方括号+双引号严密包裹**：`node_id["显示文本内容"]`；
   - 只要用 `["..."]` 包裹，文本内的冒号 `:`、中英文括号 `()`、斜杠 `/`、减号 `-` 等均被解析器作为纯文本字符串（String Literal）安全处理，彻底免疫语法冲突；
   - 节点 ID 保持纯英文字符或编号（如 `root`, `n1`, `n1_1`），逻辑 ID 与展示文本解耦。
4. **中文文本截断防护 (CJK Truncation Defense)**：
   - **成因**：Mermaid 在计算 SVG 节点包围盒（`getBBox()`）时基于英文字体指标，导致 CJK 中文字宽实际渲染超出计算宽度；配合 SVG `<foreignObject>` 默认裁剪，造成右侧文字被切。
   - **文档层防线（原生无依赖）**：
     - 在图表顶部注入指令声明中文字体、折行宽度与边距：`%%{init: {'flowchart': {'htmlLabels': true, 'wrappingWidth': 300, 'padding': 20}, 'themeVariables': {'fontSize': '13px', 'fontFamily': 'PingFang SC, sans-serif'}}}%%`；
     - 长文本节点合理使用 `<br/>` 换行（单行控制在 8-12 个汉字以内）。
   - **环境层防线（MPE / Crossnote 引擎）**：
     - 现代 MPE (v0.8+) 底层采用 Crossnote，macOS 全局配置位于 `~/.local/state/crossnote/style.less`（工作区可置于 `.crossnote/style.less`）：
       ```less
       .markdown-preview.markdown-preview {
         .mermaid {
           foreignObject { overflow: visible !important; }
           .nodeLabel, .label {
             font-size: 13px !important;
             line-height: 1.4 !important;
             font-family: -apple-system, BlinkMacSystemFont, "PingFang SC", sans-serif !important;
           }
         }
       }
       ```
   - **信息架构防线（克制原则）**：
     - 严禁在思维导图或架构图节点中强行塞入 15 字以上的长句子或解释段落；
     - 节点文本严控在 4~10 个汉字精炼骨架词以内，详细解释和案例下沉至正文分析或 Socratic 探针中。

---

## 4. 章节启航工作流 (reading-coach Kickoff Workflow)

当读者准备进入新章节（发送“开始读第 X 章”或“带我读第 X 章”）时：
1. **原文感知探针**：自动读取 `references/` 下的电子书原文，定位该章节的具体小节与论证脉络；
2. **生成 4 维靶向问题与实战探针**：
   - 提炼出覆盖【边界澄清、机理深挖、读者痛点、批判挑刺】的 4 个探照灯问题；
   - **实战任务感知 (Task-Awareness)**：若 `learning-tasks/` 下存在与本书/章节相关的编码实践（如 WebGL/引擎轮子），自动提炼 1 项动手挑战并挂载至草稿底部，实现知行合一。
3. **零阻力自动就绪草稿**：直接在 `reading/` 目录下生成 `reading/<book-name>-ch0X.md`，将问题预置在草稿中，读者直接翻书作答即可。

---

## 5. 自动化归档技能工作流 (note-archiver Workflow)

当调用 `note-archiver` 技能时，系统将遵循**“认知优先、模式分级、资产可召回”**流水线：

1. **三档模式路由 (Mode Routing)**：
   - `--quick`（快速收纳）：静默搬移资产，疑问列为待办建议，不打断心流；
   - `--deep`（深度熔炼）：认知解惑先行，执行 Socratic Q&A 研讨沉淀与金句萃取；
   - `--qa`（纯探讨追问）：针对指定章节追加 `Q(N+1)` 研讨留痕，不清空缓冲区。
2. **依据溯源与读者主权 (Cognitive Sovereignty)**：
   - AI 解答必须严格区分 `[📖 原书事实]`、`[🤖 AI 推演]`、`[💡 读者洞察]`，拒绝幻觉；
   - 嗅探出的金句与任务默认处于 `proposed`（建议稿）状态，经读者确认后方可转正。
3. **资产全局可召回与状态机 (Retrievability & State Engine)**：
   - 所有 Q&A、金句、实战任务分配全局稳定 ID（如 `QA-PRESENTER-CH02-01`、`Q-MIND-01`）；
   - 标注生命周期状态：`unresolved | in_progress | verified | closed`；
   - 规范参见 [.gemini/skills/note-archiver/references/retrieval-spec.md](./.gemini/skills/note-archiver/references/retrieval-spec.md)。
4. **书籍与多媒体资产内聚 (Multi-Asset Cohesion)**：
   - 将思维导图（`mindmap.xmind`）及配图自动移入书籍专属目录（`books/.../assets/`），并重构 Markdown 本地相对链接。
5. **跨书争议留存 (Preserve Syntopical Conflicts)**：
   - 当多本书在同一问题产生根本分歧时，生成 `CONFLICT-` 争议卡，保留认知张力。
6. **原件不可逆存底与收件箱清零**：将原始草稿完整移入 `archive/raw-notes/YYYY-MM/`，确保 `reading/` 彻底清空 (Inbox Zero)。
7. **全局看板更新**：更新根目录 `README.md` 中的在读进度与实战任务导航。

---

## 5. Skill 持续演进与自愈机制 (Skill Evolution & Feedback Loop)

为保证知识库专属 Skills（`reading-coach`、`note-archiver`、`mastery-planner` 与 `nyx`）保持生命力并根据用户的阅读习惯持续进化，建立以下演进机制：

1. **健康体检与审计**：
   - 随时通过 `/yuex-skill-doctor mastery-planner`、`/yuex-skill-doctor note-archiver`、`/yuex-skill-doctor reading-coach` 或 `/yuex-skill-doctor nyx` 触发全面健康诊断，对照 14 项铁律排查弱化措辞、缺失边界等缺陷；
   - `mastery-planner` 的架构决策原件、7大范式融合裁决与第一性原理推演见 [.gemini/skills/mastery-planner/references/design-spec.md](./.gemini/skills/mastery-planner/references/design-spec.md)；
   - `nyx`（夜之女神）作为全库思考中枢与提示语总督，维护 45 件精炼法宝矩阵（32 原生思考提示词 + 7 进阶工程技能 + 6 社区顶级法宝），恪守“原提示词逐字不改”与“对不上就说对不上”铁律，并在思考方案成熟后，精准接力至 `reading-coach`（精读）、`mastery-planner`（代码实战规划）或 `note-archiver`（金句沉淀）。
2. **渐进式反馈沉淀 (Feedback Archive)**：
   - 当日常使用中发现归档分类有误、疑问提取不够敏锐或排版不符合偏好时，直接提出纠偏指令；
   - 触发反馈归档，将修正案例沉淀为 Skill 的 `Few-Shot Examples`（黄金标准样例）。
3. **版本演进铁律**：
   - 技能修改必须做到行为可预期、平滑兼容既有目录结构；
   - 每次 Skill 新增或调整能力，必须同步更新本文档的“目录结构”与“核心逻辑”。

### 外部 Skill 工具箱（用户级 `~/.agents/skills/`，2026-11-15 部署）

- **`learn`**：结构化自主学习教练（6 阶段 14 步学习科学方法论，已适配中文触发词与本仓库 `learning-tasks/`、`references/` 结构）。用于跨会话的学习进度调度与检索复习，与 reading-coach（单章领读）形成长短线互补。
- **cc-thinking-skills 选装 5 项**：`thinking-systems`（系统动力学，对口 DDIA）、`thinking-probabilistic`（概率思维，对口《思考，快与慢》）、`thinking-steel-manning`（先立最强反方，补强批判维度）、`thinking-first-principles`（第一性原理，对口引擎造轮子）、`thinking-pre-mortem`（事前验尸，对口阶段验收）。均为**手动点名调用**（`disable-model-invocation: true`），不参与自动触发。
- 上述工具属个人用户级环境，不提交本仓库；在本库深读时可显式点名配合使用。

---

## 6. Git 版本控制与维护准则

1. **分支策略**：个人知识库默认基于 `main` 主干开发。
2. **提交规范 (Conventional Commits)**：
   - `feat(book):` 新书/新章节笔记归档（例如 `feat(ddia): archive ch02 notes`）
   - `docs(topic):` 主题研讨卡片或导读更新
   - `refactor(skill):` 优化或进化专属 Skill
   - `chore:` 调整看板、更新模板或配置
3. **安全与纯粹性**：
   - `.gitignore` 过滤系统缓存（`.DS_Store`）与编辑器配置。
   - 所有归档内容保持为通用 Markdown 与标准二进制导图，严禁将专有工具私有缓存提交进仓库。

---

## 7. TODOs 与演进规划

- [x] 初始化目录骨架与规范文档 `DEVELOPMENT.md`
- [x] 创建标准化模板 (`chapter-template.md`, `book-summary-template.md`, `topic-synthesis-template.md`)
- [x] 初始化根目录总看板 `README.md` 与领域拓扑 `topics/README.md`
- [x] 实现并部署 `note-archiver` 专属技能（支持多书并发、原件存底、Inbox Zero）
- [x] 实现并部署 `reading-coach` 专属技能（支持艾德勒四大阅读层级与跨书主题研讨）
- [x] 端到端多书混合归档与领域拓扑演练（实测验证通过）
- [x] 建立 Skill 持续演进与反馈闭环机制
- [x] 初始化 Git 仓库并完成首个工程提交 (main branch)
- [x] 搭建 `learning-tasks/webgl-fps-engine/` 5大阶段硬核造轮子实战任务库（读写做合一）
- [x] 搭建 `learning-tasks/presenter-drills/` 讲书人表达刻意练习打卡任务库
- [x] 初始化 `topics/quotes-matrix.md` 场景化金句与认知索引矩阵 (收录12条核心金句)
- [x] 基于第一性原理全面重塑 `note-archiver 2.0`（模式分级、依据溯源、资产稳定ID与生命周期状态机）
- [x] 完成《成为讲书人》ch00、ch01、ch02 历史资产全量对齐与 Socratic Q&A 研讨沉淀
- [x] 设计并部署 `mastery-planner` 硬核学习规划技能（融合 DAG 拓扑、代码微步、费曼门禁与状态机）
- [x] 全面打通 `learning-tasks/` 状态机架构：完成 `video-security-lab`、`webgl-fps-engine` 与 `presenter-drills` 的 DAG 拓扑重构与 `study-state.yaml` 导入
- [x] 设计、转化并部署 `nyx`（夜之女神）思考与提示语路由总督（收录 45 件核心法宝矩阵，打通 reading-coach、mastery-planner 与 note-archiver 接力链）
- [ ] 推进《成为讲书人》第 3 章“如何精准传递书中的信息”研读 (阶梯思考题 5 已就绪)
- [ ] 推进 `learnhub-engine` 核心引擎轮子开发（N1 结构保护原子分块器与本地检索）
