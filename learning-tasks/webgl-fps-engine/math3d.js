/**
 * math3d.js - 自研极简 3D 线性代数核心核 (W1 节点待实现)
 * 纯原生 JS，零外部依赖
 */

class Vector3 {
    constructor(x = 0, y = 0, z = 0) {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    set(x, y, z) {
        this.x = x;
        this.y = y;
        this.z = z;
        return this;
    }

    dot(v) {
        // 待实现：计算点乘 x1*x2 + y1*y2 + z1*z2
        throw new Error("W1 待实现: Vector3.dot()");
    }

    crossVectors(a, b) {
        // 待实现：计算叉积 a x b
        throw new Error("W1 待实现: Vector3.crossVectors()");
    }

    length() {
        return Math.sqrt(this.x * this.x + this.y * this.y + this.z * this.z);
    }

    normalize() {
        const l = this.length();
        if (l === 0) return this;
        this.x /= l;
        this.y /= l;
        this.z /= l;
        return this;
    }
}

class Matrix4 {
    constructor() {
        // 4x4 列优先 Float32Array 数组 (对齐 WebGL2 uniformMatrix4fv)
        this.elements = new Float32Array([
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1
        ]);
    }

    identity() {
        const te = this.elements;
        te[0] = 1; te[4] = 0; te[8] = 0;  te[12] = 0;
        te[1] = 0; te[5] = 1; te[9] = 0;  te[13] = 0;
        te[2] = 0; te[6] = 0; te[10] = 1; te[14] = 0;
        te[3] = 0; te[7] = 0; te[11] = 0; te[15] = 1;
        return this;
    }

    multiply(m) {
        // 待实现：4x4 矩阵相乘 this = this * m
        throw new Error("W1 待实现: Matrix4.multiply()");
    }

    makeTranslation(x, y, z) {
        // 待实现：平移矩阵
        throw new Error("W1 待实现: Matrix4.makeTranslation()");
    }

    makeLookAt(eye, target, up) {
        // 待实现：相机观察矩阵 (View Matrix)
        throw new Error("W1 待实现: Matrix4.makeLookAt()");
    }
}

if (typeof module !== "undefined" && module.exports) {
    module.exports = { Vector3, Matrix4 };
}
