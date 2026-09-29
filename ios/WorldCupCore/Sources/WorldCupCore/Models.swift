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

public struct TeamMeta: Hashable, Sendable {
    public let name: String
    public let flag: String
    public var label: String { "\(flag) \(name)" }
}

public func fixtureKey(_ teamCode: String, _ year: Int) -> String { "\(teamCode)_\(year)" }
