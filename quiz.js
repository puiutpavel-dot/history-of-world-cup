/* ============================================================
   HISTORY OF WORLD CUP — quiz.js
   Moduri de joc bazate pe istorie + traseul țării utilizatorului.

   buildQuizBank() generează DETERMINIST (aceeași sămânță ⇒ aceleași
   întrebări, în aceeași ordine) banca de întrebări din datele jocului
   (EDITIONS, FORMATS) + întrebările-surpriză scrise de mână. Aceeași bancă
   e exportată în Data.json pentru iOS (tools/export_ios_data.js), deci
   web și iOS au exact aceleași întrebări.

   Tipuri (kind): host, final, phase, scorer / teams, surprise, tf
   („Care afirmație e falsă?”). Quiz pe ediție = primele 5 tipuri;
   Maraton = câte o întrebare din fiecare ediție; Adevărat sau fals = tf;
   Alege faza = phase.
   ============================================================ */

/* scorul finalei (1950: meciul decisiv al grupei finale) */
const FINAL_SCORES = {
  1930: "4–2", 1934: "2–1 d.p.", 1938: "4–2", 1950: "2–1", 1954: "3–2", 1958: "5–2", 1962: "3–1",
  1966: "4–2 d.p.", 1970: "4–1", 1974: "2–1", 1978: "3–1 d.p.", 1982: "3–1", 1986: "3–2", 1990: "1–0",
  1994: "0–0, 3–2 la penalty-uri", 1998: "3–0", 2002: "2–0", 2006: "1–1, 5–3 la penalty-uri", 2010: "1–0 d.p.",
  2014: "1–0 d.p.", 2018: "4–2", 2022: "3–3, 4–2 la penalty-uri", 2026: "1–0 d.p.",
};

/* câte o întrebare-surpriză pe ediție: răspunsul corect e primul */
const QUIZ_SURPRISES = {
  1930: ["Ce s-a întâmplat cu mingea în finala din 1930?", "S-a jucat câte o repriză cu mingea fiecărei echipe", "S-a jucat cu o minge adusă de FIFA din Europa", "Mingea s-a spart, iar meciul s-a reluat", "S-a jucat tot meciul cu mingea gazdelor"],
  1934: ["Ce campioană en-titre a refuzat să vină la Mondialul din 1934?", "Uruguay", "Brazilia", "Argentina", "Anglia"],
  1938: ["De ce a intrat Suedia direct în sferturi în 1938?", "Adversara ei, Austria, dispăruse după Anschluss", "Era campioana olimpică", "Era primul cap de serie", "A câștigat o tragere la sorți"],
  1950: ["Ce îi ajungea Braziliei în ultimul meci din 1950, cu Uruguay?", "Un egal", "O victorie la două goluri", "O victorie la orice scor", "Nimic — era deja campioană"],
  1954: ["Cu ce scor pierduse RFG cu Ungaria în grupă, înainte să o învingă în finală?", "3–8", "0–3", "2–4", "1–2"],
  1958: ["Câte goluri a marcat Just Fontaine în 1958 — record încă în picioare?", "13", "9", "11", "10"],
  1962: ["Cine l-a înlocuit în echipă pe Pelé, accidentat, în 1962?", "Amarildo", "Garrincha", "Vavá", "Zagallo"],
  1966: ["Cine a găsit trofeul Jules Rimet, furat înainte de Mondialul din 1966?", "Un câine, Pickles", "Scotland Yard", "Un portar al Angliei", "Un taximetrist londonez"],
  1970: ["Ce a apărut în premieră la Mondialul din 1970?", "Cartonașele galbene și roșii", "Golul de aur", "Arbitrajul video (VAR)", "Tehnologia pe linia porții"],
  1974: ["Cine a primit primul cartonaș roșu din istoria Mondialelor, în 1974?", "Carlos Caszely (Chile)", "Antonio Rattín (Argentina)", "Johan Neeskens (Olanda)", "Gerd Müller (RFG)"],
  1978: ["La câte goluri diferență trebuia Argentina să bată Peru în 1978 ca să treacă de Brazilia?", "4", "1", "2", "6"],
  1982: ["Ce scor a făcut Ungaria cu El Salvador în 1982 — cel mai mare scor al Mondialelor?", "10–1", "9–0", "8–0", "7–0"],
  1986: ["Cât timp a trecut între „Mâna lui Dumnezeu” și „Golul secolului”?", "Aproximativ 4 minute", "O repriză întreagă", "Un meci", "Aproximativ 20 de minute"],
  1990: ["Câți ani avea Roger Milla la Mondialul din 1990?", "38", "34", "42", "30"],
  1994: ["Câte goluri a marcat Oleg Salenko într-un singur meci, în 1994?", "5", "3", "4", "6"],
  1998: ["Cine a marcat primul gol de aur din istoria Mondialelor?", "Laurent Blanc", "Zinedine Zidane", "David Trezeguet", "Thierry Henry"],
  2002: ["După câte secunde a marcat Hakan Şükür în meciul pentru locul 3 din 2002?", "11", "25", "45", "60"],
  2006: ["Cum s-a încheiat, în finala din 2006, cariera lui Zidane?", "Eliminat, după lovitura cu capul", "Cu golul victoriei", "Accidentat în prima repriză", "Cu un penalty ratat în serie"],
  2010: ["Ce a devenit Africa de Sud în 2010, prima dată în istorie?", "Prima gazdă eliminată din faza grupelor", "Prima gazdă care pierde meciul de deschidere", "Prima gazdă fără gol marcat", "Prima gazdă care joacă finala mică"],
  2014: ["Ce scor a avut semifinala Germania–Brazilia din 2014?", "7–1", "5–0", "4–1", "6–2"],
  2018: ["Cum a trecut Japonia de Senegal în grupa din 2018?", "Prin mai puține cartonașe (fair-play)", "La tragere la sorți", "Prin golaveraj", "Prin meciul direct"],
  2022: ["Ce echipă a devenit prima africană într-o semifinală de Mondial, în 2022?", "Maroc", "Senegal", "Camerun", "Ghana"],
  2026: ["Cine a marcat golul victoriei în finala din 2026?", "Ferran Torres", "Lamine Yamal", "Mikel Oyarzabal", "Nico Williams"],
};

