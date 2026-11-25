# 博客架构设计（V1）

> 状态：**待你审核**。
> 版本号均为 2026-11-25 在 npm 与官方文档查询的结果。
> 文中的代码片段按官方文档和各包 README 编写，**尚未在真实项目里实跑**；带 ⚠ 的条目要在对应里程碑先验证，汇总见第 5 节。
> 视觉样式的唯一事实源是 [design/mockup.html](design/mockup.html)，本文不重复抄写色值和样式。
> 配套文档：[背景说明](docs/BACKGROUND.md)（项目来龙去脉与规则）、[实现计划](docs/PLAN.md)（任务拆解与状态登记）。

## 1. 是什么

个人技术博客。V1 是纯静态站点：文章是仓库里的 Markdown，推送到 `main` 后由 GitHub Actions 构建并发布到 GitHub Pages。

**V1 范围**

- 页面：首页（标题卡、话数列表、标签筛选）、文章页（右侧目录、同期率进度、次回予告）、标签页、关于页、404
- Markdown 全部内容的渲染：排版、列表、提示框、代码块、LaTeX 公式、Mermaid 图表、表格、脚注、图片、内嵌 Vue 组件
- 站内搜索、评论、RSS、Sitemap、昼/夜主题切换

**V1 不做**：阅读量、登录、数据库、自建后端。

## 2. 怎么做

### 2.1 技术栈

| 关注点 | 选型 | 版本 | 说明 |
|---|---|---|---|
| 框架 | `astro` | 7.4.13 | 要求 Node ≥ 22.23.4 |
| UI 组件 | `@astrojs/vue` + `vue` | 7.1.6 / ^3.5.24 | 文章里内嵌交互组件 |
| MDX | `@astrojs/mdx` | 8.1.6 | 需要内嵌组件的文章用 `.mdx` |
| Markdown 处理器 | `@astrojs/markdown-remark` | 7.3.10 | Unified 处理器，官方说明需另装 |
| 公式 | `remark-math` + `rehype-katex` | 6.0.0 / 7.0.1 | 渲染引擎 KaTeX 0.19.1 |
| 代码块 | `astro-expressive-code` | 0.44.4 | 行号、文件名栏、复制按钮、增删标记、折叠段、代码页签 |
| 图表 | `astro-mermaid` + `mermaid` | 2.2.0 / 12.3.0 | 浏览器端按需渲染 |
| 提示框 | `rehype-github-alerts` | 4.2.0 | NOTE、TIP、IMPORTANT、WARNING、CAUTION |
| 上下标 | `remark-sub-super` | 1.0.21 | 可选 |
| 搜索 | `pagefind` | 1.6.0 | 构建后给 `dist` 建索引 |
| RSS 与 Sitemap | `@astrojs/rss`、`@astrojs/sitemap` | 4.0.19 / 3.7.6 | 官方博客模板自带 |
| 包管理 | `pnpm` | 10.9.0 | 本机已装 |
| 样式方案 | 纯 CSS 变量，不用 Tailwind | — | 见第 3 节最后一条 |

### 2.2 目录结构

