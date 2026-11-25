# 实现计划（V1）

> 状态：**待你审核**。
> 配合 [ARCHITECTURE.md](../ARCHITECTURE.md) 使用。这里只负责把里程碑拆成可以逐个完成的任务，选型和理由不在这里重复。
> 任务状态登记在第 1 节。带 ⚠ 的任务含有未实跑验证的内容，做法以实际结果为准；验证后回写 ARCHITECTURE.md 的「待验证清单」。

## 1. 任务状态

状态流转：待办 → 进行中 → 待自测 → 已完成。「已完成」以你自测通过为准，不以门禁通过为准。

建议按编号顺序做。M2-1 是整个计划里风险最高的一项，所以排在最前面。

| 编号 | 任务 | 前置任务 | 状态 |
|---|---|---|---|
| M0-1 | 初始化 Astro 项目并安装依赖 | 无 | 待办 |
| M0-2 | 配好门禁命令 | M0-1 | 待办 |
| M0-3 | Git 初始化 | M0-2 | 待办 |
| M1-1 | 设计令牌与全局样式 | M0-3 | 待办 |
| M1-2 | 内容集合与 Frontmatter | M0-1 | 待办 |
| M1-3 | 基础布局与主题切换 | M1-1 | 待办 |
| M1-4 | 首页 | M1-2、M1-3 | 待办 |
| M2-1 | ⚠ 渲染管线最小验证 | M1-4 | 待办 |
| M2-2 | 正文样式与代码块外框 | M2-1 | 待办 |
| M2-3 | 文章页 | M2-2 | 待办 |
| M2-4 | 目录与标题锚点 | M2-3 | 待办 |
| M2-5 | 同期率 | M2-3 | 待办 |
| M2-6 | 次回予告 | M2-3 | 待办 |
| M2-7 | 标签页 | M1-4 | 待办 |
| M2-8 | ⚠ 图片资源 | M2-2 | 待办 |
| M2-9 | 内嵌 Vue 组件 | M2-3 | 待办 |
| M2-10 | 全元素样例文章 | M2-2 至 M2-9 | 待办 |
| M3-1 | ⚠ Mermaid 图表 | M2-2 | 待办 |
| M3-2 | ⚠ 站内搜索 | M1-3 | 待办 |
| M3-3 | 评论 | M2-3 | 待办 |
| M4-1 | RSS、Sitemap、robots.txt | M1-2 | 待办 |
| M4-2 | 404 页 | M1-3 | 待办 |
| M4-3 | ⚠ 部署上线 | M1 至 M4-2 全部 | 待办 |
| M4-4 | 上线后自测 | M4-3 | 待办 |
| M4-5 | 项目子 skill | M0-3 | 待办 |

M3 的三项互不依赖，可以任意安排顺序。

## 2. 门禁与提交约定

每个里程碑收尾时，下面两条必须实跑通过，退出码都是 0：

```sh
pnpm build
pnpm astro check
```

提交由你来做。如果让 Agent 实现某个任务，它只改代码、跑门禁、报告结果，不代为提交。

## 3. 任务详情

### M0 项目初始化

**M0-1 初始化 Astro 项目并安装依赖**

- 做什么：`pnpm create astro@latest -- --template blog`，然后安装 ARCHITECTURE.md 技术栈表里的依赖。
- 涉及：`package.json`、`pnpm-lock.yaml`、`astro.config.mjs`
- 验收：`pnpm dev` 能打开首页和示例文章；`pnpm build` 退出码 0。
- 备注：目录里已有 `design/` 和文档，脚手架遇到非空目录会询问，选继续。

**M0-2 配好门禁命令**

- 做什么：安装 `@astrojs/check` 与 `typescript`；在 `package.json` 里加 `"check": "astro check"`。
- 验收：`pnpm build` 与 `pnpm astro check` 的退出码都是 0。

**M0-3 Git 初始化**

- 做什么：`git init`；确认 `.gitignore` 里有 `node_modules/`、`dist/`、`.astro/`；做首个提交。
- 验收：`git status` 里不出现依赖目录和构建产物。
- 备注：提交信息格式是 `type(scope): 中文描述`。分支操作按 git-flow 技能执行。

### M1 设计令牌与骨架

**M1-1 设计令牌与全局样式**

