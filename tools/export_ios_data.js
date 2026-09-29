// Exportă datele prototipului web în JSON-urile incluse în bundle-ul iOS.
// Rulare: node tools/export_ios_data.js
// Ordinea echipelor/campaniilor e păstrată (array-uri), pentru că motorul
// depinde de ea (tragerea la sorți, rating shadow) — dicționarele Swift nu
// au ordine garantată.
const fs = require("fs");
const path = require("path");
const P = require("./load_prototype")();

const out = path.join(__dirname, "..", "ios", "WorldCupCore", "Sources", "WorldCupCore", "Resources");
fs.mkdirSync(out, { recursive: true });

const data = {
  editions: P.EDITIONS,
  teams: Object.entries(P.TEAMS).map(([code, t]) => ({
    code, name: t.name, flag: t.flag,
    curve: Object.keys(t.curve).map(Number).sort((a, b) => a - b).map((y) => ({ year: y, rating: t.curve[y] })),
  })),
  shadowTeams: Object.entries(P.SHADOW_TEAMS).map(([code, t]) => ({ code, name: t.name, flag: t.flag })),
  legends: P.LEGENDS,
};

const fixtures = Object.entries(P.REAL_FIXTURES).map(([key, c]) => {
  const [team, year] = key.split("_");
  const norm = (m) => ({ opp: m.opp, scoreFor: m.scoreFor, scoreAgainst: m.scoreAgainst, round: m.round ?? null, note: m.note ?? null });
  return { team, year: Number(year), group: c.group.map(norm), knockout: c.knockout.map(norm) };
});

const rosters = {};
for (const [key, list] of Object.entries(P.REAL_ROSTERS)) rosters[key] = list.map((p) => ({ name: p.name, pos: p.pos }));

const write = (name, obj) => {
  fs.writeFileSync(path.join(out, name), JSON.stringify(obj, null, 1) + "\n");
  console.log(name, fs.statSync(path.join(out, name)).size, "bytes");
};
write("Data.json", data);
write("RealFixtures.json", fixtures);
write("RealRosters.json", rosters);
console.log(`${data.editions.length} ediții, ${data.teams.length} echipe, ${data.shadowTeams.length} shadow, ${data.legends.length} legende, ${fixtures.length} campanii, ${Object.keys(rosters).length} loturi`);
