"""Completează pagina din App Store a aplicației (versiunea 1.0), prin App Store Connect API.

Rulează în GitHub Actions (workflow „Pagina App Store”), cu secretele ASC_KEY_ID, ASC_ISSUER_ID, ASC_KEY_P8.
Idempotent: poate fi rulat de mai multe ori (actualizează ce există).

Face: categoriile, numele/subtitlul/linkul de confidențialitate (en-US + ro), declarația de drepturi,
chestionarul de vârstă (totul „None” → 4+), prețul aplicației (gratuită) și disponibilitatea (toate țările),
versiunea 1.0 cu build-ul ales, descrierea/cuvintele cheie/textul promoțional/linkul de suport (en-US + ro),
capturile de ecran iPhone 6,9" (din branch-ul `screenshots`) și notele pentru App Review.

NU face (le face titularul contului în App Store Connect): „App Privacy” (Data Not Collected), datele de contact
pentru App Review (nume, telefon, e-mail), atașarea achiziției la versiune și „Submit for Review”.
"""
import base64
import hashlib
import os
import re
import sys
import time

import jwt
import requests

APP_ID = "6817332563"
ROOT = os.path.join(os.path.dirname(__file__), "..")
SHOTS_DIR = sys.argv[1] if len(sys.argv) > 1 else "/tmp/shots"
BUILD_NUMBER = os.environ.get("BUILD_NUMBER", "").strip()
VERSION = "1.0"
COPYRIGHT = os.environ.get("COPYRIGHT", "").strip()
PAGES = "https://puiutpavel-dot.github.io/history-of-world-cup"
SCREENS = ["menu", "runLive", "runQuiz", "runBracket", "runShootout", "runFinal", "museum", "quiz", "country"]

API = "https://api.appstoreconnect.apple.com"
S = requests.Session()
WARN = []


def token():
    key = os.environ["ASC_KEY_P8"]
    if "BEGIN PRIVATE KEY" not in key:
        key = base64.b64decode(key).decode()
    now = int(time.time())
    return jwt.encode({"iss": os.environ["ASC_ISSUER_ID"], "iat": now, "exp": now + 1100, "aud": "appstoreconnect-v1"},
                      key, algorithm="ES256", headers={"kid": os.environ["ASC_KEY_ID"], "typ": "JWT"})


def call(method, path, body=None, ok=(200, 201, 204), fatal=True):
    S.headers["Authorization"] = f"Bearer {token()}"
    r = S.request(method, path if path.startswith("http") else API + path, json=body, timeout=90)
    if r.status_code not in ok:
        msg = f"{method} {path} → {r.status_code}\n{r.text[:2500]}"
        if fatal:
            print(f"::error::{msg}")
            sys.exit(1)
        print(f"::warning::{msg}")
        WARN.append(f"{method} {path.split('?')[0]} → {r.status_code}: {errors_text(r)}")
        return None
    return r.json() if r.content else {}


def errors_text(r):
    try:
        return "; ".join(f"{e.get('code')} {e.get('detail')} [{e.get('source', {}).get('pointer', '')}]"
                         for e in r.json().get("errors", []))[:1200]
    except Exception:
        return r.text[:600]


def get_all(path):
    out, url = [], path
    while url:
        j = call("GET", url)
        out += j.get("data", [])
        url = j.get("links", {}).get("next")
    return out


LOG = []


def step(msg):
    print(f"\n== {msg}", flush=True)
    LOG.append(f"**{msg}**")


def log(*parts):
    msg = " ".join(str(p) for p in parts)
    print(msg, flush=True)
    LOG.append(msg)


def rel(type_, id_):
    return {"data": {"type": type_, "id": id_}}


