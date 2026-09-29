/* ============================================================
   ARHIVA MONDIALELOR — app.js
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
      <h1>ARHIVA<br/>MONDIALELOR</h1>
      <p class="tagline">Confirmă sau rescrie istoria — 23 de ediții, 1930-2026</p>
    </div>
    <div class="menu-buttons">
      <button class="btn btn-primary" data-action="new-career">🏆 Carieră nouă</button>
      <button class="btn" data-action="quiz-menu">🧠 Quiz</button>
      ${countryButton()}
      <button class="btn" data-action="museum">📖 Muzeul Edițiilor</button>
      <button class="btn" data-action="rules">📜 Evoluția regulilor</button>
      <button class="btn" data-action="legends">⭐ Galeria Legendelor</button>
      <button class="btn" data-action="trophies">🗄️ Sala Trofeelor</button>
    </div>
    <p class="disclaimer">Joc educațional neoficial, fără legătură cu FIFA sau cu federațiile naționale. · <a href="privacy.html">Confidențialitate</a> · <a href="support.html">Suport</a></p>
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
   Carieră — motorul e în career.js (formatul real al fiecărei ediții)
   ============================================================ */

function startCareer(teamCode) {
  const year = STATE.pickedYear;
  STATE.career = createCareer(teamCode, year, seedFor(`${teamCode}-${year}-${Date.now()}`));
  STATE.tactics = { mentality: "Echilibrat", formation: "4-4-2" };
  STATE.lastRecord = null;
  goto("HUB");
}

function scoreText(r) {
  let s = `${r.gf}-${r.ga}`;
  if (r.extraTime) s += r.goldenGoal ? " (gol de aur)" : " d.p.";
  if (r.pens) s += ` (pen. ${r.pens})`;
  if (r.lots) s += ` (sorți: ${r.lots === "A" ? "câștigat" : "pierdut"})`;
  if (r.tied) s += " → rejucat";
  return s;
}

function recordRow(r) {
  return `<li class="fixture-row played"><span class="fx-label">${r.label}</span> ${teamLabel(r.opp)} ${badge(r.isReal)} <span class="fx-status">${scoreText(r)}</span></li>`;
}

/* ============================================================
   ECRAN: HUB (drum, lot, tactici)
   ============================================================ */
function renderHub() {
  const c = STATE.career;
  const fmt = FORMATS[c.year];
  const next = nextMatch(c);
  const avail = availablePlayers(c);
  const startXI = avail.slice(0, 11);
  const bench = avail.slice(11);
  const suspended = c.squad.filter((p, i) => c.suspended[i] > 0).map((p) => p.name);
  const groupBox = c.group && !c.group.done ? `<p class="hint">Grupa: ${c.group.members.map(teamLabel).join(" · ")}</p>` : "";
  const t = STATE.tactics;
  return `
  <div class="screen hub">
    <div class="topbar"><button class="btn-back" data-action="menu-confirm">← Meniu</button><h2>${TEAMS[c.team].flag} ${TEAMS[c.team].name} · CM ${c.year}</h2></div>
    <div class="hub-grid">
      <div class="panel">
        <h3>${next ? next.label : outcomeLabel(c)}</h3>
        ${groupBox}
        <ul class="fixture-list">
          ${c.records.map(recordRow).join("")}
          ${next ? `<li class="fixture-row"><span class="fx-label">${next.label}</span> ${teamLabel(next.opp)} ${badge(next.isReal)} <span class="fx-status">urmează</span></li>` : ""}
        </ul>
        <p class="hint">${fmt.summary}</p>
      </div>
      <div class="panel">
        <h3>Tactică</h3>
        <label>Mentalitate</label>
        <select id="sel-mentality">
          ${["Defensiv", "Echilibrat", "Ofensiv"].map((m) => `<option value="${m}" ${t.mentality === m ? "selected" : ""}>${m}</option>`).join("")}
        </select>
        <label>Formație</label>
        <select id="sel-formation">
          ${["4-4-2", "4-3-3", "3-5-2", "5-3-2"].map((f) => `<option value="${f}" ${t.formation === f ? "selected" : ""}>${f}</option>`).join("")}
        </select>
        ${suspended.length ? `<p class="hint">🟥 Suspendați pentru meciul următor: ${suspended.join(", ")}</p>` : ""}
      </div>
      <div class="panel panel-wide">
        <h3>Lot (Start XI)</h3>
        <div class="squad-grid">${startXI.map(playerChip).join("")}</div>
        <h4>Bancă</h4>
        <div class="squad-grid squad-bench">${bench.map(playerChip).join("")}</div>
      </div>
    </div>
    ${next ? `<button class="btn btn-primary btn-block" data-action="goto-preview">Joacă: ${next.label} →</button>` : `<button class="btn btn-primary btn-block" data-action="summary">Vezi sumarul carierei →</button>`}
  </div>`;
}
function playerChip(p) {
  return `<div class="chip ${p.isLegend ? "chip-legend" : ""}" title="${p.bio || ""}">
    <span class="chip-pos">${p.pos}</span><span class="chip-name">${p.name}${p.isLegend ? " ⭐" : ""}</span><span class="chip-ovr">${p.overall}</span>
  </div>`;
}

