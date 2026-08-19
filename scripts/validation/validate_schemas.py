#!/usr/bin/env python3
"""Validate example JSON and any provided run dir against schemas."""

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "scripts" / "controller"))
from spotctl import cmd_validate_evidence  # noqa: E402
import argparse


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--run-dir", required=True)
    return cmd_validate_evidence(p.parse_args())


if __name__ == "__main__":
    raise SystemExit(main())
