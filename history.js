/* ============================================================
   HISTORY OF WORLD CUP — history.js
   Conținut de muzeu: evoluția regulilor (1930-2026), familiile de
   format și povestea fiecărei ediții. Doar text — motorul nu îl
   folosește. Exportat și pentru iOS (tools/export_ios_data.js).
   ============================================================ */

/* ---------- Cronologia regulilor de pe teren ---------- */
const RULES_TIMELINE = [
  { years: "1930–1966", title: "Unsprezece de fier",
    items: [
      "Fără schimbări: un jucător accidentat rămânea pe teren sau echipa continua în 10.",
      "Fără cartonașe: avertismentele și eliminările se dădeau verbal.",
      "Egal în eliminatorii (1934, 1938): prelungiri, apoi meci rejucat. 1954–1970: prelungiri, apoi tragere la sorți (nefolosită în turneele finale).",
      "Portarul putea prinde cu mâna pasa înapoi de la un coechipier.",
      "Departajarea în grupă: baraj (1954, 1958), media golurilor (1962, 1966).",
    ] },
  { years: "1970", title: "Prima ruptură — Mexic",
    items: [
      "Apar cartonașele galben și roșu. Primul galben: Evgheni Lovciov (URSS), în meciul de deschidere (unele surse îl numesc pe Kahi Asatiani). Niciun roșu în tot turneul.",
      "Sunt permise 2 schimbări pe meci. Prima din istoria Mondialelor: Anatoli Puzach în locul lui Viktor Serebrianikov (URSS), la pauza meciului de deschidere.",
      "Diferența de goluri înlocuiește media golurilor la departajare.",
    ] },
  { years: "1974–1978", title: "Roșu și penalty-uri",
    items: [
      "1974: primul cartonaș roșu — Carlos Caszely (Chile), cu RFG.",
      "Loviturile de departajare intră în regulament în locul rejucării. Prima serie la un Mondial vine abia în 1982 (RFG–Franța, semifinală).",
    ] },
  { years: "1982–1990", title: "Galbenele care nu se iartă",
    items: [
      "2 schimbări, 2 puncte la victorie.",
      "Galbenele se cumulează pe tot turneul: două, oriunde, înseamnă suspendare — inclusiv pentru finală.",
      "1986: ultimele meciuri din grupă se joacă simultan, după „rușinea de la Gijón” din 1982.",
      "1990: jucătorul aflat în linie cu penultimul apărător nu mai e în ofsaid.",
    ] },
  { years: "1994", title: "Trei lovituri deodată — SUA",
    items: [
      "3 puncte la victorie, în loc de 2.",
      "Portarul nu mai poate prinde cu mâna pasa înapoi dată intenționat cu piciorul.",
      "Galbenele din grupe se șterg la începutul fazei eliminatorii.",
      "2 schimbări, plus una în plus pentru portarul accidentat.",
    ] },
  { years: "1998–2002", title: "Golul de aur",
    items: [
      "3 schimbări pe meci; 32 de echipe din 1998.",
      "Golul de aur: primul gol din prelungiri închide meciul. Abandonat după 2004 — încuraja așteptarea, nu atacul.",
      "2002: lotul crește la 23 (al treilea portar).",
    ] },
  { years: "2006–2014", title: "Prelungiri complete",
    items: [
      "Fără gol de aur: 2×15 minute, apoi penalty-uri.",
      "2010: golul nevalidat al lui Lampard (Anglia–Germania) grăbește tehnologia pe linia porții.",
      "2014: prima dată goal-line technology la un Mondial.",
    ] },
  { years: "2018", title: "VAR",
    items: [
      "Prima folosire a arbitrajului video la un Mondial; ofsaidul începe să fie verificat video.",
      "3 schimbări + a 4-a în prelungiri.",
      "La egalitate totală în grupă contează fair-play-ul: Japonia trece de Senegal prin mai puține cartonașe.",
    ] },
  { years: "2022", title: "Cinci schimbări — Qatar",
    items: [
      "5 schimbări + una în prelungiri + schimbări suplimentare la suspiciune de comoție.",
      "Lot de 26 de jucători, minimum 3 portari.",
      "VAR cu ofsaid semi-automat; timpul adăugat calculat mult mai strict.",
    ] },
  { years: "2026", title: "Ritm impus — Canada / Mexic / SUA",
    items: [
      "48 de echipe; 5 schimbări + una în prelungiri + comoție; punctaj 3/1/0.",
      "Portarul are o limită vizibilă de timp cu mingea în mână (altfel corner pentru adversar).",
      "Numărătoare de 5 secunde la aut și la lovitura de poartă; jucătorul schimbat are 10 secunde să iasă.",
      "VAR mai fin pe ofsaid (avatar 3D); sancțiuni mai dure pentru protestele grave.",
    ] },
];

