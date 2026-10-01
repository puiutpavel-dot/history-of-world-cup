"""Extrage textele traductibile din Data_en.json (generat de export_ios_data.js) → tools/i18n/data_en.json.
Notele „penalties 4-3” devin șablonul „penalties {0}-{1}”."""
import json
import os
import re

HERE = os.path.dirname(__file__)
SRC = os.path.join(HERE, "..", "..", "ios", "WorldCupCore", "Sources", "WorldCupCore", "Resources", "Data_en.json")
# câmpurile cu text (restul: coduri, steaguri, ani, nume de jucători, minute)
PATHS = {
    ".countries.best.label", ".countries.entries.finishLabel", ".countries.entries.matches.note",
    ".countries.entries.matches.round", ".countries.name", ".editions.ball", ".editions.host", ".editions.note",
    ".formats.summary", ".history.families.text", ".history.rulesTimeline.items", ".history.rulesTimeline.title",
    ".history.squadRules.text", ".history.stories.coach", ".history.stories.context", ".history.stories.final",
    ".history.stories.moments", ".history.titlePath.games", ".legends.bio", ".quiz.q", ".quiz.options",
    ".shadowTeams.name", ".teams.name",
}
PEN = re.compile(r"penalties (\d+)-(\d+)")


def template(s):
    return PEN.sub("penalties {0}-{1}", s)


def walk(x, path, f):
    if isinstance(x, dict):
        return {k: walk(v, path + "." + k, f) for k, v in x.items()}
    if isinstance(x, list):
        return [walk(v, path, f) for v in x]
    if isinstance(x, str) and path in PATHS:
        return f(x)
    return x


def main():
    d = json.load(open(SRC, encoding="utf-8"))
    out = []
    walk(d, "", lambda s: out.append(template(s)) or s)
    uniq = [s for s in dict.fromkeys(out) if re.search(r"[A-Za-z]", s)]
    json.dump(uniq, open(os.path.join(HERE, "data_en.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print(len(uniq), "texte,", sum(map(len, uniq)), "caractere")


if __name__ == "__main__":
    main()
