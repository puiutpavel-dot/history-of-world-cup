# Arhiva Mondialelor · Football Finals Archive 🏆

*(repo: history-of-world-cup)*

Prototip web jucabil pentru o aplicație iOS nativă despre istoria Campionatului Mondial de Fotbal (1930-2026) — trivia, management de echipă și simulare de meciuri, cu mecanica "confirmă sau rescrie istoria".

**[▶️ Joacă prototipul](https://puiutpavel-dot.github.io/history-of-world-cup/)** (GitHub Pages)

## Conceptul jocului

Jucătorul alege o ediție a Cupei Mondiale (1930-2026) și o națională disponibilă în acea eră. Pentru **orice combinație echipă+an care a avut loc cu adevărat istoric** (peste 300 de loturi, acoperind toate cele 23 de națiuni curate la fiecare ediție la care au participat real, plus ~24 de loturi pentru echipe "shadow" adversare în campaniile curate), lotul e **real, cu jucători istorici reali** (18-26 fotbaliști per lot, nume + poziție reale, verificate încrucișat pe surse). Doar combinațiile echipă+an care sunt teoretic selectabile în joc dar care **nu au avut loc real** (echipa nu s-a calificat sau nu a existat încă la acea ediție) primesc un lot generat, cu rating calculat dintr-o curbă istorică de putere per echipă/an — iar fotbaliștii **legendari reali** (Pelé, Maradona, Beckenbauer, Cruyff, Zidane, Messi ș.a.) apar automat în lotul echipei lor, la anul corect, indiferent de tipul de lot.

Bucla de joc: alege mentalitate + formație înaintea fiecărui meci și parcurge turneul **în formatul real al ediției alese** (`FORMATS` în `data.js`, motorul în `career.js`):

- **1930**: grupe de 3-4, doar câștigătoarea trece → semifinale → finală (fără loc 3);
- **1934 / 1938**: fără grupe — optimi, sferturi, semifinale, locul 3, finală; la egalitate prelungiri, apoi meci rejucat (1938: Suedia are bye în optimi);
- **1950**: grupe inegale → grupa finală de 4, toți contra toți (fără finală separată);
- **1954**: grupe de 4 în care capii de serie joacă doar cu necapii (2 meciuri), baraj la egalitate de puncte → sferturi → semifinale → locul 3 → finală;
- **1958 – 1970**: grupe de 4 (1958 cu baraj, 1962/1966 cu media golurilor, din 1970 golaveraj) → sferturi → semifinale → locul 3 → finală;
- **1974 / 1978**: grupe → a doua fază a grupelor (câștigătoarea joacă finala, locul 2 finala mică); **1982**: 24 de echipe, a doua fază cu grupe de 3 → semifinale;
- **1986 – 1994**: 24 de echipe, trec primele 2 + cele mai bune 4 locuri 3 → optimi …; **1998 – 2022**: 32 de echipe, 8 grupe → optimi …; **2026**: 48 de echipe, 12 grupe, + cele mai bune 8 locuri 3 → șaisprezecimi → optimi → sferturi → semifinale → locul 3 → finală.

Punctaj 2/1/0 până în 1990, 3/1/0 din 1994. Cartonașe din 1970: două galbene = suspendare la meciul următor (până în 1990 cumulate pe tot turneul, din 1994 șterse după grupe), roșu = suspendare. Egalitățile din eliminatorii: prelungiri, apoi meci rejucat (1930-1938), tragere la sorți (1954-1970) sau penalty-uri (din 1974). **Regulile de pe teren urmează epoca**: fără schimbări până în 1966 (un accidentat lasă echipa în 10), 2 schimbări 1970-1994 (+1 pentru portar în 1994), 3 schimbări 1998-2018 (+1 în prelungiri din 2018), 5 schimbări + 1 în prelungiri din 2022; gol de aur în 1998 și 2002; prelungiri și în grupă în 1954; departajare prin fair-play din 2018; loturi de 22 (până în 1998), 23 (2002-2018) și 26 (din 2022). Cariera se încheie cu locul real ocupat (campioană, vicecampioană, locul 3/4 sau faza în care a fost eliminată) și intră în Sala Trofeelor.

### "Confirmă sau rescrie istoria"

Ori de câte ori e posibil, adversarii din traseul jucătorului sunt **exact adversarii reali** pe care echipa aleasă i-a întâlnit în ediția respectivă (ordine reală, opoziție reală) — dar scorul rămâne **simulat**, în funcție de tactica aleasă. Fiecare meci arată un badge 📜 *adversar real* sau 🎲 *adversar simulat*, iar rezultatul e comparat cu scorul istoric real.

**Quiz** (`quiz.js`): quiz pe ediție (gazdă, scorul finalei, format, golgheter, o surpriză), **Maraton 1930 → 2026** (câte o întrebare pe ediție), **Duoul greșit** (3 afirmații, una falsă) și **Alege faza**; recordurile se păstrează local. Banca de întrebări e generată determinist din datele jocului și exportată identic pentru iOS.

**Traseul țării tale**: țara se stabilește automat din regiunea dispozitivului (web: limba browserului) și se poate schimba manual; ecranul arată toate participările reale ale țării (meci cu meci, 1930-2022, pentru toate cele 84 de naționale — `country_tracks.js`, generat cu `tools/build_country_tracks.py`), cel mai bun rezultat, absențele și, unde se poate, „Joacă această campanie”.

Ecrane suplimentare: **Muzeul Edițiilor** (toate cele 23 de ediții, 1930-2026, cu gazdă/golgheter/minge oficială, formatul turneului și povestea ediției — `history.js`), **Evoluția regulilor** (cronologia 1930-2026, loturi, cele 7 familii de format) și **Galeria Legendelor** (18 fotbaliști istorici cu bio scurt).

## Scope v1 — notă importantă

Acest prototip a fost **reconstruit de la zero** pornind de la conceptul și planul de arhitectură din documentul de proiect (o versiune anterioară, mai completă, a fost construită într-o sesiune Claude separată care nu mai există). Pentru a rămâne un v1 solid și verificabil:

- **Trasee reale complete**: fiecare dintre cele 23 de națiuni curate are adversarii reali la **fiecare ediție la care a participat** (278 de campanii, 1.209 meciuri reale, 1930-2022), generate din Fjelstul World Cup Database cu `tools/build_real_fixtures.py` (vezi „Surse și licențe”).
- **Loturi reale extinse la scară completă** (`real_rosters.js`, peste 300 de chei `ECHIPA_AN`, sursă: paginile Wikipedia "[an] FIFA World Cup squads", verificate jucător cu jucător): fiecare din cele 23 de națiuni curate primește lot real pentru *fiecare* ediție la care a participat cu adevărat istoric (1930-2022), plus loturi reale pentru ~24 de echipe "shadow" (adversarii din cele 12 campanii curate inițiale). Restul combinațiilor echipă+an (selectabile teoretic în joc, dar care nu au avut loc real) folosesc lot generat aleator.
- **23 de națiuni curate** cu curbă de putere pe eră + ~19 echipe "shadow" (rating dedus automat din diferența de gol reală, fără curbă proprie).
- Structura de date (`REAL_FIXTURES`, `TEAMS.curve`, `REAL_ROSTERS`) e identică cu planul original, deci **oricine poate extinde** subsetul de meciuri/loturi reale fără nicio schimbare de motor.

## Structură fișiere → plan portare iOS

Structura oglindește direct arhitectura SwiftUI propusă (vezi documentul de proiect `concept-joc-si-plan-ios.md`):

| Fișier web | Echivalent nativ iOS |
|---|---|
| `data.js` | `Data.json` (ediții, echipe, legende) |
| `real_fixtures.js` | `RealFixtures.json` |
| `real_rosters.js` | `RealRosters.json` (loturi reale pentru toate combinațiile echipă+an istorice reale) |
| `engine.js` | Motor Swift — funcții pure testabile cu XCTest (`simulateMatch`, `generateSquad`, `getTeamRating`, `getShadowRating`...) |
| `app.js` | `ObservableObject GameState` + ecrane SwiftUI |
| `style.css` | Paletă „stadion nocturn" → `Font.custom` / `Color` assets |

PRNG determinist (`mulberry32`) = echivalentul unui generator cu sămânță pentru teste unitare reproductibile.

## Aplicația iOS nativă (SwiftUI) — `ios/`

Portul nativ e în lucru în folderul [`ios/`](ios/):

| Parte | Unde | Ce face |
|---|---|---|
| **Motor** | `ios/WorldCupCore/` (Swift Package) | Port 1:1 al `engine.js` + logica de carieră din `app.js` (`Career`), fără UI. Același PRNG `mulberry32` ⇒ aceleași rezultate ca prototipul web pentru aceeași sămânță. |
| **Date** | `ios/WorldCupCore/Sources/WorldCupCore/Resources/*.json` | `Data.json`, `RealFixtures.json`, `RealRosters.json` — **generate** (nu sunt versionate) din `data.js` / `real_fixtures.js` / `real_rosters.js` cu `node tools/export_ios_data.js`; sursa unică de adevăr rămân fișierele JS. |
| **Teste** | `ios/WorldCupCore/Tests/` | Teste XCTest de **paritate cu JS**: PRNG, rating-uri, loturi, meciuri, penalty-uri și 60 de cariere complete, comparate cu vectorii din `Golden.json` (`node tools/make_golden.js`). |
| **Aplicația** | `ios/App/Sources/` + `ios/project.yml` | Toate ecranele prototipului în SwiftUI (Meniu, Ediții, Echipe, Hub, Preview, Meci live, Clasament, Sumar, Muzeu, Legende, Sala Trofeelor), paleta „stadion nocturn”, temă dark/light, carieră salvată automat. |

**Fără Mac:** workflow-ul [`.github/workflows/ios.yml`](.github/workflows/ios.yml) rulează pe un Mac din cloud (GitHub Actions, gratuit pentru repo-uri publice): testele motorului, build-ul aplicației pentru Simulator și capturi de ecran ale fiecărui ecran (tab-ul **Actions** → ultima rulare → **Artifacts**). Capturile se publică automat și pe branch-ul [`screenshots`](../../tree/screenshots), unde se văd direct în browser.

**Cu Mac:** `node tools/export_ios_data.js && node tools/make_golden.js && python3 tools/make_icon.py && brew install xcodegen && cd ios && xcodegen && open HistoryOfWorldCup.xcodeproj`.

## Monetizare iOS — o singură achiziție

Decizia: **descărcare gratuită + un singur IAP „Full History” la 4,99 $** (non-consumable). Fără reclame, fără abonament, fără alte pachete.

- **Gratuit:** Mondialele 1930, 1934, 1938 și 1994 (turneul real + quiz pe ediție), Muzeul, Evoluția regulilor, Galeria Legendelor, traseul țării (de citit).
- **Full History:** toate turneele din 1950 în modul principal, toate quizurile pe ediție + Maraton, Duoul greșit, Alege faza, „Joacă această campanie” la orice ediție, actualizările viitoare.
- Cod: `ios/App/Sources/Store.swift` (StoreKit 2: `Product.products`, `purchase()`, `Transaction.currentEntitlements`, `Transaction.updates`, `AppStore.sync()` pentru **Restaurează achizițiile** — vizibil în meniu și pe ecranul de deblocare). Rambursările / revocările re-blochează conținutul. Ultima stare se păstrează local pentru pornire offline.
- Test local fără cont Apple: `ios/App/StoreKit/FullHistory.storekit` (legat de schema Xcode prin `project.yml`).
- Prototipul web rămâne demo gratuit complet.

Pași în App Store Connect (când există contul Apple Developer):
1. Semnează *Paid Applications Agreement* și completează datele fiscale și bancare.
2. Înscrie-te în **App Store Small Business Program** (comision 15% sub 1 mil. $ / an).
3. *In-App Purchases* → **Non-Consumable**, Product ID `com.puiutpavel.historyofworldcup.fullhistory`, nume „Full History”, preț **4,99 $** cu SUA ca țară de bază (Apple calculează automat prețul în celelalte țări), **Family Sharing activat**, localizări ro + en, captură a ecranului de deblocare pentru review.
4. Aplicația: preț **Gratuit**. Subtitlu: „Retrăiește Mondialele 1930–2026” (fără preț în subtitlu — ghidul 2.3.7). În descriere: „Fără reclame, fără abonament, fără pachete.”
5. Testare: TestFlight cu un cont *Sandbox Tester*.

Pregătirea pentru App Review: `docs/app-store/` — `CHECKLIST.md` (ghidurile 2.1, 2.3, 3.1.1, 4.2, 5.1, 5.2), `METADATA.md` (nume, subtitlu, cuvinte-cheie, descrieri ro/en, vârstă, capturi) și `REVIEW_NOTES.md` (textul pentru reviewer). Politica de confidențialitate și pagina de suport: `privacy.html`, `support.html` (publicate prin GitHub Pages). Aplicația e un joc **neoficial**, fără legătură cu FIFA — fără logouri, embleme, trofee oficiale sau fotografii.

## Surse și licențe

- **Rezultatele meciurilor reale** (`real_fixtures.js`): [Fjelstul World Cup Database](https://www.github.com/jfjelstul/worldcup), © 2023 Joshua C. Fjelstul, Ph.D., licență [CC-BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/legalcode). Modificări: selecție pe echipele jocului, coduri FIFA, maparea formatelor istorice pe bracketul jocului, note în română. Fișierul de date derivat este distribuit tot sub CC-BY-SA 4.0. Regenerare: `git clone --depth 1 https://github.com/jfjelstul/worldcup /tmp/worldcup && python3 tools/build_real_fixtures.py /tmp/worldcup/data-csv/team_appearances.csv`.
- **Loturile** (`real_rosters.js`): paginile Wikipedia „[an] FIFA World Cup squads”.

## Rulare locală

Fără build, fără dependențe. Orice server static funcționează:

```bash
python3 -m http.server 8080
# apoi deschide http://localhost:8080
```

## Următorii pași

1. ~~Extinde `real_fixtures.js` la toate campaniile reale~~ — făcut (278 de campanii). Următorul pas posibil: loturi reale și pentru adversarii „shadow” noi.
2. ~~Formatul real al fiecărei ediții (inclusiv 2026)~~ — făcut: `FORMATS` în `data.js` + `career.js`.
3. ~~Port Swift al motorului de simulare + teste unitare XCTest~~ — în `ios/WorldCupCore/`, verificat automat în CI.
4. ~~Construire UI SwiftUI ecran cu ecran~~ — prima versiune în `ios/App/`; urmează rafinarea pe baza capturilor din CI / TestFlight.
5. Cont Apple Developer + semnare + TestFlight (se poate face tot din GitHub Actions, fără Mac).

---

Parte din proiectul **HISTORY OF WORLD CUP** (aplicație iOS nativă).

## Limbi (iOS)
Aplicația iOS e în **engleză** (implicit) și **română** (pe telefoanele setate în română; se poate schimba și din Setări → aplicația → Limbă). Textele de interfață sunt în cod, prin `tr("ro", "en")` (`WorldCupCore/Localization.swift`); conținutul (ediții, echipe, povești, reguli, legende, quiz, traseul țării) vine din `Data.json` (ro) sau `Data_en.json` (en), generate de `tools/export_ios_data.js` din prototip + `i18n_en.js`. Motorul nu citește textele, deci simularea e identică în ambele limbi. Prototipul web rămâne în română.

## Modul principal pe iOS: „Retrăiește un Mondial”
Pe iOS, jocul principal nu mai e cariera simulată: alegi o ediție (1930–2026) și una dintre echipele care au jucat-o (89 de naționale, din traseele reale — Fjelstul pentru 1930–2022, openfootball pentru 2026) și îi parcurgi meciurile reale, cu scorul real: fiecare meci se derulează în 19 secunde, cu marcatorii la minutul lor, fără întrebări între meciuri (quizul rămâne mod separat). După fiecare meci apare „Știai că?” (`MatchFacts.swift`): o poveste scrisă de mână pentru ~50 de meciuri celebre, apoi fapte calculate din date — record all-time de goluri, hat-trick, întoarcere de scor, gol decisiv târziu, premiere ale echipei, istoria întâlnirilor. Rezultatul intră în Sala Trofeelor. Cod: `ios/App/Sources/RealRunViews.swift`. Motorul de carieră rămâne în `WorldCupCore` (testele de paritate) și în prototipul web.

## Mondialul 2026 meci cu meci
`tracks_2026.js` (generat de `tools/build_tracks_2026.py`) conține toate cele 104 meciuri din 2026 pentru cele 48 de echipe, în formatul din `country_tracks.js`. Sursa: [openfootball/worldcup.json](https://github.com/openfootball/worldcup.json) (domeniu public), copie în `tools/data/openfootball_wc2026.json`. Scriptul verifică podiumul (Spania, Argentina, Anglia, Franța). Noi în date: RD Congo (`COD`), Capul Verde (`CPV`), Curaçao (`CUW`), Iordania (`JOR`), Uzbekistan (`UZB`); faza nouă `R32` (șaisprezecimi).

## Meciurile în 19 secunde, cu marcatorii
În „Retrăiește un Mondial”, fiecare meci se derulează în 19 secunde: cronometrul merge până la 90' (sau 120' dacă s-au jucat prelungiri), iar golurile apar la minutul lor, cu marcatorul (pen. / autogol). „Sări la final” oprește derularea. Golurile vin din `goals.csv` (Fjelstul, 1930–2022) și din `goals1`/`goals2` (openfootball, 2026), atașate fiecărui meci din `country_tracks.js` / `tracks_2026.js` ca `goals: [{m, t, n, k}]`; generatoarele verifică faptul că numărul de goluri se potrivește cu scorul fiecărui meci.
