---
name: html-mode-skill
description: >-
  Reply with Kami parchment HTML in 对话 html/index.html and preview on port 3001.
  Load ONLY when the user says 用html-mode-skill来回答我, names html-mode-skill,
  or @/menu selects this skill—not from vague 用html or 排版 alone. Does not start
  rough-idea-to-plan (port 3000, PRD forms). If preview fails, check port 3001.
disable-model-invocation: true
---

# HTML Mode · Kami 羊皮纸答复

用 **Kami 羊皮纸 HTML** 承载正文排版；聊天只给短摘要 + 预览链接。与 **`rough-idea-to-plan`**（PRD 选题、**3000**）互不自动触发。

## 何时使用

**仅当用户显式调用**时执行本 workflow：

- 用户说出：**用html-mode-skill来回答我**
- 或 @ / 菜单选用 **`html-mode-skill`**

**不要**因「用 HTML 回答」「排版好看一点」等模糊话术加载本 skill。

**不要**用本 skill 替代：

- **`rough-idea-to-plan`** — PRD 表单、`choices.json`、**http://localhost:3000**
- **`rough-idea-to-plan-continue`** — **已提交** / **写 plan** / **通过**

---

## Workflow（每次答复）

1. **Read** `doc-kami-parchment`：`~/.cursor/skills/doc-kami-parchment/doc-kami-parchment/SKILL.md`
2. **Read** 版式骨架：`~/.cursor/skills/doc-kami-parchment/doc-kami-parchment/example.html`（生成前必看）
3. 若将覆盖 `{workspaceRoot}/对话 html/index.html`，且现有页含 **保存到项目** / **待你拍板** / PRD 选题结构 → **先提醒**用户（避免误盖 `rough-idea-to-plan` 的表单）；用户仍要求则继续
4. 按 [html-mode-rules.md](html-mode-rules.md) 撰写 HTML，**Write** `{workspaceRoot}/对话 html/index.html`
5. 用户要求保留时，另存 `{workspaceRoot}/对话 html/YYYY-MM-DD-HHmm.html`（不覆盖 `index.html`）
6. 新建 `对话 html/` 且仓库有 `.gitignore` → 追加一行：`对话 html/`
7. 在工作区根目录**后台**启动预览（**端口 3001**，见下节）
8. 按「聊天回复格式」回复用户

版式与文件细则见 [html-mode-rules.md](html-mode-rules.md)。

---

## 预览服务（端口 3001）

与 `rough-idea-to-plan` 的 **3000** 分离；起本 skill 预览时**不要**占用或重启 3000。

### 一次性安装（仅当 `~/.cursor/scripts/` 缺启动器时）

从 `~/.cursor/skills/rough-idea-to-plan/scripts/` 复制到 `~/.cursor/scripts/`（无目录则 `mkdir`；**勿覆盖**已有文件）：

| 文件 | 作用 |
|------|------|
| `kami-serve.py` | 静态服务（本 skill 不需 POST 保存） |
| `kami-serve.ps1` | Windows |
| `kami-serve.sh` | macOS / Linux / Git Bash |

### 每次写完 HTML 后（工作区根目录，后台）

```powershell
# Windows
$htmlDir = Join-Path (Get-Location) "对话 html"
& "$env:USERPROFILE\.cursor\scripts\kami-serve.ps1" -Directory $htmlDir -Port 3001
```

```bash
# macOS / Linux / Git Bash
chmod +x ~/.cursor/scripts/kami-serve.sh 2>/dev/null || true
~/.cursor/scripts/kami-serve.sh "$(pwd)/对话 html" 3001 &
```

- 预览地址：**http://localhost:3001**（**禁止**让用户用 `file://` 打开）
- **起不来就检查 3001**（是否被其它进程占用；释放后重跑上列命令）
- 勿与 `html-anything` 的 `pnpm dev` 等同占 **3000**；本 skill 固定 **3001**

---

## 聊天回复格式

1. **3–8 句**中文摘要（要点即可）
2. 预览：**http://localhost:3001**
3. 路径：`对话 html/index.html`（可写工作区绝对路径）
4. **正文细节以 HTML 为准**；勿用 Markdown 大表格 / 长多级标题代替排版
5. **实用模式**：聊天里可保留**短**代码块（fenced code）；长文、表格、章节结构只在 HTML

---

## 文档形态（按内容选）

| 长度 / 类型 | 建议骨架 |
|-------------|----------|
| 短答（约 &lt; 500 字） | One-Pager：folio + 标题 + lede + 少量小节 + colophon |
| 长答 / 分析 / 教程 | Long Doc：多 `<section>` + 表格/列表 + colophon |
| 用户点名信函 / 简历 / changelog 等 | 按 `doc-kami-parchment` 对应类型 |

一律：**顶栏 folio（三列 meta）· 标题 · lede · 正文章节 · 底栏 colophon**。

---

## Agent 自检

- [ ] 用户已显式触发本 skill（口令或 @），非模糊「用 HTML」
- [ ] 已 Read `doc-kami-parchment` + `example.html`
- [ ] `.page` / 920px 居中；无 Tailwind CDN 却不用 utility 导致贴左
- [ ] 已 Write `对话 html/index.html`；非 PRD 表单页（无「保存到项目」选题流，除非用户明知覆盖）
- [ ] 预览在 **3001** 后台启动；回复含 **http://localhost:3001**
- [ ] 未用 Markdown 大表替代 HTML 正文
