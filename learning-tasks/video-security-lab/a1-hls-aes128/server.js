const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = 3000;

app.use(cors());

// 1. 静态托管切片文件与前端播放页面
app.use(express.static(path.resolve(__dirname, 'public')));
app.use('/video', express.static(path.resolve(__dirname, 'hls_enc')));

// 2. 密钥分发接口（校验 Bearer Token）
app.get('/api/key', (req, res) => {
    const authHeader = req.headers['authorization'];
    const expectedToken = 'Bearer secret_token_123';

    if (!authHeader || authHeader !== expectedToken) {
        console.warn(`[AUTH_BLOCK] 拦截未授权密钥请求 | IP: ${req.ip}`);
        return res.status(403).send('Forbidden: Invalid or Missing Token');
    }

    const keyPath = path.resolve(__dirname, 'hls_enc', 'enc.key');
    if (!fs.existsSync(keyPath)) {
        console.error(`[ERROR] 密钥文件未生成: ${keyPath}`);
        return res.status(500).send('Internal Server Error: Key Not Found');
    }

    console.log(`[AUTH_SUCCESS] 鉴权通过，下发 enc.key | IP: ${req.ip}`);
    res.setHeader('Content-Type', 'application/octet-stream');
    res.sendFile(keyPath);
});

app.listen(PORT, () => {
    console.log(`==================================================`);
    console.log(` HLS AES-128 Lab Server 运行中`);
    console.log(` 访问地址: http://localhost:${PORT}/index.html`);
    console.log(` 切片托管: http://localhost:${PORT}/video/index.m3u8`);
    console.log(`==================================================`);
});