/* afirmații false celebre („Duoul greșit”) — înlocuiesc afirmația falsă generată */
const FAMOUS_FALSE = {
  1934: "1934: turneul a început cu o fază a grupelor.",
  1950: "1950: titlul s-a decis într-o finală separată, după grupa finală.",
  1954: "1954: în grupă a jucat fiecare cu fiecare.",
  1982: "1982: a doua fază a avut grupe de câte 4 echipe.",
  2026: "2026: din fiecare grupă treceau doar primele două echipe.",
};

/* textele quizului în română; i18n_en.js are același set în engleză (pentru iOS) */
const QUIZ_RO = {
  editions: null, // implicit EDITIONS
  name: (code) => getTeamMeta(code).name,
  finalScores: FINAL_SCORES, surprises: QUIZ_SURPRISES, famousFalse: FAMOUS_FALSE,
  phase: { SF: "Semifinale", QF: "Sferturi", R16: "Optimi", R32: "Șaisprezecimi",
    group2: "A doua fază a grupelor", finalGroup: "Grupa finală", koStart: "Direct optimi, fără grupe" },
  scorerExclude: /jucători/,
  host: (y) => `Unde s-a jucat Campionatul Mondial din ${y}?`,
  final1950: (champ, runner) => `1950 nu a avut finală: titlul s-a decis în ultimul meci al grupei finale, ${champ} – ${runner}. Scorul?`,
  final: (y, champ, runner) => `Finala din ${y}: ${champ} – ${runner}. Care a fost scorul?`,
  phaseQ: (y) => `Ce urma după prima fază a turneului în ${y}?`,
  scorer: (y) => `Cine a fost golgheterul Mondialului din ${y}?`,
  teams: (y) => `Câte echipe au jucat turneul final în ${y}?`,
  tfQ: (y) => `Care afirmație despre Mondialul din ${y} e falsă?`,
  tfHost: (y, h) => `${y}: turneul s-a jucat în ${h}.`,
  tfTeams: (y, n) => `${y}: la turneul final au jucat ${n}${n < 20 ? "" : " de"} echipe.`,
  tfChamp: (y, t) => `${y}: campioană a fost ${t}.`,
  tfSubs: (y, n) => (n === 0 ? `${y}: nu era permisă nicio schimbare.` : `${y}: erau permise ${n} schimbări pe meci.`),
  tfWin: (y, p) => `${y}: o victorie aducea ${p} puncte.`,
  tfThird: (y, yes) => (yes ? `${y}: s-a jucat meci pentru locul 3.` : `${y}: nu s-a jucat meci pentru locul 3.`),
};

function phaseAfterFirst(fmt, L) {
  const st = fmt.stages;
  if (st[0].type === "ko") return L.phase.koStart;
  const next = st[1];
  if (next.type === "group2") return L.phase.group2;
  if (next.type === "finalGroup") return L.phase.finalGroup;
  return L.phase[next.round];
}

function scorerName(ed, L) {
  const m = /^(.*?)(?: \([A-Z]{3}\))? — \d+$/.exec(ed.topScorer);
  return m && !L.scorerExclude.test(m[1]) ? m[1] : null;
}

/* Fisher-Yates determinist */
function shuffled(arr, rng) {
  const a = arr.slice();
  for (let i = a.length - 1; i > 0; i--) { const j = Math.floor(rng() * (i + 1)); const t = a[i]; a[i] = a[j]; a[j] = t; }
  return a;
}

