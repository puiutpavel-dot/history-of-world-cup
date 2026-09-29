import Foundation

// Motorul de carieră pe FORMATUL REAL al fiecărei ediții — port 1:1 al
// career.js (grupe de 2-4 meciuri, baraj, cele mai bune locuri 3, a doua fază
// a grupelor, grupa finală 1950, șaisprezecimi → finală, finala mică,
// prelungiri, meci rejucat / tragere la sorți / penalty-uri, cartonașe și
// suspendări). Aceeași ordine a apelurilor de PRNG ⇒ aceleași rezultate ca
// versiunea web pentru aceeași sămânță (verificat de ParityTests).

public let roundLabels: [String: String] = [
    "R32": "Șaisprezecimi", "R16": "Optimi", "QF": "Sferturi", "SF": "Semifinală", "F": "Finală", "3P": "Finala mică",
]
public let stageLabels: [String: String] = [
    "group": "Faza grupelor", "group2": "A doua fază a grupelor", "finalGroup": "Grupa finală",
]

public enum Outcome: String, Codable, Sendable {
    case champion, runnerUp, third, fourth, out
}

public struct RealScore: Codable, Hashable, Sendable {
    public let scoreFor: Int
    public let scoreAgainst: Int
}

/// Meciul următor al jucătorului.
public struct MatchInfo: Codable, Hashable, Sendable {
    /// "group" | "group2" | "finalGroup" | "ko" | "playoff" | "3P"
    public let kind: String
    public let round: String?
    public var label: String
    public let opp: String
    public let isReal: Bool
    public let real: RealScore?
    public let note: String?
    public let knockout: Bool
    public var replay: Bool = false
}

public struct CardEvent: Codable, Hashable, Sendable {
    public let minute: Int
    public let team: Side
    /// "Y" | "R" | "Y2R"
    public let type: String
    public let player: String
    /// indexul în lotul jucătorului (-1 pentru adversar)
    public let idx: Int
}

public struct MatchRecord: Codable, Hashable, Sendable {
    public let kind: String
    public let round: String?
    public let label: String
    public let opp: String
    public let isReal: Bool
    public let real: RealScore?
    public let note: String?
    public let gf: Int
    public let ga: Int
    public let extraTime: Bool
    public let pens: String?
    /// câștigătorul tragerii la sorți
    public let lots: Side?
    public let replay: Bool
    /// egal după prelungiri → meci rejucat
    public let tied: Bool
    public let won: Bool?
    public let events: [MatchEvent]
    public let cards: [CardEvent]
    /// jucătorii care au lipsit (suspendați)
    public let suspended: [String]

    public var scoreText: String {
        var s = "\(gf)-\(ga)"
        if extraTime { s += " d.p." }
        if let pens { s += " (pen. \(pens))" }
        if let lots { s += lots == .A ? " (sorți: câștigat)" : " (sorți: pierdut)" }
        if tied { s += " → rejucat" }
        return s
    }

    /// „Confirmă sau rescrie istoria”: nil dacă meciul nu are corespondent real.
    public var historyRepeated: Bool? {
        guard isReal, let real else { return nil }
        return real.scoreFor == gf && real.scoreAgainst == ga
    }
}

public struct TableRow: Codable, Hashable, Sendable {
    public let code: String
    public var pl = 0
    public var w = 0
    public var d = 0
    public var l = 0
    public var gf = 0
    public var ga = 0
    public var pts = 0
}

public struct OtherResult: Codable, Hashable, Sendable {
    public let home: String
    public let away: String
    public let gh: Int
    public let ga: Int
    public let winner: String?
}

public struct Playoff: Codable, Hashable, Sendable {
    public var pending: Bool
    public var opp: String?
    public var won: Bool?
    public var result: OtherResult?
}

public struct ThirdsRow: Codable, Hashable, Sendable {
    public let code: String
    public let pts: Int
    public let gf: Int
    public let ga: Int
    public let mine: Bool
}

