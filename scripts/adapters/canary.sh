#!/usr/bin/env bash
# ==============================================================================
# Canary Adapter (金丝雀负向自检适配器)
# 职责: 仅在 --self-test 模式下使用，注入已知的典型坏用例，验证门禁本身是否真正具备拦截能力
# ==============================================================================

adapter_name() {
    echo "canary"
}

adapter_detect() {
    # canary 仅在 --self-test 显式指定时被核心调度器激活
    if [[ "${CANARY_MODE:-0}" == "1" ]]; then
        return 0
    fi
    return 1
}

adapter_run_tests() {
    local mode="${1:-quick}"
    if [[ "${CANARY_SCENARIO:-normal}" == "test_failed" ]]; then
        echo "[CANARY ERROR] Test brokenMethodTest() failed: expected true but was false"
        return 1
    fi
    echo "[CANARY INFO] Running Canary Unit Tests... All 12 test assertions PASSED."
    return 0
}

adapter_get_crap_metrics() {
    local mode="${1:-quick}"
    # 格式规范: 函数标识|圈复杂度|行覆盖率(0.00~1.00)
    if [[ "${CANARY_SCENARIO:-normal}" == "crap_overflow" ]]; then
        # 构造坏用例: 圈复杂度 8, 覆盖率仅 20%
        # CRAP = 8^2 * (1 - 0.2)^3 + 8 = 64 * 0.512 + 8 = 32.768 + 8 = 40.768 (> 20 硬红线)
        echo "com.example.CanaryBadModule#complexUncoveredHandler|8|0.20"
        echo "com.example.CanaryGoodModule#cleanMethod|2|1.00"
    else
        # 正常状态: 全部处于健康低复杂度高覆盖率区间
        # comp=3, cov=1.0 -> CRAP = 3
        # comp=5, cov=0.9 -> CRAP = 5^2 * 0.001 + 5 = 5.025
        echo "com.example.CanaryGoodModule#healthyMethodA|3|1.00"
        echo "com.example.CanaryGoodModule#healthyMethodB|5|0.90"
    fi
}

adapter_run_mutation() {
    local mode="${1:-deliver}"
    if [[ "${CANARY_SCENARIO:-normal}" == "mutation_survived" ]]; then
        echo "[CANARY MUTATION] Found 2 SURVIVED mutants:"
        echo "  - Mutant #1: line 42 (changed 'a >= b' to 'a > b') - SURVIVED (Missing edge-case assertion)"
        echo "  - Mutant #2: line 88 (removed call to auditLog()) - SURVIVED (Missing side-effect check)"
        return 1
    fi
    echo "[CANARY MUTATION] PITest/Stryker mutation run finished. 100% mutants killed. 0 survived."
    return 0
}
