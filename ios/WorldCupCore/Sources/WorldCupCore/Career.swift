import Foundation

// Starea unei cariere — port al obiectului `CAREER` și al funcțiilor
// startCareer / currentOpponentInfo / playCurrentMatch / afterMatch /
// finishGroupStage din app.js, fără nicio dependență de UI.

public enum Stage: String, Codable, Sendable {
    case group, QF, SF, F

    public var label: String {
        switch self {
        case .group: return "Faza grupelor"
        case .QF: return "Sferturi de finală"
        case .SF: return "Semifinală"
        case .F: return "Finală"
        }
    }

    /// „Eliminată în …”
    public var eliminationPlace: String {
        switch self {
        case .group: return "grupe"
        case .QF: return "sferturi"
        case .SF: return "semifinală"
        case .F: return "finală"
        }
    }

    public var shortLabel: String {
        switch self {
        case .group: return "Grupă"
        case .QF: return "Sferturi"
        case .SF: return "Semifinală"
        case .F: return "Finală"
        }
    }
}

public enum Outcome: String, Codable, Sendable {
    case champion
    case eliminatedGroup = "eliminated-group"
    case eliminatedKnockout = "eliminated-knockout"
}

public struct RealScore: Codable, Hashable, Sendable {
    public let scoreFor: Int
    public let scoreAgainst: Int
}

public struct GroupOpponent: Codable, Hashable, Sendable {
    public let code: String
    public let isReal: Bool
}

public struct KnockoutPlanEntry: Codable, Hashable, Sendable {
    public let opp: String
    public let real: RealScore
    public let note: String?
}

public struct OpponentInfo: Codable, Hashable, Sendable {
    public let code: String
    public let isReal: Bool
    public let real: RealScore?
    public let roundLabel: String
    public let note: String?
}

public struct MatchPreview: Sendable {
    public let opponent: OpponentInfo
    public let yourRatings: TacticalRatings
    public let opponentRatings: TacticalRatings
    public let opponentSquad: [Player]
}

public struct MatchRecord: Codable, Hashable, Sendable {
    public let stage: Stage
    public let opp: String
    public let isReal: Bool
    public let goalsFor: Int
    public let goalsAgainst: Int
    /// Scorul la penalty-uri, ex. "4-3" (doar în eliminatorii, la egalitate).
    public let pens: String?
    public let real: RealScore?
    public let won: Bool?
    public let events: [MatchEvent]

    public var scoreText: String {
        "\(goalsFor)-\(goalsAgainst)" + (pens.map { " (pen. \($0))" } ?? "")
    }

    /// „Confirmă sau rescrie istoria”: nil dacă meciul nu are corespondent real.
    public var historyRepeated: Bool? {
        guard isReal, let real else { return nil }
        return real.scoreFor == goalsFor && real.scoreAgainst == goalsAgainst
    }
}

public struct StandingRow: Codable, Hashable, Sendable {
    public let code: String
    public var pts = 0
    public var gf = 0
    public var ga = 0
    public var pl = 0
}

public struct OtherGroupResult: Codable, Hashable, Sendable {
    public let home: String
    public let away: String
    public let goalsHome: Int
    public let goalsAway: Int
}

public struct Career: Codable, Sendable {
    public let teamCode: String
    public let year: Int
    public private(set) var rng: Mulberry32
    public private(set) var squad: [Player]
    public var mentality: Mentality = .echilibrat
    public var formation: Formation = .f442

    public private(set) var groupOpponents: [GroupOpponent]
    public private(set) var groupMatchIndex = 0
    public private(set) var groupResults: [MatchRecord] = []
    public private(set) var otherGroupResults: [OtherGroupResult] = []
    public private(set) var standings: [StandingRow]?

    public private(set) var stage: Stage = .group
    public private(set) var knockoutPlan: [KnockoutPlanEntry?]
    public private(set) var knockoutIndex = 0
    public private(set) var knockoutResults: [MatchRecord] = []
    public private(set) var usedOpponents: [String]
    public private(set) var outcome: Outcome?

    private struct DrawnOpponent: Codable, Hashable { let stage: Stage; let code: String }
    private var pendingDrawn: DrawnOpponent?

    public var isFinished: Bool { outcome != nil }
    public var allResults: [MatchRecord] { groupResults + knockoutResults }

