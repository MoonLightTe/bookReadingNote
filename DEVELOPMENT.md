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
│       └── note-archiver/              # 自动化归档、领域梳理与原件存底（多书批量分流）
│           └── SKILL.md
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
│   └── README.md                       # 全局领域标签拓扑矩阵
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

## 4. 章节启航工作流 (reading-coach Kickoff Workflow)

当读者准备进入新章节（发送“开始读第 X 章”或“带我读第 X 章”）时：
1. **原文感知探针**：自动读取 `references/` 下的电子书原文，定位该章节的具体小节与论证脉络；
2. **生成 4 维靶向问题**：提炼出覆盖【边界澄清、机理深挖、读者痛点、批判挑刺】的 4 个探照灯问题；
3. **零阻力自动就绪草稿**：直接在 `reading/` 目录下生成 `reading/<book-name>-ch0X.md`，将问题预置在草稿中，读者直接翻书作答即可。

---

## 5. 自动化归档技能工作流 (note-archiver Workflow)

当调用 `note-archiver` 技能时，系统将遵循以下流水线：
1. **多书扫描与识别**：读取 `reading/` 中的全部文件（多份草稿与导图），按书名和领域自动分组。
2. **格式规范化**：按 `.templates/chapter-template.md` 重构排版与各模块（导读问题、核心提炼、批判反思）。
3. **疑问抽取与动态导读维护**：
   - 提取草稿中记录的未知问题或疑惑，追加到书籍主 `guide.md` 的【读者未决疑问库】。
   - **动态进阶导读机制 (Living Guide)**：归档时结合本章结论与下一章预告，在【教练阶梯思考罗盘】动态生成 1~2 个深度思考题，铺设认知阶梯。
   - 更新章节索引表与一句话精要。
4. **书籍自治内聚**：将思维导图移入书籍专属目录（`mindmap.xmind`），并联动更新 `guide.md` 章节索引表。
5. **领域拓扑更新**：提取书籍 Tags，同步更新 `topics/README.md` 的领域矩阵。
6. **原件不可逆存底与清空**：将原始草稿完整移入 `archive/raw-notes/YYYY-MM/`，确保 `reading/` 彻底清空 (Inbox Zero)。
7. **全局看板更新**：更新根目录 `README.md` 中的在读进度。

---

## 5. Skill 持续演进与自愈机制 (Skill Evolution & Feedback Loop)

为保证知识库专属 Skills（`reading-coach` 与 `note-archiver`）保持生命力并根据用户的阅读习惯持续进化，建立以下演进机制：

1. **健康体检与审计**：
   - 随时通过 `/yuex-skill-doctor note-archiver` 或 `/yuex-skill-doctor reading-coach` 触发全面健康诊断，对照 14 项铁律排查弱化措辞、缺失边界等缺陷。
2. **渐进式反馈沉淀 (Feedback Archive)**：
   - 当日常使用中发现归档分类有误、疑问提取不够敏锐或排版不符合偏好时，直接提出纠偏指令；
   - 触发反馈归档，将修正案例沉淀为 Skill 的 `Few-Shot Examples`（黄金标准样例）。
3. **版本演进铁律**：
   - 技能修改必须做到行为可预期、平滑兼容既有目录结构；
   - 每次 Skill 新增或调整能力，必须同步更新本文档的“目录结构”与“核心逻辑”。

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