```text
blog/
├── ARCHITECTURE.md
├── astro.config.mjs
├── package.json
├── tsconfig.json
├── design/
│   └── mockup.html              # 视觉稿，样式参照，不进构建
├── public/                      # 原样拷贝的静态文件
├── .github/workflows/deploy.yml
└── src/
    ├── content.config.ts        # 内容集合定义与 frontmatter 校验，唯一的内容入口
    ├── content/blog/            # 文章：每篇一个目录，图片与正文放在一起
    │   └── 010-dark-mode/index.md
    ├── styles/
    │   ├── global.css           # Design Token（昼/夜两套 CSS 变量）与基础样式
    │   └── markdown.css         # 文章正文里由 Markdown 生成的 HTML 的样式
    ├── layouts/
    │   └── BaseLayout.astro     # <head>、防闪烁内联脚本、导航、页脚状态栏
    ├── components/
    │   ├── TitleCard.astro      # 标题卡：首页 Hero 与文章页头共用
    │   ├── EpisodeList.astro    # 话数列表：首页、标签页共用
    │   ├── Toc.astro            # 目标索引（右侧目录）
    │   ├── SyncRate.astro       # 同期率（阅读进度）
    │   ├── NextEpisode.astro    # 次回予告
    │   ├── Comments.astro       # 评论：V1 封装 Giscus
    │   ├── SearchDialog.astro   # 目标搜索（Pagefind 界面）
    │   ├── ThemeToggle.astro
    │   └── vue/                 # 文章里内嵌的 Vue 组件
    │       └── SyncDemo.vue
    ├── lib/
    │   └── format.ts            # 纯函数：日期格式化、话数补零
    └── pages/
        ├── index.astro
        ├── about.astro
        ├── 404.astro
        ├── rss.xml.js
        ├── blog/
        │   ├── index.astro      # 全部话数（分页）
        │   └── [slug].astro     # 文章页
        └── tags/[tag].astro
```

没有 Service/Adapter 层（理由见第 3 节）。V2 接后端时的改动点只有三处：`Comments.astro`、各页面对 `getCollection('blog')` 的调用、新增一个阅读量组件。

### 2.3 Frontmatter 规范

```ts
// src/content.config.ts
import { defineCollection } from 'astro:content';
import { glob } from 'astro/loaders';
import { z } from 'astro/zod';

const blog = defineCollection({
  loader: glob({ base: './src/content/blog', pattern: '**/*.{md,mdx}' }),
  schema: ({ image }) =>
    z.object({
      title: z.string(),
      description: z.string(),
      pubDate: z.coerce.date(),
      updatedDate: z.coerce.date().optional(),
      heroImage: z.optional(image()),
      episode: z.number().int().positive(),
      tags: z.array(z.string()).default([]),
      draft: z.boolean().default(false),
    }),
});

export const collections = { blog };
```

前五个字段来自官方博客模板，后三个是本站新增。类型由 schema 推导，不另写一份：

```ts
import type { CollectionEntry } from 'astro:content';
export type PostFrontmatter = CollectionEntry<'blog'>['data'];
```

| 字段 | 必填 | 用途 |
|---|---|---|
| `title` | 是 | 标题卡上的大标题 |
| `description` | 是 | 列表摘要、页面描述、RSS 摘要 |
| `pubDate` | 是 | 发布日期，列表按它倒序 |
| `updatedDate` | 否 | 更新日期，有值时在文章头显示 |
| `heroImage` | 否 | 题图，走 Astro 图片资源管线 ⚠ |
| `episode` | 是 | 话数，手动递增，显示为 `EP.010` 与 `第 10 話` |
| `tags` | 否 | 标签，默认空数组 |
| `draft` | 否 | 草稿，默认 `false` |

示例：

```yaml
---
title: "暗色模式不闪烁：一段内联脚本"
description: "一段内联脚本，解决深色模式的首屏闪白。"
pubDate: 2026-11-08
updatedDate: 2026-11-10
episode: 10
tags: ["Astro", "CSS"]
draft: false
heroImage: "./cover.jpg"
---
```

约定：

- 目录名就是 slug，例如 `src/content/blog/010-dark-mode/` 对应 `/blog/010-dark-mode/`。
- `draft: true` 的文章不进列表、标签页和 RSS，`pnpm dev` 时可以预览。写法是在查询处按 `import.meta.env.PROD` 过滤。
- 需要内嵌 Vue 组件时，把扩展名改成 `.mdx`，其余写法不变。

### 2.4 Markdown 渲染管线

