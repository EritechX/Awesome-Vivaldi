# FavDock 拖拽弹新窗口与跨类型标签拖拽问题 — 技术报告

- **报告日期**：2026-07-31
- **Git 分支**：`main`
- **Git Commit**：`fc8de15`（fix(installers): strip stale manual script tags and add post-injection verification）
- **报告性质**：代码审查交接文档。接收方无法访问本代码库，本报告自包含全部必要信息。

---

## 1. 项目概览

### 1.1 项目用途

**Awesome-Vivaldi** 是 Vivaldi 浏览器（Chromium 内核）的 Mod 集合，通过向 Vivaldi 的 `window.html` 注入 JavaScript 与 CSS 实现浏览器 UI 定制（标签页管理、下载管理、地址栏美化、播放器等约 17 个独立 Mod）。

**FavDock** 是本项目中的收藏标签 Dock 模块，仿照 Arc Browser 的 Favorites 与 Zen Browser 的 Essentials：
- 在垂直标签栏（`tabs-left`）顶部注入一个收藏图标网格（9 槽位）；
- 用户把标签页拖入 Dock 即"收藏"该标签；
- 被收藏的标签作为**固定标签（pinned tab）**存在，其固定标题（`vivExtData.fixedTitle`）带 `✦` 前缀标记，并占据固定标签区最前 9 个位置；
- 收藏标签在标签栏本体中隐藏（只显示在 Dock 中），卸载 Mod 后标签仍以固定标签形式存在、可手动恢复（无外部存储，无数据丢失）。

### 1.2 技术栈

| 项 | 内容 |
|---|---|
| 浏览器 | Vivaldi 8.1.4087.40（基于 Chromium，侧载 Mod） |
| 前端 | 原生 JavaScript（IIFE 注入脚本）、CSS（无预处理器） |
| Vivaldi 私有能力 | `chrome.tabs.*`（query/get/update/move/remove）、`chrome.windows.*`、`tab.vivExtData`（JSON 字符串扩展数据字段，含 `fixedTitle`）、`vivaldi.tabsPrivate.move/setGroupProperties`（仅 TidyTabs 使用） |
| 拖拽机制 | HTML5 Drag & Drop API + 鼠标事件 + MutationObserver（三轨检测，原因见 §6.3） |
| 脚本加载 | `injectMods.js` 动态加载 `user_mods/js/*.js` 与 `user_mods/css/*.css` |

### 1.3 与问题相关的目录结构

```
Awesome-Vivaldi/
├── Vivaldi8.0Stable/               # 源码目录（开发态）
│   ├── Javascripts/
│   │   ├── FavDock.js              # ★ 本报告核心文件（约 940 行）
│   │   ├── TidyTabs.js             # 参照实现（vivExtData 读写模式、tabsPrivate 用法）
│   │   └── injectMods.js           # Mod 加载器
│   ├── CSS/
│   │   └── FavDock.css             # ★ 本报告核心样式（约 260 行）
│   └── Import.css                  # 注入 CSS 汇总
├── Doc/
│   ├── mod/FavDock.md              # 设计文档（v3 架构，部分内容已随迭代更新）
│   └── BundleReverse/tabdrag.md    # 逆向笔记（早期，已被 bundle.js 直接分析取代）
├── Others/Source/bundle.js         # ★ Vivaldi 8.x 前端压缩 bundle（6.7MB 单行）——逆向依据
├── dev-install.sh                  # 部署脚本（复制到 user_mods + 可选重启）
└── reports/                        # 本报告所在目录
```

### 1.4 部署方式

`dev-install.sh FavDock` 将 `Vivaldi8.0Stable/Javascripts/FavDock.js` 复制到 `D:\Package\软件\Application\8.1.4087.40\resources\vivaldi\user_mods\js\`，将 `FavDock.css` 复制到 `...\user_mods\css\`；重启 Vivaldi 生效。

---

## 2. 运行环境

| 项 | 值 |
|---|---|
| 操作系统 | Windows 11 Pro for Workstations，10.0.26100，x64 |
| Vivaldi | 8.1.4087.40（Stable），安装路径 `D:\Package\软件\Application\`（含中文字符） |
| Node.js | v22.22.3（仅用于 `node -c` 语法检查与 bundle 文本分析脚本） |
| 依赖 | 无第三方依赖（纯注入脚本） |
| 浏览器配置 | 垂直标签模式（`#browser.tabs-left`）；已开启 "Allow CSS Modification"（vivaldi://experiments） |

**构建/运行方式**：
1. 语法检查：`node -c Vivaldi8.0Stable/Javascripts/FavDock.js`
2. 部署：`bash dev-install.sh FavDock`
3. 重启：`cmd.exe /c taskkill /IM vivaldi.exe /F` + `cmd.exe /c start "" "D:\Package\软件\Application\vivaldi.exe"`（`dev-install.sh --restart` 因安装路径含中文字符无法自动启动，此为已验证的 workaround）
4. 调试入口：Vivaldi 窗口开发者工具控制台（观察 `[FavDock]` 前缀日志）

