/* ============================================================
   HISTORY OF WORLD CUP — data.js
   Date istorice statice: cele 22 de ediții, curbe de putere pe
   echipă/an și legendele. Sursă directă pentru portarea în
   Data.json / RealFixtures.json la versiunea nativă iOS.
   ============================================================ */

/* ---------- EDITIONS: cele 22 de Campionate Mondiale ---------- */
const EDITIONS = [
  { year: 1930, host: "Uruguay",        champion: "URU", runnerUp: "ARG", third: "USA", topScorer: "Guillermo Stábile (ARG) — 8", ball: "Tiento / T-Model", note: "Prima ediție. Format special: 4 grupe, fără sferturi propriu-zise." },
  { year: 1934, host: "Italia",         champion: "ITA", runnerUp: "TCH", third: "GER", topScorer: "Oldřich Nejedlý (TCH) — 5", ball: "Federale 102", note: "Prima ediție eliminatorie pură (fără grupe)." },
  { year: 1938, host: "Franța",         champion: "ITA", runnerUp: "HUN", third: "BRA", topScorer: "Leônidas (BRA) — 7", ball: "Allen", note: "Italia devine prima campioană care își apără titlul." },
  { year: 1950, host: "Brazilia",       champion: "URU", runnerUp: "BRA", third: "SWE", topScorer: "Ademir (BRA) — 8", ball: "Duplo T", note: "\"Maracanazo\": Uruguay învinge Brazilia 2-1 în fața a ~200.000 de spectatori." },
  { year: 1954, host: "Elveția",        champion: "GER", runnerUp: "HUN", third: "AUT", topScorer: "Sándor Kocsis (HUN) — 11", ball: "Swiss World Champion", note: "\"Miracolul de la Berna\": Germania Federală o învinge pe marea Ungarie a lui Puskás." },
  { year: 1958, host: "Suedia",         champion: "BRA", runnerUp: "SWE", third: "FRA", topScorer: "Just Fontaine (FRA) — 13", ball: "Top Star", note: "Debutul lui Pelé, 17 ani — primul titlu al Braziliei." },
  { year: 1962, host: "Chile",          champion: "BRA", runnerUp: "TCH", third: "CHI", topScorer: "6 jucători — 4 goluri", ball: "Crack", note: "Brazilia își apără titlul, cu Garrincha în prim-plan." },
  { year: 1966, host: "Anglia",         champion: "ENG", runnerUp: "GER", third: "POR", topScorer: "Eusébio (POR) — 9", ball: "Challenge 4-Star", note: "Anglia câștigă pe teren propriu; trofeul Jules Rimet furat și regăsit de câinele Pickles." },
  { year: 1970, host: "Mexic",          champion: "BRA", runnerUp: "ITA", third: "GER", topScorer: "Gerd Müller (GER) — 10", ball: "Telstar", note: "Considerată cea mai bună echipă din istorie — al treilea titlu, trofeul Jules Rimet rămâne definitiv Braziliei." },
  { year: 1974, host: "Germania de Vest", champion: "GER", runnerUp: "NED", third: "POL", topScorer: "Grzegorz Lato (POL) — 7", ball: "Telstar Durlast", note: "Germania învinge \"Fotbalul Total\" al Olandei lui Cruyff." },
  { year: 1978, host: "Argentina",      champion: "ARG", runnerUp: "NED", third: "BRA", topScorer: "Mario Kempes (ARG) — 6", ball: "Tango", note: "Argentina câștigă primul titlu, pe teren propriu." },
  { year: 1982, host: "Spania",         champion: "ITA", runnerUp: "GER", third: "POL", topScorer: "Paolo Rossi (ITA) — 6", ball: "Tango España", note: "Al treilea titlu al Italiei, cu un Paolo Rossi resuscitat." },
  { year: 1986, host: "Mexic",          champion: "ARG", runnerUp: "GER", third: "FRA", topScorer: "Gary Lineker (ENG) — 6", ball: "Azteca", note: "\"Mâna lui Dumnezeu\" și golul secolului — Maradona în plină glorie." },
  { year: 1990, host: "Italia",         champion: "GER", runnerUp: "ARG", third: "ITA", topScorer: "Salvatore Schillaci (ITA) — 6", ball: "Etrusco Unico", note: "Germania de Vest își ia revanșa din finala precedentă." },
  { year: 1994, host: "SUA",            champion: "BRA", runnerUp: "ITA", third: "SWE", topScorer: "Hristo Stoichkov / Oleg Salenko — 6", ball: "Questra", note: "Brazilia câștigă la penalty-uri, prima finală decisă astfel." },
  { year: 1998, host: "Franța",         champion: "FRA", runnerUp: "BRA", third: "CRO", topScorer: "Davor Šuker (CRO) — 6", ball: "Tricolore", note: "Franța lui Zidane câștigă primul titlu, pe teren propriu." },
  { year: 2002, host: "Coreea de Sud / Japonia", champion: "BRA", runnerUp: "GER", third: "TUR", topScorer: "Ronaldo (BRA) — 8", ball: "Fevernova", note: "Al cincilea titlu al Braziliei — revenirea lui Ronaldo după accidentări." },
  { year: 2006, host: "Germania",       champion: "ITA", runnerUp: "FRA", third: "GER", topScorer: "Miroslav Klose (GER) — 5", ball: "Teamgeist", note: "Italia câștigă la penalty-uri; finala rămasă în memorie pentru lovitura de cap a lui Zidane." },
  { year: 2010, host: "Africa de Sud",  champion: "ESP", runnerUp: "NED", third: "GER", topScorer: "Thomas Müller (GER) — 5", ball: "Jabulani", note: "Primul titlu al Spaniei, generația de aur tiki-taka." },
  { year: 2014, host: "Brazilia",       champion: "GER", runnerUp: "ARG", third: "NED", topScorer: "James Rodríguez (COL) — 6", ball: "Brazuca", note: "Germania 7-1 Brazilia în semifinală — al patrulea titlu german." },
  { year: 2018, host: "Rusia",          champion: "FRA", runnerUp: "CRO", third: "BEL", topScorer: "Harry Kane (ENG) — 6", ball: "Telstar 18", note: "Franța lui Mbappé și Griezmann câștigă al doilea titlu." },
  { year: 2022, host: "Qatar",          champion: "ARG", runnerUp: "FRA", third: "CRO", topScorer: "Kylian Mbappé (FRA) — 8", ball: "Al Rihla", note: "Argentina lui Messi câștigă al treilea titlu, finală istorică 3-3 (pen. 4-2) cu Franța." },
  { year: 2026, host: "Canada / Mexic / SUA", champion: "ESP", runnerUp: "ARG", third: "ENG", topScorer: "Kylian Mbappé (FRA) — 10", ball: "Trionda", note: "Prima ediție cu 48 de echipe și șaisprezecimi. Spania învinge Argentina 1-0 după prelungiri și câștigă al doilea titlu; Anglia ia bronzul după 6-4 cu Franța." },
];

