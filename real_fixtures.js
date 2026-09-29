/* ============================================================
   HISTORY OF WORLD CUP — real_fixtures.js  (FIȘIER GENERAT)
   Generat de tools/build_real_fixtures.py — nu edita manual;
   notele scrise de mână (ex. „Maracanazo”) sunt păstrate la regenerare.

   Traseul real al fiecăreia dintre cele 23 națiuni curate la fiecare
   ediție la care a participat: 278 campanii, 1209 meciuri reale.

   Sursa: Fjelstul World Cup Database, © 2023 Joshua C. Fjelstul, Ph.D.,
   https://www.github.com/jfjelstul/worldcup — licență CC-BY-SA 4.0
   (https://creativecommons.org/licenses/by-sa/4.0/legalcode).
   Modificări: selecție pe echipele jocului, coduri FIFA, mapare pe
   bracketul jocului, note în română. Acest fișier de date este, la rândul
   lui, distribuit sub CC-BY-SA 4.0.

   Cheie: "<COD_ECHIPA>_<AN>". group = meciuri din grupă, knockout = restul
   drumului, cu round = R32/R16/QF/GR2/FR/SF/3P/F. Motorul de carieră
   (career.js) ia adversarul real pentru fiecare etapă a formatului ediției.
   Scorurile sunt informative (comparate cu rezultatul simulat) — NU
   determină simularea.
   ============================================================ */

