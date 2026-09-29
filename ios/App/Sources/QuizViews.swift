import SwiftUI
import WorldCupCore

// MARK: - Quiz: meniul modurilor

struct QuizMenuView: View {
    @EnvironmentObject var game: GameState
    let columns = [GridItem(.adaptive(minimum: 150), spacing: 12)]

    var body: some View {
        ScreenContainer(title: "🧠 Quiz", backLabel: tr("Meniu", "Menu"), onBack: { game.go(.menu) }) {
            VStack(alignment: .leading, spacing: 12) {
                QuizModeCard(title: tr("🏃 Maraton 1930 → 2026", "🏃 Marathon 1930 → 2026"), subtitle: tr("23 de întrebări, câte una pe ediție", "23 questions, one per edition"),
                             best: game.quizProgress.best(.marathon, year: nil), total: 23, locked: !game.fullHistory) { game.startQuiz(.marathon) }
                QuizModeCard(title: tr("🕵️ Duoul greșit", "🕵️ Spot the fake"), subtitle: tr("3 afirmații, una e falsă — 10 runde", "3 statements, one is false — 10 rounds"),
                             best: game.quizProgress.best(.tf, year: nil), total: 10, locked: !game.fullHistory) { game.startQuiz(.tf) }
                QuizModeCard(title: tr("🧩 Alege faza", "🧩 Name the stage"), subtitle: tr("Îți dau anul, tu spui ce urma după prima fază — 10 runde", "I give you the year, you say what came after the first stage — 10 rounds"),
                             best: game.quizProgress.best(.phase, year: nil), total: 10, locked: !game.fullHistory) { game.startQuiz(.phase) }

                Text(tr("Quiz pe ediție — 5 întrebări: gazdă, finală, format, golgheter, o surpriză", "Quiz by edition — 5 questions: host, final, format, top scorer, a surprise"))
                    .font(.system(size: 14, weight: .semibold)).foregroundStyle(Color.hwcTextDim)
                    .padding(.top, 6)
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(game.data.editions) { ed in
                        Button { game.startQuiz(.edition, year: ed.year) } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(String(ed.year)).font(.scoreboard(26)).foregroundStyle(Color.hwcGold2)
                                Text(ed.host).font(.system(size: 13)).foregroundStyle(Color.hwcTextDim).lineLimit(1)
                                Text(game.quizStars(ed.year))
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

    private var label: String {
        if locked { return "🔒 Full History" }
        if let best { return tr("Record: ", "Best: ") + "\(best) / \(total)" }
        return tr("Nejucat încă", "Not played yet")
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 16, weight: .bold)).foregroundStyle(Color.hwcText)
                Text(subtitle).font(.system(size: 14)).foregroundStyle(Color.hwcTextDim)
                Text(label)
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
                    Text(tr("Întrebarea \(z.idx + 1) / \(z.questions.count) · Scor \(z.score)", "Question \(z.idx + 1) / \(z.questions.count) · Score \(z.score)"))
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
                        Text(LocalizedStringKey(picked == q.answer ? tr("✅ Corect!", "✅ Correct!") : tr("❌ Răspuns corect: ", "❌ Correct answer: ") + "**\(q.options[q.answer])**"))
                            .font(.system(size: 15)).foregroundStyle(Color.hwcText)
                        PrimaryButton(title: z.isLast ? tr("Vezi rezultatul", "See your score") : tr("Următoarea", "Next"), systemImage: "arrow.right") {
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
            let verdict = pct == 1 ? tr("Perfect! Știi istoria pe de rost.", "Perfect! You know your history by heart.")
                : pct >= 0.6 ? tr("Foarte bine!", "Very good!") : pct >= 0.3 ? tr("Nu-i rău — Muzeul te ajută.", "Not bad — the Museum will help.") : tr("Mai trece o dată prin Muzeu.", "Take another walk through the Museum.")
            ScreenContainer(title: z.title) {
                VStack(spacing: 14) {
                    Text("\(z.score) / \(total)").font(.scoreboard(48)).foregroundStyle(Color.hwcGold2)
                    Text(verdict + (z.newRecord ? tr(" · 🏅 Record nou!", " · 🏅 New best!") : ""))
                        .font(.system(size: 16)).foregroundStyle(Color.hwcText).multilineTextAlignment(.center)
                    PrimaryButton(title: tr("Încă o dată", "Play again"), systemImage: "arrow.clockwise") { game.startQuiz(z.mode, year: z.year) }
                    if let y = z.year {
                        SecondaryButton(title: tr("Citește ediția \(String(y)) în Muzeu", "Read about \(String(y)) in the Museum"), systemImage: "book") {
                            game.museumOpenYear = y
                            game.go(.museum)
                        }
                    }
                    SecondaryButton(title: tr("Înapoi la Quiz", "Back to Quiz"), systemImage: "list.bullet") { game.go(.quizMenu) }
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
        ScreenContainer(title: t.map { "\($0.flag) \($0.name)" } ?? tr("🌍 Traseul țării tale", "🌍 Your country's journey"),
                        backLabel: tr("Meniu", "Menu"), onBack: { game.go(.menu) }) {
            VStack(alignment: .leading, spacing: 12) {
                if let t {
                    Text(summary(t)).font(.system(size: 14)).foregroundStyle(Color.hwcTextDim)
                    if t.entries.isEmpty {
                        Text(tr("\(t.name) nu a jucat încă la un turneu final.", "\(t.name) have not played at a finals yet.")).foregroundStyle(Color.hwcText)
                    }
                    ForEach(Array(t.entries.enumerated()), id: \.offset) { _, e in
                        TrackEntryCard(track: t, entry: e)
                    }
                    if !t.absent.isEmpty {
                        Text(tr("Absentă la: ", "Absent in: ") + t.absent.map(String.init).joined(separator: ", ") + ".")
                            .font(.system(size: 13)).foregroundStyle(Color.hwcTextDim)
                    }
                } else {
                    Text(tr("Nu am putut stabili țara din setările telefonului. Alege-o din listă:", "We couldn't work out your country from your phone settings. Pick it from the list:"))
                        .font(.system(size: 14)).foregroundStyle(Color.hwcTextDim)
                }
                CountryPicker()
                Text(tr("Date meci cu meci: 1930-2022 Fjelstul World Cup Database (CC-BY-SA 4.0); 2026 openfootball (domeniu public).", "Match-by-match data: 1930-2022 Fjelstul World Cup Database (CC-BY-SA 4.0); 2026 openfootball (public domain)."))
                    .font(.system(size: 11)).foregroundStyle(Color.hwcTextDim)
            }
        }
    }

    func summary(_ t: CountryTrack) -> String {
        var s = tr("\(t.entries.count) participări", "\(t.entries.count) appearances")
        if let b = t.best { s += tr(" · cel mai bun rezultat: ", " · best finish: ") + "\(b.label) (\(String(b.year)))" }
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
        let playable = !entry.matches.isEmpty
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(String(entry.year)).font(.scoreboard(22)).foregroundStyle(Color.hwcGold2)
                Text(game.data.edition(entry.year)?.host ?? "").font(.system(size: 14)).foregroundStyle(Color.hwcText)
                if entry.code != track.codes.first {
                    Text(tr("(ca \(name))", "(as \(name))")).font(.system(size: 12)).foregroundStyle(Color.hwcTextDim)
                }
                Spacer()
                Text(entry.finishLabel).font(.system(size: 14, weight: .bold)).foregroundStyle(Color.hwcText)
            }
            if entry.matches.isEmpty {
                Text(tr("Meciurile din \(String(entry.year)) nu sunt încă în baza de date.", "The \(String(entry.year)) matches are not in the database yet."))
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
                let playTitle = (game.isOpen(entry.year) ? "" : "🔒 ") + tr("Joacă această campanie", "Play this campaign")
                SecondaryButton(title: playTitle, systemImage: "play.fill") {
                    game.startRun(team: entry.code, year: entry.year)
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
        let sorted = game.data.countries.sorted { $0.name.compare($1.name, locale: Locale(identifier: AppLanguage.code)) == .orderedAscending }
        Menu {
            ForEach(sorted) { c in
                Button("\(c.flag) \(c.name)") { game.setCountry(c.iso) }
            }
        } label: {
            Label(tr("Schimbă țara", "Change country"), systemImage: "globe")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.hwcGold)
        }
    }
}