/* ---------- FORMATS: regulamentul fiecărei ediții ----------
   stages = drumul unei echipe prin turneu:
     group      — faza grupelor: size (echipe în grupă), groups (câte grupe),
                  advance (câte trec), bestThirds (câte locuri 3 trec, din toate grupele),
                  seededOnly (1954: capii de serie joacă doar cu necapii → 2 meciuri),
                  sizeFromReal (1930/1950: grupe inegale — mărimea vine din grupa reală)
     group2     — a doua fază a grupelor (1974-1982): winnerTo = runda următoare,
                  secondTo = "3P" dacă locul 2 joacă finala mică
     finalGroup — grupa finală din 1950: locul 1 e campioana
     ko         — meci eliminatoriu: round = R32 / R16 / QF / SF / F
   win = puncte pentru victorie (egal = 1, înfrângere = 0)
   tiebreak = "gd" (golaveraj: diferență, apoi goluri marcate), "ga" (media golurilor),
              "playoff" (baraj la egalitate de puncte pe locul de calificare)
   koTie = cum se decide o egalitate după prelungiri: "replay" (meci rejucat),
           "lots" (tragere la sorți), "penalties"
   cards = "none" | "accumulate" (2 galbene = suspendare, tot turneul) |
           "reset" (galbenele se șterg după grupe)
   third = există finala mică
   byes = echipe scutite de o rundă (1938: Suedia în optimi)
   subs = schimbări permise în timpul regulamentar (0 până în 1966, 2, 3, apoi 5 din 2022)
   gkSub = schimbare în plus pentru portarul accidentat (1994)
   etSub = schimbări în plus dacă se ajunge în prelungiri (din 2018)
   goldenGoal = primul gol din prelungiri închide meciul (1998, 2002)
   fairPlay = la egalitate totală în grupă contează cartonașele (din 2018)
   group.groupExtraTime = și meciurile din grupă merg în prelungiri la egal (1954)
   Mărimea lotului (22 / 23 / 26) vine din squadSizeFor(year) în engine.js. */
