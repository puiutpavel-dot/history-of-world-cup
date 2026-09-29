import XCTest
@testable import WorldCupCore

/// Vectorii de referință generați din motorul JS (`node tools/make_golden.js`).
struct Golden: Decodable {
    struct RNG: Decodable { let seed: UInt32; let values: [Double] }
    struct Seed: Decodable { let input: String; let seed: UInt32 }
    struct Ratings: Decodable { let code: String; let values: [Int] }
    struct Eligible: Decodable { let year: Int; let teams: [String] }
    struct SquadCase: Decodable { let code: String; let year: Int; let seed: UInt32; let players: [String] }
    struct Match: Decodable {
        let atkA: Double, defA: Double, atkB: Double, defB: Double
        let home: String?
        let scoreA: Int, scoreB: Int
        let events: [String]
        let pens: String
    }
    struct CareerMatch: Decodable {
        let stage: String, opp: String, isReal: Bool
        let `for`: Int, against: Int
        let events: [String]
        let pens: String?
    }
    struct CareerCase: Decodable {
        let tactics: Int, team: String, year: Int, seed: UInt32
        let squad: [String], groupOpponents: [String]
        let matches: [CareerMatch]
        let standings: [String]?
        let outcome: String, finalStage: String
    }
    let rng: [RNG]
    let seeds: [Seed]
    let years: [Int]
    let ratings: [Ratings]
    let eligible: [Eligible]
    let squadCases: [SquadCase]
    let matches: [Match]
    let tacticSets: [[[String]]]
    let careers: [CareerCase]

    static let shared: Golden = {
        let url = Bundle.module.url(forResource: "Golden", withExtension: "json")!
        return try! JSONDecoder().decode(Golden.self, from: Data(contentsOf: url))
    }()
}

func describe(_ p: Player) -> String { "\(p.pos.rawValue)|\(p.name)|\(p.overall)|\(p.isLegend ? 1 : 0)" }

final class ParityTests: XCTestCase {
    let golden = Golden.shared
    let engine = Engine()

    func testDataLoads() {
        XCTAssertEqual(engine.data.editions.count, 22)
        XCTAssertEqual(engine.data.teams.count, 23)
        XCTAssertEqual(engine.data.legends.count, 18)
        XCTAssertEqual(engine.data.campaigns.count, 12)
        XCTAssertGreaterThanOrEqual(engine.data.rosters.count, 300)
    }

    func testMulberry32MatchesJS() {
        for c in golden.rng {
            var r = Mulberry32(seed: c.seed)
            for (i, expected) in c.values.enumerated() {
                let value = r.next()
                XCTAssertEqual(value, expected, "seed \(c.seed) index \(i)")
            }
        }
    }

    func testSeedForMatchesJS() {
        for c in golden.seeds {
            XCTAssertEqual(seedFor(c.input), c.seed, "seedFor(\"\(c.input)\")")
        }
    }

    func testRatingsMatchJS() {
        for c in golden.ratings {
            for (i, year) in golden.years.enumerated() {
                XCTAssertEqual(engine.ratingAt(c.code, year), c.values[i], "\(c.code) \(year)")
            }
        }
    }

    func testEligibleTeamsMatchJS() {
        for c in golden.eligible {
            XCTAssertEqual(engine.eligibleTeams(c.year).map(\.code), c.teams, "\(c.year)")
        }
    }

    func testSquadsMatchJS() {
        for c in golden.squadCases {
            var r = Mulberry32(seed: c.seed)
            let squad = engine.generateSquad(c.code, c.year, &r)
            XCTAssertEqual(squad.map(describe), c.players, "\(c.code) \(c.year)")
        }
    }

