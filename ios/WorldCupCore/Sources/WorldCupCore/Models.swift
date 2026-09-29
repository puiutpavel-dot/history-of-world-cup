import Foundation

// Modele de date statice — echivalentul data.js / real_fixtures.js /
// real_rosters.js, încărcate din JSON-urile din bundle (vezi GameData).

public struct Edition: Codable, Hashable, Identifiable, Sendable {
    public let year: Int
    public let host: String
    public let champion: String
    public let runnerUp: String
    public let third: String
    public let topScorer: String
    public let ball: String
    public let note: String
    public var id: Int { year }
}

public struct CurvePoint: Codable, Hashable, Sendable {
    public let year: Int
    public let rating: Int
}

public struct Team: Codable, Hashable, Identifiable, Sendable {
    public let code: String
    public let name: String
    public let flag: String
    /// Puncte de control sortate crescător după an.
    public let curve: [CurvePoint]
    public var id: String { code }
}

public struct ShadowTeam: Codable, Hashable, Sendable {
    public let code: String
    public let name: String
    public let flag: String
}

public struct Legend: Codable, Hashable, Identifiable, Sendable {
    public let code: String
    public let name: String
    public let team: String
    public let yearTag: Int
    public let boost: Int
    public let bio: String
    public var id: String { code }
}

public struct FixtureMatch: Codable, Hashable, Sendable {
    public let opp: String
    public let scoreFor: Int
    public let scoreAgainst: Int
    public let round: String?
    public let note: String?
}

public struct Campaign: Codable, Hashable, Sendable {
    public let team: String
    public let year: Int
    public let group: [FixtureMatch]
    public let knockout: [FixtureMatch]
    public var key: String { fixtureKey(team, year) }
}

public enum Position: String, Codable, CaseIterable, Sendable {
    case GK, DF, MF, FW
}

public struct RosterEntry: Codable, Hashable, Sendable {
    public let name: String
    public let pos: Position
}

public struct Player: Codable, Hashable, Sendable {
    public var name: String
    public var pos: Position
    public var overall: Int
    public var isLegend: Bool
    public var bio: String?
}

/// O etapă din drumul unei echipe prin turneu (vezi FORMATS în data.js).
public struct StageSpec: Codable, Hashable, Sendable {
    /// "group" | "group2" | "finalGroup" | "ko"
    public let type: String
    public let size: Int?
    public let groups: Int?
    public let advance: Int?
    public let bestThirds: Int?
    public let seededOnly: Bool?
    public let sizeFromReal: Bool?
    public let winnerTo: String?
    public let secondTo: String?
    public let round: String?
    /// 1954: și meciurile din grupă merg în prelungiri la egal
    public let groupExtraTime: Bool?
}

/// Regulamentul unei ediții: etape, punctaj, departajare, cartonașe, egalități în eliminatorii.
public struct TournamentFormat: Codable, Hashable, Sendable {
    public let year: Int
    public let teams: Int
    public let win: Int
    /// "gd" | "ga" | "playoff"
    public let tiebreak: String
    /// "replay" | "lots" | "penalties"
    public let koTie: String
    /// "none" | "accumulate" | "reset"
    public let cards: String
    public let third: Bool
    public let byes: [String: [String]]?
    public let stages: [StageSpec]
    public let summary: String
    /// schimbări permise în timpul regulamentar (0 / 2 / 3 / 5)
    public let subs: Int
    /// 1994: schimbare în plus pentru portarul accidentat
    public let gkSub: Bool?
    /// schimbări în plus în prelungiri (din 2018)
    public let etSub: Int?
    /// 1998, 2002: primul gol din prelungiri închide meciul
    public let goldenGoal: Bool?
    /// din 2018: la egalitate totală în grupă contează cartonașele
    public let fairPlay: Bool?
}

/// Lotul pe epoci: 22 de jucători până în 1998, 23 în 2002-2018, 26 din 2022 — `squadSizeFor(year)`.
public func squadSizeFor(_ year: Int) -> Int { year <= 1998 ? 22 : year <= 2018 ? 23 : 26 }

/// `squadPositionsFor(year)` din engine.js.
public func squadPositionsFor(_ year: Int) -> [Position] {
    let size = squadSizeFor(year)
    let counts = size == 22 ? [2, 7, 7, 6] : size == 23 ? [3, 7, 7, 6] : [3, 8, 9, 6]
    var out: [Position] = []
    for (i, pos) in [Position.GK, .DF, .MF, .FW].enumerated() {
        for _ in 0..<counts[i] { out.append(pos) }
    }
    return out
}