const FORMATS = {
  1930: { subs: 0, teams: 13, win: 2, tiebreak: "gd", koTie: "replay", cards: "none", third: false,
    stages: [{ type: "group", size: 3, groups: 4, advance: 1, sizeFromReal: true }, { type: "ko", round: "SF" }, { type: "ko", round: "F" }],
    summary: "13 echipe, fără calificări. 4 grupe (una de 4, trei de 3); doar câștigătoarea grupei trece. Semifinale, finală. Fără optimi, sferturi sau loc 3. Punctaj 2/1/0, fără cartonașe." },
  1934: { subs: 0, teams: 16, win: 2, tiebreak: "gd", koTie: "replay", cards: "none", third: true,
    stages: [{ type: "ko", round: "R16" }, { type: "ko", round: "QF" }, { type: "ko", round: "SF" }, { type: "ko", round: "F" }],
    summary: "16 echipe, prima ediție cu calificări. Fără grupe: optimi, sferturi, semifinale, locul 3, finală. La egalitate: prelungiri, apoi meci rejucat. Fără cartonașe." },
  1938: { subs: 0, teams: 15, win: 2, tiebreak: "gd", koTie: "replay", cards: "none", third: true, byes: { R16: ["SWE"] },
    stages: [{ type: "ko", round: "R16" }, { type: "ko", round: "QF" }, { type: "ko", round: "SF" }, { type: "ko", round: "F" }],
    summary: "15 echipe (Austria s-a retras după Anschluss; Suedia a primit bye în optimi). Fără grupe: optimi, sferturi, semifinale, locul 3, finală. La egalitate: prelungiri, apoi meci rejucat. Fără cartonașe." },
  1950: { subs: 0, teams: 13, win: 2, tiebreak: "gd", koTie: "replay", cards: "none", third: false,
    stages: [{ type: "group", size: 4, groups: 4, advance: 1, sizeFromReal: true }, { type: "finalGroup", size: 4 }],
    summary: "13 echipe (retrageri). 4 grupe inegale; câștigătoarele merg în grupa finală de 4, jucată toți contra toți — prima clasată e campioană. Fără optimi, sferturi, semifinale sau finală separată. Punctaj 2/1/0." },
  1954: { subs: 0, teams: 16, win: 2, tiebreak: "playoff", koTie: "lots", cards: "none", third: true,
    stages: [{ type: "group", size: 4, groups: 4, advance: 2, seededOnly: true, groupExtraTime: true }, { type: "ko", round: "QF" }, { type: "ko", round: "SF" }, { type: "ko", round: "F" }],
    summary: "16 echipe. 4 grupe de 4, dar capii de serie joacă doar cu necapii (2 meciuri). Primele 2 trec; la egalitate de puncte, baraj. La egal după 90 de minute, și în grupă se joacă prelungiri. Sferturi, semifinale, locul 3, finală. Punctaj 2/1/0, fără cartonașe, fără schimbări." },
  1958: { subs: 0, teams: 16, win: 2, tiebreak: "playoff", koTie: "lots", cards: "none", third: true,
    stages: [{ type: "group", size: 4, groups: 4, advance: 2 }, { type: "ko", round: "QF" }, { type: "ko", round: "SF" }, { type: "ko", round: "F" }],
    summary: "16 echipe. 4 grupe de 4, toți contra toți; primele 2 trec, la egalitate de puncte se joacă baraj. Sferturi, semifinale, locul 3, finală. Punctaj 2/1/0, fără cartonașe." },
  1962: { subs: 0, teams: 16, win: 2, tiebreak: "ga", koTie: "lots", cards: "none", third: true,
    stages: [{ type: "group", size: 4, groups: 4, advance: 2 }, { type: "ko", round: "QF" }, { type: "ko", round: "SF" }, { type: "ko", round: "F" }],
    summary: "16 echipe. 4 grupe de 4; primele 2 trec, departajare prin media golurilor. Sferturi, semifinale, locul 3, finală. Punctaj 2/1/0, fără cartonașe." },
  1966: { subs: 0, teams: 16, win: 2, tiebreak: "ga", koTie: "lots", cards: "none", third: true,
    stages: [{ type: "group", size: 4, groups: 4, advance: 2 }, { type: "ko", round: "QF" }, { type: "ko", round: "SF" }, { type: "ko", round: "F" }],
    summary: "16 echipe. 4 grupe de 4; primele 2 trec, departajare prin media golurilor. Sferturi, semifinale, locul 3, finală. Punctaj 2/1/0, fără cartonașe." },
  1970: { subs: 2, teams: 16, win: 2, tiebreak: "gd", koTie: "lots", cards: "accumulate", third: true,
    stages: [{ type: "group", size: 4, groups: 4, advance: 2 }, { type: "ko", round: "QF" }, { type: "ko", round: "SF" }, { type: "ko", round: "F" }],
    summary: "16 echipe. 4 grupe de 4; primele 2 trec, departajare prin diferența de goluri (nu media). Sferturi, semifinale, locul 3, finală. Punctaj 2/1/0. Prima ediție cu cartonașe galbene și roșii și cu schimbări (2 pe meci)." },
  1974: { subs: 2, teams: 16, win: 2, tiebreak: "gd", koTie: "penalties", cards: "accumulate", third: true,
    stages: [{ type: "group", size: 4, groups: 4, advance: 2 }, { type: "group2", size: 4, groups: 2, winnerTo: "F", secondTo: "3P" }, { type: "ko", round: "F" }],
    summary: "16 echipe. 4 grupe de 4 (primele 2 trec), apoi 2 grupe de 4: câștigătoarele joacă finala, locurile 2 joacă pentru locul 3. Fără optimi, sferturi sau semifinale clasice. Punctaj 2/1/0, 2 schimbări; penalty-urile intră în regulament. Primul cartonaș roșu din istoria Mondialelor." },
  1978: { subs: 2, teams: 16, win: 2, tiebreak: "gd", koTie: "penalties", cards: "accumulate", third: true,
    stages: [{ type: "group", size: 4, groups: 4, advance: 2 }, { type: "group2", size: 4, groups: 2, winnerTo: "F", secondTo: "3P" }, { type: "ko", round: "F" }],
    summary: "Același format ca în 1974: 4 grupe, apoi 2 grupe de 4, apoi locul 3 și finala. Fără optimi, sferturi sau semifinale clasice. Punctaj 2/1/0, cartonașe în uz." },
  1982: { subs: 2, teams: 24, win: 2, tiebreak: "gd", koTie: "penalties", cards: "accumulate", third: true,
    stages: [{ type: "group", size: 4, groups: 6, advance: 2 }, { type: "group2", size: 3, groups: 4, winnerTo: "SF" }, { type: "ko", round: "SF" }, { type: "ko", round: "F" }],
    summary: "24 de echipe, prima extindere. 6 grupe de 4 (primele 2 trec), apoi 4 grupe de 3 — câștigătoarele merg în semifinale. Semifinale, locul 3, finală. Punctaj 2/1/0, cartonașe în uz." },
  1986: { subs: 2, teams: 24, win: 2, tiebreak: "gd", koTie: "penalties", cards: "accumulate", third: true,
    stages: [{ type: "group", size: 4, groups: 6, advance: 2, bestThirds: 4 }, { type: "ko", round: "R16" }, { type: "ko", round: "QF" }, { type: "ko", round: "SF" }, { type: "ko", round: "F" }],
    summary: "24 de echipe. 6 grupe; trec primele 2 plus cele mai bune 4 locuri 3. Optimi, sferturi, semifinale, locul 3, finală — prima ediție modernă cu optimi după grupe. Punctaj 2/1/0, cartonașe în uz." },
  1990: { subs: 2, teams: 24, win: 2, tiebreak: "gd", koTie: "penalties", cards: "accumulate", third: true,
    stages: [{ type: "group", size: 4, groups: 6, advance: 2, bestThirds: 4 }, { type: "ko", round: "R16" }, { type: "ko", round: "QF" }, { type: "ko", round: "SF" }, { type: "ko", round: "F" }],
    summary: "Același format ca în 1986: 6 grupe, primele 2 + 4 locuri 3, apoi optimi, sferturi, semifinale, locul 3, finală. Ultima ediție cu 2 puncte la victorie; două galbene pe tot turneul însemnau suspendare, inclusiv în fazele târzii." },
  1994: { subs: 2, gkSub: true, teams: 24, win: 3, tiebreak: "gd", koTie: "penalties", cards: "reset", third: true,
    stages: [{ type: "group", size: 4, groups: 6, advance: 2, bestThirds: 4 }, { type: "ko", round: "R16" }, { type: "ko", round: "QF" }, { type: "ko", round: "SF" }, { type: "ko", round: "F" }],
    summary: "24 de echipe, același drum ca în 1986/1990. Punctaj nou: 3/1/0. Galbenele din grupe se șterg la faza eliminatorie. 2 schimbări + una în plus pentru portarul accidentat." },
  1998: { subs: 3, goldenGoal: true, teams: 32, win: 3, tiebreak: "gd", koTie: "penalties", cards: "reset", third: true,
    stages: [{ type: "group", size: 4, groups: 8, advance: 2 }, { type: "ko", round: "R16" }, { type: "ko", round: "QF" }, { type: "ko", round: "SF" }, { type: "ko", round: "F" }],
    summary: "32 de echipe. 8 grupe de 4, primele 2 trec. Optimi, sferturi, semifinale, locul 3, finală. Punctaj 3/1/0, galbenele se șterg după grupe. 3 schimbări; gol de aur în prelungiri." },
  2026: { subs: 5, etSub: 1, fairPlay: true, teams: 48, win: 3, tiebreak: "gd", koTie: "penalties", cards: "reset", third: true,
    stages: [{ type: "group", size: 4, groups: 12, advance: 2, bestThirds: 8 }, { type: "ko", round: "R32" }, { type: "ko", round: "R16" }, { type: "ko", round: "QF" }, { type: "ko", round: "SF" }, { type: "ko", round: "F" }],
    summary: "48 de echipe. 12 grupe de 4; trec primele 2 plus cele mai bune 8 locuri 3 (32 de echipe). Șaisprezecimi, optimi, sferturi, semifinale, locul 3, finală. Punctaj 3/1/0, galbenele se șterg după grupe. 5 schimbări + una în prelungiri; departajare și prin fair-play." },
};
FORMATS[2002] = Object.assign({}, FORMATS[1998], { summary: "32 de echipe, primul Mondial în Asia și cu două gazde. 8 grupe de 4, primele 2 trec; optimi, sferturi, semifinale, locul 3, finală. Punctaj 3/1/0, 3 schimbări, lot de 23. Ultima ediție cu gol de aur." });
const MODERN = Object.assign({}, FORMATS[1998], { goldenGoal: false });
FORMATS[2006] = Object.assign({}, MODERN, { summary: "32 de echipe, 8 grupe de 4; optimi, sferturi, semifinale, locul 3, finală. Golul de aur dispare: prelungiri complete (2×15), apoi penalty-uri. 3 schimbări, lot de 23." });
FORMATS[2010] = Object.assign({}, MODERN, { summary: "32 de echipe, 8 grupe de 4; optimi, sferturi, semifinale, locul 3, finală. Punctaj 3/1/0, 3 schimbări, prelungiri complete apoi penalty-uri." });
FORMATS[2014] = Object.assign({}, MODERN, { summary: "32 de echipe, 8 grupe de 4; optimi, sferturi, semifinale, locul 3, finală. 3 schimbări. Prima ediție cu tehnologia pe linia porții." });
FORMATS[2018] = Object.assign({}, MODERN, { etSub: 1, fairPlay: true, summary: "32 de echipe, 8 grupe de 4; optimi, sferturi, semifinale, locul 3, finală. Prima ediție cu VAR. 3 schimbări + a 4-a în prelungiri; la egalitate totală în grupă contează fair-play-ul (cartonașele)." });
FORMATS[2022] = Object.assign({}, MODERN, { subs: 5, etSub: 1, fairPlay: true, summary: "32 de echipe, ultima ediție în acest format; prima iarnă. 5 schimbări + una în prelungiri, lot de 26, VAR și ofsaid semi-automat. Departajare și prin fair-play." });
function getFormat(year) { return FORMATS[year]; }

