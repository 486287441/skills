# HTML Mode · 版式与写入规则

> 通用 Kami 阅读页。**不是** PRD 选题页；禁止套用 `rough-idea-to-plan` 的一/二/三章节、表单、`choices.json`、`html-submit-snippet`。

## 视觉（硬性）

**必须**遵循 `~/.cursor/skills/doc-kami-parchment/doc-kami-parchment/SKILL.md`：

- 羊皮纸 `#f5f4ed`、墨蓝 accent `#1B365D`、衬线字体、无渐变/大圆角/重阴影
- 单文件 HTML；占位图用色块 + hairline，勿外链图片

## 版式骨架（必做，避免「全挤在左边」）

生成前先读：`~/.cursor/skills/doc-kami-parchment/doc-kami-parchment/example.html`

1. 正文包在 `<div class="page">`（或 `max-width:920px; margin:0 auto; padding:3.5rem 2.5rem`）内  
   **不要**只给 `body` 设窄 `max-width`。
2. 结构：**顶栏 folio（三列 meta）· 标题 · lede · 章节/表格/列表 · 底栏 colophon**
3. **禁止**引入 `<script src="https://cdn.tailwindcss.com">` 却不用 Tailwind 类名——preflight 会冲掉居中，整页贴左。  
   - **推荐**：纯 CSS + `.page`  
   - 若用 Tailwind：须像 `example.html` 一样 `max-w-[920px] mx-auto` 等完整 utility
4. 章节标题用中文序号或语义 `<h2>`（如 **一、** **二、**），**不要**用 `§` 符号

## 禁止（本 skill）

- PRD 选题表单、「保存到项目」、`POST /api/save-choices`、`choices.json`
- 页内实时 JSON 预览、`<pre id="live-summary">`
- 把本页当成 `rough-idea-to-plan` 阶段 1 产出

## 写入路径

| 用途 | 路径 |
|------|------|
| 当前预览（覆盖） | `{workspaceRoot}/对话 html/index.html` |
| 可选归档 | `{workspaceRoot}/对话 html/YYYY-MM-DD-HHmm.html` |

新建 `对话 html/` 且仓库有 `.gitignore` → 追加：`对话 html/`

## 代码与表格

- 代码块：HTML 内 `<pre><code>`，Kami 排版
- 宽表、对比表、多列布局：放在 HTML，不在聊天里用 Markdown 大表替代
