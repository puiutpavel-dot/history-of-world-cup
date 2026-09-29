import Foundation

// Motorul de carieră pe FORMATUL REAL al fiecărei ediții — port 1:1 al
// career.js (grupe de 2-4 meciuri, baraj, cele mai bune locuri 3, a doua fază
// a grupelor, grupa finală 1950, șaisprezecimi → finală, finala mică,
// prelungiri, meci rejucat / tragere la sorți / penalty-uri, cartonașe și
// suspendări). Aceeași ordine a apelurilor de PRNG ⇒ aceleași rezultate ca
// versiunea web pentru aceeași sămânță (verificat de ParityTests).

public var roundLabels: [String: String] {
    AppLanguage.isRomanian
        ? ["R32": "Șaisprezecimi", "R16": "Optimi", "QF": "Sferturi", "SF": "Semifinală", "F": "Finală", "3P": "Finala mică"]
        : ["R32": "Round of 32", "R16": "Round of 16", "QF": "Quarter-final", "SF": "Semi-final", "F": "Final", "3P": "Third-place match"]
}
public var stageLabels: [String: String] {
    AppLanguage.isRomanian
        ? ["group": "Faza grupelor", "group2": "A doua fază a grupelor", "finalGroup": "Grupa finală"]
        : ["group": "Group stage", "group2": "Second group stage", "finalGroup": "Final group"]
}

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

/// O schimbare (tactică sau după accidentare) sau o accidentare fără înlocuitor (inn == nil → echipa în 10).
public struct SubEvent: Codable, Hashable, Sendable {
    public let minute: Int
    public let team: Side
    public let out: String
    public let inn: String?
    public let injury: Bool
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
    /// meciul s-a încheiat prin gol de aur (1998, 2002)
    public let goldenGoal: Bool
    public let subs: [SubEvent]
    /// puncte de fair-play (negative) ale celor două echipe
    public let fpA: Int
    public let fpB: Int

    public var scoreText: String {
        var s = "\(gf)-\(ga)"
        if extraTime { s += goldenGoal ? tr(" (gol de aur)", " (golden goal)") : tr(" d.p.", " a.e.t.") }
        if let pens { s += tr(" (pen. \(pens))", " (\(pens) pens)") }
        if let lots { s += lots == .A ? tr(" (sorți: câștigat)", " (lots: won)") : tr(" (sorți: pierdut)", " (lots: lost)") }
        if tied { s += tr(" → rejucat", " → replay") }
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
    /// puncte de fair-play (galben -1, al doilea galben -3, roșu direct -4)
    public var fp = 0
}

public struct OtherResult: Codable, Hashable, Sendable {
    public let home: String
    public let away: String
    public let gh: Int
    public let ga: Int
    public let winner: String?
    public var fph = 0
    public var fpa = 0
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
    let fpA: Int
    let fpB: Int
}

// MARK: - Regulile de pe teren: accidentări, schimbări, echipa în 10
// Fiecare echipă are 11 „posturi” (sloturi); un slot își schimbă ocupantul la o
// schimbare sau rămâne gol (accidentare fără schimbări permise, eliminare).

let injuryChance = 0.12
let shortPenalty = 0.12
let fairPlayPoints: [String: Int] = ["Y": -1, "Y2R": -3, "R": -4]

struct SlotPlayer: Hashable, Sendable {
    let player: Player
    let idx: Int
}

struct SlotEntry: Hashable, Sendable {
    let from: Int
    let p: SlotPlayer?
}

struct TeamSide {
    let team: Side
    var slots: [[SlotEntry]]
    let bench: [SlotPlayer]
    var used: [Int] = []
    var subsUsed = 0
    var factor = 1.0
    var short = false

    init(team: Side, eleven: [SlotPlayer], bench: [SlotPlayer]) {
        self.team = team
        slots = eleven.map { [SlotEntry(from: 0, p: $0)] }
        self.bench = bench
    }

    static func occupant(_ slot: [SlotEntry], _ minute: Int) -> SlotPlayer? {
        var p = slot[0].p
        for e in slot where e.from <= minute { p = e.p }
        return p
    }

    func freeBench(_ pos: Position?) -> Int {
        if let pos, let i = bench.indices.first(where: { !used.contains($0) && bench[$0].player.pos == pos }) { return i }
        return bench.indices.first { !used.contains($0) } ?? -1
    }

    static func drawInjury(_ count: Int, _ rng: inout Mulberry32) -> (k: Int, minute: Int)? {
        if rng.next() >= injuryChance { return nil }
        let k = Int((rng.next() * Double(count)).rounded(.down))
        let minute = rng.int(1, 89)
        return (k, minute)
    }