- 做什么：把视觉稿 `<style>` 里的 Token 段搬进 `src/styles/global.css`，带上昼/夜两套变量；加上双轨滚动条、`:focus-visible`、`prefers-reduced-motion` 降级。
- 涉及：`src/styles/global.css`
- 验收：昼/夜两套变量齐全；组件里没有写死的色值，全部引用变量。

**M1-2 内容集合与 Frontmatter**

- 做什么：按 ARCHITECTURE.md 的 2.3 节改写 `src/content.config.ts`；给示例文章补上 `episode` 与 `tags`。
- 涉及：`src/content.config.ts`、`src/content/blog/`
- 验收：故意漏写 `episode` 时，构建报错并指出是哪个文件。

**M1-3 基础布局与主题切换**

- 做什么：`BaseLayout.astro`，包含 `<head>` 里的防闪烁内联脚本、站点导航、页脚状态栏和 `ThemeToggle`。
- 涉及：`src/layouts/BaseLayout.astro`、`src/components/ThemeToggle.astro`
- 验收：刷新页面时主题不闪；切换昼/夜时标题卡翻面；只用 Tab 键能走完全部导航项。

**M1-4 首页**

- 做什么：标题卡、话数列表、标签筛选。
- 涉及：`src/pages/index.astro`、`TitleCard.astro`、`EpisodeList.astro`
- 验收：列表按发布日期倒序；生产构建里不出现草稿；标签筛选可用；375px 宽度下没有横向滚动条。

### M2 文章页与 Markdown 管线

**M2-1 ⚠ 渲染管线最小验证**

- 做什么：按 ARCHITECTURE.md 的 2.4 节配置处理器与插件。写一篇测试文章，里面放一个公式、一个故意写错的公式、一个提示框、一个代码块。
- 涉及：`astro.config.mjs`、一篇测试文章
- 验收：三类内容都出现在构建产物里；`pnpm build` 退出码 0。
- 验证后要回写的事：处理器写法是否生效、expressive-code 是否正常、KaTeX 对错误公式输出了什么 HTML。对应 ARCHITECTURE.md 待验证清单的第 1、2、4 项。

**M2-2 正文样式与代码块外框**

- 做什么：把视觉稿里 `.post-body` 开头的规则，以及终端、公式面板、提示框的样式搬进 `src/styles/markdown.css`。用 Expressive Code 的 `styleOverrides` 把外框改成 MAGI 终端，只配一个深色语法主题。
- 涉及：`src/styles/markdown.css`、`astro.config.mjs`
- 验收：对照视觉稿 Markdown 页的 01 到 05 区、07 和 08 区，逐项一致。

**M2-3 文章页**

- 做什么：路由 `/blog/[slug]`。标题卡头里放日期、阅读时长和标签，下面是正文。阅读时长用 `src/lib/format.ts` 里的纯函数按字数估算。
- 涉及：`src/pages/blog/[slug].astro`、`TitleCard.astro`、`src/lib/format.ts`
- 验收：示例文章能正常打开；配上 `base` 之后，样式和图片的路径仍然正确。

**M2-4 目录与标题锚点**

- 做什么：`Toc.astro`，桌面端在右侧吸顶，窄屏折叠成一个可展开的块。每个标题带 id 和可复制的锚点链接。
- 涉及：`src/components/Toc.astro`、文章页
- 验收：滚动时高亮跟着变；点击目录项跳到对应标题；只用键盘能操作。

**M2-5 同期率**

- 做什么：`SyncRate.astro`，顶部进度线加右下角读数。
- 涉及：`src/components/SyncRate.astro`
- 验收：进度线与读数同步变化；读到末尾时由紫转绿；系统开启「减少动态效果」时不报错。

**M2-6 次回予告**

- 做什么：`NextEpisode.astro`，文章末尾的「下一篇」卡片。
- 规则（我的建议，你可以改）：显示话数比当前大 1 的那一篇；不存在时整块不渲染。
- 涉及：`src/components/NextEpisode.astro`
- 验收：中间一篇文章显示正确的卡片；最新的一篇不显示。

**M2-7 标签页**

- 做什么：路由 `/tags/[tag]`，复用 `EpisodeList`。
- 涉及：`src/pages/tags/[tag].astro`
- 验收：只列出带该标签的文章；没有文章的标签不生成页面。

**M2-8 ⚠ 图片资源**

- 做什么：在文章目录里用相对路径引用图片，并写上说明文字和替代文本。
- 验收：生产构建后图片路径带哈希；说明文字显示在图下方。
- 验证后要回写的事：图片是否真的走了 Astro 的资源管线。对应待验证清单的第 5 项。

