#!/usr/bin/env python3
"""
Lint Mermaid Diagrams in Markdown Files
Ensures all Mermaid blocks comply with the project's defensive quoting and diagram-type rules.
"""

import os
import re
import sys

def check_file(path):
    issues = []
    with open(path, "r", encoding="utf-8", errors="ignore") as fp:
        lines = fp.readlines()

    in_mermaid = False
    mermaid_start_line = 0
    diagram_type = None

    for idx, line in enumerate(lines):
        line_num = idx + 1
        stripped = line.strip()

        if stripped.startswith("```mermaid"):
            in_mermaid = True
            mermaid_start_line = line_num
            diagram_type = None
            continue
        elif in_mermaid and stripped.startswith("```"):
            in_mermaid = False
            continue

        if in_mermaid:
            if diagram_type is None and stripped:
                diagram_type = stripped.split()[0]
                if diagram_type == "mindmap":
                    issues.append((line_num, "STRICTLY PROHIBITED: 'mindmap' is fragile and prone to syntax errors. Use 'graph LR' instead."))
                elif diagram_type not in ["graph", "flowchart", "stateDiagram", "stateDiagram-v2", "sequenceDiagram", "classDiagram", "erDiagram", "xychart-beta"]:
                    issues.append((line_num, f"Uncommon diagram type '{diagram_type}'. Prefer 'graph LR' or 'flowchart'."))
                continue

            # Check for unquoted nodes containing special characters like ( ) : /
            if diagram_type in ["graph", "flowchart"]:
                # Flag lines with parentheses in text that are NOT protected by ["..."]
                if re.search(r'\w+\s*(\([^\)"]+\)|\[[^\]"]*[:\(\)/][^\]"]*\])', line):
                    # Check if properly quoted
                    if not re.search(r'\["[^"]*"\]', line) and not re.search(r'\b(subgraph|style|classDef)\b', line):
                        # Potential unquoted special characters
                        if any(c in line for c in ["(", ")", "：", "/", "（", "）"]):
                            issues.append((line_num, f"Unquoted special character in node label. Must use id[\"Label text\"]: '{line.strip()}'"))

    return issues

def main():
    root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    has_errors = False
    scanned_count = 0

    for root, dirs, files in os.walk(root_dir):
        if ".git" in root or "node_modules" in root:
            continue
        for f in files:
            if f.endswith(".md"):
                p = os.path.join(root, f)
                rel_path = os.path.relpath(p, root_dir)
                issues = check_file(p)
                scanned_count += 1
                if issues:
                    has_errors = True
                    print(f"\n❌ {rel_path}:")
                    for line_num, msg in issues:
                        print(f"   Line {line_num}: {msg}")

    if not has_errors:
        print(f"✅ Mermaid Lint Passed: Checked {scanned_count} markdown files, all diagrams are 100% compliant.")
        sys.exit(0)
    else:
        print("\n⚠️ Please fix the above Mermaid syntax issues according to DEVELOPMENT.md section 3.1.")
        sys.exit(1)

if __name__ == "__main__":
    main()
