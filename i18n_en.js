/* ============================================================
   ARHIVA MONDIALELOR — i18n_en.js
   English content for the iOS app (Data_en.json). The web prototype
   stays in Romanian; tools/export_ios_data.js overlays these texts on
   the Romanian data (same structure, same order — the engine never
   reads them, so the simulation is identical in both languages).
   ============================================================ */

const EN = {};

/* ---------- Editions ---------- */
EN.editions = {
  1930: { host: "Uruguay", topScorer: "Guillermo Stábile (ARG) — 8", note: "The first edition. A special format: 4 groups, no real quarter-finals." },
  1934: { host: "Italy", topScorer: "Oldřich Nejedlý (TCH) — 5", note: "The first pure knockout edition (no groups)." },
  1938: { host: "France", topScorer: "Leônidas (BRA) — 7", note: "Italy become the first champions to defend their title." },
  1950: { host: "Brazil", topScorer: "Ademir (BRA) — 8", note: "\"Maracanazo\": Uruguay beat Brazil 2-1 in front of ~200,000 spectators." },
  1954: { host: "Switzerland", topScorer: "Sándor Kocsis (HUN) — 11", note: "\"The Miracle of Bern\": West Germany beat Puskás's great Hungary." },
  1958: { host: "Sweden", topScorer: "Just Fontaine (FRA) — 13", note: "Pelé's debut at 17 — Brazil's first title." },
  1962: { host: "Chile", topScorer: "6 players — 4 goals", note: "Brazil defend their title, with Garrincha in the spotlight." },
  1966: { host: "England", topScorer: "Eusébio (POR) — 9", note: "England win at home; the Jules Rimet trophy is stolen and found by a dog called Pickles." },
  1970: { host: "Mexico", topScorer: "Gerd Müller (GER) — 10", note: "Often called the greatest team ever — a third title, and Brazil keep the Jules Rimet trophy for good." },
  1974: { host: "West Germany", topScorer: "Grzegorz Lato (POL) — 7", note: "West Germany beat the \"Total Football\" of Cruyff's Netherlands." },
  1978: { host: "Argentina", topScorer: "Mario Kempes (ARG) — 6", note: "Argentina win their first title, at home." },
  1982: { host: "Spain", topScorer: "Paolo Rossi (ITA) — 6", note: "Italy's third title, with a revived Paolo Rossi." },
  1986: { host: "Mexico", topScorer: "Gary Lineker (ENG) — 6", note: "\"The Hand of God\" and the Goal of the Century — Maradona at his peak." },
  1990: { host: "Italy", topScorer: "Salvatore Schillaci (ITA) — 6", note: "West Germany take revenge for the previous final." },
  1994: { host: "USA", topScorer: "Hristo Stoichkov / Oleg Salenko — 6", note: "Brazil win on penalties, the first final decided that way." },
  1998: { host: "France", topScorer: "Davor Šuker (CRO) — 6", note: "Zidane's France win their first title, at home." },
  2002: { host: "South Korea / Japan", topScorer: "Ronaldo (BRA) — 8", note: "Brazil's fifth title — Ronaldo's comeback after his injuries." },
  2006: { host: "Germany", topScorer: "Miroslav Klose (GER) — 5", note: "Italy win on penalties; the final is remembered for Zidane's headbutt." },
  2010: { host: "South Africa", topScorer: "Thomas Müller (GER) — 5", note: "Spain's first title, the golden tiki-taka generation." },
  2014: { host: "Brazil", topScorer: "James Rodríguez (COL) — 6", note: "Germany 7-1 Brazil in the semi-final — Germany's fourth title." },
  2018: { host: "Russia", topScorer: "Harry Kane (ENG) — 6", note: "Mbappé and Griezmann's France win a second title." },
  2022: { host: "Qatar", topScorer: "Kylian Mbappé (FRA) — 8", note: "Messi's Argentina win a third title after a historic 3-3 final with France (4-2 on penalties)." },
  2026: { host: "Canada / Mexico / USA", topScorer: "Kylian Mbappé (FRA) — 10", note: "The first edition with 48 teams and a round of 32. Spain beat Argentina 1-0 after extra time for their second title; England take bronze after a 6-4 win over France." },
};

