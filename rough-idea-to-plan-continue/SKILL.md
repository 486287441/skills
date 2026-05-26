---
name: rough-idea-to-plan-continue
description: >-
  Continue rough-idea-to-plan after PRD HTML. For 已提交: ONLY when
  {workspace}/对话 html/choices.json exists OR the user pastes choices JSON in the
  same message—never on 已提交 alone. For 需求定了写 plan / 写 plan: ONLY when 需求.md
  exists in workspace. For 通过: ONLY when plan/当前步骤.md exists. Never start a new
  PRD; use explicit rough-idea-to-plan for that.
---

# rough-idea-to-plan · 延续

用户**不必**再次写出 `rough-idea-to-plan`。按消息类型执行：

| 用户信号 | 硬性门槛 | 阶段 | 必读主 skill 章节 |
|----------|----------|------|-------------------|
| **已提交** | 工作区存在 **`对话 html/choices.json`**，**或** 本条消息内粘贴了完整 choices JSON | 1.3 校验 → 更新 `需求.md` | [SKILL.md §1.3](../rough-idea-to-plan/SKILL.md) |
| **需求定了，写 plan** / **写 plan** | 工作区存在 **`需求.md`**（且 §6 已有已定记录，或 choices 已校验通过） | 2 技术方案 + Mxx | [SKILL.md §2](../rough-idea-to-plan/SKILL.md)、[plan-structure.md](../rough-idea-to-plan/plan-structure.md) |
| **通过**（模块验收） | 工作区存在 **`plan/当前步骤.md`** | 推进下一步 | 主 skill §2 + `plan/当前步骤.md` |

## 前置检查（按信号分别执行）

### A. 用户说 **已提交**

1. 工作区根目录已打开。
2. **先**尝试 `Read` `{workspaceRoot}/对话 html/choices.json`。
3. **若文件不存在且消息未粘贴 JSON** → **立即停止**：说明「仅『已提交』不足以接续；请先在 http://localhost:3000 点 **保存到项目**，或把 JSON 粘贴到本条消息」。**禁止**猜选、**禁止**新建 PRD/HTML、**禁止**加载主 skill 做阶段 0–1。
4. **若文件存在或消息含粘贴 JSON** → 按主 skill §1.3 校验；未通过则只给修复步骤，不改 `需求.md`。

### B. 用户说 **需求定了，写 plan** / **写 plan**

1. **必须**存在 `{workspaceRoot}/需求.md`；若无 → 提示先完成 A（已提交 + choices 校验）或显式调用 **rough-idea-to-plan**。
2. 若 `需求.md` 里 PRD 仍大量 `[待确认]` 且从未跑过 §1.3 → 先走 A，再进阶段 2。

### C. 用户说 **通过**（模块验收）

1. **必须**存在 `plan/当前步骤.md`；若无 → 说明尚未进入阶段 2，不要编造模块进度。

## 执行

1. `Read` `~/.cursor/skills/rough-idea-to-plan/SKILL.md` 中对应章节（1.3 或 2）及链接的 html-rules / requirements-template / plan-structure。
2. 严格遵循主 skill 的校验、禁止猜选、自检清单。
3. 需要 Kami 版式或改 HTML 时，再 `Read` `doc-kami-parchment`。

## 不要

- 在**没有** `对话 html/choices.json`（且未粘贴 JSON）时响应 **已提交**——这与「写 plan」「通过」的门槛同等严格。
- 用「工作区里有 `需求.md`」代替 choices 文件来触发 **已提交** 路径（写 plan 才看 `需求.md`）。
- 用本 skill 替代用户**首次**启动：首次必须用 **rough-idea-to-plan**。
