import Foundation

// Port direct al engine.js — aceleași funcții, aceeași ordine a apelurilor
// de PRNG, deci aceleași rezultate pentru aceeași sămânță (verificat de
// testele de paritate cu vectorii din Golden.json).

public enum Mentality: String, Codable, CaseIterable, Identifiable, Sendable {
    case defensiv = "Defensiv"
    case echilibrat = "Echilibrat"
    case ofensiv = "Ofensiv"
    public var id: String { rawValue }

    var mod: (atk: Double, def: Double) {
        switch self {
        case .defensiv: return (-0.06, 0.08)
        case .echilibrat: return (0, 0)
        case .ofensiv: return (0.09, -0.05)
        }
    }
}

public enum Formation: String, Codable, CaseIterable, Identifiable, Sendable {
    case f442 = "4-4-2"
    case f433 = "4-3-3"
    case f352 = "3-5-2"
    case f532 = "5-3-2"
    public var id: String { rawValue }

    var mod: (atk: Double, def: Double) {
        switch self {
        case .f442: return (0, 0)
        case .f433: return (0.05, -0.03)
        case .f352: return (0.02, -0.02)
        case .f532: return (-0.05, 0.06)
        }
    }
}

public struct TacticalRatings: Codable, Hashable, Sendable {
    public let attack: Double
    public let defense: Double
}

public enum Side: String, Codable, Sendable { case A, B }

public struct MatchEvent: Codable, Hashable, Sendable {
    public let minute: Int
    public let team: Side
    public let teamName: String
    public var scorer: String?
}

public struct SimulatedMatch: Codable, Hashable, Sendable {
    public let scoreA: Int
    public let scoreB: Int
    public let events: [MatchEvent]
}

public struct PenaltyResult: Codable, Hashable, Sendable {
    public let scoreA: Int
    public let scoreB: Int
    public let winner: Side
}

public struct Engine: Sendable {
    public let data: GameData

    public init(data: GameData = .shared) {
        self.data = data
    }

    // MARK: Rating

    /// `getTeamRating(code, year)` — curbă interpolată liniar; echipele fără curbă → shadow.
    public func teamRating(_ code: String, _ year: Int) -> Int {
        guard let team = data.teamsByCode[code] else { return shadowRating(code, year) }
        let curve = team.curve
        if let exact = curve.first(where: { $0.year == year }) { return exact.rating }
        guard let first = curve.first, let last = curve.last else { return 60 }
        if year <= first.year { return first.rating }
        if year >= last.year { return last.rating }
        for i in 0..<(curve.count - 1) {
            let y0 = curve[i].year, y1 = curve[i + 1].year
            if year > y0 && year < y1 {
                let r0 = curve[i].rating, r1 = curve[i + 1].rating
                let t = Double(year - y0) / Double(y1 - y0)
                return jsRound(Double(r0) + Double(r1 - r0) * t)
            }
        }
        return 60
    }

    /// `getShadowRating(code, year)` — dedus din diferența de gol reală față de echipele curate.
    public func shadowRating(_ code: String, _ year: Int) -> Int {
        var totalDiff = 0, matches = 0, refRatingSum = 0
        for campaign in data.campaigns {
            for m in campaign.group + campaign.knockout where m.opp == code {
                refRatingSum += teamRating(campaign.team, campaign.year)
                totalDiff += m.scoreAgainst - m.scoreFor
                matches += 1
            }
        }
        if matches == 0 { return 52 }
        let avgDiff = Double(totalDiff) / Double(matches)
        let avgRefRating = Double(refRatingSum) / Double(matches)
        let rating = avgRefRating + avgDiff * 11
        return max(35, min(85, jsRound(rating)))
    }

    /// `getRatingAt(code, year)`.
    public func ratingAt(_ code: String, _ year: Int) -> Int {
        data.teamsByCode[code] != nil ? teamRating(code, year) : shadowRating(code, year)
    }

    /// `eligibleTeams(year)` din app.js — echipele curate selectabile la o ediție.
    public func eligibleTeams(_ year: Int) -> [Team] {
        data.teams.filter { team in
            guard let minYear = team.curve.map(\.year).min() else { return false }
            return minYear <= year + 8
        }
    }

    // MARK: Lot

    static let firstNames = ["Carlos", "Miguel", "João", "Luca", "Marco", "Hans", "Klaus", "Pierre", "Jean", "Andrei", "Ion", "Mateus", "Tomás", "Diego", "Pablo", "Ivan", "Nikola", "Sven", "Erik", "Lars", "Kwame", "Amadou", "Hiroshi", "Kenji", "Sami", "Youssef", "Omar", "Rafael", "Bruno", "Felipe"]
    static let lastNames = ["Silva", "Santos", "Rossi", "Bianchi", "Müller", "Schmidt", "Dubois", "Lefevre", "Popescu", "Ionescu", "García", "Fernández", "Kowalski", "Novak", "Andersson", "Johansson", "Diallo", "Traoré", "Tanaka", "Suzuki", "Yıldız", "Demir", "Costa", "Pereira", "Martins", "Almeida"]

