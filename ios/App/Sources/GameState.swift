import SwiftUI
import WorldCupCore

/// Starea aplicației — echivalentul lui `STATE` din app.js.
/// Cariera activă și Sala Trofeelor se salvează în UserDefaults (JSON),
/// echivalentul `localStorage` din prototip.
@MainActor
final class GameState: ObservableObject {
    enum Screen: Equatable {
        case menu, editions, teams(year: Int), hub, preview, live, groupTable, summary, museum, legends, trophies, rules,
             quizMenu, quiz, quizResult, country, paywall, about, run, runSummary
    }

    @Published var screen: Screen = .menu
    /// „Full History” cumpărat (sincronizat din `Store`); 1930-1938 sunt mereu gratuite
    @Published private(set) var fullHistory = false
    static let freeYears: Set<Int> = [1930, 1934, 1938]
    private var paywallReturn: Screen = .menu
    /// capturile din CI fixează starea de deblocare (nu citesc App Store-ul)
    private var demoUnlock: Bool?
    /// ediția deschisă inițial în Muzeu (folosit la capturile din CI)
    var museumOpenYear: Int?
    @Published private(set) var career: Career?
    /// turneul real în desfășurare (modul principal: rezultate reale + quiz după fiecare meci)
    @Published private(set) var run: RealRun?
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
    private let runKey = "hwc_real_run_v1"
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
        if let saved = load(RealRun.self, key: runKey), !saved.finished {
            run = saved
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

    // MARK: Full History (achiziția unică)

    func isOpen(_ year: Int) -> Bool { fullHistory || Self.freeYears.contains(year) }

    func setStoreUnlocked(_ value: Bool) {
        fullHistory = demoUnlock ?? value
    }

    func showPaywall() {
        if screen != .paywall { paywallReturn = screen }
        go(.paywall)
    }

    func closePaywall() { go(paywallReturn) }

    /// eticheta butonului de quiz al unei ediții (Muzeu)
    func quizButtonTitle(_ year: Int) -> String {
        let y = String(year)
        if !isOpen(year) { return "🔒 Quiz \(y) · Full History" }
        if let best = quizProgress.best(.edition, year: year) { return "Quiz \(y) · " + tr("record", "best") + " \(best)/5" }
        return "Quiz \(y) · " + tr("5 întrebări", "5 questions")
    }

    /// stelele unei ediții în meniul de quiz
    func quizStars(_ year: Int) -> String {
        if !isOpen(year) { return "🔒 Full History" }
        let best = quizProgress.best(.edition, year: year) ?? 0
        return String(repeating: "⭐", count: best) + String(repeating: "☆", count: 5 - best)
    }

    /// ecranul de echipe al unei ediții (edițiile blocate duc la deblocare)
    func openEdition(_ year: Int) {
        guard hasRealMatches(year) else { return }
        if isOpen(year) { go(.teams(year: year)) } else { showPaywall() }
    }

    // MARK: Turneul real (modul principal)

    var hasResumableRun: Bool { run.map { !$0.finished } ?? false }

    /// ediția are meciurile reale în baza de date (2026: încă nu)
    func hasRealMatches(_ year: Int) -> Bool { !data.tracks(year: year).isEmpty }

    /// echipele unei ediții: întâi cele care au ajuns mai departe, apoi alfabetic
    func playableTeams(_ year: Int) -> [TrackEntry] {
        let rank = Dictionary(uniqueKeysWithValues: RunQuestions.finishOrder.enumerated().map { ($1, $0) })
        return data.tracks(year: year).sorted {
            let a = rank[$0.finish] ?? 99, b = rank[$1.finish] ?? 99
            return a != b ? a < b : data.meta($0.code).name < data.meta($1.code).name
        }
    }

    func startRun(team: String, year: Int) {
        guard isOpen(year) else { return showPaywall() }
        guard let e = data.track(team, year), !e.matches.isEmpty else { return }
        run = RealRun(team: team, year: year, matches: e.matches, finish: e.finish, finishLabel: e.finishLabel,
                      questions: RunQuestions.build(team: team, year: year, matches: e.matches, data: data))
        persistRun()
        go(.run)
    }

    func revealRunMatch() {
        guard var r = run, !r.revealed else { return }
        withAnimation(.spring(duration: 0.5)) {
            r.revealed = true
            run = r
        }
        persistRun()
    }

    func answerRun(_ i: Int) {
        guard var r = run, r.revealed, r.picked == nil else { return }
        r.picked = i
        let ok = i == r.question.answer
        r.answers.append(ok)
        if ok { r.correct += 1 } else { r.lives -= 1 }
        run = r
        persistRun()
    }

    func nextRunMatch() {
        guard var r = run, r.picked != nil else { return }
        if r.outOfLives || r.isLastMatch {
            r.finished = true
            run = r
            addTrophy(TrophyEntry(team: r.team, year: r.year, outcome: r.outcome, label: r.summaryLabel))
            defaults.removeObject(forKey: runKey)
            go(.runSummary)
            return
        }
        r.idx += 1
        r.revealed = false
        r.picked = nil
        run = r
        persistRun()
    }

    func abandonRun() {
        run = nil
        defaults.removeObject(forKey: runKey)
        go(.menu)
    }

    func endRunAndGoHome() {
        if run?.finished == true { run = nil }
        go(.menu)
    }

    private func persistRun() {
        if let run, !run.finished { save(run, key: runKey) }
    }

    // MARK: Carieră

    func startCareer(team: String, year: Int) {
        guard isOpen(year) else { return showPaywall() }
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
        let allowed = mode == .edition ? isOpen(year ?? 0) : fullHistory
        guard allowed else { return showPaywall() }
        let bank = data.quiz
        let questions: [QuizQuestion]
        let title: String
        switch mode {
        case .edition:
            questions = bank.filter { $0.year == year && QuizSession.editionKinds.contains($0.kind) }
            title = "Quiz \(String(year ?? 0))"
        case .marathon:
            questions = data.editions.compactMap { ed in bank.filter { $0.year == ed.year }.randomElement() }
            title = tr("Maraton 1930 → 2026", "Marathon 1930 → 2026")
        case .tf:
            questions = Array(bank.filter { $0.kind == "tf" }.shuffled().prefix(10))
            title = tr("Duoul greșit", "Spot the fake")
        case .phase:
            questions = Array(bank.filter { $0.kind == "phase" }.shuffled().prefix(10))
            title = tr("Alege faza", "Name the stage")
        }
        guard !questions.isEmpty else { return }
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
    /// `-demoScreen menu|editions|teams|hub|preview|live|groupTable|summary|museum|legends|trophies|rules|quizMenu|quiz|country|paywall|about`.
    private func runDemo(_ name: String) {
        // capturile arată jocul deblocat, cu excepția ecranelor care prezintă blocarea
        demoUnlock = !["paywall", "editions", "quizMenu", "about"].contains(name)
        fullHistory = demoUnlock ?? false
        var c = Career(teamCode: "BRA", year: 1970, seed: 42, engine: engine)
        switch name {
        case "editions": screen = .editions
        case "teams": screen = .teams(year: 1970)
        case "run", "runQuiz", "runSummary":
            startRun(team: "BRA", year: 1970)
            if name != "run" {
                revealRunMatch()
                answerRun(run?.question.answer ?? 0)
            }
            if name == "runSummary" {
                while let r = run, !r.finished {
                    if !r.revealed { revealRunMatch() }
                    if run?.picked == nil { answerRun(run?.question.answer ?? 0) }
                    nextRunMatch()
                }
            }
            screen = name == "runSummary" ? .runSummary : .run
        case "museum": museumOpenYear = 1970; screen = .museum
        case "quizMenu": screen = .quizMenu
        case "quiz":
            startQuiz(.edition, year: 1970)
            pickAnswer(quiz?.current.answer ?? 0)
            screen = .quiz
        case "country": countryOverride = "RO"; screen = .country
        case "paywall": screen = .paywall
        case "about": screen = .about
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
            trophies = [TrophyEntry(team: "BRA", year: 1970, outcome: .champion, label: tr("🏆 Campioană", "🏆 Champions")),
                        TrophyEntry(team: "ROU", year: 1994, outcome: .out, label: tr("Sferturi", "Quarter-finals"))]
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