/* ---------- Format of each edition ---------- */
EN.formatSummary = {
  1930: "13 teams, no qualifying. 4 groups (one of 4, three of 3); only the group winner goes through. Semi-finals and final. No round of 16, quarter-finals or third place. 2/1/0 points, no cards.",
  1934: "16 teams, the first edition with qualifying. No groups: round of 16, quarter-finals, semi-finals, third place, final. Level after extra time: a replay. No cards.",
  1938: "15 teams (Austria withdrew after the Anschluss; Sweden got a bye in the round of 16). No groups: round of 16, quarter-finals, semi-finals, third place, final. Level after extra time: a replay. No cards.",
  1950: "13 teams (withdrawals). 4 unequal groups; the winners go into a final group of 4, played as a round robin — the team on top is champion. No round of 16, quarter-finals, semi-finals or separate final. 2/1/0 points.",
  1954: "16 teams. 4 groups of 4, but the seeds only play the unseeded teams (2 matches). The top 2 go through; level on points means a play-off. Group matches level after 90 minutes also go to extra time. Quarter-finals, semi-finals, third place, final. 2/1/0 points, no cards, no substitutions.",
  1958: "16 teams. 4 groups of 4, full round robin; the top 2 go through, a play-off if level on points. Quarter-finals, semi-finals, third place, final. 2/1/0 points, no cards.",
  1962: "16 teams. 4 groups of 4; the top 2 go through, separated by goal average. Quarter-finals, semi-finals, third place, final. 2/1/0 points, no cards.",
  1966: "16 teams. 4 groups of 4; the top 2 go through, separated by goal average. Quarter-finals, semi-finals, third place, final. 2/1/0 points, no cards.",
  1970: "16 teams. 4 groups of 4; the top 2 go through, separated by goal difference (not average). Quarter-finals, semi-finals, third place, final. 2/1/0 points. The first edition with yellow and red cards and with substitutions (2 per match).",
  1974: "16 teams. 4 groups of 4 (top 2 go through), then 2 groups of 4: the winners play the final, the runners-up play for third place. No classic round of 16, quarter-finals or semi-finals. 2/1/0 points, 2 substitutions; penalty shoot-outs enter the rules. The first red card in World Cup history.",
  1978: "The same format as 1974: 4 groups, then 2 groups of 4, then third place and the final. No classic round of 16, quarter-finals or semi-finals. 2/1/0 points, cards in use.",
  1982: "24 teams, the first expansion. 6 groups of 4 (top 2 go through), then 4 groups of 3 — the winners reach the semi-finals. Semi-finals, third place, final. 2/1/0 points, cards in use.",
  1986: "24 teams. 6 groups; the top 2 plus the 4 best third-placed teams go through. Round of 16, quarter-finals, semi-finals, third place, final — the first modern edition with a round of 16 after the groups. 2/1/0 points, cards in use.",
  1990: "The same format as 1986: 6 groups, top 2 + 4 third-placed teams, then round of 16, quarter-finals, semi-finals, third place, final. The last edition with 2 points for a win; two yellow cards anywhere in the tournament meant a suspension, even late on.",
  1994: "24 teams, the same path as 1986/1990. New points system: 3/1/0. Group-stage yellow cards are wiped for the knockouts. 2 substitutions + one more for an injured goalkeeper.",
  1998: "32 teams. 8 groups of 4, the top 2 go through. Round of 16, quarter-finals, semi-finals, third place, final. 3/1/0 points, yellow cards wiped after the groups. 3 substitutions; golden goal in extra time.",
  2002: "32 teams, the first World Cup in Asia and the first with two hosts. 8 groups of 4, the top 2 go through; round of 16, quarter-finals, semi-finals, third place, final. 3/1/0 points, 3 substitutions, 23-man squads. The last edition with the golden goal.",
  2006: "32 teams, 8 groups of 4; round of 16, quarter-finals, semi-finals, third place, final. The golden goal is gone: full extra time (2×15), then penalties. 3 substitutions, 23-man squads.",
  2010: "32 teams, 8 groups of 4; round of 16, quarter-finals, semi-finals, third place, final. 3/1/0 points, 3 substitutions, full extra time then penalties.",
  2014: "32 teams, 8 groups of 4; round of 16, quarter-finals, semi-finals, third place, final. 3 substitutions. The first edition with goal-line technology.",
  2018: "32 teams, 8 groups of 4; round of 16, quarter-finals, semi-finals, third place, final. The first edition with VAR. 3 substitutions + a 4th in extra time; if completely level in a group, fair play (cards) decides.",
  2022: "32 teams, the last edition in this format; the first in winter. 5 substitutions + one in extra time, 26-man squads, VAR and semi-automated offside. Fair play also used as a tiebreaker.",
  2026: "48 teams. 12 groups of 4; the top 2 plus the 8 best third-placed teams go through (32 teams). Round of 32, round of 16, quarter-finals, semi-finals, third place, final. 3/1/0 points, yellow cards wiped after the groups. 5 substitutions + one in extra time; fair play also used as a tiebreaker.",
};

/* ---------- Team names (curated teams + historical opponents) ---------- */
EN.teams = {
  BRA: "Brazil", ARG: "Argentina", GER: "Germany", ITA: "Italy", URU: "Uruguay", ENG: "England", FRA: "France",
  NED: "Netherlands", HUN: "Hungary", ESP: "Spain", POR: "Portugal", SWE: "Sweden", BEL: "Belgium", CRO: "Croatia",
  POL: "Poland", TCH: "Czechoslovakia", MEX: "Mexico", USA: "USA", JPN: "Japan", MAR: "Morocco", KOR: "South Korea",
  TUR: "Turkey", AUT: "Austria",
  PER: "Peru", ROU: "Romania", YUG: "Yugoslavia", BUL: "Bulgaria", UAE: "United Arab Emirates", COL: "Colombia",
  RSA: "South Africa", KSA: "Saudi Arabia", DEN: "Denmark", PAR: "Paraguay", CHN: "China", CRC: "Costa Rica",
  GHA: "Ghana", ALG: "Algeria", AUS: "Australia", RUS: "Russia", TUN: "Tunisia", SUI: "Switzerland", CHI: "Chile",
  ANG: "Angola", BIH: "Bosnia and Herzegovina", BOL: "Bolivia", CAN: "Canada", CIV: "Ivory Coast", CMR: "Cameroon",
  CUB: "Cuba", CZE: "Czech Republic", DEI: "Dutch East Indies", ECU: "Ecuador", EGY: "Egypt", GDR: "East Germany",
  GRE: "Greece", HAI: "Haiti", HON: "Honduras", IRL: "Republic of Ireland", IRN: "Iran", IRQ: "Iraq", ISL: "Iceland",
  ISR: "Israel", JAM: "Jamaica", KUW: "Kuwait", NGA: "Nigeria", NIR: "Northern Ireland", NOR: "Norway",
  NZL: "New Zealand", PAN: "Panama", PRK: "North Korea", QAT: "Qatar", SCG: "Serbia and Montenegro", SCO: "Scotland",
  SEN: "Senegal", SLV: "El Salvador", SRB: "Serbia", SVK: "Slovakia", SVN: "Slovenia", TOG: "Togo",
  TRI: "Trinidad and Tobago", UKR: "Ukraine", URS: "Soviet Union", WAL: "Wales", ZAI: "Zaire",
  COD: "DR Congo", CPV: "Cape Verde", CUW: "Curaçao", JOR: "Jordan", UZB: "Uzbekistan",
};