---

## 3. 问题描述

### 3.1 当前遇到的问题（均未解决/未获最终验证）

1. **拖标签进入 Dock（或 favorites 为空时的 drop zone）松手 → 标签被 Vivaldi 弹去新窗口**：链接在新窗口打开，且成为新窗口的"收藏"。仅在 favorites 尚不存在（首次拖入 drop zone）时偶发成功过一次。
2. **固定标签与非固定标签之间无法互相拖拽**：普通标签无法拖入固定区成为固定标签，固定标签无法拖出固定区成为普通标签。用户希望实现 favorite / pinned / 普通 三种标签互相拖拽。
3. **favorite 标签在标签栏中重复显示**：被收藏的标签应被隐藏（只显示在 Dock），实际仍在固定标签区显示，出现两次。

### 3.2 问题出现的位置

- `FavDock.js`：拖拽检测、drop 事件路由、落点处理、隐藏逻辑（`applyHiddenPins`）。
- 交互位置：垂直标签栏顶部 Dock 区域（`#tabs-container` 内、`.tab-strip` 上方）、标签栏内任意 tab 上。

### 3.3 影响范围

- FavDock 全部核心交互（添加收藏、重排、移出收藏）。
- 用户明确的关键观察：**"只要标签页被拖到标签栏外，如果拖回去的时候没显示 Vivaldi 本身的 dropzone，就会变成新窗口"**——即 Vivaldi 原生拖拽合法区域（dropzone 出现条件）与 Mod 注入区域之间的冲突，是本问题的影响面。
- 附带影响：多次失败尝试后，收藏状态与用户预期不符（标签被固定/加 `✦` 标记但 Dock 未更新）。

### 3.4 前置条件

- 垂直标签模式（`tabs-left`）。
- 拖拽源为标签栏内的标签页（Vivaldi 原生标签拖拽），或 Dock 内的 favorite 槽位（Mod 自身拖拽）。
- 目标区域为 Dock 网格 / drop zone / 标签栏内任意位置。

---

## 4. 实际表现

### 4.1 稳定复现步骤

1. 启动 Vivaldi，打开 ≥2 个标签页。
2. 用鼠标拖动一个普通标签到 Dock 区域（favorites 非空时拖到 9 槽网格；favorites 为空时拖到展开的 "Pin to Favorites" drop zone）。
3. 松手。
4. 观察：标签从原窗口消失，新窗口打开该链接；原窗口控制台出现 `[FavDock] drop in dock → slot N tab <id>` 之类日志，但收藏未在 Dock 中建立。

### 4.2 错误日志（控制台实录，均带 `[FavDock]` 前缀）

成功路径期望日志链（v2 时代设计）：

```
[FavDock] ★ Mouse-drag detected! tabId: 10149786
[FavDock] drop zone shown
[FavDock] drop intercepted, pinning tab 10149786   ← 拦截成功标志
[FavDock] ✓ pinned favorite: <标题>
```

实际观察到的关键日志：

```
[FavDock] ★ Mouse-drag detected! tabId: 10152204
[FavDock] drop zone shown
[FavDock] mouseup, overDropZone: false tabId: 10152204   ← 早期版本，未命中
[FavDock] Tab gone, cannot pin: 10151503                  ← 标签已被 Vivaldi 移走（弹新窗口）
[FavDock] drop in dock → slot -1 tab <id>                 ← v3/v4 版本，随后标签仍弹走
```

（注：`Tab gone, cannot pin` 日志已在新版本移除，改用统一路由；上述为历次迭代实录。）

### 4.3 异常现象

- 松手瞬间标签先进入"拖拽幽灵"状态，随后原窗口标签消失、新窗口出现。
- favorites 为空的首次拖拽偶发成功（drop zone 展开在 `#tabs-container` 顶部时），此后失败。
- 拖回标签栏时若 Vivaldi 自身 dropzone（虚线框指示）未出现，必然开新窗口。
- favorite 标签在 Dock 与固定标签区同时可见（重复显示）。

### 4.4 调试结果（已完成的探针实验与逆向结论）

**探针实验**（自动输出脚本，700ms 增量打印事件/DOM）：
- Vivaldi 标签拖拽 = 鼠标事件（mousedown/mousemove/mouseup）+ HTML5 drag 事件（dragenter/dragover/drop）混合；`dragstart` 不在 document 触发（由 C++/内部处理）。
- 拖拽期间 DOM 出现：`.tab-dropzone`（平铺指示）、`.tab-header.expecting-drop`、`tab-acceptsdrop`、`toolbar-droptarget`、`.tab-position.tab-yield-space`（让位视觉）。
- HTML5 drag 事件确实到达注入元素（`dragenter@fav-dock`）。
- `.tab-wrapper` 存在 `data-id="tab-<tabId>"` 属性（tabId 提取可靠路径）。

**bundle.js 逆向**（`Others/Source/bundle.js`，6.7MB 单行压缩，使用 Node 脚本做上下文切片提取）——关键机制全部来自此处，详见 §8。

### 4.5 关键调用链（逆向自 bundle.js，事实）

