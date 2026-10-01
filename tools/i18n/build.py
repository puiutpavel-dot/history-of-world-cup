"""Generează resursele pentru limbile în plus (es, pt, de, fr, it), după `node tools/export_ios_data.js`:
- Data_<limbă>.json — Data_en.json cu textele traduse (aceeași structură; motorul nu citește textele);
- UI_<limbă>.json — dicționarul englez → limbă (interfață + date), folosit de `tr()` / `translated()` în aplicație.
Traducerile: tools/i18n/<limbă>.json (englez → limbă). Un text fără traducere rămâne în engleză (și e raportat)."""
import glob
import json
import os
import re
import sys

HERE = os.path.dirname(__file__)
sys.path.insert(0, HERE)
from extract_data import PATHS, walk  # noqa: E402

RES = os.path.join(HERE, "..", "..", "ios", "WorldCupCore", "Sources", "WorldCupCore", "Resources")
LANGS = ["es", "pt", "de", "fr", "it"]
PEN = re.compile(r"^penalties (\d+)-(\d+)$")


def main():
    data_en = json.load(open(os.path.join(RES, "Data_en.json"), encoding="utf-8"))
    for lang in LANGS:
        t = {}
        for f in [os.path.join(HERE, lang + ".json")]:
            t.update(json.load(open(f, encoding="utf-8")))
        missing = set()

        def tr(s):
            if s in t:
                return t[s]
            m = PEN.match(s)
            if m and "penalties {0}-{1}" in t:
                return t["penalties {0}-{1}"].replace("{0}", m.group(1)).replace("{1}", m.group(2))
            if re.search(r"[A-Za-z]", s):
                missing.add(s)
            return s

        out = walk(data_en, "", tr)
        json.dump(out, open(os.path.join(RES, f"Data_{lang}.json"), "w", encoding="utf-8"), ensure_ascii=False)
        json.dump(t, open(os.path.join(RES, f"UI_{lang}.json"), "w", encoding="utf-8"), ensure_ascii=False)
        print(f"{lang}: {len(t)} traduceri; texte rămase în engleză: {len(missing)}")
        for s in sorted(missing)[:10]:
            print("   ", s[:100])


if __name__ == "__main__":
    main()
