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

- **12 campanii istorice curate** cu adversari reali, meci cu meci (Uruguay 1930, Brazilia 1950/1970/2002, Germania 1954/1990/2014, Anglia 1966, Argentina 1986/2022, Franța 1998, Japonia 2002) — nu baza de date completă de 1316 meciuri din prototipul original.
- **Loturi reale extinse la scară completă** (`real_rosters.js`, peste 300 de chei `ECHIPA_AN`, sursă: paginile Wikipedia "[an] FIFA World Cup squads", verificate jucător cu jucător): fiecare din cele 23 de națiuni curate primește lot real pentru *fiecare* ediție la care a participat cu adevărat istoric (1930-2022), nu doar cele 12 campanii curate — plus loturi reale pentru ~24 de echipe "shadow" adversare relevante în acele 12 campanii. Restul combinațiilor echipă+an (selectabile teoretic în joc, dar care nu au avut loc real) folosesc lot generat aleator.
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

## Rulare locală

Fără build, fără dependențe. Orice server static funcționează:

```bash
python3 -m http.server 8080
# apoi deschide http://localhost:8080
```

## Următorii pași

1. Extinde `real_fixtures.js` / `real_rosters.js` cu mai multe campanii/ediții și loturi reale (structura suportă orice număr de chei `ECHIPA_AN`).
2. Stabilește scope-ul exact pentru v1 iOS (câte ediții/echipe la lansare, dacă păstrăm turneul simplificat grupă→sferturi→semifinală→finală sau extindem la 32 de echipe/optimi).
3. Port Swift al motorului de simulare + teste unitare XCTest.
4. Construire UI SwiftUI ecran cu ecran, folosind acest prototip ca referință vizuală și de interacțiune.

---

Parte din proiectul **HISTORY OF WORLD CUP** (aplicație iOS nativă).