    func testMatchesAndPenaltiesMatchJS() {
        var r = Mulberry32(seed: 777)
        for (i, m) in golden.matches.enumerated() {
            let home: Side? = m.home.flatMap(Side.init(rawValue:))
            let sim = Engine.simulateMatch(teamAName: "A", teamAAttack: m.atkA, teamADefense: m.defA,
                                           teamBName: "B", teamBAttack: m.atkB, teamBDefense: m.defB,
                                           rng: &r, homeTeam: home)
            let pens = Engine.simulatePenalties(m.atkA, m.atkB, &r)
            XCTAssertEqual(sim.scoreA, m.scoreA, "match \(i)")
            XCTAssertEqual(sim.scoreB, m.scoreB, "match \(i)")
            XCTAssertEqual(sim.events.map { "\($0.minute)\($0.team.rawValue)" }, m.events, "match \(i)")
            XCTAssertEqual("\(pens.scoreA)-\(pens.scoreB)\(pens.winner.rawValue)", m.pens, "match \(i)")
        }
    }

    func testFullCareersMatchJS() {
        for c in golden.careers {
            let tag = "\(c.team) \(c.year) tactici#\(c.tactics)"
            let tactics = golden.tacticSets[c.tactics].map { (Mentality(rawValue: $0[0])!, Formation(rawValue: $0[1])!) }
            var career = Career(teamCode: c.team, year: c.year, seed: c.seed, engine: engine)
            XCTAssertEqual(career.squad.map(describe), c.squad, tag)
            XCTAssertEqual(career.groupOpponents.map { $0.code + ($0.isReal ? "*" : "") }, c.groupOpponents, tag)

            var played: [MatchRecord] = []
            var n = 0
            while !career.isFinished && n < 10 {
                let t = tactics[n % tactics.count]
                career.mentality = t.0
                career.formation = t.1
                played.append(career.playCurrentMatch(engine: engine))
                n += 1
            }
            XCTAssertEqual(played.count, c.matches.count, tag)
            for (p, e) in zip(played, c.matches) {
                XCTAssertEqual(p.stage.rawValue, e.stage, tag)
                XCTAssertEqual(p.opp, e.opp, tag)
                XCTAssertEqual(p.isReal, e.isReal, tag)
                XCTAssertEqual(p.goalsFor, e.for, tag)
                XCTAssertEqual(p.goalsAgainst, e.against, tag)
                XCTAssertEqual(p.pens, e.pens, tag)
                XCTAssertEqual(p.events.map { "\($0.minute)\($0.team.rawValue)\($0.scorer ?? "")" }, e.events, tag)
            }
            XCTAssertEqual(career.standings?.map { "\($0.code):\($0.pl):\($0.gf)-\($0.ga):\($0.pts)" }, c.standings, tag)
            XCTAssertEqual(career.outcome?.rawValue, c.outcome, tag)
            XCTAssertEqual(career.stage.rawValue, c.finalStage, tag)
        }
    }

    func testCareerIsCodableMidway() throws {
        var a = Career(teamCode: "BRA", year: 1970, seed: 12345, engine: engine)
        a.playCurrentMatch(engine: engine)
        let data = try JSONEncoder().encode(a)
        var b = try JSONDecoder().decode(Career.self, from: data)
        // după restaurare, cariera continuă identic
        while !a.isFinished {
            let ra = a.playCurrentMatch(engine: engine)
            let rb = b.playCurrentMatch(engine: engine)
            XCTAssertEqual(ra, rb)
        }
        XCTAssertEqual(a.outcome, b.outcome)
    }

    func testRealOpponentsForArgentina1986() {
        var c = Career(teamCode: "ARG", year: 1986, seed: 1, engine: engine)
        XCTAssertEqual(c.groupOpponents.map(\.code), ["KOR", "ITA", "BUL"])
        XCTAssertTrue(c.groupOpponents.allSatisfy(\.isReal))
        XCTAssertEqual(c.knockoutPlan.compactMap { $0?.opp }, ["ENG", "BEL", "GER"])
        let first = c.currentOpponent(engine: engine)
        XCTAssertEqual(first.real, RealScore(scoreFor: 3, scoreAgainst: 1))
    }

    func testLegendsAppearInRealRosters() {
        var r = Mulberry32(seed: 9)
        let squad = engine.generateSquad("BRA", 1970, &r)
        XCTAssertTrue(squad.contains { $0.name == "Pelé" && $0.isLegend && $0.bio != nil })
    }
}
