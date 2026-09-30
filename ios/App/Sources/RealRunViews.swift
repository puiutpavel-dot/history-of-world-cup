import SwiftUI
import WorldCupCore

// MARK: - Modul principal: retrăiești un Mondial întreg.
// Se joacă fiecare meci al ediției, în ordine cronologică, cu rezultatele reale și marcatorii.
// După fiecare meci: „Știai că?”, apoi clasamentul grupei sau tabloul eliminatoriilor.
// Opțional, urmărești o echipă (evidențiată peste tot; rezultatul ei intră în Sala Trofeelor).

/// Un meci din calendarul ediției: echipa 1, echipa 2 și indexul meciului în traseul echipei 1.
struct Fixture: Codable, Equatable {
    let home: String
    let away: String
    let homeIndex: Int
    /// „MMDD”
    let date: String
}

struct RealRun: Codable, Equatable {
    let year: Int
    /// echipa urmărită (opțional)
    let focus: String?
    let fixtures: [Fixture]
    var idx = 0
    var revealed = false
    var finished = false

    var fixture: Fixture { fixtures[idx] }
    var isLastMatch: Bool { idx == fixtures.count - 1 }

    /// calendarul ediției, din `MatchOrder`: meciurile fiecărei echipe se consumă în ordinea traseului ei
    static func fixtures(year: Int) -> [Fixture] {
        guard let s = MatchOrder.byYear[year] else { return [] }
        var next: [String: Int] = [:]
        return s.split(separator: " ").compactMap { item in
            let t = String(item)
            guard t.count == 11 else { return nil }
            let date = String(t.prefix(4))
            let home = String(t.dropFirst(4).prefix(3)), away = String(t.suffix(3))
            let i = next[home, default: 0]
            next[home] = i + 1
            next[away, default: 0] += 1
            return Fixture(home: home, away: away, homeIndex: i, date: date)
        }
    }
}

extension GameData {
    /// meciul din calendar, din perspectiva echipei 1
    func match(_ f: Fixture, year: Int) -> TrackMatch? {
        guard let e = track(f.home, year), e.matches.indices.contains(f.homeIndex) else { return nil }
        return e.matches[f.homeIndex]
    }
}

/// „14 iunie” / „14 June”
func fixtureDate(_ mmdd: String) -> String {
    let ro = ["ianuarie", "februarie", "martie", "aprilie", "mai", "iunie", "iulie", "august", "septembrie", "octombrie", "noiembrie", "decembrie"]
    let en = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    guard mmdd.count == 4, let m = Int(mmdd.prefix(2)), let d = Int(mmdd.suffix(2)), (1...12).contains(m) else { return "" }
    return "\(d) " + tr(ro[m - 1], en[m - 1])
}

/// Rezultatul unui meci real, din perspectiva echipei jucătorului.
func resultTag(_ m: TrackMatch) -> (text: String, color: Color) {
    if m.gf > m.ga { return (tr("Victorie", "Win"), .hwcPitch2) }
    if m.gf < m.ga { return (tr("Înfrângere", "Defeat"), .hwcRed) }
    return (tr("Egal", "Draw"), .hwcGold)
}

enum RunQuestions {
    /// ordinea rezultatelor finale, de la campioană la eliminată în grupe
    static let finishOrder = ["champion", "runnerUp", "third", "fourth", "SF", "GR2", "QF", "R16", "R32", "G"]
}

// MARK: - Începutul turneului (ediția aleasă)

struct RunTeamSelectView: View {
    @EnvironmentObject var game: GameState
    let year: Int
    let columns = [GridItem(.adaptive(minimum: 150), spacing: 12)]

