# Zen Browser — Essentials (Essential Tabs) Implementation

## 1. FILE INVENTORY

### CSS/Styling Files
| File | Role |
|------|------|
| `zen/tabs/zen-tabs/vertical-tabs.css` | **Main styling**: grid layout, icon sizing, hover effects, drag indicator, essential tab appearance |
| `zen/tabs/zen-essentials-promo.css` | Promo/drop-target shown when essentials section is empty |
| `zen/compact-mode/sidebar.inc.css` | Compact mode essentials padding override |
| `browser/themes/shared/tabbrowser/tabs-css.patch` | Essential tab audio/sound attribute selectors |

### JS/Logic Files
| File | Role |
|------|------|
| `zen/tabs/ZenPinnedTabManager.mjs` | **Core manager**: add/remove essentials, context menu, drag-drop routing, icon management |
| `zen/drag-and-drop/ZenDragAndDrop.js` | **Drag & drop**: grid drag-over animation, fake tab placeholder, drag image creation |
| `zen/spaces/ZenSpaceManager.mjs` | **Container management**: `getEssentialsSection()`, container-specific essentials, workspace switching |
| `zen/tabs/ZenEssentialsPromo.mjs` | Custom element `<zen-essentials-promo>` for empty essentials drop target |
| `zen/common/modules/ZenSessionStore.mjs` | Session restore: sets `zen-essential` attribute from `tabData.zenEssential` |
| `zen/sessionstore/ZenWindowSync.sys.mjs` | Cross-window sync: listens for `TabAddedToEssentials`/`TabRemovedFromEssentials` |
| `zen/sessionstore/ZenSessionManager.sys.mjs` | DB migration: reads `is_essential` from `zen_pins` table |
| `zen/common/zen-sets.js` | Command routing for `cmd_contextZenAddToEssentials`/`cmd_contextZenRemoveFromEssentials` |
| `zen/urlbar/ZenUBGlobalActions.sys.mjs` | URL bar actions: "Add to essentials" / "Remove from essentials" |
| `browser/components/sessionstore/TabState-sys-mjs.patch` | Saves `zenEssential` to tab state |
| `browser/components/sessionstore/SessionStore-sys-mjs.patch` | Restores `zenEssential` on session restore; sets `pinned=true` for essentials |
| `browser/components/tabbrowser/content/tabbrowser-js.patch` | `_numZenEssentials` getter, tab move/index clamping |
| `browser/components/tabbrowser/content/tab-js.patch` | `zen-essential` attribute added to visibility/icon selectors |
| `browser/components/tabbrowser/content/tabs-js.patch` | `isContainerVerticalPinnedGrid` checks `zen-essential` |
| `browser/components/tabbrowser/content/drag-and-drop-js.patch` | Drag range slicing for essentials vs pinned vs normal |

### XHTML/Markup
| File | Role |
|------|------|
| `browser/base/content/navigator-toolbox-inc-xhtml.patch` | Injects `<div id="zen-essentials">` into DOM |

---

## 2. DOM STRUCTURE

### Container Hierarchy
```
#navigator-toolbox
  └─ #titlebar
       └─ #TabsToolbar
            └─ #TabsToolbar-customization-target
                 ├─ #zen-essentials                    ← HTML div, top-level essentials wrapper
                 │    └─ .zen-essentials-container      ← XUL hbox, per-container (by usercontextid)
                 │         ├─ tab[zen-essential="true"]  ← actual tab elements
                 │         ├─ tab[zen-essential="true"]
                 │         └─ <zen-essentials-promo>     ← empty-state promo (custom element)
                 │
                 └─ #zen-tabs-wrapper                   ← wrapper for normal + pinned tabs
                      ├─ #pinned-tabs-container          ← regular pinned tabs (not essentials)
                      ├─ .pinned-tabs-container-separator
                      └─ #tabbrowser-arrowscrollbox      ← normal (unpinned) tabs
```