public struct ThirdsRanking: Codable, Hashable, Sendable {
    public let rank: Int
    public let rows: [ThirdsRow]
}

public struct StageTable: Codable, Hashable, Sendable {
    public let stageIdx: Int
    public let type: String
    public let rows: [TableRow]
    public let others: [OtherResult]
    public let playoff: Playoff?
    public let rank: Int
    public let qualified: Bool
    public let thirds: ThirdsRanking?
}

struct GroupResult: Codable, Hashable, Sendable {
    let opp: String
    let gf: Int
    let ga: Int
}

struct GroupState: Codable, Hashable, Sendable {
    let type: String
    let members: [String]
    let playerOpps: [String]
    var results: [GroupResult] = []
    var others: [OtherResult] = []
    var table: [TableRow]?
    var playoff: Playoff?
}

public struct Career: Codable, Sendable {
    public let teamCode: String
    public let year: Int
    public private(set) var rng: Mulberry32
    public private(set) var squad: [Player] = []
    public var mentality: Mentality = .echilibrat
    public var formation: Formation = .f442

    public private(set) var stageIdx = 0
    public private(set) var queue: [MatchInfo] = []
    var group: GroupState?
    public private(set) var records: [MatchRecord] = []
    public private(set) var tables: [StageTable] = []
    /// rundele sărite (1938: Suedia în optimi)
    public private(set) var byes: [String] = []
    public private(set) var used: [String] = []
    public private(set) var suspended: [Int: Int] = [:]
    public private(set) var yellows: [Int: Int] = [:]
    public private(set) var outcome: Outcome?
    public private(set) var outStage: String?

    public var isFinished: Bool { outcome != nil }
    public var nextMatch: MatchInfo? { outcome == nil ? queue.first : nil }
    /// membrii grupei curente (dacă suntem într-o fază de grupe)
    public var groupMembers: [String]? { group?.members }

    // MARK: Pornire

    /// `createCareer(teamCode, year, seed)`.
    public init(teamCode: String, year: Int, seed: UInt32, engine: Engine) {
        self.teamCode = teamCode
        self.year = year
        rng = Mulberry32(seed: seed)
        var r = rng
        squad = engine.generateSquad(teamCode, year, &r)
        rng = r
        enterStage(0, engine: engine)
    }

    /// Carieră nouă cu sămânță aleatoare (echivalentul lui `Date.now()` din JS).
    public static func new(teamCode: String, year: Int, engine: Engine) -> Career {
        let seed = seedFor("\(teamCode)-\(year)-\(Int(Date().timeIntervalSince1970 * 1000))")
        return Career(teamCode: teamCode, year: year, seed: seed, engine: engine)
    }

    // MARK: Utilitare

    func format(_ engine: Engine) -> TournamentFormat { engine.data.formats[year]! }

    /// Jucătorii disponibili (fără suspendați), cu indexul din lot; primii 11 joacă.
    public var availablePlayers: [(idx: Int, player: Player)] {
        squad.enumerated().filter { (suspended[$0.offset] ?? 0) <= 0 }.map { (idx: $0.offset, player: $0.element) }
    }

    public var yourRatings: TacticalRatings {
        Engine.tacticalRatings(availablePlayers.map { $0.player }, mentality, formation)
    }

    public static func opponentSquad(_ code: String, _ year: Int, engine: Engine) -> [Player] {
        var r = Mulberry32(seed: seedFor("\(code)-\(year)-opp"))
        return engine.generateSquad(code, year, &r)
    }

    static func auxSquad(_ code: String, _ year: Int, engine: Engine) -> [Player] {
        var r = Mulberry32(seed: seedFor("\(code)\(year)aux"))
        return engine.generateSquad(code, year, &r)
    }

    static func drawFrom(_ rng: inout Mulberry32, _ pool: [String], excluding exclude: [String]) -> String {
        let usable = pool.filter { !exclude.contains($0) }
        return rng.choice(usable.isEmpty ? pool : usable)!
    }

