/* ============================================================
   HISTORY OF WORLD CUP — engine.js
   Motor de simulare: funcții pure, testabile, cu PRNG determinist
   (mulberry32) — portare directă în Swift ca funcții testabile cu
   XCTest (vezi README / concept-joc-si-plan-ios.md).
   ============================================================ */

/* ---------- PRNG determinist ---------- */
function mulberry32(seed) {
  let a = seed >>> 0;
  return function () {
    a |= 0; a = (a + 0x6d2b79f5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

function randInt(rng, min, max) { return Math.floor(rng() * (max - min + 1)) + min; }
function choice(rng, arr) { return arr[Math.floor(rng() * arr.length)]; }

/* ---------- Rating ---------- */
function getTeamRating(code, year) {
  const team = TEAMS[code];
  if (!team) return getShadowRating(code, year);
  const years = Object.keys(team.curve).map(Number).sort((a, b) => a - b);
  if (years.includes(year)) return team.curve[year];
  if (year <= years[0]) return team.curve[years[0]];
  if (year >= years[years.length - 1]) return team.curve[years[years.length - 1]];
  for (let i = 0; i < years.length - 1; i++) {
    const y0 = years[i], y1 = years[i + 1];
    if (year > y0 && year < y1) {
      const r0 = team.curve[y0], r1 = team.curve[y1];
      const t = (year - y0) / (y1 - y0);
      return Math.round(r0 + (r1 - r0) * t);
    }
  }
  return 60;
}

/* Rating "shadow" dedus din diferența de gol reală față de echipele curate,
   conform planului: nicio cercetare suplimentară, doar aritmetică pe
   REAL_FIXTURES. Fallback la 55 dacă nu există nicio referință. */
function getShadowRating(code, year) {
  let totalDiff = 0, matches = 0, refRatingSum = 0;
  for (const key in REAL_FIXTURES) {
    const [teamCode, campYear] = key.split("_");
    const campaign = REAL_FIXTURES[key];
    const all = [...campaign.group, ...campaign.knockout];
    for (const m of all) {
      if (m.opp === code) {
        const oppRating = getTeamRating(teamCode, Number(campYear));
        // diferența de gol reală, din perspectiva echipei shadow (negativ = shadow a pierdut)
        const diff = m.scoreAgainst - m.scoreFor;
        totalDiff += diff;
        refRatingSum += oppRating;
        matches++;
      }
    }
  }
  if (matches === 0) return 52;
  const avgDiff = totalDiff / matches; // diferența de gol reală a echipei shadow (negativ = a pierdut la diferență)
  const avgRefRating = refRatingSum / matches;
  // ~12 puncte de rating ≈ 1 gol de diferență așteptat (aceeași scală ca lambda din simulateMatch)
  const rating = avgRefRating + avgDiff * 11;
  return Math.max(35, Math.min(85, Math.round(rating)));
}

function getRatingAt(code, year) {
  return TEAMS[code] ? getTeamRating(code, year) : getShadowRating(code, year);
}

/* ---------- Lot de jucători ---------- */
const FIRST_NAMES = ["Carlos", "Miguel", "João", "Luca", "Marco", "Hans", "Klaus", "Pierre", "Jean", "Andrei", "Ion", "Mateus", "Tomás", "Diego", "Pablo", "Ivan", "Nikola", "Sven", "Erik", "Lars", "Kwame", "Amadou", "Hiroshi", "Kenji", "Sami", "Youssef", "Omar", "Rafael", "Bruno", "Felipe"];
const LAST_NAMES = ["Silva", "Santos", "Rossi", "Bianchi", "Müller", "Schmidt", "Dubois", "Lefevre", "Popescu", "Ionescu", "García", "Fernández", "Kowalski", "Novak", "Andersson", "Johansson", "Diallo", "Traoré", "Tanaka", "Suzuki", "Yıldız", "Demir", "Costa", "Pereira", "Martins", "Almeida"];

function genPlayerName(rng) {
  return `${choice(rng, FIRST_NAMES)} ${choice(rng, LAST_NAMES)}`;
}

const FORMATION_SLOTS = {
  GK: 1, DF: 4, MF: 4, FW: 2, // linia de start; restul lotului e banc
};

/* Lot real (jucători istorici reali) pentru campaniile curate din
   real_rosters.js — restul combinațiilor echipă+an nu au lot real
   și folosesc generarea aleatoare de mai jos. */
function getRealRoster(teamCode, year) {
  if (typeof REAL_ROSTERS === "undefined") return null;
  return REAL_ROSTERS[fixtureKey(teamCode, year)] || null;
}

function generateSquad(teamCode, year, rng) {
  const baseRating = getRatingAt(teamCode, year);
  const legendsHere = LEGENDS.filter((l) => l.team === teamCode && Math.abs(l.yearTag - year) <= 8);
  const realRoster = getRealRoster(teamCode, year);

  if (realRoster && realRoster.length) {
    // lot real: nume + poziție reale; dacă un jucător real e și în LEGENDS
    // (potrivire exactă de nume), primește boost-ul + bio de legendă.
    const squad = realRoster.map((p) => {
      const legend = legendsHere.find((l) => l.name === p.name);
      const variance = randInt(rng, -9, 9);
      let overall = Math.max(35, Math.min(96, baseRating + variance));
      let isLegend = false, bio;
      if (legend) {
        overall = Math.max(35, Math.min(99, baseRating + legend.boost));
        isLegend = true;
        bio = legend.bio;
      }
      return { name: p.name, pos: p.pos, overall, isLegend, bio };
    });
    squad.sort((a, b) => b.overall - a.overall);
    return squad;
  }

  // fallback: nume generate aleator (fără lot real curat pentru acest echipă+an)
  const positions = ["GK", "GK", "DF", "DF", "DF", "DF", "DF", "DF", "MF", "MF", "MF", "MF", "MF", "MF", "FW", "FW", "FW", "FW"];
  const squad = positions.map((pos, i) => {
    const variance = randInt(rng, -9, 9);
    const overall = Math.max(35, Math.min(96, baseRating + variance));
    return { name: genPlayerName(rng), pos, overall, isLegend: false };
  });
  // inserăm legendele (înlocuiesc jucătorul cu rating minim de pe poziția compatibilă)
  legendsHere.slice(0, 3).forEach((legend) => {
    const legendPos = legend.code === "GK" ? "GK" : (["MULLERG", "RONALDOBR", "STABILE", "FONTAINE", "EUSEBIO", "CR7", "PUSKAS"].includes(legend.code) ? "FW" : (["BECKENBAUER", "DISTEFANO"].includes(legend.code) ? "DF" : "MF"));
    let candidates = squad.filter((p) => p.pos === legendPos && !p.isLegend);
    if (candidates.length === 0) candidates = squad.filter((p) => !p.isLegend);
    candidates.sort((a, b) => a.overall - b.overall);
    const target = candidates[0];
    target.name = legend.name;
    target.overall = Math.max(35, Math.min(99, baseRating + legend.boost));
    target.isLegend = true;
    target.bio = legend.bio;
  });
  squad.sort((a, b) => b.overall - a.overall);
  return squad;
}

function squadStrength(squad) {
  const startXI = squad.slice(0, 11);
  return startXI.reduce((s, p) => s + p.overall, 0) / 11;
}

/* ---------- Tactici ---------- */
const MENTALITY_MOD = {
  Defensiv:  { atk: -0.06, def: 0.08 },
  Echilibrat: { atk: 0, def: 0 },
  Ofensiv:   { atk: 0.09, def: -0.05 },
};
const FORMATION_MOD = {
  "4-4-2": { atk: 0, def: 0 },
  "4-3-3": { atk: 0.05, def: -0.03 },
  "3-5-2": { atk: 0.02, def: -0.02 },
  "5-3-2": { atk: -0.05, def: 0.06 },
};

function tacticalRatings(squad, mentality, formation) {
  const base = squadStrength(squad);
  const m = MENTALITY_MOD[mentality] || MENTALITY_MOD.Echilibrat;
  const f = FORMATION_MOD[formation] || FORMATION_MOD["4-4-2"];
  return {
    attack: base * (1 + m.atk + f.atk),
    defense: base * (1 + m.def + f.def),
  };
}

/* ---------- Simulare meci ---------- */
function poissonSample(rng, lambda) {
  const L = Math.exp(-lambda);
  let k = 0, p = 1;
  do { k++; p *= rng(); } while (p > L && k < 12);
  return k - 1;
}

/* simulează un meci pe baza a două rating-uri de atac/apărare, gazdă
   opțională (bonus mic) și rng determinist. Întoarce scor + minute goluri. */
function simulateMatch(teamAName, teamAAttack, teamADefense, teamBName, teamBAttack, teamBDefense, rng, homeTeam) {
  const homeBonus = 1.5;
  let lambdaA = Math.max(0.2, (teamAAttack - teamBDefense) / 12 + 1.35 + (homeTeam === "A" ? homeBonus / 12 : 0));
  let lambdaB = Math.max(0.2, (teamBAttack - teamADefense) / 12 + 1.35 + (homeTeam === "B" ? homeBonus / 12 : 0));
  const goalsA = poissonSample(rng, lambdaA);
  const goalsB = poissonSample(rng, lambdaB);
  const events = [];
  const minutesA = new Set(); const minutesB = new Set();
  while (minutesA.size < goalsA) minutesA.add(randInt(rng, 1, 90));
  while (minutesB.size < goalsB) minutesB.add(randInt(rng, 1, 90));
  [...minutesA].forEach((min) => events.push({ minute: min, team: "A", teamName: teamAName }));
  [...minutesB].forEach((min) => events.push({ minute: min, team: "B", teamName: teamBName }));
  events.sort((a, b) => a.minute - b.minute);
  return { scoreA: goalsA, scoreB: goalsB, events };
}

function assignScorers(events, squadA, squadB, rng) {
  const attackersA = squadA.slice(0, 11).filter((p) => p.pos !== "GK");
  const attackersB = squadB.slice(0, 11).filter((p) => p.pos !== "GK");
  return events.map((e) => {
    const pool = e.team === "A" ? attackersA : attackersB;
    const weighted = pool.flatMap((p) => Array(p.pos === "FW" ? 4 : p.pos === "MF" ? 2 : 1).fill(p));
    const scorer = choice(rng, weighted.length ? weighted : pool);
    return { ...e, scorer: scorer ? scorer.name : "?" };
  });
}

/* penalty-uri: fiecare lovitură e o încercare independentă (~76% reușită),
   ușor influențată de diferența de rating; 5 runde, apoi moarte subită. */
function simulatePenalties(ratingA, ratingB, rng) {
  const skew = Math.max(-0.12, Math.min(0.12, (ratingA - ratingB) / 250));
  const pA = 0.76 + skew, pB = 0.76 - skew;
  let scoreA = 0, scoreB = 0;
  for (let round = 1; round <= 5; round++) {
    if (rng() < pA) scoreA++;
    if (rng() < pB) scoreB++;
  }
  let sudden = 0;
  while (scoreA === scoreB && sudden < 10) {
    if (rng() < pA) scoreA++;
    if (rng() < pB) scoreB++;
    sudden++;
  }
  if (scoreA === scoreB) scoreA += 1; // safety net, extrem de improbabil
  return { scoreA, scoreB, winner: scoreA > scoreB ? "A" : "B" };
}

/* ---------- Adversari reali / grupă & eliminatorii ---------- */
function fixtureKey(teamCode, year) { return `${teamCode}_${year}`; }

function getRealGroupOpponents(teamCode, year) {
  const camp = REAL_FIXTURES[fixtureKey(teamCode, year)];
  return camp ? camp.group.map((m) => m.opp) : [];
}

function getRealGroupMatch(teamCode, year, index) {
  const camp = REAL_FIXTURES[fixtureKey(teamCode, year)];
  return camp && camp.group[index] ? camp.group[index] : null;
}

function getRealKnockoutMatch(teamCode, year, roundIndex) {
  const camp = REAL_FIXTURES[fixtureKey(teamCode, year)];
  return camp && camp.knockout[roundIndex] ? camp.knockout[roundIndex] : null;
}

/* alege un adversar simulat, evitând echipele deja folosite ("fără retur") */
function drawOpponent(rng, year, excludeCodes, preferCurated) {
  const pool = Object.keys(TEAMS).filter((c) => !excludeCodes.includes(c));
  const source = preferCurated || pool.length === 0 ? Object.keys(TEAMS) : pool;
  const usable = source.filter((c) => !excludeCodes.includes(c));
  return choice(rng, usable.length ? usable : Object.keys(TEAMS));
}

if (typeof module !== "undefined" && module.exports) {
  module.exports = {
    mulberry32, randInt, choice,
    getTeamRating, getShadowRating, getRatingAt,
    generateSquad, squadStrength, tacticalRatings,
    simulateMatch, assignScorers, simulatePenalties, poissonSample,
    getRealGroupOpponents, getRealGroupMatch, getRealKnockoutMatch, drawOpponent, fixtureKey,
    getRealRoster,
  };
}
