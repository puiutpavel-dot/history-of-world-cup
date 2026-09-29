import SwiftUI
import WorldCupCore

/// Starea aplicației — echivalentul lui `STATE` din app.js.
/// Cariera activă și Sala Trofeelor se salvează în UserDefaults (JSON),
/// echivalentul `localStorage` din prototip.
@MainActor
final class GameState: ObservableObject {
    enum Screen: Equatable {
        case menu, editions, teams(year: Int), hub, preview, live, groupTable, summary, museum, legends, trophies, rules,
             quizMenu, quiz, quizResult, country
    }

    @Published var screen: Screen = .menu
    /// ediția deschisă inițial în Muzeu (folosit la capturile din CI)
    var museumOpenYear: Int?
    @Published private(set) var career: Career?
    @Published private(set) var lastMatch: MatchRecord?
    /// indexul clasamentului afișat pe ecranul de clasament
    @Published private(set) var tableIndex = 0
    private var tablesBefore = 0
    @Published private(set) var trophies: [TrophyEntry] = []
    @Published private(set) var quiz: QuizSession?
    @Published private(set) var quizProgress = QuizProgress()
    /// țara aleasă manual (ISO); nil = automat din regiunea telefonului
    @Published private(set) var countryOverride: String?

    let engine = Engine()
    var data: GameData { engine.data }

    private let careerKey = "hwc_active_career_v1"
    private let trophyKey = "hwc_trophy_room_v1"
    private let quizKey = "hwc_quiz_v1"
    private let countryKey = "hwc_country_v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard, arguments: [String] = ProcessInfo.processInfo.arguments) {
        self.defaults = defaults
        trophies = load([TrophyEntry].self, key: trophyKey) ?? []
        quizProgress = load(QuizProgress.self, key: quizKey) ?? QuizProgress()
        countryOverride = defaults.string(forKey: countryKey)
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
        persistCareer()
        go(.preview)
    }

    func playMatch() {
        guard var c = career, !c.isFinished else { return }
        tablesBefore = c.tables.count
        lastMatch = c.playNext(engine: engine)
        career = c
        if c.isFinished { addTrophy(TrophyEntry(career: c)) }
        persistCareer()
        go(.live)
    }

    /// `afterMatch()` — unde mergem după ticker.
    func continueAfterMatch() {
        guard let c = career, lastMatch != nil else { return go(.menu) }
        if c.tables.count > tablesBefore {
            tableIndex = c.tables.count - 1
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

    // MARK: Quiz

    func startQuiz(_ mode: QuizMode, year: Int? = nil) {
        let bank = data.quiz
        let questions: [QuizQuestion]
        let title: String
        switch mode {
        case .edition:
            questions = bank.filter { $0.year == year && QuizSession.editionKinds.contains($0.kind) }
            title = "Quiz \(String(year ?? 0))"
        case .marathon:
            questions = data.editions.compactMap { ed in bank.filter { $0.year == ed.year }.randomElement() }
            title = "Maraton 1930 → 2026"
        case .tf:
            questions = Array(bank.filter { $0.kind == "tf" }.shuffled().prefix(10))
            title = "Duoul greșit"
        case .phase:
            questions = Array(bank.filter { $0.kind == "phase" }.shuffled().prefix(10))
            title = "Alege faza"
        }
        quiz = QuizSession(mode: mode, year: year, title: title, questions: questions)
        go(.quiz)
    }

    func pickAnswer(_ i: Int) {
        guard var z = quiz, z.picked == nil else { return }
        z.picked = i
        if i == z.current.answer { z.score += 1 }
        quiz = z
    }

    func nextQuestion() {
        guard var z = quiz else { return }
        if z.idx + 1 < z.questions.count {
            z.idx += 1
            z.picked = nil
            quiz = z
            return
        }
        let prev = quizProgress.best(z.mode, year: z.year)
        z.newRecord = prev == nil || z.score > prev!
        if z.newRecord { quizProgress.record(z.mode, year: z.year, score: z.score) }
        save(quizProgress, key: quizKey)
        quiz = z
        go(.quizResult)
    }

    // MARK: Țara utilizatorului

    /// Regiunea telefonului (sau alegerea manuală) → traseul țării.
    var countryISO: String? {
        if let countryOverride, data.country(countryOverride) != nil { return countryOverride }
        if let r = Locale.current.region?.identifier, data.country(r) != nil { return r }
        return data.regionFromLocales(Locale.preferredLanguages)
    }

    var userCountry: CountryTrack? { countryISO.flatMap { data.country($0) } }

    func setCountry(_ iso: String) {
        countryOverride = iso
        defaults.set(iso, forKey: countryKey)
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
    /// `-demoScreen menu|editions|teams|hub|preview|live|groupTable|summary|museum|legends|trophies|rules|quizMenu|quiz|country`.
    private func runDemo(_ name: String) {
        var c = Career(teamCode: "BRA", year: 1970, seed: 42, engine: engine)
        switch name {
        case "editions": screen = .editions
        case "teams": screen = .teams(year: 1970)
        case "museum": museumOpenYear = 1970; screen = .museum
        case "quizMenu": screen = .quizMenu
        case "quiz":
            startQuiz(.edition, year: 1970)
            pickAnswer(quiz?.current.answer ?? 0)
            screen = .quiz
        case "country": countryOverride = "RO"; screen = .country
        case "rules": screen = .rules
        case "legends": screen = .legends
        case "hub":
            career = c; screen = .hub
        case "preview":
            career = c; screen = .preview
        case "live":
            lastMatch = c.playNext(engine: engine); career = c; screen = .live
        case "groupTable":
            while c.tables.isEmpty && !c.isFinished { lastMatch = c.playNext(engine: engine) }
            career = c; tableIndex = max(0, c.tables.count - 1); screen = .groupTable
        case "summary", "trophies":
            while !c.isFinished { lastMatch = c.playNext(engine: engine) }
            career = c
            trophies = [TrophyEntry(career: c)]
            screen = name == "summary" ? .summary : .trophies
        default: screen = .menu
        }
    }
}

// MARK: - Quiz: sesiune și progres

enum QuizMode: String, Codable, Sendable {
    case edition, marathon, tf, phase
}

struct QuizSession: Equatable {
    static let editionKinds: Set<String> = ["host", "final", "phase", "scorer", "teams", "surprise"]
    let mode: QuizMode
    let year: Int?
    let title: String
    let questions: [QuizQuestion]
    var idx = 0
    var score = 0
    var picked: Int?
    var newRecord = false

    var current: QuizQuestion { questions[idx] }
    var isLast: Bool { idx == questions.count - 1 }
}

/// Recordurile din quiz (UserDefaults) — echivalentul `hwc_quiz_v1` din localStorage.
struct QuizProgress: Codable, Equatable {
    var editions: [Int: Int] = [:]
    var modes: [String: Int] = [:]

    func best(_ mode: QuizMode, year: Int?) -> Int? {
        mode == .edition ? year.flatMap { editions[$0] } : modes[mode.rawValue]
    }

    mutating func record(_ mode: QuizMode, year: Int?, score: Int) {
        if mode == .edition, let year { editions[year] = score } else { modes[mode.rawValue] = score }
    }
}