```js
// astro.config.mjs   ⚠ 待 M2 实跑验证
import { defineConfig } from 'astro/config';
import mdx from '@astrojs/mdx';
import vue from '@astrojs/vue';
import sitemap from '@astrojs/sitemap';
import expressiveCode from 'astro-expressive-code';
import mermaid from 'astro-mermaid';
import { unified } from '@astrojs/markdown-remark';
import remarkMath from 'remark-math';
import rehypeKatex from 'rehype-katex';
import rehypeGithubAlerts from 'rehype-github-alerts';

export default defineConfig({
  site: 'https://<GitHub 用户名>.github.io',
  base: '/<仓库名>',            // 仓库本身就叫 <用户名>.github.io 时，删掉这一行
  integrations: [
    mermaid({                    // 该包文档要求它排在其他处理 Markdown 的集成之前
      theme: 'base',
      autoTheme: false,          // 原因见第 3 节
      mermaidConfig: {
        themeVariables: { /* 取值见视觉稿 06 区的表 */ },
      },
    }),
    expressiveCode(),
    mdx(),
    vue(),
    sitemap(),
  ],
  markdown: {
    processor: unified({
      remarkPlugins: [remarkMath],
      rehypePlugins: [rehypeKatex, rehypeGithubAlerts],
    }),
  },
});
```

另外两处配置：

- `BaseLayout.astro` 里引入 `katex/dist/katex.min.css`，公式依赖它自带的字体。
- `package.json` 的构建脚本改成 `"build": "astro build && pagefind --site dist"`，这样 Pagefind 的索引会在上传前生成。

**深浅色的三套规则**

| 对象 | 是否跟随昼/夜 | 怎么对齐 |
|---|---|---|
| 站点 | 跟随 | `<head>` 里的内联脚本在首次绘制前写入 `html[data-theme="day" 或 "night"]` |
| 代码块 | 恒为深色 | Expressive Code 只配一个深色语法主题 |
| 图表 | 恒为深色 | `autoTheme` 关闭，面板底色写死 |

**每类内容靠什么渲染**

| 内容 | 写法 | 靠什么 |
|---|---|---|
| 公式 | `$…$`、`$$…$$` | `remark-math` + `rehype-katex` |
| 图表 | 语言标为 `mermaid` 的代码块 | `astro-mermaid` |
| 提示框 | 引用块首行写 `> [!NOTE]` | `rehype-github-alerts` |
| 上下标 | `H~2~O`、`X^2^` | `remark-sub-super` |
| 高亮 | 直接写 `<mark>文字</mark>` | Markdown 里允许原生 HTML |
| 表格、任务列表、脚注、删除线 | GFM 语法 | 处理器默认开启 GFM |
| 内嵌交互组件 | 在 `.mdx` 里写 Vue 组件 | `@astrojs/mdx` + `@astrojs/vue` |
| 行号、复制按钮、增删标记 | 代码块元信息 | `astro-expressive-code` |

### 2.5 视觉稿到实现的对应

样式搬法：视觉稿 `<style>` 里的 Token 段搬进 `global.css`；`.post-body` 开头的规则搬进 `markdown.css`；其余按组件拆进各自的 `<style>`。

| 视觉稿里的元素 | 落点 | 需要浏览器脚本吗 |
|---|---|---|
| 标题卡 | `TitleCard.astro` | 否 |
| 话数列表 | `EpisodeList.astro` | 否 |
| 标签筛选 | `EpisodeList.astro` | 是，少量 |
| 索敌框、警示条、提示框 | 纯 CSS | 否 |
| 次回予告 | `NextEpisode.astro` | 否 |
| 同期率 | `SyncRate.astro` | 是，监听滚动 |
| 目标搜索 | `SearchDialog.astro` | 是，打开时才加载 Pagefind |
| 评论 | `Comments.astro` | iframe，设为懒加载 |
| 图表 | `astro-mermaid` 自动处理 | 页面里有图表才加载 |
| 内嵌组件 | `vue/*.vue` | 用 `client:visible` 控制 |

### 2.6 里程碑与验收标准

每个里程碑收尾时，下面两条门禁必须实跑通过：

```sh
pnpm build        # 退出码 0
pnpm astro check  # 退出码 0；需先另装 @astrojs/check，官方博客模板没有自带
```