### Key Attributes on Tab Elements
| Attribute | Value | Meaning |
|-----------|-------|---------|
| `zen-essential` | `"true"` | Tab is an essential (always pinned too) |
| `pinned` | `"true"` | Always set for essentials (forced) |
| `zen-workspace-id` | UUID string | Removed from essentials (essentials are cross-workspace) |
| `zenDefaultUserContextId` | `"true"` | Set when tab is added to essentials |
| `zen-pinned-icon` | string | Custom icon path |
| `id` | string | Used for cross-window sync (`zenSyncId`) |

### Key Attributes on Containers
| Selector | Attribute | Purpose |
|----------|-----------|---------|
| `.zen-essentials-container` | `container="N"` | N = usercontextid (0 = default, or container ID) |
| `.zen-essentials-container` | `hidden="true"` | When container-specific essentials is ON and this isn't the active container |
| `.zen-essentials-container` | `data-hack-type="1\|2\|3"` | Grid layout variants for different item counts |

---

## 3. CSS GRID LAYOUT — Essentials Container

### Container Grid (`.zen-essentials-container`)
```css
/* vertical-tabs.css:1118-1159 */
.zen-essentials-container {
  display: grid;
  overflow: hidden;
  min-height: 2px;
  gap: 4px;
  
  /* Responsive grid: auto-fit columns, each at least ~23.7% wide */
  grid-template-columns: repeat(
    auto-fit,
    minmax(max(23.7%, var(--min-essentials-width-wrap)), 1fr)
  );
  
  /* min-essentials-width-wrap = tab-min-height + 4px */
  --min-essentials-width-wrap: calc(var(--tab-min-height) + 4px);
  
  /* Layout hack variants for specific item counts */
  &[data-hack-type="1"] { /* 1 item */ 
    grid-template-columns: repeat(auto-fit, minmax(max(30%, ...), auto)); 
  }
  &[data-hack-type="2"] { /* 2 items */
    grid-template-columns: repeat(auto-fit, minmax(max(23%, ...), 1fr) minmax(..., 1fr));
  }
  &[data-hack-type="3"] { /* 3 items */
    grid-template-columns: repeat(auto-fit, minmax(max(25%, 48px), 1fr));
  }
  
  scrollbar-width: thin;
  min-width: calc(100% + var(--zen-toolbox-padding) * 2);
  width: calc(100% + var(--zen-toolbox-padding) * 2);
  padding: 0 var(--zen-toolbox-padding);
  position: absolute;
  
  /* Smooth transitions for layout changes */
  transition: max-height 0.3s ease-out, grid-template-columns 0.3s ease-out;
}
```

### Collapsed Mode (sidebar not expanded)
```css
/* vertical-tabs.css:731-738 */
& .zen-essentials-container {
  justify-content: center;
  grid-template-columns: 1fr !important;  /* Single column when collapsed */
  padding: 0 !important;
  max-width: var(--zen-sidebar-width) !important;
  min-width: unset !important;
  width: 100% !important;
}
```

### Parent (#zen-essentials)
```css
/* vertical-tabs.css:1108-1116 */
#zen-essentials {
  margin-left: calc(-1 * var(--zen-toolbox-padding));
  min-width: calc(100% + var(--zen-toolbox-padding) * 2);
  z-index: 2;
  --tab-min-height: 44px;  /* Set in expanded mode */
}
```

---

## 4. ESSENTIAL TAB APPEARANCE

### Base Styles (`.tabbrowser-tab[zen-essential="true"]`)
```css
/* vertical-tabs.css:1161-1195 */
.tabbrowser-tab[zen-essential="true"] {
  --toolbarbutton-padding-inner: 0;
  max-width: unset;
  width: 100% !important;
  
  /* Square-ish rounded background */
  & .tab-background {
    border-radius: var(--border-radius-medium) !important;
  }
  
  /* Selected state */
  --tab-background-color-selected: light-dark(
    rgba(255,255,255,0.85), 
    rgba(255,255,255,0.2)
  );
  
  /* Unselected: use toolbar element bg */
  &:not([visuallyselected], [multiselected="true"]) .tab-background {
    background: var(--zen-toolbar-element-bg);
    border: none;
  }
  
  /* Center the icon */
  & .tab-content {
    display: flex;
    justify-content: center;
  }
  
  /* HIDE label and close button */
  & .tab-label-container,
  & .tab-close-button {
    display: none !important;
  }
  
  /* Icon spacing */
  & .tab-icon-image,
  & .tab-icon-overlay {
    margin-inline-end: 0 !important;
  }
  
  /* Hover effect */
  &:hover .tab-background {
    background: light-dark(rgba(0,0,0,0.1), var(--tab-background-color-selected));
  }
}
```

