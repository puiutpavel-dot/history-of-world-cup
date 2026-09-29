# TestFlight fără Mac — pașii tăi (o singură dată)

Build-ul, semnarea și încărcarea le face GitHub Actions (workflow-ul `TestFlight`, pe un Mac din cloud). Tu ai de făcut doar pașii care cer contul tău Apple — nimeni altcineva nu îi poate face în locul tău (parole, plăți, chei).

## 1. Cont Apple Developer (99 $/an)
- https://developer.apple.com/programs/enroll → **Individual** (pe numele tău; numele apare în App Store ca dezvoltator).
- Apple ID cu autentificare în doi pași. Aprobarea durează de obicei 24–48 de ore.

## 2. Acorduri
App Store Connect → **Business** (Agreements, Tax, and Banking): semnează **Paid Applications Agreement** și completează datele fiscale și bancare. Fără el, achiziția „Full History” nu se încarcă nici măcar în testele TestFlight.

## 3. Team ID
developer.apple.com → **Account → Membership details → Team ID** (10 caractere, ex. `AB12CD34EF`).

## 4. Identificatorul aplicației
developer.apple.com → **Certificates, Identifiers & Profiles → Identifiers → +** → *App IDs* → *App* →
- Description: `Football Finals Archive`
- Bundle ID: **Explicit** `com.puiutpavel.historyofworldcup`
- Capabilities: lasă **In-App Purchase** bifat (e implicit).

## 5. Aplicația în App Store Connect
https://appstoreconnect.apple.com → **Apps → + → New App**:
- Platform: iOS · Name: **Football Finals Archive** · Primary language: **English (U.S.)** (româna se adaugă apoi ca localizare, cu numele „Arhiva Mondialelor”)
- Bundle ID: `com.puiutpavel.historyofworldcup` · SKU: `HWC001` · User Access: Full Access

## 6. Cheia App Store Connect API (pentru GitHub)
App Store Connect → **Users and Access → Integrations → App Store Connect API → Team Keys → Generate API Key**:
- Name: `GitHub CI` · Access: **Admin** (necesar ca semnarea să se facă automat, în cloud)
- Descarcă fișierul `AuthKey_XXXXXXXXXX.p8` — **se poate descărca o singură dată**, păstrează-l.
- Notează **Key ID** (10 caractere) și **Issuer ID** (UUID, sus pe pagină).

## 7. Secretele în GitHub
github.com/puiutpavel-dot/history-of-world-cup → **Settings → Secrets and variables → Actions → New repository secret**, de 4 ori:

| Nume | Valoare |
|---|---|
| `ASC_KEY_ID` | Key ID de la pasul 6 |
| `ASC_ISSUER_ID` | Issuer ID de la pasul 6 |
| `ASC_KEY_P8` | tot conținutul fișierului `.p8` (deschide-l în Notepad / TextEdit și copiază tot, inclusiv liniile `-----BEGIN PRIVATE KEY-----` și `-----END PRIVATE KEY-----`) |
| `APPLE_TEAM_ID` | Team ID de la pasul 3 |

Secretele sunt criptate: nu apar în loguri și nu le vede nimeni care se uită la repo.

## 8. Build-ul
GitHub → **Actions → TestFlight → Run workflow**. Durează ~10 minute. La final, build-ul apare în App Store Connect → aplicația → **TestFlight** după procesare (5–30 de minute). Fiecare rulare primește un număr de build nou (numărul rulării).

## 9. Pe iPhone
- App Store Connect → TestFlight → **Internal Testing → +** grup „Eu” → adaugă-te pe tine (contul tău e deja utilizator).
- Instalează aplicația **TestFlight** din App Store pe iPhone → acceptă invitația → **Install**.
- Testarea internă (până la 100 de persoane din echipa ta) nu trece prin review. Pentru prieteni din afara echipei: *External Testing* (prima versiune trece printr-un review scurt „Beta App Review”).

## 10. Achiziția „Full History” în TestFlight
App Store Connect → aplicația → **Monetization → In-App Purchases → +** → *Non-Consumable*:
- Reference Name `Full History` · Product ID **`com.puiutpavel.historyofworldcup.fullhistory`** (exact acesta)
- Price 4,99 $ · Family Sharing: **On** · localizare ro (nume + descriere) · captură a ecranului de deblocare (din branch-ul `screenshots`: `paywall.png`)
În TestFlight cumpărarea e **gratuită** (sandbox) — poți testa cumpărarea, „Restaurează achizițiile”, reinstalarea și închiderea/redeschiderea aplicației.

## Ce verifici pe telefon înainte de review
- [ ] Carieră 1930 până la final; quiz 1934; Traseul țării.
- [ ] Ediție 1950 → ecranul Full History → cumpără (sandbox) → edițiile se deblochează.
- [ ] Șterge aplicația, reinstalează din TestFlight → „Despre și setări → Restaurează achizițiile”.
- [ ] Închide aplicația din multitasking în mijlocul unei cariere → redeschide → cariera continuă.
