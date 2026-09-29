// Rulare "headless" a unei cariere complete, oglindind exact logica din
// app.js (startCareer → currentOpponentInfo → playCurrentMatch → afterMatch
// → finishGroupStage), fără DOM. Servește drept referință ("golden") pentru
// portul Swift (ios/WorldCupCore/Sources/WorldCupCore/Career.swift).
const loadPrototype = require("./load_prototype");
const P = loadPrototype();

function seedFor(str) {
  let h = 2166136261;
  for (let i = 0; i < str.length; i++) { h ^= str.charCodeAt(i); h = Math.imul(h, 16777619); }
  return h >>> 0;
}

/* tactics: listă de [mentalitate, formație] folosite ciclic, meci cu meci */
function runCareer(teamCode, year, seed, tactics) {
  const rng = P.mulberry32(seed);
  const squad = P.generateSquad(teamCode, year, rng);

  const realGroup = P.getRealGroupOpponents(teamCode, year);
  const usedOpponents = [teamCode];
  const groupOpponents = [];
  for (let i = 0; i < 3; i++) {
    let opp = realGroup[i];
    const isReal = !!opp;
    if (!opp) opp = P.drawOpponent(rng, year, [...usedOpponents, ...groupOpponents.map((g) => g.code)]);
    usedOpponents.push(opp);
    groupOpponents.push({ code: opp, isReal });
  }
  const knockoutPlan = P.buildKnockoutPlan(teamCode, year).map((m) => (m ? { opp: m.opp } : null));

  const c = { stage: "group", groupMatchIndex: 0, knockoutIndex: 0, groupResults: [], knockoutResults: [], outcome: null, pendingDrawn: null };
  const log = [];
  let matchNo = 0;

  function currentOpponent() {
    if (c.stage === "group") { const g = groupOpponents[c.groupMatchIndex]; return { code: g.code, isReal: g.isReal }; }
    const plan = knockoutPlan[c.knockoutIndex];
    if (plan && !usedOpponents.includes(plan.opp)) return { code: plan.opp, isReal: true };
    if (!c.pendingDrawn || c.pendingDrawn.stage !== c.stage) c.pendingDrawn = { stage: c.stage, code: P.drawOpponent(rng, year, usedOpponents) };
    return { code: c.pendingDrawn.code, isReal: false };
  }

  while (!c.outcome) {
    const [mentality, formation] = tactics[matchNo % tactics.length];
    matchNo++;
    const opp = currentOpponent();
    const oppSquad = P.generateSquad(opp.code, year, P.mulberry32(seedFor(`${opp.code}-${year}-opp`)));
    const oppR = P.tacticalRatings(oppSquad, "Echilibrat", "4-4-2");
    const yourR = P.tacticalRatings(squad, mentality, formation);
    const r = P.simulateMatch(P.TEAMS[teamCode].name, yourR.attack, yourR.defense, P.getTeamMeta(opp.code).name, oppR.attack, oppR.defense, rng, null);
    const events = P.assignScorers(r.events, squad, oppSquad, rng);
    const entry = { stage: c.stage, opp: opp.code, isReal: opp.isReal, for: r.scoreA, against: r.scoreB, events: events.map((e) => `${e.minute}${e.team}${e.scorer}`) };

    if (c.stage === "group") {
      c.groupResults.push({ opp: opp.code, for: r.scoreA, against: r.scoreB });
      c.groupMatchIndex++;
      log.push(entry);
      if (c.groupMatchIndex < 3) continue;
      // finishGroupStage
      const [o1, o2, o3] = groupOpponents.map((g) => g.code);
      const simPair = (x, y) => {
        const sx = P.generateSquad(x, year, P.mulberry32(seedFor(x + year + "aux")));
        const sy = P.generateSquad(y, year, P.mulberry32(seedFor(y + year + "aux")));
        const rx = P.tacticalRatings(sx, "Echilibrat", "4-4-2");
        const ry = P.tacticalRatings(sy, "Echilibrat", "4-4-2");
        const m = P.simulateMatch(x, rx.attack, rx.defense, y, ry.attack, ry.defense, rng, null);
        return { for: m.scoreA, against: m.scoreB };
      };
      const m12 = simPair(o1, o2), m13 = simPair(o1, o3), m23 = simPair(o2, o3);
      const table = {};
      [teamCode, o1, o2, o3].forEach((code) => { table[code] = { code, pts: 0, gf: 0, ga: 0, pl: 0 }; });
      const apply = (a, b, gfa, gfb) => {
        table[a].pl++; table[b].pl++;
        table[a].gf += gfa; table[a].ga += gfb;
        table[b].gf += gfb; table[b].ga += gfa;
        if (gfa > gfb) table[a].pts += 3; else if (gfa < gfb) table[b].pts += 3; else { table[a].pts += 1; table[b].pts += 1; }
      };
      c.groupResults.forEach((g) => apply(teamCode, g.opp, g.for, g.against));
      apply(o1, o2, m12.for, m12.against); apply(o1, o3, m13.for, m13.against); apply(o2, o3, m23.for, m23.against);
      const standings = Object.values(table).sort((a, b) => (b.pts - a.pts) || ((b.gf - b.ga) - (a.gf - a.ga)) || (b.gf - a.gf));
      c.standings = standings.map((s) => `${s.code}:${s.pl}:${s.gf}-${s.ga}:${s.pts}`);
      const rank = standings.findIndex((s) => s.code === teamCode);
      if (rank <= 1) { c.stage = "QF"; c.knockoutIndex = 0; } else c.outcome = "eliminated-group";
      continue;
    }
    // knockout
    let won;
    if (r.scoreA === r.scoreB) {
      const pens = P.simulatePenalties(yourR.attack, oppR.attack, rng);
      entry.pens = `${pens.scoreA}-${pens.scoreB}`;
      won = pens.winner === "A";
    } else won = r.scoreA > r.scoreB;
    log.push(entry);
    usedOpponents.push(opp.code);
    if (!won) { c.outcome = "eliminated-knockout"; break; }
    if (c.stage === "F") { c.outcome = "champion"; break; }
    c.stage = c.stage === "QF" ? "SF" : "F";
    c.knockoutIndex++;
  }
  return {
    team: teamCode, year, seed,
    squad: squad.map((p) => `${p.pos}|${p.name}|${p.overall}|${p.isLegend ? 1 : 0}`),
    groupOpponents: groupOpponents.map((g) => `${g.code}${g.isReal ? "*" : ""}`),
    matches: log, standings: c.standings || null, outcome: c.outcome, finalStage: c.stage,
  };
}

module.exports = { P, seedFor, runCareer };
