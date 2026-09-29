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
    struct Extra: Decodable { let a: Double; let b: Double; let et: String; let cards: String }
    struct Pool: Decodable { let year: Int; let pool: [String] }
    struct CareerCase: Decodable {
        let tactics: Int, team: String, year: Int, seed: UInt32
        let squad: [String]
        let records: [String]
        let tables: [String]
        let log: String
        let outcome: String?, outStage: String, label: String
        let rng: UInt32
    }
    let rng: [RNG]
    let seeds: [Seed]
    let years: [Int]
    let ratings: [Ratings]
    let eligible: [Eligible]
    let squadCases: [SquadCase]
    let matches: [Match]
    let tacticSets: [[[String]]]
    let extras: [Extra]
    let pools: [Pool]
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
        XCTAssertEqual(engine.data.editions.count, 23)
        XCTAssertEqual(engine.data.formats.count, 23)
        XCTAssertEqual(engine.data.teams.count, 23)
        XCTAssertEqual(engine.data.legends.count, 18)
        XCTAssertGreaterThanOrEqual(engine.data.campaigns.count, 250)
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

    func testExtraTimeAndCardsMatchJS() {
        var r = Mulberry32(seed: 4242)
        var sr = Mulberry32(seed: 5)
        let eleven = Array(engine.generateSquad("BRA", 1970, &sr).prefix(11))
        for (i, x) in golden.extras.enumerated() {
            let et = Engine.simulateExtraTime(teamAName: "A", teamAAttack: x.a, teamADefense: x.a,
                                              teamBName: "B", teamBAttack: x.b, teamBDefense: x.b, rng: &r)
            let cards = Engine.simulateCards(count: eleven.count, &r)
            XCTAssertEqual("\(et.scoreA)-\(et.scoreB):" + et.events.map { "\($0.minute)\($0.team.rawValue)" }.joined(separator: ","), x.et, "extra \(i)")
            XCTAssertEqual(cards.map { "\($0.minute)\($0.type)\($0.k)" }.joined(separator: ","), x.cards, "cards \(i)")
        }
    }

    func testEditionPoolsMatchJS() {
        for p in golden.pools {
            XCTAssertEqual(engine.data.editionPool(p.year), p.pool, "\(p.year)")
        }
    }

    static func describeCareer(_ c: Career) -> (records: [String], tables: [String]) {
        let records = c.records.map { r -> String in
            [r.kind, r.round ?? "", r.label, r.opp, r.isReal ? "1" : "0", "\(r.gf)", "\(r.ga)", r.extraTime ? "1" : "0",
             r.pens ?? "", r.lots?.rawValue ?? "", r.replay ? "1" : "0", r.tied ? "1" : "0", r.won.map { $0 ? "1" : "0" } ?? "",
             r.events.map { "\($0.minute)\($0.team.rawValue)\($0.scorer ?? "")" }.joined(separator: ","),
             r.cards.map { "\($0.minute)\($0.team.rawValue)\($0.type)\($0.player)" }.joined(separator: ","),
             r.suspended.joined(separator: ",")].joined(separator: "|")
        }
        let tables = c.tables.map { t -> String in
            let playoff: String
            if let p = t.playoff {
                if let o = p.result { playoff = "O:\(o.home)-\(o.away):\(o.gh)-\(o.ga):\(o.winner ?? "")" }
                else { playoff = "P:\(p.opp ?? ""):\(p.won == true ? 1 : 0)" }
            } else { playoff = "" }
            let thirds = t.thirds.map { "\($0.rank):" + $0.rows.map { "\($0.code)\($0.pts)/\($0.gf)-\($0.ga)" }.joined(separator: ",") } ?? ""
            return [t.type, "\(t.rank)", t.qualified ? "1" : "0",
                    t.rows.map { "\($0.code):\($0.pl):\($0.gf)-\($0.ga):\($0.pts)" }.joined(separator: ","),
                    t.others.map { "\($0.home)-\($0.away):\($0.gh)-\($0.ga)" + ($0.winner.map { ":" + $0 } ?? "") }.joined(separator: ","),
                    playoff, thirds].joined(separator: "|")
        }
        return (records, tables)
    }

    func testFullCareersMatchJS() {
        for c in golden.careers {
            let tag = "\(c.team) \(c.year) tactici#\(c.tactics)"
            let tactics = golden.tacticSets[c.tactics].map { (Mentality(rawValue: $0[0])!, Formation(rawValue: $0[1])!) }
            var career = Career(teamCode: c.team, year: c.year, seed: c.seed, engine: engine)
            XCTAssertEqual(career.squad.map(describe), c.squad, tag)
            var n = 0
            while !career.isFinished && n < 20 {
                let t = tactics[n % tactics.count]
                career.mentality = t.0
                career.formation = t.1
                career.playNext(engine: engine)
                n += 1
            }
            let d = Self.describeCareer(career)
            XCTAssertEqual(d.records.count, c.records.count, tag)
            for (i, (a, b)) in zip(d.records, c.records).enumerated() { XCTAssertEqual(a, b, "\(tag) meci \(i)") }
            XCTAssertEqual(d.tables, c.tables, tag)
            XCTAssertEqual(career.byes.joined(separator: ","), c.log, tag)
            XCTAssertEqual(career.outcome?.rawValue, c.outcome, tag)
            XCTAssertEqual(career.outStage ?? "", c.outStage, tag)
            XCTAssertEqual(career.outcomeLabel, c.label, tag)
            XCTAssertEqual(career.rng.state, c.rng, tag)
        }
    }

    func testCareerIsCodableMidway() throws {
        var a = Career(teamCode: "BRA", year: 1970, seed: 12345, engine: engine)
        a.playNext(engine: engine)
        let data = try JSONEncoder().encode(a)
        var b = try JSONDecoder().decode(Career.self, from: data)
        while !a.isFinished {
            let ra = a.playNext(engine: engine)
            let rb = b.playNext(engine: engine)
            XCTAssertEqual(ra, rb)
        }
        XCTAssertEqual(a.outcome, b.outcome)
    }

    func testRealOpponentsForArgentina1986() {
        let c = Career(teamCode: "ARG", year: 1986, seed: 1, engine: engine)
        XCTAssertEqual(c.groupMembers, ["ARG", "KOR", "ITA", "BUL"])
        XCTAssertEqual(c.nextMatch?.real, RealScore(scoreFor: 3, scoreAgainst: 1))
        XCTAssertEqual(engine.data.formats[1986]?.stages.map { $0.round ?? $0.type }, ["group", "R16", "QF", "SF", "F"])
    }

    func testSwedenHasByeIn1938() {
        let c = Career(teamCode: "SWE", year: 1938, seed: 7, engine: engine)
        XCTAssertEqual(c.byes, ["R16"])
        XCTAssertEqual(c.nextMatch?.round, "QF")
        XCTAssertEqual(c.nextMatch?.opp, "CUB")
    }

    func testLegendsAppearInRealRosters() {
        var r = Mulberry32(seed: 9)
        let squad = engine.generateSquad("BRA", 1970, &r)
        XCTAssertTrue(squad.contains { $0.name == "Pelé" && $0.isLegend && $0.bio != nil })
    }
}
