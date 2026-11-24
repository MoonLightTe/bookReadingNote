#!/usr/bin/env python3
"""
mastery_state.py - 硬核学习规划器状态流转引擎 (Mastery Planner State Engine)
用法:
  python3 scripts/mastery_state.py status [--all]
  python3 scripts/mastery_state.py start <node-id> [--file <path>]
  python3 scripts/mastery_state.py pass <node-id> [--file <path>]
  python3 scripts/mastery_state.py fail <node-id> --weak "<weak_point>" [--file <path>]
  python3 scripts/mastery_state.py review <node-id> [--file <path>]
"""

import sys
import os
import argparse
import datetime
from pathlib import Path

try:
    import yaml
except ImportError:
    print("错误: 缺少 PyYAML 库，请运行 pip3 install pyyaml", file=sys.stderr)
    sys.exit(1)

REVIEW_INTERVALS = {
    1: 1,   # 1 天
    2: 3,   # 3 天
    3: 7,   # 7 天
    4: 14,  # 14 天
}

def find_state_file(explicit_path=None) -> Path:
    if explicit_path:
        p = Path(explicit_path)
        if p.exists():
            return p
        raise FileNotFoundError(f"未找到指定的状态文件: {explicit_path}")

    # 1. 当前目录
    cur = Path("./study-state.yaml")
    if cur.exists():
        return cur

    # 2. 扫描 learning-tasks/ 下的子目录
    candidates = list(Path("./learning-tasks").glob("*/study-state.yaml"))
    if len(candidates) == 1:
        return candidates[0]
    elif len(candidates) > 1:
        # 按修改时间找最近更新的一个
        candidates.sort(key=lambda x: x.stat().st_mtime, reverse=True)
        return candidates[0]

    raise FileNotFoundError("未探测到任何 study-state.yaml 文件")

def load_yaml(file_path: Path) -> dict:
    with open(file_path, "r", encoding="utf-8") as f:
        data = yaml.safe_load(f) or {}
    return data

def save_yaml(file_path: Path, data: dict):
    # 原子写入：写临时文件再重命名，杜绝内容损坏
    tmp_path = file_path.with_suffix(".tmp")
    with open(tmp_path, "w", encoding="utf-8") as f:
        yaml.dump(data, f, allow_unicode=True, sort_keys=False)
    tmp_path.replace(file_path)

def auto_unlock_dag(nodes: list[dict]) -> list[str]:
    """根据拓扑依赖，自动将所有前置已满足的 locked 节点解锁为 ready"""
    unlocked = []
    node_map = {n["id"]: n for n in nodes}
    mastered_ids = {n["id"] for n in nodes if n.get("status") == "mastered"}

    for n in nodes:
        if n.get("status") == "locked":
            prereqs = n.get("prereqs", [])
            if all(p in mastered_ids for p in prereqs):
                n["status"] = "ready"
                unlocked.append(n["id"])
    return unlocked

def cmd_status(args):
    target_files = []
    if args.all:
        target_files = list(Path("./learning-tasks").glob("*/study-state.yaml"))
        if Path("./study-state.yaml").exists() and Path("./study-state.yaml") not in target_files:
            target_files.append(Path("./study-state.yaml"))
    else:
        target_files = [find_state_file(args.file)]

    today = datetime.date.today()

    for sf in target_files:
        data = load_yaml(sf)
        topic = data.get("topic", sf.parent.name)
        nodes = data.get("nodes", [])
        total = len(nodes)
        mastered = sum(1 for n in nodes if n.get("status") == "mastered")
        pct = (mastered / total * 100) if total > 0 else 0

        # 检查休眠天数
        mtime = datetime.date.fromtimestamp(sf.stat().st_mtime)
        inactive_days = (today - mtime).days

        print(f"\n==================================================")
        print(f"📊 主题: {topic} (路径: {sf})")
        print(f"📈 进度: {mastered}/{total} 通关 ({pct:.1f}%) | 每日预算: {data.get('daily_budget_min', 60)}m")
        if inactive_days >= 7:
            print(f"⚠️  警告: 本主题已休眠 {inactive_days} 天未推进！")
        print(f"--------------------------------------------------")

        for n in nodes:
            nid = n.get("id")
            title = n.get("title", "")
            status = n.get("status", "unknown")
            diff = n.get("difficulty", "medium")
            review_date = n.get("next_review")

            status_icons = {
                "mastered": "🟢 [MASTERED]",
                "in_progress": "🟡 [IN_PROGRESS]",
                "ready": "⚪ [READY]",
                "locked": "🔒 [LOCKED]"
            }
            icon = status_icons.get(status, f"[{status}]")
            extra = []
            if review_date:
                r_date = datetime.date.fromisoformat(str(review_date))
                if r_date <= today:
                    extra.append(f"⏰ 到期复习: {review_date}")
                else:
                    extra.append(f"复习日: {review_date}")
            if n.get("weak_points"):
                extra.append(f"盲区: {len(n['weak_points'])}项")

            extra_str = f" ({', '.join(extra)})" if extra else ""
            print(f"  {icon} {nid}: {title} [{diff}]{extra_str}")

