import SwiftUI
import WorldCupCore

// MARK: - Quiz: meniul modurilor

struct QuizMenuView: View {
    @EnvironmentObject var game: GameState
    let columns = [GridItem(.adaptive(minimum: 150), spacing: 12)]

    var body: some View {
        ScreenContainer(title: "🧠 Quiz", backLabel: "Meniu", onBack: { game.go(.menu) }) {
            VStack(alignment: .leading, spacing: 12) {
                QuizModeCard(title: "🏃 Maraton 1930 → 2026", subtitle: "23 de întrebări, câte una pe ediție",
                             best: game.quizProgress.best(.marathon, year: nil), total: 23, locked: !game.fullHistory) { game.startQuiz(.marathon) }
                QuizModeCard(title: "🕵️ Duoul greșit", subtitle: "3 afirmații, una e falsă — 10 runde",
                             best: game.quizProgress.best(.tf, year: nil), total: 10, locked: !game.fullHistory) { game.startQuiz(.tf) }
                QuizModeCard(title: "🧩 Alege faza", subtitle: "Îți dau anul, tu spui ce urma după prima fază — 10 runde",
                             best: game.quizProgress.best(.phase, year: nil), total: 10, locked: !game.fullHistory) { game.startQuiz(.phase) }

                Text("Quiz pe ediție — 5 întrebări: gazdă, finală, format, golgheter, o surpriză")
                    .font(.system(size: 14, weight: .semibold)).foregroundStyle(Color.hwcTextDim)
                    .padding(.top, 6)
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(game.data.editions) { ed in
                        let best = game.quizProgress.best(.edition, year: ed.year)
                        Button { game.startQuiz(.edition, year: ed.year) } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(String(ed.year)).font(.scoreboard(26)).foregroundStyle(Color.hwcGold2)
                                Text(ed.host).font(.system(size: 13)).foregroundStyle(Color.hwcTextDim).lineLimit(1)
                                Text(game.isOpen(ed.year)
                                     ? String(repeating: "⭐", count: best ?? 0) + String(repeating: "☆", count: 5 - (best ?? 0))
                                     : "🔒 Full History")
                                    .font(.system(size: 11))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color.hwcPanel, in: RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.hwcBorder))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

struct QuizModeCard: View {
    let title: String
    let subtitle: String
    let best: Int?
    let total: Int
    var locked = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 16, weight: .bold)).foregroundStyle(Color.hwcText)
                Text(subtitle).font(.system(size: 14)).foregroundStyle(Color.hwcTextDim)
                Text(locked ? "🔒 Full History" : best.map { "Record: \($0) / \(total)" } ?? "Nejucat încă")
                    .font(.stat(12)).foregroundStyle(Color.hwcGold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color.hwcPanel, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.hwcBorder))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Quiz: o întrebare

struct QuizPlayView: View {
    @EnvironmentObject var game: GameState

    var body: some View {
        if let z = game.quiz {
            let q = z.current
            ScreenContainer(title: z.title, backLabel: "Quiz", onBack: { game.go(.quizMenu) }) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Întrebarea \(z.idx + 1) / \(z.questions.count) · Scor \(z.score)")
                        .font(.stat(13)).foregroundStyle(Color.hwcTextDim)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(String(q.year)).font(.stat(12)).foregroundStyle(Color.hwcTextDim)
                        Text(q.q).font(.system(size: 18, weight: .semibold)).foregroundStyle(Color.hwcText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color.hwcPanel, in: RoundedRectangle(cornerRadius: 12))

                    ForEach(Array(q.options.enumerated()), id: \.offset) { i, option in
                        QuizOptionButton(text: option, state: optionState(i, z)) { game.pickAnswer(i) }
                            .disabled(z.picked != nil)
                    }

                    if let picked = z.picked {
                        Text(picked == q.answer ? "✅ Corect!" : "❌ Răspuns corect: **\(q.options[q.answer])**")
                            .font(.system(size: 15)).foregroundStyle(Color.hwcText)
                        PrimaryButton(title: z.isLast ? "Vezi rezultatul" : "Următoarea", systemImage: "arrow.right") {
                            game.nextQuestion()
                        }
                    }
                }
            }
        } else {
            QuizMenuView()
        }
    }

    func optionState(_ i: Int, _ z: QuizSession) -> QuizOptionButton.Mark {
        guard let picked = z.picked else { return .idle }
        if i == z.current.answer { return .correct }
        return i == picked ? .wrong : .idle
    }
}

struct QuizOptionButton: View {
    enum Mark { case idle, correct, wrong }
    let text: String
    let state: Mark
    let action: () -> Void

