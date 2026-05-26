# HTML 提交区（生成 `对话 html/index.html` 时必嵌）

## 用户流程（2 步）

1. 在 **http://localhost:3000** 完成 **二、待你拍板** 中全部必选题 → 点 **「保存到项目」**（页面上会显示**写入的绝对路径**）
2. 在 Cursor 回复 **已提交**

**禁止**把「下载 choices.json 再覆盖到文件夹」写成主流程。

**备用**（仅当 POST 失败）：**复制 JSON** 粘贴到对话并写「已提交」——Agent 以粘贴为准，并提示用户再点「保存到项目」同步文件。

## lede 文案（照抄或改写）

```html
<p class="lede">
  这是在敲定<strong>产品需求（PRD）</strong>，请从使用者角度点选；<strong>不涉及</strong>编程框架或部署方式（技术路线稍后写在 <code>plan/技术方案.md</code>）。
  每题除选项外还可选 <strong>「其他（自己填写）」</strong> 并打字说明。N 题选完后点 <strong>「保存到项目」</strong>，再在 Cursor 回复 <strong>已提交</strong>。请用 <strong>http://localhost:3000</strong> 打开，不要用 file://。
</p>
```

## 章节标题（一、二、三 — 禁止 §）

```html
<section class="panel" id="section-a">
  <h2><span class="section-num">一、</span>已定（来自粗糙plan.md，无需选择）</h2>
  …
</section>

<section class="panel" id="section-b">
  <h2><span class="section-num">二、</span>待你拍板</h2>
  <div id="questions-root"></div>
</section>
```

```css
.section-num {
  color: #1B365D;
  font-weight: 500;
}
```

**禁止**：`<span class="kicker">§ A</span>`、`§ B`、`§ C` 及页面上任何 `§` 字符。

## 三、提交区（无 JSON 预览块）

```html
<div class="panel" id="submit-panel">
  <h2><span class="section-num">三、</span>提交给 Agent</h2>
  <p>全部必答题完成后，点主按钮一键写入 <strong>对话 html/choices.json</strong>（须通过 localhost:3000 打开）。</p>
  <div class="btn-row">
    <button type="button" id="btn-save-project">保存到项目</button>
    <button type="button" class="secondary" id="btn-copy">复制 JSON（备用）</button>
    <button type="button" class="secondary" id="btn-reload">从 choices.json 重新加载</button>
    <button type="button" class="secondary" id="btn-clear">清空我的选择</button>
  </div>
  <div id="status-banner"></div>
</div>
```

**禁止**在 HTML 中加入：

```html
<!-- 不要生成 -->
<pre id="live-summary" …></pre>
```

`updateUI()` **不得**向 DOM 写入 `JSON.stringify(buildExportPayload(...))`。

## `choices.json` 格式（与保存 API 一致）

```json
{
  "version": 1,
  "updatedAt": "2026-05-25T12:00:00.000Z",
  "submitted": true,
  "choices": {
    "tech_stack": "single_html"
  }
}
```

- 键名 = 每题 `id`（与 `QUESTIONS[].id` 一致）
- 自定义：`choices[id] === "__custom__"` 且 `choices[id + "_custom"]` 为用户输入（trim 后非空）
- `updatedAt` 保存时必须为 ISO 时间（勿留 `null`）
- `submitted` 保存时必须为 `true`

## 自定义选项（每题必嵌）

**硬性**：不要依赖用户在 `options` 里手写自定义项；由脚本为**每一题**追加。

```javascript
const CUSTOM_VALUE = '__custom__';

function customFieldId(qid) {
  return qid + '_custom';
}

function isQuestionAnswered(q) {
  const v = choices[q.id];
  if (v === undefined || v === null || String(v).length === 0) return false;
  if (v === CUSTOM_VALUE) {
    return String(choices[customFieldId(q.id)] || '').trim().length > 0;
  }
  return true;
}

function allRequiredAnswered() {
  return QUESTIONS.filter((q) => q.required).every(isQuestionAnswered);
}
```

```css
.q-options label.custom-row { display: block; }
.custom-input-wrap {
  margin: 0.35rem 0 0.5rem 1.6rem;
  display: none;
}
.custom-input-wrap.visible { display: block; }
.custom-input-wrap input[type="text"] {
  width: 100%;
  max-width: 36rem;
  padding: 0.55rem 0.75rem;
  font-family: inherit;
  font-size: 0.95rem;
  border: 1px solid #d4d1c5;
  background: #f5f4ed;
  color: #1f1d18;
}
.custom-input-wrap input[type="text"]:focus {
  outline: none;
  border-color: #1B365D;
}
```

在 `renderQuestions()` 里，预设 `q.options.forEach(...)` 之后**必须**追加：

