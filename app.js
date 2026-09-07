/* ============================================================
   HISTORY OF WORLD CUP — app.js
   Stare de joc + randare UI (vanilla JS, fără dependențe).
   Echivalent direct al unui ObservableObject `GameState` din
   planul SwiftUI (vezi README).
   ============================================================ */

const ROOT = document.getElementById("app");
const TROPHY_KEY = "hwc_trophy_room_v1";
const THEME_KEY = "hwc_theme_v1";

const STATE = {
  screen: "MENU",
  career: null,
  museumOpen: null,
};

/* ---------- Temă ---------- */
function initTheme() {
  const saved = localStorage.getItem(THEME_KEY);
  const theme = saved || "dark";
  document.documentElement.setAttribute("data-theme", theme);
}
function toggleTheme() {
  const cur = document.documentElement.getAttribute("data-theme");
  const next = cur === "dark" ? "light" : "dark";
  document.documentElement.setAttribute("data-theme", next);
  localStorage.setItem(THEME_KEY, next);
}

/* ---------- Trofee (persistență) ---------- */
function loadTrophies() {
  try { return JSON.parse(localStorage.getItem(TROPHY_KEY)) || []; }
  catch (e) { return []; }
}
function saveTrophy(entry) {
  const list = loadTrophies();
  list.unshift(entry);
  localStorage.setItem(TROPHY_KEY, JSON.stringify(list.slice(0, 50)));
}

/* ---------- Utilitare afișare ---------- */
function teamLabel(code) {
  const m = getTeamMeta(code);
  return `${m.flag} ${m.name}`;
}
function badge(isReal) {
  return isReal
    ? `<span class="badge badge-real">📜 adversar real</span>`
    : `<span class="badge badge-sim">🎲 adversar simulat</span>`;
}
function scoreCompare(sim, real) {
  if (!real) return "";
  const same = sim.for === real.scoreFor && sim.against === real.scoreAgainst;
  return same
    ? `<div class="compare compare-same">📖 Istoria s-a repetat: scor identic (${real.scoreFor}-${real.scoreAgainst})</div>`
    : `<div class="compare compare-diff">✍️ Ai rescris istoria! (real: ${real.scoreFor}-${real.scoreAgainst})</div>`;
}

/* ---------- Navigare ---------- */
function goto(screen, extra) {
  STATE.screen = screen;
  Object.assign(STATE, extra || {});
  render();
  ROOT.scrollIntoView({ behavior: "instant", block: "start" });
}

/* ============================================================
   ECRAN: MENIU
   ============================================================ */
function renderMenu() {
  return `
  <div class="screen menu">
    <div class="hero">
      <div class="hero-ball">⚽</div>
      <h1>HISTORY OF<br/>WORLD CUP</h1>
      <p class="tagline">Confirmă sau rescrie istoria — 22 ediții, 1930-2022</p>
    </div>
    <div class="menu-buttons">
      <button class="btn btn-primary" data-action="new-career">🏆 Carieră nouă</button>
      <button class="btn" data-action="museum">📖 Muzeul Edițiilor</button>
      <button class="btn" data-action="legends">⭐ Galeria Legendelor</button>
      <button class="btn" data-action="trophies">🗄️ Sala Trofeelor</button>
    </div>
  </div>`;
}

/* ============================================================
   ECRAN: ALEGERE EDIȚIE
   ============================================================ */
function renderEditionSelect() {
  const cards = EDITIONS.map((ed) => `
    <button class="card edition-card" data-action="pick-edition" data-year="${ed.year}">
      <div class="edition-year">${ed.year}</div>
      <div class="edition-host">${ed.host}</div>
      <div class="edition-champ">🏆 ${teamLabel(ed.champion)}</div>
    </button>`).join("");
  return `
  <div class="screen">
    <div class="topbar"><button class="btn-back" data-action="menu">← Meniu</button><h2>Alege o ediție</h2></div>
    <div class="grid grid-editions">${cards}</div>
  </div>`;
}

/* ============================================================
   ECRAN: ALEGERE ECHIPĂ
   ============================================================ */