### Favicon Background Effect (opt-in via `zen.theme.essentials-favicon-bg`)
```css
/* vertical-tabs.css:1197-1242 */
@media -moz-pref("zen.theme.essentials-favicon-bg") {
  &[visuallyselected] > .tab-stack > .tab-background {
    /* Blurred favicon glow behind the tab */
    &::after {
      content: "";
      inset: -50%;
      filter: blur(20px);
      position: absolute;
      background-image: var(--zen-essential-tab-icon);
      background-size: contain;
      background-position: center;
      z-index: -1;
    }
    
    /* Frosted glass overlay */
    &::before {
      background: var(--zen-essential-tab-selected-bg);
      margin: var(--zen-essential-bg-margin);  /* 2px */
      border-radius: calc(var(--border-radius-medium) - 2px);
      position: absolute;
      inset: 0;
      z-index: 0;
      transition: background 0.1s ease-in-out;
    }
  }
}
```

The `--zen-essential-tab-icon` CSS variable is set programmatically:
```js
// ZenPinnedTabManager.mjs:112-115
setEssentialTabIcon(tab, url = null) {
    const iconUrl = url ?? tab.getAttribute("image") ?? "";
    tab.style.setProperty("--zen-essential-tab-icon", `url(${iconUrl})`);
}
```

---

## 5. DRAG & DROP IMPLEMENTATION

### 5a. Starting a Drag (Essential Tabs)
```js
// ZenDragAndDrop.js:138-158
startTabDrag(event, tab, ...args) {
    // ... normal drag image creation ...
    dt.setDragImage(...this.originalDragImageArgs);
    if (tab.hasAttribute("zen-essential")) {
        tab.style.visibility = "hidden";  // Hide original during drag
    }
}
```

### 5b. Drag Image for Essentials
When dragging an essential tab, the clone preserves its grid-cell dimensions:
```js
// ZenDragAndDrop.js:161-224
#createDragImageForTabs(movingTabs) {
    // ... wrapper creation ...
    for (let i = 0; i < movingTabsCount; i++) {
        const tabClone = tab.cloneNode(true);
        if (tab.hasAttribute("zen-essential")) {
            const rect = tab.getBoundingClientRect();
            tabClone.style.minWidth = tabClone.style.maxWidth = `${rect.width}px`;
            tabClone.style.minHeight = tabClone.style.maxHeight = `${rect.height}px`;
            if (tabClone.hasAttribute("visuallyselected")) {
                tabClone.style.transform = "translate(-50%, -50%)";
            }
        }
        // ... append to wrapper ...
    }
}
```

### 5c. Grid Drag-Over Animation (Reordering Within Essentials)
The core method `#animateVerticalPinnedGridDragOver` handles free-form grid reordering:

```js
// ZenDragAndDrop.js:1469-1749
#animateVerticalPinnedGridDragOver(event) {
    // 1. Check if dragged tab CAN be added as essential
    if (!gZenPinnedTabManager.canEssentialBeAdded(draggedTab)) return;
    
    // 2. Show promo if essentials section is empty
    let essentialsPromoStatus = this.createZenEssentialsPromo();
    
    // 3. Create a "fake essential tab" placeholder if dragging non-essential into essentials
    if (!this._fakeEssentialTab) {
        this._fakeEssentialTab = document.createXULElement("vbox");
        this._fakeEssentialTab.elementIndex = numEssentials;
        if (!draggedTab.hasAttribute("zen-essential")) {
            event.target.closest(".zen-essentials-container")
                .appendChild(this._fakeEssentialTab);
        }
    }
    
    // 4. Calculate tabs-per-row by scanning tab positions
    // 5. Use binary search to find drop target index
    // 6. Shift background tabs via CSS transforms:
    for (let tab of tabs) {
        let [shiftX, shiftY] = getTabShift(tab, newIndex);
        tab.style.transform = shiftX || shiftY 
            ? `translate(${shiftX}px, ${shiftY}px)` 
            : "";
    }
}
```

