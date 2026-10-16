#!/usr/bin/env python3
"""Load config/foundation-build-pins.yml for CI build scripts."""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

try:
    import yaml
except ImportError as exc:  # pragma: no cover
    raise SystemExit(
        "PyYAML required (pip install pyyaml) for foundation-build-pins.yml"
    ) from exc


def repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def load_pins(path: Path | None = None) -> dict:
    path = path or (repo_root() / "config" / "foundation-build-pins.yml")
    data = yaml.safe_load(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise ValueError(f"Invalid pins config: {path}")
    deploy = data.get("deploy") or {}
    latest = str(deploy.get("latest_foundation_ref") or "").strip()
    pins = data.get("foundation_pins") or []
    normalized = []
    for entry in pins:
        if not isinstance(entry, dict):
            continue
        ref = str(entry.get("ref") or "").strip()
        version = str(entry.get("version") or "").strip()
        if ref and version:
            normalized.append({"ref": ref, "version": version})
    if not normalized:
        raise ValueError("foundation_pins is empty")
    if not latest:
        raise ValueError("deploy.latest_foundation_ref is required")
    refs = {p["ref"] for p in normalized}
    if latest not in refs:
        raise ValueError(
            f"deploy.latest_foundation_ref {latest!r} not in foundation_pins"
        )
    return {"latest_foundation_ref": latest, "foundation_pins": normalized}


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--format",
        choices=("json", "env"),
        default="json",
        help="json: full config; env: shell exports for latest pin",
    )
    parser.add_argument("--config", type=Path, default=None)
    args = parser.parse_args()
    cfg = load_pins(args.config)

    if args.format == "json":
        json.dump(cfg, sys.stdout, indent=2)
        sys.stdout.write("\n")
        return 0

    latest_ref = cfg["latest_foundation_ref"]
    latest_version = next(
        p["version"]
        for p in cfg["foundation_pins"]
        if p["ref"] == latest_ref
    )
    print(f'export HITSAVE_LATEST_FOUNDATION_REF="{latest_ref}"')
    print(f'export HITSAVE_LATEST_FOUNDATION_VERSION="{latest_version}"')
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
