#!/usr/bin/env python3
"""Shared persistent progress store for the RHCSA simulator."""

from __future__ import annotations

import contextlib
import datetime as _dt
import fcntl
import json
import os
import re
import tempfile
from pathlib import Path
from typing import Any, Iterable

SCHEMA_VERSION = 2


def _utc_now() -> str:
    return _dt.datetime.now(_dt.timezone.utc).isoformat()


def _default_data() -> dict[str, Any]:
    return {
        "schema": SCHEMA_VERSION,
        "completed": {},
        "legacy_unmapped": [],
        "updated_at": _utc_now(),
    }


def _read_assignment(path: Path, name: str) -> str | None:
    try:
        content = path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return None
    match = re.search(
        rf"(?m)^[ \t]*{re.escape(name)}[ \t]*=[ \t]*([\"'])(.*?)\1[ \t]*$",
        content,
    )
    return match.group(2) if match else None


def build_catalog(questions_dir: Path) -> tuple[dict[str, dict[str, str]], dict[str, str]]:
    """Return lab metadata keyed by LAB_ID and an alias -> LAB_ID map."""
    by_id: dict[str, dict[str, str]] = {}
    aliases: dict[str, str] = {}

    if not questions_dir.is_dir():
        return by_id, aliases

    chapter_dirs = sorted(
        (p for p in questions_dir.iterdir() if p.is_dir() and p.name.isdigit()),
        key=lambda p: int(p.name),
    )
    for chapter_dir in chapter_dirs:
        for lab_path in sorted(chapter_dir.glob("lab_*.sh")):
            if lab_path.is_symlink() or not lab_path.is_file():
                continue
            lab_id = _read_assignment(lab_path, "LAB_ID")
            if not lab_id:
                continue
            metadata = {
                "lab_id": lab_id,
                "filename": lab_path.name,
                "chapter": chapter_dir.name,
                "path": str(lab_path),
                "lab_version": _read_assignment(lab_path, "LAB_VERSION") or "",
            }
            by_id[lab_id] = metadata
            aliases[lab_id] = lab_id
            aliases[lab_path.name] = lab_id
            aliases[f"{chapter_dir.name}/{lab_path.name}"] = lab_id
            aliases[f"questions/{chapter_dir.name}/{lab_path.name}"] = lab_id
    return by_id, aliases


class ProgressStore:
    def __init__(self, progress_file: Path, questions_dir: Path):
        self.progress_file = progress_file
        self.questions_dir = questions_dir
        self.lock_file = progress_file.with_suffix(progress_file.suffix + ".lock")
        self.progress_file.parent.mkdir(parents=True, exist_ok=True)

    @contextlib.contextmanager
    def _locked(self):
        self.lock_file.parent.mkdir(parents=True, exist_ok=True)
        with self.lock_file.open("a+", encoding="utf-8") as handle:
            fcntl.flock(handle.fileno(), fcntl.LOCK_EX)
            try:
                yield
            finally:
                fcntl.flock(handle.fileno(), fcntl.LOCK_UN)

    def _load_unlocked(self) -> dict[str, Any]:
        if not self.progress_file.exists():
            return _default_data()
        try:
            data = json.loads(self.progress_file.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError, TypeError):
            return _default_data()
        if not isinstance(data, dict):
            return _default_data()
        data.setdefault("schema", SCHEMA_VERSION)
        data.setdefault("completed", {})
        data.setdefault("legacy_unmapped", [])
        if not isinstance(data["completed"], dict):
            data["completed"] = {}
        if not isinstance(data["legacy_unmapped"], list):
            data["legacy_unmapped"] = []
        return data

    def _write_unlocked(self, data: dict[str, Any]) -> None:
        data["schema"] = SCHEMA_VERSION
        data["updated_at"] = _utc_now()
        fd, temp_name = tempfile.mkstemp(
            prefix=f".{self.progress_file.name}.",
            dir=str(self.progress_file.parent),
            text=True,
        )
        try:
            with os.fdopen(fd, "w", encoding="utf-8") as handle:
                json.dump(data, handle, indent=2, sort_keys=True)
                handle.write("\n")
                handle.flush()
                os.fsync(handle.fileno())
            os.chmod(temp_name, 0o600)
            os.replace(temp_name, self.progress_file)
        finally:
            with contextlib.suppress(FileNotFoundError):
                os.unlink(temp_name)

    def list_completed(self) -> dict[str, dict[str, Any]]:
        with self._locked():
            data = self._load_unlocked()
            return dict(data["completed"])

    def is_completed(self, lab_id: str) -> bool:
        return lab_id in self.list_completed()

    def mark_completed(
        self,
        lab_id: str,
        *,
        lab_version: str = "",
        chapter: str = "",
        filename: str = "",
    ) -> None:
        with self._locked():
            data = self._load_unlocked()
            data["completed"][lab_id] = {
                "status": "completed",
                "timestamp": _utc_now(),
                "lab_version": lab_version,
                "chapter": chapter,
                "filename": filename,
            }
            self._write_unlocked(data)

    def migrate_legacy(self, legacy_paths: Iterable[Path]) -> dict[str, int]:
        by_id, aliases = build_catalog(self.questions_dir)
        migrated = 0
        unmapped = 0

        with self._locked():
            data = self._load_unlocked()
            completed = data["completed"]
            legacy_unmapped = set(str(x) for x in data.get("legacy_unmapped", []))

            for legacy_path in legacy_paths:
                if not legacy_path.is_file():
                    continue
                try:
                    entries = [
                        line.strip()
                        for line in legacy_path.read_text(
                            encoding="utf-8", errors="replace"
                        ).splitlines()
                        if line.strip()
                    ]
                except OSError:
                    continue

                for entry in entries:
                    lab_id = aliases.get(entry)
                    if lab_id is None:
                        # Tolerate absolute paths from old installations.
                        normalized = entry.replace("\\", "/")
                        for alias, candidate in aliases.items():
                            if normalized.endswith("/" + alias):
                                lab_id = candidate
                                break
                    if lab_id and lab_id in by_id:
                        if lab_id not in completed:
                            metadata = by_id[lab_id]
                            completed[lab_id] = {
                                "status": "completed",
                                "timestamp": _utc_now(),
                                "lab_version": metadata.get("lab_version", ""),
                                "chapter": metadata.get("chapter", ""),
                                "filename": metadata.get("filename", ""),
                                "migrated_from": entry,
                            }
                            migrated += 1
                    else:
                        legacy_unmapped.add(entry)
                        unmapped += 1

            data["legacy_unmapped"] = sorted(legacy_unmapped)
            self._write_unlocked(data)

        return {"migrated": migrated, "unmapped": unmapped}
