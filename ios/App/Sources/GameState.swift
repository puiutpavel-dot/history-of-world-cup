import SwiftUI
import WorldCupCore

/// Starea aplicației — echivalentul lui `STATE` din app.js.
/// Cariera activă și Sala Trofeelor se salvează în UserDefaults (JSON),
/// echivalentul `localStorage` din prototip.
@MainActor
final class GameState: ObservableObject {
    enum Screen: Equatable {
        case menu, editions, teams(year: Int), hub, preview, live, groupTable, summary, museum, legends, trophies
    }

    @Published var screen: Screen = .menu
    @Published private(set) var career: Career?
    @Published private(set) var preview: MatchPreview?
    @Published private(set) var lastMatch: MatchRecord?
    @Published private(set) var trophies: [TrophyEntry] = []

    let engine = Engine()
    var data: GameData { engine.data }

    private let careerKey = "hwc_active_career_v1"
    private let trophyKey = "hwc_trophy_room_v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard, arguments: [String] = ProcessInfo.processInfo.arguments) {
        self.defaults = defaults
        trophies = load([TrophyEntry].self, key: trophyKey) ?? []
        if let saved = load(Career.self, key: careerKey), !saved.isFinished {
            career = saved
        }
        if let i = arguments.firstIndex(of: "-demoScreen"), i + 1 < arguments.count {
            runDemo(arguments[i + 1])
        }
    }

    // MARK: Navigare

    func go(_ screen: Screen) {
        withAnimation(.easeInOut(duration: 0.2)) { self.screen = screen }
    }

    var hasResumableCareer: Bool { career.map { !$0.isFinished } ?? false }

    // MARK: Carieră

    func startCareer(team: String, year: Int) {
        career = Career.new(teamCode: team, year: year, engine: engine)
        lastMatch = nil
        preview = nil
        persistCareer()
        go(.hub)
    }

    func abandonCareer() {
        career = nil
        defaults.removeObject(forKey: careerKey)
        go(.menu)
    }

    func setMentality(_ m: Mentality) {
        career?.mentality = m
        persistCareer()
    }

    func setFormation(_ f: Formation) {
        career?.formation = f
        persistCareer()
    }

    func openPreview() {
        guard career != nil else { return }
        preview = career!.preview(engine: engine)
        persistCareer()
        go(.preview)
    }

    func playMatch() {
        guard var c = career, !c.isFinished else { return }
        lastMatch = c.playCurrentMatch(engine: engine)
        career = c
        if c.isFinished { addTrophy(TrophyEntry(career: c)) }
        persistCareer()
        go(.live)
    }

    /// `afterMatch()` — unde mergem după ticker.
    func continueAfterMatch() {
        guard let c = career, let m = lastMatch else { return go(.menu) }
        if m.stage == .group && c.groupMatchIndex == 3 {
            go(.groupTable)
        } else if c.isFinished {
            go(.summary)
        } else {
            go(.hub)
        }
    }

    func endCareerAndGoHome() {
        if career?.isFinished == true {
            career = nil
            defaults.removeObject(forKey: careerKey)
        }
        go(.menu)
    }

    // MARK: Utilitare

    func label(_ code: String) -> String { data.meta(code).label }

    private func addTrophy(_ entry: TrophyEntry) {
        trophies.insert(entry, at: 0)
        trophies = Array(trophies.prefix(50))
        save(trophies, key: trophyKey)
    }

    func clearTrophies() {
        trophies = []
        defaults.removeObject(forKey: trophyKey)
    }

    private func persistCareer() {
        if let career { save(career, key: careerKey) }
    }

    private func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let d = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: d)
    }

    private func save<T: Encodable>(_ value: T, key: String) {
        if let d = try? JSONEncoder().encode(value) { defaults.set(d, forKey: key) }
    }

    /// Stări demonstrative pentru capturile de ecran automate din CI:
    /// `-demoScreen menu|editions|teams|hub|preview|live|groupTable|summary|museum|legends|trophies`.
    private func runDemo(_ name: String) {
        var c = Career(teamCode: "BRA", year: 1970, seed: 42, engine: engine)
        switch name {
        case "editions": screen = .editions
        case "teams": screen = .teams(year: 1970)
        case "museum": screen = .museum
        case "legends": screen = .legends
        case "hub":
            career = c; screen = .hub
        case "preview":
            preview = c.preview(engine: engine); career = c; screen = .preview
        case "live":
            lastMatch = c.playCurrentMatch(engine: engine); career = c; screen = .live
        case "groupTable":
            for _ in 0..<3 { lastMatch = c.playCurrentMatch(engine: engine) }
            career = c; screen = .groupTable
        case "summary", "trophies":
            while !c.isFinished { lastMatch = c.playCurrentMatch(engine: engine) }
            career = c
            trophies = [TrophyEntry(career: c)]
            screen = name == "summary" ? .summary : .trophies
        default: screen = .menu
        }
    }
}