/* ---------- Legends ---------- */
EN.legends = {
  PELE: "The only player with 3 World Cup titles (1958, 1962, 1970). \"O Rei\" — a legendary goalscorer and the symbol of Brazilian football.",
  MARADONA: "Won the World Cup almost single-handedly in 1986 — \"The Hand of God\" and \"The Goal of the Century\", both in the same match.",
  BECKENBAUER: "\"Der Kaiser\" — reinvented the role of the sweeper (libero); world champion as a player (1974) and as a coach (1990).",
  CRUYFF: "The symbol of Dutch \"Total Football\" — a finalist in 1974 and one of the most influential tactical figures in history.",
  ZIDANE: "Hero of the 1998 title (two goals in the final) and a finalist in 2006 — one of the most elegant midfielders ever.",
  MESSI: "Finally won the World Cup in 2022, in Qatar, crowning a career with eight Ballon d'Or awards.",
  RONALDOBR: "\"The Phenomenon\" — scored twice in the 2002 final, back from serious injuries to win Brazil's fifth title.",
  MULLERG: "West Germany's World Cup record scorer of his era — 10 goals in 1970 and the winning goal in the 1974 final.",
  PUSKAS: "Captain of the \"Golden Team\" of Hungary, finalists in 1954 — one of the greatest goalscorers in football history.",
  DISTEFANO: "The Real Madrid legend never played at a World Cup finals — included here as a tribute to his era.",
  PLATINI: "Captain and conductor of France's \"Carré Magique\" in the 1980s — a semi-finalist in 1982 and 1986.",
  EUSEBIO: "\"The Black Panther\" — top scorer at the 1966 World Cup (9 goals) and the driving force behind Portugal's best-ever finish.",
  CR7: "Played at five consecutive editions (2006-2022) — a memorable hat-trick against Spain in 2018.",
  KAKA: "Ballon d'Or 2007 — part of Brazil's 2002 winning squad at just 20.",
  INIESTA: "Scored the winning goal in the 2010 final — the symbol of Spain's golden generation.",
  KLOSE: "The all-time top scorer at World Cups (16 goals, 2002-2014) — world champion in 2014.",
  STABILE: "Top scorer at the very first World Cup (1930), with Argentina reaching the final.",
  FONTAINE: "The all-time record for goals at a single edition — 13 goals in 1958, still unmatched.",
};

/* ---------- Rules through the years ---------- */
EN.rulesTimeline = [
  { years: "1930–1966", title: "Eleven of iron",
    items: [
      "No substitutions: an injured player stayed on the pitch or the team played on with 10.",
      "No cards: cautions and sendings-off were given verbally.",
      "Draws in knockout ties (1934, 1938): extra time, then a replay. 1954–1970: extra time, then drawing lots (never needed at a finals).",
      "The goalkeeper could pick up a back pass from a team-mate.",
      "Group tiebreakers: a play-off (1954, 1958), goal average (1962, 1966).",
    ] },
  { years: "1970", title: "The first break — Mexico",
    items: [
      "Yellow and red cards arrive. The first yellow: Evgeny Lovchev (USSR), in the opening match (some sources name Kakhi Asatiani). Not a single red in the whole tournament.",
      "2 substitutions per match are allowed. The first in World Cup history: Anatoliy Puzach for Viktor Serebryanikov (USSR), at half-time of the opening match.",
      "Goal difference replaces goal average as the tiebreaker.",
    ] },
  { years: "1974–1978", title: "Red cards and penalties",
    items: [
      "1974: the first red card — Carlos Caszely (Chile), against West Germany.",
      "Penalty shoot-outs enter the rules instead of replays. The first shoot-out at a World Cup comes only in 1982 (West Germany–France, semi-final).",
    ] },
  { years: "1982–1990", title: "Yellow cards that never go away",
    items: [
      "2 substitutions, 2 points for a win.",
      "Yellow cards add up over the whole tournament: two, anywhere, mean a suspension — even for the final.",
      "1986: the last group matches are played at the same time, after the \"Disgrace of Gijón\" in 1982.",
      "1990: a player level with the second-last defender is no longer offside.",
    ] },
  { years: "1994", title: "Three changes at once — USA",
    items: [
      "3 points for a win instead of 2.",
      "The goalkeeper can no longer pick up a deliberate back pass from a team-mate's foot.",
      "Group-stage yellow cards are wiped at the start of the knockouts.",
      "2 substitutions, plus one more for an injured goalkeeper.",
    ] },
  { years: "1998–2002", title: "The golden goal",
    items: [
      "3 substitutions per match; 32 teams from 1998.",
      "The golden goal: the first goal in extra time ends the match. Dropped after 2004 — it encouraged caution, not attack.",
      "2002: squads grow to 23 (a third goalkeeper).",
    ] },
  { years: "2006–2014", title: "Full extra time",
    items: [
      "No golden goal: 2×15 minutes, then penalties.",
      "2010: Lampard's disallowed goal (England–Germany) speeds up goal-line technology.",
      "2014: goal-line technology used at a World Cup for the first time.",
    ] },
  { years: "2018", title: "VAR",
    items: [
      "The first use of video refereeing at a World Cup; offside starts being checked on video.",
      "3 substitutions + a 4th in extra time.",
      "If completely level in a group, fair play decides: Japan go through ahead of Senegal with fewer cards.",
    ] },
  { years: "2022", title: "Five substitutions — Qatar",
    items: [
      "5 substitutions + one in extra time + extra changes for suspected concussion.",
      "26-man squads, at least 3 goalkeepers.",
      "VAR with semi-automated offside; added time calculated much more strictly.",
    ] },
  { years: "2026", title: "Keeping the pace — Canada / Mexico / USA",
    items: [
      "48 teams; 5 substitutions + one in extra time + concussion subs; 3/1/0 points.",
      "The goalkeeper has a visible time limit with the ball in hand (otherwise a corner to the opponents).",
      "A 5-second count for throw-ins and goal kicks; a substituted player has 10 seconds to leave the pitch.",
      "Finer VAR offside calls (3D avatar); tougher sanctions for serious protests.",
    ] },
];

EN.squadRules = [
  { years: "1930–1998", size: "22", text: "With no substitutions until 1970, the squad was cover for injuries and travel, not a tactical bench." },
  { years: "2002–2018", size: "23", text: "The 23rd man is almost always the third goalkeeper." },
  { years: "2022–2026", size: "26", text: "At least 3 goalkeepers. With 5 substitutions, a squad needs two compatible starting elevens. In 2026: a preliminary list of 35–55 names, the final list 10 days before the start, replacements only for injury or illness." },
];