/* ============================================================
   Preview + meci
   ============================================================ */
function renderMatchPreview() {
  const c = STATE.career;
  const next = nextMatch(c);
  const t = STATE.tactics;
  const yourRatings = tacticalRatings(availablePlayers(c), t.mentality, t.formation);
  const oppRatings = tacticalRatings(oppSquadOf(next.opp, c.year), "Echilibrat", "4-4-2");
  return `
  <div class="screen">
    <div class="topbar"><button class="btn-back" data-action="hub">← Hub</button><h2>${next.label}</h2></div>
    <div class="preview-vs">
      <div class="preview-team">${teamLabel(c.team)}<div class="preview-rating">Atac ${yourRatings.attack.toFixed(0)} · Apărare ${yourRatings.defense.toFixed(0)}</div></div>
      <div class="preview-vs-label">VS</div>
      <div class="preview-team">${teamLabel(next.opp)}<div class="preview-rating">Atac ${oppRatings.attack.toFixed(0)} · Apărare ${oppRatings.defense.toFixed(0)}</div></div>
    </div>
    <div class="preview-badge">${badge(next.isReal)}${next.note ? `<div class="note">${next.note}</div>` : ""}</div>
    <p class="hint">Mentalitate: <b>${t.mentality}</b> · Formație: <b>${t.formation}</b>${next.knockout ? " · Eliminatoriu: la egal se joacă prelungiri" : ""}</p>
    <p class="hint">${rulesLine(FORMATS[c.year])}</p>
    <button class="btn btn-primary btn-block" data-action="play-match">▶️ Joacă meciul</button>
  </div>`;
}

function renderMatchLive() {
  const c = STATE.career;
  const r = STATE.lastRecord;
  return `
  <div class="screen">
    <div class="topbar"><h2>${r.label}</h2></div>
    <div class="live-score">
      <span>${teamLabel(c.team)}</span>
      <span id="live-score-num">0 - 0</span>
      <span>${teamLabel(r.opp)}</span>
    </div>
    <ul id="live-ticker" class="ticker"></ul>
    <button id="btn-skip" class="btn btn-block" data-action="skip-ticker">⏭ Sări peste</button>
    <div id="live-continue" hidden>
      <div id="live-extra"></div>
      <button class="btn btn-primary btn-block" data-action="after-match">Continuă →</button>
    </div>
  </div>`;
}

function playCurrentMatch() {
  const c = STATE.career;
  STATE.tablesBefore = c.tables.length;
  STATE.lastRecord = playNext(c, STATE.tactics.mentality, STATE.tactics.formation);
  if (c.outcome) saveTrophy({ date: new Date().toISOString(), team: c.team, year: c.year, outcome: c.outcome, label: outcomeLabel(c) });
  goto("MATCH_LIVE");
}

