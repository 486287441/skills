---
name: rough-idea-to-plan
description: >-
  START a PRD-first planning pipeline: Kami HTML forms in 对话 html/ → 需求.md via
  choices.json → plan/技术方案.md + flat Mxx modules. Load ONLY when the user
  explicitly invokes rough-idea-to-plan (skill name, @skill, or /skill menu)—not
  from vague phrases like 粗糙灵感 or 写计划 alone. After HTML is ready, continuation
  uses skill rough-idea-to-plan-continue (已提交, 需求定了写 plan).
disable-model-invocation: true
---

# 粗糙灵感 → 可执行计划

把模糊灵感落成**可验收、可逐步实现**的计划。分两阶段，**不要跳步**。

## 触发与延续（必读）

| 动作 | 如何触发 | 执行范围 |
|------|----------|----------|
| **启动整条流水线** | 用户**明确写出** `rough-idea-to-plan`（或 @ / 菜单选用本 skill） | 阶段 0 → 1.1 → 1.2（生成 HTML、`需求.md` 草稿、起预览） |
| **HTML 选题之后** | **已提交** 且工作区已有 `对话 html/choices.json`（或本条粘贴 JSON）；或 **需求定了，写 plan** 且已有 `需求.md` | 由 **`rough-idea-to-plan-continue`** 接续；本文件 §1.3、§2 |
| **不要误启动** | 仅「有个想法」「帮我写 plan」、改代码、review | **禁止**跑阶段 0–1；可正常写代码 |

同一会话里一旦已按本 skill 启动，Agent 应记住处于本流程；用户说 **已提交** 时**无需**再次点名 `rough-idea-to-plan`。

| 阶段 | 产出 | 用户动作（默认 2 步） |
|------|------|------------------------|
| 1 · PRD 敲定 | `需求.md`（产品需求）+ `对话 html/index.html`（**只问产品**） | 选题 → **保存到项目** → 回复 **已提交** |
| 2 · 技术 + 实施 | `plan/技术方案.md` + `plan/Mxx-….md` + 分步验收 | 按 `plan/当前步骤.md` 逐步验收 |

**前置**：必须有打开的工作区根目录。

**关联**：版式 `doc-kami-parchment`；HTML/预览/提交见 [html-rules.md](html-rules.md)、[html-submit-snippet.md](html-submit-snippet.md)。

---

## 何时使用（启动）

**仅当用户显式调用本 skill 名**时，从阶段 0 开始：

- 工作区有 `粗糙需求.md` 或用户在调用时附带灵感草稿
- 需要生成 `对话 html/index.html` + 初始 `需求.md`

**不由本 skill 启动**（交给 `rough-idea-to-plan-continue` 或普通对话）：

- 用户只说 **已提交** / 粘贴 JSON / **需求定了，写 plan**（且未在本轮再次点名启动）
- 仅改代码、纯 review、明确不要 html/plan

---

## 预览启动器（含一键保存 API）

自带 `scripts/kami-serve.py` + `.ps1` / `.sh`。**禁止**每次用 AI 重写启动器。

### 一次性安装（仅当 `~/.cursor/scripts/` 缺文件时）

从 `~/.cursor/skills/rough-idea-to-plan/scripts/` 复制到 `~/.cursor/scripts/`（无目录则 `mkdir`；**勿覆盖**已有文件）：

| 文件 | 作用 |
|------|------|
| `kami-serve.py` | 静态服务 + `POST /api/save-choices` → `choices.json` |
| `kami-serve.ps1` | Windows 启动（内部调用 `.py`） |
| `kami-serve.sh` | Unix 启动（`chmod +x`） |

### 为何首次常见 `ERR_CONNECTION_REFUSED`（-102）

| 最常见原因 | 说明 |
|------------|------|
| **端口尚未监听就打开链接** | `kami-serve.ps1` 用 `Start-Process` 拉起 Python 后**原先会立刻退出**；Cursor / Browser MCP 若同时打开 `http://localhost:3000`，会撞上「进程还没 bind」的空窗期。 |
| **Agent 把预览放进后台** | Shell 设 `block_until_ms: 0` 或命令末尾 `&`，Agent 不等启动结束就在回复里贴链接或 `browser_navigate`。 |
| **启动器未装 / Python 缺失** | 首次未复制 `~/.cursor/scripts/kami-serve.py`，或本机无 `python`/`py`，实际没有进程在 3000 监听。 |

**不是** HTML 写错；是**启动顺序与等待**问题。

### 每次写完 HTML 后（工作区根目录，顺序固定）

**顺序（禁止跳步）**：① 若缺文件 → 一次性安装 → ② **写完** `对话 html/index.html` → ③ **前台**跑启动脚本（须等到 exit 0）→ ④ **再**在聊天里贴 `http://localhost:3000`（或让用户自行打开）。

```powershell
# Windows — 前台执行，脚本会等到 127.0.0.1:3000 可连再退出
$htmlDir = Join-Path (Get-Location) "对话 html"
$kami = Join-Path $env:USERPROFILE ".cursor\skills\rough-idea-to-plan\scripts\kami-serve.ps1"
if (-not (Test-Path $kami)) { $kami = Join-Path $env:USERPROFILE ".cursor\scripts\kami-serve.ps1" }
& $kami -Directory $htmlDir
# 期望输出含：Kami preview: http://localhost:3000
```