```
用户拖拽标签
  → mousedown(.tab) + mousemove 超过 5px
    → maybeStartDragging()：tabsPrivate.startDrag({...})，QW.dndMode="move"（同窗口模式）
    → initDragging()：注册 context 级 mousemove/mouseup 监听
  → 拖拽中 mousemove → handleMouseMove → detectInternalOverlap()
    → 遍历布局树（yoga）中所有 "tab" 节点，计算拖拽标签与目标 tab 的重叠
    → 命中则调用 moveTabs({target: 目标extId, pages: 拖拽页, tweaks: [target-is-tab, above/below]})
      → ★ 悬停期间标签已被"实时移动"（Vivaldi 内部机制，非 drop 时）
    → 同时 windowDragOverHandler（document 级 dragover，bubble）：
      dataTransfer.types 含 Vivaldi 内部 MIME（f.Up）→ preventDefault + stopPropagation
      → 无 #qn（放置目标）时兜底：handleTabPosition(最后一个tab, "after")
  → 松手：
    → HTML5 drop 事件（因 dragover 已被 preventDefault 必然触发）
      · 落在 tab 上 → TabPosition.onDropHandler：
          mB.dropHandlerFired = true
          → droppedTabHandler → moveDetachedTabs(#qn)（tabsPrivate.move，target=#qn.extId）
      · 落在非 tab 区域 → 冒泡到 TabStrip.windowDropHandler：
          mB.dropHandlerFired = true
          → 同窗口(move)模式 → 不执行任何移动（no-op）；"add"模式才 detachPage
    → mouseup → 内部拖拽结束 → endInternalDragging / cleanupDragging
    → C++ 触发 tabsPrivate.onDragEnd → setupDragEndHandler 注册的回调 t(n,i,s,o)：
        if (n) → abortAndRevertDragging（取消）
        if (mB.dropHandlerFired) → #Fn()  ← 仅保持 auto-hide 标签栏可见，安全，不移动标签
        else → 检查 detachPage 条件：e.size>0 && e.size!==窗口标签总数 → detachPage（★ 开新窗口！）
```

**判定：开新窗口的唯一开关是 `mB.dropHandlerFired`**（drop 事件未到达任何 Vivaldi 处理器的场景，该标志为 false）。

---

## 5. 期望表现

1. 拖普通标签到 Dock 任意槽位/空槽 → 标签被固定、标题加 `✦`、移动到对应槽位、标签栏本体隐藏、Dock 显示图标；**不产生新窗口**。
2. 拖普通标签到固定区 → 成为普通固定标签（不带 `✦`）；拖固定标签到普通区 → 取消固定；拖 favorite 在 Dock 内 → 重排；三种状态互相转换全部可用。
3. favorite 标签在标签栏中不重复显示（`favdock-hidden` 生效且稳定）。
4. 拖到标签栏内任意位置时 Vivaldi 原生 dropzone（虚线框）正常出现/消失（不破坏原生拖拽链）。

**修复完成判定标准**：
- 上述 4 项交互全部可用，控制台出现 `[FavDock] ✓ pinned favorite: <标题>` 且无新窗口。
- 重启 Vivaldi 后 favorites 从固定标签恢复（标题 `✦` 标记仍在），标签栏隐藏仍生效。

---

## 6. 修复过程（按时间顺序）

### 6.1 阶段一：弃用 FavouriteTabs.css（已完成，非本次问题根因）

**背景**：旧方案 `FavouriteTabs.css` 对 `.tab-position.is-pinned` 使用 `display: contents` 强行把原生标签条改为 CSS Grid，破坏 Vivaldi 内部定位系统（Position-Y、拖拽命中测试、预览定位），因此弃用。

**修改**：创建独立 `FavDock.js`/`FavDock.css`，Dock 为独立容器（`prepend` 到 `#tabs-container`），原生标签条不动。

**结果**：Dock 可显示，拖拽检测可用。此阶段不作为本问题根因。

### 6.2 阶段二：v2 — OPFS 持久化 + 三轨拖拽检测 + drop 拦截（问题仍在）

**修改内容**：
- `FavDock.js`：OPFS（`navigator.storage.getDirectory`）持久化 favorites；三轨拖拽检测（鼠标事件 mousedown+5px 阈值 / HTML5 dragstart / MutationObserver 观察 `.tab-position.dragging`、`.tab-dropzone`）。
- drop 拦截：document **capture 阶段** `drop` 监听，鼠标在 drop zone rect 内时 `preventDefault()` + `stopImmediatePropagation()`，意图阻止 Vivaldi 的 `windowDropHandler` 开新窗口；drop zone 外放行（标签栏内重排正常）。

**过程中修复的独立 bug**：
- drop zone 不显示：原代码 `style.display = ""`（移除 inline 值）导致 CSS `.fav-dock-dropzone { display:none }` 重新生效，drop zone 恒为 0×0，rect 判定全部失败。修复为显式 `style.display = "flex"/"block"/"none"`。修复后日志出现 `drop zone shown` + `mouseup, overDropZone: true`，但随即出现 `Tab gone, cannot pin: <id>`——**drop 被拦截但 Vivaldi 仍弹新窗口**。