    /// `applyInjury(fmt, inj, side, subs)`.
    mutating func applyInjury(_ fmt: TournamentFormat, _ inj: (k: Int, minute: Int)?, _ subs: inout [SubEvent]) {
        guard let inj else { return }
        let p = slots[inj.k][0].p!
        let gkExtra = (fmt.gkSub ?? false) && p.player.pos == .GK
        let bi = (fmt.subs > 0 || gkExtra) && used.count < bench.count ? freeBench(p.player.pos == .GK ? .GK : nil) : -1
        if bi >= 0 {
            let inn = bench[bi]
            used.append(bi)
            if !gkExtra { subsUsed += 1 }
            slots[inj.k].append(SlotEntry(from: inj.minute, p: inn))
            subs.append(SubEvent(minute: inj.minute, team: team, out: p.player.name, inn: inn.player.name, injury: true))
        } else {
            slots[inj.k].append(SlotEntry(from: inj.minute, p: nil))
            factor = 1 - shortPenalty * Double(90 - inj.minute) / 90
            short = true
            subs.append(SubEvent(minute: inj.minute, team: team, out: p.player.name, inn: nil, injury: true))
        }
    }

    /// `tacticalSub(side, minute, subs, rng)`.
    mutating func tacticalSub(_ minute: Int, _ subs: inout [SubEvent], _ rng: inout Mulberry32) -> Bool {
        let bi = freeBench(nil)
        if bi < 0 { return false }
        var cand: [Int] = []
        for (k, slot) in slots.enumerated() where slot.count == 1 && slot[0].p!.player.pos != .GK { cand.append(k) }
        if cand.isEmpty { return false }
        let k = cand[Int((rng.next() * Double(cand.count)).rounded(.down))]
        let inn = bench[bi]
        used.append(bi)
        slots[k].append(SlotEntry(from: minute, p: inn))
        subs.append(SubEvent(minute: minute, team: team, out: slots[k][0].p!.player.name, inn: inn.player.name, injury: false))
        return true
    }

