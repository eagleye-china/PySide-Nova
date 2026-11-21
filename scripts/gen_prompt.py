# scripts/gen_prompt.py
# 依据 docs/SESSION_HANDOFF.md 交接快照，实时生成会话接续提示词 PROMPT.md
"""根据交接快照实时更新会话接续提示词 PROMPT.md。

用法::

    python scripts/gen_prompt.py            # 从快照生成/刷新项目根目录 PROMPT.md
    python scripts/gen_prompt.py --check    # 仅校验快照与 PROMPT 是否过期（CI 可用）

交付纪律（宪法第 9 章）：每次交付更新 SESSION_HANDOFF.md 后必须运行本脚本，
保证 PROMPT.md 与快照实时同步。
"""
import argparse
import re
import subprocess
from datetime import date
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SNAPSHOT = ROOT / "docs" / "SESSION_HANDOFF.md"
TEMPLATE = ROOT / "docs" / "templates" / "PROMPT_TEMPLATE.md"
OUTPUT = ROOT / "PROMPT.md"

QUASAR_BASELINE = "2.26.0"


def snapshot_meta() -> dict:
    """从快照头部提取版本与日期。"""
    text = SNAPSHOT.read_text(encoding="utf-8")
    meta = {"DATE": date.today().isoformat(), "VERSION": "unknown"}
    m = re.search(r"更新于\s*(\S+)\s*·\s*(\d{4}-\d{2}-\d{2})", text)
    if m:
        meta["VERSION"], meta["DATE"] = m.group(1), m.group(2)
    return meta


def git_head() -> str:
    try:
        return subprocess.run(
            ["git", "rev-parse", "--short", "HEAD"],
            cwd=str(ROOT), capture_output=True, text=True, check=True,
        ).stdout.strip()
    except Exception:
        return "unknown"


def render(meta: dict) -> str:
    prompt = TEMPLATE.read_text(encoding="utf-8")
    # 剥离模板使用说明（首个 "---" 之前），只保留可粘贴的提示词正文
    marker = "\n---\n"
    if marker in prompt:
        prompt = prompt.split(marker, 1)[1]
    prompt = (prompt.replace("{{DATE}}", meta["DATE"])
                    .replace("{{VERSION}}", meta["VERSION"])
                    .replace("{{QUASAR_BASELINE}}", QUASAR_BASELINE)
                    .replace("{{WORK_FOCUS}}", "（此处可留空或填写本会话想做的事）"))
    prompt += (f"\n## 快照指纹\n\n- 快照版本：{meta['VERSION']}（{meta['DATE']}）\n"
               f"- git HEAD：{git_head()}\n")
    return prompt


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--check", action="store_true",
                    help="仅校验 PROMPT.md 是否与快照同步（不写文件）")
    args = ap.parse_args()

    meta = snapshot_meta()
    fresh = render(meta)

    if args.check:
        stale = (not OUTPUT.exists()
                 or meta["VERSION"] not in OUTPUT.read_text(encoding="utf-8"))
        print(f"[check] 快照 v{meta['VERSION']}（{meta['DATE']}）→ "
              f"PROMPT.md {'过期，需运行 gen_prompt.py 刷新' if stale else '同步 ✓'}")
        raise SystemExit(1 if stale else 0)

    OUTPUT.write_text(fresh, encoding="utf-8")
    print(f"[ok] 已生成 {OUTPUT.relative_to(ROOT).as_posix()} "
          f"（快照 v{meta['VERSION']} · {meta['DATE']} · HEAD {git_head()}）")


if __name__ == "__main__":
    main()
