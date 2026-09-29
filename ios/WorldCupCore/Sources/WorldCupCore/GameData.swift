import Foundation

/// Conținutul static al jocului, încărcat o singură dată din bundle.
/// JSON-urile sunt generate din prototipul web cu `node tools/export_ios_data.js`.
public final class GameData: @unchecked Sendable {
    public let editions: [Edition]
    /// Ordinea contează (tragerea la sorți e indexată) — identică cu `Object.keys(TEAMS)`.
    public let teams: [Team]
    public let shadowTeams: [ShadowTeam]
    public let legends: [Legend]
    /// Ordinea contează — identică cu `REAL_FIXTURES` din JS.
    public let campaigns: [Campaign]
    public let rosters: [String: [RosterEntry]]

    public let teamsByCode: [String: Team]
    private let shadowByCode: [String: ShadowTeam]
    private let campaignsByKey: [String: Campaign]

    private struct DataFile: Decodable {
        let editions: [Edition]
        let teams: [Team]
        let shadowTeams: [ShadowTeam]
        let legends: [Legend]
    }

    public init(editions: [Edition], teams: [Team], shadowTeams: [ShadowTeam], legends: [Legend],
                campaigns: [Campaign], rosters: [String: [RosterEntry]]) {
        self.editions = editions
        self.teams = teams
        self.shadowTeams = shadowTeams
        self.legends = legends
        self.campaigns = campaigns
        self.rosters = rosters
        var t: [String: Team] = [:]
        for team in teams { t[team.code] = team }
        teamsByCode = t
        var s: [String: ShadowTeam] = [:]
        for team in shadowTeams { s[team.code] = team }
        shadowByCode = s
        var c: [String: Campaign] = [:]
        for camp in campaigns where c[camp.key] == nil { c[camp.key] = camp }
        campaignsByKey = c
    }

    public enum LoadError: Error { case missingResource(String) }

    public static func load(bundle: Bundle? = nil) throws -> GameData {
        let bundle = bundle ?? Bundle.module
        func read(_ name: String) throws -> Data {
            guard let url = bundle.url(forResource: name, withExtension: "json") else {
                throw LoadError.missingResource(name)
            }
            return try Data(contentsOf: url)
        }
        let decoder = JSONDecoder()
        let file = try decoder.decode(DataFile.self, from: read("Data"))
        let campaigns = try decoder.decode([Campaign].self, from: read("RealFixtures"))
        let rosters = try decoder.decode([String: [RosterEntry]].self, from: read("RealRosters"))
        return GameData(editions: file.editions, teams: file.teams, shadowTeams: file.shadowTeams,
                        legends: file.legends, campaigns: campaigns, rosters: rosters)
    }

    /// Instanța implicită, din resursele pachetului.
    public static let shared: GameData = {
        do { return try load() } catch { fatalError("Nu pot încărca datele jocului: \(error)") }
    }()

    public func campaign(_ teamCode: String, _ year: Int) -> Campaign? {
        campaignsByKey[fixtureKey(teamCode, year)]
    }

    public func edition(_ year: Int) -> Edition? {
        editions.first { $0.year == year }
    }

    /// `getTeamMeta(code)` din data.js.
    public func meta(_ code: String) -> TeamMeta {
        if let t = teamsByCode[code] { return TeamMeta(name: t.name, flag: t.flag) }
        if let s = shadowByCode[code] { return TeamMeta(name: s.name, flag: s.flag) }
        return TeamMeta(name: code, flag: "🏳️")
    }
}
