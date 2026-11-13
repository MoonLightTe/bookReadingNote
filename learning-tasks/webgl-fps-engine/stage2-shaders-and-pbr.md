# 阶段二实战任务：GLSL 着色器、程序化材质与 PBR 渲染 (第 6 - 10 周)

> **目标**：攻克《几猫》画面逼真（水坑、雨夜、沥青反射、软阴影）的核心秘密——算法着色与现代物理光照。

---

## 📚 对应阅读章节与理论输入

1. **[The Book of Shaders](https://thebookofshaders.com/)（着色器之书）**
   * 第 5-7 章：造型函数、着色逻辑与图形绘制
   * 第 10-12 章：生成随机（Random）、一维/二维噪声（Noise）、网格与分形布朗运动（FBM）
2. **《Real-Time Rendering 4th》（实时渲染第四版）**
   * 第 9 章：Physically Based Shading（基于物理的着色：微表面理论、库克-托伦斯 BRDF、法线分布函数 D、几何遮蔽 G、菲涅尔 F）
   * 第 7 章：Shadows（PCF 与 PCSS 软阴影原理）
3. **[Inigo Quilez 计算机图形艺术技术文集](https://iquilezles.org/)**
   * Procedural Texturing（程序化纹理）与 Voronoi 算法在水坑、裂纹中的实战技巧。

---

## 🛠️ 动手实操任务清单

### 任务 2.1：纯数学噪声算法实现（Noise & FBM）
* **任务描述**：
  * 在 GLSL 片元着色器中，不使用任何外置图片作为贴图。
  * 手写 2D Hash 伪随机函数。
  * 实现二维 Value Noise / Perlin Noise 算法。
  * 叠加 4-6 层不同频率与振幅的噪声，构建分形布朗运动（Fractal Brownian Motion, FBM）。
* **验收标准**：
  * 在屏幕上生成连绵起伏、有机自然的云雾纹理，或生成地面粗糙斑驳的高频细节。

---

### 任务 2.2：纯代码打造“雨夜潮湿沥青路面”程序化材质 (Procedural PBR)
* **任务描述**：
  * 基于 Three.js 的 `ShaderMaterial` 或扩展 `MeshStandardMaterial`（使用 `onBeforeCompile`）。
  * **基础沥青层**：用高频噪声生成细小的粗糙碎石颗粒感（Albedo 暗灰），基础粗糙度（Roughness）设为 0.75。
  * **水泥接缝与裂纹**：用 Voronoi / 距离场函数生成 6 米间距的水泥伸缩缝与深色沥青灌缝裂纹。
  * **积水坑模型（Puddle Height Mask）**：用低频 FBM 噪声生成大尺度的地势高度掩码；地势低洼处生成水面。
  * **动态粗糙度平滑渐变**：
    * 干燥区：Roughness $\approx 0.75$
    * 潮湿泛光带：Roughness $0.35 \sim 0.5$
    * 积水坑倒影：Roughness $< 0.08$（近似镜面反射）。
* **验收标准**：
  * 在 3D 场景中移动视角，能看到水坑呈现清晰锐利的镜面环境倒影，水坑边缘有自然的浸润过渡，地面干燥处有哑光散射质感。

---

### 任务 2.3：实现 PCSS (Percentage-Closer Soft Shadows) 高级软阴影
* **任务描述**：
  * 在自定义 Shadow Shader 中编写 PCSS 算法：
    1. **Blocker Search（遮挡物检索）**：在受光点周围的阴影贴图中搜索平均遮挡物深度。
    2. **Penumbra Calculation（半影计算）**：根据公式 $w_{penumbra} = \frac{d_{receiver} - d_{blocker}}{d_{blocker}} \times w_{light}$，动态计算半影宽度（物体距离阴影越近，阴影越硬锐；距离越远，阴影越柔和弥散）。
    3. **Filtering（自适应核滤波采样）**：以计算出的半影宽度作为泊松圆盘采样半径进行 PCF 采样。
* **验收标准**：
  * 场景中起重机或柱子投射在地面的阴影，根部极其锐利清晰，延伸至远端则自然晕开为柔和的软阴影。

---

### 任务 2.4：后处理全屏渲染通道与 AgX 色调映射 (AgX Tone Mapping)
* **任务描述**：
  * 使用 WebGL 帧缓冲对象（FBO）实现全屏后处理管线。
  * 引入高动态范围（HDR）光照计算，允许片元着色器中的发光体颜色值超过 1.0。
  * 手写 **AgX 色调映射（Filament/Blender 拟合算法）**，替代传统的简单 Reinhard 映射，防止高光区色彩过度过曝发白，保留丰富的暗部细节。
  * 加入电影感色彩分级（Color Grading）：微调中灰对比度、加入暗角（Vignette）与微妙的色温偏移。
* **验收标准**：
  * 场景在强光照射下呈现类似现代电影大片的胶片质感，高光不过曝，阴影有深度。

---

## 🎯 阶段交付物检查点 (Checklist)

- [ ] `shader-noise-fbm.html`：纯 GLSL 算法生成的动态有机云层与地形噪波。
- [ ] `procedural-wet-asphalt.html`：逼真的雨后湿润码头沥青路面（含积水镜面倒影）。
- [ ] `pcss-soft-shadows.html`：可动态调节光源半径的真实柔和接触硬阴影。
- [ ] `cinematic-postprocessing.html`：具备 AgX Tone Mapping 与胶片色调的后处理通道。
