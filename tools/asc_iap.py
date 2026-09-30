"""Creează (sau completează) achiziția „Full History” în App Store Connect, prin API.

Rulează în GitHub Actions (workflow „Achiziție Full History”), cu aceleași secrete ca TestFlight:
ASC_KEY_ID, ASC_ISSUER_ID, ASC_KEY_P8. E idempotent: ce există deja nu se recreează.

Pași: produsul non-consumable (Family Sharing pornit) → numele și descrierea în engleză și română →
prețul (4,99 USD, celelalte țări echivalent automat) → disponibil în toate țările →
captura de ecran pentru App Review (ecranul de cumpărare din capturile CI).
Prima achiziție a unei aplicații se trimite la review împreună cu o versiune a aplicației.
"""
import base64
import hashlib
import json
import os
import sys
import time

import jwt
import requests

APP_ID = "6817332563"
PRODUCT_ID = "com.puiutpavel.historyofworldcup.fullhistory"
PRICE_USD = "4.99"
LOCALIZATIONS = {
    # nume: max. 30 de caractere; descriere: max. 55
    "en-US": ("Full History", "Every World Cup 1930–2026 and every quiz"),
    "ro": ("Full History", "Toate Mondialele 1930–2026 și toate quizurile"),
}
REVIEW_NOTE = ("Non-consumable, one-time purchase. Unlocks every tournament after the free ones "
               "(1930, 1934, 1938, 1994) in 'Relive a World Cup' and every quiz mode. "
               "Restore Purchases is in 'About & settings'.")
API = "https://api.appstoreconnect.apple.com"


def token():
    key = os.environ["ASC_KEY_P8"]
    if "BEGIN PRIVATE KEY" not in key:
        key = base64.b64decode(key).decode()
    now = int(time.time())
    return jwt.encode({"iss": os.environ["ASC_ISSUER_ID"], "iat": now, "exp": now + 1100, "aud": "appstoreconnect-v1"},
                      key, algorithm="ES256", headers={"kid": os.environ["ASC_KEY_ID"], "typ": "JWT"})


S = requests.Session()


def call(method, path, body=None, ok=(200, 201, 204)):
    S.headers["Authorization"] = f"Bearer {token()}"
    r = S.request(method, path if path.startswith("http") else API + path, json=body, timeout=60)
    if r.status_code not in ok:
        print(f"::error::{method} {path} → {r.status_code}\n{r.text[:3000]}")
        sys.exit(1)
    return r.json() if r.content else {}


def get_all(path):
    out, url = [], path
    while url:
        j = call("GET", url)
        out += j.get("data", [])
        url = j.get("links", {}).get("next")
    return out


def step(msg):
    print(f"\n== {msg}", flush=True)


