---
name: html-mode-skill
description: >-
  Reply with rich, interactive Kami parchment HTML in 对话 html/index.html;
  preview on port 3001. Include tables, SVG, CSS, and bidirectional widgets
  (e.g. concept explainers). Load ONLY when user invokes html-mode-skill.
  Windows: kami-preview-3001.ps1; verify HTTP before localhost link. Port 3000 = rough-idea.
disable-model-invocation: true
---

# HTML Mode · Kami 羊皮纸答复

用 **Kami 羊皮纸 HTML** 承载正文；页面应 **丰富可读** 且含 **双向互动**。聊天只给短摘要 + **已验证可访问** 的预览链接。

## 何时使用

**仅当用户显式调用**：

- **用html-mode-skill来回答我**
- 或 @ / 菜单 **`html-mode-skill`**

**不要**替代 `rough-idea-to-plan`（3000、PRD 表单）或 `rough-idea-to-plan-continue`。

---

## 内容原则（写 HTML 时必守）

### 1. 尽量丰富

在 Kami 视觉约束内，让页面像 **可阅读的纸面杂志 + 教具**，而不是纯文字 dump。优先组合使用：

- **表格**：对比、参数、术语对照
- **CSS 版式**：多栏、pull quote、`.tag`、章节 rule、突出数字
- **内联 SVG**：环、流程、架构示意（墨蓝单色）
- **轻交互装饰**：`<details>` 折叠深度内容

详见 [html-mode-rules.md](html-mode-rules.md)「丰富度」清单。**每篇**至少命中其中 **3 类**（长答/学习类更多）。

### 2. 尽量多双向互动

读者 **操作 → 同屏即时反馈**（数字、图、高亮、表行过滤等）。

- **默认**：至少 **1 个「概念讲解器」**（`.concept-explainer`）  
  例：左侧可交互哈希环（增删节点），右侧实时「迁移 key 数」，下方对比表 + 术语表 — 见 `example-interactive.html`
- **或**：≥2 个轻互动（滑块改参数、勾选过滤表、分步揭示等）
- 脚本 **内联** 在 `index.html`；无 JS 时核心文字与静态表仍可读
- 仍遵守 Kami：羊皮纸色、墨蓝 accent、无渐变/大圆角/外链图

互动下限与讲解器结构见 [html-mode-rules.md](html-mode-rules.md)。

---

## Workflow（每次答复）

1. **Read** `doc-kami-parchment`：`~/.cursor/skills/doc-kami-parchment/doc-kami-parchment/SKILL.md`
2. **Read** `~/.cursor/skills/doc-kami-parchment/doc-kami-parchment/example.html`（居中 folio 骨架）
3. **Read** `~/.cursor/skills/html-mode-skill/example-interactive.html`（丰富度 + 概念讲解器样板）
4. **Read** [html-mode-rules.md](html-mode-rules.md)（丰富度/互动下限、禁止项）
5. 若将覆盖 `对话 html/index.html` 且现有页是 PRD 选题（含「保存到项目」）→ **先提醒**
6. **Write** `{workspaceRoot}/对话 html/index.html` — 按主题选 widget，**勿**整页照抄参考页，须贴合用户问题
7. 新建 `对话 html/` 且仓库有 `.gitignore` → 追加 `对话 html/`
8. **启动预览（必做，且必须验证）** — 见下节；**禁止**只贴链接不启动、**禁止** `block_until_ms: 0` 后立即告诉用户「已开好」
9. 按「聊天回复格式」回复；若预览失败，给备用打开方式

---

## 预览服务（端口 3001）— 必读

### 根因（Windows）

`对话 html` 含中文。若用 `Start-Process` 把**完整中文路径**放进 `ArgumentList` 传给 Python，子进程常会**静默失败**，表现为 localhost 打不开。  
**正确做法**：`WorkingDirectory = 对话 html`，参数目录传 **`"."`**。

### Agent 必须执行的命令（Windows）

