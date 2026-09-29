// Încarcă fișierele prototipului web într-un context Node (fără DOM),
// expunând EDITIONS, TEAMS, LEGENDS, SHADOW_TEAMS, REAL_FIXTURES,
// REAL_ROSTERS și funcțiile din engine.js — exact ca în browser.
const fs = require("fs");
const path = require("path");
const vm = require("vm");

module.exports = function loadPrototype() {
  const root = path.join(__dirname, "..");
  const ctx = { console, Math, Object, Array, Set, JSON, Number, String };
  vm.createContext(ctx);
  for (const f of ["data.js", "real_fixtures.js", "real_rosters.js", "engine.js", "career.js", "history.js"]) {
    // `const` la nivel de script nu devine proprietate globală — îl expunem explicit.
    let src = fs.readFileSync(path.join(root, f), "utf8");
    src = src.replace(/if \(typeof module !== "undefined"[\s\S]*$/, "");
    vm.runInContext(src, ctx, { filename: f });
  }
  vm.runInContext(`this.__exports = { RULES_TIMELINE, SQUAD_RULES, FORMAT_FAMILIES, TITLE_PATH, STORIES, squadSizeFor, EDITIONS, TEAMS, LEGENDS, SHADOW_TEAMS, FORMATS, getTeamMeta, createCareer, nextMatch, playNext, outcomeLabel, editionPool, ROUND_LABEL, REAL_FIXTURES, REAL_ROSTERS,
    mulberry32, randInt, choice, getTeamRating, getShadowRating, getRatingAt, generateSquad, squadStrength,
    tacticalRatings, simulateMatch, assignScorers, simulatePenalties, poissonSample, getRealGroupOpponents,
    getRealGroupMatch, getRealKnockoutMatch, drawOpponent, fixtureKey, getRealRoster, seedFor, simulateExtraTime, simulateCards };`, ctx);
  return ctx.__exports;
};
