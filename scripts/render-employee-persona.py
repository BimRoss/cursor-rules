#!/usr/bin/env python3
"""Concatenate listed .mdc files into one persona markdown (frontmatter stripped)."""

from __future__ import annotations

import argparse
import re
from pathlib import Path


def strip_frontmatter(text: str) -> str:
    text = text.lstrip("\ufeff")
    if not text.startswith("---"):
        return text
    parts = text.split("---", 2)
    if len(parts) >= 3:
        return parts[2].lstrip("\n")
    return text


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument(
        "--repo-root",
        type=Path,
        default=Path(__file__).resolve().parents[1],
        help="cursor-rules repository root",
    )
    p.add_argument(
        "--manifest",
        type=Path,
        help="manifest file (one relative path per line)",
    )
    p.add_argument("--employee", required=True, help="employee id (e.g. alex)")
    p.add_argument("-o", "--out", type=Path, help="output file (default: stdout)")
    args = p.parse_args()

    root: Path = args.repo_root
    manifest = args.manifest or (root / "personas" / f"{args.employee}.manifest")
    lines = manifest.read_text(encoding="utf-8").splitlines()

    chunks: list[str] = []
    for line in lines:
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        path = root / line
        if not path.is_file():
            raise SystemExit(f"missing file: {path}")
        raw = path.read_text(encoding="utf-8")
        body = strip_frontmatter(raw).strip()
        if body:
            chunks.append(f"## {path.relative_to(root)}\n\n{body}\n")

    out = "\n\n---\n\n".join(chunks) + "\n"
    if args.out:
        args.out.write_text(out, encoding="utf-8")
    else:
        print(out, end="")


if __name__ == "__main__":
    main()