/* regulile de pe teren ale ediției, pe scurt */
function rulesLine(fmt) {
  const parts = [];
  if (fmt.subs === 0) parts.push("Fără schimbări: un accidentat lasă echipa în 10");
  else parts.push(`${fmt.subs} schimbări${fmt.gkSub ? " (+1 pentru portar)" : ""}${fmt.etSub ? ` (+${fmt.etSub} în prelungiri)` : ""}`);
  parts.push(fmt.cards === "none" ? "fără cartonașe" : fmt.cards === "accumulate" ? "2 galbene = suspendare, tot turneul" : "galbenele se șterg după grupe");
  if (fmt.goldenGoal) parts.push("gol de aur în prelungiri");
  if (fmt.stages.some((st) => st.groupExtraTime)) parts.push("prelungiri și în grupă");
  if (fmt.fairPlay) parts.push("fair-play la departajare");
  return "📏 " + parts.join(" · ");
}

function tickerItems(r) {
  const c = STATE.career;
  const goals = r.events.map((e) => ({ minute: e.minute, team: e.team, text: `⚽ ${e.minute}' ${e.scorer} (${getTeamMeta(e.team === "A" ? c.team : r.opp).name})`, goal: true }));
  const cardIcon = { Y: "🟨", R: "🟥", Y2R: "🟨🟥" };
  const cards = r.cards.map((k) => ({ minute: k.minute, team: k.team, text: `${cardIcon[k.type]} ${k.minute}' ${k.player} (${getTeamMeta(k.team === "A" ? c.team : r.opp).name})`, goal: false }));
  const subs = (r.subs || []).map((x) => {
    const team = getTeamMeta(x.team === "A" ? c.team : r.opp).name;
    const text = !x.inn ? `🚑 ${x.minute}' ${x.out} (${team}) accidentat — fără schimbări, echipa rămâne în 10`
      : x.injury ? `🚑🔁 ${x.minute}' ${x.out} accidentat, intră ${x.inn} (${team})`
      : `🔁 ${x.minute}' Intră ${x.inn}, iese ${x.out} (${team})`;
    return { minute: x.minute, team: x.team, text, goal: false };
  });
  return goals.concat(cards, subs).map((it, i) => ({ it, i })).sort((a, b) => a.it.minute - b.it.minute || a.i - b.i).map((x) => x.it);
}

function runTicker() {
  const r = STATE.lastRecord;
  const items = tickerItems(r);
  const tickerEl = document.getElementById("live-ticker");
  const scoreEl = document.getElementById("live-score-num");
  if (!tickerEl) return;
  let i = 0, a = 0, b = 0;
  function add(it) {
    if (it.goal) { if (it.team === "A") a++; else b++; }
    scoreEl.textContent = `${a} - ${b}`;
    const li = document.createElement("li");
    li.className = "ticker-event";
    li.textContent = it.text;
    tickerEl.appendChild(li);
  }
  function finish() {
    document.getElementById("btn-skip").hidden = true;
    const extra = [];
    if (r.goldenGoal) extra.push("⚡ Gol de aur — primul gol din prelungiri a încheiat meciul.");
    else if (r.extraTime) extra.push("⏱️ S-au jucat prelungiri.");
    if (r.pens) extra.push(`🎯 Penalty-uri: ${r.pens}`);
    if (r.lots) extra.push(r.lots === "A" ? "🪙 Tragere la sorți: câștigată!" : "🪙 Tragere la sorți: pierdută.");
    if (r.tied) extra.push("🔁 Egalitate după prelungiri — meciul se rejoacă.");
    if (r.won === true) extra.push("✅ Calificată mai departe!");
    if (r.won === false) extra.push("❌ Pierdut.");
    if (r.suspended.length) extra.push(`🟥 Au lipsit (suspendați): ${r.suspended.join(", ")}`);
    document.getElementById("live-extra").innerHTML = extra.map((x) => `<p>${x}</p>`).join("") + (r.isReal ? scoreCompare({ for: r.gf, against: r.ga }, r.real) : "");
    document.getElementById("live-continue").hidden = false;
  }
  function step() {
    if (i >= items.length) { finish(); return; }
    add(items[i++]);
    STATE.tickerTimer = setTimeout(step, 550);
  }
  document.getElementById("btn-skip").onclick = () => {
    clearTimeout(STATE.tickerTimer);
    while (i < items.length) add(items[i++]);
    finish();
  };
  step();
}

