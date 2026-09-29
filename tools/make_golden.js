// Generează vectori de referință ("golden") din motorul JS, pe care testele
// XCTest ale portului Swift trebuie să îi reproducă bit cu bit.
// Rulare: node tools/make_golden.js
const fs = require("fs");
const path = require("path");
const P = require("./load_prototype")();
const seedFor = P.seedFor;

const years = P.EDITIONS.map((e) => e.year);
const allCodes = [...Object.keys(P.TEAMS), ...Object.keys(P.SHADOW_TEAMS)];

const rng = [0, 1, 42, 123456789, 4294967295].map((seed) => {
  const r = P.mulberry32(seed);
  return { seed, values: Array.from({ length: 20 }, () => r()) };
});
const seeds = ["BRA-1970-opp", "ARG1986aux", "Ungaria-ă-ș", "", "GER-2014-1727600000000"].map((s) => ({ input: s, seed: seedFor(s) }));
const ratings = allCodes.map((code) => ({ code, values: years.map((y) => P.getRatingAt(code, y)) }));
const eligible = years.map((y) => ({ year: y, teams: Object.keys(P.TEAMS).filter((c) => Math.min(...Object.keys(P.TEAMS[c].curve).map(Number)) <= y + 8) }));

const squadCases = [["BRA", 1970], ["ARG", 1986], ["ARG", 2022], ["GER", 1974], ["HUN", 1954], ["ESP", 1962], ["POR", 1966], ["MAR", 1930], ["PER", 1970], ["ROU", 1994], ["KOR", 2002], ["NED", 1998]]
  .map(([code, year], i) => {
    const s = P.generateSquad(code, year, P.mulberry32(1000 + i));
    return { code, year, seed: 1000 + i, players: s.map((p) => `${p.pos}|${p.name}|${p.overall}|${p.isLegend ? 1 : 0}`) };
  });

const matches = [];
const mr = P.mulberry32(777);
for (let i = 0; i < 40; i++) {
  const a = 55 + (i * 7) % 40, d = 50 + (i * 11) % 45, b = 60 + (i * 5) % 35, e = 52 + (i * 13) % 40;
  const home = [null, "A", "B"][i % 3];
  const r = P.simulateMatch("A", a, d, "B", b, e, mr, home);
  const pens = P.simulatePenalties(a, b, mr);
  matches.push({ atkA: a, defA: d, atkB: b, defB: e, home, scoreA: r.scoreA, scoreB: r.scoreB, events: r.events.map((x) => `${x.minute}${x.team}`), pens: `${pens.scoreA}-${pens.scoreB}${pens.winner}` });
}

const tacticSets = [
  [["Echilibrat", "4-4-2"]],
  [["Ofensiv", "4-3-3"], ["Defensiv", "5-3-2"], ["Echilibrat", "3-5-2"]],
  [["Defensiv", "4-4-2"], ["Ofensiv", "3-5-2"]],
];

// prelungiri + cartonașe (vectori izolați)
const extras = [];
const xr = P.mulberry32(4242);
const eleven = P.generateSquad("BRA", 1970, P.mulberry32(5)).slice(0, 11);
for (let i = 0; i < 30; i++) {
  const a = 60 + (i * 7) % 35, b = 58 + (i * 11) % 37;
  const et = P.simulateExtraTime("A", a, a, "B", b, b, xr);
  const cards = P.simulateCards(eleven, xr);
  extras.push({ a, b, et: `${et.scoreA}-${et.scoreB}:` + et.events.map((e) => `${e.minute}${e.team}`).join(","), cards: cards.map((c) => `${c.minute}${c.type}${c.k}`).join(",") });
}

// cariere complete pe formatul real: toate edițiile, echipe curate eligibile
const describeCareer = (st) => ({
  records: st.records.map((r) => [r.kind, r.round || "", r.label, r.opp, r.isReal ? 1 : 0, r.gf, r.ga, r.extraTime ? 1 : 0, r.pens || "", r.lots || "", r.replay ? 1 : 0, r.tied ? 1 : 0, r.won === null ? "" : r.won ? 1 : 0,
    r.events.map((e) => `${e.minute}${e.team}${e.scorer}`).join(","), r.cards.map((c) => `${c.minute}${c.team}${c.type}${c.player}`).join(","), r.suspended.join(",")].join("|")),
  tables: st.tables.map((t) => [t.type, t.rank, t.qualified ? 1 : 0, t.rows.map((r) => `${r.code}:${r.pl}:${r.gf}-${r.ga}:${r.pts}`).join(","),
    t.others.map((o) => `${o.home}-${o.away}:${o.gh}-${o.ga}${o.winner ? ":" + o.winner : ""}`).join(","),
    t.playoff ? (t.playoff.result ? `O:${t.playoff.result.home}-${t.playoff.result.away}:${t.playoff.result.gh}-${t.playoff.result.ga}:${t.playoff.result.winner}` : `P:${t.playoff.opp}:${t.playoff.won ? 1 : 0}`) : "", t.thirds ? `${t.thirds.rank}:` + t.thirds.rows.map((r) => `${r.code}${r.pts}/${r.gf}-${r.ga}`).join(",") : ""].join("|")),
  log: st.log.map((l) => l.bye).join(","),
  outcome: st.outcome, outStage: st.outStage || "", label: P.outcomeLabel(st), rng: st.rng,
});
const careers = [];
let n = 0;
for (const e of P.EDITIONS) {
  const teams = Object.keys(P.TEAMS).filter((c) => Math.min(...Object.keys(P.TEAMS[c].curve).map(Number)) <= e.year + 8);
  teams.forEach((t, i) => {
    if ((i + e.year) % 3 !== 0 && !P.REAL_FIXTURES[`${t}_${e.year}`]) return;
    const k = n++ % 3;
    const seed = seedFor(`${t}-${e.year}-${k}`);
    const st = P.createCareer(t, e.year, seed);
    const squad = st.squad.map((p) => `${p.pos}|${p.name}|${p.overall}|${p.isLegend ? 1 : 0}`);
    let m = 0;
    while (!st.outcome && m < 20) { const [ment, form] = tacticSets[k][m % tacticSets[k].length]; P.playNext(st, ment, form); m++; }
    careers.push({ team: t, year: e.year, seed, tactics: k, squad, ...describeCareer(st) });
  });
}
const pools = P.EDITIONS.map((e) => ({ year: e.year, pool: P.editionPool(e.year) }));

const out = { rng, seeds, years, ratings, eligible, squadCases, matches, tacticSets, extras, pools, careers };
const file = path.join(__dirname, "..", "ios", "WorldCupCore", "Tests", "WorldCupCoreTests", "Resources", "Golden.json");
fs.mkdirSync(path.dirname(file), { recursive: true });
fs.writeFileSync(file, JSON.stringify(out) + "\n");
const outcomes = careers.reduce((m, c) => (m[c.outcome] = (m[c.outcome] || 0) + 1, m), {});
console.log("Golden.json", fs.statSync(file).size, "bytes;", careers.length, "cariere", outcomes);