```javascript
const customLabelText = q.customOptionLabel || '其他（自己填写）';
const customPlaceholder = q.customPlaceholder || '请用一句话说明你的想法…';

const customRadioLabel = document.createElement('label');
customRadioLabel.className = 'custom-row';
const customRadio = document.createElement('input');
customRadio.type = 'radio';
customRadio.name = q.id;
customRadio.value = CUSTOM_VALUE;
if (choices[q.id] === CUSTOM_VALUE) customRadio.checked = true;

const customWrap = document.createElement('div');
customWrap.className = 'custom-input-wrap' + (choices[q.id] === CUSTOM_VALUE ? ' visible' : '');

const customInput = document.createElement('input');
customInput.type = 'text';
customInput.placeholder = customPlaceholder;
customInput.value = choices[customFieldId(q.id)] || '';
customInput.setAttribute('aria-label', customLabelText);

function syncCustom() {
  if (choices[q.id] === CUSTOM_VALUE) {
    customWrap.classList.add('visible');
    customInput.disabled = false;
  } else {
    customWrap.classList.remove('visible');
    customInput.disabled = true;
  }
}

customRadio.addEventListener('change', () => {
  choices[q.id] = CUSTOM_VALUE;
  syncCustom();
  customInput.focus();
  persistChoices();
  updateUI();
});

customInput.addEventListener('input', () => {
  choices[customFieldId(q.id)] = customInput.value;
  if (choices[q.id] !== CUSTOM_VALUE) {
    choices[q.id] = CUSTOM_VALUE;
    customRadio.checked = true;
    document.querySelectorAll('input[name="' + q.id + '"]').forEach((el) => {
      if (el !== customRadio) el.checked = false;
    });
  }
  syncCustom();
  persistChoices();
  updateUI();
});

// 预设选项 change 时：delete choices[customFieldId(q.id)] 可选；至少 syncCustom()
customRadioLabel.appendChild(customRadio);
customRadioLabel.appendChild(document.createTextNode(' ' + customLabelText));
customWrap.appendChild(customInput);
opts.appendChild(customRadioLabel);
opts.appendChild(customWrap);
syncCustom();
```

预设单选 `change` 时建议：`delete choices[customFieldId(q.id)]`（或保留不清空），并 `syncCustom()` 隐藏文本框。

`buildExportPayload` / 保存前：若 `choices[id] !== CUSTOM_VALUE`，可 `delete choices[customFieldId(id)]` 保持 JSON 干净。

进度条：`required.filter(isQuestionAnswered).length`。

## 保存到项目（必含 — 显示 API 返回路径）

```javascript
document.getElementById('btn-save-project').addEventListener('click', async () => {
  const payload = buildExportPayload(true);
  const banner = document.getElementById('status-banner');
  try {
    const res = await fetch('/api/save-choices', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });
    if (!res.ok) throw new Error('HTTP ' + res.status);
    const data = await res.json();
    const savedPath = data.path || 'choices.json';
    banner.className = 'ok';
    banner.innerHTML =
      '已写入 <code>' + savedPath + '</code>。请确认路径在项目 <strong>对话 html/</strong> 下，再在 Cursor 回复 <strong>已提交</strong>。';
  } catch (e) {
    banner.className = 'warn';
    banner.innerHTML =
      '无法一键保存（' + e.message + '）。请用 Agent 启动的 <code>kami-serve.py</code> 预览，或「复制 JSON」粘贴到对话。';
  }
});
```

`buildExportPayload` 必须设置 `updatedAt: new Date().toISOString()` 与 `submitted: true`。

## 进度与按钮启用

```javascript
function updateUI() {
  const required = QUESTIONS.filter((q) => q.required);
  const done = required.filter(isQuestionAnswered).length;
  const total = required.length;
  document.getElementById('progress-text').textContent = '已完成 ' + done + ' / ' + total + ' 题';
  document.getElementById('progress-fill').style.width = total ? (100 * done / total) + '%' : '0%';
  document.getElementById('btn-save-project').disabled = !allRequiredAnswered();
}
```

## 复制 JSON（备用）

```javascript
document.getElementById('btn-copy').addEventListener('click', async () => {
  const text = JSON.stringify(buildExportPayload(true), null, 2);
  await navigator.clipboard.writeText(text);
  alert('已复制。粘贴到 Cursor 对话并回复「已提交」。若 POST 可用，仍建议再点「保存到项目」。');
});
```

## 后端

`kami-serve.py` 的 `POST /api/save-choices` 响应示例：

```json
{ "ok": true, "path": "D:/project/对话 html/choices.json" }
```

写入目录 = 启动脚本传入的 `对话 html` 绝对路径（服务根目录）。