function afterMatch() {
  const c = STATE.career;
  if (c.tables.length > STATE.tablesBefore) return goto("GROUP_TABLE", { tableIdx: c.tables.length - 1 });
  if (c.outcome) return goto("CAREER_SUMMARY");
  goto("HUB");
}

/* ============================================================
   ECRAN: CLASAMENT (după fiecare fază de grupe)
   ============================================================ */
function renderGroupTable() {
  const c = STATE.career;
  const t = c.tables[STATE.tableIdx];
  const fmt = FORMATS[c.year];
  const rows = t.rows.map((r, i) => `
    <tr class="${r.code === c.team ? "me" : ""}">
      <td>${i + 1}</td><td>${teamLabel(r.code)}</td><td>${r.pl}</td><td>${r.gf}-${r.ga}</td><td><b>${r.pts}</b></td>
    </tr>`).join("");
  const others = t.others.map((o) => `<li>${teamLabel(o.home)} – ${teamLabel(o.away)}: <b>${o.gh}-${o.ga}</b></li>`).join("");
  let extra = "";
  if (t.playoff && t.playoff.result) extra += `<p class="hint">Baraj: ${teamLabel(t.playoff.result.home)} – ${teamLabel(t.playoff.result.away)} ${t.playoff.result.gh}-${t.playoff.result.ga} (trece ${teamLabel(t.playoff.result.winner)})</p>`;
  if (t.playoff && !t.playoff.result && t.playoff.opp) extra += `<p class="hint">Egalitate de puncte pe locul de calificare → baraj cu ${teamLabel(t.playoff.opp)}: ${t.playoff.won ? "câștigat" : "pierdut"}.</p>`;
  if (t.thirds) extra += `<p class="hint">Clasamentul locurilor 3: locul ${t.thirds.rank + 1} din ${t.thirds.rows.length} — ${t.qualified ? "calificată printre cele mai bune locuri 3!" : "nu ajunge printre cele mai bune locuri 3."}</p>`;
  const title = { group: "Clasament grupă", group2: "A doua fază a grupelor", finalGroup: "Grupa finală" }[t.type];
  const verdict = t.type === "finalGroup" ? outcomeLabel(c) : t.qualified ? "✅ Calificată" : "❌ Eliminată";
  return `
  <div class="screen">
    <div class="topbar"><h2>${title} — CM ${c.year}</h2></div>
    <table class="standings"><thead><tr><th>#</th><th>Echipă</th><th>M</th><th>G</th><th>Pct</th></tr></thead><tbody>${rows}</tbody></table>
    <p class="hint">Victorie = ${fmt.win} puncte · ${verdict}</p>
    ${others ? `<h3>Celelalte meciuri</h3><ul class="fixture-list">${others}</ul>` : ""}
    ${extra}
    ${c.outcome ? `<button class="btn btn-primary btn-block" data-action="summary">Vezi sumarul carierei →</button>` : `<button class="btn btn-primary btn-block" data-action="hub">Continuă →</button>`}
  </div>`;
}

/* ============================================================
   ECRAN: SUMAR CARIERĂ
   ============================================================ */
