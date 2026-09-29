import SwiftUI
import WorldCupCore

// MARK: - Modul principal: retrăiești turneul real al unei echipe.
// Meciurile au rezultatele reale; după fiecare meci răspunzi la o întrebare ca să
// mergi mai departe. 3 vieți pe turneu: la al treilea răspuns greșit turneul se termină.

struct RealRun: Codable, Equatable {
    static let startLives = 3

    let team: String
    let year: Int
    let matches: [TrackMatch]
    /// rezultatul real al echipei (champion / runnerUp / third / fourth / SF / GR2 / QF / R16 / G)
    let finish: String
    let finishLabel: String
    /// câte o întrebare după fiecare meci
    let questions: [QuizQuestion]
    var idx = 0
    var revealed = false
    var picked: Int?
    var lives = startLives
    var correct = 0
    /// răspunsurile date, în ordine (true = corect)
    var answers: [Bool] = []
    var finished = false

    var match: TrackMatch { matches[idx] }
    var question: QuizQuestion { questions[idx] }
    var isLastMatch: Bool { idx == matches.count - 1 }
    var outOfLives: Bool { lives <= 0 }
    /// a jucat tot turneul (nu a rămas fără vieți)
    var completed: Bool { finished && !outOfLives }

    var outcome: Outcome {
        guard completed else { return .out }
        switch finish {
        case "champion": return .champion
        case "runnerUp": return .runnerUp
        case "third": return .third
        case "fourth": return .fourth
        default: return .out
        }
    }

    var summaryLabel: String {
        if outOfLives {
            return tr("💔 Fără vieți — meciul \(answers.count)/\(matches.count)", "💔 Out of lives — match \(answers.count)/\(matches.count)")
        }
        return finishLabel
    }
}

/// Rezultatul unui meci real, din perspectiva echipei jucătorului.
func resultTag(_ m: TrackMatch) -> (text: String, color: Color) {
    if m.gf > m.ga { return (tr("Victorie", "Win"), .hwcPitch2) }
    if m.gf < m.ga { return (tr("Înfrângere", "Defeat"), .hwcRed) }
    return (tr("Egal", "Draw"), .hwcGold)
}

// MARK: - Întrebările de după meciuri

enum RunQuestions {
    static let finishOrder = ["champion", "runnerUp", "third", "fourth", "SF", "GR2", "QF", "R16", "R32", "G"]

    /// O întrebare pentru fiecare meci: alternativ despre meciul tocmai jucat (adversarul lui)
    /// și din întrebările ediției (gazdă, finală, format, golgheter, surpriză, adevărat/fals).
    static func build(team: String, year: Int, matches: [TrackMatch], data: GameData) -> [QuizQuestion] {
        var bank = data.quiz.filter { $0.year == year }.shuffled()
        var used = Set<String>()
        var out: [QuizQuestion] = []
        let kinds = ["oppFinish", "oppTitles", "oppDebut"].shuffled()
        var k = 0
        for (i, m) in matches.enumerated() {
            var q: QuizQuestion?
            if i % 2 == 0 || bank.isEmpty {
                for attempt in 0..<kinds.count {
                    if let c = matchQuestion(kinds[(k + attempt) % kinds.count], m, index: i, year: year, data: data),
                       !used.contains(c.q) {
                        q = c
                        k += attempt + 1
                        break
                    }
                }
            }
            if q == nil, let b = bank.first(where: { !used.contains($0.q) }) {
                q = b
                bank.removeAll { $0.q == b.q }
            }
            let chosen = q ?? scoreQuestion(m, index: i, team: team, year: year, data: data)
            used.insert(chosen.q)
            out.append(chosen)
        }
        return out
    }

    private static func mcq(_ id: String, _ year: Int, _ kind: String, _ q: String, correct: String, wrong: [String]) -> QuizQuestion {
        let distinct = Array(Set(wrong.filter { $0 != correct })).shuffled().prefix(3)
        let options = ([correct] + distinct).shuffled()
        return QuizQuestion(id: id, year: year, kind: kind, q: q, options: options, answer: options.firstIndex(of: correct) ?? 0)
    }