function eligibleTeams(year) {
  return Object.keys(TEAMS).filter((code) => {
    const years = Object.keys(TEAMS[code].curve).map(Number);
    return Math.min(...years) <= year + 8;
  });
}
function renderTeamSelect() {
  const year = STATE.pickedYear;
  const ed = EDITIONS.find((e) => e.year === year);
  const teams = eligibleTeams(year);
  const cards = teams.map((code) => {
    const rating = getTeamRating(code, year);
    return `<button class="card team-card" data-action="pick-team" data-code="${code}">
      <div class="team-flag">${TEAMS[code].flag}</div>
      <div class="team-name">${TEAMS[code].name}</div>
      <div class="team-rating">Rating ${rating}</div>
    </button>`;
  }).join("");
  return `
  <div class="screen">
    <div class="topbar"><button class="btn-back" data-action="edition">← Ediții</button><h2>${year} · ${ed.host}</h2></div>
    <div class="grid grid-teams">${cards}</div>
  </div>`;
}

/* ============================================================
   Inițializare carieră
   ============================================================ */
function seedFor(str) {
  let h = 2166136261;
  for (let i = 0; i < str.length; i++) { h ^= str.charCodeAt(i); h = Math.imul(h, 16777619); }
  return h >>> 0;
}

function startCareer(teamCode) {
  const year = STATE.pickedYear;
  const rng = mulberry32(seedFor(`${teamCode}-${year}-${Date.now()}`));
  const squad = generateSquad(teamCode, year, rng);

  const realGroup = getRealGroupOpponents(teamCode, year);
  const usedOpponents = [teamCode];
  const groupOpponents = [];
  for (let i = 0; i < 3; i++) {
    let opp = realGroup[i];
    const isReal = !!opp;
    if (!opp) opp = drawOpponent(rng, year, [...usedOpponents, ...groupOpponents.map(g => g.code)]);
    usedOpponents.push(opp);
    groupOpponents.push({ code: opp, isReal });
  }

  const kl = (REAL_FIXTURES[fixtureKey(teamCode, year)] || {}).knockout || [];
  const last3 = kl.slice(-3);
  const pad = 3 - last3.length;
  const knockoutPlan = Array(pad).fill(null).concat(last3).map((m) => m ? { opp: m.opp, isReal: true, realScoreFor: m.scoreFor, realScoreAgainst: m.scoreAgainst, note: m.note } : null);

  STATE.career = {
    teamCode, year, rng,
    squad, mentality: "Echilibrat", formation: "4-4-2",
    groupOpponents, groupMatchIndex: 0,
    groupResults: [], // {opp, isReal, for, against, realScore}
    otherGroupResults: null,
    standings: null,
    stage: "group", // group -> QF -> SF -> F -> done
    knockoutPlan, knockoutIndex: 0,
    knockoutResults: [],
    usedOpponents,
    outcome: null, // "champion" | "eliminated-group" | "eliminated-knockout"
    pendingMatch: null,
  };
  goto("HUB");
}

/* ============================================================
   ECRAN: HUB (lot + tactici)
   ============================================================ */