def read_metadata():
    """textele din docs/app-store/METADATA.md și REVIEW_NOTES.md"""
    md = open(os.path.join(ROOT, "docs", "app-store", "METADATA.md"), encoding="utf-8").read()

    def bullet(section, lang):
        block = md.split(section, 1)[1].split("\n## ", 1)[0]
        m = re.search(rf"^- {lang}: (.+)$", block, re.M)
        return m.group(1).strip().strip("*").strip("`").strip() if m else None

    def fenced(section):
        block = md.split(section, 1)[1]
        return block.split("```", 2)[1].strip("\n")

    subtitle = {"ro": bullet("## Subtitlu", "ro"), "en": bullet("## Subtitlu", "en")}
    subtitle = {k: re.sub(r"\s*\(\d+\)$", "", v).strip("*").strip() for k, v in subtitle.items()}
    keywords = {"ro": bullet("## Cuvinte-cheie", "ro"), "en": bullet("## Cuvinte-cheie", "en")}
    keywords = {k: v.split("`")[0].strip() for k, v in keywords.items()}
    promo = {"ro": bullet("## Text promoțional", "ro"), "en": bullet("## Text promoțional", "en")}
    desc = {"ro": fenced("## Descriere (ro)"), "en": fenced("## Description (en)")}
    notes = open(os.path.join(ROOT, "docs", "app-store", "REVIEW_NOTES.md"), encoding="utf-8").read().split("```", 2)[1].strip("\n")
    for k in ("ro", "en"):
        assert len(subtitle[k]) <= 30, subtitle
        assert len(keywords[k]) <= 100, keywords
        assert len(promo[k]) <= 170, promo
        assert len(desc[k]) <= 4000
    return subtitle, keywords, promo, desc, notes


LOCALES = {"en-US": "en", "ro": "ro"}
NAMES = {"en-US": "Football Finals Archive", "ro": "Arhiva Mondialelor"}
PRIVACY = {"en-US": f"{PAGES}/privacy-en.html", "ro": f"{PAGES}/privacy.html"}
SUPPORT = {"en-US": f"{PAGES}/support-en.html", "ro": f"{PAGES}/support.html"}


def app_info_and_categories():
    step("App info: categorii, nume, subtitlu, confidențialitate")
    subtitle = META[0]
    infos = get_all(f"/v1/apps/{APP_ID}/appInfos")
    info = next((i for i in infos if i["attributes"].get("appStoreState") not in ("READY_FOR_SALE", "REPLACED_WITH_NEW_INFO")
                 and i["attributes"].get("state") not in ("READY_FOR_DISTRIBUTION",)), infos[0])
    print("appInfo", info["id"], info["attributes"].get("appStoreState") or info["attributes"].get("state"))
    call("PATCH", f"/v1/appInfos/{info['id']}", {"data": {"type": "appInfos", "id": info["id"], "relationships": {
        "primaryCategory": rel("appCategories", "GAMES"),
        "primarySubcategoryOne": rel("appCategories", "GAMES_TRIVIA"),
        "primarySubcategoryTwo": rel("appCategories", "GAMES_SPORTS"),
        "secondaryCategory": rel("appCategories", "EDUCATION")}}}, fatal=False)
    have = {l["attributes"]["locale"]: l for l in get_all(f"/v1/appInfos/{info['id']}/appInfoLocalizations")}
    for loc, lang in LOCALES.items():
        attrs = {"name": NAMES[loc], "subtitle": subtitle[lang], "privacyPolicyUrl": PRIVACY[loc]}
        if loc in have:
            call("PATCH", f"/v1/appInfoLocalizations/{have[loc]['id']}", {"data": {
                "type": "appInfoLocalizations", "id": have[loc]["id"], "attributes": attrs}}, fatal=False)
        else:
            call("POST", "/v1/appInfoLocalizations", {"data": {"type": "appInfoLocalizations",
                                                               "attributes": {"locale": loc, **attrs},
                                                               "relationships": {"appInfo": rel("appInfos", info["id"])}}}, fatal=False)
        log(loc, attrs["name"], "|", attrs["subtitle"])
    return info


