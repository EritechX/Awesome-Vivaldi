# 【GPT_Image_Playground】纯前端的 GPT-Image-2 API 调用 WebUI，参数齐全，功能完备，一上手就被吓到眩晕瘫坐，那一刻就像看到原子弹爆炸！

---

#### 本帖使用社区开源推广，符合推广要求。我申明并遵循社区要求的以下内容：

*   **我的帖子已经打上 [开源推广](/tag/2234-tag/2234) 标签：** 是
*   **我的开源项目完整开源，无未开源部分：** 是
*   **我的开源项目已链接认可 LINUX DO 社区：** 是
*   **我帖子内的项目介绍，AI生成、润色内容部分已截图发出：** 是
*   **以上选择我承诺是永久有效的，接受社区和佬友监督：** 是

_以下为项目介绍正文内容，AI生成、润色内容已使用截图方式发出_

* * *

# GPT Image Playground

一站式解决 `GPT-Image-2` 的 Image API / Response API 参数可视化调整、API 调用、输入与输出存储、输出复用等需求，支持多请求同时进行。

听不懂？

~~我给你最直接、最真相、最不绕弯、最扎心、最硬核、最干的一句话总结，保证稳稳地……~~

人话版：

**可以在这个纯前端网页中接入、使用你自己的 `GPT-Image-2` API（支持 Image API / Response API / fal.ai），还能存储和查看历史生成记录、一键复用当时的参数和参考图、一键将输出结果作为新一轮的参考图、自定义服务商（支持同步、异步任务）……**

**桌面端主界面**  

[![桌面端主界面](images/image_0_桌面端主界面.jpeg)

桌面端主界面2549×1242 196 KB

](https://cdn3.ldstatic.com/original/4X/8/b/a/8ba7b34bb5d69251001e222c1b145d8d4323b884.jpeg "桌面端主界面")

  

**任务详情与实际参数**  

[![任务详情与实际参数](images/image_1_任务详情与实际参数.jpeg)

任务详情与实际参数1920×936 122 KB

](https://cdn3.ldstatic.com/original/4X/b/b/2/bb21e4b33a85f8caa88688d92f1ed4fe8e0974d9.jpeg "任务详情与实际参数")

  

**桌面端批量选择**  

[![桌面端批量选择](images/image_2_桌面端批量选择.jpeg)

桌面端批量选择2549×1242 195 KB

](https://cdn3.ldstatic.com/original/4X/8/e/6/8e6e446824e859dda7bced52addec6c62acee671.jpeg "桌面端批量选择")

  

**桌面端 Agent 模式**  

[![桌面端 Agent 模式](images/image_3_桌面端 Agent 模式.jpeg)

桌面端 Agent 模式1920×936 152 KB

](https://cdn3.ldstatic.com/original/4X/0/6/4/064ba4df6d55f1cd6db4051271e6224cef6c9764.jpeg "桌面端 Agent 模式")

  

**移动端主界面**  

[![移动端主界面](images/image_4_移动端主界面.jpeg)

移动端主界面1440×3000 273 KB

](https://cdn3.ldstatic.com/original/4X/3/0/2/302f861c8648d6009efb14fccefa4708968dfaf7.jpeg "移动端主界面")

  

**移动端侧滑多选**  

[![移动端侧滑多选](images/image_5_移动端侧滑多选.jpeg)

移动端侧滑多选1440×3000 350 KB

](https://cdn3.ldstatic.com/original/4X/5/d/8/5d8d4078cf0f27b3408a39ab7774fc92f42368b4.jpeg "移动端侧滑多选")

  

**设置图像尺寸-自动**  

[![自动](images/image_6_自动.png)

自动583×705 23.1 KB

](https://cdn3.ldstatic.com/original/4X/6/6/3/6636c3ff6b8b711c6d485987efa16e2a012750cb.png "自动")

  

**设置图像尺寸-按比例**  

[![按比例](images/image_7_按比例.png)

按比例581×721 28.8 KB

](https://cdn3.ldstatic.com/original/4X/b/e/5/be5e6176fe9944588ea32c6289845d04405a04bb.png "按比例")

  

**设置图像尺寸-自定义宽高**  

[![自定义宽高](images/image_8_自定义宽高.png)

自定义宽高583×705 33.1 KB

](https://cdn3.ldstatic.com/original/4X/a/2/6/a2642d28e3491e4bd26b3178f9e200762b6890d8.png "自定义宽高")

此外，本项目还支持通过 URL 查询参数快捷填充配置，可以方便快捷地将 Vercel / GitHub Pages URL 或自部署的 URL 加入 New API 聊天应用:

```bash
https://gpt-image-playground.cooksleep.dev?apiUrl={address}&apiKey={key}
```

```bash
https://cooksleep.github.io/gpt_image_playground?apiUrl={address}&apiKey={key}
```

* * *

# 更多详情、部署方式见 GitHub：

[github.com](https://github.com/CookSleep/gpt_image_playground)

![](images/image_9_image_9.png)

### [GitHub - CookSleep/gpt\_image\_playground: 基于 OpenAI gpt-image-2 API 的图片生成与编辑工具](https://github.com/CookSleep/gpt_image_playground)

基于 OpenAI gpt-image-2 API 的图片生成与编辑工具

# 在线体验

> 如有调用非本地的 HTTP API 的需求，请使用 GitHub Pages 版本或自行部署，因为 `.dev` 域名要求页面本身及其加载的资源（的来源）均为 HTTPS。

*   Vercel 部署版本：  
    https://gpt-image-playground.cooksleep.dev
    
*   GitHub Pages 部署版本：  
    [GPT Image Playground](https://cooksleep.github.io/gpt_image_playground)
    

如果这个项目能帮到你，就给我点个 Star 吧！感谢你的支持！