    static func matchQuestion(_ kind: String, _ m: TrackMatch, index: Int, year: Int, data: GameData) -> QuizQuestion? {
        let opp = data.meta(m.opp).name
        let id = "run-\(year)-\(index)-\(kind)"
        switch kind {
        case "oppFinish":
            guard let t = data.track(m.opp, year) else { return nil }
            var labels: [String: String] = [:]
            for e in data.countries.flatMap(\.entries) where labels[e.finish] == nil { labels[e.finish] = e.finishLabel }
            let present = Set(data.tracks(year: year).map(\.finish))
            let pool = finishOrder.filter { present.contains($0) && $0 != t.finish }.compactMap { labels[$0] }
            guard pool.count >= 3 else { return nil }
            return mcq(id, year, kind, tr("Până unde a ajuns \(opp) la Mondialul din \(String(year))?",
                                          "How far did \(opp) go at the \(String(year)) World Cup?"),
                       correct: t.finishLabel, wrong: pool)
        case "oppTitles":
            // doar pentru adversarii care au câștigat vreodată Cupa (altfel răspunsul ar fi mereu 0)
            guard data.editions.contains(where: { $0.champion == m.opp && $0.year < year }) else { return nil }
            let n = data.editions.filter { $0.year < year && $0.champion == m.opp }.count
            let wrong = [n + 1, n + 2, n + 3, n - 1, n - 2].filter { $0 >= 0 }.map(String.init)
            return mcq(id, year, kind, tr("Câte titluri mondiale avea \(opp) înainte de \(String(year))?",
                                          "How many World Cups had \(opp) won before \(String(year))?"),
                       correct: String(n), wrong: wrong)
        case "oppDebut":
            guard let first = data.debutYear(m.opp) else { return nil }
            let years = data.editions.map(\.year).filter { $0 != first && abs($0 - first) <= 16 }
            guard years.count >= 3 else { return nil }
            return mcq(id, year, kind, tr("În ce an a jucat \(opp) primul său Mondial?",
                                          "In which year did \(opp) play their first World Cup?"),
                       correct: String(first), wrong: years.map(String.init))
        default:
            return nil
        }
    }

    /// rezervă: scorul meciului (se folosește doar dacă nu există altă întrebare)
    static func scoreQuestion(_ m: TrackMatch, index: Int, team: String, year: Int, data: GameData) -> QuizQuestion {
        let correct = "\(m.gf)–\(m.ga)"
        let wrong = [(m.gf + 1, m.ga), (m.gf, m.ga + 1), (m.ga, m.gf), (m.gf + 1, m.ga + 1), (max(0, m.gf - 1), m.ga)]
            .map { "\($0.0)–\($0.1)" }
        return mcq("run-\(year)-\(index)-score", year, "score",
                   tr("Cu ce scor s-a terminat \(data.meta(team).name) – \(data.meta(m.opp).name)?",
                      "What was the final score of \(data.meta(team).name) – \(data.meta(m.opp).name)?"),
                   correct: correct, wrong: wrong)
    }
}

// MARK: - Alegerea echipei (ediția aleasă)

struct RunTeamSelectView: View {
    @EnvironmentObject var game: GameState
    let year: Int
    let columns = [GridItem(.adaptive(minimum: 150), spacing: 12)]

    var body: some View {
        let host = game.data.edition(year)?.host ?? ""
        ScreenContainer(title: "\(String(year)) · \(host)", backLabel: tr("Ediții", "Editions"), onBack: { game.go(.editions) }) {
            VStack(alignment: .leading, spacing: 12) {
                Text(tr("Alege o echipă și retrăiește-i turneul, meci cu meci, cu rezultatele reale. După fiecare meci răspunzi la o întrebare ca să mergi mai departe — ai 3 vieți.",
                        "Pick a team and relive its tournament match by match, with the real results. After every match you answer a question to move on — you have 3 lives."))
                    .font(.system(size: 14)).foregroundStyle(Color.hwcTextDim)
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(game.playableTeams(year), id: \.code) { e in
                        let meta = game.data.meta(e.code)
                        Button { game.startRun(team: e.code, year: year) } label: {
                            VStack(spacing: 6) {
                                Text(meta.flag).font(.system(size: 40))
                                Text(meta.name).font(.scoreboard(18, weight: .semibold)).foregroundStyle(Color.hwcText)
                                    .multilineTextAlignment(.center).lineLimit(2).minimumScaleFactor(0.8)
                                Text(tr("\(e.matches.count) meciuri", "\(e.matches.count) matches"))
                                    .font(.stat(12)).foregroundStyle(Color.hwcTextDim)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(Color.hwcPanel, in: RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(e.finish == "champion" ? Color.hwcGold : Color.hwcBorder))
                        }
                        .buttonStyle(.plain)
                    }
                }
                Text(tr("Rezultate reale: 1930–2022 Fjelstul World Cup Database (CC-BY-SA 4.0); 2026 openfootball (domeniu public).", "Real results: 1930–2022 Fjelstul World Cup Database (CC-BY-SA 4.0); 2026 openfootball (public domain)."))
                    .font(.system(size: 11)).foregroundStyle(Color.hwcTextDim)
            }
        }
    }
}

