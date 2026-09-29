"""Generează tracks_2026.js — traseul real al fiecăreia dintre cele 48 de
naționale la Campionatul Mondial 2026 (104 meciuri), în același format ca
country_tracks.js (care acoperă 1930-2022, din Fjelstul).

Sursa: openfootball/worldcup.json (2026/worldcup.json) — domeniu public.
https://github.com/openfootball/worldcup.json — copie în tools/data/openfootball_wc2026.json

Rulare: python3 tools/build_tracks_2026.py
"""
import json
import os
from collections import defaultdict

ROOT = os.path.join(os.path.dirname(__file__), "..")
SRC = os.path.join(os.path.dirname(__file__), "data", "openfootball_wc2026.json")

CODE = {
    "Algeria": "ALG", "Argentina": "ARG", "Australia": "AUS", "Austria": "AUT", "Belgium": "BEL",
    "Bosnia & Herzegovina": "BIH", "Brazil": "BRA", "Canada": "CAN", "Cape Verde": "CPV", "Colombia": "COL",
    "Croatia": "CRO", "Curaçao": "CUW", "Czech Republic": "CZE", "DR Congo": "COD", "Ecuador": "ECU",
    "Egypt": "EGY", "England": "ENG", "France": "FRA", "Germany": "GER", "Ghana": "GHA", "Haiti": "HAI",
    "Iran": "IRN", "Iraq": "IRQ", "Ivory Coast": "CIV", "Japan": "JPN", "Jordan": "JOR", "Mexico": "MEX",
    "Morocco": "MAR", "Netherlands": "NED", "New Zealand": "NZL", "Norway": "NOR", "Panama": "PAN",
    "Paraguay": "PAR", "Portugal": "POR", "Qatar": "QAT", "Saudi Arabia": "KSA", "Scotland": "SCO",
    "Senegal": "SEN", "South Africa": "RSA", "South Korea": "KOR", "Spain": "ESP", "Sweden": "SWE",
    "Switzerland": "SUI", "Tunisia": "TUN", "Turkey": "TUR", "USA": "USA", "Uruguay": "URU",
    "Uzbekistan": "UZB",
}
ROUND = {"Round of 32": "R32", "Round of 16": "R16", "Quarter-final": "QF", "Semi-final": "SF",
         "Match for third place": "3P", "Final": "F"}
DEPTH = {"G": 0, "R32": 1, "R16": 2, "QF": 3, "SF": 4, "3P": 5, "F": 6}


def main(out=os.path.join(ROOT, "tracks_2026.js")):
    matches = json.load(open(SRC, encoding="utf-8"))["matches"]
    assert len(matches) == 104, len(matches)
    tracks = defaultdict(lambda: {"year": 2026, "finish": None, "matches": []})
    for m in sorted(matches, key=lambda m: (m["date"], m.get("time", ""))):
        rnd = ROUND.get(m["round"], "G")
        s = m["score"]
        a, b = s.get("et") or s["ft"]
        pens = s.get("p")
        # golurile (fără loviturile de departajare): goals1 = creditate echipei 1 (inclusiv autogolurile adversarului)
        def minute_key(g):
            base, _, extra = g["minute"].partition("+")
            return (int(base), int(extra or 0))
        allg = sorted([(g, 1) for g in m.get("goals1") or []] + [(g, 2) for g in m.get("goals2") or []], key=lambda x: minute_key(x[0]))
        assert sum(1 for _, s in allg if s == 1) == a and sum(1 for _, s in allg if s == 2) == b, (m["team1"], m["team2"], s)
        for side, (team, opp, gf, ga, pf, pa) in enumerate(((m["team1"], m["team2"], a, b, *(pens or (0, 0))),
                                                            (m["team2"], m["team1"], b, a, *(reversed(pens) if pens else (0, 0)))), 1):
            note = []
            if "et" in s and not pens:
                note.append("după prelungiri")
            if pens:
                note.append(f"penalty-uri {pf}-{pa}")
            t = tracks[CODE[team]]
            goals = [{"m": g["minute"], "t": 1 if s == side else 0, "n": g["name"],
                      "k": "og" if g.get("owngoal") else "p" if g.get("penalty") else None} for g, s in allg]
            t["matches"].append({"round": rnd, "opp": CODE[opp], "gf": gf, "ga": ga, "note": ", ".join(note) or None, "goals": goals})
            won = gf > ga or (pens is not None and pf > pa)
            if rnd == "F":
                t["finish"] = "champion" if won else "runnerUp"
            elif rnd == "3P":
                t["finish"] = "third" if won else "fourth"
    for t in tracks.values():
        if not t["finish"]:
            t["finish"] = max((x["round"] for x in t["matches"]), key=lambda r: DEPTH[r])
    assert len(tracks) == 48, len(tracks)
    podium = {c: t["finish"] for c, t in tracks.items() if t["finish"] in ("champion", "runnerUp", "third", "fourth")}
    assert podium == {"ESP": "champion", "ARG": "runnerUp", "ENG": "third", "FRA": "fourth"}, podium
    with open(out, "w", encoding="utf-8") as f:
        f.write("/* ============================================================\n")
        f.write("   ARHIVA MONDIALELOR — tracks_2026.js (GENERAT, nu edita manual)\n")
        f.write("   Traseul real al celor 48 de naționale la Mondialul 2026 (104 meciuri),\n")
        f.write("   în formatul din country_tracks.js. Generator: tools/build_tracks_2026.py\n")
        f.write("   Sursa: openfootball/worldcup.json — domeniu public.\n")
        f.write("   ============================================================ */\n")
        f.write("const COUNTRY_TRACKS_2026 = {\n")
        for c in sorted(tracks):
            f.write(f"  {c}: {json.dumps(tracks[c], ensure_ascii=False, separators=(',', ':'))},\n")
        f.write("};\n")
    print(f"{out}: {len(tracks)} echipe, {sum(len(t['matches']) for t in tracks.values()) // 2} meciuri")


if __name__ == "__main__":
    main()
