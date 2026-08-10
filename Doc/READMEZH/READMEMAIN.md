<!-- source-commit: 04a37c2be209d9fd4ec770ec5d703a189c2c08d6 -->
<p align="center">
  <img src="./assets/readme/hero.svg" width="100%" alt="将 Vivaldi 浏览器转变为 Arc 的模组">
</p>

<div align="center">

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/PaRr0tBoY/Awesome-Vivaldi)
[![Vivaldi Forum](https://img.shields.io/badge/Vivaldi-Forum-red)](https://forum.vivaldi.net/topic/112064/modpack-community-essentials-mods-collection?_=1761221602450)
[![LINUX DO](https://img.shields.io/badge/LINUX-DO-1c1c1e?logo=data%3Aimage%2Fsvg%2Bxml%3Bbase64%2CPD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz48c3ZnIHZlcnNpb249IjEuMiIgYmFzZVByb2ZpbGU9InRpbnktcHMiIHdpZHRoPSIxMjgiIGhlaWdodD0iMTI4IiB2aWV3Qm94PSIwIDAgMTIwIDEyMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48dGl0bGU%2BTElOVVggRE8gTG9nbzwvdGl0bGU%2BPGNsaXBQYXRoIGlkPSJhIj48Y2lyY2xlIGN4PSI2MCIgY3k9IjYwIiByPSI0NyIvPjwvY2xpcFBhdGg%2BPGNpcmNsZSBmaWxsPSIjZjBmMGYwIiBjeD0iNjAiIGN5PSI2MCIgcj0iNTAiLz48cmVjdCBmaWxsPSIjMWMxYzFlIiBjbGlwLXBhdGg9InVybCgjYSkiIHg9IjEwIiB5PSIxMCIgd2lkdGg9IjEwMCIgaGVpZ2h0PSIzMCIvPjxyZWN0IGZpbGw9IiNmMGYwZjAiIGNsaXAtcGF0aD0idXJsKCNhKSIgeD0iMTAiIHk9IjQwIiB3aWR0aD0iMTAwIiBoZWlnaHQ9IjQwIi8%2BPHJlY3QgZmlsbD0iI2ZmYjAwMyIgY2xpcC1wYXRoPSJ1cmwoI2EpIiB4PSIxMCIgeT0iODAiIHdpZHRoPSIxMDAiIGhlaWdodD0iMzAiLz48L3N2Zz4%3D "Proudly from LINUX DO")](https://linux.do)
[![Awesome](https://awesome.re/badge.svg)](https://awesome.re)
![GitHub Repo stars](https://img.shields.io/github/stars/PaRr0tBoY/Awesome-Vivaldi)

**English** | [简体中文](./Doc/READMEZH/READMEMAIN.md)

</div>

---

## 快速开始

适用于 [Vivaldi 8.0+](./Vivaldi8.0Stable)。可在 `vivaldi:about` 查看您的版本。

```powershell
irm https://raw.githubusercontent.com/PaRr0tBoY/Awesome-Vivaldi/main/install.ps1 | iex
```

**Windows** (PowerShell):

```powershell
irm https://raw.githubusercontent.com/PaRr0tBoY/Awesome-Vivaldi/main/install.ps1 | iex
```

**macOS** (bash):

```bash
curl -fsSL https://raw.githubusercontent.com/PaRr0tBoY/Awesome-Vivaldi/main/install.sh | bash
```

**Linux** (bash):

```bash
curl -fsSL https://raw.githubusercontent.com/PaRr0tBoY/Awesome-Vivaldi/main/install.sh | sudo bash
```

> 若更倾向手动安装，请参见 **[Installation Guide](./Vivaldi8.0Stable/README.md)**。
> 如果有一个编程代理，请让它：`Install https://github.com/PaRr0tBoY/Awesome-Vivaldi for me.`

<p align="center">
  <img src="https://github.com/user-attachments/assets/2084ca97-4712-4c12-b3f8-ad79ba124cfb" width="800" alt="安装程序预览" src="https://github.com/user-attachments/assets/2084ca97-4712-4c12-b3f8-ad79ba124cfb" />
</p>

---

<p align="center">
  <img src="./assets/readme/section-showcase.svg" width="100%" alt="Vivaldi MAX AI Features">
</p>

| Feature                                         | Mod Files                            | What it does                                                                                 |
|:----------------------------------------------- |:------------------------------------ |:-------------------------------------------------------------------------------------------- |
| ![VividPeek](./Others/assets/ArcPeek.gif)       | `VividPeek.css` + `VividPeek.js`     | Arc 风格的弹出预览标签页对话框 — 无需离开当前页面即可预览标签页                                |
| ![VividPlayer](./Others/assets/VividPlayer.gif) | `VividPlayer.css` + `VividPlayer.js` | 带进度条、 artwork、和播放控制的媒体播放弹出窗口                                             |
| ![PeekTabbar](./Others/assets/PeekTabbar.gif)   | `PeekTabbar.css`                     | 自动隐藏的标签栏，悬停时会展开，支持双层堆叠                                               |

---

<p align="center">
  <img src="./assets/readme/section-max.svg" width="100%" alt="Vivaldi MAX AI Features">
</p>

| Feature                                             | Mod Files                        | What it does                                                       |
|:--------------------------------------------------- |:-------------------------------- |:------------------------------------------------------------------ |
| ![TidyTabs](./Others/assets/VivaldiMax.gif)         | `TidyTabs.js` + `TidyTitles.js`  | AI 驱动的标签分组和标题清理                                        |
| ![TidyDownloads](./Others/assets/TidyDownloads.gif) | `TidyDownloads.js`               | 将混乱的下载文件名重命名为可读的名称                               |
| ![TidyAddress](./Others/assets/tidyaddress.gif)     | `TidyAddress.js`                 | 将 URL 后缀转换为人类可读的 slug                                 |

---

## 文档

在 **[parr0tboy.github.io/docs](https://parr0tboy.github.io/docs/)** 浏览完整文档 — 设计哲学、模组架构深入分析、API 参考以及反向工程 Vivaldi 内部实现。

<details>
<summary><h2>社区模组</h2></summary>

以下模组来自 [Vivaldi Forum](https://forum.vivaldi.net/)，并已包含在本包中：

| 模组                         | 来源                                                                                                                                       |
|:---------------------------- |:-------------------------------------------------------------------------------------------------------------------------------------------- |
| Element Capture              | [Forum](https://forum.vivaldi.net/topic/103686/element-capture) — 自动选择截图区域                                               |
| Colorful Tabs                | [Forum](https://forum.vivaldi.net/topic/96586/colorful-tabs) — 基于图标的标签页着色                                     |
| Monochrome Icons             | [Forum](https://forum.vivaldi.net/topic/102661/monochrome-icons) — 降低网页面板图标的色彩                                   |
| Easy Files                   | [Forum](https://forum.vivaldi.net/topic/94531/easy-files) — 剪贴板 + 下载文件选择器                                             |
| Command Chains Import/Export | [Forum](https://forum.vivaldi.net/topic/93964/import-export-command-chains) — 导入/导出命令链                                         |
| Click to Add Blocking List   | [Forum](https://forum.vivaldi.net/topic/45735/click-to-add-blocking-list) — 一键安装广告拦截列表                                   |
| Global Media Controls        | [Forum](https://forum.vivaldi.net/topic/66803/global-media-controls-panel) — Chrome 风格媒体面板                                 |
| Markdown Editor for Notes    | [Forum](https://forum.vivaldi.net/topic/35644/markdown-editor-for-notes) — 笔记中的 markdown 编辑                                     |
| Open Panels on Mouse-Over    | [Forum](https://forum.vivaldi.net/topic/28413/open-panels-on-mouse-over) — 鼠标悬停自动打开/关闭面板                                      |
| Dashboard Camo               | [Forum](https://forum.vivaldi.net/topic/102173/dashboard-camo-theme-integration-for-dashboard-webpages) — 主题感知的部件样式                                         |
| Colorful Top Loading Bar     | [Forum](https://forum.vivaldi.net/topic/111621/colorful-top-loading-bar) — 页面加载时的动态标题栏                                       |
| Feed Icons                   | [Forum](https://forum.vivaldi.net/topic/73001/feed-icons) — 将订阅图标转换为 favicon                                   |
| Address Bar (Yandex-style)   | [Forum](https://forum.vivaldi.net/topic/96072/address-bar-like-in-yandex-browser) — 标题 + 域名显示                                         |
| Open in Dialog               | [Forum](https://forum.vivaldi.net/topic/92501/open-in-dialog-mod) — 在弹出对话框中打开链接                                         |
| Tab Stack Auto-Expand        | [Forum](https://forum.vivaldi.net/topic/111893/auto-expand-and-collapse-tabbar-for-two-level-tab-stack-rework) — 自动展开/收起标签栏                                         |
| Theme Previews Plus          | [Forum](https://forum.vivaldi.net/topic/103422/theme-previews-plus) — 在设置中提供准确的主题预览                                    |
| VivalArc                     | [GitHub](https://github.com/tovifun/VivalArc) — Arc 主题移植                                                 |

</details>

---

## 小技巧

<details>
<summary>创建一个一键重启按钮（对模组开发有用）</summary>

1. 前往 `vivaldi://vivaldi-urls/` → 启用 **internal debugging pages**
2. 在 `vivaldi:settings/qc/` 创建一个 Quick Command：`Open Link in Current Tab` → `chrome://restart`
3. 通过 **customize toolbar** 将其添加到工具栏
4. 如需，可在 `vivaldi:settings/themes/` 更改图标

</details>

---

特别感谢 [LINUX DO](https://linux.do) 社区的支持。
![Repo activity](https://repobeats.axiom.co/api/embed/4a30f8a4b398404c3c773f672d36c2b52f7865c3.svg "Repobeats analytics")