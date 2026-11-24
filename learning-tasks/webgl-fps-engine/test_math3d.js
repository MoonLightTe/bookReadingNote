#!/usr/bin/env node
/**
 * test_math3d.js - W1 节点数学核 TDD 红灯测试脚手架
 * 运行命令: node learning-tasks/webgl-fps-engine/test_math3d.js
 */

const assert = require("assert");
const { Vector3, Matrix4 } = require("./math3d.js");

console.log("🚀 [W1 TDD 测试] 开始验证 3D 线性代数数学核...");

// 1. Vector3 测试
try {
    const v1 = new Vector3(1, 0, 0);
    const v2 = new Vector3(0, 1, 0);
    
    // 正交向量点积为 0
    const dotProduct = v1.dot(v2);
    assert.strictEqual(dotProduct, 0, "正交单位向量点乘必须为 0");
    console.log("  ✅ Vector3.dot 正交检验通过");
} catch (err) {
    console.error("  🔴 [FAIL] Vector3.dot 失败:", err.message);
}

try {
    const v1 = new Vector3(1, 0, 0); // X轴
    const v2 = new Vector3(0, 1, 0); // Y轴
    const v3 = new Vector3();
    v3.crossVectors(v1, v2);         // X x Y 应为 Z轴 (0, 0, 1)
    
    assert.strictEqual(v3.x, 0);
    assert.strictEqual(v3.y, 0);
    assert.strictEqual(v3.z, 1);
    console.log("  ✅ Vector3.crossVectors 右手法则通过 (X x Y = Z)");
} catch (err) {
    console.error("  🔴 [FAIL] Vector3.crossVectors 失败:", err.message);
}

// 2. Matrix4 测试
try {
    const m1 = new Matrix4();
    m1.makeTranslation(10, 20, 30);
    // 列优先存储中，平移分量位于索引 12, 13, 14
    assert.strictEqual(m1.elements[12], 10, "Tx 平移分量应为 10");
    assert.strictEqual(m1.elements[13], 20, "Ty 平移分量应为 20");
    assert.strictEqual(m1.elements[14], 30, "Tz 平移分量应为 30");
    console.log("  ✅ Matrix4.makeTranslation 平移矩阵通过");
} catch (err) {
    console.error("  🔴 [FAIL] Matrix4.makeTranslation 失败:", err.message);
}

console.log("\n🎯 目标：修改 math3d.js，实现上述数学函数，直至所有测试项全部显示 ✅！");
