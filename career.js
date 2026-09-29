/* ============================================================
   HISTORY OF WORLD CUP — career.js
   Motorul de carieră pe FORMATUL REAL al fiecărei ediții (vezi FORMATS
   în data.js): grupe de 2-4 meciuri, baraj, cele mai bune locuri 3, a doua
   fază a grupelor, grupa finală din 1950, șaisprezecimi → finală, finala
   mică, prelungiri, meci rejucat / tragere la sorți / penalty-uri,
   cartonașe și suspendări. Fără DOM — folosit de app.js (web), de
   tools/ (vectori de referință) și portat 1:1 în Swift (Career.swift).

   API:
     createCareer(teamCode, year, seed) → stare serializabilă (JSON)
     nextMatch(state)                   → meciul următor (fără efecte)
     playNext(state, mentality, formation) → înregistrarea meciului jucat
   ============================================================ */

const ROUND_LABEL = { R32: "Șaisprezecimi", R16: "Optimi", QF: "Sferturi", SF: "Semifinală", F: "Finală", "3P": "Finala mică" };
const STAGE_LABEL = { group: "Faza grupelor", group2: "A doua fază a grupelor", finalGroup: "Grupa finală" };

/* ---------- PRNG serializabil (aceeași secvență ca mulberry32) ---------- */
function rngOf(state) {
  return function () {
    let a = state.rng | 0;
    a = (a + 0x6d2b79f5) | 0;
    state.rng = a >>> 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

/* ---------- Echipele prezente la o ediție (pentru tragerile la sorți) ---------- */
function editionPool(year) {
  let y = year;
  while (y >= 1930) {
    const set = new Set();
    for (const key in REAL_FIXTURES) {
      if (!key.endsWith("_" + y)) continue;
      set.add(key.slice(0, 3));
      const c = REAL_FIXTURES[key];
      for (const m of c.group) set.add(m.opp);
      for (const m of c.knockout) set.add(m.opp);
    }
    if (set.size >= 8) return [...set].sort();
    y -= 4; // ediție fără date (2026): folosim echipele ediției anterioare
  }
  return Object.keys(TEAMS).sort();
}

function drawFrom(rng, pool, exclude) {
  const usable = pool.filter((c) => !exclude.includes(c));
  return choice(rng, usable.length ? usable : pool);
}

/* ---------- Clasament ---------- */
function emptyRow(code) { return { code, pl: 0, w: 0, d: 0, l: 0, gf: 0, ga: 0, pts: 0 }; }

function applyResult(table, a, b, ga, gb, win) {
  const A = table.find((r) => r.code === a), B = table.find((r) => r.code === b);
  A.pl++; B.pl++; A.gf += ga; A.ga += gb; B.gf += gb; B.ga += ga;
  if (ga > gb) { A.w++; B.l++; A.pts += win; }
  else if (ga < gb) { B.w++; A.l++; B.pts += win; }
  else { A.d++; B.d++; A.pts += 1; B.pts += 1; }
}

function goalAverage(r) { return r.ga === 0 ? (r.gf > 0 ? 1e9 + r.gf : 0) : r.gf / r.ga; }

function sortTable(table, tiebreak) {
  return table.map((r, i) => ({ r, i })).sort((x, y) => {
    const a = x.r, b = y.r;
    if (a.pts !== b.pts) return b.pts - a.pts;
    if (tiebreak === "ga") {
      const d = goalAverage(b) - goalAverage(a);
      if (d !== 0) return d;
    } else {
      const d = (b.gf - b.ga) - (a.gf - a.ga);
      if (d !== 0) return d;
      if (a.gf !== b.gf) return b.gf - a.gf;
    }
    return x.i - y.i;
  }).map((x) => x.r);
}

/* ---------- Loturi și forță ---------- */
function oppSquadOf(code, year) {
  return generateSquad(code, year, mulberry32(seedFor(`${code}-${year}-opp`)));
}

function auxSquadOf(code, year) {
  return generateSquad(code, year, mulberry32(seedFor(code + year + "aux")));
}

/* jucătorii disponibili (fără suspendați), în ordinea lotului; primii 11 joacă */
function availablePlayers(state) {
  return state.squad.map((p, idx) => ({ ...p, idx })).filter((p) => !(state.suspended[p.idx] > 0));
}

/* ---------- Construirea etapelor ---------- */
function realFixturesOf(state) {
  return REAL_FIXTURES[fixtureKey(state.team, state.year)] || null;
}

function realForRound(state, round) {
  const c = realFixturesOf(state);
  return c ? c.knockout.find((m) => m.round === round) || null : null;
}

function matchInfo(opp, isReal, real, extra) {
  return Object.assign({ opp, isReal, real: real ? { scoreFor: real.scoreFor, scoreAgainst: real.scoreAgainst } : null, note: real && real.note ? real.note : null }, extra);
}

/* intră în etapa stageIdx: stabilește adversarii (trageri la sorți incluse) */
function enterStage(state, stageIdx) {
  const fmt = FORMATS[state.year];
  const rng = rngOf(state);
  state.stageIdx = stageIdx;
  state.queue = [];
  state.group = null;
  if (stageIdx >= fmt.stages.length) return;
  const st = fmt.stages[stageIdx];
  const pool = editionPool(state.year);
  const real = realFixturesOf(state);

  if (st.type === "group" || st.type === "group2" || st.type === "finalGroup") {
    let list = [];
    if (real) {
      if (st.type === "group") list = real.group;
      else list = real.knockout.filter((m) => m.round === (st.type === "group2" ? "GR2" : "FR"));
    }
    const distinct = [];
    for (const m of list) if (!distinct.some((d) => d.opp === m.opp)) distinct.push(m);
    const size = st.sizeFromReal && distinct.length ? distinct.length + 1 : st.size;
    const members = [state.team];
    const realOf = {};
    for (const m of distinct) {
      if (members.length >= size) break;
      if (!members.includes(m.opp)) { members.push(m.opp); realOf[m.opp] = m; }
    }
    const exclude = st.type === "group" ? [] : state.used.slice();
    while (members.length < size) members.push(drawFrom(rng, pool, members.concat(exclude)));
    const opps = st.seededOnly ? members.slice(1, 3) : members.slice(1);
    const label = STAGE_LABEL[st.type];
    state.group = { type: st.type, members, playerOpps: opps, results: [], others: [], table: null, done: false };
    opps.forEach((code, i) => {
      state.queue.push(matchInfo(code, !!realOf[code], realOf[code], { kind: st.type, knockout: false, label: `${label} — meci ${i + 1}/${opps.length}` }));
    });
    for (const c of members) if (c !== state.team && !state.used.includes(c)) state.used.push(c);
    return;
  }

  // ko
  if (fmt.byes && fmt.byes[st.round] && fmt.byes[st.round].includes(state.team)) {
    state.log.push({ bye: st.round });
    return enterStage(state, stageIdx + 1);
  }
  const r = realForRound(state, st.round);
  const opp = r ? r.opp : drawFrom(rng, pool, state.used.concat([state.team]));
  if (!state.used.includes(opp)) state.used.push(opp);
  state.queue.push(matchInfo(opp, !!r, r, { kind: "ko", round: st.round, knockout: true, label: ROUND_LABEL[st.round] }));
}

function enterThirdPlace(state) {
  const rng = rngOf(state);
  const r = realForRound(state, "3P");
  const opp = r ? r.opp : drawFrom(rng, editionPool(state.year), state.used.concat([state.team]));
  if (!state.used.includes(opp)) state.used.push(opp);
  state.queue = [matchInfo(opp, !!r, r, { kind: "3P", round: "3P", knockout: true, label: ROUND_LABEL["3P"] })];
  state.group = null;
}

/* ---------- Pornire ---------- */
function createCareer(teamCode, year, seed) {
  const state = {
    team: teamCode, year, rng: seed >>> 0,
    squad: [], stageIdx: 0, queue: [], group: null,
    records: [], tables: [], log: [], used: [],
    suspended: {}, yellows: {}, outcome: null,
  };
  const rng = rngOf(state);
  state.squad = generateSquad(teamCode, year, rng);
  enterStage(state, 0);
  return state;
}

function nextMatch(state) {
  return state.outcome ? null : state.queue[0] || null;
}

/* ---------- Un meci al jucătorului ---------- */
function simulateFixture(state, info, mentality, formation) {
  const fmt = FORMATS[state.year];
  const rng = rngOf(state);
  const avail = availablePlayers(state);
  const eleven = avail.slice(0, 11);
  const oppSquad = oppSquadOf(info.opp, state.year);
  const you = tacticalRatings(avail, mentality, formation);
  const them = tacticalRatings(oppSquad, "Echilibrat", "4-4-2");
  const nameA = getTeamMeta(state.team).name, nameB = getTeamMeta(info.opp).name;

  const r = simulateMatch(nameA, you.attack, you.defense, nameB, them.attack, them.defense, rng, null);
  let events = assignScorers(r.events, avail, oppSquad, rng);
  let gf = r.scoreA, ga = r.scoreB, extraTime = false, pens = null, lots = null, tied = false;
  if (info.knockout && gf === ga) {
    const et = simulateExtraTime(nameA, you.attack, you.defense, nameB, them.attack, them.defense, rng);
    events = events.concat(assignScorers(et.events, avail, oppSquad, rng));
    gf += et.scoreA; ga += et.scoreB; extraTime = true;
    if (gf === ga) {
      const mode = info.replay ? "lots" : fmt.koTie;
      if (mode === "penalties") { const p = simulatePenalties(you.attack, them.attack, rng); pens = `${p.scoreA}-${p.scoreB}`; }
      else if (mode === "lots") { lots = rng() < 0.5 ? "A" : "B"; }
      else tied = true; // meci rejucat
    }
  }
  const cards = [];
  if (fmt.cards !== "none") {
    for (const c of simulateCards(eleven, rng)) cards.push({ minute: c.minute, team: "A", type: c.type, player: eleven[c.k].name, idx: eleven[c.k].idx });
    const oppEleven = oppSquad.slice(0, 11);
    for (const c of simulateCards(oppEleven, rng)) cards.push({ minute: c.minute, team: "B", type: c.type, player: oppEleven[c.k].name, idx: -1 });
    cards.sort((a, b) => a.minute - b.minute);
  }
  let won = null;
  if (info.knockout && !tied) won = gf > ga ? true : gf < ga ? false : pens ? Number(pens.split("-")[0]) > Number(pens.split("-")[1]) : lots === "A";
  return {
    kind: info.kind, round: info.round || null, label: info.label, opp: info.opp, isReal: info.isReal, real: info.real, note: info.note,
    gf, ga, extraTime, pens, lots, replay: !!info.replay, tied, won,
    events: events.map((e) => ({ minute: e.minute, team: e.team, scorer: e.scorer })), cards,
    suspended: state.squad.map((p, i) => i).filter((i) => state.suspended[i] > 0).map((i) => state.squad[i].name),
  };
}

/* suspendări: cei suspendați la acest meci și-au ispășit pedeapsa; se adaugă cele noi */
function applyDiscipline(state, rec) {
  const fmt = FORMATS[state.year];
  for (const k in state.suspended) if (state.suspended[k] > 0) state.suspended[k]--;
  if (fmt.cards === "none") return;
  const off = new Set(rec.cards.filter((c) => c.team === "A" && c.type !== "Y").map((c) => c.idx));
  for (const c of rec.cards) {
    if (c.team !== "A") continue;
    if (c.type === "Y") {
      if (off.has(c.idx)) continue; // primul galben dintr-o eliminare nu se cumulează
      state.yellows[c.idx] = (state.yellows[c.idx] || 0) + 1;
      if (state.yellows[c.idx] >= 2) { state.suspended[c.idx] = 1; state.yellows[c.idx] = 0; }
    } else {
      state.suspended[c.idx] = 1;
    }
  }
}

/* ---------- Finalul unei faze de grupă ---------- */
function simOther(state, a, b, rngFn, knockout) {
  const sa = auxSquadOf(a, state.year), sb = auxSquadOf(b, state.year);
  const ra = tacticalRatings(sa, "Echilibrat", "4-4-2"), rb = tacticalRatings(sb, "Echilibrat", "4-4-2");
  const m = simulateMatch(a, ra.attack, ra.defense, b, rb.attack, rb.defense, rngFn, null);
  let ga = m.scoreA, gb = m.scoreB, winner = null;
  if (knockout) {
    if (ga === gb) { const et = simulateExtraTime(a, ra.attack, ra.defense, b, rb.attack, rb.defense, rngFn); ga += et.scoreA; gb += et.scoreB; }
    winner = ga > gb ? a : ga < gb ? b : (rngFn() < 0.5 ? a : b);
  }
  return { home: a, away: b, gh: ga, ga: gb, winner };
}

function finishGroup(state) {
  const fmt = FORMATS[state.year];
  const st = fmt.stages[state.stageIdx];
  const g = state.group;
  const rng = rngOf(state);
  const m = g.members;
  const pairs = [];
  if (st.seededOnly) { pairs.push([m[1], m[3]], [m[2], m[3]]); }
  else for (let i = 1; i < m.length; i++) for (let j = i + 1; j < m.length; j++) pairs.push([m[i], m[j]]);
  for (const [a, b] of pairs) g.others.push(simOther(state, a, b, rng, false));

  const table = m.map(emptyRow);
  for (const r of g.results) applyResult(table, state.team, r.opp, r.gf, r.ga, fmt.win);
  for (const o of g.others) applyResult(table, o.home, o.away, o.gh, o.ga, fmt.win);
  let sorted = sortTable(table, st.type === "group" ? fmt.tiebreak : "gd");
  g.table = sorted;

  const advance = st.type === "group" ? st.advance : 1;
  // baraj la egalitate de puncte pe locul de calificare (1954, 1958)
  if (st.type === "group" && fmt.tiebreak === "playoff" && advance < sorted.length && sorted[advance - 1].pts === sorted[advance].pts && !g.playoff) {
    const a = sorted[advance - 1].code, b = sorted[advance].code;
    if (a === state.team || b === state.team) {
      const opp = a === state.team ? b : a;
      const real = (realFixturesOf(state) || { group: [] }).group.filter((x) => x.opp === opp);
      const r = real.length > 1 ? real[real.length - 1] : null;
      g.playoff = { pending: true, opp };
      state.queue.push(matchInfo(opp, !!r, r, { kind: "playoff", knockout: true, label: "Baraj de grupă" }));
      return;
    }
    const o = simOther(state, a, b, rng, true);
    g.playoff = { pending: false, opp: null, result: o };
    if (o.winner === b) { sorted = sorted.slice(); const t = sorted[advance - 1]; sorted[advance - 1] = sorted[advance]; sorted[advance] = t; }
    g.table = sorted;
  }
  concludeGroup(state);
}

function concludeGroup(state) {
  const fmt = FORMATS[state.year];
  const st = fmt.stages[state.stageIdx];
  const g = state.group;
  const sorted = g.table;
  const rank = sorted.findIndex((r) => r.code === state.team);
  let qualified = false, thirds = null;

  if (st.type === "finalGroup") {
    state.tables.push({ stageIdx: state.stageIdx, type: st.type, rows: sorted, others: g.others, playoff: g.playoff || null, rank, qualified: rank === 0 });
    state.outcome = ["champion", "runnerUp", "third", "fourth"][rank] || "out";
    state.outStage = STAGE_LABEL.finalGroup;
    return;
  }
  const advance = st.type === "group" ? st.advance : 1;
  if (rank < advance) qualified = true;
  else if (st.type === "group" && st.bestThirds && rank === advance) {
    thirds = rankThirds(state, st, sorted[rank]);
    qualified = thirds.rank < st.bestThirds;
  }
  const toThird = st.type === "group2" && rank === 1 && st.secondTo === "3P";
  state.tables.push({ stageIdx: state.stageIdx, type: st.type, rows: sorted, others: g.others, playoff: g.playoff || null, rank, qualified: qualified || toThird, thirds });
  if (st.type === "group" && fmt.cards === "reset") state.yellows = {};
  if (qualified) return enterStage(state, state.stageIdx + 1);
  if (toThird) return enterThirdPlace(state);
  state.outcome = "out";
  state.outStage = STAGE_LABEL[st.type];
  state.queue = [];
}

/* cele mai bune locuri 3: celelalte grupe sunt simulate cu echipe trase la sorți
   din echipele ediției (forța = ratingul istoric al echipei) */
function rankThirds(state, st, myRow) {
  const fmt = FORMATS[state.year];
  const rng = rngOf(state);
  const pool = editionPool(state.year);
  const rows = [{ ...myRow, mine: true }];
  for (let gi = 1; gi < st.groups; gi++) {
    const members = [];
    while (members.length < st.size) members.push(drawFrom(rng, pool, members.concat(state.group.members)));
    const table = members.map(emptyRow);
    for (let i = 0; i < members.length; i++) for (let j = i + 1; j < members.length; j++) {
      const ra = getRatingAt(members[i], state.year), rb = getRatingAt(members[j], state.year);
      const m = simulateMatch(members[i], ra, ra, members[j], rb, rb, rng, null);
      applyResult(table, members[i], members[j], m.scoreA, m.scoreB, fmt.win);
    }
    const third = sortTable(table, fmt.tiebreak)[st.advance];
    rows.push({ ...third, mine: false });
  }
  const ranked = sortTable(rows, "gd");
  return { rank: ranked.findIndex((r) => r.mine), rows: ranked.map((r) => ({ code: r.code, pts: r.pts, gf: r.gf, ga: r.ga, mine: r.mine })) };
}

/* ---------- Joacă meciul următor și avansează cariera ---------- */
function playNext(state, mentality, formation) {
  if (state.outcome) return null;
  const info = state.queue.shift();
  const rec = simulateFixture(state, info, mentality, formation);
  applyDiscipline(state, rec);
  state.records.push(rec);
  const fmt = FORMATS[state.year];

  if (info.kind === "group" || info.kind === "group2" || info.kind === "finalGroup") {
    state.group.results.push({ opp: info.opp, gf: rec.gf, ga: rec.ga });
    if (!state.queue.length) finishGroup(state);
    return rec;
  }
  if (rec.tied) { // meci rejucat, apoi tragere la sorți
    state.queue.unshift(Object.assign({}, info, { replay: true, label: `${info.label} (rejucat)` }));
    return rec;
  }
  if (info.kind === "playoff") {
    const g = state.group, st = fmt.stages[state.stageIdx];
    g.playoff = { pending: false, opp: info.opp, won: rec.won };
    const sorted = g.table.slice(), adv = st.advance;
    const mine = sorted.findIndex((r) => r.code === state.team);
    const other = sorted.findIndex((r) => r.code === info.opp);
    const winnerIdx = rec.won ? mine : other, loserIdx = rec.won ? other : mine;
    const w = sorted[winnerIdx], l = sorted[loserIdx];
    sorted[adv - 1] = w; sorted[adv] = l;
    g.table = sorted;
    concludeGroup(state);
    return rec;
  }
  if (info.kind === "3P") {
    state.outcome = rec.won ? "third" : "fourth";
    state.outStage = ROUND_LABEL["3P"];
    return rec;
  }
  // ko
  if (rec.won) {
    if (info.round === "F") { state.outcome = "champion"; state.outStage = ROUND_LABEL.F; }
    else enterStage(state, state.stageIdx + 1);
  } else if (info.round === "F") {
    state.outcome = "runnerUp"; state.outStage = ROUND_LABEL.F;
  } else if (info.round === "SF" && fmt.third) {
    enterThirdPlace(state);
  } else {
    state.outcome = "out"; state.outStage = ROUND_LABEL[info.round];
  }
  return rec;
}

const OUTCOME_LABEL = { champion: "🏆 Campioană mondială", runnerUp: "🥈 Vicecampioană", third: "🥉 Locul 3", fourth: "Locul 4" };
function outcomeLabel(state) {
  if (!state.outcome) return "În desfășurare";
  if (state.outcome === "out") return `Eliminată — ${state.outStage}`;
  return OUTCOME_LABEL[state.outcome];
}

if (typeof module !== "undefined" && module.exports) {
  module.exports = { createCareer, nextMatch, playNext, outcomeLabel, editionPool, ROUND_LABEL, STAGE_LABEL };
}
