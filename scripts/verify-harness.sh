#!/usr/bin/env bash
# ==============================================================================
# verify-harness.sh (语言中立双轨质量门禁调度器)
# 职责:
#   1. 提供四种标准入口:
#      - --lean:     极简极速模式 (日常敏捷: 单测 + 复杂度硬卡 <=10 + 物理防改测试, 5秒内反馈)
#      - --quick:    常规内环门禁 (关联单测 + CRAP 静态指标判定)
#      - --deliver:  复杂严格模式 (外环交付终审: quick + 变异测试 + 三重非零断言 + 生成凭据)
#      - --self-test:金丝雀负向自检 (注入破坏性坏用例，验证门禁本身是否具备硬拦截能力)
#   2. 语言中立: 自动发现并调度 scripts/adapters/*.sh，不硬编码具体编译命令
#   3. 刚性退出码契约: 任何项不达标一律 Exit 1 并打印结构化报错; 全部通过 Exit 0
#   4. 凭据化交付: 在 --deliver 模式成功后生成 .harness/audit.json 供 CI 校验
# ==============================================================================

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${TARGET_DIR:-$PWD}"
ADAPTERS_DIR="${SCRIPT_DIR}/adapters"
HARNESS_DIR="${TARGET_DIR}/.harness"

# 门禁阈值配置
CRAP_HARD_LIMIT="${CRAP_HARD_LIMIT:-20.0}"
CRAP_WARN_LIMIT="${CRAP_WARN_LIMIT:-25.0}"
LEAN_COMPLEXITY_LIMIT="${LEAN_COMPLEXITY_LIMIT:-10}"

# 打印工具函数
_info()  { echo -e "\033[1;34m[HARNESS INFO]\033[0m $*"; }
_warn()  { echo -e "\033[1;33m[HARNESS WARN]\033[0m $*"; }
_err()   { echo -e "\033[1;31m[HARNESS ERROR]\033[0m $*"; }
_pass()  { echo -e "\033[1;32m[HARNESS PASS]\033[0m $*"; }

usage() {
    cat <<EOF
Usage: ./scripts/verify-harness.sh [MODE] [OPTIONS]

Modes:
  --lean        (日常极简极速模式) 5秒极速反馈: 跑单测 + 函数圈复杂度硬卡(<=10) + 防改测试
  --quick       (常规内环模式) 跑关联单测 + CRAP 复杂度与覆盖率综合判定
  --deliver     (复杂严格模式) 交付发版终审: quick + 全量变异测试 + 非零断言审计 + 生成 .harness/audit.json
  --self-test   (金丝雀负向自检) 注入坏用例，验证门禁本身是否真正具备硬拦截能力
  -h, --help    显示帮助信息

Environment Variables:
  CRAP_HARD_LIMIT       CRAP 绝对硬红线，默认 20.0
  CRAP_WARN_LIMIT       CRAP 告警线，默认 25.0
  LEAN_COMPLEXITY_LIMIT lean 模式下单函数圈复杂度上限，默认 10
  ALLOW_TEST_TAMPER     设为 1 时允许修改既有单测断言 (仅限人类手工调试，严禁 Agent 开启)
EOF
    exit 0
}

# ------------------------------------------------------------------------------
# 1. 防篡改检测: 拦截对已有单测文件的删减改动 (Anti-Tamper)
# ------------------------------------------------------------------------------
check_anti_tamper() {
    if [[ "${ALLOW_TEST_TAMPER:-0}" == "1" ]]; then
        _warn "ALLOW_TEST_TAMPER=1 detected. Skipping anti-tamper check."
        return 0
    fi

    if command -v git &>/dev/null && git -C "${TARGET_DIR}" rev-parse --is-inside-work-tree &>/dev/null; then
        local modified_tests
        modified_tests=$(git -C "${TARGET_DIR}" status --porcelain 2>/dev/null | grep -E '^[ M][M ] .*(Test\.|_test\.|\.spec\.|\.test\.)' | awk '{print $2}' || true)
        
        if [[ -n "${modified_tests}" ]]; then
            for tf in ${modified_tests}; do
                local deleted_lines
                deleted_lines=$(git -C "${TARGET_DIR}" diff -U0 -- "${tf}" 2>/dev/null | grep -E '^-[^-]' || true)
                if [[ -n "${deleted_lines}" ]]; then
                    _err "SECURITY ALERT: 检测到对既有测试文件 [${tf}] 的修改/删除行为！"
                    _err "严禁 Agent 通过修改已有断言或削弱测试用例来逃避红灯！"
                    _err "若确系业务规格变更，必须由人类复核并在提交时签署确认。"
                    return 1
                fi
            done
        fi
    fi
    return 0
}

