"""Generează country_tracks.js — traseul real al FIECĂREI naționale (84 de
echipe) la fiecare Campionat Mondial la care a jucat, 1930-2022: meciuri,
scoruri și locul final. Folosit de ecranul „Traseul țării tale”.

Sursa datelor: Fjelstul World Cup Database, © 2023 Joshua C. Fjelstul, Ph.D.,
https://www.github.com/jfjelstul/worldcup — licență CC-BY-SA 4.0
(https://creativecommons.org/licenses/by-sa/4.0/legalcode).
Modificări: coduri FIFA, etichete în română, locul final calculat din meciuri.

Rulare:
  curl -sSLo /tmp/team_appearances.csv https://raw.githubusercontent.com/jfjelstul/worldcup/35a8667f518b07469182ae16d35574dd0e7a00fb/data-csv/team_appearances.csv
  curl -sSLo /tmp/goals.csv https://raw.githubusercontent.com/jfjelstul/worldcup/35a8667f518b07469182ae16d35574dd0e7a00fb/data-csv/goals.csv
  python3 tools/build_country_tracks.py /tmp/team_appearances.csv /tmp/goals.csv

Golurile (al doilea fișier, opțional): în fiecare meci, „goals” = [{m, t, n, k}] în ordine
cronologică — m = minutul („90+2”), t = 1 dacă a marcat echipa traseului, 0 adversarul,
n = marcatorul, k = „p” (penalty) / „og” (autogol) / null. Loviturile de departajare nu sunt goluri.
"""
import csv
import json
import os
import sys
from collections import defaultdict

sys.path.insert(0, os.path.dirname(__file__))
from build_real_fixtures import CODE, code  # noqa: E402

ROOT = os.path.join(os.path.dirname(__file__), "..")

STAGE = {
    "group stage": "G", "round of 16": "R16", "quarter-finals": "QF", "quarter-final": "QF",
    "second group stage": "GR2", "final round": "FR", "semi-finals": "SF", "semi-final": "SF",
    "third-place match": "3P", "final": "F",
}
DEPTH = {"G": 0, "R16": 1, "QF": 2, "GR2": 2, "SF": 3, "FR": 3, "3P": 4, "F": 5}


def load_goals(goals_path):
    """match_id → listă de goluri (echipa creditată, minut, marcator, tip), în ordine cronologică."""
    by_match = defaultdict(list)
    if not goals_path:
        return by_match
    for g in csv.DictReader(open(goals_path, encoding="utf-8")):
        if "Men's" not in g["tournament_name"]:
            continue
        reg, stop = int(g["minute_regulation"]), int(g["minute_stoppage"])
        name = g["family_name"] if g["given_name"] == "not applicable" else f"{g['given_name']} {g['family_name']}"
        kind = "og" if g["own_goal"] == "1" else "p" if g["penalty"] == "1" else None
        by_match[g["match_id"]].append((reg, stop, code(g["team_code"]), f"{reg}+{stop}" if stop else str(reg), name, kind))
    for gs in by_match.values():
        gs.sort(key=lambda x: (x[0], x[1]))
    return by_match


def main(csv_path, goals_path=None, out=os.path.join(ROOT, "country_tracks.js")):
    goals = load_goals(goals_path)
    rows = [r for r in csv.DictReader(open(csv_path, encoding="utf-8")) if "Men's" in r["tournament_name"]]
    by = defaultdict(list)
    for r in rows:
        by[(code(r["team_code"]), int(r["tournament_id"][3:]))].append(r)

    # grupa finală 1950: clasament din meciurile rundei finale
    fr_pts = defaultdict(lambda: [0, 0])
    for r in rows:
        if r["tournament_id"] == "WC-1950" and r["stage_name"] == "final round":
            t = code(r["team_code"])
            fr_pts[t][0] += 2 if r["result"] == "win" else 1 if r["result"] == "draw" else 0
            fr_pts[t][1] += int(r["goals_for"]) - int(r["goals_against"])
    fr_rank = sorted(fr_pts, key=lambda t: (-fr_pts[t][0], -fr_pts[t][1]))

    tracks = defaultdict(list)
    for (team, year), ms in by.items():
        ms.sort(key=lambda r: (r["match_date"], r["match_id"]))
        matches = []
        deepest = "G"
        finish = None
        for r in ms:
            st = STAGE[r["stage_name"]]
            if DEPTH[st] > DEPTH[deepest]:
                deepest = st
            note = []
            if r["replay"] == "1":
                note.append("rejucare")
            if r["extra_time"] == "1" and r["penalty_shootout"] != "1":
                note.append("după prelungiri")
            if r["replayed"] == "1":
                note.append("egal — meciul s-a rejucat")
            if r["penalty_shootout"] == "1":
                note.append(f"penalty-uri {r['penalties_for']}-{r['penalties_against']}")
            match = {"round": st, "opp": code(r["opponent_code"]), "gf": int(r["goals_for"]),
                     "ga": int(r["goals_against"]), "note": ", ".join(note) or None}
            if goals_path:
                gs = goals.get(r["match_id"], [])
                match["goals"] = [{"m": m, "t": 1 if tc == team else 0, "n": n, "k": k} for _, _, tc, m, n, k in gs]
                mine = sum(1 for g in match["goals"] if g["t"] == 1)
                assert mine == match["gf"] and len(gs) - mine == match["ga"], (r["match_id"], team, mine, match)
            matches.append(match)
            if st == "F":
                finish = "champion" if r["result"] == "win" or (r["penalty_shootout"] == "1" and int(r["penalties_for"]) > int(r["penalties_against"])) else "runnerUp"
            if st == "3P":
                finish = "third" if r["result"] == "win" or (r["penalty_shootout"] == "1" and int(r["penalties_for"]) > int(r["penalties_against"])) else "fourth"
        if year == 1950 and deepest == "FR":
            finish = ["champion", "runnerUp", "third", "fourth"][fr_rank.index(team)]
        if year == 1930 and team == "USA":
            finish = "third"  # clasamentul oficial FIFA (nu s-a jucat finala mică)
        if year == 1930 and team == "YUG":
            finish = "fourth"
        tracks[team].append({"year": year, "finish": finish or deepest, "matches": matches})

    for t in tracks:
        tracks[t].sort(key=lambda e: e["year"])
    n = sum(len(v) for v in tracks.values())
    with open(out, "w", encoding="utf-8") as f:
        f.write("/* ============================================================\n")
        f.write("   HISTORY OF WORLD CUP — country_tracks.js (GENERAT, nu edita manual)\n")
        f.write("   Traseul real al fiecărei naționale la Mondiale, 1930-2022.\n")
        f.write("   Generator: tools/build_country_tracks.py\n")
        f.write("   Sursa: Fjelstul World Cup Database, © 2023 Joshua C. Fjelstul, Ph.D.,\n")
        f.write("   https://www.github.com/jfjelstul/worldcup — CC-BY-SA 4.0 (date adaptate).\n")
        f.write("   finish: champion / runnerUp / third / fourth sau ultima fază atinsă\n")
        f.write("   (G = grupe, R16, QF, GR2 = a doua fază a grupelor, SF).\n")
        f.write("   ============================================================ */\n")
        f.write("const COUNTRY_TRACKS = {\n")
        for t in sorted(tracks):
            f.write(f"  {t}: {json.dumps(tracks[t], ensure_ascii=False, separators=(',', ':'))},\n")
        f.write("};\n")
    print(f"{out}: {len(tracks)} echipe, {n} participări")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else None)
