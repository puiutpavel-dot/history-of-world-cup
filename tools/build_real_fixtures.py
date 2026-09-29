"""Generează real_fixtures.js — traseul real (grupă + eliminatorii) al fiecărei
națiuni curate (TEAMS din data.js) la fiecare Campionat Mondial la care a
participat, din Fjelstul World Cup Database.

Sursa datelor: Fjelstul World Cup Database, © 2023 Joshua C. Fjelstul, Ph.D.,
https://www.github.com/jfjelstul/worldcup — licență CC-BY-SA 4.0
(https://creativecommons.org/licenses/by-sa/4.0/legalcode).
Modificări: selecție pe echipele curate ale jocului, coduri FIFA, maparea
formatelor istorice pe bracketul jocului (vezi mai jos), note în română.

Rulare:
  git clone --depth 1 https://github.com/jfjelstul/worldcup /tmp/worldcup
  python3 tools/build_real_fixtures.py /tmp/worldcup/data-csv/team_appearances.csv

Structură (motorul de carieră folosește formatul real al fiecărei ediții,
vezi FORMATS în data.js și career.js):
  - `group`: meciurile din faza grupelor, în ordine cronologică (inclusiv
    barajul de grupă din 1954/1958);
  - `knockout`: restul drumului, cronologic, cu `round` = R32 / R16 / QF /
    GR2 (a doua fază a grupelor 1974-1982) / FR (grupa finală 1950) / SF /
    3P (finala mică) / F;
  - meciurile rejucate (1934/1938): se păstrează doar rejucarea.
"""
import csv
import json
import os
import re
import sys
from collections import defaultdict

ROOT = os.path.join(os.path.dirname(__file__), "..")

# cod din baza de date → cod FIFA folosit în joc
CODE = {
    "AGO": "ANG", "ARE": "UAE", "BGR": "BUL", "CHE": "SUI", "CHL": "CHI", "COD": "ZAI", "CRI": "CRC",
    "CSK": "TCH", "DDR": "GDR", "DEU": "GER", "DNK": "DEN", "DZA": "ALG", "GRC": "GRE", "HND": "HON",
    "HRV": "CRO", "HTI": "HAI", "IDN": "DEI", "KWT": "KUW", "NLD": "NED", "PRT": "POR", "PRY": "PAR",
    "SAU": "KSA", "SUN": "URS", "TGO": "TOG", "TTO": "TRI", "URY": "URU", "ZAF": "RSA",
}

STAGE = {
    "group stage": "G", "round of 16": "R16", "quarter-finals": "QF", "second group stage": "GR2",
    "final round": "FR", "semi-finals": "SF", "third-place match": "3P", "final": "F",
}


def code(c):
    return CODE.get(c, c)


def curated_codes():
    src = open(os.path.join(ROOT, "data.js"), encoding="utf-8").read()
    block = src[src.index("const TEAMS = {"):src.index("};", src.index("const TEAMS = {"))]
    return re.findall(r"^\s+([A-Z]{3}): \{", block, re.M)


def existing_notes():
    """Notele scrise de mână în versiunea anterioară (Maracanazo etc.) se păstrează."""
    path = os.path.join(ROOT, "real_fixtures.js")
    notes = {}
    if not os.path.exists(path):
        return notes
    src = open(path, encoding="utf-8").read()
    for key, body in re.findall(r"\n  ([A-Z]{3}_\d{4}): \{(.*?)\n  \},", src, re.S):
        for m in re.finditer(r'opp: "([A-Z]{3})", scoreFor: (\d+), scoreAgainst: (\d+)(?:, note: "((?:[^"\\]|\\.)*)")?', body):
            # notele „în realitate: …” veneau din maparea veche pe bracket — nu sunt note de mână
            note = re.sub(r"^în realitate: [^;]*(; )?", "", json.loads(f'"{m.group(4)}"')) if m.group(4) else ""
            if note:
                notes[(key, m.group(1), int(m.group(2)), int(m.group(3)))] = note
    return notes


def js_str(s):
    return json.dumps(s, ensure_ascii=False)


