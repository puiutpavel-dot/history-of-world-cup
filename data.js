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
  { year: 1950, host: "Brazilia",       champion: "URU", runnerUp: "BRA", third: "SWE", topScorer: "Ademir (BRA) — 9", ball: "Duplo T", note: "\"Maracanazo\": Uruguay învinge Brazilia 2-1 în fața a ~200.000 de spectatori." },
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
  { year: 2022, host: "Qatar",          champion: "ARG", runnerUp: "FRA", third: "MAR", topScorer: "Kylian Mbappé (FRA) — 8", ball: "Al Rihla", note: "Argentina lui Messi câștigă al treilea titlu, finală istorică 3-3 (pen. 4-2) cu Franța." },
];

/* ---------- TEAMS: curbe de putere (puncte de control interpolate) ----------
   rating pe scară 40-99. Punctele lipsă dintre ani se interpolează liniar
   în engine.js (getTeamRating). */
const TEAMS = {
  BRA: { name: "Brazilia", flag: "🇧🇷", curve: { 1930:58, 1938:70, 1950:78, 1958:88, 1962:87, 1970:93, 1978:80, 1982:85, 1986:80, 1994:86, 1998:87, 2002:90, 2006:84, 2014:82, 2018:85, 2022:86 } },
  ARG: { name: "Argentina", flag: "🇦🇷", curve: { 1930:70, 1958:65, 1974:72, 1978:83, 1982:78, 1986:90, 1990:82, 1994:78, 1998:80, 2002:78, 2006:82, 2010:80, 2014:85, 2018:75, 2022:89 } },
  GER: { name: "Germania", flag: "🇩🇪", curve: { 1934:68, 1954:83, 1958:72, 1966:82, 1970:83, 1974:88, 1982:80, 1986:85, 1990:90, 1994:78, 1998:70, 2002:80, 2006:82, 2010:83, 2014:91, 2018:72, 2022:76 } },
  ITA: { name: "Italia", flag: "🇮🇹", curve: { 1934:85, 1938:88, 1950:65, 1962:65, 1970:84, 1978:76, 1982:86, 1986:70, 1990:84, 1994:83, 1998:78, 2006:86, 2010:65, 2014:70 } },
  URU: { name: "Uruguay", flag: "🇺🇾", curve: { 1930:88, 1950:85, 1954:78, 1970:65, 1986:62, 2010:76, 2014:70, 2018:72, 2022:65 } },
  ENG: { name: "Anglia", flag: "🏴", curve: { 1950:60, 1962:65, 1966:87, 1970:78, 1990:75, 2002:72, 2006:73, 2010:65, 2014:60, 2018:78, 2022:76 } },
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
   Rating-ul lor se deduce automat în engine.js (getShadowRating) din diferența
   de gol reală față de echipele curate — vezi real_fixtures.js. */
const SHADOW_TEAMS = {
  PER: { name: "Peru", flag: "🇵🇪" },
  ROU: { name: "România", flag: "🇷🇴" },
  YUG: { name: "Iugoslavia", flag: "🇾🇺" },
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
};

function getTeamMeta(code) {
  return TEAMS[code] || SHADOW_TEAMS[code] || { name: code, flag: "🏳️" };
}

if (typeof module !== "undefined" && module.exports) {
  module.exports = { EDITIONS, TEAMS, LEGENDS, SHADOW_TEAMS, getTeamMeta };
}
