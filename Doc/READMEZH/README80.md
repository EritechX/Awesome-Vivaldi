<!-- source-commit: 04a37c2be209d9fd4ec770ec5d703a189c2c08d6 -->
<p align="center">
  <img src="../assets/readme/hero-80.svg" width="100%" alt="Volante — Vivaldi 8.0 Stable 安装指南">
</p>

<div align="center">

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/PaRr0tBoY/Awesome-Vivaldi)
[![Vivaldi Forum](https://img.shields.io/badge/Vivaldi-Forum-red)](https://forum.vivaldi.net/topic/112064/modpack-community-essentials-mods-collection?_=1761221602450)
![GitHub Repo stars](https://img.shields.io/github/stars/PaRr0tBoY/Awesome-Vivaldi)

**English** | [简体中文](../Doc/READMEZH/README80.md)

</div>

---

## 目录

- [Prerequisites](#prerequisites)
- [Install CSS Mods](#install-css-mods)
- [Install JavaScript Mods](#install-javascript-mods)
- [Settings Panel](#settings-panel)
- [Update](#update)
- [Development](#development)
- [FAQ](#faq)

---

## 前提条件

打开 `vivaldi:about` 以检查您的版本。然后应用以下设置：

| 设置 | 路径 | 值 |
|:---|:---|:---|
| UI 自动隐藏 | `vivaldi:settings/appearance/` → UI Auto-Hide | **启用** |
| 标签页堆叠 | `vivaldi:settings/tabs/` → Tab Stacking | **两级**（非紧凑模式） |
| 新标签页位置 | `vivaldi:settings/tabs/` → New Tab Position | **与相关标签页一起堆叠** |
| 快速命令 | `vivaldi:settings/qc/` → Quick Command Options | **在新标签页中打开链接** |

---

## 安装 CSS 模组

1. 打开 `vivaldi://flags/#vivaldi-css-mods` → **启用** → 重新启动
2. 前往 **设置 → 外观 → 自定义 UI 修改**
3. 选择包含 `Import.css` 的文件夹（即本文件夹：`Vivaldi8.0Stable/`）
4. 重新启动 Vivaldi

> **7.7+**: CSS 模组标志已移至 `vivaldi://flags/` 下 — 搜索 "vivaldi-" 或前往 `chrome://flags/#vivaldi-css-mods`。
>
> **文件命名**: CSS 文件名中不能包含空格。目录路径可以包含空格。在 Windows 上请确保文件扩展名可见。

---

## 安装 JavaScript 模组

### 自动

| 平台 | 工具 |
|:---|:---|
| Windows | [Vivaldi Mod Manager](https://github.com/eximido/vivaldimodmanager) |
| Linux | [vivaldi-autoinject-custom-js-ui (AUR)](https://aur.archlinux.org/vivaldi-autoinject-custom-js-ui.git) |
| 所有 | [Patching Vivaldi with batch scripts](https://forum.vivaldi.net/topic/10592/patching-vivaldi-with-batch-scripts/21?page=2) |
| macOS | [upviv patch script](https://github.com/PaRr0tBoY/Vivaldi-Mods/blob/8a1e9f8a63f195f67f27ab2e5b86c4aff0081096/MacOSPatchScripts/upviv) |

### 手动

> ⚠️ 编辑前请备份 `window.html`。损坏的文件可能会导致 Vivaldi 无法启动。

1. 将 [`Javascripts/`](./Javascripts/) 中的所有文件复制到：
   ```
   <VIVALDI>/Application/<VERSION>/resources/vivaldi/
   ```
2. 包含的 `window.html` 已引用所有模组 — 替换原始文件
3. 重新启动 Vivaldi
4. 在 `vivaldi:inspect/#apps` 中验证 → 检查 `window.html` → 在元素标签中查看 `<script>` 标签

<details>
<summary>window.html 样子</summary>

```html
<!-- Vivaldi window document -->
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>Vivaldi</title>
    <link rel="stylesheet" href="style/common.css" />
    <link rel="stylesheet" href="chrome://vivaldi-data/css-mods/css" />
  </head>

  <body>
    <script src="TidyTitles.js"></script>
    <script src="TidyTabs.js"></script>
    <script src="TidyDownloads.js"></script>
    <script src="Diabar.js"></script>
    <script src="AskOnPage.js"></script>
    <script src="TabScroll.js"></script>
    <script src="MonochromeIcons.js"></script>
    <script src="VividAddress.js"></script>
    <script src="QuickCapture.js"></script>
    <script src="GlobalMediaControls.js"></script>
    <script src="EasyFiles.js"></script>
    <script src="ModConfig.js"></script>
    <script src="VividPeek.js"></script>
  </body>
</html>
```

</details>

> **AI 功能**: 在 [cheahjs/free-llm-api-resources](https://github.com/cheahjs/free-llm-api-resources?tab=readme-ov-file#opencode-zen) 获取免费的 OpenAI 兼容 API 密钥。

---

## 设置面板

`ModConfig.js` 在 `vivaldi:settings/appearance/` 中添加了一个 **Volante** 部分：

1. 与其他 JS 模组一起安装 `ModConfig.js` → 重新启动
2. 打开 `vivaldi:settings/appearance/` → 找到 **Volante**
3. 配置：
   - **AI 配置** — 端点、API 密钥、模型、每个模组的覆盖设置
   - **Arc Peek** — 点击修饰符、长按按钮、按住计时、自动打开模式
   - **快速捕获** / **自动隐藏面板** — 行为切换
4. 修改后**保存**。使用 **导入** / **导出** 在配置文件之间同步

设置存储在 `.askonpage/config.json`（起源私人文件系统）。支持的模组会自动加载保存的值。

---

## 更新

```bash
cd path/to/Awesome-Vivaldi
git pull

# 将 CSS 模组文件夹的内容重新复制到 Vivaldi CSS 模组文件夹
# 将 Javascripts/ 重新复制到 <VIVALDI>/Application/<VERSION>/resources/vivaldi/
# 如果添加了新的 script 引用，请更新 window.html
```

---

## 开发

### 架构

- **CSS** — 通过 `Import.css` 中的 `@import` 引用。将新的 `.css` 文件添加到 `CSS/`，并在 `Import.css` 中导入
- **JavaScript** — 通过 `window.html` 中的 `<script>` 引用。将新的 `.js` 文件添加到 `Javascripts/`，并添加一个 `<script>` 标签

### 文件元数据

<details>
<summary>CSS — UserStyle 格式</summary>

```css
/* ==UserStyle==
 * @name         Your Mod Name
 * @description  Brief description
 * @version      YYYY.MM.DD
 * @author       Your Name
 * @website      https://github.com/PaRr0tBoY/Awesome-Vivaldi
 * ==/UserStyle==
 */
```

</details>

<details>
<summary>JavaScript — UserScript 格式</summary>

```javascript
// ==UserScript==
// @name         YourMod
// @description  Brief description
// @version      YYYY.MM.DD
// @author       Your Name
// ==/UserScript==
```

</details>

### 检查 Vivaldi UI

使用 `vivaldi:inspect/#apps` → 点击 `window.html` 的 **检查** 按钮以打开浏览器 chrome 的 DevTools。参见 [Vivaldi UI Inspect Tutorial](https://forum.vivaldi.net/post/135732)。

### CSS 注意事项

| 问题 | 解决方案 |
|:---|:---|
| 变量在版本之间断裂 | 使用 Computed Styles 验证；尽量使用硬编码的 `px` |
| CSS 锚点定位不可靠 | 使用 `left: 50%; transform: translateX(-50%)` |
| 需要样式化更早的 DOM 元素 | 在共同父元素上使用 `:has()` |
| Vivaldi 通过 JS 设置内联样式 | 使用 `position: fixed !important` 或 `!important` |

### JavaScript 注意事项

| 问题 | 解决方案 |
|:---|:---|
| MV3 脚本执行 | 使用 `chrome.scripting.executeScript`，而非 `chrome.tabs.executeScript` |
| 工作区重建 `.tab-strip` | 将 MutationObserver 绑定到 `#browser`，在重建时重新绑定内部观察器 |
| `chrome://` / `vivaldi://` 标签页 | 在 `executeScript` 之前始终检查 `tab.url` — 在内部页面上会抛出异常 |

### 资源

- [PrettyBundle.js](../Others/UsefulResources/Source/source/pretty-bundle.js) & [common.css](../Others/UsefulResources/Source/source/common.css) — Vivaldi 的核心 bundle 文件
- [Docs portal](https://parr0tboy.github.io/docs/) — JavaScript 模组 API 参考
- [Vivaldi Browser Source](https://github.com/ric2b/Vivaldi-browser) | [DeepWiki](https://deepwiki.com/ric2b/Vivaldi-browser)
- [Lonm's API Reference](https://lonmcgregor.github.io/VivaldiModdersAPI/OfficialApi/everything.html)

### Vivaldi CSS 变量

主题感知的自定义属性在 `#browser` 上 — 值随主题变化，仅通过 `var()` 名称引用。

<details>
<summary>完整变量参考</summary>

| 类别 | 关键变量 |
|:---|:---|
| **背景** | `--colorBg`, `--colorBgAlpha`, `--colorBgDark`/`Darker`, `--colorBgLight`/`Lighter`, `--colorBgIntense`/`Intenser`, `--colorBgInverse`, `--colorBgFaded` |
| **前景** | `--colorFg`, `--colorFgIntense`, `--colorFgFaded`/`FadedMore`/`FadedMost` |
| **高亮** | `--colorHighlightBg`, `--colorHighlightFg`, `--colorHighlightBgDark`, `--colorHighlightBgAlpha` |
| **强调色** | `--colorAccentBg`, `--colorAccentFg`, `--colorAccentBorder`, `--colorAccentBgDark`/`Darker` |
| **边框** | `--colorBorder`, `--colorBorderSubtle`, `--colorBorderIntense`, `--colorBorderDisabled` |
| **语义** | `--colorSuccessBg`/`Fg`, `--colorWarningBg`/`Fg`, `--colorErrorBg`/`Fg` |
| **圆角** | `--radius`, `--radiusHalf`, `--radiusCap`, `--radiusRound`, `--radiusRounded` |
| **其他** | `--colorTabBar`, `--densityGap`, `--scrollbarWidth`, `--monospaceFont`, `--sansSerifFont`, `--uiZoomLevel` |

</details>

---

## 常见问题

### 安装后没有任何变化

- [ ] CSS 模组在 `vivaldi://flags/#vivaldi-css-mods` 中启用了吗？
- [ ] 在 **设置 → 外观 → 自定义 UI 修改** 中选择了正确的文件夹吗？路径应为 `Awesome-Vivaldi/Vivaldi8.0Stable`
- [ ] JS 文件复制到了 `<VIVALDI>/Application/<VERSION>/resources/vivaldi/` 吗？

### AI 功能无法使用

AI 模组需要 API 密钥。请在 **设置 → 外观 → Volante → AI 配置** 中配置一个，或直接编辑脚本文件中的前几行。

### FavouriteTabs 不显示

只有前 9 个**固定**标签才会变成网格。请至少固定一个标签以查看效果。注意：此模组可能会破坏标签页弹出缩略图。

### 我看不到任何可见的变化

许多模组在后台运行。请查看 [Mod List](../README.md#mod-list) 以了解每个模组的功能及其效果出现的时间。

### 某些功能似乎被禁用

一些模组是故意关闭的（存在 bug/未完成）。可以手动启用：
- CSS → 编辑 [Import.css](./Import.css) — 取消 `@import` 的注释
- JS → 编辑 [window.html](./Javascripts/window.html) — 添加 `<script>` 标签

### 为什么我无法展开我的标签栏？

如果您启用了 **Better Animation**，并且您的标签栏设置为自动隐藏（仅垂直布局：左或右），当将鼠标悬停在屏幕边缘时，标签栏只会显示一条细窄的 8px 条。这是设计使然 — 为了防止当鼠标靠近边缘时意外展开。

要完全展开标签栏，请使用以下方法之一：

| 方法 | 操作 |
|:---|:---|
| **点击** | 点击屏幕边缘出现的细窄预览条 |
| **悬停 1 秒** | 将鼠标放在预览条上，1 秒内不移动 |
| **双击边缘** | 将鼠标移动到屏幕边缘，轻微拉回，然后在 500ms 内再次击中边缘 |

预览条在悬停时还会显示方向箭头叠加层，因此您可以准确看见点击位置。

如果标签栏根本无法展开，请确认您的标签栏设置为 **左** 或 **右** — 此模组不适用于 **顶部** 或 **底部** 标签栏位置。

### 仍然无法使用

1. 重新启动 Vivaldi
2. 仔细检查文件路径（最常见的问题）
3. 验证文件是*替换*而不是与原始文件并行复制

```