function renderCareerSummary() {
  const c = STATE.career;
  return `
  <div class="screen">
    <div class="topbar"><h2>Sumar carieră</h2></div>
    <div class="summary-hero">
      <div class="summary-team">${teamLabel(c.team)} · CM ${c.year}</div>
      <div class="summary-outcome">${outcomeLabel(c)}</div>
    </div>
    <ul class="fixture-list">
      ${c.records.map((r) => `<li class="fixture-row played">
        <span>${r.label}: ${teamLabel(r.opp)}</span> ${badge(r.isReal)} <span class="fx-status">${scoreText(r)}</span>
        ${r.isReal ? scoreCompare({ for: r.gf, against: r.ga }, r.real) : ""}
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
        ${FORMATS[ed.year] ? `<p>📋 <b>Format:</b> ${FORMATS[ed.year].summary}</p><p>${rulesLine(FORMATS[ed.year])}</p>` : ""}
        ${STORIES[ed.year] ? storyHtml(STORIES[ed.year]) : ""}
        <button class="btn btn-block" data-action="quiz-start" data-mode="edition" data-year="${ed.year}">🧠 Quiz ${ed.year} (${quizBest("edition", ed.year) != null ? `record ${quizBest("edition", ed.year)}/5` : "5 întrebări"})</button>
      </div>` : ""}
    </div>`;
  }).join("");
  return `
  <div class="screen">
    <div class="topbar"><button class="btn-back" data-action="menu">← Meniu</button><h2>📖 Muzeul Edițiilor</h2></div>
    <div class="museum-list">${items}</div>
    <p class="hint credits">Rezultatele meciurilor reale: <a href="https://www.github.com/jfjelstul/worldcup" target="_blank" rel="noopener">Fjelstul World Cup Database</a> © 2023 Joshua C. Fjelstul, Ph.D., licență <a href="https://creativecommons.org/licenses/by-sa/4.0/legalcode" target="_blank" rel="noopener">CC-BY-SA 4.0</a> (date adaptate). Loturi: Wikipedia, „FIFA World Cup squads”.</p>
  </div>`;
}

function storyHtml(st) {
  return `<div class="story">
    <p>${st.context}</p>
    <p><b>Momente-cheie</b></p>
    <ul class="story-list">${st.moments.map((m) => `<li>${m}</li>`).join("")}</ul>
    <p>🏟️ <b>Finala:</b> ${st.final}</p>
    <p>🧑‍💼 <b>Antrenor campion:</b> ${st.coach}</p>
  </div>`;
}

/* ============================================================
   QUIZ — moduri de joc (banca de întrebări vine din quiz.js)
   ============================================================ */
const QUIZ_KEY = "hwc_quiz_v1";
const QUIZ_BANK = buildQuizBank();
const EDITION_KINDS = ["host", "final", "phase", "scorer", "teams", "surprise"];

function loadQuizProgress() {
  try { return JSON.parse(localStorage.getItem(QUIZ_KEY)) || { editions: {}, modes: {} }; }
  catch (e) { return { editions: {}, modes: {} }; }
}
function saveQuizProgress(p) {
  try { localStorage.setItem(QUIZ_KEY, JSON.stringify(p)); } catch (e) { /* stocare indisponibilă */ }
}
function pickRandom(arr, n) {
  const a = arr.slice();
  for (let i = a.length - 1; i > 0; i--) { const j = Math.floor(Math.random() * (i + 1)); [a[i], a[j]] = [a[j], a[i]]; }
  return a.slice(0, n);
}

/* mode: "edition" (cu year) | "marathon" | "tf" | "phase" */
function startQuiz(mode, year) {
  let questions, title;
  if (mode === "edition") {
    questions = QUIZ_BANK.filter((q) => q.year === year && EDITION_KINDS.includes(q.kind));
    title = `Quiz ${year}`;
  } else if (mode === "marathon") {
    questions = EDITIONS.map((e) => pickRandom(QUIZ_BANK.filter((q) => q.year === e.year), 1)[0]);
    title = "Maraton 1930 → 2026";
  } else if (mode === "tf") {
    questions = pickRandom(QUIZ_BANK.filter((q) => q.kind === "tf"), 10);
    title = "Duoul greșit";
  } else {
    questions = pickRandom(QUIZ_BANK.filter((q) => q.kind === "phase"), 10);
    title = "Alege faza";
  }
  STATE.quiz = { mode, year: year || null, title, questions, idx: 0, score: 0, picked: null };
  goto("QUIZ_PLAY");
}

function quizBest(mode, year) {
  const p = loadQuizProgress();
  return mode === "edition" ? p.editions[year] : p.modes[mode];
}