/* întrebare cu variante: corect + 3 distractori distincți, amestecate */
function mcq(rng, year, kind, q, correct, pool) {
  const wrong = shuffled([...new Set(pool.filter((x) => x !== correct))], rng).slice(0, 3);
  const options = shuffled([correct, ...wrong], rng);
  return { id: `${year}-${kind}`, year, kind, q, options, answer: options.indexOf(correct) };
}

/* L = textele unei limbi (QUIZ_RO implicit); întrebările și ordinea lor sunt aceleași în orice limbă */
function buildQuizBank(L = QUIZ_RO) {
  const out = [];
  const eds = L.editions || EDITIONS;
  const hosts = eds.map((e) => e.host);
  const finals = Object.values(L.finalScores);
  const scorers = eds.map((e) => scorerName(e, L)).filter(Boolean);
  const phaseAnswers = ["SF", "QF", "R16", "R32", "group2", "finalGroup", "koStart"].map((k) => L.phase[k]);
  const teamCounts = ["13", "15", "16", "24", "32", "48"];
  for (const ed of eds) {
    const y = ed.year, fmt = FORMATS[y];
    const rng = mulberry32(seedFor(`quiz-${y}`));
    const champ = L.name(ed.champion), runner = L.name(ed.runnerUp);
    out.push(mcq(rng, y, "host", L.host(y), ed.host, hosts));
    out.push(mcq(rng, y, "final", y === 1950 ? L.final1950(champ, runner) : L.final(y, champ, runner), L.finalScores[y], finals));
    out.push(mcq(rng, y, "phase", L.phaseQ(y), phaseAfterFirst(fmt, L), phaseAnswers));
    const sc = scorerName(ed, L);
    if (sc) out.push(mcq(rng, y, "scorer", L.scorer(y), sc, scorers));
    else out.push(mcq(rng, y, "teams", L.teams(y), String(fmt.teams), teamCounts));
    const s = L.surprises[y];
    const opts = shuffled(s.slice(1), rng);
    out.push({ id: `${y}-surprise`, year: y, kind: "surprise", q: s[0], options: opts, answer: opts.indexOf(s[1]) });
    out.push(tfQuestion(ed, fmt, rng, hosts, L));
  }
  return out;
}

/* „Care afirmație e falsă?” — 2 afirmații adevărate + 1 falsă, din date */
function tfQuestion(ed, fmt, rng, hosts, L) {
  const y = ed.year;
  const champ = L.name(ed.champion), runner = L.name(ed.runnerUp);
  const otherSubs = { 0: 2, 2: 3, 3: 5, 5: 3 }[fmt.subs];
  const otherTeams = [16, 24, 32, 48, 13].find((n) => n !== fmt.teams && Math.abs(n - fmt.teams) >= 3);
  const otherHost = shuffled(hosts.filter((h) => h !== ed.host), rng)[0];
  const facts = [
    [L.tfHost(y, ed.host), L.tfHost(y, otherHost)],
    [L.tfTeams(y, fmt.teams), L.tfTeams(y, otherTeams)],
    [L.tfChamp(y, champ), L.tfChamp(y, runner)],
    [L.tfSubs(y, fmt.subs), L.tfSubs(y, otherSubs)],
    [L.tfWin(y, fmt.win), L.tfWin(y, 5 - fmt.win)],
    [L.tfThird(y, fmt.third), L.tfThird(y, !fmt.third)],
  ];
  const picked = shuffled(facts, rng).slice(0, 3);
  const falseIdx = Math.floor(rng() * 3);
  const options = picked.map((f, i) => (i === falseIdx ? (L.famousFalse[y] || f[1]) : f[0]));
  return { id: `${y}-tf`, year: y, kind: "tf", q: L.tfQ(y), options, answer: falseIdx };
}

/* ---------- Țara utilizatorului ---------- */
const FINISH_LABEL = {
  champion: "🏆 Campioană", runnerUp: "🥈 Finalistă", third: "🥉 Locul 3", fourth: "Locul 4",
  SF: "Semifinală", GR2: "A doua fază a grupelor", QF: "Sferturi", R16: "Optimi", R32: "Șaisprezecimi", G: "Faza grupelor",
};
const FINISH_RANK = { champion: 0, runnerUp: 1, third: 2, fourth: 3, SF: 4, GR2: 5, QF: 6, R16: 7, R32: 8, G: 9 };
const TRACK_ROUND = { G: "Grupă", R32: "Șaisprezecimi", R16: "Optimi", QF: "Sferturi", GR2: "Grupa a doua", FR: "Grupa finală", SF: "Semifinală", "3P": "Finala mică", F: "Finală" };

