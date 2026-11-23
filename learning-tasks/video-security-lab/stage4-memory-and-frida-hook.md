# Stage 4: 内存读写对抗与解码最后一公里截流 (P2-L4A)

- **所属路线**：Phase 2 · Level 4-Attack（红方渗透）
- **DAG 依赖**：前置为 `P1-L1`（HLS 基础）；本模块为 `P2-L4D`（Stage 6 内存解密播放器）提供攻防检验靶标
- **预计耗时**：2 周
- **环境要求**：Windows 10+（或 macOS/Linux，Frida 支持全平台），Visual Studio 2022 / Clang，x64dbg / LLDB，Frida。

---

## 攻防对抗核心逻辑
作为红方攻击者，绕过所有网络层 HTTPS 与 DRM 传输加密，直接在解码器准备解压裸流的“最后一公里”（`avcodec_send_packet`）处截获明文 `AVPacket`。
**通关目标**：亲手写出自动化 Frida Hook 脚本，把播放器中的裸流导出为可播放的 MP4，作为下游自研防御播放器（Stage 6）必须击退的攻击标靶。

---

## 核心任务与行动指令
1. **用户态内存读写**：
   - 编写 `Target.exe` 与 `Hack.exe`（`OpenProcess` + `WriteProcessMemory`）；
   - x64dbg 动态打补丁改汇编分支。
2. **Frida 挂钩解码器入口截流**：
   - 编写 Frida 脚本挂钩 `avcodec_send_packet`；
   - 从 `AVPacket` 结构体指针读取 `data` 与 `size`，流式导出 `dumped.h264` 并用 FFmpeg 重新封装为 MP4。