    func realOfRound(_ round: String, engine: Engine) -> FixtureMatch? {
        engine.data.campaign(teamCode, year)?.knockout.first { $0.round == round }
    }

    static func info(_ opp: String, _ real: FixtureMatch?, kind: String, round: String?, knockout: Bool, label: String) -> MatchInfo {
        MatchInfo(kind: kind, round: round, label: label, opp: opp, isReal: real != nil,
                  real: real.map { RealScore(scoreFor: $0.scoreFor, scoreAgainst: $0.scoreAgainst) },
                  note: real?.note, knockout: knockout)
    }

    // MARK: Etape

    /// `enterStage(state, stageIdx)` — stabilește adversarii etapei (trageri la sorți incluse).
    mutating func enterStage(_ idx: Int, engine: Engine) {
        let fmt = format(engine)
        stageIdx = idx
        queue = []
        group = nil
        if idx >= fmt.stages.count { return }
        let st = fmt.stages[idx]
        let pool = engine.data.editionPool(year)
        let real = engine.data.campaign(teamCode, year)

        if st.type == "group" || st.type == "group2" || st.type == "finalGroup" {
            var list: [FixtureMatch] = []
            if let real {
                if st.type == "group" {
                    list = real.group
                } else {
                    let r = st.type == "group2" ? "GR2" : "FR"
                    list = real.knockout.filter { $0.round == r }
                }
            }
            var distinct: [FixtureMatch] = []
            for m in list where !distinct.contains(where: { $0.opp == m.opp }) { distinct.append(m) }
            let size = (st.sizeFromReal ?? false) && !distinct.isEmpty ? distinct.count + 1 : (st.size ?? 4)
            var members = [teamCode]
            var realOf: [String: FixtureMatch] = [:]
            for m in distinct {
                if members.count >= size { break }
                if !members.contains(m.opp) {
                    members.append(m.opp)
                    realOf[m.opp] = m
                }
            }
            let exclude = st.type == "group" ? [] : used
            while members.count < size {
                members.append(Self.drawFrom(&rng, pool, excluding: members + exclude))
            }
            let opps = (st.seededOnly ?? false) ? Array(members[1..<3]) : Array(members.dropFirst())
            let label = stageLabels[st.type] ?? st.type
            group = GroupState(type: st.type, members: members, playerOpps: opps)
            for (i, code) in opps.enumerated() {
                queue.append(Self.info(code, realOf[code], kind: st.type, round: nil, knockout: false,
                                       label: "\(label) — meci \(i + 1)/\(opps.count)"))
            }
            for c in members where c != teamCode && !used.contains(c) { used.append(c) }
            return
        }

        // ko
        let round = st.round ?? "F"
        if let byes = fmt.byes?[round], byes.contains(teamCode) {
            self.byes.append(round)
            enterStage(idx + 1, engine: engine)
            return
        }
        let r = realOfRound(round, engine: engine)
        let opp = r?.opp ?? Self.drawFrom(&rng, pool, excluding: used + [teamCode])
        if !used.contains(opp) { used.append(opp) }
        queue.append(Self.info(opp, r, kind: "ko", round: round, knockout: true, label: roundLabels[round] ?? round))
    }

    mutating func enterThirdPlace(engine: Engine) {
        let r = realOfRound("3P", engine: engine)
        let opp = r?.opp ?? Self.drawFrom(&rng, engine.data.editionPool(year), excluding: used + [teamCode])
        if !used.contains(opp) { used.append(opp) }
        queue = [Self.info(opp, r, kind: "3P", round: "3P", knockout: true, label: roundLabels["3P"]!)]
        group = nil
    }

    // MARK: Meciul jucătorului