EN.families = [
  { years: "1930", text: "Short groups → semi-finals → final. No third place." },
  { years: "1934–1938", text: "All knockout, from the round of 16." },
  { years: "1950", text: "Groups → a final group of 4, no actual final." },
  { years: "1954–1970", text: "4 groups of 4 → quarter-finals." },
  { years: "1974–1982", text: "Two group stages (1982: then semi-finals)." },
  { years: "1986–2022", text: "Groups → round of 16 (24, then 32 teams)." },
  { years: "2026", text: "12 groups → round of 32 (48 teams)." },
];

EN.titlePath = [
  { years: "1930", games: "4" }, { years: "1934–1938", games: "4–5 (with replays)" }, { years: "1950", games: "6" },
  { years: "1954", games: "5–6" }, { years: "1958–1970", games: "6" }, { years: "1974–2022", games: "7" }, { years: "2026", games: "8" },
];

/* ---------- The story of each edition ---------- */
EN.stories = {
  1930: {
    context: "Uruguay, 13–30 July. The first edition, the only one without qualifying and the only one played entirely in one city: Montevideo. The country was celebrating 100 years since its first constitution and was double Olympic champion; it paid the teams' travel. Only 13 came: four from Europe (France, Belgium, Romania — with a squad picked by King Carol II — and Yugoslavia), by ship, together with Jules Rimet and the trophy.",
    moments: [
      "France 4–1 Mexico: the first goal in World Cup history, Lucien Laurent, 19th minute.",
      "USA 3–0 Paraguay: Bert Patenaude, the first hat-trick recognised by FIFA.",
      "Romania 3–1 Peru: Romania's first win at a World Cup.",
      "The Estadio Centenario opens 5 days late because of the rain.",
      "Argentina 6–1 USA in the semi-final: the American Raphael Tracey breaks his leg — with no substitutions, his team play on with 10.",
    ],
    final: "Uruguay 4–2 Argentina (Dorado, Peucelle, Stábile, Cea, Iriarte, Castro). One half with each team's ball; referee John Langenus asked for an escort. The next day was a national holiday in Uruguay.",
    coach: "Alberto Suppici (Uruguay), aged 28 — the youngest coach ever to win the World Cup.",
  },
  1934: {
    context: "Italy, 27 May–10 June. The first edition with qualifying (the hosts had to get past Greece) and the first in Europe. Uruguay, the champions, refused to come. Egypt become the first African team at a World Cup.",
    moments: [
      "All round-of-16 matches are played on the same day, at the same time.",
      "Argentina and Brazil go home after a single match; all the quarter-finalists are European.",
      "Italy 1–1 Spain in the quarter-final, then 1–0 in the replay the next day, without their injured goalkeeper Zamora.",
      "Germany 3–2 Austria: the first third-place match in history.",
    ],
    final: "Italy 2–1 Czechoslovakia after extra time (Puč; Orsi, Schiavio), in Rome. The first European champions.",
    coach: "Vittorio Pozzo (Italy).",
  },
  1938: {
    context: "France, 4–19 June. Qualified Austria disappear after the Anschluss — Sweden, their opponents, go straight into the quarter-finals, so there are 15 teams. Spain are missing because of the civil war; Argentina and Uruguay stay away. Cuba and the Dutch East Indies (today Indonesia) make their debut.",
    moments: [
      "Cuba 3–3 Romania, then 2–1 in the replay: Romania go out in the round of 16.",
      "Switzerland 4–2 Germany in a replay — Germany, with Austrian players, go out in the first round.",
      "Brazil 6–5 Poland after extra time, with four goals from Leônidas.",
      "Brazil 2–1 Czechoslovakia in the quarter-final replay; Leônidas then misses the semi-final lost to Italy.",
    ],
    final: "Italy 4–2 Hungary (Colaussi 2, Piola 2; Titkos, Sárosi), at Colombes. The first champions to defend their title.",
    coach: "Vittorio Pozzo — the only coach with two titles in a row.",
  },
  1950: {
    context: "Brazil, 24 June–16 July. The first World Cup after the war (1942 and 1946 were not held). Of 16 qualified teams, 13 remained; Germany and Japan were suspended. The Maracanã was built for the tournament. A unique format: groups, then a final group of 4 — no actual final.",
    moments: [
      "USA 1–0 England in Belo Horizonte (Gaetjens) — England's World Cup debut ends in one of the greatest upsets ever.",
      "Italy, the holders, weakened after the Superga air disaster, go out in the group against Sweden.",
      "Uruguay play only one group match: 8–0 against Bolivia.",
      "Brazil 7–1 Sweden and 6–1 Spain in the final group: overwhelming favourites.",
    ],
    final: "The last match of the final group: Uruguay 2–1 Brazil (Friaça; Schiaffino, Ghiggia), in front of more than 170,000 people — the \"Maracanaço\". A draw would have been enough for Brazil.",
    coach: "Juan López (Uruguay); captain Obdulio Varela.",
  },
  1954: {
    context: "Switzerland, 16 June–4 July. \"The World Cup of goals\": 140 in 26 matches, 5.38 per game — a record. Puskás, Kocsis and Hidegkuti's Hungary arrived unbeaten in more than 30 matches. In the groups, the seeds only played the unseeded teams, and drawn matches went to extra time.",
    moments: [
      "Hungary 8–3 West Germany in the group: Herberger rests his starters; West Germany then beat Turkey in a play-off (7–2).",
      "Austria 7–5 Switzerland in the quarter-final: the highest-scoring match in World Cup history.",
      "Hungary 4–2 Brazil: the \"Battle of Bern\", with three verbal sendings-off.",
      "Hungary 4–2 Uruguay after extra time: Uruguay's first ever World Cup defeat.",
    ],
    final: "West Germany 3–2 Hungary in Bern (Puskás, Czibor; Morlock, Rahn 2), after being 0–2 down within 8 minutes — \"The Miracle of Bern\". The first team to lose a match at the tournament and still lift the Cup.",
    coach: "Sepp Herberger (West Germany).",
  },
  1958: {
    context: "Sweden, 8–29 June. The groups become full round robins, and a tie on points for second place means a play-off — three were played. The USSR, Wales and Northern Ireland make their debut; Italy are missing.",
    moments: [
      "The play-offs: Northern Ireland, Wales and the USSR get past Czechoslovakia, Hungary and England.",
      "Pelé, 17, only starts from the third match; he scores in the quarter-final (1–0 against Wales), then a hat-trick against France.",
      "Just Fontaine: 13 goals, including 4 in the third-place match (France 6–3 West Germany). The record still stands.",
    ],
    final: "Brazil 5–2 Sweden in Stockholm (Vavá 2, Pelé 2, Zagallo; Liedholm, Simonsson). Brazil's first title.",
    coach: "Vicente Feola (Brazil).",
  },
  1962: {
    context: "Chile, 30 May–17 June, after the devastating 1960 earthquake: \"Because we have nothing, we will do everything\" (Carlos Dittborn, who died a month before kick-off). Group tiebreaker: goal average.",
    moments: [
      "Chile 2–0 Italy: the \"Battle of Santiago\", refereed by Ken Aston — the future inventor of cards.",
      "Pelé is injured in the second match; with no substitutions, Amarildo replaces him in the team from the next match.",
      "Garrincha carries Brazil through the quarter-final and semi-final; sent off against Chile, he is allowed to play the final.",
      "Chile 1–0 Yugoslavia: the hosts on the podium.",
    ],
    final: "Brazil 3–1 Czechoslovakia (Masopust; Amarildo, Zito, Vavá). The second team to defend their title.",
    coach: "Aymoré Moreira (Brazil).",
  },
  1966: {
    context: "England, 11–30 July. The Jules Rimet trophy is stolen before the tournament and found by a dog called Pickles. Portugal and North Korea make their debut. The tiebreaker is still goal average.",
    moments: [
      "Portugal and Hungary knock Brazil out in the group; Pelé is kicked mercilessly.",
      "North Korea 1–0 Italy (Pak Doo-ik): Italy are met with tomatoes at home.",
      "Portugal 5–3 North Korea after being 0–3 down: Eusébio scores 4.",
      "England 1–0 Argentina: Rattín, sent off, refuses to leave — the idea of cards is born here.",
    ],
    final: "England 4–2 West Germany after extra time at Wembley (Haller, Weber; Hurst 3, Peters). The 3–2 \"was it in?\" goal; Hurst, the only hat-trick in a final until 2022.",
    coach: "Alf Ramsey (England) — the \"wingless wonders\".",
  },
  1970: {
    context: "Mexico, 31 May–21 June. Heat, altitude, midday kick-offs for European television and the first large-scale colour broadcasts. The rules change, not the format: cards, 2 substitutions, goal difference.",
    moments: [
      "Mexico 0–0 USSR: the first yellow card and the first substitution in World Cup history.",
      "Brazil 1–0 England: Gordon Banks's save from Pelé's header.",
      "Brazil 3–2 Romania: two goals for Pelé.",
      "Italy 4–3 West Germany after extra time: \"The Game of the Century\", with 5 goals in extra time and Beckenbauer playing with his arm in a sling.",
    ],
    final: "Brazil 4–1 Italy at the Azteca (Pelé, Gérson, Jairzinho, Carlos Alberto; Boninsegna). A third title, and Brazil keep the Jules Rimet trophy for good. Jairzinho scored in every match.",
    coach: "Mário Zagallo — the first to win the World Cup as a player and as a coach.",
  },
  1974: {
    context: "West Germany, 13 June–7 July. The new FIFA trophy replaces the Jules Rimet. The structure changes: two group stages, no classic quarter-finals and semi-finals. Debuts: Australia, East Germany, Haiti, Zaire.",
    moments: [
      "West Germany 1–0 Chile: Carlos Caszely, the first red card in World Cup history.",
      "East Germany 1–0 West Germany (Sparwasser), the only match ever between the two Germanies.",
      "Scotland go out unbeaten, on goal difference.",
      "Netherlands 2–0 Brazil in the second group stage: \"Total Football\" beats the holders.",
      "West Germany 1–0 Poland in the rain in Frankfurt — the match that decides the finalist.",
    ],
    final: "West Germany 2–1 Netherlands in Munich (Neeskens pen.; Breitner pen., Müller). The Dutch lead before a German has touched the ball.",
    coach: "Helmut Schön (West Germany).",
  },
  1978: {
    context: "Argentina, 1–25 June, under the military junta. The same format as 1974. Cruyff does not come. Debuts: Iran and Tunisia.",
    moments: [
      "Tunisia 3–1 Mexico: the first African win at a World Cup.",
      "Scotland 3–2 Netherlands (Gemmill's goal) and still out on goal difference.",
      "Austria 3–2 West Germany: the holders go home without a medal.",
      "Argentina 6–0 Peru: they needed to win by 4 goals to finish ahead of Brazil. A match still disputed today.",
      "Brazil finish as the only unbeaten team, in third place.",
    ],
    final: "Argentina 3–1 Netherlands after extra time at the Monumental (Kempes 2, Bertoni; Nanninga). The Dutch hit the post in the 90th minute.",
    coach: "César Luis Menotti (Argentina).",
  },
  1982: {
    context: "Spain, 13 June–11 July. The first edition with 24 teams: 6 groups, then 4 groups of 3, then semi-finals. Debuts: Algeria, Cameroon, Honduras, Kuwait, New Zealand.",
    moments: [
      "Algeria 2–1 West Germany, then West Germany 1–0 Austria — the \"Disgrace of Gijón\" sends Algeria home and leads to simultaneous final group matches.",
      "Hungary 10–1 El Salvador: the biggest score in World Cup history.",
      "Italy 3–2 Brazil: a Paolo Rossi hat-trick; Zico and Sócrates's Brazil only needed a draw.",
      "West Germany 3–3 France, 5–4 on penalties: the first shoot-out at a World Cup; Schumacher flattens Battiston without punishment.",
    ],
    final: "Italy 3–1 West Germany at the Bernabéu (Rossi, Tardelli, Altobelli; Breitner). Tardelli's scream; Zoff lifts the trophy at 40.",
    coach: "Enzo Bearzot (Italy).",
  },
  1986: {
    context: "Mexico, 31 May–29 June. Colombia withdraw and Mexico step in, a year after the earthquake. The round of 16 returns: the top 2 plus the 4 best third-placed teams. The last group matches are played at the same time.",
    moments: [
      "Morocco win their group: the first African team to finish top.",
      "Denmark 6–1 Uruguay, then 1–5 against Spain in the round of 16 (Butragueño 4).",
      "Argentina 2–1 England: \"The Hand of God\" and \"The Goal of the Century\", four minutes apart.",
      "France 1–1 Brazil, 4–3 on penalties: Zico misses a penalty during the match, Sócrates and Platini in the shoot-out.",
    ],
    final: "Argentina 3–2 West Germany at the Azteca (Brown, Valdano, Burruchaga; Rummenigge, Völler). From 2–0 to 2–2, then Maradona's pass for Burruchaga.",
    coach: "Carlos Bilardo (Argentina).",
  },
  1990: {
    context: "Italy, 8 June–8 July. The lowest-scoring modern World Cup. The last edition with 2 points for a win; yellow cards add up over the whole tournament. Offside is relaxed: level is no longer offside.",
    moments: [
      "Cameroon 1–0 Argentina in the opening match, with 9 men. Roger Milla, 38, scores 4 goals off the bench.",
      "Romania 2–0 USSR (Lăcătuș 2) and 1–1 with Argentina; out in the round of 16 on penalties against Ireland.",
      "Argentina 1–0 Brazil in the round of 16: Caniggia, after Maradona's run.",
      "England 3–2 Cameroon after extra time: the Africans reach the quarter-finals.",
      "West Germany–England 1–1, 4–3 on penalties; Gascoigne cries after the yellow card that would have ruled him out of the final.",
    ],
    final: "West Germany 1–0 Argentina in Rome (Brehme, a penalty in the 85th minute). Two Argentines sent off.",
    coach: "Franz Beckenbauer — champion as a player (1974) and as a coach.",
  },
  1994: {
    context: "USA, 17 June–17 July. The same path as 1986, new rules: 3 points for a win, no back pass picked up by the goalkeeper, yellow cards wiped after the groups. Germany play reunified, Russia replace the USSR.",
    moments: [
      "Romania 3–1 Colombia (Hagi, from long range). Andrés Escobar, after an own goal against the USA, is killed back home.",
      "Russia 6–1 Cameroon: Oleg Salenko scores 5 in one match; Roger Milla, 42, the oldest scorer ever.",
      "Maradona is thrown out after a positive test; Romania beat Argentina 3–2 in the round of 16.",
      "Bulgaria 2–1 Germany in the quarter-final (Stoichkov, Letchkov).",
      "Romania 2–2 Sweden, out on penalties in the quarter-final — Romania's best-ever run.",
    ],
    final: "Brazil 0–0 Italy after extra time, 3–2 on penalties, in Pasadena. The first goalless final; Roberto Baggio blazes over.",
    coach: "Carlos Alberto Parreira (Brazil).",
  },
  1998: {
    context: "France, 10 June–12 July. The first edition with 32 teams: 8 groups, only the top 2 go through. 3 substitutions and the golden goal in extra time. Croatia make their debut as an independent state.",
    moments: [
      "Romania 2–1 England (Moldovan, Petrescu) and first place in the group; out in the round of 16 against Croatia (Šuker).",
      "France 1–0 Paraguay: the first golden goal at a World Cup, Laurent Blanc, 114th minute.",
      "Argentina 2–2 England, 4–3 on penalties: Owen's goal, Beckham's red card.",
      "Croatia 3–0 Germany in the quarter-final; then bronze at their first World Cup.",
      "France 2–1 Croatia: Thuram, his only two goals for his country.",
    ],
    final: "France 3–0 Brazil at the Stade de France (Zidane 2, Petit). Ronaldo plays after an unexplained night of medical trouble.",
    coach: "Aimé Jacquet (France).",
  },
  2002: {
    context: "South Korea and Japan, 31 May–30 June. The first World Cup in Asia and the first with two hosts. 23-man squads. The last edition with the golden goal. Debuts: China, Ecuador, Senegal, Slovenia.",
    moments: [
      "Senegal 1–0 France in the opening match: the holders go out without scoring a goal.",
      "Brazil 2–1 Turkey: Rivaldo's penalty and his play-acting at a throw of the ball.",
      "South Korea 2–1 Italy, golden goal (Ahn Jung-hwan), then a penalty win over Spain — disputed refereeing.",
      "Senegal and Turkey reach the quarter-finals with golden goals; Turkey stop in the semi-final.",
      "Hakan Şükür scores after 11 seconds in the third-place match — the fastest goal in World Cup history.",
    ],
    final: "Brazil 2–0 Germany in Yokohama (Ronaldo 2). A fifth title; Ronaldo, with 8 goals, closes the story of 1998.",
    coach: "Luiz Felipe Scolari (Brazil).",
  },
  2006: {
    context: "Germany, 9 June–9 July. The golden goal is gone: full extra time, then penalties. Serbia and Montenegro play their last tournament together. Debuts: Angola, Ivory Coast, Ghana, Togo, Trinidad and Tobago, Ukraine.",
    moments: [
      "Argentina 6–0 Serbia and Montenegro: Cambiasso's goal, after a move of more than 20 passes.",
      "Portugal 1–0 Netherlands: the \"Battle of Nuremberg\", 16 yellow cards and 4 reds.",
      "Switzerland go out in the round of 16 without conceding a goal.",
      "Italy 2–0 Germany after extra time, in Dortmund (Grosso 119, Del Piero).",
    ],
    final: "Italy 1–1 France after extra time, 5–3 on penalties, in Berlin (Materazzi; Zidane, a Panenka penalty). Zidane is sent off after the headbutt; Trezeguet hits the bar.",
    coach: "Marcello Lippi (Italy).",
  },
  2010: {
    context: "South Africa, 11 June–11 July. The first World Cup in Africa. South Africa become the first hosts knocked out in the group stage. France collapse after a dressing-room revolt.",
    moments: [
      "Switzerland 1–0 Spain: the favourites lose their opener.",
      "Slovakia 3–2 Italy: the holders go out in the group; New Zealand go home unbeaten.",
      "Germany 4–1 England: Lampard's goal, over the line, not given.",
      "Uruguay–Ghana: Suárez stops the ball with his hand in the 120th minute, Gyan misses the penalty, Uruguay win the shoot-out.",
    ],
    final: "Spain 1–0 Netherlands after extra time, in Johannesburg (Iniesta 116). 14 yellow cards; Spain's first title.",
    coach: "Vicente del Bosque (Spain).",
  },
  2014: {
    context: "Brazil, 12 June–13 July. The first edition with goal-line technology. Debut: Bosnia and Herzegovina.",
    moments: [
      "Spain 1–5 Netherlands (Van Persie's diving header): the holders are out after two matches.",
      "Costa Rica win a group with Uruguay, Italy and England.",
      "Colombia 2–0 Uruguay: the goal of the tournament, James Rodríguez.",
      "Netherlands–Costa Rica: Van Gaal brings on Krul just for the penalties.",
      "Germany 7–1 Brazil in the semi-final, 5–0 at half-time; Klose reaches 16 goals, the all-time record.",
    ],
    final: "Germany 1–0 Argentina after extra time, at the Maracanã (Götze 113). The first European champions in the Americas.",
    coach: "Joachim Löw (Germany).",
  },
  2018: {
    context: "Russia, 14 June–15 July. The first edition with VAR and a fourth substitution in extra time. Debuts: Iceland, Panama.",
    moments: [
      "Portugal 3–3 Spain: a Cristiano Ronaldo hat-trick.",
      "France 2–1 Australia: the first penalty awarded through VAR at a World Cup.",
      "South Korea 2–0 Germany: the holders go out in the group.",
      "Japan go through ahead of Senegal on fair play: same points and goals, fewer cards.",
      "France 4–3 Argentina in the round of 16 (Pavard, Mbappé 2).",
    ],
    final: "France 4–2 Croatia in Moscow (Mandžukić own goal, Griezmann pen., Pogba, Mbappé; Perišić, Mandžukić).",
    coach: "Didier Deschamps — the third to win as a player and as a coach.",
  },
  2022: {
    context: "Qatar, 20 November–18 December. The first winter World Cup and the first in the Arab world. 26-man squads, 5 substitutions, semi-automated offside, much longer added time. The last edition with 32 teams.",
    moments: [
      "Saudi Arabia 2–1 Argentina: the shock of the tournament.",
      "Japan beat Germany and Spain; Germany go out in the group again.",
      "Poland finish ahead of Mexico on goal difference.",
      "Morocco knock out Spain and Portugal: the first African team in a semi-final.",
      "Croatia knock Brazil out on penalties in the quarter-final.",
    ],
    final: "Argentina 3–3 France after extra time, 4–2 on penalties, at Lusail (Messi 2, Di María; Mbappé 3). Mbappé, a hat-trick in a lost final; Messi, champion and player of the tournament.",
    coach: "Lionel Scaloni (Argentina).",
  },
  2026: {
    context: "Canada, Mexico and the USA, 11 June–19 July. The first edition with 48 teams and three hosts: 104 matches in 16 cities, a new round (the round of 32) and 8 matches for the champions. New pace rules: a limit on the goalkeeper holding the ball, 5 seconds for throw-ins and goal kicks, 10 seconds for a substituted player to leave.",
    moments: [
      "Spain open with a 0–0 against Cape Verde, then never lose again.",
      "Germany (against Paraguay) and the Netherlands (against Morocco) go out in the round of 32 on penalties.",
      "Norway 2–1 Brazil in the round of 16.",
      "Argentina 2–1 England in the semi-final, with two late goals.",
      "England 6–4 France in the third-place match, a Bukayo Saka hat-trick.",
    ],
    final: "Spain 1–0 Argentina after extra time, at MetLife Stadium (Ferran Torres 106). Argentina finish with 10 men after Enzo Fernández is sent off. Spain's second title.",
    coach: "Luis de la Fuente (Spain).",
  },
};

