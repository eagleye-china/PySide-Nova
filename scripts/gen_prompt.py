# scripts/gen_prompt.py
# 依据 docs/SESSION_HANDOFF.md 交接快照，生成**自包含**的会话接续提示词 PROMPT.md
"""生成自包含的会话接续提示词 PROMPT.md（快照全文内联，单文件即可接续）。

用法::

    python scripts/gen_prompt.py            # 从快照生成/刷新项目根目录 PROMPT.md
    python scripts/gen_prompt.py --check    # 校验 PROMPT 与快照是否同步（CI 可用）

设计（0.3.4 起）：不再让新会话去翻 4 个文件，而是把交接快照全文内联进 PROMPT.md，
宪法/PARITY 等改为"按需深读"。快照仍是唯一事实源（source of truth），
PROMPT.md 是它的可粘贴投影；`--check` 用内容指纹判定是否过期。

交付纪律（宪法第 9 章）：每次交付更新 SESSION_HANDOFF.md 后必须运行本脚本。
"""
import argparse
import hashlib
import re
import subprocess
from datetime import date, datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SNAPSHOT = ROOT / "docs" / "SESSION_HANDOFF.md"
TEMPLATE = ROOT / "docs" / "templates" / "PROMPT_TEMPLATE.md"
OUTPUT = ROOT / "PROMPT.md"

QUASAR_BASELINE = "2.35.5"
WEEK = "一二三四五六日"


def snapshot_meta(text: str) -> dict:
    """从快照头部提取版本与日期。"""
    meta = {"DATE": date.today().isoformat(), "VERSION": "unknown"}
    m = re.search(r"更新于\s*(\S+)\s*·\s*(\d{4}-\d{2}-\d{2})", text)
    if m:
        meta["VERSION"], meta["DATE"] = m.group(1), m.group(2)
    return meta


def snapshot_body(text: str) -> str:
    """把快照转成可内联的正文：去掉 H1 标题与使用说明引用块，标题降一级。"""
    body: list[str] = []
    seen_heading = False
    for ln in text.split("\n"):
        if ln.startswith("# "):
            continue                                  # 去 H1（由提示词结构接管）
        if ln.startswith("## "):
            seen_heading = True
        if ln.startswith(">") and not seen_heading:
            continue                                  # 去首个 H2 之前的使用说明引用块
        if ln.startswith("## "):
            ln = "#" + ln                             # H2 → H3，嵌套进"第一步"
        elif ln.startswith("### "):
            ln = "#" + ln
        body.append(ln)
    return "\n".join(body).strip()


def fingerprint(text: str) -> str:
    """快照内容指纹（前 12 位），用于 --check 判定 PROMPT 是否过期。"""
    return hashlib.sha256(text.encode("utf-8")).hexdigest()[:12]


def git_head() -> str:
    try:
        return subprocess.run(
            ["git", "rev-parse", "--short", "HEAD"],
            cwd=str(ROOT), capture_output=True, text=True, check=True,
        ).stdout.strip()
    except Exception:
        return "unknown"


def render(meta: dict, body: str, fp: str) -> str:
    prompt = TEMPLATE.read_text(encoding="utf-8")
    # 剥离模板使用说明（首个 "---" 之前），只保留可粘贴的提示词正文
    marker = "\n---\n"
    if marker in prompt:
        prompt = prompt.split(marker, 1)[1]
    now = datetime.now()
    prompt = (prompt.replace("{{SNAPSHOT}}", body)
                    .replace("{{DATE}}", meta["DATE"])
                    .replace("{{VERSION}}", meta["VERSION"])
                    .replace("{{QUASAR_BASELINE}}", QUASAR_BASELINE)
                    .replace("{{WORK_FOCUS}}", "（此处可留空或填写本会话想做的事）"))
    prompt += (f"\n## 快照指纹\n\n"
               f"- 快照版本：{meta['VERSION']}（{meta['DATE']}）\n"
               f"- 内容指纹：`{fp}`\n"
               f"- git HEAD：{git_head()}\n"
               f"- 生成时间：{now:%Y-%m-%d %H:%M}（星期{WEEK[now.weekday()]}）\n"
               f"- 生成器：`scripts/gen_prompt.py`（PROMPT.md 勿手改，改快照后重新生成）\n")
    return prompt.lstrip("\n")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--check", action="store_true",
                    help="仅校验 PROMPT.md 是否与快照同步（不写文件）")
    args = ap.parse_args()

    text = SNAPSHOT.read_text(encoding="utf-8")
    meta = snapshot_meta(text)
    fp = fingerprint(text)
    fresh = render(meta, snapshot_body(text), fp)

    if args.check:
        stale = (not OUTPUT.exists()
                 or fp not in OUTPUT.read_text(encoding="utf-8"))
        print(f"[check] 快照 v{meta['VERSION']}（{meta['DATE']}）指纹 {fp} → "
              f"PROMPT.md {'过期，请运行 gen_prompt.py' if stale else '同步 ✓'}")
        raise SystemExit(1 if stale else 0)

    OUTPUT.write_text(fresh, encoding="utf-8")
    print(f"[ok] 已生成 {OUTPUT.relative_to(ROOT).as_posix()}（自包含 {len(fresh)} 字符 · "
          f"快照 v{meta['VERSION']} · 指纹 {fp}）")


if __name__ == "__main__":
    main()