/* 2026: cele 104 meciuri, din tracks_2026.js (openfootball, domeniu public) */
const TRACKS_2026 = typeof COUNTRY_TRACKS_2026 !== "undefined" ? COUNTRY_TRACKS_2026 : {};

/* regiunea (ISO 3166) → echipele care o reprezintă istoric (prima dă numele) */
const COUNTRY_ISO = {
  AE: ["UAE"], AO: ["ANG"], AR: ["ARG"], AT: ["AUT"], AU: ["AUS"], BA: ["BIH"], BE: ["BEL"], BG: ["BUL"],
  BO: ["BOL"], BR: ["BRA"], CA: ["CAN"], CD: ["COD", "ZAI"], CH: ["SUI"], CI: ["CIV"], CL: ["CHI"], CM: ["CMR"],
  CN: ["CHN"], CO: ["COL"], CR: ["CRC"], CU: ["CUB"], CZ: ["CZE", "TCH"], DE: ["GER", "GDR"], DK: ["DEN"],
  DZ: ["ALG"], EC: ["ECU"], EG: ["EGY"], ES: ["ESP"], FR: ["FRA"], GB: ["ENG", "SCO", "WAL", "NIR"],
  GH: ["GHA"], GR: ["GRE"], HN: ["HON"], HR: ["CRO"], HT: ["HAI"], HU: ["HUN"], ID: ["DEI"], IE: ["IRL"],
  IL: ["ISR"], IQ: ["IRQ"], IR: ["IRN"], IS: ["ISL"], IT: ["ITA"], JM: ["JAM"], JP: ["JPN"], KP: ["PRK"],
  KR: ["KOR"], KW: ["KUW"], MA: ["MAR"], ME: ["SCG", "YUG"], MX: ["MEX"], NG: ["NGA"], NL: ["NED"],
  NO: ["NOR"], NZ: ["NZL"], PA: ["PAN"], PE: ["PER"], PL: ["POL"], PT: ["POR"], PY: ["PAR"], QA: ["QAT"],
  RO: ["ROU"], RS: ["SRB", "SCG", "YUG"], RU: ["RUS", "URS"], SA: ["KSA"], SE: ["SWE"], SI: ["SVN"],
  SK: ["SVK", "TCH"], SN: ["SEN"], SV: ["SLV"], TG: ["TOG"], TN: ["TUN"], TR: ["TUR"], TT: ["TRI"],
  UA: ["UKR"], US: ["USA"], UY: ["URU"], ZA: ["RSA"],
  CV: ["CPV"], CW: ["CUW"], JO: ["JOR"], UZ: ["UZB"],
};
/* limba fără regiune → țara cea mai probabilă */
const LANG_REGION = { ro: "RO", de: "DE", fr: "FR", it: "IT", es: "ES", nl: "NL", pl: "PL", hu: "HU", sv: "SE", ja: "JP", ko: "KR", tr: "TR", hr: "HR", cs: "CZ", sk: "SK", pt: "PT", el: "GR", bg: "BG", sr: "RS", uk: "UA", ru: "RU", da: "DK", nb: "NO", no: "NO" };

/* regiunea din codurile de limbă ale dispozitivului, ex. ["ro-RO", "en-US"] → "RO" */
function regionFromLocales(locales) {
  for (const l of locales || []) {
    const parts = String(l).replace("_", "-").split("-");
    const reg = parts.slice(1).find((p) => /^[A-Za-z]{2}$/.test(p));
    if (reg && COUNTRY_ISO[reg.toUpperCase()]) return reg.toUpperCase();
  }
  for (const l of locales || []) {
    const lang = String(l).slice(0, 2).toLowerCase();
    if (LANG_REGION[lang]) return LANG_REGION[lang];
  }
  return null;
}

/* traseul unei țări (ISO): participările, cronologic, cu echipa care a jucat */
function countryTrack(iso) {
  const codes = COUNTRY_ISO[iso];
  if (!codes) return null;
  const entries = [];
  for (const code of codes) for (const e of COUNTRY_TRACKS[code] || []) entries.push({ ...e, code });
  for (const code of codes) if (TRACKS_2026[code]) entries.push({ ...TRACKS_2026[code], code });
  entries.sort((a, b) => a.year - b.year);
  const best = entries.slice().sort((a, b) => FINISH_RANK[a.finish] - FINISH_RANK[b.finish] || a.year - b.year)[0] || null;
  const played = new Set(entries.map((e) => e.year));
  return { iso, codes, name: getTeamMeta(codes[0]).name, flag: getTeamMeta(codes[0]).flag, entries, best,
    absent: EDITIONS.map((e) => e.year).filter((y) => !played.has(y)) };
}

if (typeof module !== "undefined" && module.exports) {
  module.exports = { buildQuizBank, countryTrack, regionFromLocales, COUNTRY_ISO, LANG_REGION, FINISH_LABEL, TRACK_ROUND };
}
