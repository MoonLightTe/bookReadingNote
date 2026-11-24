---
name: quality-harness
description: Uncle Bob 代码质量门禁与自愈总督。基于“不读具体代码、由机器硬指标把关”哲学，支持双轨智能路由（日常敏捷 --lean vs 交付终审 --deliver）。强制执行“编码前出架构图、测试锁定防篡改、红灯读报错自愈、三轮熔断求助、交付呈递签字卡片”。触发词包括 quality-harness, /quality-harness, 门禁, 质量门禁, 跑门禁, 验收卡点, 交付验证。
---

# Uncle Bob 代码质量门禁与自愈总督 (`quality-harness`)

> “代码的读者换成了 Agent，规矩是防止 Agent 认知过载与逻辑腐化。
> 人类从具体的逐行代码中抽离，退到宏观层审查架构依赖，并以机器刚性退出码为唯一交付依据。”

---

## 核心定位：说明书与状态机，不是执行者

- **本 Skill 是指令层（说明书）**：负责指导 Agent 的行为流程、模式路由和自愈策略；
- **物理阻断靠脚本退出码**：无论 Agent 在对话中如何解释，**只要 `./scripts/verify-harness.sh` 退出码非 0，一律视为未完成，严禁口头宣布交付**。

---

## 一、 双轨模式路由规范 (Dual-Track Mode Routing)

Agent 收到编码任务时，应根据任务性质自动判定或由人类显式指定执行模式：

```
                    【模式选择状态机】
                           │
       ┌───────────────────┴───────────────────┐
       ▼                                       ▼
【极简极速模式 (Lean)】                   【严格完整模式 (Deliver)】
• 触发场景: 日常小需求、局部重构、修复Bug    • 触发场景: 核心资产、金融结算、发版交付
• 执行命令:                              • 执行命令:
  ./scripts/verify-harness.sh --lean       ./scripts/verify-harness.sh --deliver
• 核心门禁:                              • 核心门禁:
  1. 物理锁定已有单测 (严禁删改既有断言)     1. 关联单测全绿 (Gate 1)
  2. 单元测试秒级全绿 (5~10 秒)             2. CRAP 硬红线 <= 20.0 (Gate 2)
  3. 单函数圈复杂度硬卡 <= 10               3. PITest/Stryker 变异测试 0 存活 (Gate 3)
  4. 3 轮自愈失败自动熔断                  4. 生成 .harness/audit.json 密码凭据
```

---

## 二、 交付四步闭环生命周期 (4-Step Lifecycle)

任何受控编码任务，Agent 必须严格遵守以下作业顺序：

### 第 1 步：架构出图与契约先行 (Contract First)
在动任何业务实现代码前，Agent 必须向人类汇报：
1. **Mermaid 模块依赖拓扑图**：证明改动未引入循环依赖、模块职责单一；
2. **红灯契约单测**：列出即将编写或追加的单测边界用例（此时运行应为红灯）。
> **停顿门禁**：必须等待人类确认架构设计无误后，方可进入第 2 步。

### 第 2 步：测试锁定防作弊 (Anti-Tamper Lock)
- **铁律**：Agent 只能“追加新测试”，**严禁修改或删除已有测试用例断言**；
- 脚本内嵌的 `check_anti_tamper` 将监控 Git diff，一旦检测到对既有测试的删除行（`-` 开头），门禁将直接打挂并阻断。

### 第 3 步：内部编码与自愈循环 (Act -> Observe -> Fix)
- Agent 编写业务实现，并在终端调用门禁命令（`--lean` 或 `--deliver`）；
- 若门禁报错（Exit 1）：
  - **严禁**：打扰人类、自作聪明修改门禁脚本、调大阈值或改单测；
  - **必须**：仔细阅读脚本打印的 `[CRAP FAILED]` 或 `[MUTATION ALERT]` 结构化错误，自主拆解高复杂度函数或补全边界断言；
- **熔断机制**：连续失败 3 轮，或代码修改陷入停滞时，必须主动触发熔断向人类求助：
  > `[CIRCUIT BREAKER] 自愈已达到 3 轮上限，检测到停滞。请人类工程师介入指导！`

### 第 4 步：交付签字卡片 (Sign-off Artifact)
当且仅当 `./scripts/verify-harness.sh` 退出码为 `0` 时，Agent 方可向人类呈递标准交付卡片：

```markdown
### 🎯 质量门禁交付签字卡片

- **执行模式**: `[lean / deliver]`
- **门禁状态**: `ALL GATES PASSED (Exit Code: 0)`
- **质量指标矩阵**:
  - 单测对账: `12 / 12 PASSED`
  - 复杂度指标: `Max Complexity = 6 (Limit: <=10)`
  - 变异消灭率: `100% (0 survived)` *(deliver 模式)*
  - 审计凭据: `.harness/audit.json 已生成`
- **系统架构图**:
  \`\`\`mermaid
  flowchart LR
     A[Client] --> B[OrderService]
     B --> C[PaymentGateway]
  \`\`\`
- **请人类审查架构拓扑，确认签字提交。**
```

---

## 三、 快速指令表

| 人类指令 | 触发行为 |
| :--- | :--- |
| `/quality-harness --lean` | 以极简极速模式启动编码自愈闭环 |
| `/quality-harness --deliver` | 以严格交付模式启动全量门禁与变异核验 |
| `/quality-harness self-test` | 驱动 `./scripts/verify-harness.sh --self-test` 验证门禁拦截健康度 |