    var body: some View {
        let stroke: Color = state == .correct ? .hwcPitch2 : state == .wrong ? .hwcRed : .hwcBorder
        Button(action: action) {
            Text(text)
                .font(.system(size: 15))
                .foregroundStyle(Color.hwcText)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(stroke.opacity(state == .idle ? 0 : 0.18), in: RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(stroke))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Quiz: rezultat

struct QuizResultView: View {
    @EnvironmentObject var game: GameState

    var body: some View {
        if let z = game.quiz {
            let total = z.questions.count
            let pct = Double(z.score) / Double(max(total, 1))
            let verdict = pct == 1 ? "Perfect! Știi istoria pe de rost."
                : pct >= 0.6 ? "Foarte bine!" : pct >= 0.3 ? "Nu-i rău — Muzeul te ajută." : "Mai trece o dată prin Muzeu."
            ScreenContainer(title: z.title) {
                VStack(spacing: 14) {
                    Text("\(z.score) / \(total)").font(.scoreboard(48)).foregroundStyle(Color.hwcGold2)
                    Text(verdict + (z.newRecord ? " · 🏅 Record nou!" : ""))
                        .font(.system(size: 16)).foregroundStyle(Color.hwcText).multilineTextAlignment(.center)
                    PrimaryButton(title: "Încă o dată", systemImage: "arrow.clockwise") { game.startQuiz(z.mode, year: z.year) }
                    if let y = z.year {
                        SecondaryButton(title: "Citește ediția \(String(y)) în Muzeu", systemImage: "book") {
                            game.museumOpenYear = y
                            game.go(.museum)
                        }
                    }
                    SecondaryButton(title: "Înapoi la Quiz", systemImage: "list.bullet") { game.go(.quizMenu) }
                }
                .padding(.top, 20)
            }
        } else {
            QuizMenuView()
        }
    }
}

// MARK: - Traseul țării utilizatorului

struct CountryView: View {
    @EnvironmentObject var game: GameState

    var body: some View {
        let t = game.userCountry
        ScreenContainer(title: t.map { "\($0.flag) \($0.name)" } ?? "🌍 Traseul țării tale",
                        backLabel: "Meniu", onBack: { game.go(.menu) }) {
            VStack(alignment: .leading, spacing: 12) {
                if let t {
                    Text(summary(t)).font(.system(size: 14)).foregroundStyle(Color.hwcTextDim)
                    if t.entries.isEmpty {
                        Text("\(t.name) nu a jucat încă la un turneu final.").foregroundStyle(Color.hwcText)
                    }
                    ForEach(Array(t.entries.enumerated()), id: \.offset) { _, e in
                        TrackEntryCard(track: t, entry: e)
                    }
                    if !t.absent.isEmpty {
                        Text("Absentă la: " + t.absent.map(String.init).joined(separator: ", ") + ".")
                            .font(.system(size: 13)).foregroundStyle(Color.hwcTextDim)
                    }
                } else {
                    Text("Nu am putut stabili țara din setările telefonului. Alege-o din listă:")
                        .font(.system(size: 14)).foregroundStyle(Color.hwcTextDim)
                }
                CountryPicker()
                Text("Date meci cu meci 1930-2022: Fjelstul World Cup Database, CC-BY-SA 4.0.")
                    .font(.system(size: 11)).foregroundStyle(Color.hwcTextDim)
            }
        }
    }

    func summary(_ t: CountryTrack) -> String {
        var s = "\(t.entries.count) participări"
        if let b = t.best { s += " · cel mai bun rezultat: \(b.label) (\(String(b.year)))" }
        return s
    }
}

struct TrackEntryCard: View {
    @EnvironmentObject var game: GameState
    let track: CountryTrack
    let entry: TrackEntry

    var body: some View {
        let name = game.data.meta(entry.code).name
        let moments = game.data.story(entry.year)?.moments.filter { $0.contains(name) } ?? []
        let playable = game.engine.eligibleTeams(entry.year).contains { $0.code == entry.code }
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(String(entry.year)).font(.scoreboard(22)).foregroundStyle(Color.hwcGold2)
                Text(game.data.edition(entry.year)?.host ?? "").font(.system(size: 14)).foregroundStyle(Color.hwcText)
                if entry.code != track.codes.first {
                    Text("(ca \(name))").font(.system(size: 12)).foregroundStyle(Color.hwcTextDim)
                }
                Spacer()
                Text(entry.finishLabel).font(.system(size: 14, weight: .bold)).foregroundStyle(Color.hwcText)
            }
            if entry.matches.isEmpty {
                Text("Meciurile din \(String(entry.year)) nu sunt încă în baza de date.")
                    .font(.system(size: 13)).foregroundStyle(Color.hwcTextDim)
            }
            ForEach(Array(entry.matches.enumerated()), id: \.offset) { _, m in
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(m.round).font(.system(size: 11)).foregroundStyle(Color.hwcTextDim).frame(width: 78, alignment: .leading)
                    Text(game.label(m.opp)).font(.system(size: 14))
                    Text("\(m.gf)–\(m.ga)").font(.stat(14, weight: .bold))
                    if let note = m.note {
                        Text("(\(note))").font(.system(size: 11)).foregroundStyle(Color.hwcTextDim)
                    }
                }
                .foregroundStyle(Color.hwcText)
            }
            ForEach(moments, id: \.self) { m in
                Text("📖 " + m).font(.system(size: 13).italic()).foregroundStyle(Color.hwcTextDim)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if playable {
                SecondaryButton(title: game.isOpen(entry.year) ? "Joacă această campanie" : "🔒 Joacă această campanie",
                                systemImage: "play.fill") {
                    game.startCareer(team: entry.code, year: entry.year)
                }
            }
        }
        .padding(14)
        .background(Color.hwcPanel, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.hwcBorder))
    }
}

struct CountryPicker: View {
    @EnvironmentObject var game: GameState

    var body: some View {
        let sorted = game.data.countries.sorted { $0.name.compare($1.name, locale: Locale(identifier: "ro")) == .orderedAscending }
        Menu {
            ForEach(sorted) { c in
                Button("\(c.flag) \(c.name)") { game.setCountry(c.iso) }
            }
        } label: {
            Label("Schimbă țara", systemImage: "globe")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.hwcGold)
        }
    }
}
