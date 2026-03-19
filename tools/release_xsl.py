#!/usr/bin/env python3

from __future__ import annotations

import argparse
import re
import shutil
import subprocess
from pathlib import Path

from build_xsl import expand_includes


DEFAULT_SOURCE = Path("xsl/main.xsl")
DEFAULT_LAYOUT = Path("xsl/layout.xsl")
DEFAULT_DIST_DIR = Path("dist")
DEFAULT_CANONICAL_NAME = "nmap2html-standalone.xsl"
VERSION_RE = re.compile(r"Template:\s*([A-Za-z0-9._-]+)")


def detect_version(layout_path: Path) -> str:
    match = VERSION_RE.search(layout_path.read_text())
    if not match:
        raise ValueError(f"Could not detect template version from {layout_path}")
    return match.group(1)


def normalize_version(raw_version: str) -> str:
    version = raw_version.strip().lower()
    if not version.startswith("v"):
        version = f"v{version}"
    return version


def build_release(source: Path, canonical_output: Path) -> None:
    built = expand_includes(source).rstrip() + "\n"
    canonical_output.parent.mkdir(parents=True, exist_ok=True)
    canonical_output.write_text(built)


def maybe_create_git_tag(tag_name: str) -> None:
    existing = subprocess.run(
        ["git", "tag", "--list", tag_name],
        check=True,
        capture_output=True,
        text=True,
    ).stdout.strip()
    if existing:
        raise RuntimeError(f"Git tag already exists: {tag_name}")

    subprocess.run(["git", "tag", tag_name], check=True)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Build release artifacts for the standalone XSLT and optionally create a git tag."
    )
    parser.add_argument("--source", type=Path, default=DEFAULT_SOURCE)
    parser.add_argument("--layout", type=Path, default=DEFAULT_LAYOUT)
    parser.add_argument("--dist-dir", type=Path, default=DEFAULT_DIST_DIR)
    parser.add_argument("--version", help="Override detected template version.")
    parser.add_argument("--git-tag", action="store_true", help="Create a git tag for the resolved version.")
    parser.add_argument("--tag-name", help="Override the git tag name. Defaults to the normalized version.")
    args = parser.parse_args()

    version = normalize_version(args.version or detect_version(args.layout))
    canonical_output = args.dist_dir / DEFAULT_CANONICAL_NAME
    versioned_output = args.dist_dir / f"nmap2html-{version}-standalone.xsl"

    build_release(args.source, canonical_output)
    shutil.copyfile(canonical_output, versioned_output)

    print(f"Built {canonical_output}")
    print(f"Built {versioned_output}")

    if args.git_tag:
        tag_name = args.tag_name or version
        maybe_create_git_tag(tag_name)
        print(f"Created git tag {tag_name}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
