#!/usr/bin/env python3
"""Concatenate employee rule files into one persona markdown (frontmatter stripped).

Default: all ``.cursor/rules/{employee}-*.mdc`` files, sorted by filename.
Optional ``--manifest`` overrides with an explicit path list (legacy / escape hatch).
"""

from __future__ import annotations

import argparse
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
    p.add_argument("-o", "--out", type=Path, help="output file (default: stdout)")
    args = p.parse_args()

    root: Path = args.repo_root
    rules_dir: Path = args.rules_dir or (root / ".cursor" / "rules")

    if args.manifest is not None:
        paths = load_manifest_paths(root, args.manifest)
    else:
        paths = glob_employee_rules(rules_dir, args.employee)

    missing = [p for p in paths if not p.is_file()]
    if missing:
        for m in missing:
            print(f"missing file: {m}", file=__import__("sys").stderr)
        raise SystemExit(1)

    if not paths:
        raise SystemExit(
            f"no rules matched {rules_dir}/{args.employee}-*.mdc "
            f"(add .mdc files with that prefix, or pass --manifest)"
        )

    chunks: list[str] = []
    for path in paths:
        raw = path.read_text(encoding="utf-8")
        body = strip_frontmatter(raw).strip()
        if body:
            try:
                rel = path.relative_to(root)
            except ValueError:
                rel = path
            chunks.append(f"## {rel}\n\n{body}\n")

    out = "\n\n---\n\n".join(chunks) + "\n"
    if args.out:
        args.out.write_text(out, encoding="utf-8")
    else:
        print(out, end="")


if __name__ == "__main__":
    main()