    mutating func simulateFixture(_ info: MatchInfo, engine: Engine) -> MatchRecord {
        let fmt = format(engine)
        let avail = availablePlayers
        let availPlayers = avail.map { $0.player }
        let eleven = Array(avail.prefix(11))
        let oppSquad = Self.opponentSquad(info.opp, year, engine: engine)
        let you = Engine.tacticalRatings(availPlayers, mentality, formation)
        let them = Engine.tacticalRatings(oppSquad, .echilibrat, .f442)
        let nameA = engine.data.meta(teamCode).name, nameB = engine.data.meta(info.opp).name

        var r = rng
        let sim = Engine.simulateMatch(teamAName: nameA, teamAAttack: you.attack, teamADefense: you.defense,
                                       teamBName: nameB, teamBAttack: them.attack, teamBDefense: them.defense, rng: &r)
        var events = Engine.assignScorers(sim.events, availPlayers, oppSquad, &r)
        var gf = sim.scoreA, ga = sim.scoreB
        var extraTime = false, tied = false
        var pens: String?
        var lots: Side?
        if info.knockout && gf == ga {
            let et = Engine.simulateExtraTime(teamAName: nameA, teamAAttack: you.attack, teamADefense: you.defense,
                                              teamBName: nameB, teamBAttack: them.attack, teamBDefense: them.defense, rng: &r)
            events += Engine.assignScorers(et.events, availPlayers, oppSquad, &r)
            gf += et.scoreA
            ga += et.scoreB
            extraTime = true
            if gf == ga {
                let mode = info.replay ? "lots" : fmt.koTie
                if mode == "penalties" {
                    let p = Engine.simulatePenalties(you.attack, them.attack, &r)
                    pens = "\(p.scoreA)-\(p.scoreB)"
                } else if mode == "lots" {
                    lots = r.next() < 0.5 ? .A : .B
                } else {
                    tied = true
                }
            }
        }
        var cards: [CardEvent] = []
        if fmt.cards != "none" {
            for c in Engine.simulateCards(count: eleven.count, &r) {
                cards.append(CardEvent(minute: c.minute, team: .A, type: c.type, player: eleven[c.k].player.name, idx: eleven[c.k].idx))
            }
            let oppEleven = Array(oppSquad.prefix(11))
            for c in Engine.simulateCards(count: oppEleven.count, &r) {
                cards.append(CardEvent(minute: c.minute, team: .B, type: c.type, player: oppEleven[c.k].name, idx: -1))
            }
            cards = cards.enumerated()
                .sorted { $0.element.minute != $1.element.minute ? $0.element.minute < $1.element.minute : $0.offset < $1.offset }
                .map(\.element)
        }
        rng = r
        var won: Bool?
        if info.knockout && !tied {
            if gf != ga {
                won = gf > ga
            } else if let pens {
                let parts = pens.split(separator: "-").map { Int($0)! }
                won = parts[0] > parts[1]
            } else {
                won = lots == .A
            }
        }
        let missing = squad.indices.filter { (suspended[$0] ?? 0) > 0 }.map { squad[$0].name }
        return MatchRecord(kind: info.kind, round: info.round, label: info.label, opp: info.opp, isReal: info.isReal,
                           real: info.real, note: info.note, gf: gf, ga: ga, extraTime: extraTime, pens: pens, lots: lots,
                           replay: info.replay, tied: tied, won: won, events: events, cards: cards, suspended: missing)
    }

    /// Suspendări: cei suspendați la acest meci și-au ispășit pedeapsa; se adaugă cele noi.
    mutating func applyDiscipline(_ rec: MatchRecord, engine: Engine) {
        for k in suspended.keys where suspended[k]! > 0 { suspended[k]! -= 1 }
        if format(engine).cards == "none" { return }
        let off = Set(rec.cards.filter { $0.team == .A && $0.type != "Y" }.map(\.idx))
        for c in rec.cards where c.team == .A {
            if c.type == "Y" {
                if off.contains(c.idx) { continue }
                yellows[c.idx, default: 0] += 1
                if yellows[c.idx]! >= 2 {
                    suspended[c.idx] = 1
                    yellows[c.idx] = 0
                }
            } else {
                suspended[c.idx] = 1
            }
        }
    }

