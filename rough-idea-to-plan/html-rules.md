# HTML 规则

> 阶段 1 产出的是 **PRD 选题页**，不是技术评审表。选题口径见 [html-questions-guide.md](html-questions-guide.md)。

1. **必须**遵循 skill `doc-kami-parchment`（`~/.cursor/skills/doc-kami-parchment/doc-kami-parchment/SKILL.md`）。
2. **版式骨架（必做，避免「全挤在左边」）**：
   - 生成前先读 `~/.cursor/skills/doc-kami-parchment/example.html` 或 `layout-shell.html`。
   - 正文包在 `<div class="page">`（或 `max-width:920px; margin:0 auto; padding:3.5rem 2.5rem`）内，**不要**只给 `body` 设窄 `max-width`。
   - 顶栏 folio（三列 meta）、标题、lede、章节/表格、底栏 colophon。
   - **禁止**引入 `<script src="https://cdn.tailwindcss.com">` 却不用 Tailwind 类名——Tailwind preflight 会冲掉 `body { margin:auto }`，导致整页贴左。要么纯 CSS（推荐），要么像 example 一样用 `max-w-[920px] mx-auto` 等完整 utility。
3. **章节标题（必做，禁止 § 符号）**：
   - 三大块用中文序号：**一、已定** · **二、待你拍板** · **三、提交给 Agent**。
   - 写法示例：`<h2><span class="section-num">一、</span>已定（…）</h2>`，序号与标题同一行、衬线字号，**不要**用 `§`、`§ A/B/C`、西文 `kicker` 小节标。
   - DOM `id` 可保留 `section-a` / `section-b` / `submit-panel`（仅给脚本用，页面上不显示 §）。
4. **选题内容（产品经理口吻）**：
   - **二、待拍板**只问：用户目标、场景、体验、范围、完成标准等（见 html-questions-guide）。
   - **每题**除预设单选外，必须提供 **「其他（自己填写）」** 及文本框（实现见 html-submit-snippet）。
   - **禁止**在 HTML 中出现：技术栈、构建工具、框架、部署平台、存储方案、PWA/API 等实现级选项。
   - lede 须点明：这是在定 **产品需求（PRD）**；技术路线在后续 `plan/技术方案.md` 再定。
5. **禁止在页面上展示 JSON 预览**：
   - **不要**嵌入 `<pre id="live-summary">` 或任何实时 `JSON.stringify(choices)` 区块。
   - 选项仅通过表单控件表达；提交结果只写在 `choices.json`（保存成功用 `#status-banner` 提示路径）。
   - `updateUI()` 只更新进度条与按钮状态，不向页面输出 payload 原文。
6. 写入路径（覆盖）：
   `{workspaceRoot}/对话 html/index.html`
7. 可选归档（不覆盖 index）：
   `{workspaceRoot}/对话 html/YYYY-MM-DD-HHmm.html`
8. 若新建 `对话 html/` 且仓库有 `.gitignore`，追加一行：`对话 html/`（避免误提交预览文件）。

## 交互与提交（必做）

生成 HTML 时**必须**按 [html-submit-snippet.md](html-submit-snippet.md) 嵌入：

- 主按钮 **「保存到项目」** → `POST /api/save-choices`
- 备用 **「复制 JSON」**（无 `kami-serve.py` 时）
- **不要**以「下载文件再手动覆盖」作为主流程

`choices.json` 字段：`version`、`updatedAt`、`submitted`、`choices`（题号 → 选项值；自定义题为 `__custom__` + `{id}_custom` 用户文字，见 html-questions-guide）。

## 预览服务（每次写完 HTML 后）

在**工作区根目录****前台**启动预览（脚本会等到 `127.0.0.1:3000` 可连再退出；**勿** `block_until_ms: 0` / 命令末尾 `&`；**勿**在就绪前用 Browser MCP 打开 3000）。启动器由 skill **`rough-idea-to-plan`** 自带：

1. **若** `~/.cursor/scripts/` 缺少启动器 → 从 `~/.cursor/skills/rough-idea-to-plan/scripts/` **复制**（一次性，勿 AI 现场写脚本）：
   - `kami-serve.py`（**必须**，提供保存 API）
   - `kami-serve.ps1`（Windows）
   - `kami-serve.sh`（macOS / Linux / Git Bash，`chmod +x`）
2. **再执行**（Windows 用 `.ps1`，其它用 `.sh`）指向 `{workspaceRoot}/对话 html`。

`kami-serve.py` 在 **3000** 端口提供静态页，并处理 `POST /api/save-choices` → 写入同目录 `choices.json`。无 `kami-serve.py` 时回退 `python -m http.server`（此时仅能用复制 JSON）。释放 **3000** 后启动。勿与 `html-anything` 的 `pnpm dev` 同时占 3000。

**Windows（工作区根目录）：**

```powershell
$htmlDir = Join-Path (Get-Location) "对话 html"
$kami = Join-Path $env:USERPROFILE ".cursor\skills\rough-idea-to-plan\scripts\kami-serve.ps1"
if (-not (Test-Path $kami)) { $kami = Join-Path $env:USERPROFILE ".cursor\scripts\kami-serve.ps1" }
& $kami -Directory $htmlDir
```

**macOS / Linux / Git Bash：**

```bash
KAMI="$HOME/.cursor/skills/rough-idea-to-plan/scripts/kami-serve.sh"
[ -x "$KAMI" ] || KAMI="$HOME/.cursor/scripts/kami-serve.sh"
"$KAMI" "$(pwd)/对话 html"
```

## 聊天回复格式

1. **3–8 句**中文摘要（要点即可）。
2. 附预览链接：**http://localhost:3000**（强调勿用 `file://`）
3. 附路径：`对话 html/index.html` 与 **`{workspaceRoot}/对话 html/choices.json`**
4. 用户操作：**选完 → 保存到项目（看页面写入路径）→ 已提交**
5. 正文细节以 HTML 为准，勿用 Markdown 大表格替代排版文档。

## Agent 收到「已提交」时

必须先 `Read` `choices.json` 并校验（见 `SKILL.md` §1.3）。**禁止**根据截图或口头描述直接改 `需求.md`。
