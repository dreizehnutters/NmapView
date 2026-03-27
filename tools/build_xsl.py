#!/usr/bin/env python3

from __future__ import annotations

import argparse
import re
from pathlib import Path


INCLUDE_RE = re.compile(r'^\s*<xsl:include href="(?P<href>[^"]+)"\s*/>\s*$', re.MULTILINE)
ASSET_RE = re.compile(
    r'^(?P<indent>\s*)<\?include-asset\s+type="(?P<type>js|css)"\s+href="(?P<href>[^"]+)"\s*\?>\s*$',
    re.MULTILINE,
)
XML_DECL_RE = re.compile(r'^\s*<\?xml[^>]*\?>\s*\n?', re.MULTILINE)
STYLESHEET_OPEN_RE = re.compile(r'^\s*<xsl:stylesheet\b[^>]*>\s*\n?', re.MULTILINE)
STYLESHEET_CLOSE_RE = re.compile(r'\n?\s*</xsl:stylesheet>\s*$', re.MULTILINE)


def strip_stylesheet_wrapper(text: str) -> str:
    text = XML_DECL_RE.sub("", text, count=1)
    text = STYLESHEET_OPEN_RE.sub("", text, count=1)
    text = STYLESHEET_CLOSE_RE.sub("", text, count=1)
    return text.rstrip() + "\n"


def wrap_asset(asset_type: str, content: str, indent: str) -> str:
    tag_name = "script" if asset_type == "js" else "style"
    safe_content = content.rstrip().replace("]]>", "]]]]><![CDATA[>")
    return f"{indent}<{tag_name}><![CDATA[\n{safe_content}\n{indent}]]></{tag_name}>"


def expand_assets(text: str, base: Path) -> str:
    def replace(match: re.Match[str]) -> str:
        asset_path = (base / match.group("href")).resolve()
        content = asset_path.read_text(encoding="utf-8")
        return wrap_asset(match.group("type"), content, match.group("indent"))

    return ASSET_RE.sub(replace, text)


def expand_includes(path: Path) -> str:
    text = path.read_text(encoding="utf-8")

    def replace(match: re.Match[str]) -> str:
        include_path = (path.parent / match.group("href")).resolve()
        included = strip_stylesheet_wrapper(expand_includes(include_path))
        return included

    text = INCLUDE_RE.sub(replace, text)
    return expand_assets(text, path.parent)


def main() -> int:
    parser = argparse.ArgumentParser(description="Build the single-file XSLT release from split source files.")
    parser.add_argument("source", nargs="?", default=Path("xsl/main.xsl"), type=Path)
    parser.add_argument("output", nargs="?", default=Path("dist/NmapView.xsl"), type=Path)
    args = parser.parse_args()

    built = expand_includes(args.source).rstrip() + "\n"
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(built, encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
