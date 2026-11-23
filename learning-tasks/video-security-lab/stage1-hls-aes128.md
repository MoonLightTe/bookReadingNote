# Stage 1: HLS AES-128 全栈贯通与明文密钥失效边界

- **所属路线**：路线 A · 模块 A1
- **预计耗时**：1 ~ 2 周
- **环境要求**：macOS / Linux / Windows，已安装 `ffmpeg`、`openssl`、`node (v18+)`、VLC 播放器。
- **配套工程代码**：[a1-hls-aes128/](file:///Users/qiyue/code/learn/bookReadingNote/learning-tasks/video-security-lab/a1-hls-aes128/)

---

## 一、 核心目标与产物
1. 构建全链路 HLS AES-128 加密切片流水线；
2. 搭建基于 Bearer Token 鉴权的 Node.js 密钥分发网关与前端 HLS.js 播放器；
3. 以红方视角从网络流量提取密钥，逆向解密切片并合并还原出完整明文 MP4；
4. 记录破解耗时与安全性边界。

> [!TIP]
> ⚡ **极速工作流 (Makefile)**：工程内已配置 `Makefile`，若想跳过繁琐的手工参数拼装，可直接使用以下命令：
> - `make check`：环境自检（检查 ffmpeg/openssl/node）
> - `make gen-sample`：无需网上找视频，利用 FFmpeg 虚拟设备自动合成 10 秒 1080p 标准彩条与音频测试片源 `input.mp4`
> - `make slice`：全自动生成随机 Key/IV、构造 `enc.keyinfo` 并完成加密切片
> - `make serve`：启动鉴权服务与播放器
> - `make rip`：一键触发红方破解并输出 `recovered.mp4`
> - `make clean`：一键清空实验中间切片与转储文件

---

## 二、 逐步行动指引

### Day 1：加密切片与本地止损校验
1. 进入工程目录：
   ```bash
   cd learning-tasks/video-security-lab/a1-hls-aes128
   ```
2. 准备一段 1080p 本地测试视频 `input.mp4`（30~60 秒）。
3. 生成 16 字节密钥与 32 位 Hex IV：
   ```bash
   mkdir -p hls_enc
   openssl rand 16 > hls_enc/enc.key
   openssl rand -hex 16 > hls_enc/iv.txt
   ```
4. 编写 `enc.keyinfo`（严格 3 行）：
   ```text
   http://localhost:3000/api/key
   hls_enc/enc.key
   <填入 iv.txt 中的 32 位 Hex 字符>
   ```
5. 执行 FFmpeg 切片：
   ```bash
   ffmpeg -i input.mp4 -c copy -hls_time 6 -hls_list_size 0 \
     -hls_key_info_file enc.keyinfo -f hls hls_enc/index.m3u8
   ```
6. **🛑 止损判据**：用 VLC 播放器打开 `hls_enc/index0.ts`，**必须报错或黑屏无法播放**。若能正常播放，说明加密未生效，严禁进入下一阶段。

---

### Day 2：Node.js 鉴权网关
1. 安装依赖并启动服务：
   ```bash
   npm install
   node server.js
   ```
2. 接口自测：
   * `curl -i http://localhost:3000/api/key` $\rightarrow$ 必须返回 `403 Forbidden`。
   * `curl -i -H "Authorization: Bearer secret_token_123" http://localhost:3000/api/key` $\rightarrow$ 必须返回 `200 OK` 且内容为 16 字节二进制。

---

### Day 3：前端 HLS.js 挂载与播放
1. 浏览器访问 `http://localhost:3000/index.html`。
2. 验证：
   * 视频正常起播、进度条拖动正常；
   * F12 Network 中可见针对 `/api/key` 的请求携带了 `Authorization: Bearer secret_token_123` 头。

---

### Day 4–5：红方自测与自动化提取脚本
1. 在 Network 面板中提取 16 字节响应保存为 Hex 字符串。
2. 命令行手动单片解密验证：
   ```bash
   openssl aes-128-cbc -d -K <KeyHex> -iv <IVHex> -in hls_enc/index0.ts -out plain0.ts
   ```
3. 用 VLC 打开 `plain0.ts` 确认已解密。
4. 运行配套的自动化爬取还原脚本 `scripts/rip_hls.py` 自动化完成批量提取与 MP4 封装。

---

## 三、 结项验收记录表

| 评估维度 | 指标项 | 实测结果 | 结论判定 |
| :--- | :--- | :--- | :--- |
| **破解时效** | 拿到 URL 到还原出明文 MP4 | ______ 分钟 | 防御层级仅限未授权访客与基础爬虫 |
| **性能体验** | 起播延迟增量 | ______ ms | 对正常播放体验影响极小 |
| **失效边界** | 关键失效条件 | 任何已登录并能拿到 Token 的客户端均可直接解密全量视频 |
