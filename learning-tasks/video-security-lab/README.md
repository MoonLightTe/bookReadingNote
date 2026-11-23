# 视频加密与防盗录攻防实战任务库 (video-security-lab)

本任务库整合了底层音视频安全攻防原理、商用零驱动流媒体安全架构（路线 A）与系统内核级逆向对抗（路线 B），旨在通过“动手造轮子、红蓝双向验证、测量硬性指标”建立专家级防护体系认知。

> [!NOTE]
> 📖 **方案核心设计哲学与决策背景**：详见核心留档文档 [WHY_AND_DESIGN_RATIONALE.md](file:///Users/qiyue/code/learn/bookReadingNote/learning-tasks/video-security-lab/WHY_AND_DESIGN_RATIONALE.md)。该文档完整阐述了：为什么要做这套体系（**四大目的**）、底层三大攻防原理底座、前两版方案为何不可行、各阶段技术选型背后的第一性原理与被舍弃的替代方案。
>
> 💻 **跨设备学习指南（Win / Linux / Mac）**：详见 [CROSS_PLATFORM_GUIDE.md](file:///Users/qiyue/code/learn/bookReadingNote/learning-tasks/video-security-lab/CROSS_PLATFORM_GUIDE.md)。提供了三大系统的包管理一键安装脚本、换行符防坑指南、以及主力机（Mac/Linux）与 Windows 内核隔离虚拟机的协同拓扑。

---

## 核心设计之四大目的

1. **突破跨界断层**：打通“音视频流媒体管线”与“底层二进制逆向”的技术鸿沟。
2. **红蓝双向闭环**：不仅会筑防，更要亲手用渗透脚本击穿防线，告别虚妄安全感。
3. **三维度量淘汰**：从二元对错转向“绕过耗时、性能损耗、失效边界”的量化决策。
4. **沉淀工业级资产**：构建生产可参考的代码底座与选型权衡库，避开玩具代码陷阱。

---

## 目录索引与模块导航

| 阶段 / 模块 | 核心主题 | 技术栈 | 交付状态 | 入口指引 |
| :--- | :--- | :--- | :---: | :--- |
| **Stage 1 (A1)** | HLS AES-128 全栈与明文密钥失效边界 | FFmpeg, OpenSSL, Node.js, HLS.js | 🟢 已就绪 (可运行) | [Stage 1 任务说明](file:///Users/qiyue/code/learn/bookReadingNote/learning-tasks/video-security-lab/stage1-hls-aes128.md) |
| **Stage 2 (A2)** | CENC 封装、DRM 代理与 OBS 录屏防御 | Shaka Packager, EME, ClearKey/Axinom, OBS | ⚪ 规划中 | [Stage 2 任务说明](file:///Users/qiyue/code/learn/bookReadingNote/learning-tasks/video-security-lab/stage2-cenc-drm.md) |
| **Stage 3 (A3)** | 频域 DCT 水印与 ORB+RANSAC 透视校正 | Python, OpenCV, DCT/SVD, Matplotlib | ⚪ 规划中 | [Stage 3 任务说明](file:///Users/qiyue/code/learn/bookReadingNote/learning-tasks/video-security-lab/stage3-dct-watermark.md) |
| **Stage 4 (B1)** | 内存读写对抗与解码最后一公里截流 | C++, x64dbg, IDA Pro, Frida | ⚪ 规划中 | [Stage 4 任务说明](file:///Users/qiyue/code/learn/bookReadingNote/learning-tasks/video-security-lab/stage4-memory-and-frida-hook.md) |
| **Stage 5 (B2)** | Windows 内核只读枚举与回调完整性防御 | C, WDK, WinDbg, KDNET (Win10 1703) | ⚪ 规划中 | [Stage 5 任务说明](file:///Users/qiyue/code/learn/bookReadingNote/learning-tasks/video-security-lab/stage5-kernel-callbacks.md) |
| **Stage 6 (B3)** | 私有 AVIOContext 内存解密播放器 | C++, FFmpeg Libav, OpenSSL AES-CTR, ProcMon | ⚪ 规划中 | [Stage 6 任务说明](file:///Users/qiyue/code/learn/bookReadingNote/learning-tasks/video-security-lab/stage6-aviocontext-player.md) |
| **Stage 7 (B4)** | OLLVM 代码混淆与 1080p 性能淘汰线 | Clang OLLVM, C++, 性能分析 | ⚪ 规划中 | [Stage 7 任务说明](file:///Users/qiyue/code/learn/bookReadingNote/learning-tasks/video-security-lab/stage7-ollvm-benchmarking.md) |

---

## 核心推进原则与度量标准

每完成一个模块，严禁仅以“代码跑通了”为标准，必须在各自模块的结项报告中如实记录以下 3 项量化指标：
1. **绕过时间（Bypass Time）**：从攻击者拿到目标文件/URL 开始，到产出可播放明文 MP4 所消耗的精确分钟数。
2. **性能与体验代价（Overhead）**：CPU 增量、内存增量、1080p 60fps 帧率下降值、起播延迟（ms）。
3. **失效边界（Failure Boundary）**：记录在何种物理或软件条件下，该防御机制会发生静默失效。
