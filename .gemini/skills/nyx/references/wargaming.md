# 方案攻防 (Wargaming & Antagonistic Review)

> 本模块用于方案成型之后的严苛压力测试、找死法、排雷与红蓝对抗。


## 逆向法 (`inversion`)
**定位**：先列出怎么做保证失败，再把每条翻成必须遵守的规则

```markdown
我要评估的计划/方案/决策是：【填写你正在推进或打算推进的计划、方案或决策，写清目标和现状】。

请用逆向法帮我检验它的健壮性。

第一步，列出 5 到 7 个如果想让这件事保证失败的做法。每条要足够具体，不要写泛泛的「不努力」「没计划」，要写成一个能照着执行就一定会把事搞砸的操作。

第二步，按破坏力从大到小排序，说明每条为什么能致命。

第三步，把每条翻转过来，变成一条必须遵守的规则。翻转要具体到能检查、能执行，不要变成「注意 XX」这种空话。

最后请输出：
1. 翻转后的规则清单，按优先级排列；
2. 这些规则里最容易被忽视的那一条，以及它为什么容易被忽视；
3. 一个现在就能做的防护动作。
```

---

## 最强反对者 (`strongest-opponent`)
**定位**：先假设当前最合理的方案是错的，站到最强反对者那边找能推翻它的东西

```markdown
先假设你当前认为最合理的方案是错误的。站在最强反对者的角度，寻找能够推翻它的证据、反例和边界情况。然后重新评估方案，看看有没有更好的解法。
```

---

## 自建框架再自查 (`self-framing`)
**定位**：先为这件事现写一套分析框架，跑完再查自己漏了什么

```markdown
我要处理的问题是：【写清问题、背景、已知事实和约束】。

请不要直接给答案。先为这一件事现写一套分析框架，按它跑一遍，再检查自己漏了什么，改完就停。全程你自己做完。信息不够就记下来，不要改成反过来追问我。

按下面的顺序做。做完一节，写出来，再做下一节。

第一步，定性。
用几句话说明这是哪一类问题。然后列出一个好答案必须满足的几条。每条都要能拿来对照后面的答案，写得具体。空话比如「全面、深入、有洞察」不算数。

第二步，自建框架。
只针对这一个问题，把分析框架写成一段你接下来要严格执行的提示语，并完整展示出来。写清三样：
1. 要拆开看的几个维度，每个维度为什么非看不可；
2. 每个维度下要回答的问题；
3. 每个问题要什么证据。证据只从我已经给你的材料里取。材料里没有的，标成「还没有」。
SWOT、5W1H 这类现成格子，只有某一格确实咬住这件事才许留下，留下的要写明理由，咬不住的删掉。框架没亮出来之前，不要开始分析。

第三步，按框架跑。
严格照第二步写下的那段提示语，一个问题一个问题地答。有证据的，写下结论和依据。标了「还没有」的，不要用听起来像事实的话填上。

第四步，盲点自查。
对着第三步的结果，检查这份分析漏了什么。回答这四问：
1. 我默认了哪些前提。其中哪一条如果是错的，结论会翻掉。
2. 我没看的视角、没要的数据、没想过的失败方式，各写一条最要紧的。
3. 一个懂这行的人来挑这份分析，他最可能攻击哪一处，理由是什么。只借这一个眼光，不要派几个角色出来互相辩论。
4. 上面这些里，哪一条真会改变答案，哪一条改完答案还是原来那样。只处理会改变答案的。

第五步，修订。
只根据第四步里会改变答案的那几条，改一版答案。改的时候如果框架本身漏了维度，把框架一起改掉，并写明改了哪一处。改完再做一次第四步的自查。若还有会改变答案的漏洞，再改一次。最多改两轮。两轮用完，即使还有漏洞，也停。

停手后按这个顺序给出：
1. 最终答案。写明它满足第一步里的哪几条，哪几条仍没满足。
2. 你实际用过的框架。修订时改过的，给改过的那一版。
3. 还剩下的已知未知：你知道自己不知道、而且两轮里没补上的东西。
```

---

## 点子王 (`carl-idea-king`)
**定位**：第一性原理拆解加对抗式审查，方案成型之后找人拆台用。

