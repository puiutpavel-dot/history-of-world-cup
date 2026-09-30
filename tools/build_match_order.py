"""Generează ios/App/Sources/MatchOrder.swift — ordinea cronologică a TUTUROR meciurilor
fiecărei ediții (1930-2026), pentru modul „Retrăiește un Mondial”, în care se joacă
fiecare meci al turneului, pe rând. Scorurile și golurile vin din traseele echipelor
(country_tracks.js / tracks_2026.js); aici e doar ordinea: data + echipa 1 + echipa 2.

Surse: Fjelstul World Cup Database (CC-BY-SA 4.0), matches.csv, commit 35a8667;
2026: openfootball/worldcup.json (domeniu public), ora convertită în UTC.

Rulare:
  curl -sSLo /tmp/matches.csv https://raw.githubusercontent.com/jfjelstul/worldcup/35a8667f518b07469182ae16d35574dd0e7a00fb/data-csv/matches.csv
  curl -sSLo /tmp/bookings.csv https://raw.githubusercontent.com/jfjelstul/worldcup/35a8667f518b07469182ae16d35574dd0e7a00fb/data-csv/bookings.csv
  curl -sSLo /tmp/penalty_kicks.csv https://raw.githubusercontent.com/jfjelstul/worldcup/35a8667f518b07469182ae16d35574dd0e7a00fb/data-csv/penalty_kicks.csv
  python3 tools/build_match_order.py /tmp/matches.csv /tmp/bookings.csv /tmp/penalty_kicks.csv

Cu bookings.csv și penalty_kicks.csv generează și ios/App/Sources/MatchEvents.swift: eliminările
(roșu direct sau al doilea galben; în sursă doar din 1970, când au apărut cartonașele) și loviturile
de departajare, pe echipe, marcate/ratate, pentru fiecare meci (indexul din calendarul ediției).
"""
import csv
import json
import os
import re
import sys
from collections import defaultdict
from datetime import datetime, timedelta

sys.path.insert(0, os.path.dirname(__file__))
from build_real_fixtures import code  # noqa: E402
from build_tracks_2026 import CODE as CODE_2026, SRC as SRC_2026  # noqa: E402

ROOT = os.path.join(os.path.dirname(__file__), "..")


def person(r):
    return r["family_name"] if r["given_name"] == "not applicable" else f"{r['given_name']} {r['family_name']}"


def main(matches_csv, bookings_csv=None, kicks_csv=None, out=os.path.join(ROOT, "ios", "App", "Sources", "MatchOrder.swift")):
    by_year = defaultdict(list)
    for r in csv.DictReader(open(matches_csv, encoding="utf-8")):
        if "Men's" not in r["tournament_name"]:
            continue
        y = int(r["tournament_id"][3:])
        by_year[y].append((r["match_date"], r["match_time"], r["match_id"], code(r["home_team_code"]), code(r["away_team_code"])))
    for m in json.load(open(SRC_2026, encoding="utf-8"))["matches"]:
        t, _, tz = m["time"].partition(" UTC")
        local = datetime.strptime(f"{m['date']} {t}", "%Y-%m-%d %H:%M")
        utc = local - timedelta(hours=int(tz or 0))
        by_year[2026].append((utc.strftime("%Y-%m-%d"), utc.strftime("%H:%M"), "", CODE_2026[m["team1"]], CODE_2026[m["team2"]]))
    # evenimentele fiecărui meci (match_id), din perspectiva echipei 1 (home)
    events = defaultdict(list)
    homes = {r[2]: r[3] for v in by_year.values() for r in v if r[2]}
    if bookings_csv:
        rows = [r for r in csv.DictReader(open(bookings_csv, encoding="utf-8"))
                if "Men's" in r["tournament_name"] and r["sending_off"] == "1"]
        rows.sort(key=lambda r: (r["match_id"], int(r["minute_regulation"]), int(r["minute_stoppage"])))
        for r in rows:
            reg, stop = int(r["minute_regulation"]), int(r["minute_stoppage"])
            side = 1 if code(r["team_code"]) == homes[r["match_id"]] else 0
            events[r["match_id"]].append(f"R|{reg}+{stop}|{side}|{person(r)}|{2 if r['second_yellow_card'] == '1' else 1}" if stop
                                         else f"R|{reg}|{side}|{person(r)}|{2 if r['second_yellow_card'] == '1' else 1}")
    if kicks_csv:
        for r in sorted((r for r in csv.DictReader(open(kicks_csv, encoding="utf-8")) if "Men's" in r["tournament_name"]),
                        key=lambda r: int(r["key_id"])):
            side = 1 if code(r["team_code"]) == homes[r["match_id"]] else 0
            events[r["match_id"]].append(f"K|{side}|{person(r)}|{r['converted']}")
    for e in events.values():
        assert all("\"" not in x and ";" not in x[2:] for x in e), e
    ev_lines = []

    lines = []
    for y in sorted(by_year):
        ms = sorted(by_year[y])
        ev = [f"{i}: \"{';'.join(events[m[2]])}\"" for i, m in enumerate(ms) if m[2] in events]
        if ev:
            ev_lines.append(f"        {y}: [" + ", ".join(ev) + "],")
        # data afișată = ziua din sursă (MMDD); pentru 2026, ziua UTC
        items = " ".join(f"{d[5:7]}{d[8:10]}{a}-{b}" for d, _, _, a, b in ms)
        assert all(re.fullmatch(r"\d{4}[A-Z]{3}-[A-Z]{3}", x) for x in items.split()), y
        lines.append(f"        {y}: \"{items}\",")
    with open(out, "w", encoding="utf-8") as f:
        f.write("// GENERAT de tools/build_match_order.py — nu edita manual.\n")
        f.write("// Ordinea cronologică a tuturor meciurilor fiecărei ediții: „MMDD” + echipa 1 + „-” + echipa 2.\n")
        f.write("// Surse: Fjelstul World Cup Database (CC-BY-SA 4.0); 2026: openfootball (domeniu public).\n\n")
        f.write("enum MatchOrder {\n    static let byYear: [Int: String] = [\n")
        f.write("\n".join(lines) + "\n    ]\n}\n")
    print("meciuri:", {y: len(v) for y, v in sorted(by_year.items())})
    if bookings_csv or kicks_csv:
        with open(os.path.join(os.path.dirname(out), "MatchEvents.swift"), "w", encoding="utf-8") as f:
            f.write("// GENERAT de tools/build_match_order.py — nu edita manual.\n")
            f.write("// Eliminările și loviturile de departajare, pe meci (indexul din calendarul `MatchOrder`).\n")
            f.write("// „R|minut|1=echipa 1, 0=echipa 2|jucător|1=roșu direct, 2=al doilea galben”; „K|echipa|jucător|1=marcat, 0=ratat”.\n")
            f.write("// Sursa: Fjelstul World Cup Database (CC-BY-SA 4.0), 1930-2022 (cartonașe din 1970).\n\n")
            f.write("enum MatchEventsData {\n    static let byYear: [Int: [Int: String]] = [\n")
            f.write("\n".join(ev_lines) + "\n    ]\n}\n")
        print("evenimente:", sum(len(v) for v in events.values()))


if __name__ == "__main__":
    main(*sys.argv[1:])