/* ---------- Lotul pe epoci ---------- */
const SQUAD_RULES = [
  { years: "1930–1998", size: "22", text: "Fără schimbări până în 1970, lotul era rezervă de accidentări și de drum, nu bancă tactică." },
  { years: "2002–2018", size: "23", text: "Al 23-lea e aproape mereu al treilea portar." },
  { years: "2022–2026", size: "26", text: "Minimum 3 portari. Cu 5 schimbări, lotul trebuie să aibă două unsprezecuri compatibile. În 2026: listă preliminară de 35–55 de nume, lista finală cu 10 zile înainte de start, înlocuiri doar pentru accidentare sau boală." },
];

/* ---------- Cele 7 familii de format ---------- */
const FORMAT_FAMILIES = [
  { years: "1930", text: "Grupe scurte → semifinale → finală. Fără locul 3." },
  { years: "1934–1938", text: "Totul eliminatoriu, de la optimi." },
  { years: "1950", text: "Grupe → grupă finală de 4, fără finală propriu-zisă." },
  { years: "1954–1970", text: "4 grupe de 4 → sferturi." },
  { years: "1974–1982", text: "Grupe în două trepte (1982: apoi semifinale)." },
  { years: "1986–2022", text: "Grupe → optimi (24, apoi 32 de echipe)." },
  { years: "2026", text: "12 grupe → șaisprezecimi (48 de echipe)." },
];

const TITLE_PATH = [
  { years: "1930", games: "4" }, { years: "1934–1938", games: "4–5 (cu rejucări)" }, { years: "1950", games: "6" },
  { years: "1954", games: "5–6" }, { years: "1958–1970", games: "6" }, { years: "1974–2022", games: "7" }, { years: "2026", games: "8" },
];

