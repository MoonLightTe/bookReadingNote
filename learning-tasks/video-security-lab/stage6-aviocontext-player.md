# Stage 6: 私有 AVIOContext 内存解密播放器 (P2-L4D)

- **所属路线**：Phase 2 · Level 4-Defense（蓝方筑防）
- **DAG 依赖**：强依赖 `P2-L4A`（Stage 4 Frida 截流）；为 `P3-L5`（Stage 7 OLLVM 混淆）提供二进制代码载体
- **预计耗时**：2 周
- **环境要求**：C++, FFmpeg 开发库 (libavformat / libavcodec), OpenSSL (AES-256-CTR), Process Monitor (ProcMon) 或 macOS fs_usage。

---

## 攻防对抗核心逻辑
作为蓝方防守者，反制 Stage 4 (P2-L4A) 的截流威胁。
通过私有 `AVIOContext` 将解密过程完全内聚在播放器内存回调中，做到**“分块按需解密、内存用完即抹（SecureZeroMemory）、全程绝对零落盘”**。
**通关目标**：运行自己在 Stage 4 写出的 Frida 脚本，验证其无法在磁盘嗅探到明文缓存，且内存中的明文暴露窗口缩短至微秒级；拖动进度条无解码花屏。

---

## 核心任务与行动指令
1. **AES-256-CTR 分块离线加密**：
   - 摒弃 CBC，选用 CTR 计数器模式，按 64KB 为一个逻辑块加密测试视频。
2. **自定义 AVIOContext 回调挂载**：
   - 实现 `ReadPacketCallback`（解密到临时 buffer，用完立即 `SecureZeroMemory`）；
   - 实现 `SeekCallback`（准确推导 CTR 计数器大端序偏移，避免拖动花屏）。
3. **零落盘合规审计**：
   - 使用 ProcMon 过滤监控进程 `WriteFile` 行为，确保全程无任何明文数据落盘。