def age_rating(info):
    step("Chestionarul de vârstă (totul None / Nu → 4+)")
    j = call("GET", f"/v1/appInfos/{info['id']}/ageRatingDeclaration", fatal=False)
    if not j:
        return
    decl = j["data"]
    skip = {"kidsAgeBand", "ageRatingOverride", "ageRatingOverrideV2", "koreaAgeRatingOverride", "developerAgeRatingInfoUrl",
            "seventeenPlus"}
    # Apple cere toate câmpurile deodată; tipul fiecăruia (text „NONE” sau boolean) îl aflăm din erorile API-ului
    attrs = {k: (v if v not in (None, "", []) else "NONE") for k, v in decl["attributes"].items() if k not in skip}
    for _ in range(12):
        S.headers["Authorization"] = f"Bearer {token()}"
        r = S.patch(f"{API}/v1/ageRatingDeclarations/{decl['id']}", json={"data": {
            "type": "ageRatingDeclarations", "id": decl["id"], "attributes": attrs}}, timeout=90)
        if r.status_code == 200:
            break
        changed = False
        for e in r.json().get("errors", []):
            key = e.get("source", {}).get("pointer", "").rsplit("/", 1)[-1]
            detail = e.get("detail", "")
            if not key:
                continue
            if "Expected a BOOLEAN" in detail and attrs.get(key) is not False:
                attrs[key] = False
                changed = True
            elif ("Expected a STRING" in detail or "Expected a" in detail) and attrs.get(key) is False:
                attrs[key] = "NONE"
                changed = True
            elif "REQUIRED" in e.get("code", "") and key not in attrs:
                attrs[key] = "NONE"
                changed = True
            elif "ENUM" in e.get("code", "") or "not a valid" in detail or "invalid" in detail.lower():
                if attrs.get(key) == "NONE":
                    attrs[key] = False
                    changed = True
        if not changed:
            print(f"::warning::vârsta: {r.status_code} {r.text[:1500]}")
            WARN.append("chestionarul de vârstă nu s-a putut completa automat: " + errors_text(r)
                        + " | trimis: " + ", ".join(f"{k}={v}" for k, v in attrs.items()))
            return
    else:
        WARN.append("chestionarul de vârstă: prea multe încercări")
        return
    final = call("GET", f"/v1/appInfos/{info['id']}/ageRatingDeclaration")["data"]["attributes"]
    log("vârstă: " + (", ".join(f"{k}={v}" for k, v in final.items() if v not in (None, "NONE", False)) or "toate None / Nu → 4+"))


def rights_price_availability():
    step("Drepturi de conținut")
    call("PATCH", f"/v1/apps/{APP_ID}", {"data": {"type": "apps", "id": APP_ID,
                                                   "attributes": {"contentRightsDeclaration": "USES_THIRD_PARTY_CONTENT"}}}, fatal=False)
    log("USES_THIRD_PARTY_CONTENT (date istorice cu licență deschisă, CC-BY-SA / domeniu public)")

    step("Preț: gratuită")
    sched = call("GET", f"/v1/apps/{APP_ID}/appPriceSchedule", ok=(200, 404), fatal=False)
    if sched and sched.get("data"):
        log("există deja un program de preț")
    else:
        points = get_all(f"/v1/apps/{APP_ID}/appPricePoints?filter[territory]=USA&limit=200")
        free = next((p for p in points if p["attributes"]["customerPrice"] in ("0", "0.0", "0.00")), None)
        if free:
            call("POST", "/v1/appPriceSchedules", {
                "data": {"type": "appPriceSchedules", "relationships": {
                    "app": rel("apps", APP_ID), "baseTerritory": rel("territories", "USA"),
                    "manualPrices": {"data": [{"type": "appPrices", "id": "${p0}"}]}}},
                "included": [{"type": "appPrices", "id": "${p0}", "attributes": {"startDate": None},
                              "relationships": {"appPricePoint": rel("appPricePoints", free["id"])}}]}, fatal=False)
            log("gratuită")
        else:
            WARN.append("nu am găsit prețul 0")

    step("Disponibilitate: toate țările")
    avail = call("GET", f"/v1/apps/{APP_ID}/appAvailabilityV2", ok=(200, 404), fatal=False)
    if avail and avail.get("data"):
        log("există deja")
    else:
        terr = get_all("/v1/territories?limit=200")
        call("POST", "/v2/appAvailabilities", {
            "data": {"type": "appAvailabilities", "attributes": {"availableInNewTerritories": True},
                     "relationships": {"app": rel("apps", APP_ID), "territoryAvailabilities": {
                         "data": [{"type": "territoryAvailabilities", "id": f"${{t{i}}}"} for i in range(len(terr))]}}},
            "included": [{"type": "territoryAvailabilities", "id": f"${{t{i}}}", "attributes": {"available": True},
                          "relationships": {"territory": rel("territories", t["id"])}} for i, t in enumerate(terr)]}, fatal=False)
        log("disponibilă în", len(terr), "țări")


