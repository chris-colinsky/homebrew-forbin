#!/usr/bin/env python3
"""Merge bottle JSON files and update the bottle do block in a Homebrew formula."""

import json
import re
import sys
from pathlib import Path

TAG_ORDER = [
    "arm64_sequoia",
    "arm64_sonoma",
    "arm64_ventura",
    "arm64_monterey",
    "sequoia",
    "sonoma",
    "ventura",
    "monterey",
    "big_sur",
    "x86_64_linux",
]


def main():
    if len(sys.argv) != 3:
        print("Usage: update_bottle_block.py <bottles_dir> <formula_path>")
        sys.exit(1)

    bottles_dir = Path(sys.argv[1])
    formula_path = Path(sys.argv[2])

    tags: dict[str, str] = {}
    root_url: str | None = None

    rebuild = 0
    for json_file in sorted(bottles_dir.glob("*.bottle*.json")):
        data = json.loads(json_file.read_text())
        formula_data = next(iter(data.values()))
        bottle = formula_data["bottle"]
        root_url = root_url or bottle["root_url"]
        rebuild = max(rebuild, bottle.get("rebuild", 0))
        for tag, info in bottle["tags"].items():
            tags[tag] = info["sha256"]

    if not tags:
        print("ERROR: No .bottle.json files found in", bottles_dir)
        sys.exit(1)

    print(f"Bottles found: {', '.join(tags)}")

    sorted_tags = sorted(
        tags, key=lambda t: TAG_ORDER.index(t) if t in TAG_ORDER else 99
    )
    max_len = max(len(t) for t in sorted_tags)

    lines = ["  bottle do"]
    if rebuild:
        lines.append(f"    rebuild {rebuild}")
    lines.append(f'    root_url "{root_url}"')
    for tag in sorted_tags:
        pad = " " * (max_len - len(tag))
        lines.append(
            f'    sha256 cellar: :any_skip_relocation, {tag}:{pad} "{tags[tag]}"'
        )
    lines.append("  end")
    block = "\n".join(lines)

    formula = formula_path.read_text()

    # Replace existing bottle block, or insert after license line
    if re.search(r"  bottle do\n", formula):
        formula = re.sub(
            r"  bottle do\n(?:.*\n)*?  end\n", block + "\n", formula
        )
    else:
        formula = re.sub(
            r'(  license "[^"]+"\n)', f"\\1\n{block}\n", formula
        )

    formula_path.write_text(formula)
    print(f"Updated {formula_path}")


if __name__ == "__main__":
    main()
