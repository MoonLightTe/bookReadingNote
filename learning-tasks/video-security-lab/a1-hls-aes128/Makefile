# ==============================================================================
# HLS AES-128 Lab 跨平台一键管理 Makefile (macOS / Linux / Windows Git-Bash)
# ==============================================================================

.PHONY: check gen-sample slice serve rip clean

# 跨平台系统探测
UNAME_S := $(shell uname -s 2>/dev/null || echo Windows)

check:
	@echo "🔍 正在进行跨平台依赖自检 [当前检测系统: $(UNAME_S)]..."
	@which ffmpeg >/dev/null 2>&1 && echo "  [OK] ffmpeg 就绪" || echo "  [!!] 缺失 ffmpeg: (macOS: 'brew install ffmpeg' | Ubuntu: 'sudo apt install ffmpeg' | Win: 'winget install Gyan.FFmpeg')"
	@which openssl >/dev/null 2>&1 && echo "  [OK] openssl 就绪" || echo "  [!!] 缺失 openssl"
	@which node >/dev/null 2>&1 && echo "  [OK] node 就绪" || echo "  [!!] 缺失 node"
	@which python3 >/dev/null 2>&1 && echo "  [OK] python3 就绪" || echo "  [!!] 缺失 python3"
	@echo "🎯 检查结束。若有标记 [!!] 的工具，请按指引补充安装。"

gen-sample:
	@echo "🎬 使用 FFmpeg 虚拟设备合成 10 秒 1080p 标准彩条与音频测试视频 (input.mp4)..."
	@ffmpeg -y -f lavfi -i testsrc=duration=10:size=1920x1080:rate=30 \
	  -f lavfi -i sine=frequency=1000:duration=10 \
	  -c:v libx264 -pix_fmt yuv420p -c:a aac input.mp4
	@echo "✅ input.mp4 生成完毕！"

slice:
	@echo "🔐 生成随机 16 字节密钥与 32 位 Hex IV..."
	@mkdir -p hls_enc
	@openssl rand 16 > hls_enc/enc.key
	@openssl rand -hex 16 > hls_enc/iv.txt
	@echo "http://localhost:3000/api/key" > enc.keyinfo
	@echo "hls_enc/enc.key" >> enc.keyinfo
	@cat hls_enc/iv.txt >> enc.keyinfo
	@echo "✂️ 执行跨平台标准加密切片 (HLS AES-128)..."
	@ffmpeg -y -i input.mp4 -c copy -hls_time 3 -hls_list_size 0 \
	  -hls_key_info_file enc.keyinfo -f hls hls_enc/index.m3u8
	@echo "✅ 加密切片就绪 -> hls_enc/index.m3u8"

serve:
	@npm install
	@node server.js

rip:
	@echo "🕵️ 启动红方自测：全自动逆向解密还原明文 MP4..."
	@python3 scripts/rip_hls.py --m3u8 http://localhost:3000/video/index.m3u8 --token "Bearer secret_token_123" --out recovered.mp4

clean:
	@rm -rf hls_enc dump_temp enc.keyinfo recovered.mp4 plain*.ts input.mp4
	@echo "🧹 临时测试数据已彻底清空"