/* ---------- TEAMS: curbe de putere (puncte de control interpolate) ----------
   rating pe scară 40-99. Punctele lipsă dintre ani se interpolează liniar
   în engine.js (getTeamRating). */
const TEAMS = {
  BRA: { name: "Brazilia", flag: "🇧🇷", curve: { 1930:58, 1938:70, 1950:78, 1958:88, 1962:87, 1970:93, 1978:80, 1982:85, 1986:80, 1994:86, 1998:87, 2002:90, 2006:84, 2014:82, 2018:85, 2022:86 } },
  ARG: { name: "Argentina", flag: "🇦🇷", curve: { 1930:70, 1958:65, 1974:72, 1978:83, 1982:78, 1986:90, 1990:82, 1994:78, 1998:80, 2002:78, 2006:82, 2010:80, 2014:85, 2018:75, 2022:89 } },
  GER: { name: "Germania", flag: "🇩🇪", curve: { 1934:68, 1954:83, 1958:72, 1966:82, 1970:83, 1974:88, 1982:80, 1986:85, 1990:90, 1994:78, 1998:70, 2002:80, 2006:82, 2010:83, 2014:91, 2018:72, 2022:76 } },
  ITA: { name: "Italia", flag: "🇮🇹", curve: { 1934:85, 1938:88, 1950:65, 1962:65, 1970:84, 1978:76, 1982:86, 1986:70, 1990:84, 1994:83, 1998:78, 2006:86, 2010:65, 2014:70 } },
  URU: { name: "Uruguay", flag: "🇺🇾", curve: { 1930:88, 1950:85, 1954:78, 1970:65, 1986:62, 2010:76, 2014:70, 2018:72, 2022:65 } },
  ENG: { name: "Anglia", flag: "🏴󠁧󠁢󠁥󠁮󠁧󠁿", curve: { 1950:60, 1962:65, 1966:87, 1970:78, 1990:75, 2002:72, 2006:73, 2010:65, 2014:60, 2018:78, 2022:76 } },
  FRA: { name: "Franța", flag: "🇫🇷", curve: { 1930:55, 1938:62, 1958:82, 1978:65, 1982:80, 1986:80, 1998:90, 2002:60, 2006:83, 2010:55, 2014:72, 2018:87, 2022:88 } },
  NED: { name: "Olanda", flag: "🇳🇱", curve: { 1974:88, 1978:85, 1990:70, 1994:75, 1998:80, 2010:83, 2014:81, 2022:78 } },
  HUN: { name: "Ungaria", flag: "🇭🇺", curve: { 1934:70, 1938:78, 1954:92, 1958:60, 1966:65 } },
  ESP: { name: "Spania", flag: "🇪🇸", curve: { 1934:65, 1950:70, 1966:60, 1982:62, 1994:70, 2002:75, 2010:90, 2014:70, 2018:74, 2022:75 } },
  POR: { name: "Portugalia", flag: "🇵🇹", curve: { 1966:82, 2006:78, 2010:70, 2014:65, 2018:75, 2022:74 } },
  SWE: { name: "Suedia", flag: "🇸🇪", curve: { 1938:65, 1950:70, 1958:83, 1994:80 } },
  BEL: { name: "Belgia", flag: "🇧🇪", curve: { 1986:70, 2014:68, 2018:83, 2022:70 } },
  CRO: { name: "Croația", flag: "🇭🇷", curve: { 1998:78, 2018:85, 2022:80 } },
  POL: { name: "Polonia", flag: "🇵🇱", curve: { 1974:80, 1982:76 } },
  TCH: { name: "Cehoslovacia", flag: "🇨🇿", curve: { 1934:80, 1962:74 } },
  MEX: { name: "Mexic", flag: "🇲🇽", curve: { 1970:65, 1986:68, 2018:65 } },
  USA: { name: "SUA", flag: "🇺🇸", curve: { 1930:58, 1994:60, 2002:62, 2022:63 } },
  JPN: { name: "Japonia", flag: "🇯🇵", curve: { 2002:62, 2010:60, 2018:60, 2022:65 } },
  MAR: { name: "Maroc", flag: "🇲🇦", curve: { 2022:74 } },
  KOR: { name: "Coreea de Sud", flag: "🇰🇷", curve: { 2002:65, 2010:58 } },
  TUR: { name: "Turcia", flag: "🇹🇷", curve: { 2002:70 } },
  AUT: { name: "Austria", flag: "🇦🇹", curve: { 1954:75 } },
};

