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

Ordinea: după ora de start în același fus (orele din sursă sunt locale; pentru edițiile cu mai multe fusuri
— 1994, 2014, 2018 — se corectează după oraș). Meciurile care au început în același moment sunt marcate
cu „=” în fața lor („se joacă simultan cu meciul anterior”) și apar pe același ecran în aplicație.
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

# Diferența de fus (ore) față de fusul principal al ediției, pentru orașele care nu sunt în el.
# 1994: fusul de Est (EDT); 2014: ora Brasíliei; 2018: ora Moscovei.
TZ_SHIFT = {
    1994: {"Pasadena": -3, "Stanford": -3, "Chicago": -1, "Dallas": -1},
    2014: {"Manaus": -1, "Cuiabá": -1},
    2018: {"Kaliningrad": -1, "Samara": 1, "Yekaterinburg": 2},
}


def kickoff(y, date, time, city):
    """momentul de start, în fusul principal al ediției (pentru ordonare și pentru meciurile simultane)"""
    t = datetime.strptime(f"{date} {time}", "%Y-%m-%d %H:%M")
    return t - timedelta(hours=TZ_SHIFT.get(y, {}).get(city, 0))


def ordered(rows):
    """meciurile unei ediții în ordinea startului (data afișată rămâne ziua locală din sursă)"""
    return sorted(rows, key=lambda m: (m[5], m[2]))

