#!/usr/bin/env python3
"""CLI for the shared RHCSA progress store."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

INSTALL_DIR = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(INSTALL_DIR))

from lib.progress import ProgressStore, build_catalog  # noqa: E402


def store() -> ProgressStore:
    return ProgressStore(
        Path("/usr/local/share/rhcsa/progress.json")
        if INSTALL_DIR == Path("/usr/local/share/rhcsa")
        else INSTALL_DIR / "progress.json",
        INSTALL_DIR / "questions",
    )


def main() -> int:
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="command", required=True)

    p_list = sub.add_parser("list")
    p_list.add_argument("--plain", action="store_true")

    p_is = sub.add_parser("is-complete")
    p_is.add_argument("lab_id")

    p_mark = sub.add_parser("mark")
    p_mark.add_argument("lab_id")
    p_mark.add_argument("--lab-version", default="")
    p_mark.add_argument("--chapter", default="")
    p_mark.add_argument("--filename", default="")

    p_migrate = sub.add_parser("migrate")
    p_migrate.add_argument("--legacy", action="append", default=[])

    p_catalog = sub.add_parser("catalog")
    p_catalog.add_argument("--json", action="store_true")

    args = parser.parse_args()
    progress = store()

    if args.command == "list":
        completed = progress.list_completed()
        if args.plain:
            for lab_id in sorted(completed):
                print(lab_id)
        else:
            print(json.dumps({"completed": completed}, indent=2, sort_keys=True))
        return 0

    if args.command == "is-complete":
        return 0 if progress.is_completed(args.lab_id) else 1

    if args.command == "mark":
        progress.mark_completed(
            args.lab_id,
            lab_version=args.lab_version,
            chapter=args.chapter,
            filename=args.filename,
        )
        return 0

    if args.command == "migrate":
        legacy = [Path(value) for value in args.legacy]
        result = progress.migrate_legacy(legacy)
        print(json.dumps(result, sort_keys=True))
        return 0

    if args.command == "catalog":
        by_id, aliases = build_catalog(INSTALL_DIR / "questions")
        print(json.dumps({"labs": by_id, "aliases": aliases}, indent=2, sort_keys=True))
        return 0

    return 2


if __name__ == "__main__":
    raise SystemExit(main())
