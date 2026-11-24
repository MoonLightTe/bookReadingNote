"""
chunker.py - LearnHub 核心引擎: Markdown 原子结构保护分块器 (待实现)
"""

def chunk_markdown(content: str, max_chars: int = 800, overlap_chars: int = 120) -> list[dict]:
    """
    将 Markdown 文本切分为结构保护的 Chunks。
    
    参数:
        content: Markdown 纯文本
        max_chars: 普通文本块的目标最大字符数预算 (默认 800)
        overlap_chars: 普通文本块滑动重叠字符数 (默认 120)
        
    返回:
        list[dict]: 每个元素包含:
            - chunk_id: 分块编号 (从 1 开始)
            - chunk_type: 'normal' | 'code' | 'math' | 'table' (原子类型)
            - content: 切片文本内容
            - char_count: 字符数
            
    原子保护铁律:
        1. 多行 LaTeX 公式 ($$...$$) 无论多长，必须作为单一原子块完整保留，绝不内部截断。
        2. 代码围栏 (```...```) 无论多长，必须作为单一原子块完整保留，绝不内部截断。
        3. Markdown 表格 (| 表头 | ... |) 必须行完整保留，绝不腰斩。
    """
    # 待实现：当前故意抛出异常以制造 TDD 红灯
    raise NotImplementedError("N1 核心分块函数尚未实现，请编写状态机或行扫描逻辑修绿测试！")