**结果判定**：拦截在 HTML5 事件层面"成功"（日志 `drop intercepted` 出现），但**标签仍被移去新窗口**。此阶段明确暴露：capture 阶段 `preventDefault/stopImmediatePropagation` 无法阻止开新窗口，且疑似破坏了什么——当时未定位（见 §6.4 的根因）。

### 6.3 阶段三：v3 — 按用户需求重写为"标题标记 + 9 槽位 + Zen 式动画"（问题仍在）

用户提出四点设计变更：①favorites 不自我托管（卸载不丢）→ 用"标题特殊符号 + 前 9 固定位"标记；②参考 Zen Browser 的拖拽动画；③drop zone 仅 favorites 为空时显示；④favorite 槽位边框用主题色；另有 z-index 过高盖住地址栏问题。

**修改内容**（`FavDock.js`/`FavDock.css` 整体重写）：
- **标记机制**：`CONFIG.marker = "✦"`；`markFavorite(tabId)` 将 `vivExtData.fixedTitle` 设为 `✦ 原标题`（保留用户已有 fixedTitle）；`unmarkFavorite` 反向剥离；`isMarked(tab)` 判定"标题含 ✦"。
- **不变量维护** `syncFavoritesNow()`：标记但不在前 9 固定位 → 剥离标记；带标记的固定标签批量 `chrome.tabs.move(ids, {index:0})` 前置（保证 favorites 连续占据固定区最前）；favorites = 前 9 固定 ∩ 带标记。
- **9 槽位网格**：常驻 9 个 slot（2 列 × 5 行，`--favdock-cell:44px`）；空槽平时 `display:none`，拖拽悬停 Dock 时显示（`state.dockHovering`）。
- **Zen 式动画**：参考 Zen 源码 `getTabShift` 逻辑，拖拽悬停时目标槽之后（或区间内）的 filled 槽做 `translate` 让位动画（180ms cubic-bezier(0.4,0,0.2,1)，跨行时按 Zen 公式补偿 X/Y）；空槽悬停显示虚线框（scale pop 动画）。
- **drop zone**：仅 `favorites.length === 0` 且拖拽中显示（展开动画 height 0→76px）。
- **边框**：`--favdock-accent: var(--colorAccentBg)` 主题色混合边框。
- **z-index**：`.fav-dock` 从 `z-index:10` 降至 `1`（低于地址栏/toolbar 的 10+，仍高于标签条）。
- **跨类型拖拽**（v3 方案）：capture drop 路由——dock 内 → `handleDockDrop`（addFavorite/重排）；strip 内 → `handleStripDrop`（按 `insertIdx < pinnedCount` 判定固定区，实现 pin/unpin/mark/move）；普通重排（同类型）放行原生。`.separate` 分割线尚未用于判定（v3 用 pinnedCount 快照）。
- **隐藏逻辑**（v3 初版）：`applyHiddenPins` 读取 `.tab-title` 文本含 `✦` 的 `.tab-position.is-pinned` 加 `favdock-hidden`；strip MutationObserver 维护。

**结果**：部署后用户测试（第 3 轮反馈）：
- 拖入 drop zone 仍开新窗口（仅 favorites 空时偶发成功一次）；
- 固定/非固定仍不互通；
- **favorite 标签在固定区重复显示（隐藏失效）**。

**初步归因（当时假设，后经 §6.4 证实为真）**：
- 隐藏失效疑为 `.tab-title` 文本不包含 `✦`（`fixedTitle` 的 DOM 渲染路径未确认），或 strip 重建后 MutationObserver 失效。
- 开新窗口疑为捕获拦截机制本身有问题。

### 6.4 阶段四：v4 — bundle.js 逆向定位根因并重构 drop 路由（已部署，用户未验证即要求暂停）

**逆向方法**：对 `Others/Source/bundle.js`（Vivaldi 前端压缩 bundle，6.7MB 单行）用 Node 脚本做上下文切片提取，定位以下符号：`setupDragEndHandler`、`windowDropHandler`、`windowDragOverHandler`、`detectInternalOverlap`、`onDropHandler`、`droppedTabHandler`、`moveDetachedTabs`、`mB.dropHandlerFired`、`#Fn`、`handleTabPosition`、`.separate`（搜索结果为不存在于 bundle 字符串中，判定由 C++ 侧或 CSS 侧创建）。