def main(csv_path, out=os.path.join(ROOT, "real_fixtures.js")):
    curated = set(curated_codes())
    manual = existing_notes()
    rows = [r for r in csv.DictReader(open(csv_path, encoding="utf-8")) if "Men's" in r["tournament_name"]]

    by_campaign = defaultdict(list)
    for r in rows:
        team = code(r["team_code"])
        if team in curated and r["replayed"] != "1":
            by_campaign[(team, int(r["tournament_id"][3:]))].append(r)

    campaigns = {}
    for (team, year), ms in by_campaign.items():
        ms.sort(key=lambda r: (r["match_date"], r["match_id"]))
        key = f"{team}_{year}"
        group, knockout = [], []
        for r in ms:
            st = STAGE[r["stage_name"]]
            gf, ga = int(r["goals_for"]), int(r["goals_against"])
            opp = code(r["opponent_code"])
            auto = []
            if r["replay"] == "1":
                auto.append("meci rejucat")
            if r["extra_time"] == "1" and r["penalty_shootout"] != "1":
                auto.append("prelungiri")
            if r["penalty_shootout"] == "1":
                auto.append(f"penalty-uri {r['penalties_for']}-{r['penalties_against']}")
            m = {"round": st, "opp": opp, "scoreFor": gf, "scoreAgainst": ga,
                 "note": manual.get((key, opp, gf, ga)) or (", ".join(auto) or None)}
            (group if st == "G" else knockout).append(m)
        for m in group:
            m.pop("round")
        campaigns[key] = {"group": group, "knockout": knockout}

    order = sorted(campaigns, key=lambda k: (int(k[4:]), k[:3]))
    n_matches = sum(len(c["group"]) + len(c["knockout"]) for c in campaigns.values())

    def fmt(m):
        parts = []
        if "round" in m:
            parts.append(f'round: "{m["round"]}"')
        parts += [f'opp: "{m["opp"]}"', f'scoreFor: {m["scoreFor"]}', f'scoreAgainst: {m["scoreAgainst"]}']
        if m["note"]:
            parts.append(f"note: {js_str(m['note'])}")
        return "      { " + ", ".join(parts) + " },"

    lines = [
        "/* ============================================================",
        "   HISTORY OF WORLD CUP — real_fixtures.js  (FIȘIER GENERAT)",
        "   Generat de tools/build_real_fixtures.py — nu edita manual;",
        "   notele scrise de mână (ex. „Maracanazo”) sunt păstrate la regenerare.",
        "",
        f"   Traseul real al fiecăreia dintre cele {len(curated)} națiuni curate la fiecare",
        f"   ediție la care a participat: {len(campaigns)} campanii, {n_matches} meciuri reale.",
        "",
        "   Sursa: Fjelstul World Cup Database, © 2023 Joshua C. Fjelstul, Ph.D.,",
        "   https://www.github.com/jfjelstul/worldcup — licență CC-BY-SA 4.0",
        "   (https://creativecommons.org/licenses/by-sa/4.0/legalcode).",
        "   Modificări: selecție pe echipele jocului, coduri FIFA, mapare pe",
        "   bracketul jocului, note în română. Acest fișier de date este, la rândul",
        "   lui, distribuit sub CC-BY-SA 4.0.",
        "",
        "   Cheie: \"<COD_ECHIPA>_<AN>\". group = meciuri din grupă, knockout = restul",
        "   drumului, cu round = R32/R16/QF/GR2/FR/SF/3P/F. Motorul de carieră",
        "   (career.js) ia adversarul real pentru fiecare etapă a formatului ediției.",
        "   Scorurile sunt informative (comparate cu rezultatul simulat) — NU",
        "   determină simularea.",
        "   ============================================================ */",
        "",
        "const REAL_FIXTURES = {",
    ]
    for k in order:
        c = campaigns[k]
        lines.append("")
        lines.append(f"  {k}: {{")
        lines.append("    group: [")
        lines += [fmt(m) for m in c["group"]]
        lines.append("    ],")
        lines.append("    knockout: [")
        lines += [fmt(m) for m in c["knockout"]]
        lines.append("    ],")
        lines.append("  },")
    lines += [
        "",
        "};",
        "",
        'if (typeof module !== "undefined" && module.exports) {',
        "  module.exports = { REAL_FIXTURES };",
        "}",
        "",
    ]
    open(out, "w", encoding="utf-8").write("\n".join(lines))
    opps = sorted({m["opp"] for c in campaigns.values() for m in c["group"] + c["knockout"]} - curated)
    print(f"{out}: {len(campaigns)} campanii, {n_matches} meciuri; adversari non-curați: {' '.join(opps)}")


if __name__ == "__main__":
    main(*sys.argv[1:])
