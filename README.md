# History of World Cup 🏆

Prototip web jucabil pentru o aplicație iOS nativă despre istoria Campionatului Mondial de Fotbal (1930-2022) — trivia, management de echipă și simulare de meciuri, cu mecanica "confirmă sau rescrie istoria".

**[▶️ Joacă prototipul](https://puiutpavel-dot.github.io/history-of-world-cup/)** (GitHub Pages)

## Conceptul jocului

Jucătorul alege o ediție a Cupei Mondiale (1930-2022) și o națională disponibilă în acea eră. Pentru **orice combinație echipă+an care a avut loc cu adevărat istoric** (peste 300 de loturi, acoperind toate cele 23 de națiuni curate la fiecare ediție la care au participat real, plus ~24 de loturi pentru echipe "shadow" adversare în campaniile curate), lotul e **real, cu jucători istorici reali** (18-26 fotbaliști per lot, nume + poziție reale, verificate încrucișat pe surse). Doar combinațiile echipă+an care sunt teoretic selectabile în joc dar care **nu au avut loc real** (echipa nu s-a calificat sau nu a existat încă la acea ediție) primesc un lot generat, cu rating calculat dintr-o curbă istorică de putere per echipă/an — iar fotbaliștii **legendari reali** (Pelé, Maradona, Beckenbauer, Cruyff, Zidane, Messi ș.a.) apar automat în lotul echipei lor, la anul corect, indiferent de tipul de lot.

Bucla de joc: alege mentalitate + formație → joacă 3 meciuri în grupă (celelalte se simulează automat pentru clasament) → sferturi → semifinală → finală (penalty-uri la egalitate) → cariera intră în Sala Trofeelor.

### "Confirmă sau rescrie istoria"

Ori de câte ori e posibil, adversarii din traseul jucătorului sunt **exact adversarii reali** pe care echipa aleasă i-a întâlnit în ediția respectivă (ordine reală, opoziție reală) — dar scorul rămâne **simulat**, în funcție de tactica aleasă. Fiecare meci arată un badge 📜 *adversar real* sau 🎲 *adversar simulat*, iar rezultatul e comparat cu scorul istoric real.

Ecrane suplimentare: **Muzeul Edițiilor** (toate cele 22 de ediții, cu gazdă/scor din finală/golgheter/minge oficială/rezumat istoric) și **Galeria Legendelor** (18 fotbaliști istorici cu bio scurt).

## Scope v1 — notă importantă

Acest prototip a fost **reconstruit de la zero** pornind de la conceptul și planul de arhitectură din documentul de proiect (o versiune anterioară, mai completă, a fost construită într-o sesiune Claude separată care nu mai există). Pentru a rămâne un v1 solid și verificabil:

- **Trasee reale complete**: fiecare dintre cele 23 de națiuni curate are adversarii reali la **fiecare ediție la care a participat** (278 de campanii, 1.173 de meciuri reale, 1930-2022), generate din Fjelstul World Cup Database cu `tools/build_real_fixtures.py` (vezi „Surse și licențe”).
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
2. Stabilește scope-ul exact pentru v1 iOS (câte ediții/echipe la lansare, dacă păstrăm turneul simplificat grupă→sferturi→semifinală→finală sau extindem la 32 de echipe/optimi).
3. ~~Port Swift al motorului de simulare + teste unitare XCTest~~ — în `ios/WorldCupCore/`, verificat automat în CI.
4. ~~Construire UI SwiftUI ecran cu ecran~~ — prima versiune în `ios/App/`; urmează rafinarea pe baza capturilor din CI / TestFlight.
5. Cont Apple Developer + semnare + TestFlight (se poate face tot din GitHub Actions, fără Mac).

---

Parte din proiectul **HISTORY OF WORLD CUP** (aplicație iOS nativă).