/* ---------- Povestea fiecărei ediții ---------- */
const STORIES = {
  1930: {
    context: "Uruguay, 13–30 iulie. Prima ediție, singura fără calificări și singura jucată integral într-un singur oraș: Montevideo. Țara sărbătorea 100 de ani de la prima constituție și era dublă campioană olimpică; a plătit drumul echipelor. Au venit doar 13: patru europene (Franța, Belgia, România — cu lotul ales de regele Carol al II-lea — și Iugoslavia), cu vaporul, împreună cu Jules Rimet și trofeul.",
    moments: [
      "Franța 4–1 Mexic: primul gol din istoria Mondialelor, Lucien Laurent, minutul 19.",
      "SUA 3–0 Paraguay: Bert Patenaude, primul hat-trick recunoscut de FIFA.",
      "România 3–1 Peru: prima victorie a României la un Mondial.",
      "Estadio Centenario se deschide cu 5 zile întârziere, din cauza ploilor.",
      "Argentina 6–1 SUA în semifinală: americanul Raphael Tracey își rupe piciorul — fără schimbări, echipa rămâne în 10.",
    ],
    final: "Uruguay 4–2 Argentina (Dorado, Peucelle, Stábile, Cea, Iriarte, Castro). O repriză cu mingea fiecărei echipe; arbitrul John Langenus a cerut escortă. A doua zi, zi liberă națională în Uruguay.",
    coach: "Alberto Suppici (Uruguay), 28 de ani — cel mai tânăr antrenor campion mondial.",
  },
  1934: {
    context: "Italia, 27 mai–10 iunie. Prima ediție cu calificări (gazda a trebuit să treacă de Grecia) și prima în Europa. Uruguay, campioana, a refuzat să vină. Egiptul devine prima echipă africană la un Mondial.",
    moments: [
      "Toate optimile se joacă în aceeași zi, la aceeași oră.",
      "Argentina și Brazilia pleacă acasă după un singur meci; toate sferturile sunt europene.",
      "Italia 1–1 Spania în sferturi, apoi 1–0 în meciul rejucat a doua zi, fără portarul Zamora, accidentat.",
      "Germania 3–2 Austria: primul meci pentru locul 3 din istorie.",
    ],
    final: "Italia 2–1 Cehoslovacia după prelungiri (Puc; Orsi, Schiavio), la Roma. Prima campioană europeană.",
    coach: "Vittorio Pozzo (Italia).",
  },
  1938: {
    context: "Franța, 4–19 iunie. Austria, calificată, dispare după Anschluss — Suedia, adversara ei, trece direct în sferturi, deci 15 echipe. Spania lipsește din cauza războiului civil, Argentina și Uruguay nu vin. Debutează Cuba și Indiile Olandeze de Est (azi Indonezia).",
    moments: [
      "Cuba 3–3 România, apoi 2–1 în rejucare: România iese în optimi.",
      "Elveția 4–2 Germania în rejucare — Germania, cu jucători austrieci, iese din primul tur.",
      "Brazilia 6–5 Polonia după prelungiri, cu patru goluri ale lui Leônidas.",
      "Brazilia 2–1 Cehoslovacia în rejucarea sfertului; Leônidas lipsește apoi din semifinala pierdută cu Italia.",
    ],
    final: "Italia 4–2 Ungaria (Colaussi 2, Piola 2; Titkos, Sárosi), la Colombes. Prima campioană care își apără titlul.",
    coach: "Vittorio Pozzo — singurul antrenor cu două titluri consecutive.",
  },
  1950: {
    context: "Brazilia, 24 iunie–16 iulie. Primul Mondial după război (1942 și 1946 nu s-au ținut). Din 16 calificate au rămas 13; Germania și Japonia erau suspendate. Maracanã e construit pentru turneu. Format unic: grupe, apoi o grupă finală de 4 — fără finală propriu-zisă.",
    moments: [
      "SUA 1–0 Anglia la Belo Horizonte (Gaetjens) — debutul englez la Mondiale se termină cu una dintre cele mai mari surprize.",
      "Italia, campioană en-titre și slăbită după tragedia de la Superga, iese în grupă cu Suedia.",
      "Uruguay joacă un singur meci în grupă: 8–0 cu Bolivia.",
      "Brazilia 7–1 Suedia și 6–1 Spania în grupa finală: favorită absolută.",
    ],
    final: "Ultimul meci al grupei finale: Uruguay 2–1 Brazilia (Friaça; Schiaffino, Ghiggia), în fața a peste 170.000 de oameni — „Maracanaço”. Braziliei îi ajungea egalul.",
    coach: "Juan López (Uruguay); căpitan Obdulio Varela.",
  },
  1954: {
    context: "Elveția, 16 iunie–4 iulie. „Mondialul golurilor”: 140 în 26 de meciuri, 5,38 pe meci — record. Ungaria lui Puskás, Kocsis și Hidegkuti venea cu peste 30 de meciuri fără înfrângere. În grupă, capii de serie jucau doar cu necapii, iar la egal se jucau prelungiri.",
    moments: [
      "Ungaria 8–3 RFG în grupă: Herberger își odihnește titularii; RFG trece apoi de Turcia în baraj (7–2).",
      "Austria 7–5 Elveția în sferturi: cel mai prolific meci din istoria Mondialelor.",
      "Ungaria 4–2 Brazilia: „Bătălia de la Berna”, cu trei eliminări verbale.",
      "Ungaria 4–2 Uruguay după prelungiri: prima înfrângere a Uruguayului la un Mondial.",
    ],
    final: "RFG 3–2 Ungaria la Berna (Puskás, Czibor; Morlock, Rahn 2), după 0–2 în 8 minute — „Miracolul de la Berna”. Prima echipă care pierde un meci în turneu și tot ia Cupa.",
    coach: "Sepp Herberger (RFG).",
  },
  1958: {
    context: "Suedia, 8–29 iunie. Grupele devin rotunde (toți contra toți), iar la egalitate de puncte pe locul 2 se joacă baraj — s-au jucat trei. Debutează URSS, Țara Galilor și Irlanda de Nord; Italia lipsește.",
    moments: [
      "Barajele: Irlanda de Nord, Țara Galilor și URSS trec de Cehoslovacia, Ungaria și Anglia.",
      "Pelé, 17 ani, intră titular abia în al treilea meci; marchează în sferturi (1–0 cu Țara Galilor), apoi hat-trick cu Franța.",
      "Just Fontaine: 13 goluri, inclusiv 4 în meciul pentru locul 3 (Franța 6–3 RFG). Record încă în picioare.",
    ],
    final: "Brazilia 5–2 Suedia la Stockholm (Vavá 2, Pelé 2, Zagallo; Liedholm, Simonsson). Primul titlu al Braziliei.",
    coach: "Vicente Feola (Brazilia).",
  },
  1962: {
    context: "Chile, 30 mai–17 iunie, după cutremurul devastator din 1960: „Pentru că nu mai avem nimic, vom face totul” (Carlos Dittborn, mort cu o lună înainte de start). Departajarea din grupă: media golurilor.",
    moments: [
      "Chile 2–0 Italia: „Bătălia de la Santiago”, arbitrată de Ken Aston — viitorul inventator al cartonașelor.",
      "Pelé se accidentează în al doilea meci; fără schimbări, îl înlocuiește în echipă Amarildo din meciul următor.",
      "Garrincha duce Brazilia prin sferturi și semifinală; eliminat cu Chile, e lăsat să joace finala.",
      "Chile 1–0 Iugoslavia: gazda pe podium.",
    ],
    final: "Brazilia 3–1 Cehoslovacia (Masopust; Amarildo, Zito, Vavá). A doua campioană care își apără titlul.",
    coach: "Aymoré Moreira (Brazilia).",
  },
  1966: {
    context: "Anglia, 11–30 iulie. Trofeul Jules Rimet e furat înainte de turneu și găsit de câinele Pickles. Debutează Portugalia și Coreea de Nord. Departajare tot prin media golurilor.",
    moments: [
      "Portugalia și Ungaria scot Brazilia din grupă; Pelé e lovit fără milă.",
      "Coreea de Nord 1–0 Italia (Pak Doo-ik): Italia acasă întâmpinată cu roșii.",
      "Portugalia 5–3 Coreea de Nord după 0–3: Eusébio, 4 goluri.",
      "Anglia 1–0 Argentina: Rattín, eliminat, refuză să iasă — de aici se naște ideea cartonașelor.",
    ],
    final: "Anglia 4–2 RFG după prelungiri la Wembley (Haller, Weber; Hurst 3, Peters). Golul de 3–2 „a fost / n-a fost”; Hurst, singurul hat-trick într-o finală până în 2022.",
    coach: "Alf Ramsey (Anglia) — „wingless wonders”.",
  },
  1970: {
    context: "Mexic, 31 mai–21 iunie. Căldură, altitudine, meciuri la prânz pentru televiziunea europeană, prima transmisie color pe scară largă. Se schimbă regulile, nu formatul: cartonașe, 2 schimbări, diferența de goluri.",
    moments: [
      "Mexic 0–0 URSS: primul cartonaș galben și prima schimbare din istoria Mondialelor.",
      "Brazilia 1–0 Anglia: parada lui Gordon Banks la capul lui Pelé.",
      "Brazilia 3–2 România: Pelé, două goluri.",
      "Italia 4–3 RFG după prelungiri: „Meciul secolului”, cu 5 goluri în prelungiri și Beckenbauer cu brațul în eșarfă.",
    ],
    final: "Brazilia 4–1 Italia la Azteca (Pelé, Gérson, Jairzinho, Carlos Alberto; Boninsegna). Al treilea titlu, trofeul Jules Rimet rămâne definitiv Braziliei. Jairzinho a marcat în toate meciurile.",
    coach: "Mário Zagallo — primul campion mondial ca jucător și ca antrenor.",
  },
  1974: {
    context: "RFG, 13 iunie–7 iulie. Noul trofeu FIFA înlocuiește Jules Rimet. Structura se schimbă: două faze de grupe, fără sferturi și semifinale clasice. Debut: Australia, RD Germană, Haiti, Zair.",
    moments: [
      "RFG 1–0 Chile: Carlos Caszely, primul cartonaș roșu din istoria Mondialelor.",
      "RD Germană 1–0 RFG (Sparwasser), singurul meci dintre cele două Germanii.",
      "Scoția iese neînvinsă, la diferență de goluri.",
      "Olanda 2–0 Brazilia în grupa a doua: „fotbalul total” trece de campioană.",
      "RFG 1–0 Polonia pe ploaie, la Frankfurt — meciul care decide finalista.",
    ],
    final: "RFG 2–1 Olanda la München (Neeskens pen.; Breitner pen., Müller). Olanda conduce înainte ca un german să atingă mingea.",
    coach: "Helmut Schön (RFG).",
  },
  1978: {
    context: "Argentina, 1–25 iunie, sub junta militară. Același format ca în 1974. Cruijff nu vine. Debut: Iran și Tunisia.",
    moments: [
      "Tunisia 3–1 Mexic: prima victorie africană la un Mondial.",
      "Scoția 3–2 Olanda (golul lui Gemmill) și tot iese la diferența de goluri.",
      "Austria 3–2 RFG: campioana en-titre pleacă fără medalie.",
      "Argentina 6–0 Peru: avea nevoie de 4 goluri diferență ca să treacă de Brazilia. Meci contestat și azi.",
      "Brazilia termină singura neînvinsă, pe locul 3.",
    ],
    final: "Argentina 3–1 Olanda după prelungiri la Monumental (Kempes 2, Bertoni; Nanninga). Olanda lovește bara în minutul 90.",
    coach: "César Luis Menotti (Argentina).",
  },
  1982: {
    context: "Spania, 13 iunie–11 iulie. Prima ediție cu 24 de echipe: 6 grupe, apoi 4 grupe de câte 3, apoi semifinale. Debut: Algeria, Camerun, Honduras, Kuweit, Noua Zeelandă.",
    moments: [
      "Algeria 2–1 RFG, apoi RFG 1–0 Austria — „rușinea de la Gijón” trimite Algeria acasă și duce la meciurile simultane.",
      "Ungaria 10–1 El Salvador: cel mai mare scor al Mondialelor.",
      "Italia 3–2 Brazilia: hat-trick Paolo Rossi; Braziliei lui Zico și Sócrates îi ajungea egalul.",
      "RFG 3–3 Franța, 5–4 la penalty-uri: prima serie de lovituri de departajare la un Mondial; Schumacher îl lovește pe Battiston fără sancțiune.",
    ],
    final: "Italia 3–1 RFG la Bernabéu (Rossi, Tardelli, Altobelli; Breitner). Urletul lui Tardelli; Zoff ridică trofeul la 40 de ani.",
    coach: "Enzo Bearzot (Italia).",
  },
  1986: {
    context: "Mexic, 31 mai–29 iunie. Columbia renunță, Mexic preia la un an după cutremur. Revin optimile: primele 2 plus cele mai bune 4 locuri 3. Ultimele meciuri din grupă se joacă simultan.",
    moments: [
      "Maroc câștigă grupa: prima africană pe primul loc.",
      "Danemarca 6–1 Uruguay, apoi 1–5 cu Spania în optimi (Butragueño 4).",
      "Argentina 2–1 Anglia: „Mâna lui Dumnezeu” și „Golul secolului”, la patru minute distanță.",
      "Franța 1–1 Brazilia, 4–3 la penalty-uri: Zico ratează un penalty în timpul jocului, Sócrates și Platini în serie.",
    ],
    final: "Argentina 3–2 RFG la Azteca (Brown, Valdano, Burruchaga; Rummenigge, Völler). De la 2–0 la 2–2, apoi pasa lui Maradona pentru Burruchaga.",
    coach: "Carlos Bilardo (Argentina).",
  },
  1990: {
    context: "Italia, 8 iunie–8 iulie. Cel mai sărac Mondial modern în goluri. Ultima ediție cu 2 puncte la victorie; galbenele se cumulează pe tot turneul. Ofsaidul se îndulcește: în linie nu mai e ofsaid.",
    moments: [
      "Camerun 1–0 Argentina la deschidere, în 9 oameni. Roger Milla, 38 de ani, 4 goluri de pe bancă.",
      "România 2–0 URSS (Lăcătuș 2) și 1–1 cu Argentina; iese în optimi la penalty-uri cu Irlanda.",
      "Argentina 1–0 Brazilia în optimi: Caniggia, după cursa lui Maradona.",
      "Anglia 3–2 Camerun după prelungiri: africanii ajung în sferturi.",
      "RFG–Anglia 1–1, 4–3 la penalty-uri; Gascoigne plânge după galbenul care l-ar fi scos din finală.",
    ],
    final: "RFG 1–0 Argentina la Roma (Brehme, penalty în minutul 85). Doi argentinieni eliminați.",
    coach: "Franz Beckenbauer — campion ca jucător (1974) și ca antrenor.",
  },
  1994: {
    context: "SUA, 17 iunie–17 iulie. Același drum ca în 1986, reguli noi: 3 puncte la victorie, fără pasă înapoi prinsă de portar, galbenele șterse după grupe. Germania joacă reunificată, Rusia în locul URSS.",
    moments: [
      "România 3–1 Columbia (Hagi, de la mare distanță). Andrés Escobar, după un autogol cu SUA, e ucis la întoarcere.",
      "Rusia 6–1 Camerun: Oleg Salenko, 5 goluri într-un meci; Roger Milla, 42 de ani, cel mai vârstnic marcator.",
      "Maradona e exclus după un control pozitiv; România 3–2 Argentina în optimi.",
      "Bulgaria 2–1 Germania în sferturi (Stoichkov, Letchkov).",
      "România 2–2 Suedia, eliminată la penalty-uri în sferturi — cel mai bun parcurs românesc.",
    ],
    final: "Brazilia 0–0 Italia după prelungiri, 3–2 la penalty-uri, la Pasadena. Prima finală fără gol; Roberto Baggio trimite peste poartă.",
    coach: "Carlos Alberto Parreira (Brazilia).",
  },
  1998: {
    context: "Franța, 10 iunie–12 iulie. Prima ediție cu 32 de echipe: 8 grupe, doar primele 2 trec. 3 schimbări și gol de aur în prelungiri. Croația debutează ca stat independent.",
    moments: [
      "România 2–1 Anglia (Moldovan, Petrescu) și primul loc în grupă; iese în optimi cu Croația (Šuker).",
      "Franța 1–0 Paraguay: primul gol de aur la un Mondial, Laurent Blanc, minutul 114.",
      "Argentina 2–2 Anglia, 4–3 la penalty-uri: golul lui Owen, eliminarea lui Beckham.",
      "Croația 3–0 Germania în sferturi; apoi bronz la prima participare.",
      "Franța 2–1 Croația: Thuram, singurele lui două goluri la națională.",
    ],
    final: "Franța 3–0 Brazilia la Stade de France (Zidane 2, Petit). Ronaldo joacă după o noapte medicală neclară.",
    coach: "Aimé Jacquet (Franța).",
  },
  2002: {
    context: "Coreea de Sud și Japonia, 31 mai–30 iunie. Primul Mondial în Asia și primul cu două gazde. Lot de 23. Ultima ediție cu gol de aur. Debut: China, Ecuador, Senegal, Slovenia.",
    moments: [
      "Senegal 1–0 Franța la deschidere: campioana iese fără gol marcat.",
      "Brazilia 2–1 Turcia: penalty-ul lui Rivaldo și simularea lui la aruncarea mingii.",
      "Coreea de Sud 2–1 Italia, gol de aur (Ahn Jung-hwan), apoi victorie la penalty-uri cu Spania — arbitraje contestate.",
      "Senegal și Turcia trec de sferturi cu goluri de aur; Turcia se oprește în semifinală.",
      "Hakan Șükür marchează după 11 secunde în meciul pentru locul 3 — cel mai rapid gol din istoria Mondialelor.",
    ],
    final: "Brazilia 2–0 Germania la Yokohama (Ronaldo 2). Al cincilea titlu; Ronaldo, 8 goluri, închide povestea din 1998.",
    coach: "Luiz Felipe Scolari (Brazilia).",
  },
  2006: {
    context: "Germania, 9 iunie–9 iulie. Golul de aur dispare: prelungiri complete, apoi penalty-uri. Serbia și Muntenegru joacă ultimul turneu împreună. Debut: Angola, Coasta de Fildeș, Ghana, Togo, Trinidad-Tobago, Ucraina.",
    moments: [
      "Argentina 6–0 Serbia-Muntenegru: golul lui Cambiasso, după o acțiune cu peste 20 de pase.",
      "Portugalia 1–0 Olanda: „Bătălia de la Nürnberg”, 16 galbene și 4 roșii.",
      "Elveția iese în optimi fără să fi primit vreun gol.",
      "Italia 2–0 Germania după prelungiri, la Dortmund (Grosso 119, Del Piero).",
    ],
    final: "Italia 1–1 Franța după prelungiri, 5–3 la penalty-uri, la Berlin (Materazzi; Zidane, penalty Panenka). Zidane e eliminat după lovitura de cap; Trezeguet lovește bara.",
    coach: "Marcello Lippi (Italia).",
  },
  2010: {
    context: "Africa de Sud, 11 iunie–11 iulie. Primul Mondial în Africa. Africa de Sud devine prima gazdă eliminată din grupe. Franța se prăbușește după revolta din vestiar.",
    moments: [
      "Elveția 1–0 Spania: favorita pierde la debut.",
      "Slovacia 3–2 Italia: campioana iese din grupă; Noua Zeelandă pleacă neînvinsă.",
      "Germania 4–1 Anglia: golul lui Lampard, peste linie, nevalidat.",
      "Uruguay–Ghana: Suárez oprește cu mâna în minutul 120, Gyan ratează penalty-ul, Uruguay trece la lovituri de departajare.",
    ],
    final: "Spania 1–0 Olanda după prelungiri, la Johannesburg (Iniesta 116). 14 galbene; primul titlu al Spaniei.",
    coach: "Vicente del Bosque (Spania).",
  },
  2014: {
    context: "Brazilia, 12 iunie–13 iulie. Prima ediție cu tehnologie pe linia porții. Debut: Bosnia-Herțegovina.",
    moments: [
      "Spania 1–5 Olanda (plonjonul lui Van Persie): campioana iese după două meciuri.",
      "Costa Rica câștigă grupa cu Uruguay, Italia și Anglia.",
      "Columbia 2–0 Uruguay: golul turneului, James Rodríguez.",
      "Olanda–Costa Rica: Van Gaal îl aduce pe Krul doar pentru penalty-uri.",
      "Germania 7–1 Brazilia în semifinală, 5–0 la pauză; Klose ajunge la 16 goluri, record all-time.",
    ],
    final: "Germania 1–0 Argentina după prelungiri, la Maracanã (Götze 113). Prima europeană campioană în America.",
    coach: "Joachim Löw (Germania).",
  },
  2018: {
    context: "Rusia, 14 iunie–15 iulie. Prima ediție cu VAR și cu a patra schimbare în prelungiri. Debut: Islanda, Panama.",
    moments: [
      "Portugalia 3–3 Spania: hat-trick Cristiano Ronaldo.",
      "Franța 2–1 Australia: primul penalty acordat prin VAR la un Mondial.",
      "Coreea de Sud 2–0 Germania: campioana iese din grupă.",
      "Japonia trece de Senegal la fair-play: aceleași puncte și goluri, mai puține cartonașe.",
      "Franța 4–3 Argentina în optimi (Pavard, Mbappé 2).",
    ],
    final: "Franța 4–2 Croația la Moscova (autogol Mandžukić, Griezmann pen., Pogba, Mbappé; Perišić, Mandžukić).",
    coach: "Didier Deschamps — al treilea campion ca jucător și ca antrenor.",
  },
  2022: {
    context: "Qatar, 20 noiembrie–18 decembrie. Prima iarnă și primul Mondial în lumea arabă. Lot de 26, 5 schimbări, ofsaid semi-automat, timp adăugat mult mai lung. Ultima ediție cu 32 de echipe.",
    moments: [
      "Arabia Saudită 2–1 Argentina: șocul turneului.",
      "Japonia bate Germania și Spania; Germania iese din nou din grupă.",
      "Polonia trece de Mexic la diferența de goluri.",
      "Maroc elimină Spania și Portugalia: prima echipă africană în semifinale.",
      "Croația elimină Brazilia la penalty-uri în sferturi.",
    ],
    final: "Argentina 3–3 Franța după prelungiri, 4–2 la penalty-uri, la Lusail (Messi 2, Di María; Mbappé 3). Mbappé, hat-trick într-o finală pierdută; Messi, campion și cel mai bun jucător.",
    coach: "Lionel Scaloni (Argentina).",
  },
  2026: {
    context: "Canada, Mexic și SUA, 11 iunie–19 iulie. Prima ediție cu 48 de echipe și trei gazde: 104 meciuri în 16 orașe, un tur nou (șaisprezecimile) și 8 meciuri pentru campioană. Reguli noi de ritm: limită la ținerea mingii de către portar, 5 secunde la aut și la lovitura de poartă, 10 secunde la ieșirea jucătorului schimbat.",
    moments: [
      "Spania începe cu 0–0 cu Capul Verde, apoi nu mai pierde.",
      "Germania (cu Paraguay) și Olanda (cu Maroc) ies în șaisprezecimi la penalty-uri.",
      "Norvegia 2–1 Brazilia în optimi.",
      "Argentina 2–1 Anglia în semifinală, cu două goluri în ultimele minute.",
      "Anglia 6–4 Franța în finala mică, hat-trick Bukayo Saka.",
    ],
    final: "Spania 1–0 Argentina după prelungiri, la MetLife (Ferran Torres 106). Argentina termină în 10 după eliminarea lui Enzo Fernández. Al doilea titlu al Spaniei.",
    coach: "Luis de la Fuente (Spania).",
  },
};

if (typeof module !== "undefined" && module.exports) {
  module.exports = { RULES_TIMELINE, SQUAD_RULES, FORMAT_FAMILIES, TITLE_PATH, STORIES };
}