在工作区根目录执行（把路径换成当前 `{workspaceRoot}`）：

```powershell
$root = "D:\path\to\project"   # 当前工作区根目录绝对路径
$htmlDir = Join-Path $root "对话 html"
& "$env:USERPROFILE\.cursor\skills\html-mode-skill\scripts\kami-preview-3001.ps1" -HtmlDirectory $htmlDir
```

- **`block_until_ms` ≥ 30000**（等待脚本跑完；脚本内含端口 + HTTP 校验）
- 成功时脚本输出 `Kami preview: http://localhost:3001` 并写入 `对话 html/.preview-status.json`（`ok: true`）
- 失败时读 `对话 html/.preview.log`，**不要**仍声称链接可用

### macOS / Linux / Git Bash

```bash
chmod +x ~/.cursor/skills/html-mode-skill/scripts/kami-preview-3001.sh 2>/dev/null || true
~/.cursor/skills/html-mode-skill/scripts/kami-preview-3001.sh "/path/to/project" 3001
```

（若无 `.sh`，用 rough-idea 的 `kami-serve.sh` 传**绝对路径**到 `对话 html`，端口 **3001**。）

### 禁止

- **禁止**让用户用 `file://` 打开（样式/字体常异常）
- **禁止**仅用旧命令 `kami-serve.ps1 -Directory ...` 且把中文路径塞进参数（已修复的全局脚本用 `.`，但 html-mode **优先**专用脚本）
- **禁止**占用 **3000**（留给 rough-idea-to-plan）

### 预览失败时的备用方案（按顺序）

1. 让用户在终端手动执行上一节两行 PowerShell（含 `Join-Path` 与 `-HtmlDirectory`）
2. 用 **cursor-app-control** `open_resource` 打开 `{workspaceRoot}/对话 html/index.html`（编辑器内阅读，非浏览器）
3. 说明需安装 **Python 3** 并加入 PATH

### 一次性依赖

- **Python 3**（`python` 或 `py` 在 PATH）
- `kami-serve.py`：专用脚本会依次查找 `~/.cursor/scripts/`、`rough-idea-to-plan/scripts/`、本 skill 的 `scripts/`

---

## 聊天回复格式

1. **3–8 句**中文摘要（可点名页内主要互动，如「环上可增删节点」）
2. 仅当 **HTTP 校验通过** 后写：**http://localhost:3001**
3. 路径：`对话 html/index.html`
4. 正文细节以 HTML 为准
5. 若预览失败：说明原因 + 贴手动命令或 `open_resource` 已打开文件

---

## Agent 自检

- [ ] 已 Write `对话 html/index.html`
- [ ] 页面含 **≥3 类** 丰富元素（表/SVG/CSS 版式等），且 **≥1 个** 概念讲解器或 **≥2 个** 轻互动
- [ ] 互动有即时反馈；术语表/对比表在 widget 下方或相邻章节
- [ ] 已读 `example-interactive.html` 并贴合主题实现（非无脑复制一致性哈希 demo）
- [ ] 已运行 **`kami-preview-3001.ps1`**（或等价 sh），且 **`block_until_ms` ≥ 30000**
- [ ] 已确认 `对话 html/.preview-status.json` 中 `ok: true`，或终端出现 `Kami preview: http://localhost:3001` 且无报错
- [ ] 未在预览失败时仍只给 localhost 链接
- [ ] 未用 Markdown 大表代替 HTML 正文

---

## 文档形态

| 类型 | 骨架 | 丰富 / 互动 |
|------|------|-------------|
| 短答 | folio + 标题 + lede + 小节 + colophon | ≥1 表或 SVG；≥1 轻互动或 `<details>` |
| 长答 | 多 section + 表/列表 + colophon | ≥3 类丰富元素；≥1 讲解器 |
| 学习/研究 | 分节 + **每节可含 widget** + 术语表 | 讲解器 + 对比表为默认 |

版式与讲解器 DOM 结构见 [html-mode-rules.md](html-mode-rules.md)。