    var body: some View {
        let host = game.data.edition(year)?.host ?? ""
        let count = RealRun.fixtures(year: year).count
        ScreenContainer(title: "\(String(year)) · \(host)", backLabel: tr("Ediții", "Editions"), onBack: { game.go(.editions) }) {
            VStack(alignment: .leading, spacing: 12) {
                Text(tr("Joci toate cele \(count) de meciuri ale Mondialului, în ordinea în care s-au jucat, cu rezultatele reale și marcatorii. După fiecare meci vezi clasamentul grupei sau tabloul eliminatoriilor.",
                        "Play all \(count) matches of the World Cup in the order they were played, with the real results and goalscorers. After every match you see the group table or the knockout bracket."))
                    .font(.system(size: 14)).foregroundStyle(Color.hwcTextDim)
                PrimaryButton(title: tr("Începe turneul", "Start the tournament"), systemImage: "play.fill") {
                    game.startRun(year: year, focus: nil)
                }
                Text(tr("Sau alege o echipă pe care s-o urmărești (evidențiată în clasamente și în tablou):",
                        "Or pick a team to follow (highlighted in the tables and the bracket):"))
                    .font(.system(size: 13)).foregroundStyle(Color.hwcTextDim)
                    .padding(.top, 4)
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(game.playableTeams(year), id: \.code) { e in
                        let meta = game.data.meta(e.code)
                        Button { game.startRun(year: year, focus: e.code) } label: {
                            VStack(spacing: 6) {
                                Text(meta.flag).font(.system(size: 40))
                                Text(meta.name).font(.scoreboard(18, weight: .semibold)).foregroundStyle(Color.hwcText)
                                    .multilineTextAlignment(.center).lineLimit(2).minimumScaleFactor(0.8)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(Color.hwcPanel, in: RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.hwcBorder))
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

// MARK: - Meciul curent

struct RunView: View {
    @EnvironmentObject var game: GameState
    @State private var confirmExit = false
    /// derularea meciului: 0 → 1 în `matchSeconds` secunde
    @State private var progress: Double = 0
    @State private var playing = false
    @State private var ticker: Task<Void, Never>?
    static let matchSeconds = 19.0

    var body: some View {
        if let r = game.run, let m = game.data.match(r.fixture, year: r.year) {
            let host = game.data.edition(r.year)?.host ?? ""
            ScreenContainer(title: "\(String(r.year)) · \(host)", backLabel: tr("Meniu", "Menu"), onBack: { game.go(.menu) }) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        if let f = r.focus {
                            Text(tr("Urmărești: ", "Following: ") + game.label(f))
                                .font(.system(size: 13)).foregroundStyle(Color.hwcGold).lineLimit(1)
                        }
                        Spacer()
                        Text(tr("Meciul \(r.idx + 1)/\(r.fixtures.count)", "Match \(r.idx + 1)/\(r.fixtures.count)") + " · " + fixtureDate(r.fixture.date))
                            .font(.stat(13)).foregroundStyle(Color.hwcTextDim)
                    }

                    let shown = playing ? progress : (r.revealed ? 1 : 0)
                    RunMatchCard(team: r.fixture.home, match: m, revealed: r.revealed, progress: shown, playing: playing)

                    if !r.revealed {
                        PrimaryButton(title: tr("Joacă meciul", "Play the match"), systemImage: "play.fill") { play() }
                        SecondaryButton(title: tr("Arată direct rezultatul", "Show the result"), systemImage: "forward.end.fill") {
                            game.revealRunMatch(); finish()
                        }
                    } else if playing {
                        SecondaryButton(title: tr("Sări la final", "Skip to full time"), systemImage: "forward.end.fill") { finish() }
                    } else {
                        PrimaryButton(title: r.isLastMatch ? tr("Vezi rezultatul", "See the result") : tr("Meciul următor", "Next match"),
                                      systemImage: "arrow.right") { game.nextRunMatch() }
                    }

                    if r.revealed && !playing {
                        MatchFactsPanel(facts: game.matchFacts.facts(team: r.fixture.home, year: r.year, index: r.fixture.homeIndex))
                            .transition(.opacity)
                        if let board = StageBoard.build(data: game.data, run: r) {
                            StageBoardView(board: board, highlight: [r.fixture.home, r.fixture.away], focus: r.focus)
                                .transition(.opacity)
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

// MARK: - Rezultatul turneului

struct RunSummaryView: View {
    @EnvironmentObject var game: GameState

    var body: some View {
        if let r = game.run {
            let host = game.data.edition(r.year)?.host ?? ""
            let tracks = game.data.tracks(year: r.year)
            let podium: [(String, String)] = [("champion", "🏆"), ("runnerUp", "🥈"), ("third", "🥉")].compactMap { key, icon in
                tracks.first { $0.finish == key }.map { ($0.code, icon) }
            }
            let scorers = topScorers(r)
            ScreenContainer(title: tr("Rezultat", "Result")) {
                VStack(spacing: 14) {
                    VStack(spacing: 6) {
                        Text("\(String(r.year)) · \(host)").font(.scoreboard(22)).foregroundStyle(Color.hwcText)
                        if let champ = podium.first {
                            let meta = game.data.meta(champ.0)
                            Text("🏆 \(meta.flag) \(meta.name)").font(.scoreboard(30)).foregroundStyle(Color.hwcGold2)
                                .multilineTextAlignment(.center)
                            Text(tr("Campioană mondială", "World champions")).font(.system(size: 14)).foregroundStyle(Color.hwcTextDim)
                        }
                        Text(tr("\(r.fixtures.count) meciuri jucate", "\(r.fixtures.count) matches played"))
                            .font(.system(size: 13)).foregroundStyle(Color.hwcTextDim)
                    }
                    .padding(.vertical, 10)

                    Panel(title: tr("Podium", "Podium")) {
                        ForEach(Array(podium.enumerated()), id: \.offset) { _, place in
                            let (code, icon) = place
                            HStack {
                                Text(icon)
                                Text(game.label(code)).font(.system(size: 15, weight: code == r.focus ? .bold : .regular))
                                Spacer()
                            }
                            .foregroundStyle(code == r.focus ? Color.hwcGold : Color.hwcText)
                        }
                        if let top = scorers {
                            Text(tr("⚽ Golgheter: \(top.0) — \(top.1) goluri", "⚽ Top scorer: \(top.0) — \(top.1) goals"))
                                .font(.system(size: 14)).foregroundStyle(Color.hwcTextDim)
                                .padding(.top, 4)
                        }
                        if let f = r.focus, let e = game.data.track(f, r.year) {
                            Text(tr("Echipa ta, \(game.data.meta(f).name): \(e.finishLabel)", "Your team, \(game.data.meta(f).name): \(e.finishLabel)"))
                                .font(.system(size: 14)).foregroundStyle(Color.hwcGold)
                                .padding(.top, 2)
                        }
                    }

                    if let board = StageBoard.build(data: game.data, run: r) {
                        StageBoardView(board: board, highlight: [], focus: r.focus)
                    }

                    PrimaryButton(title: tr("Joacă din nou", "Play again"), systemImage: "arrow.clockwise") {
                        game.startRun(year: r.year, focus: r.focus)
                    }
                    SecondaryButton(title: tr("Alege alt Mondial", "Pick another World Cup"), systemImage: "trophy") { game.go(.editions) }
                    SecondaryButton(title: tr("Meniu principal", "Main menu"), systemImage: "house.fill") { game.endRunAndGoHome() }
                }
            }
        } else {
            MenuView()
        }
    }

    /// golgheterul (sau golgheterii) ediției, din golurile meciurilor
    private func topScorers(_ r: RealRun) -> (String, Int)? {
        var count: [String: Int] = [:]
        for f in r.fixtures {
            for g in game.data.match(f, year: r.year)?.goals ?? [] where g.k != "og" { count[g.n, default: 0] += 1 }
        }
        guard let best = count.values.max(), best > 0 else { return nil }
        return (count.filter { $0.value == best }.keys.sorted().joined(separator: ", "), best)
    }
}