    /// `startCareer(teamCode)` — `seed` înlocuiește `seedFor("\(team)-\(year)-\(Date.now)")`.
    public init(teamCode: String, year: Int, seed: UInt32, engine: Engine) {
        self.teamCode = teamCode
        self.year = year
        var rng = Mulberry32(seed: seed)
        squad = engine.generateSquad(teamCode, year, &rng)

        let realGroup = engine.realGroupOpponents(teamCode, year)
        var used = [teamCode]
        var group: [GroupOpponent] = []
        for i in 0..<3 {
            var opp = i < realGroup.count ? realGroup[i] : nil
            let isReal = opp != nil
            if opp == nil {
                opp = engine.drawOpponent(&rng, excluding: used + group.map(\.code))
            }
            used.append(opp!)
            group.append(GroupOpponent(code: opp!, isReal: isReal))
        }
        groupOpponents = group
        usedOpponents = used

        knockoutPlan = engine.knockoutPlan(teamCode, year).map { m in
            m.map { KnockoutPlanEntry(opp: $0.opp, real: RealScore(scoreFor: $0.scoreFor, scoreAgainst: $0.scoreAgainst), note: $0.note) }
        }
        self.rng = rng
    }

    /// Pornește o carieră nouă cu o sămânță aleatoare (echivalentul lui `Date.now()` din JS).
    public static func new(teamCode: String, year: Int, engine: Engine) -> Career {
        let seed = seedFor("\(teamCode)-\(year)-\(Int(Date().timeIntervalSince1970 * 1000))")
        return Career(teamCode: teamCode, year: year, seed: seed, engine: engine)
    }

    // MARK: Meciul curent

    /// `currentOpponentInfo()` — poate trage la sorți un adversar (o singură dată pe rundă).
    public mutating func currentOpponent(engine: Engine) -> OpponentInfo {
        if stage == .group {
            let g = groupOpponents[groupMatchIndex]
            let real = g.isReal ? engine.realGroupMatch(teamCode, year, groupMatchIndex) : nil
            return OpponentInfo(code: g.code, isReal: g.isReal,
                                real: real.map { RealScore(scoreFor: $0.scoreFor, scoreAgainst: $0.scoreAgainst) },
                                roundLabel: "Grupă — meci \(groupMatchIndex + 1)/3", note: real?.note)
        }
        if let plan = knockoutPlan[knockoutIndex], !usedOpponents.contains(plan.opp) {
            return OpponentInfo(code: plan.opp, isReal: true, real: plan.real, roundLabel: stage.label, note: plan.note)
        }
        if pendingDrawn == nil || pendingDrawn?.stage != stage {
            let opp = engine.drawOpponent(&rng, excluding: usedOpponents)
            pendingDrawn = DrawnOpponent(stage: stage, code: opp)
        }
        return OpponentInfo(code: pendingDrawn!.code, isReal: false, real: nil, roundLabel: stage.label, note: nil)
    }

    /// Lotul adversarului — determinist, ca în `renderMatchPreview()`.
    public func opponentSquad(_ code: String, engine: Engine) -> [Player] {
        var r = Mulberry32(seed: seedFor("\(code)-\(year)-opp"))
        return engine.generateSquad(code, year, &r)
    }

    public var yourRatings: TacticalRatings {
        Engine.tacticalRatings(squad, mentality, formation)
    }

    /// Ecranul de preview (`renderMatchPreview`).
    public mutating func preview(engine: Engine) -> MatchPreview {
        let opp = currentOpponent(engine: engine)
        let oppSquad = opponentSquad(opp.code, engine: engine)
        return MatchPreview(opponent: opp, yourRatings: yourRatings,
                            opponentRatings: Engine.tacticalRatings(oppSquad, .echilibrat, .f442),
                            opponentSquad: oppSquad)
    }

    /// `playCurrentMatch()` + `afterMatch()`: simulează meciul curent și avansează cariera.
    @discardableResult
    public mutating func playCurrentMatch(engine: Engine) -> MatchRecord {
        precondition(!isFinished, "Cariera s-a încheiat deja")
        let p = preview(engine: engine)
        let opp = p.opponent
        let your = p.yourRatings
        let sim = Engine.simulateMatch(teamAName: engine.data.meta(teamCode).name, teamAAttack: your.attack, teamADefense: your.defense,
                                       teamBName: engine.data.meta(opp.code).name, teamBAttack: p.opponentRatings.attack,
                                       teamBDefense: p.opponentRatings.defense, rng: &rng, homeTeam: nil)
        let events = Engine.assignScorers(sim.events, squad, p.opponentSquad, &rng)

        if stage == .group {
            let record = MatchRecord(stage: .group, opp: opp.code, isReal: opp.isReal, goalsFor: sim.scoreA,
                                     goalsAgainst: sim.scoreB, pens: nil, real: opp.real, won: nil, events: events)
            groupResults.append(record)
            groupMatchIndex += 1
            if groupMatchIndex == 3 { finishGroupStage(engine: engine) }
            return record
        }

        var won: Bool
        var pens: String?
        if sim.scoreA == sim.scoreB {
            let pr = Engine.simulatePenalties(your.attack, p.opponentRatings.attack, &rng)
            pens = "\(pr.scoreA)-\(pr.scoreB)"
            won = pr.winner == .A
        } else {
            won = sim.scoreA > sim.scoreB
        }
        let record = MatchRecord(stage: stage, opp: opp.code, isReal: opp.isReal, goalsFor: sim.scoreA,
                                 goalsAgainst: sim.scoreB, pens: pens, real: opp.real, won: won, events: events)
        knockoutResults.append(record)
        usedOpponents.append(opp.code)

        if !won {
            outcome = .eliminatedKnockout
        } else if stage == .F {
            outcome = .champion
        } else {
            stage = stage == .QF ? .SF : .F
            knockoutIndex += 1
        }
        return record
    }