**已验证结论（bundle.js 源码实证，本报告 §4.5 调用链）**：
1. **开新窗口的唯一开关**：onDragEnd 回调中 `mB.dropHandlerFired` 为 false 时执行 `detachPage`（`e.size>0 && e.size!==窗口标签总数` 时）。
2. `mB.dropHandlerFired` 由 **TabStrip.windowDropHandler**（document 级 drop，bubble 阶段，注册于 `componentDidMount` 的 `this.context.addEventListener("drop", ...)`）**以及 TabPosition.onDropHandler** 设置（后者先设标志再 `stopPropagation`）。
3. **v2/v3 的 capture `stopImmediatePropagation` 恰好阻止了 windowDropHandler 执行 → 标志永远为 false → detachPage 必然触发。这就是"拦截了 drop 仍开新窗口"的根因（已验证的结论）。**
4. `#Fn()` 仅执行 auto-hide 标签栏可见性保持，不移动标签、不产生副作用。
5. 同窗口（`dndMode="move"`）drop 到非 tab 区域 → windowDropHandler no-op（不移动、不开窗）；仅 `dndMode="add"`（外部拖入）才 detachPage。
6. `detectInternalOverlap` 在**拖拽悬停期间**就实时调用 `moveTabs`（`tweaks: ["target-is-tab", above/below]`）——即 Vivaldi 原生"让位"是真实移动，跨类型是否自动 pin/unpin 取决于 `tabsPrivate.move` 内部实现（未进一步确认）。
7. `windowDragOverHandler`（document 级 dragover）对 Vivaldi 标签拖拽（MIME 含内部类型）**无条件 preventDefault + stopPropagation**；无放置目标（`#qn` 为空）时兜底设置"最后一个 tab after"。
8. `.separate`（固定/非固定分割线）在 bundle 布局代码中由 `kTabsShowSeparator` 偏好控制插入（`type:"separator"`，高度 18px），`createFlexBoxLayout` 中"第一个非 pinned tab 前插入"。**用户指示：高于 `.separate` 即固定区，低于即非固定区**。

**v4 修改内容**（当前部署版本）：
1. **drop 路由重构**：capture 阶段 `drop` 监听**不再 `preventDefault`/`stopImmediatePropagation`**（让 Vivaldi 处理器完整运行以设置 `dropHandlerFired`）：
   - 落点在 Dock → 立即 `handleDockDrop`（addFavorite/重排）；
   - 落点在 tab-strip → 记录 `dropHandled`，`setTimeout(120ms)` 后 `reconcileStripDrop` 纠正状态（此时 Vivaldi 已自行完成移动）。
2. **新增 `reconcileStripDrop(sourceId, x, y)`**：区域判定改用 **`.separate` 的 rect**（`y < separate.top` = 固定区，fallback 为 pinnedCount 判定）；固定区 → 确保 pinned + `intoFavZone`（insertIdx<9）时 mark 否则 unmark + moveTab；非固定区 → unmark + unpin + moveTab。
3. **dragover**：不再全局 preventDefault；仅当 `state.dockDragTabId`（Dock 内拖出的 favorite，dataTransfer 无 Vivaldi MIME）时 preventDefault，保证其 drop 事件可触发。
4. **隐藏逻辑改为 tabId 驱动**：`applyHiddenPins` 用 `.tab-wrapper[data-id]` 提取 tabId，与 `state.favorites` 匹配后 toggle `favdock-hidden`（不依赖标题文本渲染）。
5. `beginDrag`/`onSlotDragStart` 重置 `state.dropHandled`；mouseup 兜底（drop 未触发场景）增加 `dropHandled` 防重。
6. drop zone 悬停高亮：favorites 为空时 dragover 命中 drop zone rect → toggle `fav-dock-dropzone-active`。

**结果**：已通过 `node -c` 语法检查，已部署并重启 Vivaldi。**用户未反馈 v4 的测试结果**，即指示"暂停继续修复，出具报告"，并明确此前各问题（开新窗口、跨类型不互通、favorite 重复显示）均未解决。**v4 的有效性属于"待验证"状态，不是已验证的成功或失败。**

---

## 7. 当前分析

### 7.1 已排除的可能性（已验证结论）

| 可能性 | 结论 | 依据 |
|---|---|---|
| `display: contents` 破坏原生布局 | 已排除（v1 弃用） | 独立容器方案下问题依旧 |
| drop zone 尺寸为 0 导致判定失败 | 已排除 | 显式 display 修复后 rect 判定正常（`overDropZone: true` 日志） |
| capture 阶段 drop `preventDefault` 可阻止开新窗口 | **已排除且已定位** | bundle.js 证实 `stopImmediatePropagation` 阻断 `dropHandlerFired` 设置，反而必然触发 detachPage |
| 隐藏失效因 `.tab-title` 文本无 `✦` 或 observer 失效 | 部分排除 | v4 已改为 tabId 驱动（不依赖文本），但 v4 未验证 |
| `.separate` 存在于 bundle 字符串中 | 已排除 | 全文搜索无结果，判定由 C++/CSS 侧创建（DOM 存在性由用户确认） |

### 7.2 当前怀疑的根因（推测，待验证）

1. **开新窗口**：v2/v3 的 capture 拦截破坏 `mB.dropHandlerFired` 是已证实的根因；v4 已按正确机制重写，**怀疑已解决，但未验证**。
2. **跨类型拖拽不互通**：推测 Vivaldi 8.1 的 `tabsPrivate.move` 对"普通↔固定"跨类型拖拽（`detectInternalOverlap` 实时 move）**可能原生支持自动 pin/unpin**，之前不互通是 v2/v3 破坏事件链的副作用；v4 的 reconcile 作为兜底纠正。**此推测未验证**。
3. **favorite 重复显示**：v4 的 tabId 驱动隐藏未验证；若仍失效，疑为 strip 重建后 observer 观察目标失效（v3 观察的是旧 `.tab-strip` 节点）。

