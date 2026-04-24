"""
Render a tree from a list of paths or bare filenames.

Reads entries (one per line) from a file argument or stdin. For each entry:
  - If it exists relative to cwd (or is an absolute path that exists), it is
    used as-is.
  - If it is a bare filename that does NOT exist at cwd, the script searches
    for it recursively under cwd, skipping noisy dirs (.git, .venv, etc.).

The rendered tree shows the project root as the top node (cwd name, or the
common first component of all paths if they share one). Directories carry a
trailing '/'; files do not.

Usage:
    uv run python tree_fromfile.py lista.txt
    git diff --cached --name-only | uv run python tree_fromfile.py
"""

import sys
from pathlib import Path

SKIP_DIRS = {
    ".git", ".venv", "venv", "env",
    "node_modules", "__pycache__", ".pytest_cache",
    ".mypy_cache", ".ruff_cache", ".ipynb_checkpoints",
}


def search_filename(name: str, search_root: Path) -> list[Path]:
    """Recursively search for files matching basename, skipping noisy dirs.
    Stops after 2 matches (enough to detect ambiguity)."""
    matches: list[Path] = []
    for p in search_root.rglob(name):
        rel_parts = p.relative_to(search_root).parts
        if any(part in SKIP_DIRS for part in rel_parts):
            continue
        matches.append(p)
        if len(matches) >= 2:
            break
    return matches


def resolve(entry: str, cwd: Path) -> Path | None:
    """Resolve a user-provided entry to a path relative to cwd."""
    p = Path(entry)

    # Absolute path
    if p.is_absolute():
        if not p.exists():
            return None
        try:
            return p.relative_to(cwd)
        except ValueError:
            return p  # outside cwd; keep absolute

    # Relative path that exists from cwd
    if (cwd / p).exists():
        return p

    # Bare filename: search recursively
    if len(p.parts) == 1:
        matches = search_filename(p.name, cwd)
        if len(matches) == 1:
            return matches[0].relative_to(cwd)
        if len(matches) >= 2:
            print(
                f"# Warning: '{entry}' is ambiguous, using {matches[0].relative_to(cwd)}",
                file=sys.stderr,
            )
            return matches[0].relative_to(cwd)

    return None


def build_tree(paths: list[Path]) -> dict:
    tree: dict = {}
    for p in paths:
        node = tree
        for part in p.parts:
            node = node.setdefault(part, {})
    return tree


def render(node: dict, prefix: str = "") -> None:
    items = list(node.items())
    for i, (name, child) in enumerate(items):
        last = i == len(items) - 1
        connector = "└── " if last else "├── "
        suffix = "/" if child else ""  # has children -> directory
        print(f"{prefix}{connector}{name}{suffix}")
        extension = "    " if last else "│   "
        render(child, prefix + extension)


def find_common_root(paths: list[Path]) -> str | None:
    """If all paths share the same first component, return it."""
    first_parts = [p.parts[0] for p in paths if p.parts]
    if first_parts and all(fp == first_parts[0] for fp in first_parts):
        return first_parts[0]
    return None


def main() -> int:
    source = open(sys.argv[1]) if len(sys.argv) > 1 else sys.stdin
    entries = [line.strip() for line in source if line.strip()]

    cwd = Path.cwd()
    resolved: list[Path] = []
    for entry in entries:
        path = resolve(entry, cwd)
        if path is None:
            print(f"# Warning: not found: {entry}", file=sys.stderr)
            continue
        resolved.append(path)

    if not resolved:
        print("# No paths to display.", file=sys.stderr)
        return 1

    # Decide root name and strip its prefix from paths if applicable.
    common = find_common_root(resolved)
    if common:
        root_name = common
        tree_paths = [Path(*p.parts[1:]) for p in resolved if len(p.parts) > 1]
    else:
        root_name = cwd.name
        tree_paths = resolved

    print(f"{root_name}/")
    render(build_tree(tree_paths))
    return 0


if __name__ == "__main__":
    sys.exit(main())
