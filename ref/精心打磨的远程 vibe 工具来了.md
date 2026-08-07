# 精心打磨的远程 vibe 工具来了

---

#### 本帖使用社区开源推广，符合推广要求。我申明并遵循社区要求的以下内容：

*   **我的帖子已经打上 [开源推广](/tag/2234-tag/2234) 标签：** 是
*   **我的开源项目完整开源，无未开源部分：** 是
*   **我的开源项目已链接认可 LINUX DO 社区：** 是
*   **我帖子内的项目介绍，AI生成、润色内容部分已截图发出：** 是
*   **以上选择我承诺是永久有效的，接受社区和佬友监督：** 是

_以下为项目介绍正文内容，AI生成、润色内容已使用截图方式发出_

* * *

[github.com](https://github.com/a9gent/mindfs)

![](images/image_0_image_0.png)

### [GitHub - a9gent/mindfs: Access your personal AI agents and workstation...](https://github.com/a9gent/mindfs)

Access your personal AI agents and workstation data anywhere, anytime through MindFS.

* * *

## 欢迎佬友们反馈

## 我的刚需

*   必须可以远程随时随地vibe
*   主流agent都要支持
*   agent电脑上的文件访问
*   远程时能随时拉起历史session继续
*   必须自托管，没有relay我用ip:port一样可以访问
*   能远程添加本地/github/空白项目/worktree
*   app锁屏通知提醒任务完成

## 缘由

去年vibe停不下来，试过各种远程vibe的姿势，都很让人抓狂，包括 happy 这种。  
年初只有一个模糊的想法，主要诉求就上面几点，改了很多版，才逐渐把交互稳定下来。  
这一个多月收了一些反馈，问题也基本收敛。

## 得意的几点设计

*   输入框蓝点左滑新建 session
*   统一上下文，一个 session 中随时切换 agent，特别适合互相 review 的。
*   文件和会话双向关联：文件被那些 session 修改，session 修改了那些文件。
*   独立relay：定制的 relay服务器，作为远程vibe 的可选项。
*   抽屉会话，随时弹出/收起，这点在文件和 session 之间切换时特别方便。
*   项目后端用 go 开发，安装包不到 10M，codex 和 cc 用了 go sdk 接入，而不是 acp 协议转换，接近原生体验了。

## 界面预览

[![mindfs-desktop](images/image_1_mindfs-desktop.webp "桌面端")

桌面端3732×2702 546 KB

](https://cdn3.ldstatic.com/original/4X/f/3/6/f369ec9cd15866a5751e0817f43404642f1aa797.webp "桌面端")

[![mindfs-mibile](images/image_2_mindfs-mibile.webp "移动端")

移动端5222×2738 856 KB

](https://cdn3.ldstatic.com/original/4X/b/d/5/bd5b9fbc99a31dd993a023f710c654edc65a49c3.webp "移动端")

* * *

## 一些重要的更新

*   agent 配置备份和切换，替代 cc-switch 部分功能
*   命令执行模式，快速执行非交互命令
*   codex 的 /goal，subagent
*   worktree 创建和切换
*   agent 定时任务
*   更加完善的交互：消息排队，完整toolcall
*   流行 agent 可从前端安装更新
*   自定义支持 acp 的agent

## 核心场景

*   服务器上安装，走美国家宽代理，远程访问，避免 claude 封号
*   工作电脑安装，通过内置 relay/tailscale 等通道，随时随地开始 vibe，不用在带电脑了
*   公司服务器安装，通过 e2ee 保护走局域网访问
*   替代 codex/cc 桌面端，当然这个看使用习惯

## 其他

*   更新基本是一周一两版的节奏
*   后续会聚焦agent 环境不在身边，需要远程 vibe的场景。
*   用户反馈太重要了，根据反馈最近一版加了 agent 配置备份和切换，用来多账号切换发现真香。