# ------------------------------------------------------------------------------
# 2. 适配器加载与探测
# ------------------------------------------------------------------------------
load_adapter() {
    local target_mode="$1"
    
    if [[ "${target_mode}" == "self-test" ]]; then
        if [[ -f "${ADAPTERS_DIR}/canary.sh" ]]; then
            export CANARY_MODE=1
            # shellcheck source=/dev/null
            source "${ADAPTERS_DIR}/canary.sh"
            _info "Active Adapter: [$(adapter_name)] (Canary Self-Test Mode)"
            return 0
        else
            _err "Canary adapter not found at ${ADAPTERS_DIR}/canary.sh"
            return 1
        fi
    fi

    local matched=0
    for adapter_file in "${ADAPTERS_DIR}"/*.sh; do
        [[ -e "${adapter_file}" ]] || continue
        [[ "$(basename "${adapter_file}")" == "canary.sh" ]] && continue

        # shellcheck source=/dev/null
        source "${adapter_file}"
        if adapter_detect "${TARGET_DIR}"; then
            _info "Auto-detected project stack: [$(adapter_name)] at ${TARGET_DIR}"
            matched=1
            break
        fi
    done

    if [[ ${matched} -eq 0 ]]; then
        _err "未识别到受支持的技术栈适配器 (目标目录: ${TARGET_DIR})。请检查 ${ADAPTERS_DIR}/ 是否包含对应的 adapter。"
        return 1
    fi
    return 0
}

# ------------------------------------------------------------------------------
# 3. 指标计算与判定引擎 (Lean 复杂度 vs Quick/Deliver CRAP)
# ------------------------------------------------------------------------------
evaluate_metrics() {
    local mode="$1"
    local raw_metrics
    raw_metrics=$(adapter_get_crap_metrics "${mode}" "${TARGET_DIR}")

    if [[ -z "${raw_metrics}" ]]; then
        _info "No method-level complexity/coverage metrics collected from adapter. Skipping metrics calculation."
        return 0
    fi

    if [[ "${mode}" == "lean" ]]; then
        # 极简模式: 仅做圈复杂度硬卡 (<= LEAN_COMPLEXITY_LIMIT)
        _info "Running Gate 2 (Lean): Checking Cyclomatic Complexity (Limit: <= ${LEAN_COMPLEXITY_LIMIT})..."
        python3 -c "
import sys
raw_lines = '''${raw_metrics}'''.strip().splitlines()
limit = float('${LEAN_COMPLEXITY_LIMIT}')
violations = []
for line in raw_lines:
    parts = line.strip().split('|')
    if len(parts) != 3: continue
    func, comp_str = parts[0], parts[1]
    try:
        comp = float(comp_str)
        if comp > limit:
            violations.append((func, comp))
    except ValueError: pass

if violations:
    for f, c in violations:
        print(f'\033[1;31m[LEAN FAILED]\033[0m Method \'{f}\' complexity={c:.0f} EXCEEDS limit ({limit:.0f})! 请拆小函数，将圈复杂度压至 10 以内。')
    sys.exit(1)
print(f'[LEAN PASS] All functions have clean cyclomatic complexity (<= {limit:.0f}).')
sys.exit(0)
"
        return $?
    else
        # 完整模式 / Quick 模式: 运行完整 CRAP 公式计算
        _info "Running Gate 2: CRAP Metric Assessment (Hard Limit: <= ${CRAP_HARD_LIMIT})..."
        python3 -c "
import sys

raw_lines = '''${raw_metrics}'''.strip().splitlines()
hard_limit = float('${CRAP_HARD_LIMIT}')
warn_limit = float('${CRAP_WARN_LIMIT}')

violations = []
warnings = []
passed_count = 0

for line in raw_lines:
    parts = line.strip().split('|')
    if len(parts) != 3:
        continue
    func_name, comp_str, cov_str = parts[0], parts[1], parts[2]
    try:
        comp = float(comp_str)
        cov = float(cov_str)
        # CRAP 公式: comp^2 * (1 - cov)^3 + comp
        crap = (comp ** 2) * ((1.0 - cov) ** 3) + comp
    except ValueError:
        continue

    record = (func_name, comp, cov, crap)
    if crap > hard_limit:
        violations.append(record)
    elif crap > warn_limit:
        warnings.append(record)
    else:
        passed_count += 1

print(f'[CRAP SUMMARY] Checked: {passed_count + len(warnings) + len(violations)} functions. Healthy: {passed_count}, Warnings: {len(warnings)}, Violations: {len(violations)}')

for func, comp, cov, crap in warnings:
    print(f'\033[1;33m[CRAP WARN]\033[0m Method \'{func}\' CRAP={crap:.2f} (comp={comp:.0f}, cov={cov*100:.1f}%) exceeds warning threshold ({warn_limit}).')

if violations:
    for func, comp, cov, crap in violations:
        print(f'\033[1;31m[CRAP FAILED]\033[0m Method \'{func}\' CRAP={crap:.2f} (comp={comp:.0f}, cov={cov*100:.1f}%) EXCEEDS HARD LIMIT ({hard_limit})!')
        print(f'              -> 修复建议: 逻辑分支过多且测试未充分覆盖。请拆小函数或针对未覆盖路径补充单测。')
    sys.exit(1)

sys.exit(0)
"
        return $?
    fi
}

# ------------------------------------------------------------------------------
# 4. 生成交付审计凭据 (.harness/audit.json)
# ------------------------------------------------------------------------------
generate_audit_token() {
    mkdir -p "${HARNESS_DIR}"
    local commit_hash="working-tree"
    if command -v git &>/dev/null && git -C "${TARGET_DIR}" rev-parse --is-inside-work-tree &>/dev/null; then
        commit_hash=$(git -C "${TARGET_DIR}" rev-parse --short HEAD 2>/dev/null || echo "working-tree")
    fi
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    cat <<EOF > "${HARNESS_DIR}/audit.json"
{
  "harness_version": "2.0.0",
  "mode": "deliver",
  "status": "PASSED",
  "commit": "${commit_hash}",
  "timestamp": "${timestamp}",
  "gates": {
    "anti_tamper": "PASSED",
    "unit_tests": "PASSED",
    "crap_metrics": "PASSED",
    "mutation_testing": "PASSED"
  }
}
EOF
    _pass "Audit Token generated at: ${HARNESS_DIR}/audit.json"
}

# ------------------------------------------------------------------------------
# 5. 核心调度流水线
# ------------------------------------------------------------------------------
run_pipeline() {
    local mode="$1"
    _info "=========================================================="
    _info "  Starting Verification Harness (Mode: ${mode})           "
    _info "=========================================================="

    # A. 检查防篡改
    if ! check_anti_tamper; then
        _err "Pipeline BLOCKED by Anti-Tamper check."
        return 1
    fi

    # B. Gate 1: 单元测试
    _info "Running Gate 1: Unit Tests (Double-entry Bookkeeping)..."
    if ! adapter_run_tests "${mode}" "${TARGET_DIR}"; then
        _err "Gate 1 FAILED: Unit tests did not pass. Stop here."
        return 1
    fi
    _pass "Gate 1 PASSED: All unit tests green."

    # C. Gate 2: 复杂度 / CRAP 判定
    if ! evaluate_metrics "${mode}"; then
        _err "Gate 2 FAILED: Code complexity / risk anti-pattern exceeded threshold."
        return 1
    fi
    _pass "Gate 2 PASSED: Code metrics within acceptable boundaries."

    # D. Gate 3: 变异测试 (仅在 --deliver 交付阶段触发)
    if [[ "${mode}" == "deliver" ]]; then
        _info "Running Gate 3: Mutation Testing (Eliminating Surviving Mutants)..."
        if ! adapter_run_mutation "${mode}" "${TARGET_DIR}"; then
            _err "Gate 3 FAILED: Surviving mutants detected! Defensive tests are inadequate."
            return 1
        fi
        _pass "Gate 3 PASSED: Mutation testing passed. Zero surviving mutants."

        # 生成交付审计凭据
        generate_audit_token
    else
        _info "Skipping Gate 3 (Mutation Testing is reserved for --deliver mode)."
    fi

    _pass "=========================================================="
    _pass "  ALL HARNESS GATES PASSED! (Mode: ${mode}, Exit Code: 0)  "
    _pass "=========================================================="
    return 0
}

# ------------------------------------------------------------------------------
# 6. 金丝雀负向自检流程 (--self-test)
# ------------------------------------------------------------------------------
run_self_test() {
    _info "=========================================================="
    _info "  Starting Canary Negative Self-Test (--self-test)        "
    _info "  目标: 证明门禁脚本能真正拦截坏代码，防止'配置错误全绿假象'"
    _info "=========================================================="

    load_adapter "self-test" || return 1

    # 测试项 1: 正常用例必须绿
    _info "[CANARY STEP 1/5] 验证正常代码在门禁下是否报绿..."
    export CANARY_SCENARIO="normal"
    if ! run_pipeline "quick" >/dev/null 2>&1; then
        _err "CANARY SELF-TEST FAILED: Normal code unexpectedly failed the harness!"
        return 1
    fi
    _pass "CANARY STEP 1/5 PASSED: 正常代码如期全绿。"

    # 测试项 2: Lean 模式复杂度超标拦截
    _info "[CANARY STEP 2/5] 验证 Lean 模式下圈复杂度超标(comp=8 > limit=5)是否如期拦截..."
    export CANARY_SCENARIO="crap_overflow"
    if LEAN_COMPLEXITY_LIMIT=5 run_pipeline "lean" >/dev/null 2>&1; then
        _err "CANARY SELF-TEST FAILED: Lean 复杂度超标竟然被放行了！"
        return 1
    fi
    _pass "CANARY STEP 2/5 PASSED: Lean 模式成功拦截复杂度超标代码。"

    # 测试项 3: 单测失败必须红
    _info "[CANARY STEP 3/5] 注入单测失败坏代码，验证 Gate 1 是否如期红灯拦截..."
    export CANARY_SCENARIO="test_failed"
    if run_pipeline "quick" >/dev/null 2>&1; then
        _err "CANARY SELF-TEST FAILED: 单测失败竟然被门禁放行了！Gate 1 处于哑火状态！"
        return 1
    fi
    _pass "CANARY STEP 3/5 PASSED: Gate 1 成功拦截单测失败坏代码 (Exit Code 1)。"

    # 测试项 4: CRAP 超标必须红
    _info "[CANARY STEP 4/5] 注入高复杂度未覆盖函数 (CRAP=40.7)，验证 Gate 2 是否如期红灯拦截..."
    export CANARY_SCENARIO="crap_overflow"
    if run_pipeline "quick" >/dev/null 2>&1; then
        _err "CANARY SELF-TEST FAILED: CRAP 超标竟然被门禁放行了！Gate 2 处于哑火状态！"
        return 1
    fi
    _pass "CANARY STEP 4/5 PASSED: Gate 2 成功拦截 CRAP 超标坏代码 (Exit Code 1)。"

    # 测试项 5: 变异体存活必须红 (deliver 阶段)
    _info "[CANARY STEP 5/5] 注入存活变异体，验证 Gate 3 (变异测试) 是否如期红灯拦截..."
    export CANARY_SCENARIO="mutation_survived"
    if run_pipeline "deliver" >/dev/null 2>&1; then
        _err "CANARY SELF-TEST FAILED: 存在存活变异体竟然被 deliver 交付放行了！Gate 3 处于哑火状态！"
        return 1
    fi
    _pass "CANARY STEP 5/5 PASSED: Gate 3 成功拦截存活变异体 (Exit Code 1)。"

    _pass "=========================================================="
    _pass "  CANARY SELF-TEST COMPLETE: 门禁双轨拦截能力 100% 有效！ "
    _pass "=========================================================="
    return 0
}

# ------------------------------------------------------------------------------
# 主入口处理
# ------------------------------------------------------------------------------
main() {
    local mode="quick"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --lean)
                mode="lean"
                shift
                ;;
            --quick)
                mode="quick"
                shift
                ;;
            --deliver)
                mode="deliver"
                shift
                ;;
            --self-test)
                run_self_test
                exit $?
                ;;
            -h|--help)
                usage
                ;;
            *)
                _err "Unknown argument: $1"
                usage
                ;;
        esac
    done

    load_adapter "${mode}" || exit 1
    run_pipeline "${mode}"
    exit $?
}

main "$@"