def version_and_build():
    step(f"Versiunea {VERSION}")
    versions = get_all(f"/v1/apps/{APP_ID}/appStoreVersions?filter[platform]=IOS&limit=50")
    editable = ("PREPARE_FOR_SUBMISSION", "DEVELOPER_REJECTED", "REJECTED", "METADATA_REJECTED", "INVALID_BINARY")
    ver = next((v for v in versions if (v["attributes"].get("appStoreState") or v["attributes"].get("appVersionState")) in editable
                or v["attributes"].get("appVersionState") in ("PREPARE_FOR_SUBMISSION", "DEVELOPER_REJECTED", "REJECTED")), None)
    if not ver:
        ver = call("POST", "/v1/appStoreVersions", {"data": {"type": "appStoreVersions",
                                                              "attributes": {"platform": "IOS", "versionString": VERSION},
                                                              "relationships": {"app": rel("apps", APP_ID)}}})["data"]
        log("creată")
    vid = ver["id"]
    attrs = {"releaseType": "AFTER_APPROVAL"}
    if COPYRIGHT:
        attrs["copyright"] = COPYRIGHT
    if ver["attributes"].get("versionString") != VERSION:
        attrs["versionString"] = VERSION
    call("PATCH", f"/v1/appStoreVersions/{vid}", {"data": {"type": "appStoreVersions", "id": vid, "attributes": attrs}}, fatal=False)
    log("versiune", vid, ver["attributes"].get("appStoreState") or ver["attributes"].get("appVersionState"), attrs)

    step("Build-ul")
    q = f"/v1/builds?filter[app]={APP_ID}&filter[preReleaseVersion.version]={VERSION}&sort=-uploadedDate&limit=20"
    builds = get_all(q)
    valid = [b for b in builds if b["attributes"].get("processingState") == "VALID" and not b["attributes"].get("expired")]
    if BUILD_NUMBER:
        valid = [b for b in valid if b["attributes"]["version"] == BUILD_NUMBER]
    if not valid:
        WARN.append("niciun build VALID pentru 1.0" + (f" cu numărul {BUILD_NUMBER}" if BUILD_NUMBER else ""))
        log("::warning::niciun build valid", [(b["attributes"]["version"], b["attributes"].get("processingState")) for b in builds])
    else:
        b = valid[0]
        call("PATCH", f"/v1/appStoreVersions/{vid}/relationships/build", rel("builds", b["id"]), fatal=False)
        log("build atașat:", b["attributes"]["version"])
    return vid


def version_texts(vid):
    step("Descriere, cuvinte cheie, text promoțional, suport (en-US + ro)")
    _, keywords, promo, desc, _ = META
    have = {l["attributes"]["locale"]: l for l in get_all(f"/v1/appStoreVersions/{vid}/appStoreVersionLocalizations")}
    out = {}
    for loc, lang in LOCALES.items():
        attrs = {"description": desc[lang], "keywords": keywords[lang], "promotionalText": promo[lang], "supportUrl": SUPPORT[loc]}
        if loc in have:
            call("PATCH", f"/v1/appStoreVersionLocalizations/{have[loc]['id']}", {"data": {
                "type": "appStoreVersionLocalizations", "id": have[loc]["id"], "attributes": attrs}}, fatal=False)
            out[loc] = have[loc]["id"]
        else:
            r = call("POST", "/v1/appStoreVersionLocalizations", {"data": {
                "type": "appStoreVersionLocalizations", "attributes": {"locale": loc, **attrs},
                "relationships": {"appStoreVersion": rel("appStoreVersions", vid)}}}, fatal=False)
            if r:
                out[loc] = r["data"]["id"]
        log(loc, "ok")
    return out