/* ---------- LEGENDS: fotbaliști istorici (apar automat în lotul echipei lor) ---------- */
const LEGENDS = [
  { code: "PELE",   name: "Pelé",              team: "BRA", yearTag: 1970, boost: 14, bio: "Singurul jucător cu 3 titluri mondiale (1958, 1962, 1970). \"O Rei\" — golgheter legendar și simbol al fotbalului brazilian." },
  { code: "MARADONA", name: "Diego Maradona",  team: "ARG", yearTag: 1986, boost: 14, bio: "Câștigă Cupa Mondială aproape de unul singur în 1986 — \"Mâna lui Dumnezeu\" și \"Golul Secolului\", ambele în același meci." },
  { code: "BECKENBAUER", name: "Franz Beckenbauer", team: "GER", yearTag: 1974, boost: 12, bio: "\"Der Kaiser\" — a reinventat rolul de fundaș central liber (libero); campion mondial ca jucător (1974) și antrenor (1990)." },
  { code: "CRUYFF", name: "Johan Cruyff",       team: "NED", yearTag: 1974, boost: 12, bio: "Simbolul \"Fotbalului Total\" olandez — finalist în 1974, una dintre cele mai influente figuri tactice din istorie." },
  { code: "ZIDANE", name: "Zinédine Zidane",    team: "FRA", yearTag: 1998, boost: 13, bio: "Erou al titlului din 1998 (dublă în finală) și finalist în 2006 — unul dintre cei mai eleganți mijlocași din istorie." },
  { code: "MESSI",  name: "Lionel Messi",       team: "ARG", yearTag: 2022, boost: 14, bio: "Câștigă în sfârșit Cupa Mondială în 2022, la Qatar, încununând o carieră de opt Baloane de Aur." },
  { code: "RONALDOBR", name: "Ronaldo Nazário", team: "BRA", yearTag: 2002, boost: 13, bio: "\"Fenomenul\" — golgheterul finalei din 2002, revenit din accidentări grave pentru al cincilea titlu al Braziliei." },
  { code: "MULLERG", name: "Gerd Müller",       team: "GER", yearTag: 1970, boost: 12, bio: "Golgheterul all-time al Germaniei la CM — 10 goluri în 1970, gol decisiv în finala din 1974." },
  { code: "PUSKAS",  name: "Ferenc Puskás",     team: "HUN", yearTag: 1954, boost: 12, bio: "Căpitanul \"Marii Echipe Maghiare\", finalistă în 1954 — unul dintre cei mai mari marcatori din istoria fotbalului." },
  { code: "DISTEFANO", name: "Alfredo Di Stéfano", team: "ESP", yearTag: 1962, boost: 8, bio: "Legenda Realului Madrid nu a jucat niciodată la o fază finală de Cupă Mondială — inclus aici ca omagiu la era sa." },
  { code: "PLATINI", name: "Michel Platini",    team: "FRA", yearTag: 1982, boost: 11, bio: "Căpitan și dirijor al Franței \"Carré Magique\" din anii '80 — semifinalist în 1982 și 1986." },
  { code: "EUSEBIO", name: "Eusébio",           team: "POR", yearTag: 1966, boost: 12, bio: "\"Pantera Neagră\" — golgheter al CM 1966 (9 goluri) și artizanul celui mai bun rezultat portughez din istorie." },
  { code: "CR7",     name: "Cristiano Ronaldo", team: "POR", yearTag: 2018, boost: 12, bio: "Prezent la cinci ediții consecutive (2006-2022) — hat-trick memorabil contra Spaniei în 2018." },
  { code: "KAKA",    name: "Kaká",              team: "BRA", yearTag: 2002, boost: 9, bio: "Balon de Aur 2007 — parte din lotul campion al Braziliei în 2002, la doar 20 de ani." },
  { code: "INIESTA", name: "Andrés Iniesta",    team: "ESP", yearTag: 2010, boost: 11, bio: "Autorul golului din finala din 2010 — simbolul generației de aur a Spaniei." },
  { code: "KLOSE",   name: "Miroslav Klose",    team: "GER", yearTag: 2014, boost: 11, bio: "Golgheterul all-time al Cupelor Mondiale (16 goluri, 2002-2014) — campion mondial în 2014." },
  { code: "STABILE", name: "Guillermo Stábile", team: "ARG", yearTag: 1930, boost: 10, bio: "Golgheterul primei ediții a Cupei Mondiale (1930), cu Argentina finalistă." },
  { code: "FONTAINE", name: "Just Fontaine",    team: "FRA", yearTag: 1958, boost: 10, bio: "Recordul absolut de goluri într-o singură ediție — 13 goluri în 1958, record neegalat." },
];

