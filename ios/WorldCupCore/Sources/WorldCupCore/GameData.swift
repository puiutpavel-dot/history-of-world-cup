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
    public let formats: [Int: TournamentFormat]
    /// Evoluția regulilor și povestea fiecărei ediții (history.js)
    public let history: HistoryContent?
    /// banca de întrebări (quiz.js)
    public let quiz: [QuizQuestion]
    /// traseul fiecărei țări, după regiunea ISO
    public let countries: [CountryTrack]
    /// limbă fără regiune → țara cea mai probabilă
    public let langRegion: [String: String]

    public let teamsByCode: [String: Team]
    private let shadowByCode: [String: ShadowTeam]
    private let campaignsByKey: [String: Campaign]

    private struct DataFile: Decodable {
        let editions: [Edition]
        let teams: [Team]
        let shadowTeams: [ShadowTeam]
        let legends: [Legend]
        let formats: [TournamentFormat]
        let history: HistoryContent?
        let quiz: [QuizQuestion]?
        let countries: [CountryTrack]?
        let langRegion: [String: String]?
    }

    public init(editions: [Edition], teams: [Team], shadowTeams: [ShadowTeam], legends: [Legend],
                campaigns: [Campaign], rosters: [String: [RosterEntry]], formats: [TournamentFormat] = [],
                history: HistoryContent? = nil, quiz: [QuizQuestion] = [], countries: [CountryTrack] = [],
                langRegion: [String: String] = [:]) {
        self.history = history
        self.quiz = quiz
        self.countries = countries
        self.langRegion = langRegion
        var f: [Int: TournamentFormat] = [:]
        for fmt in formats { f[fmt.year] = fmt }
        self.formats = f
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
                        legends: file.legends, campaigns: campaigns, rosters: rosters, formats: file.formats,
                        history: file.history, quiz: file.quiz ?? [], countries: file.countries ?? [],
                        langRegion: file.langRegion ?? [:])
    }

    /// Instanța implicită, din resursele pachetului.
    public static let shared: GameData = {
        do { return try load() } catch { fatalError("Nu pot încărca datele jocului: \(error)") }
    }()

    public func campaign(_ teamCode: String, _ year: Int) -> Campaign? {
        campaignsByKey[fixtureKey(teamCode, year)]
    }

    /// Echipele prezente la o ediție (pentru tragerile la sorți), sortate — `editionPool(year)` din career.js.
    /// Pentru o ediție fără date (2026) se folosesc echipele ediției anterioare.
    public func editionPool(_ year: Int) -> [String] {
        var y = year
        while y >= 1930 {
            var set = Set<String>()
            for c in campaigns where c.year == y {
                set.insert(c.team)
                for m in c.group { set.insert(m.opp) }
                for m in c.knockout { set.insert(m.opp) }
            }
            if set.count >= 8 { return set.sorted() }
            y -= 4
        }
        return teams.map(\.code).sorted()
    }

    public func country(_ iso: String) -> CountryTrack? {
        countries.first { $0.iso == iso }
    }

    /// `regionFromLocales(locales)` din quiz.js: ex. ["ro-RO", "en-US"] → "RO".
    public func regionFromLocales(_ locales: [String]) -> String? {
        for l in locales {
            let parts = l.replacingOccurrences(of: "_", with: "-").split(separator: "-").map(String.init)
            if let reg = parts.dropFirst().first(where: { $0.count == 2 && $0.allSatisfy(\.isLetter) }),
               country(reg.uppercased()) != nil {
                return reg.uppercased()
            }
        }
        for l in locales {
            if let r = langRegion[String(l.prefix(2)).lowercased()] { return r }
        }
        return nil
    }

    public func story(_ year: Int) -> EditionStory? {
        history?.stories.first { $0.year == year }
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