```bash
# macOS / Linux — 同样前台执行（脚本内部 nohup，但会 wait 端口就绪）
KAMI="$HOME/.cursor/skills/rough-idea-to-plan/scripts/kami-serve.sh"
[ -x "$KAMI" ] || KAMI="$HOME/.cursor/scripts/kami-serve.sh"
"$KAMI" "$(pwd)/对话 html"
```

- **禁止**对启动命令使用 `block_until_ms: 0` 或 shell 末尾 `&`（除非同一条命令里已包含就绪等待）。
- **禁止**在启动命令**成功之前**用 `cursor-ide-browser` / `browser_navigate` 打开 `localhost:3000`（易触发 IDE 的 Browser error 面板）。
- 启动失败（exit ≠ 0）：先修 Python / 复制 `kami-serve.py`，**不要**先给用户贴预览链接。

保存 API 失败时检查是否用了 `kami-serve.py`（回退 `http.server` 无 POST）。

### 启动后自检（同一会话内，生成 HTML 后必做）

1. **工作区**：必须在**已打开的项目根**执行启动命令；`$htmlDir` / `$(pwd)/对话 html` 必须等于 `{workspaceRoot}/对话 html`。
2. **就绪**：启动脚本 **exit 0** 且终端出现 `Kami preview: http://localhost:3000` 后，才在 §1.2 回复中贴该链接。
3. **路径**：回复中写明绝对路径，例如 `{workspaceRoot}/对话 html/choices.json`，并提醒用户**只用 http://localhost:3000 打开，禁止 file://**。
4. **API（可选，仅当 `choices.json` 为空或 `submitted` 为 false 时）**：对工作区发测试 `POST /api/save-choices` 会覆盖用户数据，**禁止**用测试 POST；仅依赖用户点击「保存到项目」。
5. 若用户反馈「保存成功但 Agent 读不到」：检查 3000 是否被**其它项目**占用；重启 `kami-serve.ps1` 并让用户再点「保存到项目」，核对页面上显示的 **写入路径** 与工作区一致。

---

## 阶段 0：读取粗糙输入

1. 读 `粗糙需求.md`；无则用用户消息草稿。
2. 分为 **已定**（一）、**待拍板**（二、选项）、**不做**。
3. `需求.md` 已存在则增量更新。

---

## 阶段 1：HTML 选题 → PRD（`需求.md`）

### 1.1 生成交互页

1. 读 `doc-kami-parchment` 的 `example.html` 作骨架。
2. 读 [html-questions-guide.md](html-questions-guide.md)，从 `粗糙需求.md` 提炼 **5–8 道产品向必答题**（**禁止**技术栈/构建/部署类题目）。
3. 按 [html-rules.md](html-rules.md) 写 `对话 html/index.html`。
4. 结构：**一、**已定（PRD 结论）· **二、**待拍板（产品选项，`q_` 语义化 id）· 进度条 · **三、**提交区；**禁止** `§` 与页内 JSON 预览。
5. **三、提交区**必须按 [html-submit-snippet.md](html-submit-snippet.md)：
   - 主按钮 **保存到项目** → `fetch('/api/save-choices', { method:'POST', … })`
   - 备用 **复制 JSON**
   - lede 写清：PRD 选题 → 保存到项目 → Cursor **已提交**
6. **每题必带「自定义」选项**（见 [html-questions-guide.md](html-questions-guide.md) · [html-submit-snippet.md](html-submit-snippet.md)）：预设单选之外，统一追加 **「其他（自己填写）」**；选中后显示文本框，保存约定见下。
7. `choices.json` 格式：

```json
{
  "version": 1,
  "updatedAt": "ISO-8601",
  "submitted": true,
  "choices": {
    "q_resume_progress": "start_fresh",
    "q_done_definition": "__custom__",
    "q_done_definition_custom": "每批背两遍才算完成"
  }
}
```

- 预设选项：`choices[q.id]` = 该选项的 `value`（蛇形英文）。
- 自定义：`choices[q.id]` = `"__custom__"`，且 `choices[q.id + "_custom"]` = 用户输入（trim 后非空）。
- 未选自定义时，可不写入 `*_custom` 键。

8. 同步 `需求.md`（PRD 模板 [requirements-template.md](requirements-template.md)）；§8 技术实现保持「见 plan」，**不得**把 HTML 答案填进技术栈。
9. 新建 `对话 html/` 时在 `.gitignore` 追加 `对话 html/`（若有）。
10. **前台**启动预览（上一节 §「每次写完 HTML 后」）：安装脚本（若缺）→ 跑 `kami-serve.ps1` / `.sh` 至 exit 0 → **之后**再写 §1.2 回复。

### 1.2 聊天回复（阶段 1）

1. **3–8 句**中文摘要。
2. **http://localhost:3000**
3. 路径：`对话 html/index.html`
4. 用户操作：**选完 → 保存到项目 → 已提交**（勿主推下载覆盖）