def main():
    step("Aplicația")
    app = call("GET", f"/v1/apps/{APP_ID}")["data"]
    print(app["attributes"]["name"], app["attributes"]["bundleId"])

    step("Produsul")
    existing = [p for p in get_all(f"/v1/apps/{APP_ID}/inAppPurchasesV2?limit=200")
                if p["attributes"].get("productId") == PRODUCT_ID]
    if existing:
        iap = existing[0]
        print("există deja:", iap["id"], iap["attributes"].get("state"))
    else:
        iap = call("POST", "/v2/inAppPurchases", {"data": {
            "type": "inAppPurchases",
            "attributes": {"name": "Full History", "productId": PRODUCT_ID, "inAppPurchaseType": "NON_CONSUMABLE",
                           "familySharable": True, "reviewNote": REVIEW_NOTE},
            "relationships": {"app": {"data": {"type": "apps", "id": APP_ID}}}}})["data"]
        print("creat:", iap["id"])
    iap_id = iap["id"]
    if not iap["attributes"].get("familySharable"):
        call("PATCH", f"/v2/inAppPurchases/{iap_id}", {"data": {"type": "inAppPurchases", "id": iap_id,
                                                                "attributes": {"familySharable": True, "reviewNote": REVIEW_NOTE}}})
        print("Family Sharing pornit")

    step("Nume și descriere")
    have = {l["attributes"]["locale"]: l for l in get_all(f"/v2/inAppPurchases/{iap_id}/inAppPurchaseLocalizations")}
    for loc, (name, desc) in LOCALIZATIONS.items():
        assert len(name) <= 30 and len(desc) <= 55, (loc, len(name), len(desc))
        if loc in have:
            call("PATCH", f"/v1/inAppPurchaseLocalizations/{have[loc]['id']}", {"data": {
                "type": "inAppPurchaseLocalizations", "id": have[loc]["id"], "attributes": {"name": name, "description": desc}}})
            print(loc, "actualizat")
        else:
            call("POST", "/v1/inAppPurchaseLocalizations", {"data": {
                "type": "inAppPurchaseLocalizations", "attributes": {"locale": loc, "name": name, "description": desc},
                "relationships": {"inAppPurchaseV2": {"data": {"type": "inAppPurchases", "id": iap_id}}}}})
            print(loc, "creat")

    step("Preț")
    points = get_all(f"/v2/inAppPurchases/{iap_id}/pricePoints?filter[territory]=USA&limit=200")
    pp = next((p for p in points if p["attributes"]["customerPrice"] == PRICE_USD), None)
    if not pp:
        print("::error::nu găsesc prețul", PRICE_USD, [p["attributes"]["customerPrice"] for p in points[:40]])
        sys.exit(1)
    call("POST", "/v1/inAppPurchasePriceSchedules", {
        "data": {"type": "inAppPurchasePriceSchedules", "relationships": {
            "inAppPurchase": {"data": {"type": "inAppPurchases", "id": iap_id}},
            "baseTerritory": {"data": {"type": "territories", "id": "USA"}},
            "manualPrices": {"data": [{"type": "inAppPurchasePrices", "id": "${price0}"}]}}},
        "included": [{"type": "inAppPurchasePrices", "id": "${price0}", "attributes": {"startDate": None},
                      "relationships": {"inAppPurchaseV2": {"data": {"type": "inAppPurchases", "id": iap_id}},
                                        "inAppPurchasePricePoint": {"data": {"type": "inAppPurchasePricePoints", "id": pp["id"]}}}}]},
         ok=(200, 201, 409))
    print("preț de bază:", PRICE_USD, "USD (celelalte țări: echivalent automat)")

    step("Disponibilitate")
    territories = [{"type": "territories", "id": t["id"]} for t in get_all("/v1/territories?limit=200")]
    call("POST", "/v1/inAppPurchaseAvailabilities", {"data": {
        "type": "inAppPurchaseAvailabilities", "attributes": {"availableInNewTerritories": True},
        "relationships": {"inAppPurchase": {"data": {"type": "inAppPurchases", "id": iap_id}},
                          "availableTerritories": {"data": territories}}}}, ok=(200, 201, 409))
    print("disponibil în", len(territories), "țări")

    step("Captura pentru App Review")
    shot = sys.argv[1] if len(sys.argv) > 1 else None
    current = call("GET", f"/v2/inAppPurchases/{iap_id}/appStoreReviewScreenshot", ok=(200, 404)).get("data")
    if current:
        print("există deja")
    elif shot and os.path.exists(shot):
        data = open(shot, "rb").read()
        res = call("POST", "/v1/inAppPurchaseAppStoreReviewScreenshots", {"data": {
            "type": "inAppPurchaseAppStoreReviewScreenshots",
            "attributes": {"fileName": os.path.basename(shot), "fileSize": len(data)},
            "relationships": {"inAppPurchaseV2": {"data": {"type": "inAppPurchases", "id": iap_id}}}}})["data"]
        for op in res["attributes"]["uploadOperations"]:
            chunk = data[op["offset"]:op["offset"] + op["length"]]
            r = requests.request(op["method"], op["url"], data=chunk,
                                 headers={h["name"]: h["value"] for h in op.get("requestHeaders", [])}, timeout=120)
            r.raise_for_status()
        call("PATCH", f"/v1/inAppPurchaseAppStoreReviewScreenshots/{res['id']}", {"data": {
            "type": "inAppPurchaseAppStoreReviewScreenshots", "id": res["id"],
            "attributes": {"uploaded": True, "sourceFileChecksum": hashlib.md5(data).hexdigest()}}})
        print("încărcată:", os.path.basename(shot), len(data), "bytes")
    else:
        print("::warning::fără captură (lipsește fișierul)")

    step("Stare")
    iap = call("GET", f"/v2/inAppPurchases/{iap_id}")["data"]
    print(json.dumps(iap["attributes"], ensure_ascii=False, indent=1))
    with open(os.environ.get("GITHUB_STEP_SUMMARY", os.devnull), "a") as f:
        f.write(f"### ✅ „Full History” ({PRODUCT_ID}) — stare: {iap['attributes'].get('state')}\n")


if __name__ == "__main__":
    main()
