# Stage 4: 内存读写对抗与解码最后一公里截流

- **所属路线**：路线 B · 模块 B1
- **预计耗时**：2 周
- **环境要求**：Windows 10+, Visual Studio 2022, x64dbg, IDA Pro, Frida。

---

## 核心任务与行动指令
1. **用户态内存读写**：
   - 编写 `Target.exe` 与 `Hack.exe`（`OpenProcess` + `WriteProcessMemory`）；
   - x64dbg 动态打补丁改汇编分支。
2. **Frida 挂钩解码器入口截流**：
   - 编写 Frida 脚本挂钩 `avcodec_send_packet`；
   - 从 `AVPacket` 结构体指针读取 `data` 与 `size`，流式导出 `dumped.h264` 并用 FFmpeg 重新封装为 MP4。