Key grid-aware behaviors:
- **tabsPerRow**: calculated by scanning tab positions left-to-right, detecting row breaks
- **Row wrapping**: when shifting tabs, detects if a tab moves to a different row and adjusts X/Y shift
- **Binary search**: uses `screenX`/`screenY` center-of-tab as reference to find target position
- **Haptic feedback**: `Services.zen.playHapticFeedback()` on position change

### 5d. Tab Visibility Transition
```css
/* vertical-tabs.css:429-446 */
/* Glance tabs inside essentials float absolutely */
&[zen-essential="true"] .tabbrowser-tab {
    position: absolute;
    top: 0;
    right: 0;
    --tab-collapsed-width: 34px;
    --tab-min-height: 16px;
    width: var(--tab-collapsed-width) !important;
    z-index: 1;
    pointer-events: none;
}
```

### 5e. Drag Target Detection
```js
// ZenDragAndDrop.js:246-260 — _animateTabMove dispatches to grid or normal
_animateTabMove(event) {
    if (event.target.closest("#zen-essentials") && !isEssentialsPromo(event.target)) {
        return this.#animateVerticalPinnedGridDragOver(event);  // Grid mode
    } else if (this._fakeEssentialTab) {
        this.#makeDragImageNonEssential(event);  // Leaving essentials
    }
    // ... normal vertical tab drag ...
}
```

### 5f. Drop Handling (ZenPinnedTabManager.mjs:797-923)
On drop, the manager checks which container received the tab:

```js
// If dropping into essentials container:
if (essentialTabsTarget) {
    // Container-specific check
    if (gZenWorkspaces.containerSpecificEssentials) {
        const sameContextId = (tab.getAttribute("usercontextid") || 0) == targetContainerId;
        if (!sameContextId && tab.hasAttribute("zen-essential")) {
            this.removeEssentials(tab, false);  // Remove from wrong container
        }
    }
    if (!tab.hasAttribute("zen-essential") && !tab?.group?.hasAttribute("split-view-group")) {
        this.addToEssentials(tab);  // Add to essentials
    }
}
// If dropping into pinned tabs container:
else if (pinnedTabsTarget) {
    if (tab.hasAttribute("zen-essential")) {
        this.removeEssentials(tab, false);  // Downgrade to regular pinned
    }
}
// If dropping into normal tabs:
else if (tabsTarget) {
    if (tab.hasAttribute("zen-essential")) {
        this.removeEssentials(tab);  // Fully unpin and remove
    }
}
```

### 5g. Fake Tab Cleanup
```js
// ZenDragAndDrop.js:1751-1762
#maybeClearVerticalPinnedGridDragOver() {
    if (this._fakeEssentialTab) {
        this._fakeEssentialTab.remove();
        this._fakeEssentialTab = null;
        // Reset transforms on all essential tabs
    }
}
```

---

## 6. STATE MANAGEMENT & PERSISTENCE

### 6a. Adding to Essentials (`addToEssentials`)
```js
// ZenPinnedTabManager.mjs:506-561
addToEssentials(tab) {
    // 1. Validate: container-specific check + max count check
    if (!this.canEssentialBeAdded(tab)) return false;
    
    // 2. Set attribute
    tab.setAttribute("zen-essential", "true");
    
    // 3. Remove workspace association (essentials are cross-workspace)
    tab.removeAttribute("zen-workspace-id");
    
    // 4. Pin if not already pinned, move to essentials container
    if (tab.pinned) {
        section.appendChild(tab);  // Move DOM node to essentials
    } else {
        gBrowser.pinTab(tab);      // Will trigger pin → essentials path
    }
    
    // 5. Set container identity
    tab.setAttribute("zenDefaultUserContextId", true);
    
    // 6. Update icon
    this.onTabIconChanged(tab);
    
    // 7. Dispatch sync event
    tab.dispatchEvent(new CustomEvent("TabAddedToEssentials", { bubbles: true }));
}
```