# Penalty-uri ratate în timpul meciurilor (nu la departajare): (an, echipa 1, echipa 2, minut, cine a executat,
# echipa lui, portarul care a apărat sau None dacă a trimis pe lângă / în bară / peste).
# Surse: RSSSF World Cup Archive (rsssf.org/tables/<an>full.html) pentru 1930-2018; 2006 și 2022 din BeSoccer
# (clasamentul penalty-urilor ratate) + rapoartele de meci; 2026 din khelnow.com / BeSoccer / Sky Sports / football360.
MISSED = [
    (1930, "CHI", "FRA", "30", "Saavedra", "CHI", "Alex Thépot"),
    (1930, "ARG", "MEX", "23", "Paternoster", "ARG", "Óscar Bonfiglio"),
    (1930, "ARG", "MEX", "65", "Manuel Rosas", "MEX", "Ángel Bossio"),
    (1934, "ESP", "BRA", "62", "Waldemar de Brito", "BRA", "Ricardo Zamora"),
    (1938, "SWE", "CUB", "42", "Fernández", "CUB", "Henock Abrahamsson"),
    (1938, "BRA", "SWE", "78", "Patesko", "BRA", None),
    (1954, "AUT", "SUI", "42", "Alfred Körner", "AUT", None),
    (1958, "FRA", "SCO", "23", "John Hewie", "SCO", None),
    (1958, "SWE", "HUN", "69", "Nils Liedholm", "SWE", None),
    (1958, "URS", "AUT", "55", "Buzek", "AUT", "Lev Yashin"),
    (1962, "BRA", "ENG", "66", "Garrincha", "BRA", "Ron Springett"),
    (1974, "POL", "SWE", "64", "Staffan Tapper", "SWE", "Jan Tomaszewski"),
    (1974, "GER", "POL", "53", "Uli Hoeneß", "GER", "Jan Tomaszewski"),
    (1978, "PER", "SCO", "63", "Don Masson", "SCO", "Ramón Quiroga"),
    (1978, "ARG", "POL", "39", "Kazimierz Deyna", "POL", "Ubaldo Fillol"),
    (1982, "AUT", "CHI", "26", "Carlos Caszely", "CHI", None),
    (1982, "ESP", "YUG", "14", "Roberto López Ufarte", "ESP", None),
    (1982, "ITA", "GER", "25", "Antonio Cabrini", "ITA", None),
    (1986, "ITA", "KOR", "26", "Alessandro Altobelli", "ITA", None),
    (1986, "MEX", "PAR", "88", "Hugo Sánchez", "MEX", "Roberto Fernández"),
    (1986, "URS", "HUN", "77", "Vadym Yevtushenko", "URS", None),
    (1986, "FRA", "BRA", "75", "Zico", "BRA", "Joël Bats"),
    (1990, "TCH", "USA", "88", "Michal Bílek", "TCH", "Tony Meola"),
    (1990, "ITA", "USA", "20", "Gianluca Vialli", "ITA", None),
    (1990, "YUG", "COL", "81", "Faruk Hadžibegić", "YUG", "René Higuita"),
    (1990, "ESP", "URU", "73", "Rubén Sosa", "URU", None),
    (1990, "ESP", "BEL", "59", "Enzo Scifo", "BEL", None),
    (1998, "NED", "YUG", "50", "Predrag Mijatović", "YUG", None),
    (2002, "KOR", "USA", "39", "Lee Eul-yong", "KOR", "Brad Friedel"),
    (2002, "POL", "USA", "67", "Maciej Żurawski", "POL", "Brad Friedel"),
    (2002, "SWE", "ARG", "88", "Ariel Ortega", "ARG", "Magnus Hedman"),
    (2002, "ESP", "IRL", "62", "Ian Harte", "IRL", "Iker Casillas"),
    (2002, "KOR", "ITA", "4", "Ahn Jung-hwan", "KOR", "Gianluigi Buffon"),
    (2006, "CZE", "GHA", "65", "Asamoah Gyan", "GHA", None),
    (2006, "JPN", "CRO", "22", "Darijo Srna", "CRO", "Yoshikatsu Kawaguchi"),
    (2006, "GER", "SWE", "52", "Henrik Larsson", "SWE", None),
    (2006, "POR", "MEX", "58", "Omar Bravo", "MEX", None),
    (2010, "SRB", "GER", "60", "Lukas Podolski", "GER", "Vladimir Stojković"),
    (2010, "JPN", "DEN", "81", "Jon Dahl Tomasson", "DEN", "Eiji Kawashima"),
    (2010, "ESP", "HON", "62", "David Villa", "ESP", None),
    (2010, "URU", "GHA", "120", "Asamoah Gyan", "GHA", None),
    (2010, "PAR", "ESP", "59", "Óscar Cardozo", "PAR", "Iker Casillas"),
    (2010, "PAR", "ESP", "61", "Xabi Alonso", "ESP", "Justo Villar"),
    (2014, "SUI", "FRA", "32", "Karim Benzema", "FRA", "Diego Benaglio"),
    (2018, "KSA", "EGY", "41", "Fahad Al-Muwallad", "KSA", "Essam El-Hadary"),
    (2018, "IRN", "POR", "53", "Cristiano Ronaldo", "POR", "Alireza Beiranvand"),
    (2018, "PER", "DEN", "45+1", "Christian Cueva", "PER", None),
    (2018, "ARG", "ISL", "64", "Lionel Messi", "ARG", "Hannes Þór Halldórsson"),
    (2018, "NGA", "ISL", "83", "Gylfi Sigurðsson", "ISL", None),
    (2018, "SUI", "CRC", "90+3", "Bryan Ruiz", "CRC", None),
    (2018, "CRO", "DEN", "116", "Luka Modrić", "CRO", "Kasper Schmeichel"),
    (2022, "BEL", "CAN", "10", "Alphonso Davies", "CAN", "Thibaut Courtois"),
    (2022, "MEX", "POL", "58", "Robert Lewandowski", "POL", "Guillermo Ochoa"),
    (2022, "GHA", "URU", "21", "André Ayew", "GHA", "Sergio Rochet"),
    (2022, "POL", "KSA", "44", "Salem Al-Dawsari", "KSA", "Wojciech Szczęsny"),
    (2022, "POL", "ARG", "39", "Lionel Messi", "ARG", "Wojciech Szczęsny"),
    (2022, "ENG", "FRA", "84", "Harry Kane", "ENG", None),
    (2026, "ARG", "AUT", "5", "Lionel Messi", "ARG", None),
    (2026, "EGY", "IRN", "9", "Mehdi Taremi", "IRN", "Mostafa Shobeir"),
    (2026, "NOR", "FRA", "50", "Jørgen Strand Larsen", "NOR", "Mike Maignan"),
    (2026, "BRA", "NOR", "14", "Bruno Guimarães", "BRA", "Ørjan Nyland"),
    (2026, "ARG", "EGY", "21", "Lionel Messi", "ARG", "Mostafa Shobeir"),
    (2026, "FRA", "MAR", "28", "Kylian Mbappé", "FRA", "Yassine Bounou"),
]


def person(r):
    return r["family_name"] if r["given_name"] == "not applicable" else f"{r['given_name']} {r['family_name']}"