// MARK: - Meciul curent + întrebarea

struct RunView: View {
    @EnvironmentObject var game: GameState
    @State private var confirmExit = false
    /// derularea meciului: 0 → 1 în `matchSeconds` secunde
    @State private var progress: Double = 0
    @State private var playing = false
    @State private var ticker: Task<Void, Never>?
    static let matchSeconds = 19.0

    var body: some View {
        if let r = game.run {
            let team = game.data.meta(r.team)
            ScreenContainer(title: "\(team.flag) \(team.name) · \(String(r.year))", backLabel: tr("Meniu", "Menu"), onBack: { game.go(.menu) }) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text(String(repeating: "❤️", count: max(r.lives, 0)) + String(repeating: "🖤", count: RealRun.startLives - max(r.lives, 0)))
                            .font(.system(size: 18))
                        Spacer()
                        Text(tr("Meciul \(r.idx + 1)/\(r.matches.count) · ✅ \(r.correct)", "Match \(r.idx + 1)/\(r.matches.count) · ✅ \(r.correct)"))
                            .font(.stat(13)).foregroundStyle(Color.hwcTextDim)
                    }

                    let shown = playing ? progress : (r.revealed ? 1 : 0)
                    RunMatchCard(team: r.team, match: r.match, revealed: r.revealed, progress: shown, playing: playing)

                    if !r.revealed {
                        PrimaryButton(title: tr("Joacă meciul", "Play the match"), systemImage: "play.fill") { play() }
                    } else if playing {
                        SecondaryButton(title: tr("Sări la final", "Skip to full time"), systemImage: "forward.end.fill") { finish() }
                    } else {
                        RunQuestionPanel(run: r)
                    }

                    if r.idx > 0 {
                        Panel(title: tr("Drumul până aici", "The road so far")) {
                            ForEach(Array(r.matches.prefix(r.idx).enumerated()), id: \.offset) { i, m in
                                HStack(spacing: 8) {
                                    Text(m.round).font(.system(size: 11)).foregroundStyle(Color.hwcTextDim).frame(width: 84, alignment: .leading)
                                    Text(game.label(m.opp)).font(.system(size: 14)).lineLimit(1)
                                    Spacer()
                                    Text("\(m.gf)–\(m.ga)").font(.stat(14, weight: .bold))
                                    Text(r.answers.indices.contains(i) && r.answers[i] ? "✅" : "❌").font(.system(size: 13))
                                }
                                .foregroundStyle(Color.hwcText)
                            }
                        }
                    }

                    Button(tr("Abandonează turneul", "Abandon the tournament"), role: .destructive) { confirmExit = true }
                        .font(.system(size: 14))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 4)
                }
            }
            .confirmationDialog(tr("Sigur vrei să abandonezi turneul?", "Abandon this tournament?"), isPresented: $confirmExit, titleVisibility: .visible) {
                Button(tr("Abandonează", "Abandon"), role: .destructive) { game.abandonRun() }
                Button(tr("Renunță", "Cancel"), role: .cancel) {}
            }
            .onChange(of: r.idx) { finish(); progress = 0 }
            .onDisappear { ticker?.cancel(); playing = false }
            .onAppear {
                // capturile din CI: meciul oprit la mijloc
                if let p = game.demoMatchProgress { progress = p; playing = true }
            }
        } else {
            MenuView()
        }
    }

    /// Meciul se derulează în 19 secunde: cronometrul merge până la 90 (sau 120) și golurile apar la minutul lor.
    private func play() {
        ticker?.cancel()
        progress = 0
        playing = true
        game.revealRunMatch()
        let start = Date()
        ticker = Task { @MainActor in
            while !Task.isCancelled {
                let p = min(1, Date().timeIntervalSince(start) / Self.matchSeconds)
                progress = p
                if p >= 1 { break }
                try? await Task.sleep(nanoseconds: 50_000_000)
            }
            if !Task.isCancelled { withAnimation(.easeInOut(duration: 0.25)) { playing = false } }
        }
    }

    private func finish() {
        ticker?.cancel()
        progress = 1
        withAnimation(.easeInOut(duration: 0.25)) { playing = false }
    }
}

struct RunMatchCard: View {
    @EnvironmentObject var game: GameState
    let team: String
    let match: TrackMatch
    let revealed: Bool
    /// 0 = înainte de start, 1 = final
    var progress: Double = 1
    var playing = false

