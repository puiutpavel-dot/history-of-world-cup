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

/* Data.json (română) și Data_en.json (engleză): aceeași structură și ordine —
   motorul nu citește textele, deci simularea e identică în ambele limbi. */
function buildData(lang) {
  const E = lang === "en" ? P.EN : null;
  const name = (code) => (E ? E.teams[code] : P.getTeamMeta(code).name);
  if (E) for (const code of [...Object.keys(P.TEAMS), ...Object.keys(P.SHADOW_TEAMS)]) {
    if (!E.teams[code]) throw new Error(`i18n_en.js: lipsește numele echipei ${code}`);
  }
  const editions = P.EDITIONS.map((e) => (E ? { ...e, ...E.editions[e.year] } : e));
  const finishLabel = E ? E.finishLabel : P.FINISH_LABEL;
  const trackRound = E ? E.trackRound : P.TRACK_ROUND;
  const note = (s) => (E ? E.note(s) : s);
  const story = (y) => (E ? E.stories[y] : P.STORIES[y]);
  const quizText = E ? { ...E.quiz, editions, name } : P.QUIZ_RO;
  return {
    editions,
    teams: Object.entries(P.TEAMS).map(([code, t]) => ({
      code, name: name(code), flag: t.flag,
      curve: Object.keys(t.curve).map(Number).sort((a, b) => a - b).map((y) => ({ year: y, rating: t.curve[y] })),
    })),
    shadowTeams: Object.entries(P.SHADOW_TEAMS).map(([code, t]) => ({ code, name: name(code), flag: t.flag })),
    legends: P.LEGENDS.map((l) => (E ? { ...l, bio: E.legends[l.code] } : l)),
    formats: P.EDITIONS.map((e) => ({ year: e.year, ...P.FORMATS[e.year], ...(E ? { summary: E.formatSummary[e.year] } : {}) })),
    history: {
      rulesTimeline: E ? E.rulesTimeline : P.RULES_TIMELINE,
      squadRules: E ? E.squadRules : P.SQUAD_RULES,
      families: E ? E.families : P.FORMAT_FAMILIES,
      titlePath: E ? E.titlePath : P.TITLE_PATH,
      stories: P.EDITIONS.filter((e) => P.STORIES[e.year]).map((e) => ({ year: e.year, ...story(e.year) })),
    },
    // banca de întrebări (aceleași întrebări ca pe web, în limba cerută) și traseul fiecărei țări
    quiz: P.buildQuizBank(quizText),
    countries: Object.keys(P.COUNTRY_ISO).map((iso) => {
      const t = P.countryTrack(iso);
      return {
        iso, codes: t.codes, name: name(t.codes[0]), flag: t.flag, absent: t.absent,
        best: t.best ? { year: t.best.year, finish: t.best.finish, label: finishLabel[t.best.finish] } : null,
        entries: t.entries.map((e) => ({
          year: e.year, code: e.code, finish: e.finish, finishLabel: finishLabel[e.finish],
          matches: e.matches.map((m) => ({ round: trackRound[m.round], opp: m.opp, gf: m.gf, ga: m.ga, note: note(m.note) })),
        })),
      };
    }),
    langRegion: P.LANG_REGION,
  };
}
const data = buildData("ro");
const dataEn = buildData("en");

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
write("Data_en.json", dataEn);
write("RealFixtures.json", fixtures);
write("RealRosters.json", rosters);
console.log(`${data.editions.length} ediții, ${data.teams.length} echipe, ${data.shadowTeams.length} shadow, ${data.legends.length} legende, ${fixtures.length} campanii, ${Object.keys(rosters).length} loturi`);