### 1.3 用户提交后（先校验，再改需求）

收到 **已提交** 后，**禁止**在未校验通过前更新 `需求.md`。

#### 步骤 1：读取数据

1. **优先** `Read` `{workspaceRoot}/对话 html/choices.json`（用工作区绝对路径，勿猜临时目录）。
2. 若文件无效且用户在消息中**粘贴了 JSON**，用粘贴内容，并在回复中说明「以粘贴为准；请再点保存到项目同步文件」。
3. 字段以 **`choices`** 为准；若仅有 `answers` 则当作 `choices`。

#### 步骤 2：校验（不通过则中止）

| 检查项 | 不通过时 |
|--------|----------|
| `submitted === true` | 要求用户再点「保存到项目」，或粘贴 JSON |
| `choices` 为非空对象 | 同上 |
| 每个「二、待拍板」必答题 `id` 在 `choices` 中有值 | 列出缺失的 `id`（从 `index.html` 的 `QUESTIONS` / `required: true` 读取） |
| 值为 `__custom__` 时，存在非空的 `choices[id + "_custom"]` | 列出需补填自定义文字的题号 |

**禁止**在未通过校验时：根据截图、对话摘要或记忆**猜测**选项并写入 `choices.json` 或 `需求.md`。

#### 步骤 3：通过后才更新

1. 更新 `需求.md`：`[待确认]`→`[已定]`，填 **§6 产品决策记录**（题号、值、用户可理解含义）；若值为 `__custom__`，含义列写 **「自定义：」+ `*_custom` 原文**，勿只写 `__custom__`。
2. 有逻辑矛盾（如「每次从头」+「跨天累计用时」）在 §6 或对应节加 **说明** 一句，勿静默忽略。
3. 有歧义则增补 HTML（可归档 `对话 html/YYYY-MM-DD-HHmm.html`）。
4. 用户说「需求定了，写 plan」→ 阶段 2。

#### 校验失败时的回复模板

- 说明已读路径及当前 `submitted` / `choices` 键数量。
- 给出修复步骤：localhost:3000 → 保存到项目 → 看页面上 **写入路径** → 再回复已提交；或复制 JSON 粘贴。

---

## 阶段 2：技术方案 + 模块化 plan

见 [plan-structure.md](plan-structure.md)。

1. **先**根据已定 `需求.md` 撰写 `plan/技术方案.md`（技术栈、目录、部署、数据流、与 PRD 对应表）。
2. **再**生成扁平 `M01-<模块名>.md`、`M02-….md` …（**禁止** `Mxx/验收.md` 子目录）；模块内容可引用技术方案，写清实现与验收。
3. 初始化 `plan/当前步骤.md`；**一次只推一步**；用户 **通过** 后再下一步。

---

## 文件约定

| 文件 | 说明 |
|------|------|
| `粗糙需求.md` | 输入 |
| `需求.md` | PRD（产品需求，不含技术栈定论） |
| `plan/技术方案.md` | 技术栈与实现路线（阶段 2） |
| `对话 html/index.html` | 选题页 |
| `对话 html/choices.json` | 一键保存结果 |
| `plan/当前步骤.md` | 辅导指针 |
| `plan/M01-<模块名>.md` … | 各模块验收（扁平，无子目录） |

---

## Agent 自检

- [ ] HTML 题为**产品向**（见 html-questions-guide），无技术栈/构建/部署类必答题
- [ ] HTML 章节为 **一、二、三**（无 `§`）；**无**页内 JSON/`live-summary` 预览（见 html-rules）
- [ ] 每题有预设选项 + **「其他（自己填写）」** 及联动文本框；校验 `__custom__` 时 `*_custom` 非空
- [ ] HTML 含 **保存到项目** + 保存成功显示 **API 返回的 path**（见 html-submit-snippet）
- [ ] 预览：先装脚本（若缺）→ **前台**启动至 exit 0 → 再贴 localhost:3000；**未**在就绪前 `browser_navigate` 3000
- [ ] 已用 `kami-serve.py` 起预览；回复中写了 `choices.json` 绝对路径
- [ ] `.page` / 920px 居中，无 Tailwind preflight 贴左
- [ ] **已提交**：已 `Read` 文件且校验通过后才改 `需求.md`（未猜选）
- [ ] `choices.json`：`submitted: true` 且全部必答题 `id` 有值
- [ ] `需求.md` §6 与 `choices` 一致；§8 技术未越权写成 HTML 已定
- [ ] 阶段 2：已有 `plan/技术方案.md`；`Mxx-….md` 扁平、无子目录；辅导只推 `当前步骤.md` 中的一步

---

## 附加资源

- [html-questions-guide.md](html-questions-guide.md) — **PRD 选题口径（必读）**
- [html-rules.md](html-rules.md) — 版式、预览、回复格式
- [html-submit-snippet.md](html-submit-snippet.md) — 三、提交区按钮与 JS（**生成 HTML 必读**）
- [requirements-template.md](requirements-template.md)
- [plan-structure.md](plan-structure.md)
- `scripts/kami-serve.py` — 保存 API 实现
