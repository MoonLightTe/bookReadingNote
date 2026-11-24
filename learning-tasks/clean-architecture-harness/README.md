# 🛡️ Clean Architecture Harness 实战任务库

> 基于 Uncle Bob 软件质量工程哲学，从零构建跨平台双轨代码质量门禁，驱动 AI 完成端到端自愈交付。

---

## 📌 当前状态总览

- **目标主题**: Uncle Bob 质量门禁体系与 AI 协同实战
- **终极交付**: 双轨门禁引擎 + AI 3次红灯自愈试金石签字交付
- **状态机**: [`./study-state.yaml`](./study-state.yaml)
- **理论参考专论**: [`../../topics/clean-architecture-harness.md`](../../topics/clean-architecture-harness.md)
- **门禁执行调度器**: [`../../scripts/verify-harness.sh`](../../scripts/verify-harness.sh)

---

## 🗺️ 最小骨干 DAG 拓扑

```mermaid
flowchart TD
    N1["N1: 退出码契约与防假绿断言 (in_progress)"]
    N2["N2: 测试锁定防作弊机制 (ready)"]
    N3["N3: CRAP 状态机与圈复杂度探针 (locked)"]
    N4["N4: PITest 变异测试与杀虫 (locked)"]
    N5["N5: 金丝雀负向自检自毁体系 (locked)"]
    N6["N6: 双轨极速/交付模式重构 (locked)"]
    N7["N7: 三次红灯试金石实战验收 (locked)"]

    N1 --> N3
    N2 --> N3
    N3 --> N4
    N3 --> N5
    N4 --> N6
    N5 --> N6
    N6 --> N7
```
