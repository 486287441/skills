# HTML Mode · 版式与写入规则

> 通用 Kami 阅读页。**不是** PRD 选题页；禁止套用 `rough-idea-to-plan` 的一/二/三章节、表单、`choices.json`、`html-submit-snippet`。

## 视觉（硬性）

**必须**遵循 `~/.cursor/skills/doc-kami-parchment/doc-kami-parchment/SKILL.md`：

- 羊皮纸 `#f5f4ed`、墨蓝 accent `#1B365D`、衬线字体、无渐变/大圆角/重阴影
- 单文件 HTML；插图优先 **内联 SVG**（单色 `#1B365D` / `#6b665b`），勿外链图片
- 交互态可用 `#efeee5` 底、`1px #d4d1c5` hairline；圆角 ≤ 6px

## 两大内容原则（必达）

### 1. 丰富度 — 让页面「值得点开预览」

除 folio / 标题 / lede 外，**每篇答复**应尽量包含 **≥3 类** 下列元素（按主题选用，勿堆砌无关装饰）：

| 类型 | 要求 |
|------|------|
| **表格** | 对比表、参数表、术语对照、前后差异；表头用墨蓝或 meta 小字 |
| **版式 CSS** | 双栏/三栏、pull quote、编号列表、标签 `.tag`、章节 rule、高亮数字 |
| **SVG** | 示意图、流程、环/树/时间轴；仅用墨蓝 + 灰线，无渐变 |
| **静态图解** | 用 CSS + SVG 画架构/数据流，配简短 caption |
| **折叠/选项卡** | `<details>` 或轻量 JS 切换，藏深度内容 |
| **代码** | `<pre><code>` 关键片段，配「复制」可选 |

**禁止**：聊天里用 Markdown 大表代替 HTML；禁止整页只有三段纯文字。

### 2. 双向互动 — 读者操作，页面即时反馈

**每篇答复**应至少包含 **1 个**「概念讲解器」级 widget（见下），或 **2 个** 较轻互动（滑块 + 实时数字、可勾选对比行、可排序列表等）。

互动须满足：

- **输入 → 输出**：拖/点/输入后，**同屏**更新数字、图、表或说明（不跳转）
- **可发现**：按钮/环/节点有 hover、`cursor: pointer`、`:focus-visible` 描边
- **Kami 一致**：控件像纸面教具，不像 SaaS dashboard（无霓虹、无大阴影）
- **单文件**：`<script>` 内联在 `index.html` 末尾；不依赖 React/Vue CDN
- **降级**：无 JS 时仍可读核心文字与静态表

#### 概念讲解器（Concept Explainer）— 推荐结构

用于技术概念、算法、架构对比。**参考实现**：`example-interactive.html` 中的一致性哈希卡片。

```
┌─ .concept-explainer ─────────────────────────────────────┐
│ 标题 + 一句 lede                                          │
├──────────────────┬───────────────────────────────────────┤
│ .explainer-viz   │ .explainer-metrics                    │
│ 可交互主视图      │ 实时指标（大数字 + 短解释）              │
│ (SVG 环/图/轴)   │                                       │
├──────────────────┴───────────────────────────────────────┤
│ .explainer-controls — 添加/移除/重置/预设场景按钮          │
├──────────────────────────────────────────────────────────┤
│ 对比表（方案 A vs B）                                       │
├──────────────────────────────────────────────────────────┤
│ 术语表（`<dl>` 或两列表）                                  │
└──────────────────────────────────────────────────────────┘
```

| 区块 | 职责 |
|------|------|
| **viz** | 主交互区：环上增删节点、拖拽参数、点击高亮路径等 |
| **metrics** | 派生量实时刷新，如「迁移 key 数 / 比例」「命中节点」 |
| **controls** | 明确动作：添加节点、移除、随机 key、重置 |
| **对比表** | 与普通哈希、轮询等并列 |
| **术语表** | vnode、replica、jump hash 等 |

#### 其他常见互动模式

| 模式 | 适用 | 互动要点 |
|------|------|----------|
| 参数滑块 + 曲线 | 复杂度、容量规划 | 滑块改 N，SVG 折线/柱更新 |
| 分步揭示 | 流程、协议握手 | 下一步高亮当前步， dim 其余 |
| 可勾选矩阵 | 特性对比 | 勾选过滤表格行 |
| 迷你计算器 | 公式、单位换算 | 输入框 `input` 事件更新结果区 |
| 测验卡片 | 学习巩固 | 选答案后显示解析（`details` 或切换 class） |

## 版式骨架（必做，避免「全挤在左边」）

生成前先读：

1. `~/.cursor/skills/doc-kami-parchment/doc-kami-parchment/example.html` — 居中、folio、三栏
2. `~/.cursor/skills/html-mode-skill/example-interactive.html` — 丰富度 + 概念讲解器

1. 正文包在 `<div class="page">`（或 `max-width:920px; margin:0 auto; padding:3.5rem 2.5rem`）内  
   **不要**只给 `body` 设窄 `max-width`。
2. 结构：**顶栏 folio · 标题 · lede · 章节（含 widget）· 表/术语 · colophon**
3. **禁止**引入 `<script src="https://cdn.tailwindcss.com">` 却不用 Tailwind 类名——preflight 会冲掉居中。  
   - **推荐**：纯 CSS + `.page`（互动页常用）  
   - 若用 Tailwind：须 `max-w-[920px] mx-auto` 等完整 utility
4. 章节标题用中文序号或语义 `<h2>`（如 **一、** **二、**），**不要**用 `§` 符号

## 文档形态

| 类型 | 骨架 | 丰富度 / 互动下限 |
|------|------|-------------------|
| 短答 | folio + 标题 + lede + 1–2 小节 + colophon | ≥1 表或 SVG；≥1 轻互动或 `<details>` |
| 长答 | 多 section + 表/列表 + colophon | ≥3 类丰富元素；≥1 概念讲解器或 2 个轻互动 |
| 学习/研究 | 分节 + **每节至少 1 widget** + 术语表 | 讲解器 + 对比表为默认配置 |

## 禁止（本 skill）

- PRD 选题表单、「保存到项目」、`POST /api/save-choices`、`choices.json`
- 页内实时 JSON 预览、`<pre id="live-summary">`
- 把本页当成 `rough-idea-to-plan` 阶段 1 产出
- 多色图表、渐变按钮、圆角 > 8px、外链图床
- 仅有文字、无任何表/图/互动的「幻灯片式空页」

## 写入路径

| 用途 | 路径 |
|------|------|
| 当前预览（覆盖） | `{workspaceRoot}/对话 html/index.html` |
| 可选归档 | `{workspaceRoot}/对话 html/YYYY-MM-DD-HHmm.html` |

新建 `对话 html/` 且仓库有 `.gitignore` → 追加：`对话 html/`

## 预览（Agent）

- Windows：**必须**运行 `kami-preview-3001.ps1 -HtmlDirectory (Join-Path "<工作区根>" "对话 html")`（见 SKILL.md）
- 成功标志：`对话 html/.preview-status.json` 含 `"ok": true`
- 日志：`对话 html/.preview.log`
- 勿用 `file://`；勿在未验证 HTTP 200 时只发 localhost 链接

## 实现提示（互动脚本）

- 用 `requestAnimationFrame` 或同步 DOM 更新即可，避免重依赖
- SVG 节点用 `circle` + `data-id`；点击命中用 `elementFromPoint` 或按钮驱动增删
- 指标区用 `[data-metric="migrated"]` 等属性，便于一次 `textContent` 刷新
- 对比表、术语表 **始终静态 HTML**，不依赖 JS 才可见