/* ---------- SHADOW TEAMS: adversari "doar istorici", fără curbă curatoare ----------
   Statele istorice fără steag emoji folosesc steagul succesorului principal
   (Iugoslavia → Serbia, URSS → Rusia, RDG → Germania, Indiile Olandeze → Indonezia).
   Rating-ul lor se deduce automat în engine.js (getShadowRating) din diferența
   de gol reală față de echipele curate — vezi real_fixtures.js. */
const SHADOW_TEAMS = {
  PER: { name: "Peru", flag: "🇵🇪" },
  ROU: { name: "România", flag: "🇷🇴" },
  YUG: { name: "Iugoslavia", flag: "🇷🇸" },
  BUL: { name: "Bulgaria", flag: "🇧🇬" },
  UAE: { name: "Emiratele Arabe Unite", flag: "🇦🇪" },
  COL: { name: "Columbia", flag: "🇨🇴" },
  RSA: { name: "Africa de Sud", flag: "🇿🇦" },
  KSA: { name: "Arabia Saudită", flag: "🇸🇦" },
  DEN: { name: "Danemarca", flag: "🇩🇰" },
  PAR: { name: "Paraguay", flag: "🇵🇾" },
  CHN: { name: "China", flag: "🇨🇳" },
  CRC: { name: "Costa Rica", flag: "🇨🇷" },
  GHA: { name: "Ghana", flag: "🇬🇭" },
  ALG: { name: "Algeria", flag: "🇩🇿" },
  AUS: { name: "Australia", flag: "🇦🇺" },
  RUS: { name: "Rusia", flag: "🇷🇺" },
  TUN: { name: "Tunisia", flag: "🇹🇳" },
  SUI: { name: "Elveția", flag: "🇨🇭" },
  CHI: { name: "Chile", flag: "🇨🇱" },
  ANG: { name: "Angola", flag: "🇦🇴" },
  BIH: { name: "Bosnia și Herțegovina", flag: "🇧🇦" },
  BOL: { name: "Bolivia", flag: "🇧🇴" },
  CAN: { name: "Canada", flag: "🇨🇦" },
  CIV: { name: "Coasta de Fildeș", flag: "🇨🇮" },
  CMR: { name: "Camerun", flag: "🇨🇲" },
  CUB: { name: "Cuba", flag: "🇨🇺" },
  CZE: { name: "Cehia", flag: "🇨🇿" },
  DEI: { name: "Indiile Olandeze de Est", flag: "🇮🇩" },
  ECU: { name: "Ecuador", flag: "🇪🇨" },
  EGY: { name: "Egipt", flag: "🇪🇬" },
  GDR: { name: "Germania de Est", flag: "🇩🇪" },
  GRE: { name: "Grecia", flag: "🇬🇷" },
  HAI: { name: "Haiti", flag: "🇭🇹" },
  HON: { name: "Honduras", flag: "🇭🇳" },
  IRL: { name: "Irlanda", flag: "🇮🇪" },
  IRN: { name: "Iran", flag: "🇮🇷" },
  IRQ: { name: "Irak", flag: "🇮🇶" },
  ISL: { name: "Islanda", flag: "🇮🇸" },
  ISR: { name: "Israel", flag: "🇮🇱" },
  JAM: { name: "Jamaica", flag: "🇯🇲" },
  KUW: { name: "Kuweit", flag: "🇰🇼" },
  NGA: { name: "Nigeria", flag: "🇳🇬" },
  NIR: { name: "Irlanda de Nord", flag: "🇬🇧" },
  NOR: { name: "Norvegia", flag: "🇳🇴" },
  NZL: { name: "Noua Zeelandă", flag: "🇳🇿" },
  PAN: { name: "Panama", flag: "🇵🇦" },
  PRK: { name: "Coreea de Nord", flag: "🇰🇵" },
  QAT: { name: "Qatar", flag: "🇶🇦" },
  SCG: { name: "Serbia și Muntenegru", flag: "🇷🇸" },
  SCO: { name: "Scoția", flag: "🏴󠁧󠁢󠁳󠁣󠁴󠁿" },
  SEN: { name: "Senegal", flag: "🇸🇳" },
  SLV: { name: "El Salvador", flag: "🇸🇻" },
  SRB: { name: "Serbia", flag: "🇷🇸" },
  SVK: { name: "Slovacia", flag: "🇸🇰" },
  SVN: { name: "Slovenia", flag: "🇸🇮" },
  TOG: { name: "Togo", flag: "🇹🇬" },
  TRI: { name: "Trinidad-Tobago", flag: "🇹🇹" },
  UKR: { name: "Ucraina", flag: "🇺🇦" },
  URS: { name: "Uniunea Sovietică", flag: "🇷🇺" },
  WAL: { name: "Țara Galilor", flag: "🏴󠁧󠁢󠁷󠁬󠁳󠁿" },
  ZAI: { name: "Zair", flag: "🇨🇩" },
};

function getTeamMeta(code) {
  return TEAMS[code] || SHADOW_TEAMS[code] || { name: code, flag: "🏳️" };
}

if (typeof module !== "undefined" && module.exports) {
  module.exports = { EDITIONS, TEAMS, LEGENDS, SHADOW_TEAMS, FORMATS, getFormat, getTeamMeta };
}