const REAL_FIXTURES = {

  ARG_1930: {
    group: [
      { opp: "FRA", scoreFor: 1, scoreAgainst: 0 },
      { opp: "MEX", scoreFor: 6, scoreAgainst: 3 },
      { opp: "CHI", scoreFor: 3, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "SF", opp: "USA", scoreFor: 6, scoreAgainst: 1 },
      { round: "F", opp: "URU", scoreFor: 2, scoreAgainst: 4 },
    ],
  },

  BEL_1930: {
    group: [
      { opp: "USA", scoreFor: 0, scoreAgainst: 3 },
      { opp: "PAR", scoreFor: 0, scoreAgainst: 1 },
    ],
    knockout: [
    ],
  },

  BRA_1930: {
    group: [
      { opp: "YUG", scoreFor: 1, scoreAgainst: 2 },
      { opp: "BOL", scoreFor: 4, scoreAgainst: 0 },
    ],
    knockout: [
    ],
  },

  FRA_1930: {
    group: [
      { opp: "MEX", scoreFor: 4, scoreAgainst: 1 },
      { opp: "ARG", scoreFor: 0, scoreAgainst: 1 },
      { opp: "CHI", scoreFor: 0, scoreAgainst: 1 },
    ],
    knockout: [
    ],
  },

  MEX_1930: {
    group: [
      { opp: "FRA", scoreFor: 1, scoreAgainst: 4 },
      { opp: "CHI", scoreFor: 0, scoreAgainst: 3 },
      { opp: "ARG", scoreFor: 3, scoreAgainst: 6 },
    ],
    knockout: [
    ],
  },

  URU_1930: {
    group: [
      { opp: "PER", scoreFor: 1, scoreAgainst: 0 },
      { opp: "ROU", scoreFor: 4, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "SF", opp: "YUG", scoreFor: 6, scoreAgainst: 1 },
      { round: "F", opp: "ARG", scoreFor: 4, scoreAgainst: 2 },
    ],
  },

  USA_1930: {
    group: [
      { opp: "BEL", scoreFor: 3, scoreAgainst: 0 },
      { opp: "PAR", scoreFor: 3, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "SF", opp: "ARG", scoreFor: 1, scoreAgainst: 6 },
    ],
  },

  ARG_1934: {
    group: [
    ],
    knockout: [
      { round: "R16", opp: "SWE", scoreFor: 2, scoreAgainst: 3 },
    ],
  },

  AUT_1934: {
    group: [
    ],
    knockout: [
      { round: "R16", opp: "FRA", scoreFor: 3, scoreAgainst: 2, note: "prelungiri" },
      { round: "QF", opp: "HUN", scoreFor: 2, scoreAgainst: 1 },
      { round: "SF", opp: "ITA", scoreFor: 0, scoreAgainst: 1 },
      { round: "3P", opp: "GER", scoreFor: 2, scoreAgainst: 3 },
    ],
  },

  BEL_1934: {
    group: [
    ],
    knockout: [
      { round: "R16", opp: "GER", scoreFor: 2, scoreAgainst: 5 },
    ],
  },

  BRA_1934: {
    group: [
    ],
    knockout: [
      { round: "R16", opp: "ESP", scoreFor: 1, scoreAgainst: 3 },
    ],
  },

  ESP_1934: {
    group: [
    ],
    knockout: [
      { round: "R16", opp: "BRA", scoreFor: 3, scoreAgainst: 1 },
      { round: "QF", opp: "ITA", scoreFor: 0, scoreAgainst: 1, note: "meci rejucat" },
    ],
  },

  FRA_1934: {
    group: [
    ],
    knockout: [
      { round: "R16", opp: "AUT", scoreFor: 2, scoreAgainst: 3, note: "prelungiri" },
    ],
  },

  GER_1934: {
    group: [
    ],
    knockout: [
      { round: "R16", opp: "BEL", scoreFor: 5, scoreAgainst: 2 },
      { round: "QF", opp: "SWE", scoreFor: 2, scoreAgainst: 1 },
      { round: "SF", opp: "TCH", scoreFor: 1, scoreAgainst: 3 },
      { round: "3P", opp: "AUT", scoreFor: 3, scoreAgainst: 2 },
    ],
  },

  HUN_1934: {
    group: [
    ],
    knockout: [
      { round: "R16", opp: "EGY", scoreFor: 4, scoreAgainst: 2 },
      { round: "QF", opp: "AUT", scoreFor: 1, scoreAgainst: 2 },
    ],
  },

  ITA_1934: {
    group: [
    ],
    knockout: [
      { round: "R16", opp: "USA", scoreFor: 7, scoreAgainst: 1 },
      { round: "QF", opp: "ESP", scoreFor: 1, scoreAgainst: 0, note: "meci rejucat" },
      { round: "SF", opp: "AUT", scoreFor: 1, scoreAgainst: 0 },
      { round: "F", opp: "TCH", scoreFor: 2, scoreAgainst: 1, note: "prelungiri" },
    ],
  },

  NED_1934: {
    group: [
    ],
    knockout: [
      { round: "R16", opp: "SUI", scoreFor: 2, scoreAgainst: 3 },
    ],
  },

  SWE_1934: {
    group: [
    ],
    knockout: [
      { round: "R16", opp: "ARG", scoreFor: 3, scoreAgainst: 2 },
      { round: "QF", opp: "GER", scoreFor: 1, scoreAgainst: 2 },
    ],
  },

  TCH_1934: {
    group: [
    ],
    knockout: [
      { round: "R16", opp: "ROU", scoreFor: 2, scoreAgainst: 1 },
      { round: "QF", opp: "SUI", scoreFor: 3, scoreAgainst: 2 },
      { round: "SF", opp: "GER", scoreFor: 3, scoreAgainst: 1 },
      { round: "F", opp: "ITA", scoreFor: 1, scoreAgainst: 2, note: "prelungiri" },
    ],
  },

  USA_1934: {
    group: [
    ],
    knockout: [
      { round: "R16", opp: "ITA", scoreFor: 1, scoreAgainst: 7 },
    ],
  },

  BEL_1938: {
    group: [
    ],
    knockout: [
      { round: "R16", opp: "FRA", scoreFor: 1, scoreAgainst: 3 },
    ],
  },

  BRA_1938: {
    group: [
    ],
    knockout: [
      { round: "R16", opp: "POL", scoreFor: 6, scoreAgainst: 5, note: "prelungiri" },
      { round: "QF", opp: "TCH", scoreFor: 2, scoreAgainst: 1, note: "meci rejucat" },
      { round: "SF", opp: "ITA", scoreFor: 1, scoreAgainst: 2 },
      { round: "3P", opp: "SWE", scoreFor: 4, scoreAgainst: 2 },
    ],
  },

  FRA_1938: {
    group: [
    ],
    knockout: [
      { round: "R16", opp: "BEL", scoreFor: 3, scoreAgainst: 1 },
      { round: "QF", opp: "ITA", scoreFor: 1, scoreAgainst: 3 },
    ],
  },

  GER_1938: {
    group: [
    ],
    knockout: [
      { round: "R16", opp: "SUI", scoreFor: 2, scoreAgainst: 4, note: "meci rejucat" },
    ],
  },

  HUN_1938: {
    group: [
    ],
    knockout: [
      { round: "R16", opp: "DEI", scoreFor: 6, scoreAgainst: 0 },
      { round: "QF", opp: "SUI", scoreFor: 2, scoreAgainst: 0 },
      { round: "SF", opp: "SWE", scoreFor: 5, scoreAgainst: 1 },
      { round: "F", opp: "ITA", scoreFor: 2, scoreAgainst: 4 },
    ],
  },

  ITA_1938: {
    group: [
    ],
    knockout: [
      { round: "R16", opp: "NOR", scoreFor: 2, scoreAgainst: 1, note: "prelungiri" },
      { round: "QF", opp: "FRA", scoreFor: 3, scoreAgainst: 1 },
      { round: "SF", opp: "BRA", scoreFor: 2, scoreAgainst: 1 },
      { round: "F", opp: "HUN", scoreFor: 4, scoreAgainst: 2 },
    ],
  },

  NED_1938: {
    group: [
    ],
    knockout: [
      { round: "R16", opp: "TCH", scoreFor: 0, scoreAgainst: 3, note: "prelungiri" },
    ],
  },

  POL_1938: {
    group: [
    ],
    knockout: [
      { round: "R16", opp: "BRA", scoreFor: 5, scoreAgainst: 6, note: "prelungiri" },
    ],
  },

  SWE_1938: {
    group: [
    ],
    knockout: [
      { round: "QF", opp: "CUB", scoreFor: 8, scoreAgainst: 0 },
      { round: "SF", opp: "HUN", scoreFor: 1, scoreAgainst: 5 },
      { round: "3P", opp: "BRA", scoreFor: 2, scoreAgainst: 4 },
    ],
  },

  TCH_1938: {
    group: [
    ],
    knockout: [
      { round: "R16", opp: "NED", scoreFor: 3, scoreAgainst: 0, note: "prelungiri" },
      { round: "QF", opp: "BRA", scoreFor: 1, scoreAgainst: 2, note: "meci rejucat" },
    ],
  },

  BRA_1950: {
    group: [
      { opp: "MEX", scoreFor: 4, scoreAgainst: 0 },
      { opp: "SUI", scoreFor: 2, scoreAgainst: 2 },
      { opp: "YUG", scoreFor: 2, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "FR", opp: "SWE", scoreFor: 7, scoreAgainst: 1, note: "grupă finală round-robin, mapată ca eliminatorii" },
      { round: "FR", opp: "ESP", scoreFor: 6, scoreAgainst: 1 },
      { round: "FR", opp: "URU", scoreFor: 1, scoreAgainst: 2, note: "\"Maracanazo\" — meciul decisiv al grupei finale" },
    ],
  },

  ENG_1950: {
    group: [
      { opp: "CHI", scoreFor: 2, scoreAgainst: 0 },
      { opp: "USA", scoreFor: 0, scoreAgainst: 1 },
      { opp: "ESP", scoreFor: 0, scoreAgainst: 1 },
    ],
    knockout: [
    ],
  },

  ESP_1950: {
    group: [
      { opp: "USA", scoreFor: 3, scoreAgainst: 1 },
      { opp: "CHI", scoreFor: 2, scoreAgainst: 0 },
      { opp: "ENG", scoreFor: 1, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "FR", opp: "URU", scoreFor: 2, scoreAgainst: 2 },
      { round: "FR", opp: "BRA", scoreFor: 1, scoreAgainst: 6 },
      { round: "FR", opp: "SWE", scoreFor: 1, scoreAgainst: 3 },
    ],
  },

  ITA_1950: {
    group: [
      { opp: "SWE", scoreFor: 2, scoreAgainst: 3 },
      { opp: "PAR", scoreFor: 2, scoreAgainst: 0 },
    ],
    knockout: [
    ],
  },

  MEX_1950: {
    group: [
      { opp: "BRA", scoreFor: 0, scoreAgainst: 4 },
      { opp: "YUG", scoreFor: 1, scoreAgainst: 4 },
      { opp: "SUI", scoreFor: 1, scoreAgainst: 2 },
    ],
    knockout: [
    ],
  },

  SWE_1950: {
    group: [
      { opp: "ITA", scoreFor: 3, scoreAgainst: 2 },
      { opp: "PAR", scoreFor: 2, scoreAgainst: 2 },
    ],
    knockout: [
      { round: "FR", opp: "BRA", scoreFor: 1, scoreAgainst: 7 },
      { round: "FR", opp: "URU", scoreFor: 2, scoreAgainst: 3 },
      { round: "FR", opp: "ESP", scoreFor: 3, scoreAgainst: 1 },
    ],
  },

  URU_1950: {
    group: [
      { opp: "BOL", scoreFor: 8, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "FR", opp: "ESP", scoreFor: 2, scoreAgainst: 2 },
      { round: "FR", opp: "SWE", scoreFor: 3, scoreAgainst: 2 },
      { round: "FR", opp: "BRA", scoreFor: 2, scoreAgainst: 1 },
    ],
  },

  USA_1950: {
    group: [
      { opp: "ESP", scoreFor: 1, scoreAgainst: 3 },
      { opp: "ENG", scoreFor: 1, scoreAgainst: 0 },
      { opp: "CHI", scoreFor: 2, scoreAgainst: 5 },
    ],
    knockout: [
    ],
  },

  AUT_1954: {
    group: [
      { opp: "SCO", scoreFor: 1, scoreAgainst: 0 },
      { opp: "TCH", scoreFor: 5, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "QF", opp: "SUI", scoreFor: 7, scoreAgainst: 5 },
      { round: "SF", opp: "GER", scoreFor: 1, scoreAgainst: 6 },
      { round: "3P", opp: "URU", scoreFor: 3, scoreAgainst: 1 },
    ],
  },

  BEL_1954: {
    group: [
      { opp: "ENG", scoreFor: 4, scoreAgainst: 4, note: "prelungiri" },
      { opp: "ITA", scoreFor: 1, scoreAgainst: 4 },
    ],
    knockout: [
    ],
  },

  BRA_1954: {
    group: [
      { opp: "MEX", scoreFor: 5, scoreAgainst: 0 },
      { opp: "YUG", scoreFor: 1, scoreAgainst: 1, note: "prelungiri" },
    ],
    knockout: [
      { round: "QF", opp: "HUN", scoreFor: 2, scoreAgainst: 4 },
    ],
  },

  ENG_1954: {
    group: [
      { opp: "BEL", scoreFor: 4, scoreAgainst: 4, note: "prelungiri" },
      { opp: "SUI", scoreFor: 2, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "QF", opp: "URU", scoreFor: 2, scoreAgainst: 4 },
    ],
  },

  FRA_1954: {
    group: [
      { opp: "YUG", scoreFor: 0, scoreAgainst: 1 },
      { opp: "MEX", scoreFor: 3, scoreAgainst: 2 },
    ],
    knockout: [
    ],
  },

  GER_1954: {
    group: [
      { opp: "TUR", scoreFor: 4, scoreAgainst: 1 },
      { opp: "HUN", scoreFor: 3, scoreAgainst: 8 },
      { opp: "TUR", scoreFor: 7, scoreAgainst: 2, note: "baraj de grupă" },
    ],
    knockout: [
      { round: "QF", opp: "YUG", scoreFor: 2, scoreAgainst: 0 },
      { round: "SF", opp: "AUT", scoreFor: 6, scoreAgainst: 1 },
      { round: "F", opp: "HUN", scoreFor: 3, scoreAgainst: 2, note: "\"Miracolul de la Berna\"" },
    ],
  },

  HUN_1954: {
    group: [
      { opp: "KOR", scoreFor: 9, scoreAgainst: 0 },
      { opp: "GER", scoreFor: 8, scoreAgainst: 3 },
    ],
    knockout: [
      { round: "QF", opp: "BRA", scoreFor: 4, scoreAgainst: 2 },
      { round: "SF", opp: "URU", scoreFor: 4, scoreAgainst: 2, note: "prelungiri" },
      { round: "F", opp: "GER", scoreFor: 2, scoreAgainst: 3 },
    ],
  },

  ITA_1954: {
    group: [
      { opp: "SUI", scoreFor: 1, scoreAgainst: 2 },
      { opp: "BEL", scoreFor: 4, scoreAgainst: 1 },
      { opp: "SUI", scoreFor: 1, scoreAgainst: 4 },
    ],
    knockout: [
    ],
  },

  KOR_1954: {
    group: [
      { opp: "HUN", scoreFor: 0, scoreAgainst: 9 },
      { opp: "TUR", scoreFor: 0, scoreAgainst: 7 },
    ],
    knockout: [
    ],
  },

  MEX_1954: {
    group: [
      { opp: "BRA", scoreFor: 0, scoreAgainst: 5 },
      { opp: "FRA", scoreFor: 2, scoreAgainst: 3 },
    ],
    knockout: [
    ],
  },

  TCH_1954: {
    group: [
      { opp: "URU", scoreFor: 0, scoreAgainst: 2 },
      { opp: "AUT", scoreFor: 0, scoreAgainst: 5 },
    ],
    knockout: [
    ],
  },

  TUR_1954: {
    group: [
      { opp: "GER", scoreFor: 1, scoreAgainst: 4 },
      { opp: "KOR", scoreFor: 7, scoreAgainst: 0 },
      { opp: "GER", scoreFor: 2, scoreAgainst: 7 },
    ],
    knockout: [
    ],
  },

  URU_1954: {
    group: [
      { opp: "TCH", scoreFor: 2, scoreAgainst: 0 },
      { opp: "SCO", scoreFor: 7, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "QF", opp: "ENG", scoreFor: 4, scoreAgainst: 2 },
      { round: "SF", opp: "HUN", scoreFor: 2, scoreAgainst: 4, note: "prelungiri" },
      { round: "3P", opp: "AUT", scoreFor: 1, scoreAgainst: 3 },
    ],
  },

  ARG_1958: {
    group: [
      { opp: "GER", scoreFor: 1, scoreAgainst: 3 },
      { opp: "NIR", scoreFor: 3, scoreAgainst: 1 },
      { opp: "TCH", scoreFor: 1, scoreAgainst: 6 },
    ],
    knockout: [
    ],
  },

  AUT_1958: {
    group: [
      { opp: "BRA", scoreFor: 0, scoreAgainst: 3 },
      { opp: "URS", scoreFor: 0, scoreAgainst: 2 },
      { opp: "ENG", scoreFor: 2, scoreAgainst: 2 },
    ],
    knockout: [
    ],
  },

  BRA_1958: {
    group: [
      { opp: "AUT", scoreFor: 3, scoreAgainst: 0 },
      { opp: "ENG", scoreFor: 0, scoreAgainst: 0 },
      { opp: "URS", scoreFor: 2, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "QF", opp: "WAL", scoreFor: 1, scoreAgainst: 0 },
      { round: "SF", opp: "FRA", scoreFor: 5, scoreAgainst: 2 },
      { round: "F", opp: "SWE", scoreFor: 5, scoreAgainst: 2 },
    ],
  },

  ENG_1958: {
    group: [
      { opp: "URS", scoreFor: 2, scoreAgainst: 2 },
      { opp: "BRA", scoreFor: 0, scoreAgainst: 0 },
      { opp: "AUT", scoreFor: 2, scoreAgainst: 2 },
      { opp: "URS", scoreFor: 0, scoreAgainst: 1 },
    ],
    knockout: [
    ],
  },

  FRA_1958: {
    group: [
      { opp: "PAR", scoreFor: 7, scoreAgainst: 3 },
      { opp: "YUG", scoreFor: 2, scoreAgainst: 3 },
      { opp: "SCO", scoreFor: 2, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "QF", opp: "NIR", scoreFor: 4, scoreAgainst: 0 },
      { round: "SF", opp: "BRA", scoreFor: 2, scoreAgainst: 5 },
      { round: "3P", opp: "GER", scoreFor: 6, scoreAgainst: 3 },
    ],
  },

  GER_1958: {
    group: [
      { opp: "ARG", scoreFor: 3, scoreAgainst: 1 },
      { opp: "TCH", scoreFor: 2, scoreAgainst: 2 },
      { opp: "NIR", scoreFor: 2, scoreAgainst: 2 },
    ],
    knockout: [
      { round: "QF", opp: "YUG", scoreFor: 1, scoreAgainst: 0 },
      { round: "SF", opp: "SWE", scoreFor: 1, scoreAgainst: 3 },
      { round: "3P", opp: "FRA", scoreFor: 3, scoreAgainst: 6 },
    ],
  },

  HUN_1958: {
    group: [
      { opp: "WAL", scoreFor: 1, scoreAgainst: 1 },
      { opp: "SWE", scoreFor: 1, scoreAgainst: 2 },
      { opp: "MEX", scoreFor: 4, scoreAgainst: 0 },
      { opp: "WAL", scoreFor: 1, scoreAgainst: 2 },
    ],
    knockout: [
    ],
  },

  MEX_1958: {
    group: [
      { opp: "SWE", scoreFor: 0, scoreAgainst: 3 },
      { opp: "WAL", scoreFor: 1, scoreAgainst: 1 },
      { opp: "HUN", scoreFor: 0, scoreAgainst: 4 },
    ],
    knockout: [
    ],
  },

  SWE_1958: {
    group: [
      { opp: "MEX", scoreFor: 3, scoreAgainst: 0 },
      { opp: "HUN", scoreFor: 2, scoreAgainst: 1 },
      { opp: "WAL", scoreFor: 0, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "QF", opp: "URS", scoreFor: 2, scoreAgainst: 0 },
      { round: "SF", opp: "GER", scoreFor: 3, scoreAgainst: 1 },
      { round: "F", opp: "BRA", scoreFor: 2, scoreAgainst: 5 },
    ],
  },

  TCH_1958: {
    group: [
      { opp: "NIR", scoreFor: 0, scoreAgainst: 1 },
      { opp: "GER", scoreFor: 2, scoreAgainst: 2 },
      { opp: "ARG", scoreFor: 6, scoreAgainst: 1 },
      { opp: "NIR", scoreFor: 1, scoreAgainst: 2, note: "prelungiri" },
    ],
    knockout: [
    ],
  },

  ARG_1962: {
    group: [
      { opp: "BUL", scoreFor: 1, scoreAgainst: 0 },
      { opp: "ENG", scoreFor: 1, scoreAgainst: 3 },
      { opp: "HUN", scoreFor: 0, scoreAgainst: 0 },
    ],
    knockout: [
    ],
  },

  BRA_1962: {
    group: [
      { opp: "MEX", scoreFor: 2, scoreAgainst: 0 },
      { opp: "TCH", scoreFor: 0, scoreAgainst: 0 },
      { opp: "ESP", scoreFor: 2, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "QF", opp: "ENG", scoreFor: 3, scoreAgainst: 1 },
      { round: "SF", opp: "CHI", scoreFor: 4, scoreAgainst: 2 },
      { round: "F", opp: "TCH", scoreFor: 3, scoreAgainst: 1 },
    ],
  },

  ENG_1962: {
    group: [
      { opp: "HUN", scoreFor: 1, scoreAgainst: 2 },
      { opp: "ARG", scoreFor: 3, scoreAgainst: 1 },
      { opp: "BUL", scoreFor: 0, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "QF", opp: "BRA", scoreFor: 1, scoreAgainst: 3 },
    ],
  },

  ESP_1962: {
    group: [
      { opp: "TCH", scoreFor: 0, scoreAgainst: 1 },
      { opp: "MEX", scoreFor: 1, scoreAgainst: 0 },
      { opp: "BRA", scoreFor: 1, scoreAgainst: 2 },
    ],
    knockout: [
    ],
  },

  GER_1962: {
    group: [
      { opp: "ITA", scoreFor: 0, scoreAgainst: 0 },
      { opp: "SUI", scoreFor: 2, scoreAgainst: 1 },
      { opp: "CHI", scoreFor: 2, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "QF", opp: "YUG", scoreFor: 0, scoreAgainst: 1 },
    ],
  },

  HUN_1962: {
    group: [
      { opp: "ENG", scoreFor: 2, scoreAgainst: 1 },
      { opp: "BUL", scoreFor: 6, scoreAgainst: 1 },
      { opp: "ARG", scoreFor: 0, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "QF", opp: "TCH", scoreFor: 0, scoreAgainst: 1 },
    ],
  },

  ITA_1962: {
    group: [
      { opp: "GER", scoreFor: 0, scoreAgainst: 0 },
      { opp: "CHI", scoreFor: 0, scoreAgainst: 2 },
      { opp: "SUI", scoreFor: 3, scoreAgainst: 0 },
    ],
    knockout: [
    ],
  },

  MEX_1962: {
    group: [
      { opp: "BRA", scoreFor: 0, scoreAgainst: 2 },
      { opp: "ESP", scoreFor: 0, scoreAgainst: 1 },
      { opp: "TCH", scoreFor: 3, scoreAgainst: 1 },
    ],
    knockout: [
    ],
  },

  TCH_1962: {
    group: [
      { opp: "ESP", scoreFor: 1, scoreAgainst: 0 },
      { opp: "BRA", scoreFor: 0, scoreAgainst: 0 },
      { opp: "MEX", scoreFor: 1, scoreAgainst: 3 },
    ],
    knockout: [
      { round: "QF", opp: "HUN", scoreFor: 1, scoreAgainst: 0 },
      { round: "SF", opp: "YUG", scoreFor: 3, scoreAgainst: 1 },
      { round: "F", opp: "BRA", scoreFor: 1, scoreAgainst: 3 },
    ],
  },

  URU_1962: {
    group: [
      { opp: "COL", scoreFor: 2, scoreAgainst: 1 },
      { opp: "YUG", scoreFor: 1, scoreAgainst: 3 },
      { opp: "URS", scoreFor: 1, scoreAgainst: 2 },
    ],
    knockout: [
    ],
  },

  ARG_1966: {
    group: [
      { opp: "ESP", scoreFor: 2, scoreAgainst: 1 },
      { opp: "GER", scoreFor: 0, scoreAgainst: 0 },
      { opp: "SUI", scoreFor: 2, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "QF", opp: "ENG", scoreFor: 0, scoreAgainst: 1 },
    ],
  },

  BRA_1966: {
    group: [
      { opp: "BUL", scoreFor: 2, scoreAgainst: 0 },
      { opp: "HUN", scoreFor: 1, scoreAgainst: 3 },
      { opp: "POR", scoreFor: 1, scoreAgainst: 3 },
    ],
    knockout: [
    ],
  },

  ENG_1966: {
    group: [
      { opp: "URU", scoreFor: 0, scoreAgainst: 0 },
      { opp: "MEX", scoreFor: 2, scoreAgainst: 0 },
      { opp: "FRA", scoreFor: 2, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "QF", opp: "ARG", scoreFor: 1, scoreAgainst: 0 },
      { round: "SF", opp: "POR", scoreFor: 2, scoreAgainst: 1 },
      { round: "F", opp: "GER", scoreFor: 4, scoreAgainst: 2, note: "prelungiri" },
    ],
  },

  ESP_1966: {
    group: [
      { opp: "ARG", scoreFor: 1, scoreAgainst: 2 },
      { opp: "SUI", scoreFor: 2, scoreAgainst: 1 },
      { opp: "GER", scoreFor: 1, scoreAgainst: 2 },
    ],
    knockout: [
    ],
  },

  FRA_1966: {
    group: [
      { opp: "MEX", scoreFor: 1, scoreAgainst: 1 },
      { opp: "URU", scoreFor: 1, scoreAgainst: 2 },
      { opp: "ENG", scoreFor: 0, scoreAgainst: 2 },
    ],
    knockout: [
    ],
  },

  GER_1966: {
    group: [
      { opp: "SUI", scoreFor: 5, scoreAgainst: 0 },
      { opp: "ARG", scoreFor: 0, scoreAgainst: 0 },
      { opp: "ESP", scoreFor: 2, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "QF", opp: "URU", scoreFor: 4, scoreAgainst: 0 },
      { round: "SF", opp: "URS", scoreFor: 2, scoreAgainst: 1 },
      { round: "F", opp: "ENG", scoreFor: 2, scoreAgainst: 4, note: "prelungiri" },
    ],
  },

  HUN_1966: {
    group: [
      { opp: "POR", scoreFor: 1, scoreAgainst: 3 },
      { opp: "BRA", scoreFor: 3, scoreAgainst: 1 },
      { opp: "BUL", scoreFor: 3, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "QF", opp: "URS", scoreFor: 1, scoreAgainst: 2 },
    ],
  },

  ITA_1966: {
    group: [
      { opp: "CHI", scoreFor: 2, scoreAgainst: 0 },
      { opp: "URS", scoreFor: 0, scoreAgainst: 1 },
      { opp: "PRK", scoreFor: 0, scoreAgainst: 1 },
    ],
    knockout: [
    ],
  },

  MEX_1966: {
    group: [
      { opp: "FRA", scoreFor: 1, scoreAgainst: 1 },
      { opp: "ENG", scoreFor: 0, scoreAgainst: 2 },
      { opp: "URU", scoreFor: 0, scoreAgainst: 0 },
    ],
    knockout: [
    ],
  },

  POR_1966: {
    group: [
      { opp: "HUN", scoreFor: 3, scoreAgainst: 1 },
      { opp: "BUL", scoreFor: 3, scoreAgainst: 0 },
      { opp: "BRA", scoreFor: 3, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "QF", opp: "PRK", scoreFor: 5, scoreAgainst: 3 },
      { round: "SF", opp: "ENG", scoreFor: 1, scoreAgainst: 2 },
      { round: "3P", opp: "URS", scoreFor: 2, scoreAgainst: 1 },
    ],
  },

  URU_1966: {
    group: [
      { opp: "ENG", scoreFor: 0, scoreAgainst: 0 },
      { opp: "FRA", scoreFor: 2, scoreAgainst: 1 },
      { opp: "MEX", scoreFor: 0, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "QF", opp: "GER", scoreFor: 0, scoreAgainst: 4 },
    ],
  },

  BEL_1970: {
    group: [
      { opp: "SLV", scoreFor: 3, scoreAgainst: 0 },
      { opp: "URS", scoreFor: 1, scoreAgainst: 4 },
      { opp: "MEX", scoreFor: 0, scoreAgainst: 1 },
    ],
    knockout: [
    ],
  },

  BRA_1970: {
    group: [
      { opp: "TCH", scoreFor: 4, scoreAgainst: 1 },
      { opp: "ENG", scoreFor: 1, scoreAgainst: 0 },
      { opp: "ROU", scoreFor: 3, scoreAgainst: 2 },
    ],
    knockout: [
      { round: "QF", opp: "PER", scoreFor: 4, scoreAgainst: 2 },
      { round: "SF", opp: "URU", scoreFor: 3, scoreAgainst: 1 },
      { round: "F", opp: "ITA", scoreFor: 4, scoreAgainst: 1 },
    ],
  },

  ENG_1970: {
    group: [
      { opp: "ROU", scoreFor: 1, scoreAgainst: 0 },
      { opp: "BRA", scoreFor: 0, scoreAgainst: 1 },
      { opp: "TCH", scoreFor: 1, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "QF", opp: "GER", scoreFor: 2, scoreAgainst: 3, note: "prelungiri" },
    ],
  },

  GER_1970: {
    group: [
      { opp: "MAR", scoreFor: 2, scoreAgainst: 1 },
      { opp: "BUL", scoreFor: 5, scoreAgainst: 2 },
      { opp: "PER", scoreFor: 3, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "QF", opp: "ENG", scoreFor: 3, scoreAgainst: 2, note: "prelungiri" },
      { round: "SF", opp: "ITA", scoreFor: 3, scoreAgainst: 4, note: "prelungiri" },
      { round: "3P", opp: "URU", scoreFor: 1, scoreAgainst: 0 },
    ],
  },

  ITA_1970: {
    group: [
      { opp: "SWE", scoreFor: 1, scoreAgainst: 0 },
      { opp: "URU", scoreFor: 0, scoreAgainst: 0 },
      { opp: "ISR", scoreFor: 0, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "QF", opp: "MEX", scoreFor: 4, scoreAgainst: 1 },
      { round: "SF", opp: "GER", scoreFor: 4, scoreAgainst: 3, note: "prelungiri" },
      { round: "F", opp: "BRA", scoreFor: 1, scoreAgainst: 4 },
    ],
  },

  MAR_1970: {
    group: [
      { opp: "GER", scoreFor: 1, scoreAgainst: 2 },
      { opp: "PER", scoreFor: 0, scoreAgainst: 3 },
      { opp: "BUL", scoreFor: 1, scoreAgainst: 1 },
    ],
    knockout: [
    ],
  },

  MEX_1970: {
    group: [
      { opp: "URS", scoreFor: 0, scoreAgainst: 0 },
      { opp: "SLV", scoreFor: 4, scoreAgainst: 0 },
      { opp: "BEL", scoreFor: 1, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "QF", opp: "ITA", scoreFor: 1, scoreAgainst: 4 },
    ],
  },

  SWE_1970: {
    group: [
      { opp: "ITA", scoreFor: 0, scoreAgainst: 1 },
      { opp: "ISR", scoreFor: 1, scoreAgainst: 1 },
      { opp: "URU", scoreFor: 1, scoreAgainst: 0 },
    ],
    knockout: [
    ],
  },

  TCH_1970: {
    group: [
      { opp: "BRA", scoreFor: 1, scoreAgainst: 4 },
      { opp: "ROU", scoreFor: 1, scoreAgainst: 2 },
      { opp: "ENG", scoreFor: 0, scoreAgainst: 1 },
    ],
    knockout: [
    ],
  },

  URU_1970: {
    group: [
      { opp: "ISR", scoreFor: 2, scoreAgainst: 0 },
      { opp: "ITA", scoreFor: 0, scoreAgainst: 0 },
      { opp: "SWE", scoreFor: 0, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "QF", opp: "URS", scoreFor: 1, scoreAgainst: 0, note: "prelungiri" },
      { round: "SF", opp: "BRA", scoreFor: 1, scoreAgainst: 3 },
      { round: "3P", opp: "GER", scoreFor: 0, scoreAgainst: 1 },
    ],
  },

  ARG_1974: {
    group: [
      { opp: "POL", scoreFor: 2, scoreAgainst: 3 },
      { opp: "ITA", scoreFor: 1, scoreAgainst: 1 },
      { opp: "HAI", scoreFor: 4, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "GR2", opp: "NED", scoreFor: 0, scoreAgainst: 4 },
      { round: "GR2", opp: "BRA", scoreFor: 1, scoreAgainst: 2 },
      { round: "GR2", opp: "GDR", scoreFor: 1, scoreAgainst: 1 },
    ],
  },

  BRA_1974: {
    group: [
      { opp: "YUG", scoreFor: 0, scoreAgainst: 0 },
      { opp: "SCO", scoreFor: 0, scoreAgainst: 0 },
      { opp: "ZAI", scoreFor: 3, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "GR2", opp: "GDR", scoreFor: 1, scoreAgainst: 0 },
      { round: "GR2", opp: "ARG", scoreFor: 2, scoreAgainst: 1 },
      { round: "GR2", opp: "NED", scoreFor: 0, scoreAgainst: 2 },
      { round: "3P", opp: "POL", scoreFor: 0, scoreAgainst: 1 },
    ],
  },

  GER_1974: {
    group: [
      { opp: "CHI", scoreFor: 1, scoreAgainst: 0 },
      { opp: "AUS", scoreFor: 3, scoreAgainst: 0 },
      { opp: "GDR", scoreFor: 0, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "GR2", opp: "YUG", scoreFor: 2, scoreAgainst: 0 },
      { round: "GR2", opp: "SWE", scoreFor: 4, scoreAgainst: 2 },
      { round: "GR2", opp: "POL", scoreFor: 1, scoreAgainst: 0 },
      { round: "F", opp: "NED", scoreFor: 2, scoreAgainst: 1 },
    ],
  },

  ITA_1974: {
    group: [
      { opp: "HAI", scoreFor: 3, scoreAgainst: 1 },
      { opp: "ARG", scoreFor: 1, scoreAgainst: 1 },
      { opp: "POL", scoreFor: 1, scoreAgainst: 2 },
    ],
    knockout: [
    ],
  },

  NED_1974: {
    group: [
      { opp: "URU", scoreFor: 2, scoreAgainst: 0 },
      { opp: "SWE", scoreFor: 0, scoreAgainst: 0 },
      { opp: "BUL", scoreFor: 4, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "GR2", opp: "ARG", scoreFor: 4, scoreAgainst: 0 },
      { round: "GR2", opp: "GDR", scoreFor: 2, scoreAgainst: 0 },
      { round: "GR2", opp: "BRA", scoreFor: 2, scoreAgainst: 0 },
      { round: "F", opp: "GER", scoreFor: 1, scoreAgainst: 2 },
    ],
  },

  POL_1974: {
    group: [
      { opp: "ARG", scoreFor: 3, scoreAgainst: 2 },
      { opp: "HAI", scoreFor: 7, scoreAgainst: 0 },
      { opp: "ITA", scoreFor: 2, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "GR2", opp: "SWE", scoreFor: 1, scoreAgainst: 0 },
      { round: "GR2", opp: "YUG", scoreFor: 2, scoreAgainst: 1 },
      { round: "GR2", opp: "GER", scoreFor: 0, scoreAgainst: 1 },
      { round: "3P", opp: "BRA", scoreFor: 1, scoreAgainst: 0 },
    ],
  },

  SWE_1974: {
    group: [
      { opp: "BUL", scoreFor: 0, scoreAgainst: 0 },
      { opp: "NED", scoreFor: 0, scoreAgainst: 0 },
      { opp: "URU", scoreFor: 3, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "GR2", opp: "POL", scoreFor: 0, scoreAgainst: 1 },
      { round: "GR2", opp: "GER", scoreFor: 2, scoreAgainst: 4 },
      { round: "GR2", opp: "YUG", scoreFor: 2, scoreAgainst: 1 },
    ],
  },

  URU_1974: {
    group: [
      { opp: "NED", scoreFor: 0, scoreAgainst: 2 },
      { opp: "BUL", scoreFor: 1, scoreAgainst: 1 },
      { opp: "SWE", scoreFor: 0, scoreAgainst: 3 },
    ],
    knockout: [
    ],
  },

  ARG_1978: {
    group: [
      { opp: "HUN", scoreFor: 2, scoreAgainst: 1 },
      { opp: "FRA", scoreFor: 2, scoreAgainst: 1 },
      { opp: "ITA", scoreFor: 0, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "GR2", opp: "POL", scoreFor: 2, scoreAgainst: 0 },
      { round: "GR2", opp: "BRA", scoreFor: 0, scoreAgainst: 0 },
      { round: "GR2", opp: "PER", scoreFor: 6, scoreAgainst: 0 },
      { round: "F", opp: "NED", scoreFor: 3, scoreAgainst: 1, note: "prelungiri" },
    ],
  },

  AUT_1978: {
    group: [
      { opp: "ESP", scoreFor: 2, scoreAgainst: 1 },
      { opp: "SWE", scoreFor: 1, scoreAgainst: 0 },
      { opp: "BRA", scoreFor: 0, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "GR2", opp: "NED", scoreFor: 1, scoreAgainst: 5 },
      { round: "GR2", opp: "ITA", scoreFor: 0, scoreAgainst: 1 },
      { round: "GR2", opp: "GER", scoreFor: 3, scoreAgainst: 2 },
    ],
  },

  BRA_1978: {
    group: [
      { opp: "SWE", scoreFor: 1, scoreAgainst: 1 },
      { opp: "ESP", scoreFor: 0, scoreAgainst: 0 },
      { opp: "AUT", scoreFor: 1, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "GR2", opp: "PER", scoreFor: 3, scoreAgainst: 0 },
      { round: "GR2", opp: "ARG", scoreFor: 0, scoreAgainst: 0 },
      { round: "GR2", opp: "POL", scoreFor: 3, scoreAgainst: 1 },
      { round: "3P", opp: "ITA", scoreFor: 2, scoreAgainst: 1 },
    ],
  },

  ESP_1978: {
    group: [
      { opp: "AUT", scoreFor: 1, scoreAgainst: 2 },
      { opp: "BRA", scoreFor: 0, scoreAgainst: 0 },
      { opp: "SWE", scoreFor: 1, scoreAgainst: 0 },
    ],
    knockout: [
    ],
  },

  FRA_1978: {
    group: [
      { opp: "ITA", scoreFor: 1, scoreAgainst: 2 },
      { opp: "ARG", scoreFor: 1, scoreAgainst: 2 },
      { opp: "HUN", scoreFor: 3, scoreAgainst: 1 },
    ],
    knockout: [
    ],
  },

  GER_1978: {
    group: [
      { opp: "POL", scoreFor: 0, scoreAgainst: 0 },
      { opp: "MEX", scoreFor: 6, scoreAgainst: 0 },
      { opp: "TUN", scoreFor: 0, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "GR2", opp: "ITA", scoreFor: 0, scoreAgainst: 0 },
      { round: "GR2", opp: "NED", scoreFor: 2, scoreAgainst: 2 },
      { round: "GR2", opp: "AUT", scoreFor: 2, scoreAgainst: 3 },
    ],
  },

  HUN_1978: {
    group: [
      { opp: "ARG", scoreFor: 1, scoreAgainst: 2 },
      { opp: "ITA", scoreFor: 1, scoreAgainst: 3 },
      { opp: "FRA", scoreFor: 1, scoreAgainst: 3 },
    ],
    knockout: [
    ],
  },

  ITA_1978: {
    group: [
      { opp: "FRA", scoreFor: 2, scoreAgainst: 1 },
      { opp: "HUN", scoreFor: 3, scoreAgainst: 1 },
      { opp: "ARG", scoreFor: 1, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "GR2", opp: "GER", scoreFor: 0, scoreAgainst: 0 },
      { round: "GR2", opp: "AUT", scoreFor: 1, scoreAgainst: 0 },
      { round: "GR2", opp: "NED", scoreFor: 1, scoreAgainst: 2 },
      { round: "3P", opp: "BRA", scoreFor: 1, scoreAgainst: 2 },
    ],
  },

  MEX_1978: {
    group: [
      { opp: "TUN", scoreFor: 1, scoreAgainst: 3 },
      { opp: "GER", scoreFor: 0, scoreAgainst: 6 },
      { opp: "POL", scoreFor: 1, scoreAgainst: 3 },
    ],
    knockout: [
    ],
  },

  NED_1978: {
    group: [
      { opp: "IRN", scoreFor: 3, scoreAgainst: 0 },
      { opp: "PER", scoreFor: 0, scoreAgainst: 0 },
      { opp: "SCO", scoreFor: 2, scoreAgainst: 3 },
    ],
    knockout: [
      { round: "GR2", opp: "AUT", scoreFor: 5, scoreAgainst: 1 },
      { round: "GR2", opp: "GER", scoreFor: 2, scoreAgainst: 2 },
      { round: "GR2", opp: "ITA", scoreFor: 2, scoreAgainst: 1 },
      { round: "F", opp: "ARG", scoreFor: 1, scoreAgainst: 3, note: "prelungiri" },
    ],
  },

  POL_1978: {
    group: [
      { opp: "GER", scoreFor: 0, scoreAgainst: 0 },
      { opp: "TUN", scoreFor: 1, scoreAgainst: 0 },
      { opp: "MEX", scoreFor: 3, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "GR2", opp: "ARG", scoreFor: 0, scoreAgainst: 2 },
      { round: "GR2", opp: "PER", scoreFor: 1, scoreAgainst: 0 },
      { round: "GR2", opp: "BRA", scoreFor: 1, scoreAgainst: 3 },
    ],
  },

  SWE_1978: {
    group: [
      { opp: "BRA", scoreFor: 1, scoreAgainst: 1 },
      { opp: "AUT", scoreFor: 0, scoreAgainst: 1 },
      { opp: "ESP", scoreFor: 0, scoreAgainst: 1 },
    ],
    knockout: [
    ],
  },

  ARG_1982: {
    group: [
      { opp: "BEL", scoreFor: 0, scoreAgainst: 1 },
      { opp: "HUN", scoreFor: 4, scoreAgainst: 1 },
      { opp: "SLV", scoreFor: 2, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "GR2", opp: "ITA", scoreFor: 1, scoreAgainst: 2 },
      { round: "GR2", opp: "BRA", scoreFor: 1, scoreAgainst: 3 },
    ],
  },

  AUT_1982: {
    group: [
      { opp: "CHI", scoreFor: 1, scoreAgainst: 0 },
      { opp: "ALG", scoreFor: 2, scoreAgainst: 0 },
      { opp: "GER", scoreFor: 0, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "GR2", opp: "FRA", scoreFor: 0, scoreAgainst: 1 },
      { round: "GR2", opp: "NIR", scoreFor: 2, scoreAgainst: 2 },
    ],
  },

  BEL_1982: {
    group: [
      { opp: "ARG", scoreFor: 1, scoreAgainst: 0 },
      { opp: "SLV", scoreFor: 1, scoreAgainst: 0 },
      { opp: "HUN", scoreFor: 1, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "GR2", opp: "POL", scoreFor: 0, scoreAgainst: 3 },
      { round: "GR2", opp: "URS", scoreFor: 0, scoreAgainst: 1 },
    ],
  },

  BRA_1982: {
    group: [
      { opp: "URS", scoreFor: 2, scoreAgainst: 1 },
      { opp: "SCO", scoreFor: 4, scoreAgainst: 1 },
      { opp: "NZL", scoreFor: 4, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "GR2", opp: "ARG", scoreFor: 3, scoreAgainst: 1 },
      { round: "GR2", opp: "ITA", scoreFor: 2, scoreAgainst: 3 },
    ],
  },

  ENG_1982: {
    group: [
      { opp: "FRA", scoreFor: 3, scoreAgainst: 1 },
      { opp: "TCH", scoreFor: 2, scoreAgainst: 0 },
      { opp: "KUW", scoreFor: 1, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "GR2", opp: "GER", scoreFor: 0, scoreAgainst: 0 },
      { round: "GR2", opp: "ESP", scoreFor: 0, scoreAgainst: 0 },
    ],
  },

  ESP_1982: {
    group: [
      { opp: "HON", scoreFor: 1, scoreAgainst: 1 },
      { opp: "YUG", scoreFor: 2, scoreAgainst: 1 },
      { opp: "NIR", scoreFor: 0, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "GR2", opp: "GER", scoreFor: 1, scoreAgainst: 2 },
      { round: "GR2", opp: "ENG", scoreFor: 0, scoreAgainst: 0 },
    ],
  },

  FRA_1982: {
    group: [
      { opp: "ENG", scoreFor: 1, scoreAgainst: 3 },
      { opp: "KUW", scoreFor: 4, scoreAgainst: 1 },
      { opp: "TCH", scoreFor: 1, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "GR2", opp: "AUT", scoreFor: 1, scoreAgainst: 0 },
      { round: "GR2", opp: "NIR", scoreFor: 4, scoreAgainst: 1 },
      { round: "SF", opp: "GER", scoreFor: 3, scoreAgainst: 3, note: "penalty-uri 4-5" },
      { round: "3P", opp: "POL", scoreFor: 2, scoreAgainst: 3 },
    ],
  },

  GER_1982: {
    group: [
      { opp: "ALG", scoreFor: 1, scoreAgainst: 2 },
      { opp: "CHI", scoreFor: 4, scoreAgainst: 1 },
      { opp: "AUT", scoreFor: 1, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "GR2", opp: "ENG", scoreFor: 0, scoreAgainst: 0 },
      { round: "GR2", opp: "ESP", scoreFor: 2, scoreAgainst: 1 },
      { round: "SF", opp: "FRA", scoreFor: 3, scoreAgainst: 3, note: "penalty-uri 5-4" },
      { round: "F", opp: "ITA", scoreFor: 1, scoreAgainst: 3 },
    ],
  },

  HUN_1982: {
    group: [
      { opp: "SLV", scoreFor: 10, scoreAgainst: 1 },
      { opp: "ARG", scoreFor: 1, scoreAgainst: 4 },
      { opp: "BEL", scoreFor: 1, scoreAgainst: 1 },
    ],
    knockout: [
    ],
  },

  ITA_1982: {
    group: [
      { opp: "POL", scoreFor: 0, scoreAgainst: 0 },
      { opp: "PER", scoreFor: 1, scoreAgainst: 1 },
      { opp: "CMR", scoreFor: 1, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "GR2", opp: "ARG", scoreFor: 2, scoreAgainst: 1 },
      { round: "GR2", opp: "BRA", scoreFor: 3, scoreAgainst: 2 },
      { round: "SF", opp: "POL", scoreFor: 2, scoreAgainst: 0 },
      { round: "F", opp: "GER", scoreFor: 3, scoreAgainst: 1 },
    ],
  },

  POL_1982: {
    group: [
      { opp: "ITA", scoreFor: 0, scoreAgainst: 0 },
      { opp: "CMR", scoreFor: 0, scoreAgainst: 0 },
      { opp: "PER", scoreFor: 5, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "GR2", opp: "BEL", scoreFor: 3, scoreAgainst: 0 },
      { round: "GR2", opp: "URS", scoreFor: 0, scoreAgainst: 0 },
      { round: "SF", opp: "ITA", scoreFor: 0, scoreAgainst: 2 },
      { round: "3P", opp: "FRA", scoreFor: 3, scoreAgainst: 2 },
    ],
  },

  TCH_1982: {
    group: [
      { opp: "KUW", scoreFor: 1, scoreAgainst: 1 },
      { opp: "ENG", scoreFor: 0, scoreAgainst: 2 },
      { opp: "FRA", scoreFor: 1, scoreAgainst: 1 },
    ],
    knockout: [
    ],
  },

  ARG_1986: {
    group: [
      { opp: "KOR", scoreFor: 3, scoreAgainst: 1 },
      { opp: "ITA", scoreFor: 1, scoreAgainst: 1 },
      { opp: "BUL", scoreFor: 2, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "URU", scoreFor: 1, scoreAgainst: 0 },
      { round: "QF", opp: "ENG", scoreFor: 2, scoreAgainst: 1, note: "\"Mâna lui Dumnezeu\" + \"Golul Secolului\"" },
      { round: "SF", opp: "BEL", scoreFor: 2, scoreAgainst: 0 },
      { round: "F", opp: "GER", scoreFor: 3, scoreAgainst: 2 },
    ],
  },

  BEL_1986: {
    group: [
      { opp: "MEX", scoreFor: 1, scoreAgainst: 2 },
      { opp: "IRQ", scoreFor: 2, scoreAgainst: 1 },
      { opp: "PAR", scoreFor: 2, scoreAgainst: 2 },
    ],
    knockout: [
      { round: "R16", opp: "URS", scoreFor: 4, scoreAgainst: 3, note: "prelungiri" },
      { round: "QF", opp: "ESP", scoreFor: 1, scoreAgainst: 1, note: "penalty-uri 5-4" },
      { round: "SF", opp: "ARG", scoreFor: 0, scoreAgainst: 2 },
      { round: "3P", opp: "FRA", scoreFor: 2, scoreAgainst: 4, note: "prelungiri" },
    ],
  },

  BRA_1986: {
    group: [
      { opp: "ESP", scoreFor: 1, scoreAgainst: 0 },
      { opp: "ALG", scoreFor: 1, scoreAgainst: 0 },
      { opp: "NIR", scoreFor: 3, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "POL", scoreFor: 4, scoreAgainst: 0 },
      { round: "QF", opp: "FRA", scoreFor: 1, scoreAgainst: 1, note: "penalty-uri 3-4" },
    ],
  },

  ENG_1986: {
    group: [
      { opp: "POR", scoreFor: 0, scoreAgainst: 1 },
      { opp: "MAR", scoreFor: 0, scoreAgainst: 0 },
      { opp: "POL", scoreFor: 3, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "PAR", scoreFor: 3, scoreAgainst: 0 },
      { round: "QF", opp: "ARG", scoreFor: 1, scoreAgainst: 2 },
    ],
  },

  ESP_1986: {
    group: [
      { opp: "BRA", scoreFor: 0, scoreAgainst: 1 },
      { opp: "NIR", scoreFor: 2, scoreAgainst: 1 },
      { opp: "ALG", scoreFor: 3, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "DEN", scoreFor: 5, scoreAgainst: 1 },
      { round: "QF", opp: "BEL", scoreFor: 1, scoreAgainst: 1, note: "penalty-uri 4-5" },
    ],
  },

  FRA_1986: {
    group: [
      { opp: "CAN", scoreFor: 1, scoreAgainst: 0 },
      { opp: "URS", scoreFor: 1, scoreAgainst: 1 },
      { opp: "HUN", scoreFor: 3, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "ITA", scoreFor: 2, scoreAgainst: 0 },
      { round: "QF", opp: "BRA", scoreFor: 1, scoreAgainst: 1, note: "penalty-uri 4-3" },
      { round: "SF", opp: "GER", scoreFor: 0, scoreAgainst: 2 },
      { round: "3P", opp: "BEL", scoreFor: 4, scoreAgainst: 2, note: "prelungiri" },
    ],
  },

  GER_1986: {
    group: [
      { opp: "URU", scoreFor: 1, scoreAgainst: 1 },
      { opp: "SCO", scoreFor: 2, scoreAgainst: 1 },
      { opp: "DEN", scoreFor: 0, scoreAgainst: 2 },
    ],
    knockout: [
      { round: "R16", opp: "MAR", scoreFor: 1, scoreAgainst: 0 },
      { round: "QF", opp: "MEX", scoreFor: 0, scoreAgainst: 0, note: "penalty-uri 4-1" },
      { round: "SF", opp: "FRA", scoreFor: 2, scoreAgainst: 0 },
      { round: "F", opp: "ARG", scoreFor: 2, scoreAgainst: 3 },
    ],
  },

  HUN_1986: {
    group: [
      { opp: "URS", scoreFor: 0, scoreAgainst: 6 },
      { opp: "CAN", scoreFor: 2, scoreAgainst: 0 },
      { opp: "FRA", scoreFor: 0, scoreAgainst: 3 },
    ],
    knockout: [
    ],
  },

  ITA_1986: {
    group: [
      { opp: "BUL", scoreFor: 1, scoreAgainst: 1 },
      { opp: "ARG", scoreFor: 1, scoreAgainst: 1 },
      { opp: "KOR", scoreFor: 3, scoreAgainst: 2 },
    ],
    knockout: [
      { round: "R16", opp: "FRA", scoreFor: 0, scoreAgainst: 2 },
    ],
  },

  KOR_1986: {
    group: [
      { opp: "ARG", scoreFor: 1, scoreAgainst: 3 },
      { opp: "BUL", scoreFor: 1, scoreAgainst: 1 },
      { opp: "ITA", scoreFor: 2, scoreAgainst: 3 },
    ],
    knockout: [
    ],
  },

  MAR_1986: {
    group: [
      { opp: "POL", scoreFor: 0, scoreAgainst: 0 },
      { opp: "ENG", scoreFor: 0, scoreAgainst: 0 },
      { opp: "POR", scoreFor: 3, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "GER", scoreFor: 0, scoreAgainst: 1 },
    ],
  },

  MEX_1986: {
    group: [
      { opp: "BEL", scoreFor: 2, scoreAgainst: 1 },
      { opp: "PAR", scoreFor: 1, scoreAgainst: 1 },
      { opp: "IRQ", scoreFor: 1, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "BUL", scoreFor: 2, scoreAgainst: 0 },
      { round: "QF", opp: "GER", scoreFor: 0, scoreAgainst: 0, note: "penalty-uri 1-4" },
    ],
  },

  POL_1986: {
    group: [
      { opp: "MAR", scoreFor: 0, scoreAgainst: 0 },
      { opp: "POR", scoreFor: 1, scoreAgainst: 0 },
      { opp: "ENG", scoreFor: 0, scoreAgainst: 3 },
    ],
    knockout: [
      { round: "R16", opp: "BRA", scoreFor: 0, scoreAgainst: 4 },
    ],
  },

  POR_1986: {
    group: [
      { opp: "ENG", scoreFor: 1, scoreAgainst: 0 },
      { opp: "POL", scoreFor: 0, scoreAgainst: 1 },
      { opp: "MAR", scoreFor: 1, scoreAgainst: 3 },
    ],
    knockout: [
    ],
  },

  URU_1986: {
    group: [
      { opp: "GER", scoreFor: 1, scoreAgainst: 1 },
      { opp: "DEN", scoreFor: 1, scoreAgainst: 6 },
      { opp: "SCO", scoreFor: 0, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "ARG", scoreFor: 0, scoreAgainst: 1 },
    ],
  },

  ARG_1990: {
    group: [
      { opp: "CMR", scoreFor: 0, scoreAgainst: 1 },
      { opp: "URS", scoreFor: 2, scoreAgainst: 0 },
      { opp: "ROU", scoreFor: 1, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "BRA", scoreFor: 1, scoreAgainst: 0 },
      { round: "QF", opp: "YUG", scoreFor: 0, scoreAgainst: 0, note: "penalty-uri 3-2" },
      { round: "SF", opp: "ITA", scoreFor: 1, scoreAgainst: 1, note: "penalty-uri 4-3" },
      { round: "F", opp: "GER", scoreFor: 0, scoreAgainst: 1 },
    ],
  },

  AUT_1990: {
    group: [
      { opp: "ITA", scoreFor: 0, scoreAgainst: 1 },
      { opp: "TCH", scoreFor: 0, scoreAgainst: 1 },
      { opp: "USA", scoreFor: 2, scoreAgainst: 1 },
    ],
    knockout: [
    ],
  },

  BEL_1990: {
    group: [
      { opp: "KOR", scoreFor: 2, scoreAgainst: 0 },
      { opp: "URU", scoreFor: 3, scoreAgainst: 1 },
      { opp: "ESP", scoreFor: 1, scoreAgainst: 2 },
    ],
    knockout: [
      { round: "R16", opp: "ENG", scoreFor: 0, scoreAgainst: 1, note: "prelungiri" },
    ],
  },

  BRA_1990: {
    group: [
      { opp: "SWE", scoreFor: 2, scoreAgainst: 1 },
      { opp: "CRC", scoreFor: 1, scoreAgainst: 0 },
      { opp: "SCO", scoreFor: 1, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "ARG", scoreFor: 0, scoreAgainst: 1 },
    ],
  },

  ENG_1990: {
    group: [
      { opp: "IRL", scoreFor: 1, scoreAgainst: 1 },
      { opp: "NED", scoreFor: 0, scoreAgainst: 0 },
      { opp: "EGY", scoreFor: 1, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "BEL", scoreFor: 1, scoreAgainst: 0, note: "prelungiri" },
      { round: "QF", opp: "CMR", scoreFor: 3, scoreAgainst: 2, note: "prelungiri" },
      { round: "SF", opp: "GER", scoreFor: 1, scoreAgainst: 1, note: "penalty-uri 3-4" },
      { round: "3P", opp: "ITA", scoreFor: 1, scoreAgainst: 2 },
    ],
  },

  ESP_1990: {
    group: [
      { opp: "URU", scoreFor: 0, scoreAgainst: 0 },
      { opp: "KOR", scoreFor: 3, scoreAgainst: 1 },
      { opp: "BEL", scoreFor: 2, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "YUG", scoreFor: 1, scoreAgainst: 2, note: "prelungiri" },
    ],
  },

  GER_1990: {
    group: [
      { opp: "YUG", scoreFor: 4, scoreAgainst: 1 },
      { opp: "UAE", scoreFor: 5, scoreAgainst: 1 },
      { opp: "COL", scoreFor: 1, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "NED", scoreFor: 2, scoreAgainst: 1 },
      { round: "QF", opp: "TCH", scoreFor: 1, scoreAgainst: 0 },
      { round: "SF", opp: "ENG", scoreFor: 1, scoreAgainst: 1, note: "penalty-uri 4-3" },
      { round: "F", opp: "ARG", scoreFor: 1, scoreAgainst: 0 },
    ],
  },

  ITA_1990: {
    group: [
      { opp: "AUT", scoreFor: 1, scoreAgainst: 0 },
      { opp: "USA", scoreFor: 1, scoreAgainst: 0 },
      { opp: "TCH", scoreFor: 2, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "URU", scoreFor: 2, scoreAgainst: 0 },
      { round: "QF", opp: "IRL", scoreFor: 1, scoreAgainst: 0 },
      { round: "SF", opp: "ARG", scoreFor: 1, scoreAgainst: 1, note: "penalty-uri 3-4" },
      { round: "3P", opp: "ENG", scoreFor: 2, scoreAgainst: 1 },
    ],
  },

  KOR_1990: {
    group: [
      { opp: "BEL", scoreFor: 0, scoreAgainst: 2 },
      { opp: "ESP", scoreFor: 1, scoreAgainst: 3 },
      { opp: "URU", scoreFor: 0, scoreAgainst: 1 },
    ],
    knockout: [
    ],
  },

  NED_1990: {
    group: [
      { opp: "EGY", scoreFor: 1, scoreAgainst: 1 },
      { opp: "ENG", scoreFor: 0, scoreAgainst: 0 },
      { opp: "IRL", scoreFor: 1, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "GER", scoreFor: 1, scoreAgainst: 2 },
    ],
  },

  SWE_1990: {
    group: [
      { opp: "BRA", scoreFor: 1, scoreAgainst: 2 },
      { opp: "SCO", scoreFor: 1, scoreAgainst: 2 },
      { opp: "CRC", scoreFor: 1, scoreAgainst: 2 },
    ],
    knockout: [
    ],
  },

  TCH_1990: {
    group: [
      { opp: "USA", scoreFor: 5, scoreAgainst: 1 },
      { opp: "AUT", scoreFor: 1, scoreAgainst: 0 },
      { opp: "ITA", scoreFor: 0, scoreAgainst: 2 },
    ],
    knockout: [
      { round: "R16", opp: "CRC", scoreFor: 4, scoreAgainst: 1 },
      { round: "QF", opp: "GER", scoreFor: 0, scoreAgainst: 1 },
    ],
  },

  URU_1990: {
    group: [
      { opp: "ESP", scoreFor: 0, scoreAgainst: 0 },
      { opp: "BEL", scoreFor: 1, scoreAgainst: 3 },
      { opp: "KOR", scoreFor: 1, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "ITA", scoreFor: 0, scoreAgainst: 2 },
    ],
  },

  USA_1990: {
    group: [
      { opp: "TCH", scoreFor: 1, scoreAgainst: 5 },
      { opp: "ITA", scoreFor: 0, scoreAgainst: 1 },
      { opp: "AUT", scoreFor: 1, scoreAgainst: 2 },
    ],
    knockout: [
    ],
  },

  ARG_1994: {
    group: [
      { opp: "GRE", scoreFor: 4, scoreAgainst: 0 },
      { opp: "NGA", scoreFor: 2, scoreAgainst: 1 },
      { opp: "BUL", scoreFor: 0, scoreAgainst: 2 },
    ],
    knockout: [
      { round: "R16", opp: "ROU", scoreFor: 2, scoreAgainst: 3 },
    ],
  },

  BEL_1994: {
    group: [
      { opp: "MAR", scoreFor: 1, scoreAgainst: 0 },
      { opp: "NED", scoreFor: 1, scoreAgainst: 0 },
      { opp: "KSA", scoreFor: 0, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "GER", scoreFor: 2, scoreAgainst: 3 },
    ],
  },

  BRA_1994: {
    group: [
      { opp: "RUS", scoreFor: 2, scoreAgainst: 0 },
      { opp: "CMR", scoreFor: 3, scoreAgainst: 0 },
      { opp: "SWE", scoreFor: 1, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "USA", scoreFor: 1, scoreAgainst: 0 },
      { round: "QF", opp: "NED", scoreFor: 3, scoreAgainst: 2 },
      { round: "SF", opp: "SWE", scoreFor: 1, scoreAgainst: 0 },
      { round: "F", opp: "ITA", scoreFor: 0, scoreAgainst: 0, note: "penalty-uri 3-2" },
    ],
  },

  ESP_1994: {
    group: [
      { opp: "KOR", scoreFor: 2, scoreAgainst: 2 },
      { opp: "GER", scoreFor: 1, scoreAgainst: 1 },
      { opp: "BOL", scoreFor: 3, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "SUI", scoreFor: 3, scoreAgainst: 0 },
      { round: "QF", opp: "ITA", scoreFor: 1, scoreAgainst: 2 },
    ],
  },

  GER_1994: {
    group: [
      { opp: "BOL", scoreFor: 1, scoreAgainst: 0 },
      { opp: "ESP", scoreFor: 1, scoreAgainst: 1 },
      { opp: "KOR", scoreFor: 3, scoreAgainst: 2 },
    ],
    knockout: [
      { round: "R16", opp: "BEL", scoreFor: 3, scoreAgainst: 2 },
      { round: "QF", opp: "BUL", scoreFor: 1, scoreAgainst: 2 },
    ],
  },

  ITA_1994: {
    group: [
      { opp: "IRL", scoreFor: 0, scoreAgainst: 1 },
      { opp: "NOR", scoreFor: 1, scoreAgainst: 0 },
      { opp: "MEX", scoreFor: 1, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "NGA", scoreFor: 2, scoreAgainst: 1, note: "prelungiri" },
      { round: "QF", opp: "ESP", scoreFor: 2, scoreAgainst: 1 },
      { round: "SF", opp: "BUL", scoreFor: 2, scoreAgainst: 1 },
      { round: "F", opp: "BRA", scoreFor: 0, scoreAgainst: 0, note: "penalty-uri 2-3" },
    ],
  },

  KOR_1994: {
    group: [
      { opp: "ESP", scoreFor: 2, scoreAgainst: 2 },
      { opp: "BOL", scoreFor: 0, scoreAgainst: 0 },
      { opp: "GER", scoreFor: 2, scoreAgainst: 3 },
    ],
    knockout: [
    ],
  },

  MAR_1994: {
    group: [
      { opp: "BEL", scoreFor: 0, scoreAgainst: 1 },
      { opp: "KSA", scoreFor: 1, scoreAgainst: 2 },
      { opp: "NED", scoreFor: 1, scoreAgainst: 2 },
    ],
    knockout: [
    ],
  },

  MEX_1994: {
    group: [
      { opp: "NOR", scoreFor: 0, scoreAgainst: 1 },
      { opp: "IRL", scoreFor: 2, scoreAgainst: 1 },
      { opp: "ITA", scoreFor: 1, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "BUL", scoreFor: 1, scoreAgainst: 1, note: "penalty-uri 1-3" },
    ],
  },

  NED_1994: {
    group: [
      { opp: "KSA", scoreFor: 2, scoreAgainst: 1 },
      { opp: "BEL", scoreFor: 0, scoreAgainst: 1 },
      { opp: "MAR", scoreFor: 2, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "IRL", scoreFor: 2, scoreAgainst: 0 },
      { round: "QF", opp: "BRA", scoreFor: 2, scoreAgainst: 3 },
    ],
  },

  SWE_1994: {
    group: [
      { opp: "CMR", scoreFor: 2, scoreAgainst: 2 },
      { opp: "RUS", scoreFor: 3, scoreAgainst: 1 },
      { opp: "BRA", scoreFor: 1, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "KSA", scoreFor: 3, scoreAgainst: 1 },
      { round: "QF", opp: "ROU", scoreFor: 2, scoreAgainst: 2, note: "penalty-uri 5-4" },
      { round: "SF", opp: "BRA", scoreFor: 0, scoreAgainst: 1 },
      { round: "3P", opp: "BUL", scoreFor: 4, scoreAgainst: 0 },
    ],
  },

  USA_1994: {
    group: [
      { opp: "SUI", scoreFor: 1, scoreAgainst: 1 },
      { opp: "COL", scoreFor: 2, scoreAgainst: 1 },
      { opp: "ROU", scoreFor: 0, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "BRA", scoreFor: 0, scoreAgainst: 1 },
    ],
  },

  ARG_1998: {
    group: [
      { opp: "JPN", scoreFor: 1, scoreAgainst: 0 },
      { opp: "JAM", scoreFor: 5, scoreAgainst: 0 },
      { opp: "CRO", scoreFor: 1, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "ENG", scoreFor: 2, scoreAgainst: 2, note: "penalty-uri 4-3" },
      { round: "QF", opp: "NED", scoreFor: 1, scoreAgainst: 2 },
    ],
  },

  AUT_1998: {
    group: [
      { opp: "CMR", scoreFor: 1, scoreAgainst: 1 },
      { opp: "CHI", scoreFor: 1, scoreAgainst: 1 },
      { opp: "ITA", scoreFor: 1, scoreAgainst: 2 },
    ],
    knockout: [
    ],
  },

  BEL_1998: {
    group: [
      { opp: "NED", scoreFor: 0, scoreAgainst: 0 },
      { opp: "MEX", scoreFor: 2, scoreAgainst: 2 },
      { opp: "KOR", scoreFor: 1, scoreAgainst: 1 },
    ],
    knockout: [
    ],
  },

  BRA_1998: {
    group: [
      { opp: "SCO", scoreFor: 2, scoreAgainst: 1 },
      { opp: "MAR", scoreFor: 3, scoreAgainst: 0 },
      { opp: "NOR", scoreFor: 1, scoreAgainst: 2 },
    ],
    knockout: [
      { round: "R16", opp: "CHI", scoreFor: 4, scoreAgainst: 1 },
      { round: "QF", opp: "DEN", scoreFor: 3, scoreAgainst: 2 },
      { round: "SF", opp: "NED", scoreFor: 1, scoreAgainst: 1, note: "penalty-uri 4-2" },
      { round: "F", opp: "FRA", scoreFor: 0, scoreAgainst: 3 },
    ],
  },

  CRO_1998: {
    group: [
      { opp: "JAM", scoreFor: 3, scoreAgainst: 1 },
      { opp: "JPN", scoreFor: 1, scoreAgainst: 0 },
      { opp: "ARG", scoreFor: 0, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "ROU", scoreFor: 1, scoreAgainst: 0 },
      { round: "QF", opp: "GER", scoreFor: 3, scoreAgainst: 0 },
      { round: "SF", opp: "FRA", scoreFor: 1, scoreAgainst: 2 },
      { round: "3P", opp: "NED", scoreFor: 2, scoreAgainst: 1 },
    ],
  },

  ENG_1998: {
    group: [
      { opp: "TUN", scoreFor: 2, scoreAgainst: 0 },
      { opp: "ROU", scoreFor: 1, scoreAgainst: 2 },
      { opp: "COL", scoreFor: 2, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "ARG", scoreFor: 2, scoreAgainst: 2, note: "penalty-uri 3-4" },
    ],
  },

  ESP_1998: {
    group: [
      { opp: "NGA", scoreFor: 2, scoreAgainst: 3 },
      { opp: "PAR", scoreFor: 0, scoreAgainst: 0 },
      { opp: "BUL", scoreFor: 6, scoreAgainst: 1 },
    ],
    knockout: [
    ],
  },

  FRA_1998: {
    group: [
      { opp: "RSA", scoreFor: 3, scoreAgainst: 0 },
      { opp: "KSA", scoreFor: 4, scoreAgainst: 0 },
      { opp: "DEN", scoreFor: 2, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "PAR", scoreFor: 1, scoreAgainst: 0, note: "gol de aur" },
      { round: "QF", opp: "ITA", scoreFor: 0, scoreAgainst: 0, note: "penalty-uri 4-3" },
      { round: "SF", opp: "CRO", scoreFor: 2, scoreAgainst: 1 },
      { round: "F", opp: "BRA", scoreFor: 3, scoreAgainst: 0 },
    ],
  },

  GER_1998: {
    group: [
      { opp: "USA", scoreFor: 2, scoreAgainst: 0 },
      { opp: "YUG", scoreFor: 2, scoreAgainst: 2 },
      { opp: "IRN", scoreFor: 2, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "MEX", scoreFor: 2, scoreAgainst: 1 },
      { round: "QF", opp: "CRO", scoreFor: 0, scoreAgainst: 3 },
    ],
  },

  ITA_1998: {
    group: [
      { opp: "CHI", scoreFor: 2, scoreAgainst: 2 },
      { opp: "CMR", scoreFor: 3, scoreAgainst: 0 },
      { opp: "AUT", scoreFor: 2, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "NOR", scoreFor: 1, scoreAgainst: 0 },
      { round: "QF", opp: "FRA", scoreFor: 0, scoreAgainst: 0, note: "penalty-uri 3-4" },
    ],
  },

  JPN_1998: {
    group: [
      { opp: "ARG", scoreFor: 0, scoreAgainst: 1 },
      { opp: "CRO", scoreFor: 0, scoreAgainst: 1 },
      { opp: "JAM", scoreFor: 1, scoreAgainst: 2 },
    ],
    knockout: [
    ],
  },

  KOR_1998: {
    group: [
      { opp: "MEX", scoreFor: 1, scoreAgainst: 3 },
      { opp: "NED", scoreFor: 0, scoreAgainst: 5 },
      { opp: "BEL", scoreFor: 1, scoreAgainst: 1 },
    ],
    knockout: [
    ],
  },

  MAR_1998: {
    group: [
      { opp: "NOR", scoreFor: 2, scoreAgainst: 2 },
      { opp: "BRA", scoreFor: 0, scoreAgainst: 3 },
      { opp: "SCO", scoreFor: 3, scoreAgainst: 0 },
    ],
    knockout: [
    ],
  },

  MEX_1998: {
    group: [
      { opp: "KOR", scoreFor: 3, scoreAgainst: 1 },
      { opp: "BEL", scoreFor: 2, scoreAgainst: 2 },
      { opp: "NED", scoreFor: 2, scoreAgainst: 2 },
    ],
    knockout: [
      { round: "R16", opp: "GER", scoreFor: 1, scoreAgainst: 2 },
    ],
  },

  NED_1998: {
    group: [
      { opp: "BEL", scoreFor: 0, scoreAgainst: 0 },
      { opp: "KOR", scoreFor: 5, scoreAgainst: 0 },
      { opp: "MEX", scoreFor: 2, scoreAgainst: 2 },
    ],
    knockout: [
      { round: "R16", opp: "YUG", scoreFor: 2, scoreAgainst: 1 },
      { round: "QF", opp: "ARG", scoreFor: 2, scoreAgainst: 1 },
      { round: "SF", opp: "BRA", scoreFor: 1, scoreAgainst: 1, note: "penalty-uri 2-4" },
      { round: "3P", opp: "CRO", scoreFor: 1, scoreAgainst: 2 },
    ],
  },

  USA_1998: {
    group: [
      { opp: "GER", scoreFor: 0, scoreAgainst: 2 },
      { opp: "IRN", scoreFor: 1, scoreAgainst: 2 },
      { opp: "YUG", scoreFor: 0, scoreAgainst: 1 },
    ],
    knockout: [
    ],
  },

  ARG_2002: {
    group: [
      { opp: "NGA", scoreFor: 1, scoreAgainst: 0 },
      { opp: "ENG", scoreFor: 0, scoreAgainst: 1 },
      { opp: "SWE", scoreFor: 1, scoreAgainst: 1 },
    ],
    knockout: [
    ],
  },

  BEL_2002: {
    group: [
      { opp: "JPN", scoreFor: 2, scoreAgainst: 2 },
      { opp: "TUN", scoreFor: 1, scoreAgainst: 1 },
      { opp: "RUS", scoreFor: 3, scoreAgainst: 2 },
    ],
    knockout: [
      { round: "R16", opp: "BRA", scoreFor: 0, scoreAgainst: 2 },
    ],
  },

  BRA_2002: {
    group: [
      { opp: "TUR", scoreFor: 2, scoreAgainst: 1 },
      { opp: "CHN", scoreFor: 4, scoreAgainst: 0 },
      { opp: "CRC", scoreFor: 5, scoreAgainst: 2 },
    ],
    knockout: [
      { round: "R16", opp: "BEL", scoreFor: 2, scoreAgainst: 0 },
      { round: "QF", opp: "ENG", scoreFor: 2, scoreAgainst: 1 },
      { round: "SF", opp: "TUR", scoreFor: 1, scoreAgainst: 0 },
      { round: "F", opp: "GER", scoreFor: 2, scoreAgainst: 0 },
    ],
  },

  CRO_2002: {
    group: [
      { opp: "MEX", scoreFor: 0, scoreAgainst: 1 },
      { opp: "ITA", scoreFor: 2, scoreAgainst: 1 },
      { opp: "ECU", scoreFor: 0, scoreAgainst: 1 },
    ],
    knockout: [
    ],
  },

  ENG_2002: {
    group: [
      { opp: "SWE", scoreFor: 1, scoreAgainst: 1 },
      { opp: "ARG", scoreFor: 1, scoreAgainst: 0 },
      { opp: "NGA", scoreFor: 0, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "DEN", scoreFor: 3, scoreAgainst: 0 },
      { round: "QF", opp: "BRA", scoreFor: 1, scoreAgainst: 2 },
    ],
  },

  ESP_2002: {
    group: [
      { opp: "SVN", scoreFor: 3, scoreAgainst: 1 },
      { opp: "PAR", scoreFor: 3, scoreAgainst: 1 },
      { opp: "RSA", scoreFor: 3, scoreAgainst: 2 },
    ],
    knockout: [
      { round: "R16", opp: "IRL", scoreFor: 1, scoreAgainst: 1, note: "penalty-uri 3-2" },
      { round: "QF", opp: "KOR", scoreFor: 0, scoreAgainst: 0, note: "penalty-uri 3-5" },
    ],
  },

  FRA_2002: {
    group: [
      { opp: "SEN", scoreFor: 0, scoreAgainst: 1 },
      { opp: "URU", scoreFor: 0, scoreAgainst: 0 },
      { opp: "DEN", scoreFor: 0, scoreAgainst: 2 },
    ],
    knockout: [
    ],
  },

  GER_2002: {
    group: [
      { opp: "KSA", scoreFor: 8, scoreAgainst: 0 },
      { opp: "IRL", scoreFor: 1, scoreAgainst: 1 },
      { opp: "CMR", scoreFor: 2, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "PAR", scoreFor: 1, scoreAgainst: 0 },
      { round: "QF", opp: "USA", scoreFor: 1, scoreAgainst: 0 },
      { round: "SF", opp: "KOR", scoreFor: 1, scoreAgainst: 0 },
      { round: "F", opp: "BRA", scoreFor: 0, scoreAgainst: 2 },
    ],
  },

  ITA_2002: {
    group: [
      { opp: "ECU", scoreFor: 2, scoreAgainst: 0 },
      { opp: "CRO", scoreFor: 1, scoreAgainst: 2 },
      { opp: "MEX", scoreFor: 1, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "KOR", scoreFor: 1, scoreAgainst: 2, note: "prelungiri" },
    ],
  },

  JPN_2002: {
    group: [
      { opp: "BEL", scoreFor: 2, scoreAgainst: 2 },
      { opp: "RUS", scoreFor: 1, scoreAgainst: 0 },
      { opp: "TUN", scoreFor: 2, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "TUR", scoreFor: 0, scoreAgainst: 1 },
    ],
  },

  KOR_2002: {
    group: [
      { opp: "POL", scoreFor: 2, scoreAgainst: 0 },
      { opp: "USA", scoreFor: 1, scoreAgainst: 1 },
      { opp: "POR", scoreFor: 1, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "ITA", scoreFor: 2, scoreAgainst: 1, note: "prelungiri" },
      { round: "QF", opp: "ESP", scoreFor: 0, scoreAgainst: 0, note: "penalty-uri 5-3" },
      { round: "SF", opp: "GER", scoreFor: 0, scoreAgainst: 1 },
      { round: "3P", opp: "TUR", scoreFor: 2, scoreAgainst: 3 },
    ],
  },

  MEX_2002: {
    group: [
      { opp: "CRO", scoreFor: 1, scoreAgainst: 0 },
      { opp: "ECU", scoreFor: 2, scoreAgainst: 1 },
      { opp: "ITA", scoreFor: 1, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "USA", scoreFor: 0, scoreAgainst: 2 },
    ],
  },

  POL_2002: {
    group: [
      { opp: "KOR", scoreFor: 0, scoreAgainst: 2 },
      { opp: "POR", scoreFor: 0, scoreAgainst: 4 },
      { opp: "USA", scoreFor: 3, scoreAgainst: 1 },
    ],
    knockout: [
    ],
  },

  POR_2002: {
    group: [
      { opp: "USA", scoreFor: 2, scoreAgainst: 3 },
      { opp: "POL", scoreFor: 4, scoreAgainst: 0 },
      { opp: "KOR", scoreFor: 0, scoreAgainst: 1 },
    ],
    knockout: [
    ],
  },

  SWE_2002: {
    group: [
      { opp: "ENG", scoreFor: 1, scoreAgainst: 1 },
      { opp: "NGA", scoreFor: 2, scoreAgainst: 1 },
      { opp: "ARG", scoreFor: 1, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "SEN", scoreFor: 1, scoreAgainst: 2, note: "prelungiri" },
    ],
  },

  TUR_2002: {
    group: [
      { opp: "BRA", scoreFor: 1, scoreAgainst: 2 },
      { opp: "CRC", scoreFor: 1, scoreAgainst: 1 },
      { opp: "CHN", scoreFor: 3, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "JPN", scoreFor: 1, scoreAgainst: 0 },
      { round: "QF", opp: "SEN", scoreFor: 1, scoreAgainst: 0, note: "prelungiri" },
      { round: "SF", opp: "BRA", scoreFor: 0, scoreAgainst: 1 },
      { round: "3P", opp: "KOR", scoreFor: 3, scoreAgainst: 2 },
    ],
  },

  URU_2002: {
    group: [
      { opp: "DEN", scoreFor: 1, scoreAgainst: 2 },
      { opp: "FRA", scoreFor: 0, scoreAgainst: 0 },
      { opp: "SEN", scoreFor: 3, scoreAgainst: 3 },
    ],
    knockout: [
    ],
  },

  USA_2002: {
    group: [
      { opp: "POR", scoreFor: 3, scoreAgainst: 2 },
      { opp: "KOR", scoreFor: 1, scoreAgainst: 1 },
      { opp: "POL", scoreFor: 1, scoreAgainst: 3 },
    ],
    knockout: [
      { round: "R16", opp: "MEX", scoreFor: 2, scoreAgainst: 0 },
      { round: "QF", opp: "GER", scoreFor: 0, scoreAgainst: 1 },
    ],
  },

  ARG_2006: {
    group: [
      { opp: "CIV", scoreFor: 2, scoreAgainst: 1 },
      { opp: "SCG", scoreFor: 6, scoreAgainst: 0 },
      { opp: "NED", scoreFor: 0, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "MEX", scoreFor: 2, scoreAgainst: 1, note: "prelungiri" },
      { round: "QF", opp: "GER", scoreFor: 1, scoreAgainst: 1, note: "penalty-uri 2-4" },
    ],
  },

  BRA_2006: {
    group: [
      { opp: "CRO", scoreFor: 1, scoreAgainst: 0 },
      { opp: "AUS", scoreFor: 2, scoreAgainst: 0 },
      { opp: "JPN", scoreFor: 4, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "GHA", scoreFor: 3, scoreAgainst: 0 },
      { round: "QF", opp: "FRA", scoreFor: 0, scoreAgainst: 1 },
    ],
  },

  CRO_2006: {
    group: [
      { opp: "BRA", scoreFor: 0, scoreAgainst: 1 },
      { opp: "JPN", scoreFor: 0, scoreAgainst: 0 },
      { opp: "AUS", scoreFor: 2, scoreAgainst: 2 },
    ],
    knockout: [
    ],
  },

  ENG_2006: {
    group: [
      { opp: "PAR", scoreFor: 1, scoreAgainst: 0 },
      { opp: "TRI", scoreFor: 2, scoreAgainst: 0 },
      { opp: "SWE", scoreFor: 2, scoreAgainst: 2 },
    ],
    knockout: [
      { round: "R16", opp: "ECU", scoreFor: 1, scoreAgainst: 0 },
      { round: "QF", opp: "POR", scoreFor: 0, scoreAgainst: 0, note: "penalty-uri 1-3" },
    ],
  },

  ESP_2006: {
    group: [
      { opp: "UKR", scoreFor: 4, scoreAgainst: 0 },
      { opp: "TUN", scoreFor: 3, scoreAgainst: 1 },
      { opp: "KSA", scoreFor: 1, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "FRA", scoreFor: 1, scoreAgainst: 3 },
    ],
  },

  FRA_2006: {
    group: [
      { opp: "SUI", scoreFor: 0, scoreAgainst: 0 },
      { opp: "KOR", scoreFor: 1, scoreAgainst: 1 },
      { opp: "TOG", scoreFor: 2, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "ESP", scoreFor: 3, scoreAgainst: 1 },
      { round: "QF", opp: "BRA", scoreFor: 1, scoreAgainst: 0 },
      { round: "SF", opp: "POR", scoreFor: 1, scoreAgainst: 0 },
      { round: "F", opp: "ITA", scoreFor: 1, scoreAgainst: 1, note: "penalty-uri 3-5" },
    ],
  },

  GER_2006: {
    group: [
      { opp: "CRC", scoreFor: 4, scoreAgainst: 2 },
      { opp: "POL", scoreFor: 1, scoreAgainst: 0 },
      { opp: "ECU", scoreFor: 3, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "SWE", scoreFor: 2, scoreAgainst: 0 },
      { round: "QF", opp: "ARG", scoreFor: 1, scoreAgainst: 1, note: "penalty-uri 4-2" },
      { round: "SF", opp: "ITA", scoreFor: 0, scoreAgainst: 2, note: "prelungiri" },
      { round: "3P", opp: "POR", scoreFor: 3, scoreAgainst: 1 },
    ],
  },

  ITA_2006: {
    group: [
      { opp: "GHA", scoreFor: 2, scoreAgainst: 0 },
      { opp: "USA", scoreFor: 1, scoreAgainst: 1 },
      { opp: "CZE", scoreFor: 2, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "AUS", scoreFor: 1, scoreAgainst: 0 },
      { round: "QF", opp: "UKR", scoreFor: 3, scoreAgainst: 0 },
      { round: "SF", opp: "GER", scoreFor: 2, scoreAgainst: 0, note: "prelungiri" },
      { round: "F", opp: "FRA", scoreFor: 1, scoreAgainst: 1, note: "penalty-uri 5-3" },
    ],
  },

  JPN_2006: {
    group: [
      { opp: "AUS", scoreFor: 1, scoreAgainst: 3 },
      { opp: "CRO", scoreFor: 0, scoreAgainst: 0 },
      { opp: "BRA", scoreFor: 1, scoreAgainst: 4 },
    ],
    knockout: [
    ],
  },

  KOR_2006: {
    group: [
      { opp: "TOG", scoreFor: 2, scoreAgainst: 1 },
      { opp: "FRA", scoreFor: 1, scoreAgainst: 1 },
      { opp: "SUI", scoreFor: 0, scoreAgainst: 2 },
    ],
    knockout: [
    ],
  },

  MEX_2006: {
    group: [
      { opp: "IRN", scoreFor: 3, scoreAgainst: 1 },
      { opp: "ANG", scoreFor: 0, scoreAgainst: 0 },
      { opp: "POR", scoreFor: 1, scoreAgainst: 2 },
    ],
    knockout: [
      { round: "R16", opp: "ARG", scoreFor: 1, scoreAgainst: 2, note: "prelungiri" },
    ],
  },

  NED_2006: {
    group: [
      { opp: "SCG", scoreFor: 1, scoreAgainst: 0 },
      { opp: "CIV", scoreFor: 2, scoreAgainst: 1 },
      { opp: "ARG", scoreFor: 0, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "POR", scoreFor: 0, scoreAgainst: 1 },
    ],
  },

  POL_2006: {
    group: [
      { opp: "ECU", scoreFor: 0, scoreAgainst: 2 },
      { opp: "GER", scoreFor: 0, scoreAgainst: 1 },
      { opp: "CRC", scoreFor: 2, scoreAgainst: 1 },
    ],
    knockout: [
    ],
  },

  POR_2006: {
    group: [
      { opp: "ANG", scoreFor: 1, scoreAgainst: 0 },
      { opp: "IRN", scoreFor: 2, scoreAgainst: 0 },
      { opp: "MEX", scoreFor: 2, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "NED", scoreFor: 1, scoreAgainst: 0 },
      { round: "QF", opp: "ENG", scoreFor: 0, scoreAgainst: 0, note: "penalty-uri 3-1" },
      { round: "SF", opp: "FRA", scoreFor: 0, scoreAgainst: 1 },
      { round: "3P", opp: "GER", scoreFor: 1, scoreAgainst: 3 },
    ],
  },

  SWE_2006: {
    group: [
      { opp: "TRI", scoreFor: 0, scoreAgainst: 0 },
      { opp: "PAR", scoreFor: 1, scoreAgainst: 0 },
      { opp: "ENG", scoreFor: 2, scoreAgainst: 2 },
    ],
    knockout: [
      { round: "R16", opp: "GER", scoreFor: 0, scoreAgainst: 2 },
    ],
  },

  USA_2006: {
    group: [
      { opp: "CZE", scoreFor: 0, scoreAgainst: 3 },
      { opp: "ITA", scoreFor: 1, scoreAgainst: 1 },
      { opp: "GHA", scoreFor: 1, scoreAgainst: 2 },
    ],
    knockout: [
    ],
  },

  ARG_2010: {
    group: [
      { opp: "NGA", scoreFor: 1, scoreAgainst: 0 },
      { opp: "KOR", scoreFor: 4, scoreAgainst: 1 },
      { opp: "GRE", scoreFor: 2, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "MEX", scoreFor: 3, scoreAgainst: 1 },
      { round: "QF", opp: "GER", scoreFor: 0, scoreAgainst: 4 },
    ],
  },

  BRA_2010: {
    group: [
      { opp: "PRK", scoreFor: 2, scoreAgainst: 1 },
      { opp: "CIV", scoreFor: 3, scoreAgainst: 1 },
      { opp: "POR", scoreFor: 0, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "CHI", scoreFor: 3, scoreAgainst: 0 },
      { round: "QF", opp: "NED", scoreFor: 1, scoreAgainst: 2 },
    ],
  },

  ENG_2010: {
    group: [
      { opp: "USA", scoreFor: 1, scoreAgainst: 1 },
      { opp: "ALG", scoreFor: 0, scoreAgainst: 0 },
      { opp: "SVN", scoreFor: 1, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "GER", scoreFor: 1, scoreAgainst: 4 },
    ],
  },

  ESP_2010: {
    group: [
      { opp: "SUI", scoreFor: 0, scoreAgainst: 1 },
      { opp: "HON", scoreFor: 2, scoreAgainst: 0 },
      { opp: "CHI", scoreFor: 2, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "POR", scoreFor: 1, scoreAgainst: 0 },
      { round: "QF", opp: "PAR", scoreFor: 1, scoreAgainst: 0 },
      { round: "SF", opp: "GER", scoreFor: 1, scoreAgainst: 0 },
      { round: "F", opp: "NED", scoreFor: 1, scoreAgainst: 0, note: "prelungiri" },
    ],
  },

  FRA_2010: {
    group: [
      { opp: "URU", scoreFor: 0, scoreAgainst: 0 },
      { opp: "MEX", scoreFor: 0, scoreAgainst: 2 },
      { opp: "RSA", scoreFor: 1, scoreAgainst: 2 },
    ],
    knockout: [
    ],
  },

  GER_2010: {
    group: [
      { opp: "AUS", scoreFor: 4, scoreAgainst: 0 },
      { opp: "SRB", scoreFor: 0, scoreAgainst: 1 },
      { opp: "GHA", scoreFor: 1, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "ENG", scoreFor: 4, scoreAgainst: 1 },
      { round: "QF", opp: "ARG", scoreFor: 4, scoreAgainst: 0 },
      { round: "SF", opp: "ESP", scoreFor: 0, scoreAgainst: 1 },
      { round: "3P", opp: "URU", scoreFor: 3, scoreAgainst: 2 },
    ],
  },

  ITA_2010: {
    group: [
      { opp: "PAR", scoreFor: 1, scoreAgainst: 1 },
      { opp: "NZL", scoreFor: 1, scoreAgainst: 1 },
      { opp: "SVK", scoreFor: 2, scoreAgainst: 3 },
    ],
    knockout: [
    ],
  },

  JPN_2010: {
    group: [
      { opp: "CMR", scoreFor: 1, scoreAgainst: 0 },
      { opp: "NED", scoreFor: 0, scoreAgainst: 1 },
      { opp: "DEN", scoreFor: 3, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "PAR", scoreFor: 0, scoreAgainst: 0, note: "penalty-uri 3-5" },
    ],
  },

  KOR_2010: {
    group: [
      { opp: "GRE", scoreFor: 2, scoreAgainst: 0 },
      { opp: "ARG", scoreFor: 1, scoreAgainst: 4 },
      { opp: "NGA", scoreFor: 2, scoreAgainst: 2 },
    ],
    knockout: [
      { round: "R16", opp: "URU", scoreFor: 1, scoreAgainst: 2 },
    ],
  },

  MEX_2010: {
    group: [
      { opp: "RSA", scoreFor: 1, scoreAgainst: 1 },
      { opp: "FRA", scoreFor: 2, scoreAgainst: 0 },
      { opp: "URU", scoreFor: 0, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "ARG", scoreFor: 1, scoreAgainst: 3 },
    ],
  },

  NED_2010: {
    group: [
      { opp: "DEN", scoreFor: 2, scoreAgainst: 0 },
      { opp: "JPN", scoreFor: 1, scoreAgainst: 0 },
      { opp: "CMR", scoreFor: 2, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "SVK", scoreFor: 2, scoreAgainst: 1 },
      { round: "QF", opp: "BRA", scoreFor: 2, scoreAgainst: 1 },
      { round: "SF", opp: "URU", scoreFor: 3, scoreAgainst: 2 },
      { round: "F", opp: "ESP", scoreFor: 0, scoreAgainst: 1, note: "prelungiri" },
    ],
  },

  POR_2010: {
    group: [
      { opp: "CIV", scoreFor: 0, scoreAgainst: 0 },
      { opp: "PRK", scoreFor: 7, scoreAgainst: 0 },
      { opp: "BRA", scoreFor: 0, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "ESP", scoreFor: 0, scoreAgainst: 1 },
    ],
  },

  URU_2010: {
    group: [
      { opp: "FRA", scoreFor: 0, scoreAgainst: 0 },
      { opp: "RSA", scoreFor: 3, scoreAgainst: 0 },
      { opp: "MEX", scoreFor: 1, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "KOR", scoreFor: 2, scoreAgainst: 1 },
      { round: "QF", opp: "GHA", scoreFor: 1, scoreAgainst: 1, note: "penalty-uri 4-2" },
      { round: "SF", opp: "NED", scoreFor: 2, scoreAgainst: 3 },
      { round: "3P", opp: "GER", scoreFor: 2, scoreAgainst: 3 },
    ],
  },

  USA_2010: {
    group: [
      { opp: "ENG", scoreFor: 1, scoreAgainst: 1 },
      { opp: "SVN", scoreFor: 2, scoreAgainst: 2 },
      { opp: "ALG", scoreFor: 1, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "GHA", scoreFor: 1, scoreAgainst: 2, note: "prelungiri" },
    ],
  },

  ARG_2014: {
    group: [
      { opp: "BIH", scoreFor: 2, scoreAgainst: 1 },
      { opp: "IRN", scoreFor: 1, scoreAgainst: 0 },
      { opp: "NGA", scoreFor: 3, scoreAgainst: 2 },
    ],
    knockout: [
      { round: "R16", opp: "SUI", scoreFor: 1, scoreAgainst: 0, note: "prelungiri" },
      { round: "QF", opp: "BEL", scoreFor: 1, scoreAgainst: 0 },
      { round: "SF", opp: "NED", scoreFor: 0, scoreAgainst: 0, note: "penalty-uri 4-2" },
      { round: "F", opp: "GER", scoreFor: 0, scoreAgainst: 1, note: "prelungiri" },
    ],
  },

  BEL_2014: {
    group: [
      { opp: "ALG", scoreFor: 2, scoreAgainst: 1 },
      { opp: "RUS", scoreFor: 1, scoreAgainst: 0 },
      { opp: "KOR", scoreFor: 1, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "USA", scoreFor: 2, scoreAgainst: 1, note: "prelungiri" },
      { round: "QF", opp: "ARG", scoreFor: 0, scoreAgainst: 1 },
    ],
  },

  BRA_2014: {
    group: [
      { opp: "CRO", scoreFor: 3, scoreAgainst: 1 },
      { opp: "MEX", scoreFor: 0, scoreAgainst: 0 },
      { opp: "CMR", scoreFor: 4, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "CHI", scoreFor: 1, scoreAgainst: 1, note: "penalty-uri 3-2" },
      { round: "QF", opp: "COL", scoreFor: 2, scoreAgainst: 1 },
      { round: "SF", opp: "GER", scoreFor: 1, scoreAgainst: 7 },
      { round: "3P", opp: "NED", scoreFor: 0, scoreAgainst: 3 },
    ],
  },

  CRO_2014: {
    group: [
      { opp: "BRA", scoreFor: 1, scoreAgainst: 3 },
      { opp: "CMR", scoreFor: 4, scoreAgainst: 0 },
      { opp: "MEX", scoreFor: 1, scoreAgainst: 3 },
    ],
    knockout: [
    ],
  },

  ENG_2014: {
    group: [
      { opp: "ITA", scoreFor: 1, scoreAgainst: 2 },
      { opp: "URU", scoreFor: 1, scoreAgainst: 2 },
      { opp: "CRC", scoreFor: 0, scoreAgainst: 0 },
    ],
    knockout: [
    ],
  },

  ESP_2014: {
    group: [
      { opp: "NED", scoreFor: 1, scoreAgainst: 5 },
      { opp: "CHI", scoreFor: 0, scoreAgainst: 2 },
      { opp: "AUS", scoreFor: 3, scoreAgainst: 0 },
    ],
    knockout: [
    ],
  },

  FRA_2014: {
    group: [
      { opp: "HON", scoreFor: 3, scoreAgainst: 0 },
      { opp: "SUI", scoreFor: 5, scoreAgainst: 2 },
      { opp: "ECU", scoreFor: 0, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "NGA", scoreFor: 2, scoreAgainst: 0 },
      { round: "QF", opp: "GER", scoreFor: 0, scoreAgainst: 1 },
    ],
  },

  GER_2014: {
    group: [
      { opp: "POR", scoreFor: 4, scoreAgainst: 0 },
      { opp: "GHA", scoreFor: 2, scoreAgainst: 2 },
      { opp: "USA", scoreFor: 1, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "ALG", scoreFor: 2, scoreAgainst: 1, note: "prelungiri" },
      { round: "QF", opp: "FRA", scoreFor: 1, scoreAgainst: 0 },
      { round: "SF", opp: "BRA", scoreFor: 7, scoreAgainst: 1, note: "\"Mineirazo\"" },
      { round: "F", opp: "ARG", scoreFor: 1, scoreAgainst: 0, note: "prelungiri" },
    ],
  },

  ITA_2014: {
    group: [
      { opp: "ENG", scoreFor: 2, scoreAgainst: 1 },
      { opp: "CRC", scoreFor: 0, scoreAgainst: 1 },
      { opp: "URU", scoreFor: 0, scoreAgainst: 1 },
    ],
    knockout: [
    ],
  },

  JPN_2014: {
    group: [
      { opp: "CIV", scoreFor: 1, scoreAgainst: 2 },
      { opp: "GRE", scoreFor: 0, scoreAgainst: 0 },
      { opp: "COL", scoreFor: 1, scoreAgainst: 4 },
    ],
    knockout: [
    ],
  },

  KOR_2014: {
    group: [
      { opp: "RUS", scoreFor: 1, scoreAgainst: 1 },
      { opp: "ALG", scoreFor: 2, scoreAgainst: 4 },
      { opp: "BEL", scoreFor: 0, scoreAgainst: 1 },
    ],
    knockout: [
    ],
  },

  MEX_2014: {
    group: [
      { opp: "CMR", scoreFor: 1, scoreAgainst: 0 },
      { opp: "BRA", scoreFor: 0, scoreAgainst: 0 },
      { opp: "CRO", scoreFor: 3, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "NED", scoreFor: 1, scoreAgainst: 2 },
    ],
  },

  NED_2014: {
    group: [
      { opp: "ESP", scoreFor: 5, scoreAgainst: 1 },
      { opp: "AUS", scoreFor: 3, scoreAgainst: 2 },
      { opp: "CHI", scoreFor: 2, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "MEX", scoreFor: 2, scoreAgainst: 1 },
      { round: "QF", opp: "CRC", scoreFor: 0, scoreAgainst: 0, note: "penalty-uri 4-3" },
      { round: "SF", opp: "ARG", scoreFor: 0, scoreAgainst: 0, note: "penalty-uri 2-4" },
      { round: "3P", opp: "BRA", scoreFor: 3, scoreAgainst: 0 },
    ],
  },

  POR_2014: {
    group: [
      { opp: "GER", scoreFor: 0, scoreAgainst: 4 },
      { opp: "USA", scoreFor: 2, scoreAgainst: 2 },
      { opp: "GHA", scoreFor: 2, scoreAgainst: 1 },
    ],
    knockout: [
    ],
  },

  URU_2014: {
    group: [
      { opp: "CRC", scoreFor: 1, scoreAgainst: 3 },
      { opp: "ENG", scoreFor: 2, scoreAgainst: 1 },
      { opp: "ITA", scoreFor: 1, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "COL", scoreFor: 0, scoreAgainst: 2 },
    ],
  },

  USA_2014: {
    group: [
      { opp: "GHA", scoreFor: 2, scoreAgainst: 1 },
      { opp: "POR", scoreFor: 2, scoreAgainst: 2 },
      { opp: "GER", scoreFor: 0, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "BEL", scoreFor: 1, scoreAgainst: 2, note: "prelungiri" },
    ],
  },

  ARG_2018: {
    group: [
      { opp: "ISL", scoreFor: 1, scoreAgainst: 1 },
      { opp: "CRO", scoreFor: 0, scoreAgainst: 3 },
      { opp: "NGA", scoreFor: 2, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "FRA", scoreFor: 3, scoreAgainst: 4 },
    ],
  },

  BEL_2018: {
    group: [
      { opp: "PAN", scoreFor: 3, scoreAgainst: 0 },
      { opp: "TUN", scoreFor: 5, scoreAgainst: 2 },
      { opp: "ENG", scoreFor: 1, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "JPN", scoreFor: 3, scoreAgainst: 2 },
      { round: "QF", opp: "BRA", scoreFor: 2, scoreAgainst: 1 },
      { round: "SF", opp: "FRA", scoreFor: 0, scoreAgainst: 1 },
      { round: "3P", opp: "ENG", scoreFor: 2, scoreAgainst: 0 },
    ],
  },

  BRA_2018: {
    group: [
      { opp: "SUI", scoreFor: 1, scoreAgainst: 1 },
      { opp: "CRC", scoreFor: 2, scoreAgainst: 0 },
      { opp: "SRB", scoreFor: 2, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "MEX", scoreFor: 2, scoreAgainst: 0 },
      { round: "QF", opp: "BEL", scoreFor: 1, scoreAgainst: 2 },
    ],
  },

  CRO_2018: {
    group: [
      { opp: "NGA", scoreFor: 2, scoreAgainst: 0 },
      { opp: "ARG", scoreFor: 3, scoreAgainst: 0 },
      { opp: "ISL", scoreFor: 2, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "DEN", scoreFor: 1, scoreAgainst: 1, note: "penalty-uri 3-2" },
      { round: "QF", opp: "RUS", scoreFor: 2, scoreAgainst: 2, note: "penalty-uri 4-3" },
      { round: "SF", opp: "ENG", scoreFor: 2, scoreAgainst: 1, note: "prelungiri" },
      { round: "F", opp: "FRA", scoreFor: 2, scoreAgainst: 4 },
    ],
  },

  ENG_2018: {
    group: [
      { opp: "TUN", scoreFor: 2, scoreAgainst: 1 },
      { opp: "PAN", scoreFor: 6, scoreAgainst: 1 },
      { opp: "BEL", scoreFor: 0, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "COL", scoreFor: 1, scoreAgainst: 1, note: "penalty-uri 4-3" },
      { round: "QF", opp: "SWE", scoreFor: 2, scoreAgainst: 0 },
      { round: "SF", opp: "CRO", scoreFor: 1, scoreAgainst: 2, note: "prelungiri" },
      { round: "3P", opp: "BEL", scoreFor: 0, scoreAgainst: 2 },
    ],
  },

  ESP_2018: {
    group: [
      { opp: "POR", scoreFor: 3, scoreAgainst: 3 },
      { opp: "IRN", scoreFor: 1, scoreAgainst: 0 },
      { opp: "MAR", scoreFor: 2, scoreAgainst: 2 },
    ],
    knockout: [
      { round: "R16", opp: "RUS", scoreFor: 1, scoreAgainst: 1, note: "penalty-uri 3-4" },
    ],
  },

  FRA_2018: {
    group: [
      { opp: "AUS", scoreFor: 2, scoreAgainst: 1 },
      { opp: "PER", scoreFor: 1, scoreAgainst: 0 },
      { opp: "DEN", scoreFor: 0, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "ARG", scoreFor: 4, scoreAgainst: 3 },
      { round: "QF", opp: "URU", scoreFor: 2, scoreAgainst: 0 },
      { round: "SF", opp: "BEL", scoreFor: 1, scoreAgainst: 0 },
      { round: "F", opp: "CRO", scoreFor: 4, scoreAgainst: 2 },
    ],
  },

  GER_2018: {
    group: [
      { opp: "MEX", scoreFor: 0, scoreAgainst: 1 },
      { opp: "SWE", scoreFor: 2, scoreAgainst: 1 },
      { opp: "KOR", scoreFor: 0, scoreAgainst: 2 },
    ],
    knockout: [
    ],
  },

  JPN_2018: {
    group: [
      { opp: "COL", scoreFor: 2, scoreAgainst: 1 },
      { opp: "SEN", scoreFor: 2, scoreAgainst: 2 },
      { opp: "POL", scoreFor: 0, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "BEL", scoreFor: 2, scoreAgainst: 3 },
    ],
  },

  KOR_2018: {
    group: [
      { opp: "SWE", scoreFor: 0, scoreAgainst: 1 },
      { opp: "MEX", scoreFor: 1, scoreAgainst: 2 },
      { opp: "GER", scoreFor: 2, scoreAgainst: 0 },
    ],
    knockout: [
    ],
  },

  MAR_2018: {
    group: [
      { opp: "IRN", scoreFor: 0, scoreAgainst: 1 },
      { opp: "POR", scoreFor: 0, scoreAgainst: 1 },
      { opp: "ESP", scoreFor: 2, scoreAgainst: 2 },
    ],
    knockout: [
    ],
  },

  MEX_2018: {
    group: [
      { opp: "GER", scoreFor: 1, scoreAgainst: 0 },
      { opp: "KOR", scoreFor: 2, scoreAgainst: 1 },
      { opp: "SWE", scoreFor: 0, scoreAgainst: 3 },
    ],
    knockout: [
      { round: "R16", opp: "BRA", scoreFor: 0, scoreAgainst: 2 },
    ],
  },

  POL_2018: {
    group: [
      { opp: "SEN", scoreFor: 1, scoreAgainst: 2 },
      { opp: "COL", scoreFor: 0, scoreAgainst: 3 },
      { opp: "JPN", scoreFor: 1, scoreAgainst: 0 },
    ],
    knockout: [
    ],
  },

  POR_2018: {
    group: [
      { opp: "ESP", scoreFor: 3, scoreAgainst: 3 },
      { opp: "MAR", scoreFor: 1, scoreAgainst: 0 },
      { opp: "IRN", scoreFor: 1, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "URU", scoreFor: 1, scoreAgainst: 2 },
    ],
  },

  SWE_2018: {
    group: [
      { opp: "KOR", scoreFor: 1, scoreAgainst: 0 },
      { opp: "GER", scoreFor: 1, scoreAgainst: 2 },
      { opp: "MEX", scoreFor: 3, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "SUI", scoreFor: 1, scoreAgainst: 0 },
      { round: "QF", opp: "ENG", scoreFor: 0, scoreAgainst: 2 },
    ],
  },

  URU_2018: {
    group: [
      { opp: "EGY", scoreFor: 1, scoreAgainst: 0 },
      { opp: "KSA", scoreFor: 1, scoreAgainst: 0 },
      { opp: "RUS", scoreFor: 3, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "POR", scoreFor: 2, scoreAgainst: 1 },
      { round: "QF", opp: "FRA", scoreFor: 0, scoreAgainst: 2 },
    ],
  },

  ARG_2022: {
    group: [
      { opp: "KSA", scoreFor: 1, scoreAgainst: 2 },
      { opp: "MEX", scoreFor: 2, scoreAgainst: 0 },
      { opp: "POL", scoreFor: 2, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "AUS", scoreFor: 2, scoreAgainst: 1 },
      { round: "QF", opp: "NED", scoreFor: 2, scoreAgainst: 2, note: "penalty-uri 4-3" },
      { round: "SF", opp: "CRO", scoreFor: 3, scoreAgainst: 0 },
      { round: "F", opp: "FRA", scoreFor: 3, scoreAgainst: 3, note: "penalty-uri 4-2 — una dintre cele mai mari finale din istorie" },
    ],
  },

  BEL_2022: {
    group: [
      { opp: "CAN", scoreFor: 1, scoreAgainst: 0 },
      { opp: "MAR", scoreFor: 0, scoreAgainst: 2 },
      { opp: "CRO", scoreFor: 0, scoreAgainst: 0 },
    ],
    knockout: [
    ],
  },

  BRA_2022: {
    group: [
      { opp: "SRB", scoreFor: 2, scoreAgainst: 0 },
      { opp: "SUI", scoreFor: 1, scoreAgainst: 0 },
      { opp: "CMR", scoreFor: 0, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "KOR", scoreFor: 4, scoreAgainst: 1 },
      { round: "QF", opp: "CRO", scoreFor: 1, scoreAgainst: 1, note: "penalty-uri 2-4" },
    ],
  },

  CRO_2022: {
    group: [
      { opp: "MAR", scoreFor: 0, scoreAgainst: 0 },
      { opp: "CAN", scoreFor: 4, scoreAgainst: 1 },
      { opp: "BEL", scoreFor: 0, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "JPN", scoreFor: 1, scoreAgainst: 1, note: "penalty-uri 3-1" },
      { round: "QF", opp: "BRA", scoreFor: 1, scoreAgainst: 1, note: "penalty-uri 4-2" },
      { round: "SF", opp: "ARG", scoreFor: 0, scoreAgainst: 3 },
      { round: "3P", opp: "MAR", scoreFor: 2, scoreAgainst: 1 },
    ],
  },

  ENG_2022: {
    group: [
      { opp: "IRN", scoreFor: 6, scoreAgainst: 2 },
      { opp: "USA", scoreFor: 0, scoreAgainst: 0 },
      { opp: "WAL", scoreFor: 3, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "SEN", scoreFor: 3, scoreAgainst: 0 },
      { round: "QF", opp: "FRA", scoreFor: 1, scoreAgainst: 2 },
    ],
  },

  ESP_2022: {
    group: [
      { opp: "CRC", scoreFor: 7, scoreAgainst: 0 },
      { opp: "GER", scoreFor: 1, scoreAgainst: 1 },
      { opp: "JPN", scoreFor: 1, scoreAgainst: 2 },
    ],
    knockout: [
      { round: "R16", opp: "MAR", scoreFor: 0, scoreAgainst: 0, note: "penalty-uri 0-3" },
    ],
  },

  FRA_2022: {
    group: [
      { opp: "AUS", scoreFor: 4, scoreAgainst: 1 },
      { opp: "DEN", scoreFor: 2, scoreAgainst: 1 },
      { opp: "TUN", scoreFor: 0, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "POL", scoreFor: 3, scoreAgainst: 1 },
      { round: "QF", opp: "ENG", scoreFor: 2, scoreAgainst: 1 },
      { round: "SF", opp: "MAR", scoreFor: 2, scoreAgainst: 0 },
      { round: "F", opp: "ARG", scoreFor: 3, scoreAgainst: 3, note: "penalty-uri 2-4" },
    ],
  },

  GER_2022: {
    group: [
      { opp: "JPN", scoreFor: 1, scoreAgainst: 2 },
      { opp: "ESP", scoreFor: 1, scoreAgainst: 1 },
      { opp: "CRC", scoreFor: 4, scoreAgainst: 2 },
    ],
    knockout: [
    ],
  },

  JPN_2022: {
    group: [
      { opp: "GER", scoreFor: 2, scoreAgainst: 1 },
      { opp: "CRC", scoreFor: 0, scoreAgainst: 1 },
      { opp: "ESP", scoreFor: 2, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "CRO", scoreFor: 1, scoreAgainst: 1, note: "penalty-uri 1-3" },
    ],
  },

  KOR_2022: {
    group: [
      { opp: "URU", scoreFor: 0, scoreAgainst: 0 },
      { opp: "GHA", scoreFor: 2, scoreAgainst: 3 },
      { opp: "POR", scoreFor: 2, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "BRA", scoreFor: 1, scoreAgainst: 4 },
    ],
  },

  MAR_2022: {
    group: [
      { opp: "CRO", scoreFor: 0, scoreAgainst: 0 },
      { opp: "BEL", scoreFor: 2, scoreAgainst: 0 },
      { opp: "CAN", scoreFor: 2, scoreAgainst: 1 },
    ],
    knockout: [
      { round: "R16", opp: "ESP", scoreFor: 0, scoreAgainst: 0, note: "penalty-uri 3-0" },
      { round: "QF", opp: "POR", scoreFor: 1, scoreAgainst: 0 },
      { round: "SF", opp: "FRA", scoreFor: 0, scoreAgainst: 2 },
      { round: "3P", opp: "CRO", scoreFor: 1, scoreAgainst: 2 },
    ],
  },

  MEX_2022: {
    group: [
      { opp: "POL", scoreFor: 0, scoreAgainst: 0 },
      { opp: "ARG", scoreFor: 0, scoreAgainst: 2 },
      { opp: "KSA", scoreFor: 2, scoreAgainst: 1 },
    ],
    knockout: [
    ],
  },

  NED_2022: {
    group: [
      { opp: "SEN", scoreFor: 2, scoreAgainst: 0 },
      { opp: "ECU", scoreFor: 1, scoreAgainst: 1 },
      { opp: "QAT", scoreFor: 2, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "USA", scoreFor: 3, scoreAgainst: 1 },
      { round: "QF", opp: "ARG", scoreFor: 2, scoreAgainst: 2, note: "penalty-uri 3-4" },
    ],
  },

  POL_2022: {
    group: [
      { opp: "MEX", scoreFor: 0, scoreAgainst: 0 },
      { opp: "KSA", scoreFor: 2, scoreAgainst: 0 },
      { opp: "ARG", scoreFor: 0, scoreAgainst: 2 },
    ],
    knockout: [
      { round: "R16", opp: "FRA", scoreFor: 1, scoreAgainst: 3 },
    ],
  },

  POR_2022: {
    group: [
      { opp: "GHA", scoreFor: 3, scoreAgainst: 2 },
      { opp: "URU", scoreFor: 2, scoreAgainst: 0 },
      { opp: "KOR", scoreFor: 1, scoreAgainst: 2 },
    ],
    knockout: [
      { round: "R16", opp: "SUI", scoreFor: 6, scoreAgainst: 1 },
      { round: "QF", opp: "MAR", scoreFor: 0, scoreAgainst: 1 },
    ],
  },

  URU_2022: {
    group: [
      { opp: "KOR", scoreFor: 0, scoreAgainst: 0 },
      { opp: "POR", scoreFor: 0, scoreAgainst: 2 },
      { opp: "GHA", scoreFor: 2, scoreAgainst: 0 },
    ],
    knockout: [
    ],
  },

  USA_2022: {
    group: [
      { opp: "WAL", scoreFor: 1, scoreAgainst: 1 },
      { opp: "ENG", scoreFor: 0, scoreAgainst: 0 },
      { opp: "IRN", scoreFor: 1, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "NED", scoreFor: 1, scoreAgainst: 3 },
    ],
  },

};

if (typeof module !== "undefined" && module.exports) {
  module.exports = { REAL_FIXTURES };
}