### 6b. Removing from Essentials (`removeEssentials`)
```js
// ZenPinnedTabManager.mjs:563-600
removeEssentials(tab, unpin = true) {
    tab.removeAttribute("zen-essential");
    
    // Re-assign to current workspace
    tab.setAttribute("zen-workspace-id", gZenWorkspaces.getActiveWorkspaceFromCache().uuid);
    
    if (unpin) {
        gBrowser.unpinTab(tab);        // Full unpin (→ normal tabs)
    } else {
        pinnedContainer.prepend(tab);  // Keep pinned, move to pinned section
    }
    
    tab.dispatchEvent(new CustomEvent("TabRemovedFromEssentials", { bubbles: true }));
}
```

### 6c. Validation (`canEssentialBeAdded`)
```js
// ZenPinnedTabManager.mjs:1021-1028
canEssentialBeAdded(tab) {
    return (
        // Container check: if separate-essentials is on, tab must match active container
        !((tab.getAttribute("usercontextid") || 0) != 
          gZenWorkspaces.getActiveWorkspaceFromCache().containerTabId &&
          gZenWorkspaces.containerSpecificEssentials)
        // Max count check
        && gBrowser._numZenEssentials < this.maxEssentialTabs  // default: 12
    );
}
```

### 6d. Session Store — Save (TabState.sys.mjs patch)
```js
// TabState-sys-mjs.patch
tabData.zenEssential = tab.getAttribute("zen-essential") === "true";
tabData.pinned = tabData.pinned || tabData.zenEssential;  // Force pinned
tabData.zenSyncId = tab.getAttribute("id");
tabData.zenDefaultUserContextId = tab.getAttribute("zenDefaultUserContextId");
```

### 6e. Session Store — Restore (SessionStore-sys-mjs.patch + ZenSessionStore.mjs)
```js
// SessionStore-sys-mjs.patch:303-306
if (tabData.zenEssential) {
    tab.setAttribute("zen-essential", "true");
    tabData.pinned = true;  // Essential tabs are always pinned
}

// ZenSessionStore.mjs:33-35 (early restore)
if (tabData.zenEssential) {
    tab.setAttribute("zen-essential", "true");
}
```

### 6f. Database Schema (zen_pins table — ZenSessionManager.sys.mjs)
```js
// ZenSessionManager.sys.mjs:192-208
rows = await db.execute("SELECT * FROM zen_pins ORDER BY position ASC");
data.pins = rows.map(row => ({
    uuid: row.getResultByName("uuid"),
    title: row.getResultByName("title"),
    url: row.getResultByName("url"),
    containerTabId: row.getResultByName("container_id"),
    workspaceUuid: row.getResultByName("workspace_uuid"),
    position: row.getResultByName("position"),
    isEssential: Boolean(row.getResultByName("is_essential")),  // ← KEY FIELD
    // ... other fields ...
}));
```

### 6g. Cross-Window Sync (ZenWindowSync.sys.mjs)
Listens to essential-related events for multi-window state sync:
```js
const EVENTS = [
    "TabAddedToEssentials",
    "TabRemovedFromEssentials",
    // ... other events ...
];
```

---

## 7. ESSENTIALS SECTION MANAGEMENT (ZenSpaceManager.mjs)