    // MARK: Clasamente

    static func applyResult(_ table: inout [TableRow], _ a: String, _ b: String, _ ga: Int, _ gb: Int, win: Int) {
        let ia = table.firstIndex { $0.code == a }!, ib = table.firstIndex { $0.code == b }!
        table[ia].pl += 1; table[ib].pl += 1
        table[ia].gf += ga; table[ia].ga += gb
        table[ib].gf += gb; table[ib].ga += ga
        if ga > gb {
            table[ia].w += 1; table[ib].l += 1; table[ia].pts += win
        } else if ga < gb {
            table[ib].w += 1; table[ia].l += 1; table[ib].pts += win
        } else {
            table[ia].d += 1; table[ib].d += 1; table[ia].pts += 1; table[ib].pts += 1
        }
    }

    static func goalAverage(_ r: TableRow) -> Double {
        r.ga == 0 ? (r.gf > 0 ? 1e9 + Double(r.gf) : 0) : Double(r.gf) / Double(r.ga)
    }

    /// `sortTable(table, tiebreak)` — puncte, apoi media golurilor ("ga") sau golaveraj și goluri marcate.
    static func sortTable(_ table: [TableRow], _ tiebreak: String) -> [TableRow] {
        table.enumerated().sorted { x, y in
            let a = x.element, b = y.element
            if a.pts != b.pts { return a.pts > b.pts }
            if tiebreak == "ga" {
                let ga = goalAverage(a), gb = goalAverage(b)
                if ga != gb { return ga > gb }
            } else {
                let da = a.gf - a.ga, db = b.gf - b.ga
                if da != db { return da > db }
                if a.gf != b.gf { return a.gf > b.gf }
            }
            return x.offset < y.offset
        }.map(\.element)
    }

    mutating func simOther(_ a: String, _ b: String, knockout: Bool, engine: Engine) -> OtherResult {
        let sa = Self.auxSquad(a, year, engine: engine), sb = Self.auxSquad(b, year, engine: engine)
        let ra = Engine.tacticalRatings(sa, .echilibrat, .f442), rb = Engine.tacticalRatings(sb, .echilibrat, .f442)
        var r = rng
        let m = Engine.simulateMatch(teamAName: a, teamAAttack: ra.attack, teamADefense: ra.defense,
                                     teamBName: b, teamBAttack: rb.attack, teamBDefense: rb.defense, rng: &r)
        var ga = m.scoreA, gb = m.scoreB
        var winner: String?
        if knockout {
            if ga == gb {
                let et = Engine.simulateExtraTime(teamAName: a, teamAAttack: ra.attack, teamADefense: ra.defense,
                                                  teamBName: b, teamBAttack: rb.attack, teamBDefense: rb.defense, rng: &r)
                ga += et.scoreA
                gb += et.scoreB
            }
            winner = ga > gb ? a : ga < gb ? b : (r.next() < 0.5 ? a : b)
        }
        rng = r
        return OtherResult(home: a, away: b, gh: ga, ga: gb, winner: winner)
    }