**M0 项目初始化**

- 做什么：`pnpm create astro@latest -- --template blog`，装 2.1 节的依赖，`git init`。目录里已有 `design/` 和本文档，脚手架遇到非空目录会询问，选继续。
- 验收：`pnpm dev` 能打开首页和示例文章；`pnpm build` 退出码 0。

**M1 设计令牌与骨架**

- 做什么：`global.css` 放入昼/夜两套 Token；`BaseLayout.astro`（防闪烁内联脚本、导航、页脚状态栏、主题切换）；首页的标题卡与话数列表。
- 验收：刷新页面时主题不闪；切换昼/夜，标题卡翻面；375px 宽度下没有横向滚动条；键盘 Tab 能走完全部导航项。

**M2 文章页与 Markdown 管线**

- 做什么：文章页（标题卡头、右侧目录、同期率、次回予告）；按 2.4 节配好渲染管线；写一篇「全元素样例文章」，把视觉稿 Markdown 页的十类内容各写一遍。
- 验收：样例文章的每一类元素都正确渲染，逐项对照视觉稿；浏览器控制台没有报错；`pnpm build` 退出码 0；公式、代码块、图表、提示框四项各有一个能跑通的最小例子。

**M3 图表、搜索、评论**

- 做什么：Mermaid 配色调到与视觉稿一致；Pagefind 搜索框；`Comments.astro` 接入 Giscus。
- 验收：流程图和时序图在昼、夜两种主题下都可读；用中文关键词能搜到对应文章；评论区能加载并显示（需要 GitHub 可达）。

**M4 RSS、404 与上线**

- 做什么：`rss.xml.js`、Sitemap、`robots.txt`、EMERGENCY 风格的 404；填好 `site` 与 `base`；加部署工作流；在仓库 Settings → Pages 里把 Source 选为 GitHub Actions。
- 验收：推送到 `main` 后 Actions 全绿；Pages 地址能打开；`/rss.xml` 与 `/sitemap-index.xml` 能访问且其中的链接带有 `base` 前缀；随便访问一个不存在的地址能看到 404 页。

部署工作流来自 Astro 官方文档，pnpm 会按锁文件自动识别：

```yaml
name: Deploy to GitHub Pages
on:
  push:
    branches: [main]
  workflow_dispatch:
permissions:
  contents: read
  pages: write
  id-token: write
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - uses: withastro/action@v6
  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - id: deployment
        uses: actions/deploy-pages@v5
```

## 3. 为什么（决策记录）

| 决策 | 结论 | 理由 |
|---|---|---|
| 写作方式 | 本地写 Markdown，提交 Git | 免费、零运维、无数据库，内容是纯文本 |
| 部署 | GitHub Pages + GitHub Actions | 你定的 V1 目标 |
| 框架 | Astro + Vue | 与你「V2 接独立后端」的方向一致；默认零客户端 JS；官方博客模板起步最快 |
| V2 预留 | 只留组件边界，不建接口层 | 与 devbase §1.4「拒绝预判式抽象」一致；V2 后端的接口形态未知，预设抽象大概率猜错 |
| 视觉 | EVA 标题卡为主，控制台元素点缀 | 你已认可风格 |
| 阅读量 | V1 不做 | 没有后端就没有真实数据，不做 Mock 占位 |
| Markdown 处理器 | Unified，不用 Astro 7 默认的 Sätteri | 官方文档写明 remark/rehype 插件不能直接用于 Sätteri；公式、提示框、上下标都来自这个生态 |
| 代码块 | `astro-expressive-code` | 一个插件覆盖行号、文件名栏、复制按钮、标记、折叠、页签，不必自己造 |
| 图表渲染时机 | 浏览器端按需渲染 | 构建期方案要在 CI 里装无头浏览器；按需渲染让没有图表的页面零成本 |
| 图表配色 | 关闭 `autoTheme`，面板恒为深色 | 该包文档写明 `autoTheme` 只在 Mermaid 内置的两套主题间切换，用不了自定义配色；面板恒深色后一套配色就够 |
| 公式 | 构建期渲染（KaTeX） | 页面不需要加载公式脚本 |
| 评论 | Giscus，封装在 `Comments.astro` | 免后端，数据存在仓库的 Discussions 里 |
| Tailwind | 不引入 | 见下 |

