#!/usr/bin/env bash
# ==============================================================================
# Java Adapter (Uncle Bob 武器库适配器: Maven/Gradle + JUnit + JaCoCo + PITest)
# 职责: 仅负责把 Java 技术栈的具体测试/覆盖率/变异工具调用收敛到标准契约
# ==============================================================================

adapter_name() {
    echo "java"
}

adapter_detect() {
    local target_dir="${1:-.}"
    if [[ -f "${target_dir}/pom.xml" || -f "${target_dir}/build.gradle" || -f "${target_dir}/build.gradle.kts" ]]; then
        return 0
    fi
    return 1
}

_resolve_build_tool() {
    local target_dir="${1:-.}"
    if [[ -f "${target_dir}/gradlew" ]]; then
        echo "${target_dir}/gradlew"
    elif [[ -f "${target_dir}/mvnw" ]]; then
        echo "${target_dir}/mvnw"
    elif command -v gradle &> /dev/null; then
        echo "gradle"
    elif command -v mvn &> /dev/null; then
        echo "mvn"
    else
        echo ""
    fi
}

adapter_run_tests() {
    local mode="${1:-quick}"
    local target_dir="${2:-.}"
    local tool
    tool="$(_resolve_build_tool "${target_dir}")"

    if [[ -z "${tool}" ]]; then
        echo "[JAVA ADAPTER ERROR] Neither Gradle (gradlew/gradle) nor Maven (mvnw/mvn) found in path."
        return 1
    fi

    echo "[JAVA ADAPTER] Running Java Unit Tests using ${tool} (mode: ${mode})..."
    if [[ "${tool}" == *"gradle"* ]]; then
        "${tool}" test --console=plain
    else
        "${tool}" test -B
    fi
    return $?
}

adapter_get_crap_metrics() {
    local mode="${1:-quick}"
    local target_dir="${2:-.}"
    
    # 标准格式: 函数全限定名|圈复杂度(comp)|覆盖率(0.00~1.00)
    # 本函数负责从 JaCoCo XML 报告与字节码/AST 分析提取圈复杂度与行覆盖率
    # 示例输出契约:
    # com.example.service.OrderService#calculateDiscount|8|0.75
    
    local jacoco_report=""
    if [[ -f "${target_dir}/build/reports/jacoco/test/jacoco.xml" ]]; then
        jacoco_report="${target_dir}/build/reports/jacoco/test/jacoco.xml"
    elif [[ -f "${target_dir}/target/site/jacoco/jacoco.xml" ]]; then
        jacoco_report="${target_dir}/target/site/jacoco/jacoco.xml"
    fi

    if [[ -z "${jacoco_report}" ]]; then
        # 报告未生成时，返回空，核心调度器将提示缺少覆盖率报告
        return 0
    fi

    # 轻量解析 JaCoCo XML 中的方法圈复杂度与覆盖行
    # (在真实工程中由 python/awk 快速解析 counter type="COMPLEXITY" 和 "INSTRUCTION")
    python3 -c "
import xml.etree.ElementTree as ET
import sys

try:
    tree = ET.parse('${jacoco_report}')
    root = tree.getroot()
    for package in root.findall('package'):
        pkg_name = package.get('name').replace('/', '.')
        for cls in package.findall('class'):
            cls_name = cls.get('name').replace('/', '.')
            for method in cls.findall('method'):
                m_name = method.get('name')
                if m_name in ['<init>', '<clinit>']:
                    continue
                comp = 1
                cov = 1.0
                for counter in method.findall('counter'):
                    c_type = counter.get('type')
                    missed = int(counter.get('missed', 0))
                    covered = int(counter.get('covered', 0))
                    total = missed + covered
                    if c_type == 'COMPLEXITY':
                        comp = total
                    elif c_type == 'INSTRUCTION' or c_type == 'LINE':
                        if total > 0:
                            cov = round(covered / total, 3)
                print(f'{cls_name}#{m_name}|{comp}|{cov}')
except Exception:
    pass
" 2>/dev/null
}

adapter_run_mutation() {
    local mode="${1:-deliver}"
    local target_dir="${2:-.}"
    local tool
    tool="$(_resolve_build_tool "${target_dir}")"

    if [[ -z "${tool}" ]]; then
        echo "[JAVA ADAPTER ERROR] Build tool not found for mutation testing."
        return 1
    fi

    echo "[JAVA ADAPTER] Triggering PITest mutation testing via ${tool}..."
    if [[ "${tool}" == *"gradle"* ]]; then
        "${tool}" pitest --console=plain
    else
        "${tool}" org.pitest:pitest-maven:mutationCoverage -B
    fi
    local exit_code=$?

    # 检查存活变异体报告
    # PITest 默认生成在 build/reports/pitest 或 target/pit-reports
    return ${exit_code}
}