function renderHub() {
  const c = STATE.career;
  const ed = EDITIONS.find((e) => e.year === c.year);
  const startXI = c.squad.slice(0, 11);
  const bench = c.squad.slice(11);

  const groupRows = c.groupOpponents.map((g, i) => {
    const played = c.groupResults[i];
    const status = played ? `${played.for}-${played.against}` : (i === c.groupMatchIndex ? "urmează" : "—");
    return `<li class="fixture-row ${played ? "played" : ""}">${teamLabel(g.code)} ${badge(g.isReal)} <span class="fx-status">${status}</span></li>`;
  }).join("");

  const stageLabel = { group: "Faza grupelor", QF: "Sferturi de finală", SF: "Semifinală", F: "Finală" }[c.stage] || c.stage;

  const canPlay = c.stage !== "done";
  const nextLabel = c.stage === "group" ? `Joacă meciul ${c.groupMatchIndex + 1}/3 din grupă` : `Joacă ${stageLabel}`;

  return `
  <div class="screen hub">
    <div class="topbar"><button class="btn-back" data-action="menu-confirm">← Meniu</button><h2>${TEAMS[c.teamCode].flag} ${TEAMS[c.teamCode].name} · CM ${c.year}</h2></div>
    <div class="hub-grid">
      <div class="panel">
        <h3>Etapă curentă: ${stageLabel}</h3>
        ${c.stage === "group" ? `<ul class="fixture-list">${groupRows}</ul>` : renderKnockoutSummary(c)}
      </div>
      <div class="panel">
        <h3>Tactică</h3>
        <label>Mentalitate</label>
        <select id="sel-mentality">
          ${["Defensiv", "Echilibrat", "Ofensiv"].map((m) => `<option value="${m}" ${c.mentality === m ? "selected" : ""}>${m}</option>`).join("")}
        </select>
        <label>Formație</label>
        <select id="sel-formation">
          ${["4-4-2", "4-3-3", "3-5-2", "5-3-2"].map((f) => `<option value="${f}" ${c.formation === f ? "selected" : ""}>${f}</option>`).join("")}
        </select>
      </div>
      <div class="panel panel-wide">
        <h3>Lot (Start XI)</h3>
        <div class="squad-grid">${startXI.map(playerChip).join("")}</div>
        <h4>Bancă</h4>
        <div class="squad-grid squad-bench">${bench.map(playerChip).join("")}</div>
      </div>
    </div>
    ${canPlay ? `<button class="btn btn-primary btn-block" data-action="goto-preview">${nextLabel} →</button>` : ""}
  </div>`;
}
function playerChip(p) {
  return `<div class="chip ${p.isLegend ? "chip-legend" : ""}" title="${p.bio || ""}">
    <span class="chip-pos">${p.pos}</span><span class="chip-name">${p.name}${p.isLegend ? " ⭐" : ""}</span><span class="chip-ovr">${p.overall}</span>
  </div>`;
}
function renderKnockoutSummary(c) {
  const rounds = ["QF", "SF", "F"];
  return `<ul class="fixture-list">${rounds.map((r, i) => {
    const plan = c.knockoutPlan[i];
    const result = c.knockoutResults[i];
    const label = { QF: "Sferturi", SF: "Semifinală", F: "Finală" }[r];
    if (i < c.knockoutIndex && result) {
      return `<li class="fixture-row played">${label}: ${teamLabel(result.opp)} ${badge(result.isReal)} <span class="fx-status">${result.for}-${result.against}${result.pens ? ` (pen. ${result.pens})` : ""}</span></li>`;
    }
    if (i === c.knockoutIndex) {
      const oppLabel = plan ? teamLabel(plan.opp) : "necunoscut (tragere la sorți la start)";
      return `<li class="fixture-row">${label}: ${oppLabel} ${plan ? badge(plan.isReal) : ""} <span class="fx-status">urmează</span></li>`;
    }
    return `<li class="fixture-row future">${label}: —</li>`;
  }).join("")}</ul>`;
}

/* ============================================================
   Pregătire + simulare meci curent
   ============================================================ */
function currentOpponentInfo() {
  const c = STATE.career;
  if (c.stage === "group") {
    const g = c.groupOpponents[c.groupMatchIndex];
    return { code: g.code, isReal: g.isReal, real: g.isReal ? getRealGroupMatch(c.teamCode, c.year, c.groupMatchIndex) : null, roundLabel: `Grupă — meci ${c.groupMatchIndex + 1}/3` };
  }
  const idx = c.knockoutIndex;
  const plan = c.knockoutPlan[idx];
  const roundLabel = { QF: "Sferturi de finală", SF: "Semifinală", F: "Finală" }[c.stage];
  if (plan && !c.usedOpponents.includes(plan.opp)) {
    return { code: plan.opp, isReal: true, real: { scoreFor: plan.realScoreFor, scoreAgainst: plan.realScoreAgainst }, roundLabel, note: plan.note };
  }
  // simulat: alegem la prima intrare în ecran, dacă nu există deja unul ales pentru rundă
  if (!c.pendingDrawnOpponent || c.pendingDrawnOpponent.stage !== c.stage) {
    const opp = drawOpponent(c.rng, c.year, c.usedOpponents);
    c.pendingDrawnOpponent = { stage: c.stage, code: opp };
  }
  return { code: c.pendingDrawnOpponent.code, isReal: false, real: null, roundLabel };
}