### 7.3 尚未验证的假设

- v4 部署后：拖入 Dock 是否还开新窗口。
- 原生跨类型拖拽在事件链完整时是否工作。
- `reconcileStripDrop` 的 120ms 延迟是否足够（与 Vivaldi 异步 `tabsPrivate.move` 的竞争）。
- Dock 内拖出 favorite（无 Vivaldi MIME）到标签栏：dragover 由我们 preventDefault 保证 drop 触发后，reconcile 路径是否完整。
- `.separate` 在用户环境（垂直模式 + 主题）下的实际 DOM 结构（class 名、位置）。
- `vivExtData.fixedTitle` 是否在标签 DOM 中显示为标题（影响旧隐藏方案，新方案不依赖）。

### 7.4 存在的不确定因素

- Vivaldi 8.1 内部 `tabsPrivate.move` 对 pinned 目标的自动处理行为（未读 C++ 侧源码，无法从 JS bundle 完全确认）。
- C++ 侧拖拽结束事件（`tabsPrivate.onDragEnd`）的参数 `o`（目标窗口）语义细节。
- 用户环境尚未提供 v4 的测试反馈。

---

## 8. 相关代码

### 8.1 逆向自 bundle.js 的核心机制（事实，非推测）

**（a）onDragEnd 回调 —— 开新窗口开关（`setupDragEndHandler` 内，压缩后转写）：**

```js
const t = (n, i, s, o) => {
  z.Z.tabsPrivate.onDragEnd.removeListener(t);
  this.messageDragging();
  setTimeout(() => this.maybeResetDragging(), 100);
  if (n) return void this.abortAndRevertDragging();      // n: 取消标志
  if (mB.dropHandlerFired) return mB.dropHandlerFired = false, void this.#Fn();  // ★ 关键开关
  const { screenLeft: a, screenTop: r, vivaldiWindowId: l } = this.context;
  const c = () => {
    e.size > 0 && e.size !== he.ZP.getPages(l).size &&
      g.ZP.detachPage(e, a + i, r + s);                   // ★ 开新窗口
  };
  if (o) { if (o === l) c(); else { /* 跨窗口 moveDroppedTabs */ } }
  else c();
};
this.#Vn();
z.Z.tabsPrivate.onDragEnd.addListener(t);
```

**（b）`#Fn()` —— 仅保持 auto-hide 标签栏可见（已验证无副作用）：**

```js
#Fn = () => {
  if (autoHideEnabled && kAutoHideTabBar) {
    qi.Z.updateAutoHideVisibility(getActiveWindowId(), this.props.tabPosition, { visible: true, resetOtherWindows: true });
  }
};
```

**（c）TabStrip.windowDropHandler（document 级 drop，bubble）—— 设置标志 + 同窗口 no-op：**

```js
windowDropHandler = e => {
  mB.dropHandlerFired = true;                     // ★ 任何到达的 drop 都设置
  const { dataTransfer: t } = e;
  if (!t) return;
  let n = 0, i = [];
  if (t.getData(f.Up)) { /* 解析拖拽 ids */ }
  else if (t.getData(f.lx)) { /* 解析 */ }
  if (i.length) {
    e.preventDefault(), e.stopPropagation();
    tabs.query({}, t => {
      const s = this.context.vivaldiWindowId;
      if (/* ids 中有其他窗口的标签 */) { moveDroppedTabs(s, ..., n, -1, ...); }
      else {
        const o = /* 本窗口、本 workspace 的拖拽标签 */;
        if (o.size) {
          if (tiling 启用 && (dndDropZone || "move"===dndMode && !t)) tilePages(o);
          else if ("add" === dndMode) detachPage(o, screenX, screenY);   // 仅 add 模式开窗
          // "move" 模式（同窗口）→ 什么都不做
        } else this.maybeResetDragging();
      }
      _Me.dndMode = void 0;
    });
  }
};
```

**（d）TabPosition.onDropHandler —— 先设标志再停止传播：**

```js
onDropHandler = e => {
  mB.dropHandlerFired = true;                     // ★ 先设置
  e.preventDefault(); e.stopPropagation();
  const t = e.dataTransfer.getData(f.Up);
  this.props.isExpectingDrop && t ? this.droppedTabHandler(t) : this.props.dropHandler?.(e);
};
```

**（e）detectInternalOverlap —— 悬停时实时移动（拖拽中）：**

```js
// mousemove → 遍历布局树 children（type==="tab"），计算拖拽标签与目标的重叠
if (命中) {
  const d = target.page.vivExtData.ext_id;
  this.#Wn = true;
  await g.ZP.moveTabs({ target: d, windowId: ..., pages: 拖拽页, tweaks: ["target-is-tab", above/below, ...] });
  this.#Wn = false;
}
```