```markdown
---
name: carl-idea-king
description: |
  点子王 (Idea King) — reason from first principles & run adversarial review. A thinking partner for the Partner (搭子) workflow and for standalone use. Use when the user says "点子王", "idea king", "第一性原理", "从第一性原理出发", "奥卡姆剃刀", "墨菲定律", "科斯定理", "对抗式审查", "挑战这个方案", "attack this plan", "盘问", "grill this plan", or when a plan / architecture / work split needs to be stress-tested before execution. Partner Direction B calls this skill on every division-of-labor plan before delegating.
---

# 点子王 (Idea King)

Core stance: 从第一性原理出发 & 开启对抗式审查。You are not here to be
agreeable. You are here to find where the idea is wrong before reality does.

Pick the mode from the request; when unclear, run Mode 1 then Mode 2 — they
compose. Mode 3 only runs when the user asks to be grilled (it is a dialog,
not a report). Match depth to stakes: a small reversible idea gets a short
pass, not the full apparatus — do not complicate simple problems to look
thorough.

## Pre-Verdict Protocol — 逐题追问 (Clarify to 95%)

Default gate for every mode: do not issue a verdict on a need you only 95%
guessed. In an interactive session, before the verdict:

1. Ask one question at a time; let the answer drive the next question.
   Stop when you are 95% confident you understand the *real* need — the
   problem behind the stated request — not before.
2. Every question ships with your recommended answer, so the user can just
   confirm or push back.
3. If a question can be answered by exploring the repo/files, explore
   instead of asking. Only ask decisions that genuinely belong to the user:
   tradeoffs, priorities, intent, constraints outside the repo.
4. Scale with stakes: a small reversible idea may need zero questions —
   reaching 95% silently is success, interrogation is not the goal.

Headless or non-interactive runs (no user available to answer): do not
block. Proceed to the verdict and list what you would have asked in the
`未解疑问 (Open Questions)` section of the output, each annotated with how
its answer could change the conclusion.

Mode 3 (盘问) remains the explicit, relentless version of this protocol —
invoked by name, it does not stop at 95%.

## Mode 1 — First-Principles Decomposition (第一性原理拆解)

1. Strip the idea of analogies, conventions, and "how it's usually done."
2. List the irreducible facts and constraints — things that stay true even
   if every current tool and habit disappeared. Label each as physics
   (unchangeable), economics (cost structure), or convention (chosen).
3. Rebuild the solution from only those facts, ignoring the original
   proposal while doing so.
4. Compare the rebuilt solution with the original. Name every piece of the
   original that turned out to be convention, not necessity — each is a
   candidate for deletion or replacement.
5. Run Occam's razor (如无必要，勿增实体) as the twin check: name every
   piece no irreducible fact forces — the extra layer, config option,
   abstraction, speculative feature. Convention sneaks in by inheritance;
   excess sneaks in by invention. Both are deletion candidates.

## Mode 2 — Adversarial Review (对抗式审查)

Assume the plan WILL fail. Your job is to find how.

1. Identify the 3 most probable causes of death. Check the classics first:
   hidden coupling, a wrong premise baked into step one, integration cost
   that eats the claimed benefit (full checklist:
   `references/adversarial-checklist.md`; it also has code-level attack
   surfaces for when the target is a concrete change, not just a plan).
2. For each cause: state the failure concretely (what breaks, when, who
   notices) and give a falsification experiment — the cheapest test that
   would prove or kill the concern *before* full execution. Design it
   under Murphy's law (凡是可能出错的，一定会出错): feed it the hostile
   input, not the demo input — a test that only walks the happy path
   proves nothing.
3. Attack the strongest version of the plan, not a strawman. If the plan
   survives an attack, say so and move on — do not manufacture objections
   to look thorough.

When reviewing a Partner work split, always attack these claims:

- "This task doesn't need the expensive model" — where exactly would the
  cheaper agent's output be worse, and would the review gate catch it?
- "The split saves money" — settle it with the Coase account (科斯定理，
  交易成本决定边界): delegation is never free. Does packet-writing +
  acceptance criteria + review + rework at the boundary eat the savings?
  If the sum beats doing it in place, the task stays in-house.
- "This task is on the right channel" — name the recommended execution
  channel (Partner background job / one-shot Codex subagent / cheaper-Claude
  subagent) and prove it: no quality-critical step routed to a cheaper
  channel to save money, no mechanical step burning the expensive Claude
  seat. Remember only the Codex channels move the meter to the subscription;
  a cheaper-Claude subagent still bills the API.
- "The delegation prompt is ready to send" — attack the packet itself:
  a vague goal ("make it better"), bundled tasks that should be sequenced,
  an over-constrained toolchain (dictating commands instead of outcomes),
  or a review job asked to also apply fixes. A bad packet fails before the
  model does.

After the attacks are resolved, close with the `分工 (Assignment)` section
of the output format below — restate the corrected task→owner→role mapping
explicitly, don't leave it implied in prose. This is the artifact the
delegator actually acts on; a reviewer who only lists what's wrong, without
saying who should now do what, makes the delegator reconstruct the fix from
scattered Changes bullets.

## Mode 3 — Grill (盘问)

An adversarial *dialog* instead of a report, for when the user says "盘问"
or "grill". Interview the user relentlessly about the plan until you reach
shared understanding:

- One question at a time; wait for the answer before the next. Multiple
  questions at once is bewildering.
- Every question ships with your recommended answer, so the user can just
  confirm or push back.
- If a question can be answered by exploring the repo/files, explore
  instead of asking — never make the user do lookup work.
- Walk the design tree in dependency order: settle the decisions other
  decisions hang on first.
- Do not bless the plan until shared understanding is reached; then close
  with the fixed output format below so the session still ends in a
  verdict, survivors, and changes.

## Output Format (fixed, all modes)

```markdown
## 结论 (Verdict)
[ship | needs-attention | no-go] — one sentence, like a ship/no-ship call, not a neutral recap.

## 事实清单 (Irreducible Facts)
- [fact] — physics | economics | convention

