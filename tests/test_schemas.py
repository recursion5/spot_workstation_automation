from pathlib import Path
import json
import jsonschema

ROOT = Path(__file__).resolve().parents[1]
SCHEMAS = ROOT / "schemas"


def test_collector_status_fixture_validates():
    schema = json.loads((SCHEMAS / "collector-status.schema.json").read_text())
    sample = {
        "collector": "printer_inventory",
        "version": "1",
        "run_id": "example",
        "started_at": "2026-08-19T00:00:00Z",
        "ended_at": "2026-08-19T00:00:01Z",
        "status": "success",
        "output_files": [],
        "warnings": [],
    }
    jsonschema.validate(sample, schema)


def test_run_manifest_fixture_validates():
    schema = json.loads((SCHEMAS / "run-manifest.schema.json").read_text())
    sample = {
        "run_id": "example",
        "schema": "run-manifest/v1",
        "status": "success",
        "store": "unassigned",
        "register": "specimen-01",
    }
    jsonschema.validate(sample, schema)


def test_correlation_table_requires_confidence():
    schema = json.loads((SCHEMAS / "correlation-table.schema.json").read_text())
    sample = {
        "run_id": "example",
        "mappings": [
            {
                "logical_printer": "EPSON",
                "windows_port": "USB001",
                "mapping_confidence": "hypothesis",
            }
        ],
    }
    jsonschema.validate(sample, schema)