**（f）windowDragOverHandler —— 任何位置对标签拖拽 preventDefault + 无目标兜底：**

```js
windowDragOverHandler = e => {
  if (e.dataTransfer && e.dataTransfer.types.some(t => t === f.Up) &&
      (e.preventDefault(), e.stopPropagation(), this.delayedActivateWindow(e), !this.#qn)) {
    // 无放置目标时兜底：最后 tab after
    const last = this.props.pages.getIn([-1, "id"]);
    last && this.handleTabPosition(last, "after");
  }
};
```

### 8.2 FavDock.js 当前（v4）关键代码

**（a）drop 路由（capture，只记录不拦截）：**

```js
document.addEventListener("drop", (e) => {
  if (!state.dragging) return;
  const sourceId = state.dockDragTabId || state.draggedTabId;
  if (!sourceId || state.dropHandled) return;
  const x = e.clientX, y = e.clientY;

  const rootRect = state.root?.getBoundingClientRect();
  if (rootRect && isInRect(rootRect, x, y)) {
    state.dropHandled = true;
    handleDockDrop(sourceId, x, y); // 不 preventDefault：Vivaldi 对同窗口 move drop 到非 tab 区域是 no-op
    return;
  }

  const strip = document.querySelector(".tab-strip");
  if (strip && isInRect(strip.getBoundingClientRect(), x, y)) {
    state.dropHandled = true;
    // 先让 Vivaldi 完成移动，再纠正状态
    setTimeout(() => reconcileStripDrop(sourceId, x, y), 120);
  }
}, true);
```

**（b）reconcileStripDrop —— .separate 区域判定 + 状态纠正：**

```js
async function reconcileStripDrop(sourceId, x, y) {
  const src = await getTabById(sourceId);
  if (!src) return;
  const sep = document.querySelector(".tab-strip .separate") ||
              document.querySelector(".separate");
  let inPinnedZone;
  if (sep) inPinnedZone = y < sep.getBoundingClientRect().top;
  else { /* fallback: pinnedCount 判定 */ }
  const insertIdx = computeRealInsertIndex(y);
  const intoFavZone = insertIdx < CONFIG.maxFavorites;

  if (inPinnedZone) {
    if (!src.pinned) await updateTab(sourceId, { pinned: true });
    if (intoFavZone) await markFavorite(sourceId);
    else await unmarkFavorite(sourceId);
    await moveTab(sourceId, intoFavZone ? Math.min(insertIdx, CONFIG.maxFavorites-1) : insertIdx);
  } else {
    await unmarkFavorite(sourceId);
    if (src.pinned) {
      await updateTab(sourceId, { pinned: false });
      await moveTab(sourceId, Math.max(0, insertIdx - 1));
    }
  }
  scheduleSync();
}
```

**（c）标记机制（favorites 身份）：**

```js
// 写入：vivExtData.fixedTitle = "✦ " + (原有标题去掉已有 ✦)
async function markFavorite(tabId) {
  const tab = await getTabById(tabId);
  const viv = parseViv(tab);                       // tab.vivExtData JSON 解析
  const base = (viv.fixedTitle || tab.title || "").replace(MARKER_RE, "").trim();
  const title = base ? `${CONFIG.marker} ${base}` : CONFIG.marker;
  if ((viv.fixedTitle || "") !== title) await setFixedTitle(tabId, title);
}
// setFixedTitle: chrome.tabs.update(tabId, { vivExtData: JSON.stringify(viv) })
// 判定：isMarked(tab) = (viv.fixedTitle || tab.title || "").includes("✦")
```

**（d）不变量维护 syncFavoritesNow()（截取核心步骤）：**

```js
// 1. 越界清理：前 9 固定之外的带标记标签 → unmark；非固定的带标记标签 → unmark
// 2. 重排：带标记固定标签批量 move 到 index 0（chrome.tabs.move(ids, {index:0})）保证 favorites 连续占据最前
// 3. state.favorites = 前 9 固定 ∩ 带标记 → applyHiddenPins() → renderDock()
```

**（e）隐藏（tabId 驱动，v4）：**

```js
function applyHiddenPins() {
  const strip = document.querySelector(".tab-strip");
  if (!strip) return;
  const favIds = new Set(state.favorites.map((f) => String(f.tabId)));
  for (const el of strip.querySelectorAll(":scope > .tab-position.is-pinned")) {
    const id = getTabIdFromElement(el);            // .tab-wrapper[data-id="tab-<id>"] 提取
    el.classList.toggle("favdock-hidden", id != null && favIds.has(String(id)));
  }
}
// CSS: #browser .tab-strip > .tab-position.is-pinned.favdock-hidden { display: none !important; }
```

**（f）三轨拖拽检测（v2 起沿用）：**

1. `mousedown` on `.tab`（button 0）+ mousemove 超 5px 阈值 → `beginDrag(tabId)`；
2. document capture `dragstart` → 从 `e.target.closest('.tab')` 提取 tabId；
3. MutationObserver：`.tab-position` 出现 `dragging`/`is-dragging` class，或 DOM 新增 `.tab-dropzone`/`#drag-image` → `beginDrag`。