    static func genPlayerName(_ rng: inout Mulberry32) -> String {
        let first = rng.choice(firstNames)!
        let last = rng.choice(lastNames)!
        return "\(first) \(last)"
    }

    public func realRoster(_ teamCode: String, _ year: Int) -> [RosterEntry]? {
        data.rosters[fixtureKey(teamCode, year)]
    }

    /// Sortare descrescătoare după rating, stabilă (ca `Array.prototype.sort` din JS).
    static func sortByOverallDesc(_ squad: [Player]) -> [Player] {
        squad.enumerated()
            .sorted { a, b in
                a.element.overall != b.element.overall ? a.element.overall > b.element.overall : a.offset < b.offset
            }
            .map(\.element)
    }

    /// `generateSquad(teamCode, year, rng)`.
    public func generateSquad(_ teamCode: String, _ year: Int, _ rng: inout Mulberry32) -> [Player] {
        let baseRating = ratingAt(teamCode, year)
        let legendsHere = data.legends.filter { $0.team == teamCode && abs($0.yearTag - year) <= 8 }

        if let roster = realRoster(teamCode, year), !roster.isEmpty {
            var squad: [Player] = []
            for p in roster {
                let legend = legendsHere.first { $0.name == p.name }
                let variance = rng.int(-9, 9)
                var player = Player(name: p.name, pos: p.pos,
                                    overall: max(35, min(96, baseRating + variance)),
                                    isLegend: false, bio: nil)
                if let legend {
                    player.overall = max(35, min(99, baseRating + legend.boost))
                    player.isLegend = true
                    player.bio = legend.bio
                }
                squad.append(player)
            }
            return Self.sortByOverallDesc(squad)
        }

        // fallback: nume generate (fără lot real pentru această combinație echipă+an)
        let positions: [Position] = [.GK, .GK, .DF, .DF, .DF, .DF, .DF, .DF, .MF, .MF, .MF, .MF, .MF, .MF, .FW, .FW, .FW, .FW]
        var squad: [Player] = positions.map { pos in
            let variance = rng.int(-9, 9)
            let overall = max(35, min(96, baseRating + variance))
            return Player(name: Self.genPlayerName(&rng), pos: pos, overall: overall, isLegend: false, bio: nil)
        }
        for legend in legendsHere.prefix(3) {
            let legendPos: Position
            if legend.code == "GK" {
                legendPos = .GK
            } else if ["MULLERG", "RONALDOBR", "STABILE", "FONTAINE", "EUSEBIO", "CR7", "PUSKAS"].contains(legend.code) {
                legendPos = .FW
            } else if ["BECKENBAUER", "DISTEFANO"].contains(legend.code) {
                legendPos = .DF
            } else {
                legendPos = .MF
            }
            var candidates = squad.indices.filter { squad[$0].pos == legendPos && !squad[$0].isLegend }
            if candidates.isEmpty { candidates = squad.indices.filter { !squad[$0].isLegend } }
            // primul jucător cu rating minim (sortare stabilă crescătoare → primul element)
            guard var target = candidates.first else { continue }
            for i in candidates where squad[i].overall < squad[target].overall { target = i }
            squad[target].name = legend.name
            squad[target].overall = max(35, min(99, baseRating + legend.boost))
            squad[target].isLegend = true
            squad[target].bio = legend.bio
        }
        return Self.sortByOverallDesc(squad)
    }

    // MARK: Tactici

    public static func squadStrength(_ squad: [Player]) -> Double {
        let sum = squad.prefix(11).reduce(0) { $0 + $1.overall }
        return Double(sum) / 11
    }

    public static func tacticalRatings(_ squad: [Player], _ mentality: Mentality, _ formation: Formation) -> TacticalRatings {
        let base = squadStrength(squad)
        let m = mentality.mod, f = formation.mod
        return TacticalRatings(attack: base * (1 + m.atk + f.atk), defense: base * (1 + m.def + f.def))
    }

    // MARK: Simulare

    public static func poissonSample(_ rng: inout Mulberry32, _ lambda: Double) -> Int {
        let L = exp(-lambda)
        var k = 0
        var p = 1.0
        repeat {
            k += 1
            p *= rng.next()
        } while p > L && k < 12
        return k - 1
    }

