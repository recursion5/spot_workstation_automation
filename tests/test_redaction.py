from pathlib import Path
import yaml

ROOT = Path(__file__).resolve().parents[1]


def test_redaction_patterns_include_password():
    data = yaml.safe_load(
        (ROOT / "config" / "redaction" / "patterns.yml").read_text()
    )
    needles = [n.lower() for n in data["name_needles"]]
    assert "password" in needles
    assert "token" in needles
    assert any("DefaultPassword" in v for v in data["never_export_registry_values"])