def upload(kind, parent_rel, parent_type, parent_id, path, attr_name="uploaded"):
    data = open(path, "rb").read()
    res = call("POST", f"/v1/{kind}", {"data": {"type": kind, "attributes": {"fileName": os.path.basename(path), "fileSize": len(data)},
                                                  "relationships": {parent_rel: rel(parent_type, parent_id)}}})["data"]
    for op in res["attributes"]["uploadOperations"]:
        r = requests.request(op["method"], op["url"], data=data[op["offset"]:op["offset"] + op["length"]],
                             headers={h["name"]: h["value"] for h in op.get("requestHeaders", [])}, timeout=180)
        r.raise_for_status()
    call("PATCH", f"/v1/{kind}/{res['id']}", {"data": {"type": kind, "id": res["id"],
                                                        "attributes": {attr_name: True, "sourceFileChecksum": hashlib.md5(data).hexdigest()}}})
    return res["id"]


def screenshots(locs):
    step('Capturi iPhone 6,9" (APP_IPHONE_67)')
    for loc, lid in locs.items():
        prefix = "" if loc == "en-US" else "ro_"
        files = [os.path.join(SHOTS_DIR, f"{prefix}{s}.png") for s in SCREENS]
        files = [f for f in files if os.path.exists(f)]
        if len(files) < 3:
            WARN.append(f"{loc}: doar {len(files)} capturi găsite")
            continue
        sets = get_all(f"/v1/appStoreVersionLocalizations/{lid}/appScreenshotSets")
        sset = next((s for s in sets if s["attributes"]["screenshotDisplayType"] == "APP_IPHONE_67"), None)
        if not sset:
            sset = call("POST", "/v1/appScreenshotSets", {"data": {"type": "appScreenshotSets",
                                                                   "attributes": {"screenshotDisplayType": "APP_IPHONE_67"},
                                                                   "relationships": {"appStoreVersionLocalization": rel("appStoreVersionLocalizations", lid)}}})["data"]
        for old in get_all(f"/v1/appScreenshotSets/{sset['id']}/appScreenshots"):
            call("DELETE", f"/v1/appScreenshots/{old['id']}", fatal=False)
        for f in files:
            upload("appScreenshots", "appScreenshotSet", "appScreenshotSets", sset["id"], f)
        log(loc, len(files), "capturi:", ", ".join(os.path.basename(f) for f in files))


def review_details(vid):
    step("Note pentru App Review")
    notes = META[4]
    j = call("GET", f"/v1/appStoreVersions/{vid}/appStoreReviewDetail", ok=(200, 404), fatal=False)
    attrs = {"notes": notes, "demoAccountRequired": False}
    if j and j.get("data"):
        call("PATCH", f"/v1/appStoreReviewDetails/{j['data']['id']}", {"data": {"type": "appStoreReviewDetails",
                                                                                "id": j["data"]["id"], "attributes": attrs}}, fatal=False)
    else:
        call("POST", "/v1/appStoreReviewDetails", {"data": {"type": "appStoreReviewDetails", "attributes": attrs,
                                                            "relationships": {"appStoreVersion": rel("appStoreVersions", vid)}}}, fatal=False)
    log("note setate; contactul (nume, telefon, e-mail) se completează în App Store Connect")


def main():
    global META
    META = read_metadata()
    app = call("GET", f"/v1/apps/{APP_ID}")["data"]["attributes"]
    print(app["name"], app["bundleId"], app.get("primaryLocale"))
    info = app_info_and_categories()
    age_rating(info)
    rights_price_availability()
    vid = version_and_build()
    locs = version_texts(vid)
    screenshots(locs)
    review_details(vid)
    summary = os.environ.get("GITHUB_STEP_SUMMARY", os.devnull)
    with open(summary, "a") as f:
        f.write("### Pagina App Store — versiunea 1.0\n\n" + "\n".join(f"- {l}" if not l.startswith("**") else f"\n{l}\n" for l in LOG) + "\n\n")
        f.write("✅ Gata, cu avertismente:\n" + "".join(f"- {w}\n" for w in WARN) if WARN else "✅ Totul completat.\n")
        f.write("\nRămâne în App Store Connect: App Privacy (Data Not Collected), contactul pentru App Review, "
                "achiziția „Full History” bifată la versiune, Submit for Review.\n")
    print("\nAVERTISMENTE:", WARN or "niciunul")


if __name__ == "__main__":
    main()
