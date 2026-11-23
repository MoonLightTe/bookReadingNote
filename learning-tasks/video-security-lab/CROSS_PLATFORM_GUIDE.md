# 跨平台（macOS / Linux / Windows）学习与环境协同指南

在音视频加密与系统安全对抗领域，**单一操作系统无法覆盖完整的攻防链路**：
* **路线 A（商用流媒体/算法层）**：天然具备跨平台特性（macOS/Linux/Windows 均可无缝运行）；
* **路线 B（内核驱动/底层逆向层）**：重度绑定 **Windows x64 物理机或专用虚拟机**。

为了确保你在 **macOS、Ubuntu/Debian Linux 以及 Windows** 之间切换时拥有**一致、丝滑、无坑**的学习体验，本文档制定跨平台协同规范与环境适配指南。

---

## 一、 跨平台环境支持矩阵

| 学习阶段 / 技术栈 | macOS (Apple Silicon / Intel) | Linux (Ubuntu 22.04 / Debian) | Windows 10/11 (Host / VM) | 推荐首选环境 |
| :--- | :---: | :---: | :---: | :--- |
| **Stage 1: HLS AES-128** | 🟢 原生支持 (`brew`) | 🟢 原生支持 (`apt`) | 🟢 原生支持 (`winget` / Git Bash) | **任意系统均可** (Mac/Linux 最丝滑) |
| **Stage 2: CENC & DRM** | 🟢 支持 (FairPlay / ClearKey) | 🟢 支持 (ClearKey) | 🟢 最佳 (支持 PlayReady 硬件黑屏) | **Windows** (测黑屏录制必用) |
| **Stage 3: 频域 DCT 水印** | 🟢 原生支持 (`pip`) | 🟢 原生支持 (`pip`) | 🟢 原生支持 (`pip`) | **Mac / Linux** (Python 算力高效) |
| **Stage 4: 内存读写 & Frida** | 🟡 受 SIP / 架构限制 | 🟡 调试机制不同 (ptrace) | 🟢 核心靶场 (Win32 API / x64dbg) | **Windows** (x64 架构) |
| **Stage 5: 内核回调完整性** | 🔴 不支持 (XNU 内核不同) | 🔴 不支持 (eBPF/LSM 不同) | 🟢 唯一靶场 (WDK / WinDbg / 1703 VM) | **Windows 10 1703 虚拟机** |
| **Stage 6: AVIOContext 播放器** | 🟢 可编译运行 (C++ / POSIX) | 🟢 可编译运行 (GCC / Make) | 🟢 最佳 (带 ProcMon 零落盘审计) | **Windows** (配合微软官方 ProcMon) |
| **Stage 7: OLLVM 混淆代价** | 🟢 可交叉编译 | 🟢 编译工具链最方便 | 🟢 运行测试 | **Linux 编译 $\rightarrow$ Win/Mac 测帧率** |

---

## 二、 基础依赖三端一键安装指南

### 1. macOS (Homebrew 体系)
```bash
# 核心音视频与加解密工具链
brew install ffmpeg openssl node python@3.11 make

# 跨平台代码与调试辅助
brew install --cask vlc visual-studio-code
```

### 2. Linux (Ubuntu / Debian APT 体系)
```bash
sudo apt update
sudo apt install -y \
    ffmpeg \
    openssl \
    nodejs \
    npm \
    python3 \
    python3-pip \
    python3-venv \
    build-essential \
    vlc

# 安装跨平台 Python 图像与科学计算依赖
pip3 install opencv-python-headless numpy matplotlib requests
```

### 3. Windows (Winget / Scoop / 开发者模式)
> [!TIP]
> 推荐在 Windows 上安装 **Git Bash** 或 **WSL2**，以便无缝运行项目中的 `Makefile` 与 shell 命令。

```powershell
# 以管理员身份打开 PowerShell
winget install Gyan.FFmpeg
winget install OpenSSL.Light
winget install OpenJS.NodeJS.LTS
winget install Python.Python.3.11
winget install VideoLAN.VLC
winget install Microsoft.VisualStudioCode

# 路线 B 必备的微软官方逆向与审计套件
winget install Microsoft.Sysinternals.ProcessMonitor
winget install Microsoft.WinDbg
```

---

## 三、 消除跨平台摩擦的关键规范（踩坑预防）

### 1. 换行符与文件编码（CRLF vs LF）
* **风险点**：在 Windows 下创建的 `enc.keyinfo` 文件若带有 Windows 换行符 `\r\n`，在 Mac/Linux 运行 FFmpeg 时，会把 `\r` 当作密钥路径或 URI 的一部分，导致静默退化或报 `No such file or directory`。
* **统一规范**：所有文件（代码、Markdown、配置）**一律强制使用 LF（Unix 换行）与 UTF-8 无 BOM 编码**。
* **Git 全局配置**：
  ```bash
  git config --global core.autocrlf input
  ```

### 2. Windows 运行 Makefile 方案
`a1-hls-aes128/Makefile` 使用了标准 Unix 工具命令（`cat`, `rm -rf`, `which` 等）。
* **在 Mac / Linux 上**：直接在终端输入 `make <target>`；
* **在 Windows 上**：
  * **推荐做法**：使用 **Git for Windows** 自带的 `Git Bash` 运行 `make`（若缺失 make，可通过 `winget install ezwinports.make` 或在 WSL2 中执行）。

### 3. 路线 B（内核与内存对抗）跨平台虚拟化推荐拓扑
如果你日常使用 **macOS 或 Linux 作为主力工作机**，切入路线 B 时的最佳实践方案：

```mermaid
flowchart TD
    Host["主力机 (macOS / Linux / Windows 宿主)"] -->|代码编辑 / 文档梳理| SharedRepo["bookReadingNote 工作区 (Git 共享)"]
    Host -->|VMware Fusion / VirtualBox / KVM| VM["Windows 10 1703 x64 专用测试隔离虚拟机"]
    VM -->|环境配置| VMSettings["1. testsigning on<br>2. 关闭 HVCI<br>3. 安装 WDK + WinDbg"]
    Host -.->|KDNET 网络调试 (端口 50000)| VM
```

* **安全红线**：所有针对 `ObRegisterCallbacks` 篡改、BYOVD 模拟驱动、`WriteProcessMemory` 攻击测试，**必须在快照备份的隔离虚拟机中进行**，严禁在个人日常工作物理系统上测试未经签名的内核驱动。

---

## 四、 跨平台同步与状态一致性保障

无论你在哪台设备上阅读笔记或写代码：
1. **环境自检第一步**：进入任何模块目录，先运行：
   ```bash
   make check
   ```
   它会自动嗅探当前系统平台缺失的 CLI 依赖，并给出对应平台的安装建议。
2. **Git 留痕心法**：
   在不同设备交替开发时，保持“一个模块一个分支或一个明确提交”；临时文件（如生成的 `input.mp4`、`hls_enc/` 切片、`dump_temp/`）已被 `.gitignore` 排除，不会引起跨平台脏树冲突。
