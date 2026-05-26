# HTML 选题指南（产品经理口吻）

阶段 1 的 `对话 html/index.html` 是在帮用户敲定 **PRD**，不是选技术方案。语气像和产品经理对需求，**禁止**框架、构建工具、仓库结构类问题。

## 分工边界

| 阶段 | 文档 | 问什么 | 不问什么 |
|------|------|--------|----------|
| 1 · HTML | `需求.md`（PRD） | 用户是谁、要完成什么、体验标准、范围边界 | Vite/Webpack、单文件 vs 模块化、GitHub Pages、Service Worker 实现细节 |
| 2 · plan | `plan/技术方案.md` + `Mxx-….md` | 技术栈、目录、部署、模块拆分、验收步骤 | 重复问 PRD 已定的产品目标 |

## 好问题 vs 坏问题

| 坏（太技术） | 好（产品/体验） |
|-------------|----------------|
| 单 HTML 还是 Vite？ | 主要在哪台设备上背？电脑 / 手机 / 都要 |
| 是否上 GitHub Pages？ | 是否需要分享给同学打开链接就能用？ |
| localStorage 还是 IndexedDB？ | 关掉网页后，下次要不要接着上次进度？ |
| 做不做 PWA？ | 要不要能「添加到主屏幕」，像一个小应用？ |
| prefers-color-scheme？ | 界面偏好：只要浅色 / 跟着系统明暗？ |

## 题目设计规则

1. **每题一句人话标题**，`hint` 写用户场景或「为什么问」，不写实现手段。
2. **选项用结果描述**，不出现库名、文件名、协议名（除非用户草稿里已写死且不可改）。
3. **题量**：通常 **5–8** 道必答；`粗糙plan.md` 里已写死的不要重复问。
4. **`id` 稳定**：`q_` + 英文蛇形，语义是**产品决策**（如 `q_resume_progress`），不是 `q_tech_stack`。
5. **一、已定**：只列 PRD 级结论（来自粗糙输入），不列技术选型。
6. **每题必有「自定义」**（硬性）：在 `options` 数组之外，由页面逻辑**自动追加**最后一项「其他（自己填写）」——**不要**把用户自由输入写成某个预设 `value`。选中后展开文本框；保存与校验见下节。

### 自定义选项约定（生成 HTML 必实现）

| 项 | 约定 |
| --- | --- |
| 单选值 | `__custom__`（全局常量，勿与业务 `value` 冲突） |
| 用户文字键 | `{questionId}_custom`，例如 `q_resume_progress_custom` |
| 展示文案 | 默认 **「其他（自己填写）」**；可用 `customOptionLabel` 覆盖 |
| 占位符 | 可选 `customPlaceholder`，如「用一句话说明你的情况」 |
| 完成判定 | 选中 `__custom__` 时，`trim(*_custom)` 非空才算该题已答 |
| 写入 PRD | Agent 在 §6 写 **「自定义：」+ 用户原文**，不单写 `__custom__` |

`QUESTIONS` 里**只列预设选项**；自定义 UI/校验/保存逻辑照抄 [html-submit-snippet.md](html-submit-snippet.md) 中的 `CUSTOM_VALUE` 与 `renderQuestions` 片段。

## QUESTIONS 示例（六级词站 — 仅作风格参考）

```javascript
{
  id: 'q_done_definition',
  title: '怎样才算「背完」整个词库？',
  hint: '决定什么时候出现祝贺、算不算真正完成。',
  options: [
    { value: 'every_batch_mastered', label: '每一批都要背到「这一轮全认识」才算完成' },
    { value: 'visited_all', label: '只要按顺序过完所有批次即可，不要求每批背熟' }
  ]
}
```

```javascript
{
  id: 'q_resume_progress',
  title: '关闭网页后，下次打开希望怎样？',
  hint: '影响要不要记住你背到第几批。',
  options: [
    { value: 'start_fresh', label: '每次从头开始，适合突击刷完' },
    { value: 'remember_batch', label: '记住进度，下次接着背' }
  ]
}
```

## Agent 生成 HTML 前自检

- [ ] 没有任何一题在选「技术栈 / 构建 / 部署平台 / 数据库」
- [ ] **每题**都有预设单选 +「其他（自己填写）」+ 联动文本框（未选自定义时可隐藏）
- [ ] 选项读起来像用户故事，不像架构评审
- [ ] 同步的 `需求.md` 不含 `[已定] 技术栈`（技术留给 `plan/技术方案.md`）
- [ ] lede 写明：这是在定 **产品需求**，实现方式在写 plan 时再定；可补充「不满意选项可自填」