    mutating func finishGroup(engine: Engine) {
        let fmt = format(engine)
        let st = fmt.stages[stageIdx]
        guard var g = group else { return }
        let m = g.members
        var pairs: [(String, String)] = []
        if st.seededOnly ?? false {
            pairs = [(m[1], m[3]), (m[2], m[3])]
        } else {
            for i in 1..<m.count { for j in (i + 1)..<max(i + 1, m.count) { pairs.append((m[i], m[j])) } }
        }
        for (a, b) in pairs { g.others.append(simOther(a, b, knockout: false, engine: engine)) }

        var table = m.map { TableRow(code: $0) }
        for r in g.results { Self.applyResult(&table, teamCode, r.opp, r.gf, r.ga, win: fmt.win) }
        for o in g.others { Self.applyResult(&table, o.home, o.away, o.gh, o.ga, win: fmt.win) }
        var sorted = Self.sortTable(table, st.type == "group" ? fmt.tiebreak : "gd")
        g.table = sorted

        let advance = st.type == "group" ? (st.advance ?? 2) : 1
        if st.type == "group" && fmt.tiebreak == "playoff" && advance < sorted.count
            && sorted[advance - 1].pts == sorted[advance].pts && g.playoff == nil {
            let a = sorted[advance - 1].code, b = sorted[advance].code
            if a == teamCode || b == teamCode {
                let opp = a == teamCode ? b : a
                let real = (engine.data.campaign(teamCode, year)?.group ?? []).filter { $0.opp == opp }
                let r = real.count > 1 ? real.last : nil
                g.playoff = Playoff(pending: true, opp: opp, won: nil, result: nil)
                group = g
                queue.append(Self.info(opp, r, kind: "playoff", round: nil, knockout: true, label: "Baraj de grupă"))
                return
            }
            let o = simOther(a, b, knockout: true, engine: engine)
            g.playoff = Playoff(pending: false, opp: nil, won: nil, result: o)
            if o.winner == b { sorted.swapAt(advance - 1, advance) }
            g.table = sorted
        }
        group = g
        concludeGroup(engine: engine)
    }

    mutating func concludeGroup(engine: Engine) {
        let fmt = format(engine)
        let st = fmt.stages[stageIdx]
        guard let g = group, let sorted = g.table else { return }
        let rank = sorted.firstIndex { $0.code == teamCode } ?? 99

        if st.type == "finalGroup" {
            tables.append(StageTable(stageIdx: stageIdx, type: st.type, rows: sorted, others: g.others, playoff: g.playoff,
                                     rank: rank, qualified: rank == 0, thirds: nil))
            let places: [Outcome] = [.champion, .runnerUp, .third, .fourth]
            outcome = rank < places.count ? places[rank] : .out
            outStage = stageLabels["finalGroup"]
            return
        }
        let advance = st.type == "group" ? (st.advance ?? 2) : 1
        var qualified = false
        var thirds: ThirdsRanking?
        if rank < advance {
            qualified = true
        } else if st.type == "group", let best = st.bestThirds, best > 0, rank == advance {
            let t = rankThirds(st, sorted[rank], engine: engine)
            thirds = t
            qualified = t.rank < best
        }
        let toThird = st.type == "group2" && rank == 1 && st.secondTo == "3P"
        tables.append(StageTable(stageIdx: stageIdx, type: st.type, rows: sorted, others: g.others, playoff: g.playoff,
                                 rank: rank, qualified: qualified || toThird, thirds: thirds))
        if st.type == "group" && fmt.cards == "reset" { yellows = [:] }
        if qualified {
            enterStage(stageIdx + 1, engine: engine)
        } else if toThird {
            enterThirdPlace(engine: engine)
        } else {
            outcome = .out
            outStage = stageLabels[st.type]
            queue = []
        }
    }

