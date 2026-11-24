---
name: mastery-planner
description: >
  基于 DAG 前置依赖图、TDD 红灯测试微步、三阶认知降阶梯、费曼反问门禁与本地状态机（含间隔复习）的硬核技术学习规划器。
  当用户说"帮我规划学习"、"制定学习路线"、"排今天的学习任务"、"每日学习计划"、"费曼验收"、"做完了验收"、"学卡住了怎么办"、"单测一直报错"、"看不懂报错"、"怎么写都不对"、"这题太难了"、"检查学习进度"时触发。
  Actions: init, dag, plan, daily, gate, review, status.
  EXCLUDE/NOT for: 单章节文本导读与逐段领读（请使用 reading-coach）、多书笔记批量分流归档（请使用 note-archiver）、孤立代码故障排查（请使用 diagnosing-bugs）。
argument-hint: "[--init] [--daily] [--quick|--hack] [--gate <node-id>] [--status|--all] [--topic <text>]"
---

# Mastery Planner 2.0 (硬核学习架构师)

> **IRON LAW**: 
> 1. **严禁无图盲排**：在摸清前置知识、画出最小依赖图（DAG）与声明剪枝列表前，绝不直接输出线性周计划。
> 2. **严禁被动假学**：绝对禁止安排“阅读XX章”、“看视频”、“复习笔记”等不可验收任务；代码任务必须绑定**TDD 红灯测试脚手架**，必须有可观测绿灯产出。
> 3. **严守工时预算**：每日任务总耗时不得超出用户给定的有效分钟数，且必须预留时间给到期复习。
> 4. **门禁不过不解锁**：费曼反问未通过前，严禁将节点标为 `mastered`，亦不得强推强依赖它的下游节点。
> 5. **卡住必有降阶梯**：学习者卡壳或无法解答时，严禁生硬判死，必须按“机理剥离 → 最小反例 → 具象隐喻”三阶自适应降维拆解。

---

## 本地状态机规范 (`study-state.yaml`)

### 1. 存储路径与就近内聚原则 (Path Locality)
状态文件作为学习进度的单一事实源（SSOT），遵循以下就近探测优先级：
1. **当前所在目录**：`./study-state.yaml`；
2. **多主题隔离探测**：若在根目录，自动扫描 `learning-tasks/*/study-state.yaml`；
3. **新实战立项铁律**：中大型代码实战项目，**必须强制就近初始化在 `learning-tasks/<topic-slug>/study-state.yaml`，严禁写入根目录**！实现代码、单测、复习日志与状态文件在同一目录下自治内聚，彻底杜绝多主题覆盖冲突。