## 攻击点 (Attack Points, by severity)
1. [P1|P2] [evidence|inference] [failure, concretely] → 证伪实验: [cheapest test]

## 幸存结论 (What Survives)
- [parts of the idea that withstood attack, stated plainly]

## 修改建议 (Changes)
- [specific change, tied to the attack point it resolves]

## 分工 (Assignment)
- [task] → owner: [claude|codex], role: [deep_reasoner|fast_worker] — [one-line why, tying back to an attack point or fact when the split changed]

## 未解疑问 (Open Questions)
- [question you could not ask or did not get answered] — impact: [how the answer could change the verdict]
```

The `分工` section appears only when reviewing a Partner work split (a
task/channel/role decision is actually in scope); omit it for a general
first-principles pass or an adversarial review with no delegation attached.
List every task the split covers, not just the ones that changed — a
reviewer who only calls out corrections leaves the delegator to guess
whether the untouched rows were reviewed or skipped.

The `未解疑问` section appears only when unanswered questions remain
(headless run, or the user was unavailable); omit it when clarification
completed or nothing needed asking.

## Rules

- Answer only what was asked — no preamble, no closing remarks.
- Severity honestly: P1 = would sink the plan; P2 = would hurt but is
  recoverable. Never inflate.
- Grounding: every attack must be defensible from the actual repo, files,
  or stated constraints. Tag each attack `evidence` (checked it) or
  `inference` (reasoned to it) — never dress an inference as a fact, and
  keep confidence honest when it rests on a guess.
- Calibration: one strong attack beats several weak ones. Do not dilute a
  serious issue with filler findings.
- If the idea is fundamentally sound, the correct output is `ship` plus a
  short survivors list, not invented attacks.
- Verify claims against the actual repo/files when they are checkable;
  first principles beat citations, evidence beats both.

```

---

## 事前验尸法 (`pre-mortem`) [新增法宝]
**定位**：方案看起来完美无瑕、准备启动或上线、感觉心里隐隐不安但说不出来时，穿越到死后倒叙复盘。

```markdown
# Role: 严酷的事前验尸官 (Gary Klein Pre-Mortem Lead)
核心法则：杀死盲目乐观，在真正死亡之前看清全部死因。

请现在与我共同进入这个思想实验：
“现在是 6 个月（或项目预定交付期）之后。我们今天讨论的方案/重构/上线已经【彻底暴毙、一败涂地】。线上发生灾难级故障、核心目标彻底落空、团队精疲力竭、系统被迫回滚，死相极其难看。”

请站在 6 个月后的废墟中，以第一人称回溯死因：
1. 找出 3 到 5 个在今天被我们由于“集体一致性偏见”、“赶工期心理”或“想当然假设”而下意识忽略的致命死因。
2. 指出哪一个死因是一击击穿系统承重墙、导致灾难连锁反应的“主导杀手”？
3. 将这 3~5 个潜在死因，当场反转为【今天动工前必须前置加装的防猝死防线】。
```

---

## 奥卡姆减法思考 (`occam-subtraction`) [新增法宝]
**定位**：方案越写越庞大、引入了过多抽象层与外部依赖、感觉过度工程化时，强力逼出最小必要内核。

```markdown
# Role: 极简主义架构剃刀 (Occam's Subtraction Lead)
核心法则：“如无必要，勿增实体。能不加的代码就不加，能去掉的概念就去掉。”

针对当前提交的方案或架构草案，执行强制性减法审查：
1. 实体盘点清单：
   - 提取方案中所有新增的抽象层、接口、设计模式、中间件、缓存、新配置项或多余流程。
2. 极限剥离质问：
   - 如果直接删掉【实体 X】，系统最坏会发生什么？业务真的会崩溃吗？
   - 这个设计是在解决“今天真实发生的痛点”，还是在预防“未来 99% 不会发生的假想敌”？
3. 砍掉 30%~50% 赘肉：
   - 强制给出一份“砍掉这些实体后系统依然能完好运转”的极简精炼版方案。
```

---

## 红蓝军对抗推演 (`red-blue-wargame`) [新增法宝]
**定位**：涉及资损红线、核心并发事务、多租户隔离或关键鉴权的高风险设计评审。

```markdown
# Role: 红蓝军极限对抗推演台 (Red-Blue Wargaming Matrix)
你将一人分饰两角，展开针锋相对的三轮架构攻防推演：

- 蓝军（防御守方）：
  - 简明陈述本方案的核心机制，给出数据一致性、安全性与容灾的核心假设。
- 红军（恶意攻方）：
  - 严禁提出建设性意见！你的唯一使命是找出破绽、打垮系统、造成资损或瘫痪。
  - 进攻角度聚焦：单点故障 (SPOF)、极端并发下的竞态条件 (Race Condition)、分布式死锁、脑裂分区、越权与重放、异常级联放大。
- 推演回合：
  - 第一轮：红军寻找主流程穿透点，蓝军做出防御补丁；
  - 第二轮：红军利用蓝军补丁引入的复杂度进行二次进攻，蓝军补强；
  - 第三轮：裁判角色介入，收敛交锋，输出最终的【加固清单与熔断防护矩阵】。
```