function renderMatchPreview() {
  const c = STATE.career;
  const opp = currentOpponentInfo();
  STATE.currentOpponent = opp;
  const yourRatings = tacticalRatings(c.squad, c.mentality, c.formation);
  const oppSquad = generateSquad(opp.code, c.year, mulberry32(seedFor(`${opp.code}-${c.year}-opp`)));
  STATE.oppSquad = oppSquad;
  const oppRatings = tacticalRatings(oppSquad, "Echilibrat", "4-4-2");
  STATE.oppRatings = oppRatings;

  return `
  <div class="screen">
    <div class="topbar"><button class="btn-back" data-action="hub">← Hub</button><h2>${opp.roundLabel}</h2></div>
    <div class="preview-vs">
      <div class="preview-team">${teamLabel(c.teamCode)}<div class="preview-rating">Atac ${yourRatings.attack.toFixed(0)} · Apărare ${yourRatings.defense.toFixed(0)}</div></div>
      <div class="preview-vs-label">VS</div>
      <div class="preview-team">${teamLabel(opp.code)}<div class="preview-rating">Atac ${oppRatings.attack.toFixed(0)} · Apărare ${oppRatings.defense.toFixed(0)}</div></div>
    </div>
    <div class="preview-badge">${badge(opp.isReal)}${opp.note ? `<div class="note">${opp.note}</div>` : ""}</div>
    <p class="hint">Mentalitate: <b>${c.mentality}</b> · Formație: <b>${c.formation}</b> (schimbă din Hub înainte de a juca)</p>
    <button class="btn btn-primary btn-block" data-action="play-match">▶️ Joacă meciul</button>
  </div>`;
}

function renderMatchLive() {
  const c = STATE.career;
  const m = STATE.pendingMatchResult;
  return `
  <div class="screen">
    <div class="topbar"><h2>${STATE.currentOpponent.roundLabel}</h2></div>
    <div class="live-score">
      <span>${teamLabel(c.teamCode)}</span>
      <span id="live-score-num">0 - 0</span>
      <span>${teamLabel(STATE.currentOpponent.code)}</span>
    </div>
    <ul id="live-ticker" class="ticker"></ul>
    <button id="btn-skip" class="btn btn-block" data-action="skip-ticker">⏭ Sări peste</button>
    <div id="live-continue" hidden>
      <button class="btn btn-primary btn-block" data-action="after-match">Continuă →</button>
    </div>
  </div>`;
}

function playCurrentMatch() {
  const c = STATE.career;
  const opp = STATE.currentOpponent;
  const yourRatings = tacticalRatings(c.squad, c.mentality, c.formation);
  const oppRatings = STATE.oppRatings;
  const isHomeGame = c.year && EDITIONS.find(e => e.year === c.year).host && TEAMS[c.teamCode] && false; // simplificat: fără avantaj de gazdă implicit
  const result = simulateMatch(TEAMS[c.teamCode].name, yourRatings.attack, yourRatings.defense, getTeamMeta(opp.code).name, oppRatings.attack, oppRatings.defense, c.rng, null);
  const withScorers = assignScorers(result.events, c.squad, STATE.oppSquad, c.rng);
  STATE.pendingMatchResult = { scoreA: result.scoreA, scoreB: result.scoreB, events: withScorers };
  goto("MATCH_LIVE");
}

function runTicker() {
  const m = STATE.pendingMatchResult;
  const tickerEl = document.getElementById("live-ticker");
  const scoreEl = document.getElementById("live-score-num");
  if (!tickerEl) return;
  let i = 0, a = 0, b = 0;
  function step() {
    if (i >= m.events.length) { finish(); return; }
    const ev = m.events[i];
    if (ev.team === "A") a++; else b++;
    scoreEl.textContent = `${a} - ${b}`;
    const li = document.createElement("li");
    li.className = "ticker-event";
    li.textContent = `⚽ ${ev.minute}' ${ev.scorer} (${ev.teamName})`;
    tickerEl.appendChild(li);
    i++;
    STATE.tickerTimer = setTimeout(step, 550);
  }
  function finish() {
    document.getElementById("btn-skip").hidden = true;
    document.getElementById("live-continue").hidden = false;
  }
  document.getElementById("btn-skip").onclick = () => {
    clearTimeout(STATE.tickerTimer);
    while (i < m.events.length) { const ev = m.events[i]; if (ev.team === "A") a++; else b++; i++; }
    scoreEl.textContent = `${a} - ${b}`;
    tickerEl.innerHTML = m.events.map(ev => `<li class="ticker-event">⚽ ${ev.minute}' ${ev.scorer} (${ev.teamName})</li>`).join("");
    finish();
  };
  step();
}