/* ---------- Quiz ---------- */
EN.quiz = {
  finalScores: {
    1930: "4–2", 1934: "2–1 a.e.t.", 1938: "4–2", 1950: "2–1", 1954: "3–2", 1958: "5–2", 1962: "3–1",
    1966: "4–2 a.e.t.", 1970: "4–1", 1974: "2–1", 1978: "3–1 a.e.t.", 1982: "3–1", 1986: "3–2", 1990: "1–0",
    1994: "0–0, 3–2 on penalties", 1998: "3–0", 2002: "2–0", 2006: "1–1, 5–3 on penalties", 2010: "1–0 a.e.t.",
    2014: "1–0 a.e.t.", 2018: "4–2", 2022: "3–3, 4–2 on penalties", 2026: "1–0 a.e.t.",
  },
  surprises: {
    1930: ["What happened with the ball in the 1930 final?", "Each half was played with one team's ball", "They played with a ball FIFA brought from Europe", "The ball burst and the match was restarted", "The whole match was played with the hosts' ball"],
    1934: ["Which reigning champions refused to come to the 1934 World Cup?", "Uruguay", "Brazil", "Argentina", "England"],
    1938: ["Why did Sweden go straight into the quarter-finals in 1938?", "Their opponents, Austria, had vanished after the Anschluss", "They were Olympic champions", "They were the top seeds", "They won a drawing of lots"],
    1950: ["What did Brazil need in their last match of 1950, against Uruguay?", "A draw", "A win by two goals", "A win by any score", "Nothing — they were already champions"],
    1954: ["By what score had West Germany lost to Hungary in the group, before beating them in the final?", "3–8", "0–3", "2–4", "1–2"],
    1958: ["How many goals did Just Fontaine score in 1958 — a record that still stands?", "13", "9", "11", "10"],
    1962: ["Who replaced the injured Pelé in the team in 1962?", "Amarildo", "Garrincha", "Vavá", "Zagallo"],
    1966: ["Who found the Jules Rimet trophy, stolen before the 1966 World Cup?", "A dog called Pickles", "Scotland Yard", "An England goalkeeper", "A London taxi driver"],
    1970: ["What appeared for the first time at the 1970 World Cup?", "Yellow and red cards", "The golden goal", "Video refereeing (VAR)", "Goal-line technology"],
    1974: ["Who received the first red card in World Cup history, in 1974?", "Carlos Caszely (Chile)", "Antonio Rattín (Argentina)", "Johan Neeskens (Netherlands)", "Gerd Müller (West Germany)"],
    1978: ["By how many goals did Argentina need to beat Peru in 1978 to finish ahead of Brazil?", "4", "1", "2", "6"],
    1982: ["What was Hungary's score against El Salvador in 1982 — the biggest in World Cup history?", "10–1", "9–0", "8–0", "7–0"],
    1986: ["How much time passed between \"The Hand of God\" and \"The Goal of the Century\"?", "About 4 minutes", "A whole half", "A whole match", "About 20 minutes"],
    1990: ["How old was Roger Milla at the 1990 World Cup?", "38", "34", "42", "30"],
    1994: ["How many goals did Oleg Salenko score in a single match in 1994?", "5", "3", "4", "6"],
    1998: ["Who scored the first golden goal in World Cup history?", "Laurent Blanc", "Zinedine Zidane", "David Trezeguet", "Thierry Henry"],
    2002: ["After how many seconds did Hakan Şükür score in the 2002 third-place match?", "11", "25", "45", "60"],
    2006: ["How did Zidane's career end, in the 2006 final?", "Sent off, after the headbutt", "With the winning goal", "Injured in the first half", "Missing a penalty in the shoot-out"],
    2010: ["What did South Africa become in 2010, for the first time in history?", "The first hosts knocked out in the group stage", "The first hosts to lose the opening match", "The first hosts not to score a goal", "The first hosts to play the third-place match"],
    2014: ["What was the score of the Germany–Brazil semi-final in 2014?", "7–1", "5–0", "4–1", "6–2"],
    2018: ["How did Japan finish ahead of Senegal in their 2018 group?", "Fewer cards (fair play)", "By drawing lots", "On goal difference", "On their head-to-head match"],
    2022: ["Which team became the first African side in a World Cup semi-final, in 2022?", "Morocco", "Senegal", "Cameroon", "Ghana"],
    2026: ["Who scored the winning goal in the 2026 final?", "Ferran Torres", "Lamine Yamal", "Mikel Oyarzabal", "Nico Williams"],
  },
  famousFalse: {
    1934: "1934: the tournament began with a group stage.",
    1950: "1950: the title was decided in a separate final, after the final group.",
    1954: "1954: every team in a group played every other team.",
    1982: "1982: the second stage had groups of 4 teams.",
    2026: "2026: only the top two teams in each group went through.",
  },
  phase: {
    SF: "Semi-finals", QF: "Quarter-finals", R16: "Round of 16", R32: "Round of 32",
    group2: "A second group stage", finalGroup: "A final group", koStart: "Straight to the round of 16, no groups",
  },
  scorerExclude: /players/,
  host: (y) => `Where was the ${y} World Cup played?`,
  final1950: (champ, runner) => `1950 had no final: the title was decided in the last match of the final group, ${champ} – ${runner}. The score?`,
  final: (y, champ, runner) => `The ${y} final: ${champ} – ${runner}. What was the score?`,
  phaseQ: (y) => `What came after the first stage of the tournament in ${y}?`,
  scorer: (y) => `Who was the top scorer at the ${y} World Cup?`,
  teams: (y) => `How many teams played at the ${y} finals?`,
  tfQ: (y) => `Which statement about the ${y} World Cup is false?`,
  tfHost: (y, h) => `${y}: the tournament was played in ${h}.`,
  tfTeams: (y, n) => `${y}: ${n} teams played at the finals.`,
  tfChamp: (y, t) => `${y}: the champions were ${t}.`,
  tfSubs: (y, n) => (n === 0 ? `${y}: no substitutions were allowed.` : `${y}: ${n} substitutions per match were allowed.`),
  tfWin: (y, p) => `${y}: a win was worth ${p} points.`,
  tfThird: (y, yes) => (yes ? `${y}: there was a third-place match.` : `${y}: there was no third-place match.`),
};

/* ---------- Country track ---------- */
EN.finishLabel = {
  champion: "🏆 Champions", runnerUp: "🥈 Runners-up", third: "🥉 Third place", fourth: "Fourth place",
  SF: "Semi-finals", GR2: "Second group stage", QF: "Quarter-finals", R16: "Round of 16", R32: "Round of 32", G: "Group stage",
};
EN.trackRound = { G: "Group", R32: "Round of 32", R16: "Round of 16", QF: "Quarter-final", GR2: "Second group stage", FR: "Final group", SF: "Semi-final", "3P": "Third place", F: "Final" };

/* match notes (country tracks) */
EN.note = function (s) {
  if (!s) return s;
  return s
    .replace("după prelungiri, egal — meciul s-a rejucat", "after extra time, a draw — the match was replayed")
    .replace("după prelungiri", "after extra time")
    .replace(/^prelungiri$/, "extra time")
    .replace("meci rejucat", "replay")
    .replace("rejucare", "replay")
    .replace("baraj de grupă", "group play-off")
    .replace("gol de aur", "golden goal")
    .replace(/penalty-uri (\d+-\d+)/, "penalties $1");
};

if (typeof module !== "undefined" && module.exports) module.exports = { EN };