    private var totalMinutes: Double { match.hadExtraTime ? 120 : 90 }
    private var minuteNow: Double { progress * totalMinutes }
    private var goals: [TrackGoal] { match.goals ?? [] }
    private var visibleGoals: [TrackGoal] {
        progress >= 1 ? goals : goals.filter { $0.clock <= minuteNow }
    }
    private var score: (Int, Int) {
        guard revealed else { return (0, 0) }
        if progress >= 1 { return (match.gf, match.ga) }
        let v = visibleGoals
        return (v.filter { $0.t == 1 }.count, v.filter { $0.t == 0 }.count)
    }
    private var clockText: String {
        if !revealed { return tr("Înainte de meci", "Kick-off soon") }
        if progress >= 1 { return match.hadExtraTime ? tr("Final · după prelungiri", "Full time · after extra time") : tr("Final", "Full time") }
        return "\(max(1, Int(minuteNow.rounded(.up))))'"
    }

    var body: some View {
        let a = game.data.meta(team), b = game.data.meta(match.opp)
        let sc = score
        VStack(spacing: 10) {
            Text(match.round.uppercased()).font(.scoreboard(15, weight: .semibold)).foregroundStyle(Color.hwcGold)
            HStack(alignment: .center) {
                VStack(spacing: 4) {
                    Text(a.flag).font(.system(size: 44))
                    Text(a.name).font(.system(size: 13, weight: .semibold)).multilineTextAlignment(.center).lineLimit(2)
                }
                .frame(maxWidth: .infinity)
                Text(revealed ? "\(sc.0) - \(sc.1)" : "? - ?")
                    .font(.stat(40, weight: .bold))
                    .foregroundStyle(revealed ? Color.hwcRed : Color.hwcTextDim)
                    .contentTransition(.numericText())
                    .animation(.spring(duration: 0.35), value: sc.0 + sc.1)
                    .lineLimit(1)
                    .fixedSize()
                    .layoutPriority(1)
                VStack(spacing: 4) {
                    Text(b.flag).font(.system(size: 44))
                    Text(b.name).font(.system(size: 13, weight: .semibold)).multilineTextAlignment(.center).lineLimit(2)
                }
                .frame(maxWidth: .infinity)
            }
            .foregroundStyle(Color.white)

            Text(clockText)
                .font(.stat(14, weight: .bold))
                .foregroundStyle(playing ? Color.hwcGold : Color.white.opacity(0.7))
                .contentTransition(.numericText())
            if playing {
                ProgressView(value: progress).tint(Color.hwcGold)
            }

            if revealed && !visibleGoals.isEmpty {
                VStack(spacing: 4) {
                    ForEach(Array(visibleGoals.enumerated()), id: \.offset) { _, g in
                        GoalLine(goal: g)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .animation(.easeOut(duration: 0.3), value: visibleGoals.count)
            }

            if revealed && progress >= 1 {
                let tag = resultTag(match)
                HStack(spacing: 8) {
                    Text(tag.text).font(.scoreboard(16, weight: .semibold)).foregroundStyle(tag.color)
                    if let note = match.note {
                        Text("· \(note)").font(.system(size: 13)).foregroundStyle(Color.white.opacity(0.75))
                    }
                }
                Text(tr("📜 Rezultat real", "📜 Real result")).font(.system(size: 11)).foregroundStyle(Color.white.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.black.opacity(0.85), in: RoundedRectangle(cornerRadius: 14))
        .sensoryFeedback(.impact(weight: .medium), trigger: visibleGoals.count)
    }
}

/// Un gol în cardul meciului: golurile echipei tale la stânga, ale adversarului la dreapta.
struct GoalLine: View {
    let goal: TrackGoal

    var body: some View {
        let kind = goal.k == "p" ? tr(" (pen.)", " (pen.)") : goal.k == "og" ? tr(" (autogol)", " (o.g.)") : ""
        HStack(spacing: 6) {
            if goal.t == 0 { Spacer(minLength: 0) }
            Text("⚽ \(goal.m)'").font(.stat(13, weight: .bold))
            Text(goal.n + kind).font(.system(size: 13)).lineLimit(1).minimumScaleFactor(0.8)
            if goal.t == 1 { Spacer(minLength: 0) }
        }
        .foregroundStyle(goal.t == 1 ? Color.white : Color.white.opacity(0.75))
    }
}

struct RunQuestionPanel: View {
    @EnvironmentObject var game: GameState
    let run: RealRun

    var body: some View {
        let q = run.question
        VStack(alignment: .leading, spacing: 10) {
            Text(tr("🧠 Ca să mergi mai departe:", "🧠 To move on:")).font(.system(size: 13, weight: .semibold)).foregroundStyle(Color.hwcGold)
            Text(q.q).font(.system(size: 17, weight: .semibold)).foregroundStyle(Color.hwcText)
                .fixedSize(horizontal: false, vertical: true)
            ForEach(Array(q.options.enumerated()), id: \.offset) { i, option in
                QuizOptionButton(text: option, state: state(i)) { game.answerRun(i) }
                    .disabled(run.picked != nil)
            }
            if let picked = run.picked {
                let ok = picked == q.answer
                Text(LocalizedStringKey(ok ? tr("✅ Corect!", "✅ Correct!")
                                           : tr("❌ Răspuns corect: ", "❌ Correct answer: ") + "**\(q.options[q.answer])**"))
                    .font(.system(size: 15)).foregroundStyle(Color.hwcText)
                if !ok {
                    Text(run.outOfLives ? tr("💔 Ai rămas fără vieți.", "💔 You are out of lives.")
                                        : tr("Ai pierdut o viață — mai ai \(run.lives).", "You lost a life — \(run.lives) left."))
                        .font(.system(size: 14)).foregroundStyle(Color.hwcRed)
                }
                let done = run.outOfLives || run.isLastMatch
                PrimaryButton(title: done ? tr("Vezi rezultatul", "See the result") : tr("Meciul următor", "Next match"),
                              systemImage: "arrow.right") { game.nextRunMatch() }
            }
        }
        .padding(14)
        .background(Color.hwcPanel, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.hwcBorder))
    }

    func state(_ i: Int) -> QuizOptionButton.Mark {
        guard let picked = run.picked else { return .idle }
        if i == run.question.answer { return .correct }
        return i == picked ? .wrong : .idle
    }
}

// MARK: - Rezultatul turneului

struct RunSummaryView: View {
    @EnvironmentObject var game: GameState

    var body: some View {
        if let r = game.run {
            let team = game.data.meta(r.team)
            ScreenContainer(title: tr("Rezultat", "Result")) {
                VStack(spacing: 14) {
                    VStack(spacing: 6) {
                        Text("\(team.flag) \(team.name) · \(String(r.year))").font(.scoreboard(22)).foregroundStyle(Color.hwcText)
                        Text(r.summaryLabel).font(.scoreboard(28))
                            .foregroundStyle(r.outcome == .champion ? Color.hwcGold2 : (r.outOfLives ? Color.hwcRed : Color.hwcText))
                            .multilineTextAlignment(.center)
                        Text(tr("🧠 \(r.correct) / \(r.answers.count) răspunsuri corecte", "🧠 \(r.correct) / \(r.answers.count) correct answers"))
                            .font(.system(size: 15)).foregroundStyle(Color.hwcTextDim)
                        if r.completed {
                            Text(tr("Ai dus \(team.name) până la capătul drumului real.", "You took \(team.name) all the way along their real path."))
                                .font(.system(size: 13)).foregroundStyle(Color.hwcTextDim).multilineTextAlignment(.center)
                        }
                    }
                    .padding(.vertical, 10)

                    Panel {
                        ForEach(Array(r.matches.enumerated()), id: \.offset) { i, m in
                            HStack(spacing: 8) {
                                Text(m.round).font(.system(size: 11)).foregroundStyle(Color.hwcTextDim).frame(width: 84, alignment: .leading)
                                Text(game.label(m.opp)).font(.system(size: 14)).lineLimit(1)
                                Spacer()
                                Text("\(m.gf)–\(m.ga)").font(.stat(14, weight: .bold))
                                Text(r.answers.indices.contains(i) ? (r.answers[i] ? "✅" : "❌") : "·").font(.system(size: 13))
                            }
                            .foregroundStyle(r.answers.indices.contains(i) ? Color.hwcText : Color.hwcTextDim)
                        }
                    }
                    PrimaryButton(title: tr("Joacă din nou", "Play again"), systemImage: "arrow.clockwise") {
                        game.startRun(team: r.team, year: r.year)
                    }
                    SecondaryButton(title: tr("Alege alt turneu", "Pick another tournament"), systemImage: "trophy") { game.go(.editions) }
                    SecondaryButton(title: tr("Meniu principal", "Main menu"), systemImage: "house.fill") { game.endRunAndGoHome() }
                }
            }
        } else {
            MenuView()
        }
    }
}
