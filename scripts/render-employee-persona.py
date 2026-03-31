#!/usr/bin/env python3
"""Concatenate employee rule files into one persona markdown (frontmatter stripped).

If ``.cursor/rules/bimross-company.mdc`` exists, it is prepended first (shared company identity).

Default: all ``.cursor/rules/{employee}-*.mdc`` files, sorted by filename.
Optional ``--manifest`` overrides with an explicit path list (legacy / escape hatch).

Use ``--compact`` for Slack / LLM system prompts: short section titles, no ``---``
separators, ``{employee}-core`` first, and excludes ``{employee}-trigger`` and
``{employee}-factory`` (Cursor-only orchestration that duplicates other rules).
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


def strip_frontmatter(text: str) -> str:
    text = text.lstrip("\ufeff")
    if not text.startswith("---"):
        return text
    parts = text.split("---", 2)
    if len(parts) >= 3:
        return parts[2].lstrip("\n")
    return text


def glob_employee_rules(rules_dir: Path, employee: str) -> list[Path]:
    pattern = f"{employee}-*.mdc"
    paths = sorted(rules_dir.glob(pattern))
    return paths


def sort_persona_paths(paths: list[Path], employee: str) -> list[Path]:
    """Place ``{employee}-core.mdc`` first; rest lexicographic by basename."""
    core_name = f"{employee}-core.mdc"
    core = [p for p in paths if p.name == core_name]
    rest = sorted((p for p in paths if p.name != core_name), key=lambda p: p.name)
    return core + rest


def load_exclude_file(path: Path) -> set[str]:
    """Basenames to skip, one per line; ``#`` starts a comment."""
    out: set[str] = set()
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        out.add(line)
    return out


def normalize_compact_body(text: str) -> str:
    """Collapse runs of 3+ newlines to 2 (saves tokens; keeps paragraph breaks)."""
    return re.sub(r"\n{3,}", "\n\n", text.strip())


def load_manifest_paths(root: Path, manifest: Path) -> list[Path]:
    lines = manifest.read_text(encoding="utf-8").splitlines()
    out: list[Path] = []
    for line in lines:
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        out.append(root / line)
    return out


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument(
        "--repo-root",
        type=Path,
        default=Path(__file__).resolve().parents[1],
        help="cursor-rules repository root",
    )
    p.add_argument(
        "--rules-dir",
        type=Path,
        help="directory containing *.mdc rules (default: <repo-root>/.cursor/rules)",
    )
    p.add_argument(
        "--manifest",
        type=Path,
        help="optional manifest file (one relative path per line); disables glob",
    )
    p.add_argument("--employee", required=True, help="employee id (e.g. alex, tim)")
    p.add_argument(
        "--compact",
        action="store_true",
        help="Slack/LLM mode: short headings, no horizontal rules, core first, "
        "exclude trigger/factory .mdc (Cursor meta; use --include-meta to keep them)",
    )
    p.add_argument(
        "--include-meta",
        action="store_true",
        help="With --compact, still include {employee}-trigger and {employee}-factory",
    )
    p.add_argument(
        "--exclude",
        action="append",
        default=[],
        metavar="BASENAME",
        help="exclude a rule by basename (repeatable), e.g. alex-growth-levers.mdc",
    )
    p.add_argument(
        "--exclude-file",
        type=Path,
        metavar="PATH",
        help="file with one basename per line (# comments); merged with --exclude",
    )
    p.add_argument(
        "--stats",
        action="store_true",
        help="print file count and output bytes to stderr",
    )
    p.add_argument("-o", "--out", type=Path, help="output file (default: stdout)")
    args = p.parse_args()

    root: Path = args.repo_root
    rules_dir: Path = args.rules_dir or (root / ".cursor" / "rules")
    emp = args.employee.strip()

    if args.manifest is not None:
        paths = load_manifest_paths(root, args.manifest)
    else:
        paths = glob_employee_rules(rules_dir, emp)

    exclude_names = set(args.exclude)
    if args.compact and not args.include_meta:
        exclude_names |= {f"{emp}-trigger.mdc", f"{emp}-factory.mdc"}
    if args.exclude_file is not None:
        if not args.exclude_file.is_file():
            print(f"exclude-file not found: {args.exclude_file}", file=sys.stderr)
            raise SystemExit(1)
        exclude_names |= load_exclude_file(args.exclude_file)

    paths = [p for p in paths if p.name not in exclude_names]

    if not args.manifest:
        paths = sort_persona_paths(paths, emp)

    missing = [p for p in paths if not p.is_file()]
    if missing:
        for m in missing:
            print(f"missing file: {m}", file=__import__("sys").stderr)
        raise SystemExit(1)

    if not paths:
        raise SystemExit(
            f"no rules matched {rules_dir}/{emp}-*.mdc "
            f"(add .mdc files with that prefix, or pass --manifest)"
        )

    chunks: list[str] = []
    company_path = rules_dir / "bimross-company.mdc"
    if company_path.is_file():
        raw = company_path.read_text(encoding="utf-8")
        body = strip_frontmatter(raw).strip()
        if body:
            if args.compact:
                body = normalize_compact_body(body)
            chunks.append(f"## bimross-company\n\n{body}\n")

    for path in paths:
        raw = path.read_text(encoding="utf-8")
        body = strip_frontmatter(raw).strip()
        if args.compact:
            body = normalize_compact_body(body)
        if body:
            if args.compact:
                heading = path.stem
            else:
                try:
                    rel = path.relative_to(root)
                except ValueError:
                    rel = path
                heading = str(rel)
            chunks.append(f"## {heading}\n\n{body}\n")

    sep = "\n\n" if args.compact else "\n\n---\n\n"
    out = sep.join(chunks) + "\n"
    if args.stats:
        n = len(chunks)
        b = len(out.encode("utf-8"))
        print(f"persona render: sections={n} bytes_utf8={b}", file=sys.stderr)
    if args.out:
        args.out.write_text(out, encoding="utf-8")
    else:
        print(out, end="")


if __name__ == "__main__":
    main()
