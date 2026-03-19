#!/usr/bin/env python3

from __future__ import annotations

import argparse
import re
from pathlib import Path


INCLUDE_RE = re.compile(r'^\s*<xsl:include href="(?P<href>[^"]+)"\s*/>\s*$', re.MULTILINE)
XML_DECL_RE = re.compile(r'^\s*<\?xml[^>]*\?>\s*\n?', re.MULTILINE)
STYLESHEET_OPEN_RE = re.compile(r'^\s*<xsl:stylesheet\b[^>]*>\s*\n?', re.MULTILINE)
STYLESHEET_CLOSE_RE = re.compile(r'\n?\s*</xsl:stylesheet>\s*$', re.MULTILINE)


def strip_stylesheet_wrapper(text: str) -> str:
    text = XML_DECL_RE.sub("", text, count=1)
    text = STYLESHEET_OPEN_RE.sub("", text, count=1)
    text = STYLESHEET_CLOSE_RE.sub("", text, count=1)
    return text.rstrip() + "\n"


def expand_includes(path: Path) -> str:
    text = path.read_text()

    def replace(match: re.Match[str]) -> str:
        include_path = (path.parent / match.group("href")).resolve()
        included = strip_stylesheet_wrapper(expand_includes(include_path))
        return included

    return INCLUDE_RE.sub(replace, text)


def main() -> int:
    parser = argparse.ArgumentParser(description="Build the single-file XSLT release from split source files.")
    parser.add_argument("source", nargs="?", default=Path("xsl/main.xsl"), type=Path)
    parser.add_argument("output", nargs="?", default=Path("dist/nmap2html-standalone.xsl"), type=Path)
    args = parser.parse_args()

    built = expand_includes(args.source).rstrip() + "\n"
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(built)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
