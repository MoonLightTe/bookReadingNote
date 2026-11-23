# Stage 2: CENC 封装、DRM 代理与 OBS 硬件录屏防御 (P1-L2)

- **所属路线**：Phase 1 · Level 2（商用流媒体与硬件防录）
- **DAG 依赖**：前置为 `P1-L1`（HLS AES-128 基础）
- **预计耗时**：2 ~ 3 周
- **环境要求**：Shaka Packager, Node.js, Chrome, Edge (Windows/macOS), OBS Studio。

---

## 核心任务与行动指令
1. **ClearKey / CENC 打包**：
   ```bash
   packager \
     in=input.mp4,stream=video,output=video.mp4 \
     in=input.mp4,stream=audio,output=audio.mp4 \
     --enable_raw_key_encryption \
     --keys label=HD:key_id=10000000100010001000100000000001:key=20000000200020002000200000000002 \
     --mpd_output stream.mpd
   ```
2. **License 代理接口（Express.raw）**：
   使用 `express.raw({ type: '*/*', limit: '2mb' })` 原样转发 CDM 二进制 Challenge 与 License，绝不对二进制流做任何编码转换。
3. **OBS 录屏矩阵对比**：
   - Chrome (L3 软解) vs Windows Edge (PlayReady 硬件安全路径)。
   - 验证 Edge 下 OBS 录制区域是否呈现纯黑。