// MARK: - Conținut de muzeu (history.js)

public struct RulesEra: Codable, Hashable, Sendable {
    public let years: String
    public let title: String
    public let items: [String]
}

public struct SquadRule: Codable, Hashable, Sendable {
    public let years: String
    public let size: String
    public let text: String
}

public struct YearsText: Codable, Hashable, Sendable {
    public let years: String
    public let text: String
}

public struct TitlePath: Codable, Hashable, Sendable {
    public let years: String
    public let games: String
}

public struct EditionStory: Codable, Hashable, Sendable {
    public let year: Int
    public let context: String
    public let moments: [String]
    public let finalMatch: String
    public let coach: String

    enum CodingKeys: String, CodingKey {
        case year, context, moments, coach
        case finalMatch = "final"
    }
}

public struct HistoryContent: Codable, Hashable, Sendable {
    public let rulesTimeline: [RulesEra]
    public let squadRules: [SquadRule]
    public let families: [YearsText]
    public let titlePath: [TitlePath]
    public let stories: [EditionStory]
}

public struct TeamMeta: Hashable, Sendable {
    public let name: String
    public let flag: String
    public var label: String { "\(flag) \(name)" }
}

public func fixtureKey(_ teamCode: String, _ year: Int) -> String { "\(teamCode)_\(year)" }

// MARK: - Quiz și traseul țării (quiz.js)

/// O întrebare din banca de quiz — aceeași ca pe web (generată de `buildQuizBank()`).
public struct QuizQuestion: Codable, Hashable, Identifiable, Sendable {
    public let id: String
    public let year: Int
    /// host | final | phase | scorer | teams | surprise | tf
    public let kind: String
    public let q: String
    public let options: [String]
    public let answer: Int

    public init(id: String, year: Int, kind: String, q: String, options: [String], answer: Int) {
        self.id = id
        self.year = year
        self.kind = kind
        self.q = q
        self.options = options
        self.answer = answer
    }
}

public struct TrackMatch: Codable, Hashable, Sendable {
    public let round: String
    public let opp: String
    public let gf: Int
    public let ga: Int
    public let note: String?
    /// golurile meciului, cronologic (fără loviturile de departajare)
    public let goals: [TrackGoal]?

    /// meciul a avut prelungiri (goluri după minutul 90 sau notă de prelungiri / penalty-uri)
    public var hadExtraTime: Bool {
        if (goals ?? []).contains(where: { $0.base > 90 }) { return true }
        guard let note else { return false }
        return ["prelungiri", "extra time", "penalt"].contains { note.contains($0) }
    }
}

/// Un gol dintr-un meci real: t = 1 dacă a marcat echipa traseului, 0 adversarul.
public struct TrackGoal: Codable, Hashable, Sendable {
    /// minutul, ex. „67” sau „90+3”
    public let m: String
    public let t: Int
    /// marcatorul
    public let n: String
    /// „p” = penalty, „og” = autogol
    public let k: String?

    public var base: Int { Int(m.split(separator: "+").first ?? "") ?? 0 }
    public var extra: Int { m.contains("+") ? Int(m.split(separator: "+").last ?? "") ?? 0 : 0 }
    /// poziția pe cronometru (prelungirile de timp se comprimă în minutul respectiv)
    public var clock: Double { Double(base) + Double(min(extra, 9)) / 10 }
}

public struct TrackEntry: Codable, Hashable, Sendable {
    public let year: Int
    /// echipa care a jucat (ex. „YUG” în traseul Serbiei)
    public let code: String
    public let finish: String
    public let finishLabel: String
    public let matches: [TrackMatch]
}

public struct TrackBest: Codable, Hashable, Sendable {
    public let year: Int
    public let finish: String
    public let label: String
}

/// Traseul real al unei țări (după regiunea ISO) la toate Mondialele.
public struct CountryTrack: Codable, Hashable, Identifiable, Sendable {
    public let iso: String
    public let codes: [String]
    public let name: String
    public let flag: String
    public let absent: [Int]
    public let best: TrackBest?
    public let entries: [TrackEntry]
    public var id: String { iso }
}
