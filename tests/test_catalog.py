from pathlib import Path

import json
import jsonschema
import yaml

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "config" / "catalog" / "workstations.yml"
SCHEMA = ROOT / "schemas" / "workstation-catalog.schema.json"


def _load():
    data = yaml.safe_load(CATALOG.read_text())
    schema = json.loads(SCHEMA.read_text())
    jsonschema.validate(data, schema)
    return data


def test_catalog_matches_operator_menus():
    data = _load()
    stores = {s["number"]: s for s in data["stores"]}
    assert set(stores) == {1, 2, 3}
    assert stores[1]["menu"] == "Vogue Krum"
    assert stores[2]["menu"] == "Vogue Denton"
    assert stores[3]["menu"] == "Zenith"

    vogue_menus = [w["menu"] for w in stores[1]["workstations"]]
    assert vogue_menus == [
        "Front Counter (cash drawer)",
        "Mark-In",
    ]
    assert [w["menu"] for w in stores[2]["workstations"]] == vogue_menus

    zenith_menus = [w["menu"] for w in stores[3]["workstations"]]
    assert zenith_menus == [
        "Front Counter (cash drawer)",
        "Mark-In 1 (front mark-in)",
        "Mark-In 2 (back mark-in)",
    ]


def test_spot_client_names_follow_store_and_counter():
    data = _load()
    expected = {
        ("vogue-krum", "front-counter"): "VGCTX01COUNTER1",
        ("vogue-krum", "mark-in"): "VGCTX01COUNTER2",
        ("vogue-denton", "front-counter"): "VGCTX02COUNTER1",
        ("vogue-denton", "mark-in"): "VGCTX02COUNTER2",
        ("zenith", "front-counter"): "VGCTX03COUNTER1",
        ("zenith", "mark-in-1"): "VGCTX03COUNTER2",
        ("zenith", "mark-in-2"): "VGCTX03COUNTER3",
    }
    got = {
        (s["id"], w["id"]): w["spot_client_name"]
        for s in data["stores"]
        for w in s["workstations"]
    }
    assert got == expected
    for store in data["stores"]:
        for i, w in enumerate(store["workstations"], start=1):
            assert w["spot_client_name"] == f"VGCTX{store['number']:02d}COUNTER{i}"