function renderQuizMenu() {
  const best = (m) => (quizBest(m) != null ? `Record: ${quizBest(m)}` : "Nejucat încă");
  const eds = EDITIONS.map((e) => {
    const b = quizBest("edition", e.year);
    return `<button class="card quiz-ed" data-action="quiz-start" data-mode="edition" data-year="${e.year}">
      <div class="quiz-ed-year">${e.year}</div><div class="quiz-ed-host">${e.host}</div>
      <div class="quiz-ed-best">${b != null ? `${"⭐".repeat(b)}${"☆".repeat(5 - b)}` : "☆☆☆☆☆"}</div>
    </button>`;
  }).join("");
  return `
  <div class="screen">
    <div class="topbar"><button class="btn-back" data-action="menu">← Meniu</button><h2>🧠 Quiz</h2></div>
    <div class="quiz-modes">
      <button class="card quiz-mode" data-action="quiz-start" data-mode="marathon"><b>🏃 Maraton 1930 → 2026</b><span>23 de întrebări, câte una pe ediție</span><small>${best("marathon")} / 23</small></button>
      <button class="card quiz-mode" data-action="quiz-start" data-mode="tf"><b>🕵️ Duoul greșit</b><span>3 afirmații, una e falsă — 10 runde</span><small>${best("tf")} / 10</small></button>
      <button class="card quiz-mode" data-action="quiz-start" data-mode="phase"><b>🧩 Alege faza</b><span>Îți dau anul, tu spui ce urma după prima fază — 10 runde</span><small>${best("phase")} / 10</small></button>
    </div>
    <h3 class="section-title">Quiz pe ediție — 5 întrebări: gazdă, finală, format, golgheter, o surpriză</h3>
    <div class="grid grid-editions">${eds}</div>
  </div>`;
}

function renderQuizPlay() {
  const z = STATE.quiz;
  const q = z.questions[z.idx];
  const answered = z.picked !== null;
  const opts = q.options.map((o, i) => {
    let cls = "quiz-opt";
    if (answered && i === q.answer) cls += " quiz-ok";
    else if (answered && i === z.picked) cls += " quiz-bad";
    return `<button class="${cls}" data-action="quiz-pick" data-i="${i}" ${answered ? "disabled" : ""}>${o}</button>`;
  }).join("");
  const last = z.idx === z.questions.length - 1;
  return `
  <div class="screen">
    <div class="topbar"><button class="btn-back" data-action="quiz-menu">← Quiz</button><h2>${z.title}</h2></div>
    <div class="quiz-progress">Întrebarea ${z.idx + 1} / ${z.questions.length} · Scor ${z.score}</div>
    <div class="card quiz-q"><div class="quiz-year">${q.year}</div><p>${q.q}</p></div>
    <div class="quiz-opts">${opts}</div>
    ${answered ? `<p class="quiz-feedback">${z.picked === q.answer ? "✅ Corect!" : `❌ Răspuns corect: <b>${q.options[q.answer]}</b>`}</p>
      <button class="btn btn-primary btn-block" data-action="quiz-next">${last ? "Vezi rezultatul →" : "Următoarea →"}</button>` : ""}
  </div>`;
}

function finishQuiz() {
  const z = STATE.quiz;
  const p = loadQuizProgress();
  const prev = z.mode === "edition" ? p.editions[z.year] : p.modes[z.mode];
  z.newRecord = prev == null || z.score > prev;
  if (z.newRecord) { if (z.mode === "edition") p.editions[z.year] = z.score; else p.modes[z.mode] = z.score; }
  saveQuizProgress(p);
  goto("QUIZ_RESULT");
}

function renderQuizResult() {
  const z = STATE.quiz;
  const total = z.questions.length;
  const pct = z.score / total;
  const verdict = pct === 1 ? "Perfect! Știi istoria pe de rost." : pct >= 0.6 ? "Foarte bine!" : pct >= 0.3 ? "Nu-i rău — Muzeul te ajută." : "Mai trece o dată prin Muzeu.";
  return `
  <div class="screen">
    <div class="topbar"><h2>${z.title}</h2></div>
    <div class="summary-hero">
      <div class="summary-outcome">${z.score} / ${total}</div>
      <div class="summary-team">${verdict}${z.newRecord ? " · 🏅 Record nou!" : ""}</div>
    </div>
    <button class="btn btn-primary btn-block" data-action="quiz-start" data-mode="${z.mode}" ${z.year ? `data-year="${z.year}"` : ""}>🔁 Încă o dată</button>
    ${z.year ? `<button class="btn btn-block" data-action="museum-year" data-year="${z.year}">📖 Citește ediția ${z.year} în Muzeu</button>` : ""}
    <button class="btn btn-block" data-action="quiz-menu">← Înapoi la Quiz</button>
  </div>`;
}