    /// `resolveCards(raw, side, subs, endMinute)` — cartonașele pe sloturi → jucători; eliminarea golește slotul.
    mutating func resolveCards(_ raw: [Engine.RawCard], _ subs: inout [SubEvent], endMinute: Int) -> [CardEvent] {
        var out: [CardEvent] = []
        var booked: [Int: String] = [:]
        for c in raw {
            if c.minute > endMinute { continue }
            guard let p = Self.occupant(slots[c.k], c.minute) else { continue }
            var type = c.type
            if type == "Y2R" && booked[c.k] != p.player.name { type = "Y" }
            if type == "Y" { booked[c.k] = p.player.name }
            out.append(CardEvent(minute: c.minute, team: team, type: type, player: p.player.name, idx: team == .A ? p.idx : -1))
            if type != "Y" {
                var i = slots[c.k].count - 1
                while i >= 1 {
                    if slots[c.k][i].from > c.minute, let sp = slots[c.k][i].p {
                        let name = sp.player.name
                        slots[c.k].remove(at: i)
                        if let si = subs.firstIndex(where: { $0.team == team && $0.inn == name }) { subs.remove(at: si) }
                    }
                    i -= 1
                }
                slots[c.k].append(SlotEntry(from: c.minute, p: nil))
            }
        }
        return out
    }
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
                                       label: "\(label) — \(tr("meci", "match")) \(i + 1)/\(opps.count)"))
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
        let stage: StageSpec? = stageIdx < fmt.stages.count ? fmt.stages[stageIdx] : nil
        let avail = availablePlayers
        let availPlayers = avail.map { $0.player }
        let oppSquad = Self.opponentSquad(info.opp, year, engine: engine)
        let you = Engine.tacticalRatings(availPlayers, mentality, formation)
        let them = Engine.tacticalRatings(oppSquad, .echilibrat, .f442)
        let nameA = engine.data.meta(teamCode).name, nameB = engine.data.meta(info.opp).name
        let mineAll = avail.map { SlotPlayer(player: $0.player, idx: $0.idx) }
        let oppAll = oppSquad.map { SlotPlayer(player: $0, idx: -1) }
        var sideA = TeamSide(team: .A, eleven: Array(mineAll.prefix(11)), bench: Array(mineAll.dropFirst(11)))
        var sideB = TeamSide(team: .B, eleven: Array(oppAll.prefix(11)), bench: Array(oppAll.dropFirst(11)))
        var subs: [SubEvent] = []

        var r = rng
        let injA = TeamSide.drawInjury(sideA.slots.count, &r)
        sideA.applyInjury(fmt, injA, &subs)
        let injB = TeamSide.drawInjury(sideB.slots.count, &r)
        sideB.applyInjury(fmt, injB, &subs)

        let sim = Engine.simulateMatch(teamAName: nameA, teamAAttack: you.attack * sideA.factor, teamADefense: you.defense * sideA.factor,
                                       teamBName: nameB, teamBAttack: them.attack * sideB.factor, teamBDefense: them.defense * sideB.factor, rng: &r)
        var rawEvents: [(minute: Int, team: Side)] = sim.events.map { ($0.minute, $0.team) }
        var gf = sim.scoreA, ga = sim.scoreB
        var extraTime = false, goldenGoal = false, tied = false
        var endMinute = 90
        var pens: String?
        var lots: Side?
        let groupET = !info.knockout && info.kind == "group" && (stage?.groupExtraTime ?? false)
        if (info.knockout || groupET) && gf == ga {
            let fa = sideA.short ? 1 - shortPenalty : 1, fb = sideB.short ? 1 - shortPenalty : 1
            let et = Engine.simulateExtraTime(teamAName: nameA, teamAAttack: you.attack * fa, teamADefense: you.defense * fa,
                                              teamBName: nameB, teamBAttack: them.attack * fb, teamBDefense: them.defense * fb, rng: &r)
            var etEvents: [(minute: Int, team: Side)] = et.events.map { ($0.minute, $0.team) }
            if (fmt.goldenGoal ?? false) && !etEvents.isEmpty {
                etEvents = [etEvents[0]]
                goldenGoal = true
            }
            rawEvents += etEvents
            for e in etEvents { if e.team == .A { gf += 1 } else { ga += 1 } }
            extraTime = true
            endMinute = goldenGoal ? etEvents[0].minute : 120
            if info.knockout && gf == ga {
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

        // schimbările tactice ale echipei tale (în limita regulamentului epocii)
        var i = sideA.subsUsed
        while i < fmt.subs {
            let minute = r.int(55, 88)
            if !sideA.tacticalSub(minute, &subs, &r) { break }
            i += 1
        }
        if extraTime, let etSub = fmt.etSub, etSub > 0 {
            for _ in 0..<etSub {
                let minute = r.int(91, 105)
                if minute > endMinute || !sideA.tacticalSub(minute, &subs, &r) { break }
            }
        }

        var cards: [CardEvent] = []
        if fmt.cards != "none" {
            let rawA = Engine.simulateCards(count: sideA.slots.count, &r)
            cards = sideA.resolveCards(rawA, &subs, endMinute: endMinute)
            let rawB = Engine.simulateCards(count: sideB.slots.count, &r)
            cards += sideB.resolveCards(rawB, &subs, endMinute: endMinute)
            cards = cards.enumerated()
                .sorted { $0.element.minute != $1.element.minute ? $0.element.minute < $1.element.minute : $0.offset < $1.offset }
                .map(\.element)
        }
        let events = Self.pickScorers(rawEvents, sideA, sideB, nameA: nameA, nameB: nameB, &r)
        let subsSorted = subs.enumerated()
            .sorted { $0.element.minute != $1.element.minute ? $0.element.minute < $1.element.minute : $0.offset < $1.offset }
            .map(\.element)
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
        func fpOf(_ side: Side) -> Int {
            cards.filter { $0.team == side }.reduce(0) { $0 + (fairPlayPoints[$1.type] ?? 0) }
        }
        let missing = squad.indices.filter { (suspended[$0] ?? 0) > 0 }.map { squad[$0].name }
        return MatchRecord(kind: info.kind, round: info.round, label: info.label, opp: info.opp, isReal: info.isReal,
                           real: info.real, note: info.note, gf: gf, ga: ga, extraTime: extraTime, pens: pens, lots: lots,
                           replay: info.replay, tied: tied, won: won, events: events, cards: cards, suspended: missing,
                           goldenGoal: goldenGoal, subs: subsSorted, fpA: fpOf(.A), fpB: fpOf(.B))
    }

    /// `pickScorers(events, sideA, sideB, rng)` — marcatorul e ales dintre cei aflați pe teren în acel minut.
    static func pickScorers(_ events: [(minute: Int, team: Side)], _ a: TeamSide, _ b: TeamSide,
                            nameA: String, nameB: String, _ rng: inout Mulberry32) -> [MatchEvent] {
        events.map { e in
            let side = e.team == .A ? a : b
            var pool: [Player] = []
            for slot in side.slots {
                if let p = TeamSide.occupant(slot, e.minute), p.player.pos != .GK { pool.append(p.player) }
            }
            var weighted: [Player] = []
            for p in pool {
                let w = p.pos == .FW ? 4 : p.pos == .MF ? 2 : 1
                for _ in 0..<w { weighted.append(p) }
            }
            let scorer = rng.choice(weighted.isEmpty ? pool : weighted)
            return MatchEvent(minute: e.minute, team: e.team, teamName: e.team == .A ? nameA : nameB, scorer: scorer?.name ?? "?")
        }
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

    static func applyResult(_ table: inout [TableRow], _ a: String, _ b: String, _ ga: Int, _ gb: Int, win: Int,
                            fpa: Int = 0, fpb: Int = 0) {
        let ia = table.firstIndex { $0.code == a }!, ib = table.firstIndex { $0.code == b }!
        table[ia].pl += 1; table[ib].pl += 1
        table[ia].fp += fpa; table[ib].fp += fpb
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
    static func sortTable(_ table: [TableRow], _ tiebreak: String, fairPlay: Bool = false) -> [TableRow] {
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
            if fairPlay && a.fp != b.fp { return a.fp > b.fp }
            return x.offset < y.offset
        }.map(\.element)
    }

    mutating func simOther(_ a: String, _ b: String, knockout: Bool, groupET: Bool = false, engine: Engine) -> OtherResult {
        let fmt = format(engine)
        let sa = Self.auxSquad(a, year, engine: engine), sb = Self.auxSquad(b, year, engine: engine)
        let ra = Engine.tacticalRatings(sa, .echilibrat, .f442), rb = Engine.tacticalRatings(sb, .echilibrat, .f442)
        var r = rng
        let m = Engine.simulateMatch(teamAName: a, teamAAttack: ra.attack, teamADefense: ra.defense,
                                     teamBName: b, teamBAttack: rb.attack, teamBDefense: rb.defense, rng: &r)
        var ga = m.scoreA, gb = m.scoreB
        var winner: String?
        var fph = 0, fpa = 0
        if groupET && ga == gb {
            let et = Engine.simulateExtraTime(teamAName: a, teamAAttack: ra.attack, teamADefense: ra.defense,
                                              teamBName: b, teamBAttack: rb.attack, teamBDefense: rb.defense, rng: &r)
            ga += et.scoreA
            gb += et.scoreB
        }
        if !knockout && (fmt.fairPlay ?? false) {
            for c in Engine.simulateCards(count: min(11, sa.count), &r) { fph += fairPlayPoints[c.type] ?? 0 }
            for c in Engine.simulateCards(count: min(11, sb.count), &r) { fpa += fairPlayPoints[c.type] ?? 0 }
        }
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
        return OtherResult(home: a, away: b, gh: ga, ga: gb, winner: winner, fph: fph, fpa: fpa)
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
        for (a, b) in pairs { g.others.append(simOther(a, b, knockout: false, groupET: st.groupExtraTime ?? false, engine: engine)) }

        var table = m.map { TableRow(code: $0) }
        for r in g.results { Self.applyResult(&table, teamCode, r.opp, r.gf, r.ga, win: fmt.win, fpa: r.fpA, fpb: r.fpB) }
        for o in g.others { Self.applyResult(&table, o.home, o.away, o.gh, o.ga, win: fmt.win, fpa: o.fph, fpb: o.fpa) }
        var sorted = Self.sortTable(table, st.type == "group" ? fmt.tiebreak : "gd", fairPlay: fmt.fairPlay ?? false)
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
                queue.append(Self.info(opp, r, kind: "playoff", round: nil, knockout: true, label: tr("Baraj de grupă", "Group play-off")))
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
            rows.append((Self.sortTable(table, fmt.tiebreak, fairPlay: fmt.fairPlay ?? false)[adv], false))
        }
        rng = r
        // aceeași ordine ca sortTable(rows, "gd") din JS: puncte, golaveraj, goluri marcate, ordinea inițială
        let ranked = rows.enumerated().sorted { x, y in
            let a = x.element.row, b = y.element.row
            if a.pts != b.pts { return a.pts > b.pts }
            let da = a.gf - a.ga, db = b.gf - b.ga
            if da != db { return da > db }
            if a.gf != b.gf { return a.gf > b.gf }
            if (fmt.fairPlay ?? false) && a.fp != b.fp { return a.fp > b.fp }
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
            group?.results.append(GroupResult(opp: info.opp, gf: rec.gf, ga: rec.ga, fpA: rec.fpA, fpB: rec.fpB))
            if queue.isEmpty { finishGroup(engine: engine) }
            return rec
        }
        if rec.tied {
            var again = info
            again.replay = true
            again.label = "\(info.label) \(tr("(rejucat)", "(replay)"))"
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
        case .champion: return tr("🏆 Campioană mondială", "🏆 World champions")
        case .runnerUp: return tr("🥈 Vicecampioană", "🥈 Runners-up")
        case .third: return tr("🥉 Locul 3", "🥉 Third place")
        case .fourth: return tr("Locul 4", "Fourth place")
        case .out: return tr("Eliminată — ", "Knocked out — ") + (outStage ?? "")
        case nil: return tr("În desfășurare", "In progress")
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

    public init(id: UUID = UUID(), date: Date = Date(), team: String, year: Int, outcome: Outcome, label: String) {
        self.id = id
        self.date = date
        self.team = team
        self.year = year
        self.outcome = outcome
        self.label = label
    }
}