### Container Creation (`getEssentialsSection`)
```js
// ZenSpaceManager.mjs:443-477
getEssentialsSection(container = 0) {
    // Normalize: extract usercontextid from tab/element
    if (typeof container !== "number") {
        container = container?.getAttribute("usercontextid");
    }
    container ??= 0;
    
    // If not using container-specific essentials, collapse to single section
    if (!this.containerSpecificEssentials) {
        container = 0;
    }
    
    // Find or create the essentials container
    let essentialsContainer = document.querySelector(
        `.zen-essentials-container[container="${container}"]`
    );
    if (!essentialsContainer) {
        essentialsContainer = document.createXULElement("hbox");
        essentialsContainer.className = "zen-essentials-container zen-workspace-tabs-section";
        essentialsContainer.setAttribute("flex", "1");
        essentialsContainer.setAttribute("container", container);
        document.getElementById("zen-essentials").appendChild(essentialsContainer);
    }
    
    // Show/hide based on active workspace
    if (this.containerSpecificEssentials && 
        this.getActiveWorkspaceFromCache()?.containerTabId != container) {
        essentialsContainer.setAttribute("hidden", "true");
    } else {
        essentialsContainer.removeAttribute("hidden");
    }
    
    return essentialsContainer;
}
```

### `_numZenEssentials` Getter (tabbrowser)
```js
// tabbrowser-js.patch:51-60
get _numZenEssentials() {
    let i = 0;
    for (let tab of this.tabs) {
        if (!tab.hasAttribute("zen-essential") && !tab.hasAttribute("zen-glance-tab")) {
            break;  // Essentials are always first in tab order
        }
        i += !tab.hasAttribute("zen-glance-tab");
    }
    return i;
}
```

### Tab Index Clamping (moveTabTo)
Essentials are always positioned before regular pinned tabs:
```js
// tabbrowser-js.patch:580-582
index = Math.max(index, tab.hasAttribute("zen-essential") ? 0 : this._numZenEssentials);
index = Math.min(index, tab.hasAttribute("zen-essential") ? this._numZenEssentials : this._numVisiblePinTabsWithoutCollapsed);
```

### Container Resolution for Pinning
```js
// tabbrowser-js.patch:1006-1010
let getContainer = () =>
    element.hasAttribute("zen-essential") ? gZenWorkspaces.getEssentialsSection(element) :
    element.pinned ? this.tabContainer.pinnedTabsContainer :
    this.tabContainer;
```

---

## 8. CONTEXT MENU

Menu items injected by `_insertItemsIntoTabContextMenu`:

| Menu ID | Label Key | Condition |
|---------|-----------|-----------|
| `context_zen-add-essential` | `tab-context-zen-add-essential` | Not essential, not in group; badge shows count/max |
| `context_zen-remove-essential` | `tab-context-zen-remove-essential` | Is essential |
| `context_zen-edit-pinned-page` | `tab-context-zen-edit-pinned-page` | Is pinned (sub-menu with replace/edit URL) |
| `context_zen-reset-pinned-tab` | `tab-context-zen-reset-pinned-tab` | Is pinned |

The "Close Tab" context menu item is **hidden** for essential tabs:
```js
document.getElementById("context_closeTab").hidden = contextTab.hasAttribute("zen-essential");
```

---

## 9. PREFS / CONFIGURATION

| Pref | Type | Default | Purpose |
|------|------|---------|---------|
| `zen.tabs.essentials.max` | int | `12` | Max number of essential tabs |
| `zen.workspaces.separate-essentials` | bool | `false` | Container-specific essentials |
| `zen.tabs.ctrl-tab.ignore-essential-tabs` | bool | `false` | Exclude essentials from Ctrl+Tab cycling |
| `zen.theme.essentials-favicon-bg` | — | — | Enable favicon glow background effect |

---

## 10. ICONS

| Icon | Path |
|------|------|
| `essential-add.svg` | `chrome://browser/skin/zen-icons/essential-add.svg` |
| `essential-remove.svg` | `chrome://browser/skin/zen-icons/essential-remove.svg` |

---

## 11. DRAG INDICATOR (#zen-drag-indicator)

Used for the vertical line/indicator when dragging tabs between positions:

