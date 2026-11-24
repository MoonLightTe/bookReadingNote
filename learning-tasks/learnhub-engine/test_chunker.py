#!/usr/bin/env python3
"""
test_chunker.py - N1 节点 TDD 红灯测试脚手架 (Test-Driven Learning Scaffold)
运行方式: python3 test_chunker.py
"""

import unittest
from chunker import chunk_markdown

class TestStructuralChunker(unittest.TestCase):
    
    def setUp(self):
        # 构造包含标题、多行公式、代码围栏、表格与超长文本的综合样本
        self.sample_markdown = """# 深度学习核心推导

在统计学习中，损失函数的极小化至关重要。

$$
\\mathcal{L}(\\theta) = \\frac{1}{N} \\sum_{i=1}^{N} (y_i - f(x_i; \\theta))^2 + \\lambda \\|\\theta\\|_2^2
\\\\
\\nabla_\\theta \\mathcal{L}(\\theta) = -\\frac{2}{N} \\sum_{i=1}^{N} (y_i - f(x_i; \\theta)) \\nabla f + 2\\lambda \\theta
$$

以下是参数更新的核心代码逻辑：

```python
def sgd_update(params, grads, lr=0.01, weight_decay=1e-4):
    for w, g in zip(params, grads):
        w -= lr * (g + 2 * weight_decay * w)
    return params
```

性能与超参数对照表如下：

| 超参数 | 推荐值 | 作用描述 |
| :--- | :--- | :--- |
| lr | 0.001 | 基础学习率，过大震荡，过小收敛极慢 |
| weight_decay | 1e-4 | L2 正则化惩罚项，抑制模型过拟合 |
| batch_size | 64 | 单步小批量梯度估计样本数 |

这是最后一段普通的总结性文本，用于检验普通段落是否能够按照字符预算合理切分。
"""

    def test_01_math_block_atomicity(self):
        """测试用例 1: 验证多行 LaTeX 公式绝对不被切断"""
        chunks = chunk_markdown(self.sample_markdown, max_chars=100)
        
        # 寻找包含公式的 chunk
        math_chunks = [c for c in chunks if "$$" in c["content"]]
        self.assertTrue(len(math_chunks) >= 1, "未找到包含公式的分块")
        
        # 断言整个公式块都在同一个 chunk 中完整存在
        found_full_math = False
        for c in math_chunks:
            if "\\mathcal{L}(\\theta)" in c["content"] and "2\\lambda \\theta" in c["content"]:
                found_full_math = True
                self.assertEqual(c["chunk_type"], "math", "公式块类型标记错误")
                break
        self.assertTrue(found_full_math, "多行 LaTeX 公式被错误腰斩切断！")

    def test_02_code_fence_atomicity(self):
        """测试用例 2: 验证代码围栏 (```) 绝对不被切断"""
        chunks = chunk_markdown(self.sample_markdown, max_chars=100)
        
        code_chunks = [c for c in chunks if "```python" in c["content"]]
        self.assertTrue(len(code_chunks) >= 1, "未找到代码围栏分块")
        
        found_full_code = False
        for c in code_chunks:
            if "def sgd_update" in c["content"] and "return params" in c["content"] and "```" in c["content"]:
                found_full_code = True
                self.assertEqual(c["chunk_type"], "code", "代码块类型标记错误")
                break
        self.assertTrue(found_full_code, "代码围栏被错误腰斩切断！")

    def test_03_table_integrity(self):
        """测试用例 3: 验证表格行结构完整"""
        chunks = chunk_markdown(self.sample_markdown, max_chars=100)
        
        table_chunks = [c for c in chunks if "| 超参数 |" in c["content"]]
        self.assertTrue(len(table_chunks) >= 1, "未找到包含表格的分块")
        
        c = table_chunks[0]
        self.assertIn("batch_size", c["content"], "表格最后一行被截断遗漏！")
        self.assertEqual(c["chunk_type"], "table", "表格类型标记错误")

    def test_04_normal_text_budget(self):
        """测试用例 4: 验证普通文本切片满足字符上限约束"""
        chunks = chunk_markdown(self.sample_markdown, max_chars=120)
        normal_chunks = [c for c in chunks if c["chunk_type"] == "normal"]
        for c in normal_chunks:
            # 允许一定标点缓冲，但普通块不能肆意超标
            self.assertTrue(len(c["content"]) <= 200, f"普通块严重超出字符预算: {len(c['content'])}")

if __name__ == "__main__":
    unittest.main()
