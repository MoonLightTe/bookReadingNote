# Stage 6: 私有 AVIOContext 内存解密播放器

- **所属路线**：路线 B · 模块 B3
- **预计耗时**：2 周
- **环境要求**：C++, FFmpeg 开发库, OpenSSL, Process Monitor (ProcMon)。

---

## 核心任务与行动指令
1. **AES-256-CTR 分块离线加密**：
   - 摒弃 CBC，选用 CTR 计数器模式，按 64KB 为一个逻辑块加密测试视频。
2. **自定义 AVIOContext 回调挂载**：
   - 实现 `ReadPacketCallback`（解密到临时 buffer，用完立即 `SecureZeroMemory`）；
   - 实现 `SeekCallback`（准确推导 CTR 计数器大端序偏移，避免拖动花屏）。
3. **零落盘合规审计**：
   - 使用 ProcMon 过滤监控进程 `WriteFile` 行为，确保全程无任何明文数据落盘。