`beginDrag` 记录 `state.draggedTabId`、重置 `dropHandled`、异步刷新 `dragSourceTab`（pinned/marked 快照）与 `pinnedCount`、调用 `showDropZone()`（仅 favorites 为空时有效）。

**（g）Dock 内拖出 favorite（onSlotDragStart）：**

```js
function onSlotDragStart(e, tabId) {
  state.dropHandled = false;
  state.dragging = true;
  state.dockDragTabId = tabId;
  state.dragSourceTab = { id: tabId, pinned: true, marked: true };
  e.dataTransfer.setData("text/favdock-tab", String(tabId));
  e.dataTransfer.effectAllowed = "move";
  // 注意：dataTransfer 无 Vivaldi 内部 MIME → v4 在 dragover capture 对 dockDragTabId 强制 preventDefault
}
```

### 8.3 模块调用关系

```
FavDock.js (IIFE, 注入到 window.html 上下文)
├── setupDragDetection()        → beginDrag() / endDragState()
│   ├── document capture: mousedown/mousemove/mouseup/dragstart
│   ├── document capture: dragover（指示器 + dockDragTabId 时 preventDefault）
│   ├── document capture: drop（记录 + Dock 落点立即处理 / strip 落点延迟 reconcile）
│   ├── document capture: dragend（清理）
│   └── MutationObserver（拖拽 DOM 信号）
├── handleDockDrop()            → addFavorite() / moveFavoriteTo() → syncFavoritesNow()
├── reconcileStripDrop()        → markFavorite()/unmarkFavorite()/updateTab()/moveTab() → scheduleSync()
├── syncFavoritesNow()          → applyHiddenPins() + renderDock() + updateDockVisibility()
├── chrome.tabs events          → onActivated/onUpdated/onRemoved/onCreated → renderDock()/scheduleSync()
└── FavDock.css                 → 槽位/动画/drop zone/隐藏/指示器样式
```

---

## 9. 其他补充信息

### 9.1 已知限制

- 安装路径含中文字符（`D:\Package\软件\Application\`），`dev-install.sh --restart` 无法自动重启 Vivaldi，需手动 `taskkill` + `start`（已验证 workaround）。
- Vivaldi bundle 为压缩单行文件，逆向靠 Node 脚本切片提取，无法保证所有符号语义 100% 还原（涉及 C++ 侧逻辑的部分只能推断）。
- 日志规范（项目 AGENTS.md 约定）：所有日志必须带 `[FavDock]` 前缀；禁止高频日志（dragover/mousemove 回调中不输出日志）；只打状态转换日志；预期 <5 行/交互、<20 行/会话。

### 9.2 临时解决方案（当前用户可用行为）

- favorites 为空时首次拖入 drop zone 偶发成功（机制未完全解释，可能与 `#qn` 兜底设置与 drop 时序有关）。
- 用户可手动固定标签 + 右键编辑固定标题加 `✦` 来手工创建 favorite（Dock 启动时自动识别）。

### 9.3 建议重点审查的模块

1. **FavDock.js 的 drop 路由与 reconcile 时序**（§8.2-a/b）：120ms 延迟与 Vivaldi 异步移动的竞争；`.separate` 判定在无分割线主题下的 fallback。
2. **拖拽检测与状态机**（beginDrag/endDragState/dropHandled）：三轨检测的重复触发防护、mouseup 兜底与 drop 路由的互斥。
3. **applyHiddenPins 的观察生命周期**：strip 重建（workspace 切换、标签重排）后 MutationObserver 是否仍绑定在活节点上。
4. **markFavorite 与既有 fixedTitle 的兼容**：与 TidyTitles/TidyTabs 等其他 Mod 对 `vivExtData` 的写入是否冲突（当前各自独立读写，未做互斥）。
5. **syncFavoritesNow 的批量 move**：`chrome.tabs.move(ids, {index:0})` 在极端场景（0/1 个固定标签）的边界（已有 `ordered.length > 1` 防护）。

### 9.4 其他可能帮助定位的信息

- 可复用诊断工具：早期"自动输出探针脚本"（700ms 增量打印 EVT/DOM）可再次挂载，用于确认 v4 部署后 drop 事件是否到达、`mB.dropHandlerFired` 路径是否生效（观察拖到标签栏外再拖回时 Vivaldi dropzone 是否出现）。
- bundle.js 关键锚点（供后续审查者定位）：`setupDragEndHandler`、`windowDropHandler`（TabStrip 类）、`detectInternalOverlap`、`windowDragOverHandler`、`onDropHandler`（TabPosition 类）、`droppedTabHandler`、`moveDetachedTabs`、`mB.dropHandlerFired`、`createFlexBoxLayout`（`.separate` 插入处）。
- 用户关键经验提示：**"标签拖到标签栏外后，拖回时若 Vivaldi 自身 dropzone 未出现则必开新窗口"**——可作为回归测试的判据（拖回标签栏应出现原生虚线框）。
