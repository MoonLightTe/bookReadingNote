# 阶段一实战任务：数学筑基与 WebGL2 渲染管线 (第 1 - 5 周)

> **目标**：剥离所有 3D 引擎黑盒，亲手推导并实现空间变换矩阵与原生 WebGL2 绘制管线，彻底搞懂从三维顶点到屏幕二维像素的数学机理。

---

## 📚 对应阅读章节与理论输入

1. **《GAMES101: 现代计算机图形学入门》（闫令琪）**
   * 第 1 讲：图形学概览
   * 第 2 讲：向量与线性代数（点乘、叉乘的物理与几何含义）
   * 第 3-4 讲：三维变换（旋转、缩放、仿射变换、四元数概念、齐次坐标、视图与投影矩阵）
2. **《WebGL 编程指南》（松田晃一）**
   * 第 1-4 章：WebGL 入门、绘制点线面、着色器通信（Attribute 与 Uniform）
   * 第 7 章：三维空间（观察点、视锥体、可见深度与深度缓冲区 Z-buffer）

---

## 🛠️ 动手实操任务清单

### 任务 1.1：从零手写 3D 线性代数核心库
* **任务描述**：不依赖任何现成数学库（如 glMatrix、Three.js），在单个 JS 文件中手写以下核心类：
  1. `Vector3`：向量加减、标量乘法、点积 `dot`、叉积 `crossVectors`、模长计算与归一化 `normalize`。
  2. `Matrix4`：$4 \times 4$ 齐次变换矩阵乘法、平移矩阵 `makeTranslation`、缩放矩阵 `makeScale`、旋转矩阵 `makeRotationX/Y/Z`。
  3. `Matrix4.prototype.makeLookAt(eye, target, up)`：根据相机位置、观察点和上方向，推导生成摄像机观察矩阵（View Matrix）。
  4. `Matrix4.prototype.makePerspective(fov, aspect, near, far)`：推导生成透视投影矩阵（Perspective Matrix）。
* **验收标准**：
  * 编写单元测试或测试脚本，验证两个矩阵相乘的结果与标准数学公式一致。
  * 验证点积判定正反视野、叉积判定左右方位的正确性。

---

### 任务 1.2：用 HTML5 2D Canvas 手写纯软件光栅化器 (Software Rasterizer)
* **任务描述**：
  * 使用 HTML5 原生 2D Canvas（`getContext('2d')`），**完全不用 WebGL**。
  * 定义一个三维立方体的 8 个顶点坐标。
  * 使用你在任务 1.1 中手写的 `Matrix4`，构建 `MVP = Projection * View * Model` 复合矩阵。
  * 对 8 个顶点应用 MVP 矩阵变换，执行**透视除法**（$x/w, y/w$），将其映射到 Canvas 屏幕像素坐标 $(x_{screen}, y_{screen})$。
  * 用 2D Canvas 的 `lineTo()` 绘制出旋转的 3D 线框立方体。
* **验收标准**：
  * 在浏览器中看到一个正在平滑自转的透视 3D 立方体线框，支持通过键盘 WASD 移动相机位置，画面产生正确的近大远小透视变换。

---

### 任务 1.3：原生 WebGL 2 白板绘制彩色立体旋转多面体
* **任务描述**：
  * 不使用任何封装库，直接调用原生 WebGL 2 API（`gl = canvas.getContext('webgl2')`）。
  * 手写 GLSL 顶点着色器（Vertex Shader）与片元着色器（Fragment Shader）。
  * 建立顶点数组对象（VAO）、顶点缓冲对象（VBO）和索引缓冲（EBO）。
  * 将任务 1.1 手写的 MVP 矩阵通过 `gl.uniformMatrix4fv` 传入着色器，开启深度测试 `gl.enable(gl.DEPTH_TEST)`。
* **验收标准**：
  * 正确绘制一个带表面颜色渐变的多面体，具备正确的面遮挡关系（无 Z-fighting 或面穿透反转现象）。

---

### 任务 1.4：手写第一人称漫游相机 (FPS Camera) 与主循环
* **任务描述**：
  * 实现基于 `requestAnimationFrame` 的主循环，引入精确的增量时间计算（`deltaTime = (now - last) / 1000`）。
  * 接入浏览器 **Pointer Lock API**，捕获鼠标在屏幕上的位移增量（`movementX`、`movementY`）。
  * 实现相机的偏航角（Yaw）和俯仰角（Pitch）旋转，并在代码中设置俯仰角极限（$-89^\circ \sim +89^\circ$）防止万向节翻转。
  * 结合键盘事件（WASD），计算相对于相机当前朝向的前进、后退、左右平移矢量。
* **验收标准**：
  * 鼠标点击后锁定指针，晃动鼠标可平滑环顾三维世界，键盘 WASD 可像 CS/战地一样在三维空间中自由漫游。

---

## 🎯 阶段交付物检查点 (Checklist)

- [ ] `math3d.js`：自研 3D 数学核（Vec3, Mat4），经测试无误。
- [ ] `software-cube.html`：2D Canvas 软件光栅化 3D 旋转立方体。
- [ ] `webgl2-triangle.html`：原生 WebGL 2 彩色几何体绘制 demo。
- [ ] `fps-camera-wander.html`：无任何依赖的原生 FPS 第一人称漫游场景。