    /// `simulateMatch(...)` — scor tip Poisson + minutele golurilor.
    public static func simulateMatch(teamAName: String, teamAAttack: Double, teamADefense: Double,
                                     teamBName: String, teamBAttack: Double, teamBDefense: Double,
                                     rng: inout Mulberry32, homeTeam: Side? = nil) -> SimulatedMatch {
        let homeBonus = 1.5
        let lambdaA = max(0.2, (teamAAttack - teamBDefense) / 12 + 1.35 + (homeTeam == .A ? homeBonus / 12 : 0))
        let lambdaB = max(0.2, (teamBAttack - teamADefense) / 12 + 1.35 + (homeTeam == .B ? homeBonus / 12 : 0))
        let goalsA = poissonSample(&rng, lambdaA)
        let goalsB = poissonSample(&rng, lambdaB)
        var minutesA: [Int] = []
        var minutesB: [Int] = []
        while minutesA.count < goalsA {
            let m = rng.int(1, 90)
            if !minutesA.contains(m) { minutesA.append(m) }
        }
        while minutesB.count < goalsB {
            let m = rng.int(1, 90)
            if !minutesB.contains(m) { minutesB.append(m) }
        }
        let events = minutesA.map { MatchEvent(minute: $0, team: .A, teamName: teamAName, scorer: nil) }
            + minutesB.map { MatchEvent(minute: $0, team: .B, teamName: teamBName, scorer: nil) }
        let sorted = events.enumerated()
            .sorted { $0.element.minute != $1.element.minute ? $0.element.minute < $1.element.minute : $0.offset < $1.offset }
            .map(\.element)
        return SimulatedMatch(scoreA: goalsA, scoreB: goalsB, events: sorted)
    }

    /// `assignScorers(events, squadA, squadB, rng)` — atacanții au pondere mai mare.
    public static func assignScorers(_ events: [MatchEvent], _ squadA: [Player], _ squadB: [Player],
                                     _ rng: inout Mulberry32) -> [MatchEvent] {
        let attackersA = squadA.prefix(11).filter { $0.pos != .GK }
        let attackersB = squadB.prefix(11).filter { $0.pos != .GK }
        return events.map { e in
            let pool = e.team == .A ? attackersA : attackersB
            let weighted = pool.flatMap { p in Array(repeating: p, count: p.pos == .FW ? 4 : p.pos == .MF ? 2 : 1) }
            let scorer = rng.choice(weighted.isEmpty ? pool : weighted)
            var out = e
            out.scorer = scorer?.name ?? "?"
            return out
        }
    }

    /// `simulatePenalties(ratingA, ratingB, rng)` — 5 runde + moarte subită.
    public static func simulatePenalties(_ ratingA: Double, _ ratingB: Double, _ rng: inout Mulberry32) -> PenaltyResult {
        let skew = max(-0.12, min(0.12, (ratingA - ratingB) / 250))
        let pA = 0.76 + skew, pB = 0.76 - skew
        var scoreA = 0, scoreB = 0
        for _ in 1...5 {
            if rng.next() < pA { scoreA += 1 }
            if rng.next() < pB { scoreB += 1 }
        }
        var sudden = 0
        while scoreA == scoreB && sudden < 10 {
            if rng.next() < pA { scoreA += 1 }
            if rng.next() < pB { scoreB += 1 }
            sudden += 1
        }
        if scoreA == scoreB { scoreA += 1 }
        return PenaltyResult(scoreA: scoreA, scoreB: scoreB, winner: scoreA > scoreB ? .A : .B)
    }

    // MARK: Adversari reali

    public func realGroupOpponents(_ teamCode: String, _ year: Int) -> [String] {
        data.campaign(teamCode, year)?.group.map(\.opp) ?? []
    }

    public func realGroupMatch(_ teamCode: String, _ year: Int, _ index: Int) -> FixtureMatch? {
        guard let g = data.campaign(teamCode, year)?.group, index < g.count else { return nil }
        return g[index]
    }

    public func realKnockoutMatch(_ teamCode: String, _ year: Int, _ roundIndex: Int) -> FixtureMatch? {
        guard let k = data.campaign(teamCode, year)?.knockout, roundIndex < k.count else { return nil }
        return k[roundIndex]
    }

    /// `drawOpponent(rng, year, excludeCodes, preferCurated)` — „fără retur”.
    public func drawOpponent(_ rng: inout Mulberry32, excluding exclude: [String], preferCurated: Bool = false) -> String {
        let all = data.teams.map(\.code)
        let pool = all.filter { !exclude.contains($0) }
        let source = (preferCurated || pool.isEmpty) ? all : pool
        let usable = source.filter { !exclude.contains($0) }
        return rng.choice(usable.isEmpty ? all : usable)!
    }
}