/* ============================================================
   ȚARA UTILIZATORULUI — traseul real la Mondiale
   ============================================================ */
const COUNTRY_KEY = "hwc_country_v1";

function userCountry() {
  let saved = null;
  try { saved = localStorage.getItem(COUNTRY_KEY); } catch (e) { /* ignorat */ }
  if (saved && COUNTRY_ISO[saved]) return saved;
  return regionFromLocales(navigator.languages && navigator.languages.length ? navigator.languages : [navigator.language]);
}

function countryButton() {
  const iso = userCountry();
  const t = iso ? countryTrack(iso) : null;
  return t ? `<button class="btn" data-action="country">${t.flag} Traseul: ${t.name}</button>`
    : `<button class="btn" data-action="country">🌍 Traseul țării tale</button>`;
}

function renderCountry() {
  const iso = STATE.countryIso || userCountry();
  const t = iso ? countryTrack(iso) : null;
  const options = Object.keys(COUNTRY_ISO).map((k) => ({ k, n: getTeamMeta(COUNTRY_ISO[k][0]).name }))
    .sort((a, b) => a.n.localeCompare(b.n, "ro"))
    .map((o) => `<option value="${o.k}" ${o.k === iso ? "selected" : ""}>${getTeamMeta(COUNTRY_ISO[o.k][0]).flag} ${o.n}</option>`).join("");
  const picker = `<label class="hint">Țara: <select id="sel-country">${options}</select></label>`;
  if (!t) {
    return `
    <div class="screen">
      <div class="topbar"><button class="btn-back" data-action="menu">← Meniu</button><h2>🌍 Traseul țării tale</h2></div>
      <p class="hint">Nu am putut stabili țara din setările dispozitivului. Alege-o din listă:</p>
      ${picker}
    </div>`;
  }
  const entries = t.entries.map((e) => {
    const ed = EDITIONS.find((x) => x.year === e.year);
    const as = e.code !== t.codes[0] ? ` <span class="hint">(ca ${getTeamMeta(e.code).name})</span>` : "";
    const matches = e.matches.map((m) => `<li><span class="fx-label">${TRACK_ROUND[m.round]}</span> ${teamLabel(m.opp)} <b>${m.gf}–${m.ga}</b>${m.note ? ` <span class="hint">(${m.note})</span>` : ""}</li>`).join("");
    const name = getTeamMeta(e.code).name;
    const story = STORIES[e.year] ? STORIES[e.year].moments.filter((x) => x.includes(name)) : [];
    const playable = TEAMS[e.code] && eligibleTeams(e.year).includes(e.code);
    return `<div class="card track-entry">
      <div class="track-head"><span class="quiz-ed-year">${e.year}</span> <span>${ed ? ed.host : ""}</span>${as}<span class="track-finish">${FINISH_LABEL[e.finish]}</span></div>
      ${matches ? `<ul class="story-list">${matches}</ul>` : `<p class="hint">Meciurile din ${e.year} nu sunt încă în baza de date.</p>`}
      ${story.map((x) => `<p class="museum-note">📖 ${x}</p>`).join("")}
      ${playable ? `<button class="btn btn-block" data-action="play-campaign" data-code="${e.code}" data-year="${e.year}">▶️ Joacă această campanie</button>` : ""}
    </div>`;
  }).join("");
  return `
  <div class="screen">
    <div class="topbar"><button class="btn-back" data-action="menu">← Meniu</button><h2>${t.flag} ${t.name}</h2></div>
    <p class="hint">${t.entries.length} participări${t.best ? ` · cel mai bun rezultat: <b>${FINISH_LABEL[t.best.finish]}</b> (${t.best.year})` : ""}</p>
    ${t.entries.length ? entries : `<p class="hint">${t.name} nu a jucat încă la un turneu final.</p>`}
    ${t.absent.length ? `<p class="hint">Absentă la: ${t.absent.join(", ")}.</p>` : ""}
    ${picker}
    <p class="hint credits">Date meci cu meci 1930-2022: Fjelstul World Cup Database, CC-BY-SA 4.0.</p>
  </div>`;
}