function afterMatch() {
  const c = STATE.career;
  const opp = STATE.currentOpponent;
  const m = STATE.pendingMatchResult;

  if (c.stage === "group") {
    c.groupResults[c.groupMatchIndex] = { opp: opp.code, isReal: opp.isReal, for: m.scoreA, against: m.scoreB, real: opp.real };
    c.groupMatchIndex++;
    if (c.groupMatchIndex < 3) { goto("HUB"); return; }
    finishGroupStage();
    return;
  }
  // knockout
  let winner = "player";
  let pensText = "";
  if (m.scoreA === m.scoreB) {
    const yourRatings = tacticalRatings(c.squad, c.mentality, c.formation);
    const pens = simulatePenalties(yourRatings.attack, STATE.oppRatings.attack, c.rng);
    pensText = `${pens.scoreA}-${pens.scoreB}`;
    winner = pens.winner === "A" ? "player" : "opp";
  } else {
    winner = m.scoreA > m.scoreB ? "player" : "opp";
  }
  c.knockoutResults[c.knockoutIndex] = { opp: opp.code, isReal: opp.isReal, for: m.scoreA, against: m.scoreB, pens: pensText, real: opp.real, won: winner === "player" };
  c.usedOpponents.push(opp.code);

  if (winner !== "player") {
    c.outcome = "eliminated-knockout";
    finishCareer();
    return;
  }
  if (c.stage === "F") {
    c.outcome = "champion";
    finishCareer();
    return;
  }
  c.stage = c.stage === "QF" ? "SF" : "F";
  c.knockoutIndex++;
  goto("HUB");
}

function finishGroupStage() {
  const c = STATE.career;
  const [o1, o2, o3] = c.groupOpponents.map(g => g.code);
  const otherRng = c.rng;
  function simPair(x, y) {
    const sx = generateSquad(x, c.year, mulberry32(seedFor(x + c.year + "aux")));
    const sy = generateSquad(y, c.year, mulberry32(seedFor(y + c.year + "aux")));
    const rx = tacticalRatings(sx, "Echilibrat", "4-4-2");
    const ry = tacticalRatings(sy, "Echilibrat", "4-4-2");
    const r = simulateMatch(x, rx.attack, rx.defense, y, ry.attack, ry.defense, otherRng, null);
    return { for: r.scoreA, against: r.scoreB };
  }
  const m12 = simPair(o1, o2), m13 = simPair(o1, o3), m23 = simPair(o2, o3);

  const table = {};
  [c.teamCode, o1, o2, o3].forEach((code) => { table[code] = { code, pts: 0, gf: 0, ga: 0, pl: 0 }; });
  function apply(a, b, gfa, gfb) {
    table[a].pl++; table[b].pl++;
    table[a].gf += gfa; table[a].ga += gfb;
    table[b].gf += gfb; table[b].ga += gfa;
    if (gfa > gfb) table[a].pts += 3;
    else if (gfa < gfb) table[b].pts += 3;
    else { table[a].pts += 1; table[b].pts += 1; }
  }
  c.groupResults.forEach((r) => apply(c.teamCode, r.opp, r.for, r.against));
  apply(o1, o2, m12.for, m12.against);
  apply(o1, o3, m13.for, m13.against);
  apply(o2, o3, m23.for, m23.against);

  const standings = Object.values(table).sort((a, b) => (b.pts - a.pts) || ((b.gf - b.ga) - (a.gf - a.ga)) || (b.gf - a.gf));
  c.standings = standings;
  c.otherGroupResults = { m12: { pair: [o1, o2], ...m12 }, m13: { pair: [o1, o3], ...m13 }, m23: { pair: [o2, o3], ...m23 } };

  const rank = standings.findIndex((r) => r.code === c.teamCode);
  if (rank <= 1) {
    c.stage = "QF";
    c.knockoutIndex = 0;
    goto("GROUP_TABLE");
  } else {
    c.outcome = "eliminated-group";
    finishCareer(true);
  }
}