```css
/* vertical-tabs.css:1245-1296 */
#zen-drag-indicator {
  --zen-drag-indicator-height: 2px;
  --zen-drag-indicator-bg: color-mix(
    in srgb, 
    var(--zen-primary-color) 50%, 
    light-dark(rgba(0,0,0,0.85), rgba(255,255,255,0.95)) 50%
  );

  position: fixed;
  z-index: 1000;
  background: var(--zen-drag-indicator-bg);
  pointer-events: none;
  border-radius: 5px;

  /* Circle dot at start */
  &::before {
    content: "";
    position: absolute;
    height: calc(2 * var(--zen-drag-indicator-height));
    width: calc(2 * var(--zen-drag-indicator-height));
    border: var(--zen-drag-indicator-height) solid var(--zen-drag-indicator-bg);
    border-radius: 50%;
    background: transparent;
  }

  /* Horizontal orientation (for pinned/essential rows) */
  &[orientation="horizontal"] {
    left: calc(var(--indicator-left) + 2px + 4px);
    width: calc(var(--indicator-width) - 4px - 4px);
    height: var(--zen-drag-indicator-height);
    transition: top 0.05s ease-out, left 0.05s ease-out, width 0.05s ease-out;
    &::before { left: calc(-4px); top: 50%; transform: translate(-2px, -50%); }
  }

  /* Vertical orientation (for normal tab strip) */
  &[orientation="vertical"] {
    top: calc(var(--indicator-top) + 4px + 4px);
    height: calc(var(--indicator-height) - 4px - 4px);
    width: var(--zen-drag-indicator-height);
    transition: top 0.1s ease-out, left 0.1s ease-out, height 0.1s ease-out;
    &::before { top: calc(-4px); left: 50%; transform: translate(-50%, -2px); }
  }
}
```

---

## 12. PROMO ELEMENT (Empty State)

When the essentials section is empty, a promo drop-target appears:

### HTML Structure
```html
<zen-essentials-promo class="zen-drop-target">
  <image src="chrome://browser/content/zen-images/heart.svg" />
  <label class="zen-essentials-promo-title" data-l10n-id="zen-essentials-promo-label" />
  <label class="zen-essentials-promo-sublabel" data-l10n-id="zen-essentials-promo-sublabel" />
</zen-essentials-promo>
```

### Promo CSS
```css
zen-essentials-promo {
  background: color-mix(in srgb, var(--zen-primary-color) 40%, transparent);
  border: 1px solid var(--zen-primary-color);
  border-radius: var(--border-radius-medium);
  padding: 1.1rem 0;
  margin: 2px;
  text-align: center;
  transition: background 0.1s;

  &:not([dragover="true"]) {
    background: color-mix(in srgb, var(--zen-primary-color) 60%, transparent);
    outline: 1px dashed currentColor;
  }

  /* Only visible when sidebar is expanded */
  :root:is(:not([zen-sidebar-expanded="true"]), [zen-unsynced-window="true"]) & {
    display: none !important;
  }
}
```

---

## 13. KEY BEHAVIORS SUMMARY

1. **Essentials are always pinned** — `addToEssentials` calls `pinTab()` if not pinned; session restore forces `pinned=true`
2. **Essentials live above regular pinned tabs** — index range `[0, _numZenEssentials)` vs `[_numZenEssentials, pinnedTabCount)`
3. **Essentials are cross-workspace by default** — `zen-workspace-id` attribute is removed on add
4. **Container-specific mode** — When `zen.workspaces.separate-essentials=true`, essentials are grouped by `usercontextid`
5. **Max count** — `zen.tabs.essentials.max` defaults to 12; checked in `canEssentialBeAdded()`
6. **Essentials cannot be closed** via normal close button or context menu close
7. **Essentials cannot be part of tab groups** (split-view groups)
8. **Grid layout** — CSS Grid with `auto-fit` responsive columns, collapses to single column when sidebar is compact
9. **Haptic feedback** — On position change during drag
10. **Sync events** — `TabAddedToEssentials` / `TabRemovedFromEssentials` for cross-window sync