/* ============================================================
   ECRAN: EVOLUȚIA REGULILOR
   ============================================================ */
function renderRules() {
  const eras = RULES_TIMELINE.map((e) => `
    <div class="card rules-era">
      <div class="rules-years">${e.years}</div>
      <div class="rules-title">${e.title}</div>
      <ul class="story-list">${e.items.map((x) => `<li>${x}</li>`).join("")}</ul>
    </div>`).join("");
  const squads = SQUAD_RULES.map((q) => `<li><b>${q.years} — ${q.size} de jucători.</b> ${q.text}</li>`).join("");
  const families = FORMAT_FAMILIES.map((f) => `<li><b>${f.years}:</b> ${f.text}</li>`).join("");
  const path = TITLE_PATH.map((t) => `<li><b>${t.years}:</b> ${t.games} meciuri</li>`).join("");
  return `
  <div class="screen">
    <div class="topbar"><button class="btn-back" data-action="menu">← Meniu</button><h2>📜 Evoluția regulilor</h2></div>
    <p class="hint">Regulile de pe teren s-au schimbat mai lent decât formatul turneului. Toate sunt aplicate în joc, pentru ediția aleasă.</p>
    ${eras}
    <div class="card rules-era"><div class="rules-title">Lotul</div><ul class="story-list">${squads}</ul></div>
    <div class="card rules-era"><div class="rules-title">Cele 7 familii de format</div><ul class="story-list">${families}</ul></div>
    <div class="card rules-era"><div class="rules-title">Câte meciuri joacă campioana</div><ul class="story-list">${path}</ul></div>
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
    MUSEUM: renderMuseum, LEGENDS: renderLegends, TROPHIES: renderTrophies, RULES: renderRules,
    QUIZ_MENU: renderQuizMenu, QUIZ_PLAY: renderQuizPlay, QUIZ_RESULT: renderQuizResult, COUNTRY: renderCountry,
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
  if (action === "rules") return goto("RULES");
  if (action === "quiz-menu") return goto("QUIZ_MENU");
  if (action === "quiz-start") return startQuiz(el.dataset.mode, el.dataset.year ? Number(el.dataset.year) : null);
  if (action === "quiz-pick") {
    const z = STATE.quiz;
    if (z.picked !== null) return;
    z.picked = Number(el.dataset.i);
    if (z.picked === z.questions[z.idx].answer) z.score++;
    return render();
  }
  if (action === "quiz-next") {
    const z = STATE.quiz;
    if (z.idx === z.questions.length - 1) return finishQuiz();
    z.idx++; z.picked = null;
    return render();
  }
  if (action === "museum-year") return goto("MUSEUM", { museumOpen: Number(el.dataset.year) });
  if (action === "country") return goto("COUNTRY", { countryIso: null });
  if (action === "play-campaign") { STATE.pickedYear = Number(el.dataset.year); return startCareer(el.dataset.code); }
  if (action === "trophies") return goto("TROPHIES");
  if (action === "menu") return goto("MENU");
  if (action === "menu-confirm") { if (confirm("Sigur vrei să părăsești cariera curentă?")) goto("MENU"); return; }
  if (action === "edition") return goto("EDITION");
  if (action === "pick-edition") return goto("TEAM", { pickedYear: Number(el.dataset.year) });
  if (action === "pick-team") return startCareer(el.dataset.code);
  if (action === "hub") return goto("HUB");
  if (action === "goto-preview") {
    STATE.tactics = { mentality: document.getElementById("sel-mentality").value, formation: document.getElementById("sel-formation").value };
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
ROOT.addEventListener("change", (e) => {
  if (e.target.id !== "sel-country") return;
  try { localStorage.setItem(COUNTRY_KEY, e.target.value); } catch (err) { /* ignorat */ }
  goto("COUNTRY", { countryIso: e.target.value });
});

initTheme();
render();
