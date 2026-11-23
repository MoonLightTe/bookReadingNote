#!/usr/bin/env python3
"""
rip_hls.py - 模拟红方攻击者批量下载、解密并合成 HLS AES-128 视频
用法: python3 rip_hls.py --m3u8 http://localhost:3000/video/index.m3u8 --token "Bearer secret_token_123"
"""

import os
import sys
import argparse
import subprocess
import requests
from urllib.parse import urljoin

def main():
    parser = argparse.ArgumentParser(description="HLS AES-128 红方离线解密转储工具")
    parser.add_argument("--m3u8", required=True, help="目标 m3u8 播放地址")
    parser.add_argument("--token", required=True, help="认证 Token (例如: 'Bearer secret_token_123')")
    parser.add_argument("--out", default="hacked_output.mp4", help="导出的明文 MP4 文件名")
    args = parser.parse_args()

    work_dir = "dump_temp"
    os.makedirs(work_dir, exist_ok=True)

    print(f"[*] 1. 获取 m3u8 索引: {args.m3u8}")
    headers = {"Authorization": args.token}
    res = requests.get(args.m3u8)
    if res.status_code != 200:
        print(f"[-] 获取 m3u8 失败: HTTP {res.status_code}")
        sys.exit(1)

    lines = res.text.splitlines()
    key_uri = None
    iv_hex = None
    ts_urls = []

    for line in lines:
        line = line.strip()
        if line.startswith("#EXT-X-KEY"):
            # 解析 KEY 属性: METHOD=AES-128,URI="...",IV=0x...
            parts = line.split(",")
            for p in parts:
                if "URI=" in p:
                    key_uri = p.split('URI="')[1].rstrip('"')
                elif "IV=" in p:
                    iv_hex = p.split("IV=")[1].replace("0x", "")
        elif line and not line.startswith("#"):
            full_ts_url = urljoin(args.m3u8, line)
            ts_urls.append(full_ts_url)

    if not key_uri:
        print("[-] 未在 m3u8 中找到加密密钥标签 #EXT-X-KEY")
        sys.exit(1)

    print(f"[+] 发现密钥地址: {key_uri}")
    print(f"[+] 发现 IV: {iv_hex}")
    print(f"[+] 发现切片数量: {len(ts_urls)}")

    print(f"[*] 2. 携带 Token 请求真实密钥...")
    key_res = requests.get(key_uri, headers=headers)
    if key_res.status_code != 200:
        print(f"[-] 下载密钥失败: HTTP {key_res.status_code}")
        sys.exit(1)

    key_bytes = key_res.content
    key_hex = key_bytes.hex()
    print(f"[+] 成功捕获密钥 (Hex): {key_hex}")

    print(f"[*] 3. 并发/逐片下载与 OpenSSL AES-128-CBC 解密...")
    plain_files = []
    for idx, ts_url in enumerate(ts_urls):
        enc_file = os.path.join(work_dir, f"enc_{idx}.ts")
        plain_file = os.path.join(work_dir, f"plain_{idx}.ts")

        # 下载切片
        r = requests.get(ts_url)
        with open(enc_file, "wb") as f:
            f.write(r.content)

        # 解密切片
        # 若 m3u8 未显式指定 IV，规范规定为切片序列号大端序 16 字节
        curr_iv = iv_hex if iv_hex else f"{idx:032x}"
        cmd = [
            "openssl", "aes-128-cbc", "-d",
            "-K", key_hex,
            "-iv", curr_iv,
            "-in", enc_file,
            "-out", plain_file
        ]
        ret = subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if ret.returncode != 0:
            print(f"[-] 解密切片 {idx} 失败")
            sys.exit(1)

        plain_files.append(plain_file)
        print(f"    -> 切片 {idx+1}/{len(ts_urls)} 解密完成")

    print(f"[*] 4. 使用 FFmpeg 合并为明文 MP4: {args.out}")
    concat_list_file = os.path.join(work_dir, "concat.txt")
    with open(concat_list_file, "w") as f:
        for p in plain_files:
            f.write(f"file '{os.path.abspath(p)}'\n")

    merge_cmd = [
        "ffmpeg", "-y", "-f", "concat", "-safe", "0",
        "-i", concat_list_file, "-c", "copy", args.out
    ]
    subprocess.run(merge_cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    print(f"\n=======================================================")
    print(f"🎉 攻击完成！明文视频已还原至: {args.out}")
    print(f"=======================================================")

if __name__ == "__main__":
    main()