def main(matches_csv, bookings_csv=None, kicks_csv=None, out=os.path.join(ROOT, "ios", "App", "Sources", "MatchOrder.swift")):
    by_year = defaultdict(list)
    for r in csv.DictReader(open(matches_csv, encoding="utf-8")):
        if "Men's" not in r["tournament_name"]:
            continue
        y = int(r["tournament_id"][3:])
        by_year[y].append((r["match_date"], r["match_time"], r["match_id"], code(r["home_team_code"]), code(r["away_team_code"]),
                           kickoff(y, r["match_date"], r["match_time"], r["city_name"])))
    for m in json.load(open(SRC_2026, encoding="utf-8"))["matches"]:
        t, _, tz = m["time"].partition(" UTC")
        local = datetime.strptime(f"{m['date']} {t}", "%Y-%m-%d %H:%M")
        utc = local - timedelta(hours=int(tz or 0))
        by_year[2026].append((utc.strftime("%Y-%m-%d"), utc.strftime("%H:%M"), "", CODE_2026[m["team1"]], CODE_2026[m["team2"]], utc))
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
    # penalty-urile ratate, pe meciul din calendar (perechea de echipe din ediția respectivă)
    extra = defaultdict(list)
    for y, t1, t2, minute, taker, team, keeper in MISSED:
        ms = ordered(by_year[y])
        idx = [i for i, m in enumerate(ms) if {m[3], m[4]} == {t1, t2}]
        assert len(idx) == 1, (y, t1, t2, idx)
        home = ms[idx[0]][3]
        assert team in (t1, t2), (y, t1, t2, team)
        extra[(y, idx[0])].append(f"M|{minute}|{1 if team == home else 0}|{taker}|{keeper or ''}")
    for e in events.values():
        assert all("\"" not in x and ";" not in x[2:] for x in e), e
    ev_lines = []

    lines = []
    together = 0
    for y in sorted(by_year):
        ms = ordered(by_year[y])
        ev = [f"{i}: \"{';'.join(events.get(m[2], []) + extra.get((y, i), []))}\"" for i, m in enumerate(ms)
              if m[2] in events or (y, i) in extra]
        if ev:
            ev_lines.append(f"        {y}: [" + ", ".join(ev) + "],")
        # data afișată = ziua din sursă (MMDD); pentru 2026, ziua UTC
        # „=” = a început în același moment cu meciul anterior (se joacă pe același ecran)
        items = " ".join(("=" if i and m[5] == ms[i - 1][5] else "") + f"{m[0][5:7]}{m[0][8:10]}{m[3]}-{m[4]}"
                         for i, m in enumerate(ms))
        together += items.count("=")
        assert all(re.fullmatch(r"=?\d{4}[A-Z]{3}-[A-Z]{3}", x) for x in items.split()), y
        lines.append(f"        {y}: \"{items}\",")
    with open(out, "w", encoding="utf-8") as f:
        f.write("// GENERAT de tools/build_match_order.py — nu edita manual.\n")
        f.write("// Ordinea cronologică a tuturor meciurilor fiecărei ediții: „MMDD” + echipa 1 + „-” + echipa 2.\n")
        f.write("// „=” în față: meciul a început în același moment cu cel anterior (se joacă simultan, pe același ecran).\n")
        f.write("// Surse: Fjelstul World Cup Database (CC-BY-SA 4.0); 2026: openfootball (domeniu public).\n\n")
        f.write("enum MatchOrder {\n    static let byYear: [Int: String] = [\n")
        f.write("\n".join(lines) + "\n    ]\n}\n")
    print("meciuri:", {y: len(v) for y, v in sorted(by_year.items())}, "simultane cu anteriorul:", together)
    if bookings_csv or kicks_csv or MISSED:
        with open(os.path.join(os.path.dirname(out), "MatchEvents.swift"), "w", encoding="utf-8") as f:
            f.write("// GENERAT de tools/build_match_order.py — nu edita manual.\n")
            f.write("// Eliminările și loviturile de departajare, pe meci (indexul din calendarul `MatchOrder`).\n")
            f.write("// „R|minut|1=echipa 1, 0=echipa 2|jucător|1=roșu direct, 2=al doilea galben”; „K|echipa|jucător|1=marcat, 0=ratat”;\n")
            f.write("// „M|minut|echipa|jucător|portarul care a apărat (gol = pe lângă / bară / peste)” = penalty ratat în timpul jocului.\n")
            f.write("// Surse: Fjelstul World Cup Database (CC-BY-SA 4.0), 1930-2022 (cartonașe din 1970);\n")
            f.write("// penalty-urile ratate: RSSSF, BeSoccer și rapoarte de meci (vezi MISSED în generator).\n\n")
            f.write("enum MatchEventsData {\n    static let byYear: [Int: [Int: String]] = [\n")
            f.write("\n".join(ev_lines) + "\n    ]\n}\n")
        print("evenimente:", sum(len(v) for v in events.values()))


if __name__ == "__main__":
    main(*sys.argv[1:])
