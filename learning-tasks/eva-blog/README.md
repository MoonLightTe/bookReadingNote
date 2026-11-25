# EVA 风格个人技术博客实战 (eva-blog)

> **定位**：Astro 7 + EVA 战术控制台极客风格的纯静态个人技术博客。  
> **状态机**：[`study-state.yaml`](./study-state.yaml)  
> **设计原件**：[`design/mockup.html`](./design/mockup.html)  
> **架构设计**：[`ARCHITECTURE.md`](./ARCHITECTURE.md)  
> **驱动引擎**：`python3 scripts/mastery_state.py status`

---

## 1. 终极交付目标 (Final Goal)

在 `learning-tasks/eva-blog/` 下手写交付基于 Astro 7 的 EVA 战术终端风格个人技术博客，具备昼夜翻面、MAGI 深色代码与图表面板、同期率进度、Pagefind 离线检索与 GitHub Actions 自动发布能力。

---

## 2. 剪枝清单 (Explicit Cut-list)

- ❌ **本期明确跳过自建后端服务、登录认证与数据库体系**：坚持纯静态站点。
- ❌ **本期明确跳过阅读量、点赞统计等动态数据打点**：无外部接口依赖。
- ❌ **本期明确跳过 Tailwind 等原子类 CSS 框架**：恪守纯原生 CSS 变量系统。
- ❌ **本期明确跳过商业字体 Matisse EB**：全站标题卡统一采用开源免费的思源宋体 Heavy/Black。
- ❌ **本期明确跳过自建评论管理系统**：评论完全委托给 Giscus (GitHub Discussions)。

---

## 3. DAG 拓扑与执行状态

```mermaid
%%{init: {'flowchart': {'htmlLabels': true, 'wrappingWidth': 320, 'padding': 20}, 'themeVariables': {'fontSize': '13px', 'fontFamily': 'PingFang SC, sans-serif'}}}%%
flowchart TD
    N1["N1: 【架构设计与样式契约】Design Tokens、Markdown 元素与 EVA 母题映射规范<br/>(fundamentals) [⚪ 就绪]"]
    N2["N2: 【脚手架与渲染探针】Astro 7 + Unified + 复杂 Markdown/KaTeX/Code Spike<br/>(fundamentals) [🔒 锁定]"]
    N3["N3: 【布局与昼夜切换】无闪烁 Head 脚本、BaseLayout 与导航系统<br/>(fundamentals) [🔒 锁定]"]
    N4["N4: 【内容架构与契约校验】Content Layer、Frontmatter Zod 约束与样例文档<br/>(building_blocks) [🔒 锁定]"]
    N5["N5: 【文章页核心交互】TitleCard 标题卡、MAGI 终端、TOC 目录与同期率进度<br/>(building_blocks) [🔒 锁定]"]
    N6["N6: 【扩展能力与交互增强】次回予告、astro-mermaid 恒深色图表与内嵌 Vue 交互<br/>(building_blocks) [🔒 锁定]"]
    N7["N7: 【聚合看板与离线检索】首页话数索引列表、标签聚合页与 Pagefind 中文分词<br/>(building_blocks) [🔒 锁定]"]
    N8["N8: 【交付闭环与自动发布】RSS、Sitemap、EMERGENCY 404 与 GitHub Pages 部署<br/>(real_application) [🔒 锁定]"]

    N1 --> N2
    N1 --> N3
    N2 --> N4
    N3 --> N5
    N4 --> N5
    N5 --> N6
    N5 --> N7
    N6 --> N8
    N7 --> N8
```

---

## 4. 任务清单总览

| 节点 | 阶段 | 难度 | 前置 | 核心交付标准 | 状态 |
|---|---|---|---|---|---|
| **N1** | fundamentals | medium | - | 产出《EVA 博客样式与渲染架构规范文档》，定死昼夜 CSS Token 与 Markdown 映射表 | ⚪ 就绪 |
| **N2** | fundamentals | high | N1 | Astro 7 骨架与 Unified 处理器验证，KaTeX/代码块/Alert 探针页 `pnpm build` 退出码 0 | 🔒 锁定 |
| **N3** | fundamentals | medium | N1 | BaseLayout 与 ThemeToggle，首屏防闪烁脚本，全站昼夜平滑翻面 | 🔒 锁定 |
| **N4** | building_blocks | medium | N2 | `src/content.config.ts` Content Layer 与 Zod 校验，字段违规精准报错拦截 | 🔒 锁定 |
| **N5** | building_blocks | high | N3, N4 | 极粗宋体标题卡、TOC 吸顶滚动联动、同期率百分比与进度线同步更新 | 🔒 锁定 |
| **N6** | building_blocks | high | N5 | 日夜模式下恒深色 Mermaid 渲染、正文内嵌响应式 Vue 控件、次回予告联结 | 🔒 锁定 |
| **N7** | building_blocks | medium | N5 | 首页倒序话数索引、标签聚合页、Pagefind 中文分词毫秒级快速全文搜索 | 🔒 锁定 |
| **N8** | real_application | medium | N6, N7 | RSS/Sitemap/斜纹 404，GitHub Actions 自动化构建部署至 GitHub Pages | 🔒 锁定 |