function finishCareer(skipToSummaryDirectly) {
  const c = STATE.career;
  const label = { champion: "🏆 Campioană Mondială!", "eliminated-group": "Eliminată în grupe", "eliminated-knockout": `Eliminată — ${c.stage}` }[c.outcome];
  saveTrophy({
    date: new Date().toISOString(), team: c.teamCode, year: c.year, outcome: c.outcome, label,
  });
  goto(skipToSummaryDirectly ? "GROUP_TABLE" : "CAREER_SUMMARY");
}

/* ============================================================
   ECRAN: CLASAMENT GRUPĂ
   ============================================================ */
function renderGroupTable() {
  const c = STATE.career;
  const rows = c.standings.map((r, i) => `
    <tr class="${r.code === c.teamCode ? "me" : ""} ${i < 2 ? "qualified" : ""}">
      <td>${i + 1}</td><td>${teamLabel(r.code)}</td><td>${r.pl}</td><td>${r.gf}-${r.ga}</td><td><b>${r.pts}</b></td>
    </tr>`).join("");
  const advanced = c.standings.findIndex(r => r.code === c.teamCode) <= 1;
  return `
  <div class="screen">
    <div class="topbar"><h2>Clasament grupă — CM ${c.year}</h2></div>
    <table class="standings"><thead><tr><th>#</th><th>Echipă</th><th>M</th><th>G</th><th>Pct</th></tr></thead><tbody>${rows}</tbody></table>
    <p class="hint">Primele 2 echipe se califică în sferturi.</p>
    ${advanced
      ? `<button class="btn btn-primary btn-block" data-action="hub">Continuă spre sferturi →</button>`
      : `<button class="btn btn-primary btn-block" data-action="summary">Vezi sumarul carierei →</button>`}
  </div>`;
}

/* ============================================================
   ECRAN: SUMAR CARIERĂ
   ============================================================ */
function renderCareerSummary() {
  const c = STATE.career;
  const rows = [];
  c.groupResults.forEach((r, i) => rows.push({ label: `Grupă ${i + 1}`, opp: r.opp, score: `${r.for}-${r.against}`, isReal: r.isReal, real: r.real }));
  c.knockoutResults.forEach((r, i) => { if (r) rows.push({ label: ["Sferturi", "Semifinală", "Finală"][i], opp: r.opp, score: `${r.for}-${r.against}${r.pens ? ` (pen. ${r.pens})` : ""}`, isReal: r.isReal, real: r.real }); });

  const outcomeLabel = { champion: "🏆 Campioană Mondială!", "eliminated-group": "Eliminată în faza grupelor", "eliminated-knockout": "Eliminată în faza eliminatorie" }[c.outcome];

  return `
  <div class="screen">
    <div class="topbar"><h2>Sumar carieră</h2></div>
    <div class="summary-hero">
      <div class="summary-team">${teamLabel(c.teamCode)} · CM ${c.year}</div>
      <div class="summary-outcome">${outcomeLabel}</div>
    </div>
    <ul class="fixture-list">
      ${rows.map(r => `<li class="fixture-row played">
        <span>${r.label}: ${teamLabel(r.opp)}</span> ${badge(r.isReal)} <span class="fx-status">${r.score}</span>
        ${r.isReal ? scoreCompare({ for: Number(r.score.split("-")[0]), against: Number(r.score.split("-")[1]) }, r.real) : ""}
      </li>`).join("")}
    </ul>
    <button class="btn btn-primary btn-block" data-action="menu">🏠 Meniu principal</button>
  </div>`;
}

/* ============================================================
   ECRAN: MUZEUL EDIȚIILOR
   ============================================================ */