    /// Cele mai bune locuri 3: celelalte grupe sunt simulate cu echipe trase la sorți din echipele ediției.
    mutating func rankThirds(_ st: StageSpec, _ myRow: TableRow, engine: Engine) -> ThirdsRanking {
        let fmt = format(engine)
        let pool = engine.data.editionPool(year)
        let groupMembers = group?.members ?? []
        let size = st.size ?? 4, adv = st.advance ?? 2
        var rows: [(row: TableRow, mine: Bool)] = [(myRow, true)]
        var r = rng
        for _ in 1..<(st.groups ?? 1) {
            var members: [String] = []
            while members.count < size { members.append(Self.drawFrom(&r, pool, excluding: members + groupMembers)) }
            var table = members.map { TableRow(code: $0) }
            for i in 0..<members.count {
                for j in (i + 1)..<max(i + 1, members.count) {
                    let ra = Double(engine.ratingAt(members[i], year)), rb = Double(engine.ratingAt(members[j], year))
                    let m = Engine.simulateMatch(teamAName: members[i], teamAAttack: ra, teamADefense: ra,
                                                 teamBName: members[j], teamBAttack: rb, teamBDefense: rb, rng: &r)
                    Self.applyResult(&table, members[i], members[j], m.scoreA, m.scoreB, win: fmt.win)
                }
            }
            rows.append((Self.sortTable(table, fmt.tiebreak)[adv], false))
        }
        rng = r
        // aceeași ordine ca sortTable(rows, "gd") din JS: puncte, golaveraj, goluri marcate, ordinea inițială
        let ranked = rows.enumerated().sorted { x, y in
            let a = x.element.row, b = y.element.row
            if a.pts != b.pts { return a.pts > b.pts }
            let da = a.gf - a.ga, db = b.gf - b.ga
            if da != db { return da > db }
            if a.gf != b.gf { return a.gf > b.gf }
            return x.offset < y.offset
        }.map(\.element)
        return ThirdsRanking(rank: ranked.firstIndex { $0.mine } ?? 99,
                             rows: ranked.map { ThirdsRow(code: $0.row.code, pts: $0.row.pts, gf: $0.row.gf, ga: $0.row.ga, mine: $0.mine) })
    }

    // MARK: Joacă meciul următor

    /// `playNext(state, mentality, formation)` — simulează meciul următor și avansează cariera.
    @discardableResult
    public mutating func playNext(engine: Engine) -> MatchRecord? {
        guard outcome == nil, !queue.isEmpty else { return nil }
        let info = queue.removeFirst()
        let rec = simulateFixture(info, engine: engine)
        applyDiscipline(rec, engine: engine)
        records.append(rec)
        let fmt = format(engine)

        if info.kind == "group" || info.kind == "group2" || info.kind == "finalGroup" {
            group?.results.append(GroupResult(opp: info.opp, gf: rec.gf, ga: rec.ga))
            if queue.isEmpty { finishGroup(engine: engine) }
            return rec
        }
        if rec.tied {
            var again = info
            again.replay = true
            again.label = "\(info.label) (rejucat)"
            queue.insert(again, at: 0)
            return rec
        }
        if info.kind == "playoff" {
            guard var g = group, var sorted = g.table else { return rec }
            let adv = fmt.stages[stageIdx].advance ?? 2
            g.playoff = Playoff(pending: false, opp: info.opp, won: rec.won, result: nil)
            let mine = sorted.firstIndex { $0.code == teamCode }!
            let other = sorted.firstIndex { $0.code == info.opp }!
            let w = sorted[rec.won == true ? mine : other], l = sorted[rec.won == true ? other : mine]
            sorted[adv - 1] = w
            sorted[adv] = l
            g.table = sorted
            group = g
            concludeGroup(engine: engine)
            return rec
        }
        if info.kind == "3P" {
            outcome = rec.won == true ? .third : .fourth
            outStage = roundLabels["3P"]
            return rec
        }
        // ko
        if rec.won == true {
            if info.round == "F" {
                outcome = .champion
                outStage = roundLabels["F"]
            } else {
                enterStage(stageIdx + 1, engine: engine)
            }
        } else if info.round == "F" {
            outcome = .runnerUp
            outStage = roundLabels["F"]
        } else if info.round == "SF" && fmt.third {
            enterThirdPlace(engine: engine)
        } else {
            outcome = .out
            outStage = roundLabels[info.round ?? ""] ?? info.round
        }
        return rec
    }

    /// `outcomeLabel(state)`.
    public var outcomeLabel: String {
        switch outcome {
        case .champion: return "🏆 Campioană mondială"
        case .runnerUp: return "🥈 Vicecampioană"
        case .third: return "🥉 Locul 3"
        case .fourth: return "Locul 4"
        case .out: return "Eliminată — \(outStage ?? "")"
        case nil: return "În desfășurare"
        }
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
        outcome = career.outcome ?? .out
        label = career.outcomeLabel
    }
}
