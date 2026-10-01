"""Extrage toate textele englezești ale interfeței din sursele Swift: argumentul al doilea al lui
tr("ro", "en") și câmpurile `en: "..."` (faptele scrise de mână). Interpolările \\(…) devin {0}, {1}…
Rezultatul: tools/i18n/ui_en.json (listă de șabloane) — baza traducerilor din tools/i18n/<limbă>.json.
"""
import glob
import json
import os
import re
import sys

ROOT = os.path.join(os.path.dirname(__file__), "..", "..")
FILES = sorted(glob.glob(os.path.join(ROOT, "ios/App/Sources/*.swift")) +
               glob.glob(os.path.join(ROOT, "ios/WorldCupCore/Sources/WorldCupCore/*.swift")))


def read_literal(s, i):
    """s[i] == '"' → (șablon, poziția de după ghilimeaua de închidere); interpolările → {n}"""
    assert s[i] == '"'
    i += 1
    out, n = [], 0
    while True:
        c = s[i]
        if c == '\\':
            nx = s[i + 1]
            if nx == '(':
                depth, j = 1, i + 2
                while depth:
                    if s[j] == '(':
                        depth += 1
                    elif s[j] == ')':
                        depth -= 1
                    elif s[j] == '"':  # literal în interpolare
                        _, j = read_literal(s, j)
                        continue
                    j += 1
                out.append("{%d}" % n)
                n += 1
                i = j
                continue
            out.append({'n': '\n', 't': '\t', '"': '"', '\\': '\\'}.get(nx, nx))
            i += 2
            continue
        if c == '"':
            return "".join(out), i + 1
        out.append(c)
        i += 1


def skip_ws(s, i):
    while s[i] in " \t\r\n":
        i += 1
    return i


def main():
    found, odd = [], []
    for f in FILES:
        s = open(f, encoding="utf-8").read()
        for m in re.finditer(r'(?<![A-Za-z_.])tr\(', s):
            i = skip_ws(s, m.end())
            if s[i] != '"':
                odd.append((os.path.basename(f), s[m.start():m.start() + 60].replace("\n", " ")))
                continue
            _, i = read_literal(s, i)
            i = skip_ws(s, i)
            if s[i] != ',':
                odd.append((os.path.basename(f), s[m.start():m.start() + 60]))
                continue
            i = skip_ws(s, i + 1)
            if s[i] != '"':
                odd.append((os.path.basename(f), s[m.start():m.start() + 80].replace("\n", " ")))
                continue
            en, _ = read_literal(s, i)
            found.append(en)
        for m in re.finditer(r'\ben: "', s):
            en, _ = read_literal(s, m.end() - 1)
            found.append(en)
    # textele alese din liste (tr(ro[i], en[i])): lunile anului din fixtureDate
    found += ["January", "February", "March", "April", "May", "June", "July", "August", "September",
              "October", "November", "December"]
    # notele meciurilor reale traduse la afișare (localizedNote), în engleză
    found += ["extra time", "replay", "group play-off", "golden goal", "final group (round robin)",
              "\"Maracanazo\" — the deciding match of the final group", "\"The Miracle of Bern\"",
              "\"The Hand of God\" + \"The Goal of the Century\""]
    # fără șabloanele formate doar din {n} și punctuație (ar potrivi orice text)
    found = [x for x in found if re.search(r"[A-Za-z]", re.sub(r"\{\d+\}", "", x))]
    uniq = list(dict.fromkeys(found))
    json.dump(uniq, open(os.path.join(os.path.dirname(__file__), "ui_en.json"), "w", encoding="utf-8"),
              ensure_ascii=False, indent=1)
    print(len(found), "apeluri,", len(uniq), "șabloane unice,", sum(len(x) for x in uniq), "caractere")
    for o in odd:
        print("NELITERAL:", o, file=sys.stderr)


if __name__ == "__main__":
    main()
