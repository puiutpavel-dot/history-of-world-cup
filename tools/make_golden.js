// Generează vectori de referință ("golden") din motorul JS, pe care testele
// XCTest ale portului Swift trebuie să îi reproducă bit cu bit.
// Rulare: node tools/make_golden.js
const fs = require("fs");
const path = require("path");
const { P, seedFor, runCareer } = require("./career_sim");

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
const careers = [];
const combos = Object.keys(P.REAL_FIXTURES).map((k) => k.split("_")).map(([t, y]) => [t, Number(y)])
  .concat([["ITA", 1934], ["NED", 1974], ["ESP", 2010], ["MAR", 2022], ["CRO", 2018], ["USA", 1930], ["HUN", 1954], ["POL", 1974]]);
combos.forEach(([t, y], i) => {
  const k = i % 3;
  const seed = seedFor(`${t}-${y}-${k}`);
  careers.push({ tactics: k, ...runCareer(t, y, seed, tacticSets[k]) });
});
const knockoutPlans = Object.keys(P.REAL_FIXTURES).map((key) => {
  const [t, y] = key.split("_");
  return { key, plan: P.buildKnockoutPlan(t, Number(y)).map((m) => (m ? `${m.opp}${m.scoreFor}-${m.scoreAgainst}` : null)) };
});

const out = { rng, seeds, years, ratings, eligible, squadCases, matches, tacticSets, careers, knockoutPlans };
const file = path.join(__dirname, "..", "ios", "WorldCupCore", "Tests", "WorldCupCoreTests", "Resources", "Golden.json");
fs.mkdirSync(path.dirname(file), { recursive: true });
fs.writeFileSync(file, JSON.stringify(out) + "\n");
const outcomes = careers.reduce((m, c) => (m[c.outcome] = (m[c.outcome] || 0) + 1, m), {});
console.log("Golden.json", fs.statSync(file).size, "bytes;", careers.length, "cariere", outcomes);