**M2-9 内嵌 Vue 组件**

- 做什么：启用 `@astrojs/vue`；写 `src/components/vue/SyncDemo.vue`；在一篇 `.mdx` 里用 `client:visible` 引入。
- 涉及：`astro.config.mjs`、`src/components/vue/SyncDemo.vue`
- 验收：不含组件的页面不加载 Vue；组件滚进视口后才能交互。

**M2-10 全元素样例文章**

- 做什么：把视觉稿 Markdown 页的十类内容各写一遍，放进同一篇文章。
- 验收：逐项对照视觉稿；浏览器控制台没有报错。这篇文章留作以后改样式时的回归样本。

### M3 图表、搜索、评论

**M3-1 ⚠ Mermaid 图表**

- 做什么：按 ARCHITECTURE.md 的 2.4 节配置 astro-mermaid，主题变量取视觉稿 Markdown 页 06 区表里的值。给图表面板预留最小高度。
- 涉及：`astro.config.mjs`、`src/styles/markdown.css`
- 验收：流程图和时序图渲染正确；昼、夜两种主题下都读得清；没有图表的页面不加载 mermaid 脚本。
- 验证后要回写的事：主题变量的实际效果。对应待验证清单的第 3 项。

**M3-2 ⚠ 站内搜索**

- 做什么：构建脚本改成 `"build": "astro build && pagefind --site dist"`；给导航、目录、页脚加 `data-pagefind-ignore`；写 `SearchDialog.astro`，支持 ⌘K 打开、方向键选择、Esc 关闭。
- 涉及：`package.json`、`src/components/SearchDialog.astro`、`BaseLayout.astro`
- 验收：用中文关键词能搜到对应文章；`<html>` 带 `lang` 属性；配上 `base` 之后索引仍然能加载。
- 验证后要回写的事：中文搜索的实际效果。对应待验证清单的第 7 项。

**M3-3 评论**

- 做什么：`Comments.astro` 接入 Giscus。iframe 设为懒加载。评论区的主题跟随昼/夜，做法按 Giscus 文档，切换时给 iframe 发消息。
- 涉及：`src/components/Comments.astro`
- 前置条件：有一个公开仓库，开启了 Discussions，并安装了 giscus app。
- 验收：评论区能加载；切换昼/夜时评论区跟着变。

### M4 RSS、404 与上线

**M4-1 RSS、Sitemap、robots.txt**

- 做什么：`rss.xml.js`（排除草稿）；确认 Sitemap 已启用；在 `public/` 里放 `robots.txt`。
- 涉及：`src/pages/rss.xml.js`、`public/robots.txt`
- 验收：构建后 `dist/rss.xml` 与 `dist/sitemap-index.xml` 都存在，里面的链接带有 `base` 前缀。

**M4-2 404 页**

- 做什么：EMERGENCY 风格的 404 页，样式参照视觉稿元素库的第 10 号。
- 涉及：`src/pages/404.astro`
- 验收：构建产物里有 `404.html`；`pnpm preview` 时访问一个不存在的路径，看到的是这一页。

**M4-3 ⚠ 部署上线**

- 做什么：加 ARCHITECTURE.md 2.6 节里的部署工作流；在 `astro.config.mjs` 里填好 `site` 与 `base`；在仓库的 Settings → Pages 里把 Source 选为 GitHub Actions；推送到 `main`。
- 涉及：`.github/workflows/deploy.yml`、`astro.config.mjs`
- 验收：Actions 全绿；Pages 地址上每个页面都能打开。
- 验证后要回写的事：`base` 子路径下图表、评论、RSS、Sitemap、Pagefind 的路径是否都正确。对应待验证清单的第 6 项。

**M4-4 上线后自测**

逐项确认：

- 首页、文章页、标签页、404 都能打开
- 切换昼/夜正常，刷新不闪
- 公式、代码块、图表显示正确
- 搜索能用中文搜到文章
- 评论区能加载
- `/rss.xml` 与 `/sitemap-index.xml` 能访问
- 在你常用的网络下，打开速度可以接受

**M4-5 项目子 skill**

- 做什么：用 newproj 技能生成本项目的子 skill，登记项目命令和文档路径。
- 验收：新会话里说一句与博客相关的话，子 skill 能被触发。
- 备注：这是为了以后让 Agent 接手时能自动读到这些约定，不影响站点本身。