    /// `finishGroupStage()` — simulează celelalte 3 meciuri și calculează clasamentul.
    private mutating func finishGroupStage(engine: Engine) {
        let codes = groupOpponents.map(\.code)
        let (o1, o2, o3) = (codes[0], codes[1], codes[2])
        let year = self.year
        let teamCode = self.teamCode

        func simPair(_ x: String, _ y: String, _ rng: inout Mulberry32) -> OtherGroupResult {
            var rx = Mulberry32(seed: seedFor("\(x)\(year)aux"))
            var ry = Mulberry32(seed: seedFor("\(y)\(year)aux"))
            let sx = engine.generateSquad(x, year, &rx)
            let sy = engine.generateSquad(y, year, &ry)
            let tx = Engine.tacticalRatings(sx, .echilibrat, .f442)
            let ty = Engine.tacticalRatings(sy, .echilibrat, .f442)
            let m = Engine.simulateMatch(teamAName: x, teamAAttack: tx.attack, teamADefense: tx.defense,
                                         teamBName: y, teamBAttack: ty.attack, teamBDefense: ty.defense, rng: &rng)
            return OtherGroupResult(home: x, away: y, goalsHome: m.scoreA, goalsAway: m.scoreB)
        }
        var r = rng
        let m12 = simPair(o1, o2, &r)
        let m13 = simPair(o1, o3, &r)
        let m23 = simPair(o2, o3, &r)
        rng = r
        otherGroupResults = [m12, m13, m23]

        // tabel cu ordinea de inserare a cheilor din JS (duplicatele — ex. TUR de 2 ori la GER 1954 — se contopesc)
        var order: [String] = []
        var table: [String: StandingRow] = [:]
        for code in [teamCode, o1, o2, o3] where table[code] == nil {
            order.append(code)
            table[code] = StandingRow(code: code)
        }
        func apply(_ a: String, _ b: String, _ gfa: Int, _ gfb: Int) {
            table[a]!.pl += 1; table[b]!.pl += 1
            table[a]!.gf += gfa; table[a]!.ga += gfb
            table[b]!.gf += gfb; table[b]!.ga += gfa
            if gfa > gfb { table[a]!.pts += 3 } else if gfa < gfb { table[b]!.pts += 3 } else { table[a]!.pts += 1; table[b]!.pts += 1 }
        }
        for g in groupResults { apply(teamCode, g.opp, g.goalsFor, g.goalsAgainst) }
        for m in otherGroupResults { apply(m.home, m.away, m.goalsHome, m.goalsAway) }

        let rows = order.map { table[$0]! }
        let sorted = rows.enumerated().sorted { a, b in
            let x = a.element, y = b.element
            if x.pts != y.pts { return x.pts > y.pts }
            let gdx = x.gf - x.ga, gdy = y.gf - y.ga
            if gdx != gdy { return gdx > gdy }
            if x.gf != y.gf { return x.gf > y.gf }
            return a.offset < b.offset
        }.map(\.element)
        standings = sorted

        let rank = sorted.firstIndex { $0.code == teamCode } ?? 99
        if rank <= 1 {
            stage = .QF
            knockoutIndex = 0
        } else {
            outcome = .eliminatedGroup
        }
    }

    /// Eticheta pentru Sala Trofeelor (`finishCareer`).
    public var outcomeLabel: String {
        switch outcome {
        case .champion: return "🏆 Campioană Mondială!"
        case .eliminatedGroup: return "Eliminată în grupe"
        case .eliminatedKnockout: return "Eliminată în \(stage.eliminationPlace)"
        case nil: return "În desfășurare"
        }
    }

    /// Plasament în grupă după încheierea ei (0 = primul loc).
    public var groupRank: Int? {
        standings?.firstIndex { $0.code == teamCode }
    }
}

/// O intrare din Sala Trofeelor (persistată local).
public struct TrophyEntry: Codable, Hashable, Identifiable, Sendable {
    public var id: UUID
    public let date: Date
    public let team: String
    public let year: Int
    public let outcome: Outcome
    public let label: String

    public init(id: UUID = UUID(), date: Date = Date(), career: Career) {
        self.id = id
        self.date = date
        team = career.teamCode
        year = career.year
        outcome = career.outcome ?? .eliminatedGroup
        label = career.outcomeLabel
    }
}