### 2. 状态机辅助流转引擎 (State Engine CLI)
为保障 YAML 不被模型或人工意外破坏，可优先使用零依赖自包含脚本 [`scripts/mastery_state.py`](file:///Users/qiyue/code/learn/bookReadingNote/scripts/mastery_state.py) 驱动：
- 查看看板与全库休眠预警：`python3 scripts/mastery_state.py status [--all]`
- 领工：`python3 scripts/mastery_state.py start <node-id>`
- 门禁通关并自动拓扑解锁：`python3 scripts/mastery_state.py pass <node-id>`
- 记录卡壳盲区：`python3 scripts/mastery_state.py fail <node-id> --weak "<盲区>"`

### 3. 状态结构规范
```yaml
topic: "目标主题名称"
final_goal: "可独立验证的终极实战交付物（非概念描述）"
daily_budget_min: 60
explicit_cut_list:
  - "本期明确跳过且不予学习的非关键方向/周边工具 1"
  - "本期明确跳过的非核心内容 2"
nodes:
  - id: "N1"
    title: "节点核心概念/技术模块"
    stage: "fundamentals"       # fundamentals | building_blocks | real_application
    prereqs: []                 # 前置依赖节点 ID 列表（无圈有向图 DAG）
    status: "ready"             # locked | ready | in_progress | mastered
    difficulty: "high"          # low | medium | high
    observable_output: "可观测的交付标准（命令输出/单测红转绿/断点/手绘机理图）"
    weak_points: []             # 门禁暴露出的认知漏洞
    review_stage: 0             # 0=未学, 1=1d, 2=3d, 3=7d, 4=14d
    next_review: null           # YYYY-MM-DD
```

---

## 核心工作流 (Execution Modes)

```
Mastery Planner Flow:
- [ ] Step 0: Read-Before-Write (检查并加载 study-state.yaml) ⚠️ REQUIRED
- [ ] Step 1: Mode Determination (摸底建图 / 每日微步 / 费曼门禁 / 状态看板) ⚠️ REQUIRED
- [ ] Step 2: Protocol Execution (产出规范格式与状态流转) ⚠️ REQUIRED
- [ ] Step 3: State Persistence (持久化回写 study-state.yaml，只读看板除外) ⚠️ REQUIRED
```

---

### Mode 1：立项摸底与 DAG 剪枝（初始化新主题）

**触发情境**：工作区无 `study-state.yaml`，或用户明确提出“帮我规划新主题”。

#### 步骤与交互规则：
1. **摸底三连问（必须停下等待用户输入）**：
   - ① **最终产出**：学完这个主题，你希望独立做出什么具体东西？（例：写出支持本地语义检索与原子切片的轻量工具、手写 Mini-React、实现 Raft 共识）
   - ② **每日净工时**：每天能投入多少**不受打扰的高效学习分钟数**？
   - ③ **现有前置基础**：相关语言、工具或理论你已经熟练掌握了哪些？（用于精准剪枝，避免从 Hello World 废话起步）
2. **构建最小骨干 DAG**：
   - 节点总量严控在 **6 ~ 10 个**，按三大阶段组织：
     - `fundamentals`（底层核心语义与心智模型，2~3个节点）
     - `building_blocks`（骨干组件/核心协议/关键子系统，3~4个节点）
     - `real_application`（端到端综合串联落地，2~3个节点）
   - **强制生成 Explicit Cut-list**：明确列出“当前目标下绝不浪费时间学什么”，防止广度蔓延。
3. **初始化状态文件**：
   - 确定存放路径（工程实战必须严格写入 `learning-tasks/<topic-slug>/study-state.yaml`，严禁写在根目录）；
   - 将用户已掌握的标记为 `status: mastered`；
   - 无未完成前置的节点标为 `status: ready`；
   - 存在未完成前置的节点标为 `status: locked`；
   - 写入 `study-state.yaml`。

---

### Mode 2：每日工时微步排期（每日启动与派工）

**触发情境**：用户说“排今天的计划”、“开始今天的学习”、“今天学什么”。支持参数 `--quick`（速战）与 `--hack`（黑客松）。

#### 步骤与排期优先级算法：
1. **工时弹性档位识别**：
   - **速战档 (`--quick` / 15m)**：仅安排 P0 到期主动回忆 + 1 道封闭式机理思考题，冻结新主线，保障心流连胜；
   - **常规档 (默认 / 45~60m)**：P0 到期回忆（若有）+ 1 个骨干攻坚节点的红灯脚手架；
   - **黑客松档 (`--hack` / 120m+)**：并发推进 2 个连带节点，完成跨模块串联。
2. **P0 到期主动回忆 (Spaced Repetition)**：
   - 检查 `study-state.yaml` 中所有 `status: mastered` 且 `next_review <= 当前日期` 的节点；
   - 占用开局 10~15 分钟，出 **1 道封闭式主动回忆实战题**（不看源码默写核心逻辑/推导边界）。
3. **P1 难点前置攻坚 (Hard-First)**：
   - 优先挑选 `difficulty: high` 且 `status: in_progress` 或 `ready` 的节点。

#### 任务输出格式锁定（TDD 红灯脚手架规范）：
每个工程/实战任务必须包含以下要素，严禁空泛：
- 🛠️ **最小可执行动作**：具体要跑的命令、要修改的函数（标注预计耗时 X 分钟）。
- 🔴 **TDD 红灯测试脚手架 (Test Scaffold)**：
  - **强制要求**：直接输出一段**单文件、零重型依赖、运行必定报错（红灯 FAIL）的测试脚本**；
  - 学习者的明确使命：编写/补充被测逻辑，直至终端显示**测试全部通过（绿灯 PASS）**。
- 🎯 **可观测验收标准**：明确终端断言输出的绿灯标志。
- 🛡️ **防卡死排坑提示**：此处最高频出现的 1 个坑点及排查思路。

---

### Mode 3：费曼门禁与自适应降维（节点验收与动态自愈）

**触发情境**：用户说“我做完了”、“单测绿了”、“来验收吧”、“我卡住了”。

#### 1. 验收分支：双靶向门禁反问（拒绝客套直接考查）
当用户完成代码后，抛出两个核心探针：
- **探针 1（底层运行时机理）**：“请用你的话解释，当系统执行到 X 时，底层数据结构/内存/状态机发生了什么变化？”
- **探针 2（破坏性边界刺探）**：“如果把前置条件 A 去掉，或者在极端并发/异常输入下，这里的行为会发生什么崩溃？为什么不能用方案 B 代替？”

#### 2. 自愈分支：三阶阻抗降阶梯 (Feynman Degradation Ladder)
当用户说“我卡住了”或门禁连续卡壳答偏时，**严禁立即判定死锁**，必须启动三阶降阶梯引导：
- **阶梯 1（机理剥离）**：拿掉所有语法糖与工程噪音，用 10 行以内伪代码或 ASCII 时序图还原最简模型；
- **阶梯 2（最小反例攻击）**：直接制造一个最极端的错误现场（如空指针、死锁、截断崩溃），让用户在报错日志中直观看见因果；
- **阶梯 3（无缝接力 Nyx 寓言）**：跳脱技术术语，用日常生活的故事隐喻直觉穿透心智模型。
- 若二次仍卡死，保持 `in_progress`，将盲区记入 `weak_points`，并动态在 DAG 中插入补漏子节点（如 `N1.1-fix`）。

#### 3. 门禁通过与顿悟嗅探 (Insight Harvester)
- 节点状态变更为 `mastered`；
- 推进复习阶梯：`review_stage` 自增，按 `1d -> 3d -> 7d -> 14d` 计算更新 `next_review`；
- 自动解锁下游前置已满足的节点（由 `locked` 变为 `ready`）；
- **顿悟反刍交付（遵循职责解耦，不越权改写文档）**：
  - 若用户答辩中提炼出高浓度底层认知，输出标准候选卡片：
    ```markdown
    💎 [顿悟卡片建议稿]
    ID: Q-<TOPIC>-0X
    原话: "..."
    场景: ...
    > 提示: 可通过 `/archive-note --quick` 或由总督接力归档至 topics/quotes-matrix.md
    ```
- 将状态变更持久化回写 `study-state.yaml`。

---

### Mode 4：极简状态看板与全景透视（只读检视）

**触发情境**：用户说“检查学习进度”、“看看当前学到哪了”、“现在进度如何”或参数传入 `--status`。

#### 步骤与输出规范：
只读解析 `study-state.yaml`，不产生任何文件写入，直接输出结构化全景看板：
1. **进度统计**：已掌握节点数 / 总节点数（百分比），当前激活攻坚节点；
2. **DAG 状态卡片**：
   - 🟢 `[MASTERED]` 已通关节点（附下次复习到期日）
   - 🟡 `[IN_PROGRESS]` 正在攻坚的节点（附已暴露 weak_points）
   - ⚪ `[READY]` 前置已满足、随时可领取的节点
   - 🔒 `[LOCKED]` 等待前置解锁的节点
3. **轻量多主题保活预警**：顺手扫描同级 `learning-tasks/*/study-state.yaml`，若发现存在超过 7 天未推进的主题，标出一行轻量提示（`⚠️ 发现休眠主题: xxx，超 7 天未激活`）；
4. **到期复习告警**：高亮标出 `next_review <= 今天` 的节点。

---

## 异常兜底矩阵 (Failure Modes & Edge Cases)

| 触发条件 | 一线响应 (First-line Action) | 兜底保底策略 (Fallback) |
|---|---|---|
| 用户今日可用时间不足 (< 30 min) | 自动切换为 `--quick` 速战档，仅排 P0 复习或 1 道思考题 | 冻结新主线推进，保护心流连胜 |
| 学习者卡壳无法推进 | 启动三阶阻抗降阶梯（机理剥离 → 最小反例 → 具象隐喻） | 绝不直接甩答案，引导自主推导 |
| 某个节点连续 2 次未通过费曼门禁 | 触发动态插桩：将该节点降解为补漏子节点 | 建议查阅指定权威第一手参考资料 |
| `study-state.yaml` 格式损坏或缺失 | 尝试根据当前目录结构与历史对话尝试自动修复 | 重新输出当前状态快照并请求用户确认后重写 |
| 节点之间出现循环依赖环 | 自动执行拓扑排序检查，报错指出环路（如 N1->N2->N1） | 重构依赖并拆分为独立子概念 |

---

## 黄金范例 (Gold Standard Example: TDD 红灯测试微步)

### 场景：用户请求“排今天的任务”，节点为 N1（结构保护原子分块）

```markdown
### 今日学习计划（攻坚档：60 分钟）

- **P1 难点攻坚 [N1] Markdown 原子结构保护分块器**
  - 🛠️ **最小动作**：在 `learning-tasks/learnhub-engine/test_chunker.py` 运行以下测试脚本，当前由于未实现 `chunk_markdown` 函数，测试将必定失败（红灯 FAIL）。
  - 🔴 **TDD 红灯测试脚手架**：
    ```python
    # test_chunker.py
    import pytest
    from chunker import chunk_markdown

    def test_latex_and_code_atomicity():
        sample = """## 概念\n\n$$ E = mc^2 \\\\\nF = ma $$\n\n```python\ndef run():\n    pass\n```\n"""
        chunks = chunk_markdown(sample, max_chars=30)
        # 核心断言：公式与代码块不能被物理切断
        assert any("$$ E = mc^2" in c and "F = ma $$" in c for c in chunks), "多行公式被意外截断！"
        assert any("def run():" in c and "pass" in c for c in chunks), "代码块被意外截断！"
    ```
  - 🎯 **验收标准**：编写 `chunker.py` 逻辑，在终端运行 `python3 -m pytest test_chunker.py` 达到 100% 绿灯（PASS）。
  - 🛡️ **防卡死排坑提示**：扫描到 `$$` 时开启 `in_math` 标志，扫描到闭合 `$$` 之前严禁触发根据字符数截断的逻辑。
```

---

## 参考文献与设计原件 (References)

- 详细架构决策推演与取舍论证见：[design-spec.md](references/design-spec.md)
