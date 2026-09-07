/* ============================================================
   HISTORY OF WORLD CUP — real_fixtures.js
   Traseul real (grupă + eliminatorii) al câtorva campanii istorice
   iconice, verificat pe fapte general cunoscute despre Cupa Mondială.

   IMPORTANT — scope v1: acesta este un SUBSET curat (11 campanii,
   ~50 meciuri reale), nu baza de date completă de 1316 meciuri din
   prototipul original (construită într-o sesiune anterioară, care nu
   mai există). Structura e identică, deci poate fi extinsă oricând
   cu mai multe campanii fără nicio schimbare de motor — vezi
   "Următorii pași" din README.

   Cheie: "<COD_ECHIPA>_<AN>". Fiecare campanie are:
     group:    listă ordonată de meciuri reale din grupă
     knockout: listă ordonată de meciuri reale eliminatorii
   Fiecare meci: { opp, scoreFor, scoreAgainst, round? }
   Scorurile sunt informative (comparate cu rezultatul simulat) —
   NU determină rezultatul simulării.
   ============================================================ */

const REAL_FIXTURES = {

  URU_1930: {
    group: [
      { opp: "PER", scoreFor: 1, scoreAgainst: 0 },
      { opp: "ROU", scoreFor: 4, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "SF", opp: "YUG", scoreFor: 6, scoreAgainst: 1 },
      { round: "F",  opp: "ARG", scoreFor: 4, scoreAgainst: 2 },
    ],
  },

  BRA_1950: {
    group: [
      { opp: "MEX", scoreFor: 4, scoreAgainst: 0 },
      { opp: "SUI", scoreFor: 2, scoreAgainst: 2 },
      { opp: "YUG", scoreFor: 2, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "SF", opp: "SWE", scoreFor: 7, scoreAgainst: 1, note: "grupă finală round-robin, mapată ca eliminatorii" },
      { round: "F",  opp: "URU", scoreFor: 1, scoreAgainst: 2, note: "\"Maracanazo\" — meciul decisiv al grupei finale" },
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
      { round: "F",  opp: "HUN", scoreFor: 3, scoreAgainst: 2, note: "\"Miracolul de la Berna\"" },
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
      { round: "F",  opp: "GER", scoreFor: 4, scoreAgainst: 2, note: "prelungiri" },
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
      { round: "SF", opp: "URU", scoreFor: 3, scoreAgainst: 2 },
      { round: "F",  opp: "ITA", scoreFor: 4, scoreAgainst: 1 },
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
      { round: "F",  opp: "GER", scoreFor: 3, scoreAgainst: 2 },
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
      { round: "F",  opp: "ARG", scoreFor: 1, scoreAgainst: 0 },
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
      { round: "F",  opp: "BRA", scoreFor: 3, scoreAgainst: 0 },
    ],
  },

  JPN_2002: {
    group: [
      { opp: "RUS", scoreFor: 1, scoreAgainst: 0 },
      { opp: "BEL", scoreFor: 2, scoreAgainst: 2 },
      { opp: "TUN", scoreFor: 2, scoreAgainst: 0 },
    ],
    knockout: [
      { round: "R16", opp: "TUR", scoreFor: 0, scoreAgainst: 1 },
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
      { round: "F",  opp: "GER", scoreFor: 2, scoreAgainst: 0 },
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
      { round: "F",  opp: "ARG", scoreFor: 1, scoreAgainst: 0, note: "prelungiri" },
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
      { round: "F",  opp: "FRA", scoreFor: 3, scoreAgainst: 3, note: "penalty-uri 4-2 — una dintre cele mai mari finale din istorie" },
    ],
  },

};

if (typeof module !== "undefined" && module.exports) {
  module.exports = { REAL_FIXTURES };
}