关于 Tailwind：你之前那份提示词里写过 Tailwind，现在定为不引入，理由有两条。一是视觉稿的样式全部用 CSS 变量写成，可以直接搬进 `.astro` 的 `<style>`。二是 Markdown 生成的 HTML 没有组件作用域，只能靠全局选择器写样式，这部分本来就用不上 Tailwind。以后如果想要原子类，随时可以加，两者不冲突。

## 4. 风险点

| 风险 | 影响 | 应对 |
|---|---|---|
| Astro 7 的 Markdown 处理器正在换代，插件兼容性参差 | M2 可能卡住 | M2 第一步先做一个「公式 + 代码块 + 提示框」的最小管线，跑通再往下做 |
| 图表在浏览器端渲染 | 首次加载有延迟，可能出现布局抖动 | 给图表面板预留最小高度；该包自称带加载占位与防抖动，⚠ 需实测 |
| Giscus 依赖 GitHub 可达 | 部分读者看不到评论区 | 评论区做成可选加载，不影响正文阅读 |
| GitHub Pages 在国内访问速度不稳定 | 读者打开慢 | 上线后在你自己的网络实测；不理想再考虑绑定域名或换托管 |
| EVA 是他人的作品 | 版权与商标风险 | 只用配色和警示条、HUD 括角这类通用母题；不用 NERV 标志、EVA 标题字标、角色图像和截图；不使用商业字体 Matisse EB，标题用开源的思源宋体 Black |

## 5. 待验证清单

以下几项我只查到了文档，没有在真实项目里跑过：

1. ⚠ `markdown.processor = unified({ remarkPlugins, rehypePlugins })` 在 Astro 7.4 上的实际输出。官方文档给出了这种写法，但网上的公式教程用的都是旧配置项名。
2. ⚠ `astro-expressive-code` 0.44.4 在 Astro 7 的 Unified 处理器下是否正常工作，以及它与 `@astrojs/mdx` 的注册顺序。官方安装页没有写兼容性说明。
3. ⚠ `astro-mermaid` 关闭 `autoTheme` 后，`theme: 'base'` 加 `themeVariables` 的实际效果，以及各变量名是否与 Mermaid 12.3 一致。
4. ⚠ KaTeX 遇到写错的公式时的输出，决定失败态怎么写样式。
5. ⚠ Markdown 里相对路径引用的图片是否走 Astro 的资源管线。
6. ⚠ GitHub Pages 的 `base` 子路径下，图表、评论、RSS、Sitemap、Pagefind 的路径是否都正确。
7. ⚠ Pagefind 对中文的实际搜索效果。官方文档确认了两点：中文分词只在 extended 构建里支持，而 `npx pagefind` 默认装的就是它；页面需要带 `lang` 属性，不需要额外配置。

## 6. 来源

- Astro：[安装](https://docs.astro.build/en/install-and-setup/)、[Markdown 内容与处理器](https://docs.astro.build/en/guides/markdown-content/)、[GitHub Pages 部署](https://docs.astro.build/en/guides/deploy/github/)、[官方博客模板](https://github.com/withastro/astro/tree/main/examples/blog)
- [astro-mermaid README](https://github.com/joesaby/astro-mermaid)
- Expressive Code：[功能](https://expressive-code.com/)、[配置项](https://expressive-code.com/reference/configuration/)、[安装](https://expressive-code.com/installation/)
- Pagefind：[多语言](https://pagefind.app/docs/multilingual)、[更新日志](https://github.com/CloudCannon/pagefind/blob/main/CHANGELOG.md)