function renderMuseum() {
  const items = EDITIONS.map((ed) => {
    const open = STATE.museumOpen === ed.year;
    return `<div class="museum-item">
      <button class="museum-head" data-action="toggle-museum" data-year="${ed.year}">
        <span>${ed.year} · ${ed.host}</span><span>${open ? "▲" : "▼"}</span>
      </button>
      ${open ? `<div class="museum-body">
        <p>🏆 Campioană: <b>${teamLabel(ed.champion)}</b> · Finalistă: ${teamLabel(ed.runnerUp)} · Locul 3: ${teamLabel(ed.third)}</p>
        <p>⚽ Golgheter: ${ed.topScorer}</p>
        <p>🔴 Minge oficială: ${ed.ball}</p>
        <p class="museum-note">${ed.note}</p>
      </div>` : ""}
    </div>`;
  }).join("");
  return `
  <div class="screen">
    <div class="topbar"><button class="btn-back" data-action="menu">← Meniu</button><h2>📖 Muzeul Edițiilor</h2></div>
    <div class="museum-list">${items}</div>
  </div>`;
}

/* ============================================================
   ECRAN: GALERIA LEGENDELOR
   ============================================================ */
function renderLegends() {
  const cards = LEGENDS.map((l) => `
    <div class="card legend-card">
      <div class="legend-name">${l.name}</div>
      <div class="legend-team">${teamLabel(l.team)} · ${l.yearTag}</div>
      <p class="legend-bio">${l.bio}</p>
    </div>`).join("");
  return `
  <div class="screen">
    <div class="topbar"><button class="btn-back" data-action="menu">← Meniu</button><h2>⭐ Galeria Legendelor</h2></div>
    <div class="grid grid-legends">${cards}</div>
  </div>`;
}

/* ============================================================
   ECRAN: SALA TROFEELOR
   ============================================================ */
function renderTrophies() {
  const list = loadTrophies();
  const rows = list.length ? list.map((t) => `
    <li class="trophy-row">
      <span>${teamLabel(t.team)} · CM ${t.year}</span><span>${t.label}</span>
    </li>`).join("") : `<p class="hint">Nicio carieră încheiată încă — începe una din Meniu!</p>`;
  return `
  <div class="screen">
    <div class="topbar"><button class="btn-back" data-action="menu">← Meniu</button><h2>🗄️ Sala Trofeelor</h2></div>
    <ul class="fixture-list">${rows}</ul>
  </div>`;
}

/* ============================================================
   RANDARE + EVENIMENTE
   ============================================================ */
function render() {
  const map = {
    MENU: renderMenu, EDITION: renderEditionSelect, TEAM: renderTeamSelect,
    HUB: renderHub, MATCH_PREVIEW: renderMatchPreview, MATCH_LIVE: renderMatchLive,
    GROUP_TABLE: renderGroupTable, CAREER_SUMMARY: renderCareerSummary,
    MUSEUM: renderMuseum, LEGENDS: renderLegends, TROPHIES: renderTrophies,
  };
  ROOT.innerHTML = `<button class="theme-toggle" data-action="toggle-theme">🌓</button>` + map[STATE.screen]();
  if (STATE.screen === "MATCH_LIVE") runTicker();
}

ROOT.addEventListener("click", (e) => {
  const el = e.target.closest("[data-action]");
  if (!el) return;
  const action = el.dataset.action;
  if (action === "toggle-theme") return toggleTheme();
  if (action === "new-career") return goto("EDITION");
  if (action === "museum") return goto("MUSEUM", { museumOpen: null });
  if (action === "legends") return goto("LEGENDS");
  if (action === "trophies") return goto("TROPHIES");
  if (action === "menu") return goto("MENU");
  if (action === "menu-confirm") { if (confirm("Sigur vrei să părăsești cariera curentă?")) goto("MENU"); return; }
  if (action === "edition") return goto("EDITION");
  if (action === "pick-edition") return goto("TEAM", { pickedYear: Number(el.dataset.year) });
  if (action === "pick-team") return startCareer(el.dataset.code);
  if (action === "hub") return goto("HUB");
  if (action === "goto-preview") {
    const c = STATE.career;
    c.mentality = document.getElementById("sel-mentality").value;
    c.formation = document.getElementById("sel-formation").value;
    return goto("MATCH_PREVIEW");
  }
  if (action === "play-match") return playCurrentMatch();
  if (action === "after-match") return afterMatch();
  if (action === "summary") return goto("CAREER_SUMMARY");
  if (action === "toggle-museum") {
    const y = Number(el.dataset.year);
    STATE.museumOpen = STATE.museumOpen === y ? null : y;
    return goto("MUSEUM");
  }
});
// select changes nu au nevoie de re-render imediat — citite la "goto-preview"

initTheme();
render();
