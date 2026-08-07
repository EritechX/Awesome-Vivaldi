# 【开源】CCG v1.7.55 : Claude Code 编排三 CLI 协作 | Codex + Gemini + Claude

---

> **GitHub**: [GitHub - fengshao1227/ccg-workflow: 多模型协作开发系统 - Claude 编排 + Codex 后端 + Gemini 前端，28 个命令覆盖开发全流程，一键安装零配置 · GitHub](https://github.com/fengshao1227/ccg-workflow)  
> 觉得好用请留下你的 ![:star:](images/image_0__star_.png ":star:") Star

> ![:warning:](images/image_1__warning_.png ":warning:") **OpenSpec 规范驱动已发布**
> 
> 新增 5 个 `/ccg:spec-*` 命令，把需求变成约束，让 AI 没法自由发挥。适合复杂功能开发。  
> ![:backhand_index_pointing_right:](images/image_2__backhand_index_pointing_right_.png ":backhand_index_pointing_right:") [查看新帖：CCG + OpenSpec：让 AI 不再自由发挥](https://linux.do/t/topic/1505544)

[![npm version](images/image_3_npm version.svg)](https://www.npmjs.com/package/ccg-workflow) [![License: MIT](images/image_4_License_ MIT.svg)](https://opensource.org/licenses/MIT) [![Claude Code](images/image_5_Claude Code.svg)](https://claude.ai/code)

**一句话介绍**：Claude Code 编排 Codex + Gemini 三 CLI 协作，固定路由前端→Gemini、后端→Codex，支持多模型并行工作流，一键安装极简配置。

* * *

## ![:new_button:](images/image_6__new_button_.png ":new_button:") v1.7.55：修复第三方 Gemini API 无法使用的问题

**问题背景**：  
之前用第三方 Gemini API（比如中转 API）时，因为模型名称不匹配会报错。现在可以自己指定模型了！

**更新内容**：

*   ![:white_check_mark:](images/image_13__white_check_mark_.png ":white_check_mark:") 所有 Gemini 命令默认使用 `gemini-3-pro-preview` 模型（Google 官方最新模型）
*   ![:white_check_mark:](images/image_13__white_check_mark_.png ":white_check_mark:") 支持 `--gemini-model` 参数，可以自定义模型名称（感谢 [@xuebkgithub](https://github.com/xuebkgithub) 的 PR #42）
*   ![:white_check_mark:](images/image_13__white_check_mark_.png ":white_check_mark:") 14 个命令模板全部更新，兼容第三方 API

**使用场景**：

*   用 Google 官方 API？默认就行，自动用最新模型
*   用第三方中转 API？可以指定他们支持的模型名称
*   想用其他 Gemini 模型？加个参数就行

**如何更新**：

```bash
npx ccg-workflow@latest
# 选择 "更新工作流"
```

**影响的命令**：

*   核心工作流：`/ccg:frontend`, `/ccg:workflow`, `/ccg:plan`, `/ccg:execute`
*   开发工具：`/ccg:analyze`, `/ccg:debug`, `/ccg:optimize`, `/ccg:review`, `/ccg:test`, `/ccg:feat`

* * *

## ![:gear:](images/image_10__gear_.png ":gear:") 推荐全局提示词配置

如果你想更好地使用 ace-tool MCP 和 Codex/Gemini CLI，可以在 `~/.claude/CLAUDE.md` 中添加以下全局提示词（CCG 工作流本身已封装完整提示词，此配置为可选增强）：

**点击展开查看完整配置**

**直接复制以下内容到 `~/.claude/CLAUDE.md`：**

```plaintext
# CCG 工作流增强配置

## 1. Prompt 增强 (每次对话自动触发)
**执行时机**：用户发送消息时
**工具调用**：调用 mcp__ace-tool__enhance_prompt
**作用**：将模糊需求转化为结构化、可执行的任务描述

## 2. 上下文全量检索 (生成代码前必须执行)
**执行时机**：在生成任何建议或代码之前
**工具调用**：调用 mcp__ace-tool__search_context

**检索策略**：
- 禁止基于假设 (Assumption) 回答
- 使用自然语言构建语义查询 (Where/What/How)
- 完整性检查：必须获取相关类、函数、变量的完整定义与签名
- 若上下文不足，触发递归检索直至信息完整

**需求对齐**：若检索后需求仍有模糊空间，必须向用户输出引导性问题列表，直至需求边界清晰（无遗漏、无冗余）。

## 3. 工作流执行原则

1. 先检索，后生成：永远不要在没有调用 search_context 的情况下编写代码
2. 增强需求：对于复杂任务，先调用 enhance_prompt 明确需求边界
3. 智能路由：根据任务类型自动选择 Codex/Gemini/Claude
4. 交叉验证：关键决策使用双模型并行分析
5. 代码主权：Codex/Gemini 仅负责分析、规划、审查，禁止直接修改文件；所有代码实现由 Claude 完成
```

**（可选）多模型协作调用规范**：如果你安装了 Codex/Gemini CLI，可以追加以下内容：

```plaintext
## 多模型协作调用规范

### Codex CLI 调用 (后端任务)
调用方式：codeagent-wrapper --backend codex - [工作目录] <<'EOF' ... EOF
适用场景：后端逻辑、算法实现、数据库操作、API 开发、性能优化、调试分析

### Gemini CLI 调用 (前端任务)
调用方式：codeagent-wrapper --backend gemini - [工作目录] <<'EOF' ... EOF
适用场景：UI/UX 组件开发、CSS 样式、响应式布局、前端交互逻辑

### 会话复用
每次调用返回 SESSION_ID: xxx，后续阶段用 resume xxx 复用上下文，保持对话连贯性。

新会话调用：codeagent-wrapper --backend <codex|gemini> - [工作目录] <<'EOF' ... EOF
复用会话调用：codeagent-wrapper --backend <codex|gemini> resume <SESSION_ID> - [工作目录] <<'EOF' ... EOF

### 并行调用
使用 run_in_background: true 启动后台任务，用 TaskOutput 等待结果。必须等所有模型返回后才能进入下一阶段。

并行启动示例：
Bash({ command: "codeagent-wrapper --backend codex ...", run_in_background: true, timeout: 3600000 })
Bash({ command: "codeagent-wrapper --backend gemini ...", run_in_background: true, timeout: 3600000 })

等待后台任务：TaskOutput({ task_id: <TASK_ID>, block: true, timeout: 600000 })
```

**配置后效果**：

*   ![:white_check_mark:](images/image_13__white_check_mark_.png ":white_check_mark:") 每次对话自动增强 Prompt，减少需求模糊
*   ![:white_check_mark:](images/image_13__white_check_mark_.png ":white_check_mark:") 代码生成前强制检索上下文，避免幻觉
*   ![:white_check_mark:](images/image_13__white_check_mark_.png ":white_check_mark:") 多模型协作规范化，提升代码质量

* * *

## ![:rocket:](images/image_14__rocket_.png ":rocket:") 快速开始

### 30 秒了解

CCG = **Claude Code** (主导编排) + **Codex CLI** (后端原型) + **Gemini CLI** (前端原型)

**核心理念**：让 Claude 专注于编排决策，把具体代码生成交给专业模型

*   前端任务 → Gemini（擅长 UI/CSS/组件）
*   后端任务 → Codex（擅长逻辑/算法/调试）
*   全栈整合 → Claude（编排决策、质量把控）

### 一键安装

```bash
npx ccg-workflow
```

安装流程：

1.  选择 “初始化工作流”
2.  配置 ace-tool MCP（可选，可跳过）
3.  自动安装 16 个命令
4.  重启终端生效

### 第一个命令

```bash
# 在 Claude Code 中执行
/ccg:workflow 实现用户登录功能
```

自动执行 6 阶段工作流：Prompt增强 → 代码检索 → 并行分析 → 原型生成 → 实施 → 审计

* * *

## ![:light_bulb:](images/image_15__light_bulb_.png ":light_bulb:") 核心特性

特性

说明

**Web UI 实时输出**

自动打开浏览器，流式显示思考过程、命令执行、生成结果

**固定路由**

前端→Gemini，后端→Codex，全栈→Claude

**多模型并行**

Codex ∥ Gemini 同时调用，交叉验证

**6阶段工作流**

Prompt增强 → 检索 → 分析 → 原型 → 实施 → 审计

**12个专家提示词**

ROLE\_FILE 零 token 动态注入

**16个斜杠命令**

开发工作流 + Git 工具 + 项目管理

**跨平台支持**

macOS / Linux / Windows × Intel / ARM

### 架构图

```objectivec
┌─────────────────────────────────────────────────────┐
│              Claude Code CLI (主导编排)              │
└──────────────┬──────────────────────────────────────┘
               │
       ┌───────┴───────┐
       ↓               ↓
┌─────────────┐ ┌─────────────┐
│  Codex CLI  │ │ Gemini CLI  │
│  后端原型   │ │  前端原型   │
└─────────────┘ └─────────────┘
       │               │
       └───────┬───────┘
               ↓
         返回 Patch
      (Claude 审核后应用)
```

* * *

## ![:books:](images/image_16__books_.png ":books:") 命令参考（16 个）

### 日常开发只需记住这几个

```bash
/ccg:workflow   # 完整流程，复杂任务用这个
/ccg:plan       # 多模型规划（Phase 1-2），生成计划
/ccg:execute    # 多模型执行（Phase 3-5），执行计划
/ccg:feat       # 新功能开发（规划→实施）
/ccg:frontend   # 纯前端，Gemini 快速模式
/ccg:backend    # 纯后端，Codex 快速模式
```

### 完整命令列表

**开发工作流（12 个）**

命令

用途

模式

`/ccg:workflow`

完整6阶段工作流

Codex ∥ Gemini

`/ccg:plan`

多模型规划（Phase 1-2）

Codex ∥ Gemini

`/ccg:execute`

多模型执行（Phase 3-5）

Codex ∥ Gemini + Claude

`/ccg:feat`

智能功能开发

规划 → 实施

`/ccg:frontend`

前端专项

Gemini

`/ccg:backend`

后端专项

Codex

`/ccg:analyze`

技术分析（仅分析）

Codex ∥ Gemini

`/ccg:debug`

问题诊断+修复

Codex ∥ Gemini

`/ccg:optimize`

性能优化

Codex ∥ Gemini

`/ccg:test`

测试生成

智能路由

`/ccg:review`

代码审查（无参数自动审查 git diff）

Codex ∥ Gemini

`/ccg:enhance`

Prompt 增强

ace-tool MCP

**Git 工具（4 个）**

命令

用途

`/ccg:commit`

智能提交，自动生成 conventional commit

`/ccg:rollback`

交互式回滚

`/ccg:clean-branches`

清理已合并分支

`/ccg:worktree`

Worktree 管理

**项目管理（1 个）**

命令

用途

`/ccg:init`

初始化项目 CLAUDE.md

* * *

## ![:package:](images/image_17__package_.png ":package:") 前置要求

**必需**：

*   Claude Code CLI
*   Node.js 18+

**可选**（按需安装）：

*   Codex CLI - 不装的话后端任务降级成 Claude
*   Gemini CLI - 不装的话前端任务也降级

> 只有 Claude Code 也能用，就是没有多模型协作了

* * *

## ![:wrench:](images/image_18__wrench_.png ":wrench:") ace-tool MCP 配置

安装时可选配置，用于代码检索和 Prompt 增强。

**两种方式**：

1.  **官方服务** - https://augmentcode.com/ 注册获取 Token
2.  **中转服务** - [linux.do](http://linux.do) 社区提供，无需注册：https://linux.do/t/topic/1291730

跳过也行，`/ccg:workflow` 的 Phase 0 和 Phase 1 会跳过，其他命令正常工作。

* * *

## ![:red_question_mark:](images/image_19__red_question_mark_.png ":red_question_mark:") 常见问题

**Q: codeagent-wrapper: command not found？**

PATH 未生效，重启终端或执行：

```bash
# Mac/Linux
source ~/.zshrc

# Windows
# 重新打开 PowerShell
```
**Q: 如何更新？**

```bash
# npx 安装用户（所有平台通用，包括 Windows）
npx ccg-workflow@latest
# 选择 "更新工作流"

# npm 全局安装用户
npm install -g ccg-workflow@latest
```
**Q: 如何卸载？**

```bash
npx ccg-workflow
# 选择 "卸载工作流"

# 如果之前用 npm install -g 安装过，还需执行：
npm uninstall -g ccg-workflow
```
**Q: Claude Code 任务超时？**

修改 `~/.claude/settings.json`：

```json
{
  "env": {
    "CODEX_TIMEOUT": "7200",
    "BASH_DEFAULT_TIMEOUT_MS": "600000",
    "BASH_MAX_TIMEOUT_MS": "3600000"
  }
}
```

变量

说明

`CODEX_TIMEOUT`

codeagent-wrapper 执行超时（秒），默认 7200

`BASH_DEFAULT_TIMEOUT_MS`

Bash 命令默认超时（毫秒）

`BASH_MAX_TIMEOUT_MS`

Bash 命令最大超时（毫秒）

**Q: Codex 任务卡住，获取不到结果？**

这是 Codex CLI 0.80.0 的已知 bug，`--json` 模式下进程完成输出后不会自动退出。

**解决方案**：设置环境变量让 codeagent-wrapper 检测到完成后 1 秒强制终止进程。

```bash
# Mac/Linux - 添加到 ~/.zshrc 或 ~/.bashrc
export CODEAGENT_POST_MESSAGE_DELAY=1

# Windows PowerShell - 添加到用户环境变量
[Environment]::SetEnvironmentVariable("CODEAGENT_POST_MESSAGE_DELAY", "1", "User")

# 或在 ~/.claude/settings.json 中配置
{
  "env": {
    "CODEAGENT_POST_MESSAGE_DELAY": "1"
  }
}
```

设置后重启终端生效。

* * *

## ![:folded_hands:](images/image_20__folded_hands_.png ":folded_hands:") 鸣谢

*   **[cexll/myclaude](https://github.com/cexll/myclaude)** - codeagent-wrapper 多后端调用工具
*   **[UfoMiao/zcf](https://github.com/UfoMiao/zcf)** - Git 工具 + MCP 配置逻辑
*   **[GudaStudio/skills](https://github.com/GuDaStudio/skills)** - 智能路由设计理念
*   **[ace-tool MCP](https://linux.do/t/topic/1344562)** - 代码检索和 Prompt 增强
*   **[linux.do 社区](https://linux.do/)** - Vibe Coding 技术交流社区

* * *

## ![:speech_balloon:](images/image_21__speech_balloon_.png ":speech_balloon:") 反馈

*   **GitHub Issues**: [Issues · fengshao1227/ccg-workflow · GitHub](https://github.com/fengshao1227/ccg-workflow/issues)
*   或者直接在下面回复

* * *

**版本**: v1.7.55 | **最后更新**: 2026-02-01