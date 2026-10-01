"""Verifică traducerile unei limbi: python3 tools/i18n/check.py es
Toate textele din ui_en.json și data_en.json trebuie să aibă traducere în tools/i18n/<limbă>.json,
cu aceleași {0}, {1}… și cu formulele fixe din FIXED."""
import glob
import json
import os
import re
import sys

HERE = os.path.dirname(__file__)
FIXED = {
    "es": {"after extra time": "tras la prórroga", "penalties {0}-{1}": "penaltis {0}-{1}"},
    "pt": {"after extra time": "após a prorrogação", "penalties {0}-{1}": "pênaltis {0}-{1}"},
    "de": {"after extra time": "nach Verlängerung", "penalties {0}-{1}": "Elfmeterschießen {0}-{1}"},
    "fr": {"after extra time": "après prolongation", "penalties {0}-{1}": "tirs au but {0}-{1}"},
    "it": {"after extra time": "dopo i supplementari", "penalties {0}-{1}": "rigori {0}-{1}"},
}


def load(lang):
    t = {}
    for f in [os.path.join(HERE, lang + ".json")]:
        t.update(json.load(open(f, encoding="utf-8")))
    return t


def ph(s):
    return sorted(re.findall(r"\{\d+\}", s))


def main(lang):
    t = load(lang)
    need = json.load(open(os.path.join(HERE, "ui_en.json"))) + json.load(open(os.path.join(HERE, "data_en.json")))
    missing = [k for k in dict.fromkeys(need) if k not in t]
    bad = [k for k in t if ph(k) != ph(t[k])]
    wrong = [k for k, v in FIXED.get(lang, {}).items() if t.get(k) != v]
    empty = [k for k in t if not str(t[k]).strip()]
    print(f"{lang}: {len(t)} traduceri; lipsă {len(missing)}; acolade greșite {len(bad)}; fixe greșite {len(wrong)}; goale {len(empty)}")
    for k in missing[:30]:
        print("  LIPSĂ:", k[:100])
    for k in bad[:30]:
        print("  ACOLADE:", k[:80], "→", t[k][:80])
    for k in wrong:
        print("  FIX:", k, "→ trebuie", FIXED[lang][k])
    return not (missing or bad or wrong or empty)


if __name__ == "__main__":
    sys.exit(0 if main(sys.argv[1]) else 1)