def cmd_start(args):
    sf = find_state_file(args.file)
    data = load_yaml(sf)
    target = None
    for n in data.get("nodes", []):
        if n["id"] == args.node_id:
            target = n
            break

    if not target:
        print(f"错误: 节点 {args.node_id} 不存在", file=sys.stderr)
        sys.exit(1)

    if target.get("status") not in ("ready", "in_progress"):
        print(f"警告: 节点 {args.node_id} 当前状态为 {target.get('status')}，强制领工", file=sys.stderr)

    target["status"] = "in_progress"
    save_yaml(sf, data)
    print(f"🚀 成功领工！节点 [{target['id']}: {target['title']}] 状态变更为 in_progress")

def cmd_pass(args):
    sf = find_state_file(args.file)
    data = load_yaml(sf)
    nodes = data.get("nodes", [])
    target = None
    for n in nodes:
        if n["id"] == args.node_id:
            target = n
            break

    if not target:
        print(f"错误: 节点 {args.node_id} 不存在", file=sys.stderr)
        sys.exit(1)

    # 1. 更新本节点状态
    target["status"] = "mastered"
    cur_stage = target.get("review_stage", 0) + 1
    target["review_stage"] = cur_stage

    # 2. 计算下一次复习时间
    days = REVIEW_INTERVALS.get(cur_stage, 14)
    next_date = datetime.date.today() + datetime.timedelta(days=days)
    target["next_review"] = next_date.isoformat()

    # 3. 自动拓扑解锁下游
    unlocked = auto_unlock_dag(nodes)

    save_yaml(sf, data)
    print(f"🎉 节点 [{target['id']}: {target['title']}] 成功通过门禁转为 MASTERED！")
    print(f"📅 设定下次复习日期: {target['next_review']} (Stage {cur_stage})")
    if unlocked:
        print(f"🔓 自动拓扑解锁下游节点: {', '.join(unlocked)} -> READY")

def cmd_fail(args):
    sf = find_state_file(args.file)
    data = load_yaml(sf)
    target = None
    for n in data.get("nodes", []):
        if n["id"] == args.node_id:
            target = n
            break

    if not target:
        print(f"错误: 节点 {args.node_id} 不存在", file=sys.stderr)
        sys.exit(1)

    target["status"] = "in_progress"
    if "weak_points" not in target or not isinstance(target["weak_points"], list):
        target["weak_points"] = []
    
    if args.weak and args.weak not in target["weak_points"]:
        target["weak_points"].append(args.weak)

    save_yaml(sf, data)
    print(f"⚠️ 节点 [{target['id']}] 记录盲区: {args.weak}，保持 in_progress")

def cmd_review(args):
    cmd_pass(args)

def main():
    parser = argparse.ArgumentParser(description="Mastery Planner 状态流转机 CLI")
    subparsers = parser.add_subparsers(dest="cmd", required=True)

    # status
    p_status = subparsers.add_parser("status", help="查看学习看板与拓扑进度")
    p_status.add_argument("--all", action="store_true", help="扫描全库所有主题")
    p_status.add_argument("--file", help="显式指定 study-state.yaml 路径")
    p_status.set_defaults(func=cmd_status)

    # start
    p_start = subparsers.add_parser("start", help="领取节点进入 in_progress")
    p_start.add_argument("node_id", help="节点 ID (如 N1)")
    p_start.add_argument("--file", help="显式指定 study-state.yaml 路径")
    p_start.set_defaults(func=cmd_start)

    # pass
    p_pass = subparsers.add_parser("pass", help="通过门禁，标记为 mastered 并自动解锁下游")
    p_pass.add_argument("node_id", help="节点 ID (如 N1)")
    p_pass.add_argument("--file", help="显式指定 study-state.yaml 路径")
    p_pass.set_defaults(func=cmd_pass)

    # fail
    p_fail = subparsers.add_parser("fail", help="门禁未通过或卡壳，记录 weak_points")
    p_fail.add_argument("node_id", help="节点 ID (如 N1)")
    p_fail.add_argument("--weak", required=True, help="具体的认知盲区描述")
    p_fail.add_argument("--file", help="显式指定 study-state.yaml 路径")
    p_fail.set_defaults(func=cmd_fail)

    # review
    p_review = subparsers.add_parser("review", help="完成到期主动回忆复习")
    p_review.add_argument("node_id", help="节点 ID (如 N1)")
    p_review.add_argument("--file", help="显式指定 study-state.yaml 路径")
    p_review.set_defaults(func=cmd_review)

    args = parser.parse_args()
    args.func(args)

if __name__ == "__main__":
    main()
