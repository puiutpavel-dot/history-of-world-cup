import SwiftUI
import WorldCupCore

// MARK: - Hub (lot + tactici)

struct HubView: View {
    @EnvironmentObject var game: GameState
    @State private var confirmExit = false

    var body: some View {
        if let c = game.career {
            let team = game.data.meta(c.teamCode)
            ScreenContainer(title: "\(team.flag) \(team.name) · CM \(String(c.year))", backLabel: "Meniu", onBack: { game.go(.menu) }) {
                VStack(spacing: 14) {
                    Panel(title: "Etapă curentă: \(c.stage.label)") {
                        if c.stage == .group {
                            ForEach(Array(c.groupOpponents.enumerated()), id: \.offset) { i, g in
                                let played = i < c.groupResults.count ? c.groupResults[i] : nil
                                FixtureRow(label: nil, code: g.code, isReal: g.isReal,
                                           status: played?.scoreText ?? (i == c.groupMatchIndex ? "urmează" : "—"),
                                           dimmed: false)
                            }
                        } else {
                            KnockoutSummary(career: c)
                        }
                    }

                    Panel(title: "Tactică") {
                        Text("Mentalitate").font(.system(size: 13)).foregroundStyle(Color.hwcTextDim)
                        Picker("Mentalitate", selection: Binding(get: { c.mentality }, set: { game.setMentality($0) })) {
                            ForEach(Mentality.allCases) { Text($0.rawValue).tag($0) }
                        }
                        .pickerStyle(.segmented)
                        Text("Formație").font(.system(size: 13)).foregroundStyle(Color.hwcTextDim)
                        Picker("Formație", selection: Binding(get: { c.formation }, set: { game.setFormation($0) })) {
                            ForEach(Formation.allCases) { Text($0.rawValue).tag($0) }
                        }
                        .pickerStyle(.segmented)
                        let r = c.yourRatings
                        Text("Atac \(Int(r.attack.rounded())) · Apărare \(Int(r.defense.rounded()))")
                            .font(.stat(13))
                            .foregroundStyle(Color.hwcText)
                    }

                    Panel(title: "Lot — Start XI") {
                        ForEach(Array(c.squad.prefix(11).enumerated()), id: \.offset) { _, p in PlayerChip(player: p) }
                        Text("BANCĂ").font(.scoreboard(13, weight: .semibold)).foregroundStyle(Color.hwcTextDim).padding(.top, 6)
                        ForEach(Array(c.squad.dropFirst(11).enumerated()), id: \.offset) { _, p in PlayerChip(player: p).opacity(0.8) }
                    }

                    if !c.isFinished {
                        PrimaryButton(title: c.stage == .group ? "Joacă meciul \(c.groupMatchIndex + 1)/3 din grupă" : "Joacă \(c.stage.label)",
                                      systemImage: "sportscourt.fill") {
                            game.openPreview()
                        }
                    }
                    Button("Abandonează cariera", role: .destructive) { confirmExit = true }
                        .font(.system(size: 14))
                        .padding(.top, 4)
                }
            }
            .confirmationDialog("Sigur vrei să abandonezi cariera curentă?", isPresented: $confirmExit, titleVisibility: .visible) {
                Button("Abandonează", role: .destructive) { game.abandonCareer() }
                Button("Renunță", role: .cancel) {}
            }
        } else {
            MenuView()
        }
    }
}

struct FixtureRow: View {
    @EnvironmentObject var game: GameState
    let label: String?
    let code: String
    let isReal: Bool
    let status: String
    let dimmed: Bool

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 3) {
                if let label {
                    Text(label).font(.system(size: 11, weight: .semibold)).foregroundStyle(Color.hwcTextDim)
                }
                Text(game.label(code)).font(.system(size: 15, weight: .medium)).foregroundStyle(Color.hwcText)
                RealBadge(isReal: isReal)
            }
            Spacer()
            Text(status).font(.stat(15)).foregroundStyle(Color.hwcGold2)
        }
        .padding(.vertical, 4)
        .opacity(dimmed ? 0.5 : 1)
    }
}

struct KnockoutSummary: View {
    let career: Career
    let rounds: [Stage] = [.QF, .SF, .F]

    var body: some View {
        ForEach(Array(rounds.enumerated()), id: \.offset) { i, round in
            if i < career.knockoutResults.count {
                let r = career.knockoutResults[i]
                FixtureRow(label: round.shortLabel, code: r.opp, isReal: r.isReal, status: r.scoreText, dimmed: false)
            } else if i == career.knockoutIndex && !career.isFinished {
                if let plan = career.knockoutPlan[i], !career.usedOpponents.contains(plan.opp) {
                    FixtureRow(label: round.shortLabel, code: plan.opp, isReal: true, status: "urmează", dimmed: false)
                } else {
                    HStack {
                        Text("\(round.shortLabel): adversar tras la sorți").font(.system(size: 14)).foregroundStyle(Color.hwcText)
                        Spacer()
                        Text("urmează").font(.stat(14)).foregroundStyle(Color.hwcGold2)
                    }
                }
            } else {
                Text("\(round.shortLabel): —").font(.system(size: 14)).foregroundStyle(Color.hwcTextDim)
            }
        }
    }
}

// MARK: - Preview

struct MatchPreviewView: View {
    @EnvironmentObject var game: GameState

    var body: some View {
        if let c = game.career, let p = game.preview {
            ScreenContainer(title: p.opponent.roundLabel, backLabel: "Hub", onBack: { game.go(.hub) }) {
                VStack(spacing: 18) {
                    HStack(alignment: .top) {
                        TeamColumn(code: c.teamCode, ratings: c.yourRatings)
                        Text("VS").font(.scoreboard(34)).foregroundStyle(Color.hwcRed).padding(.top, 24)
                        TeamColumn(code: p.opponent.code, ratings: p.opponentRatings)
                    }
                    .padding(.top, 12)
                    RealBadge(isReal: p.opponent.isReal)
                    if let note = p.opponent.note {
                        Text(note).font(.system(size: 14).italic()).foregroundStyle(Color.hwcTextDim).multilineTextAlignment(.center)
                    }
                    Text("Mentalitate: \(c.mentality.rawValue) · Formație: \(c.formation.rawValue)")
                        .font(.system(size: 13)).foregroundStyle(Color.hwcTextDim)
                    PrimaryButton(title: "Joacă meciul", systemImage: "play.fill") { game.playMatch() }
                }
            }
        } else {
            MenuView()
        }
    }
}

struct TeamColumn: View {
    @EnvironmentObject var game: GameState
    let code: String
    let ratings: TacticalRatings

    var body: some View {
        let meta = game.data.meta(code)
        VStack(spacing: 6) {
            Text(meta.flag).font(.system(size: 54))
            Text(meta.name).font(.scoreboard(20, weight: .semibold)).foregroundStyle(Color.hwcText).multilineTextAlignment(.center)
            Text("Atac \(Int(ratings.attack.rounded()))").font(.stat(12)).foregroundStyle(Color.hwcTextDim)
            Text("Apărare \(Int(ratings.defense.rounded()))").font(.stat(12)).foregroundStyle(Color.hwcTextDim)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Meci live (ticker)

struct MatchLiveView: View {
    @EnvironmentObject var game: GameState
    @State private var shown = 0
    @State private var finished = false
    @State private var ticker: Task<Void, Never>?

    var body: some View {
        if let c = game.career, let m = game.lastMatch {
            let visible = Array(m.events.prefix(shown))
            let a = visible.filter { $0.team == .A }.count
            let b = visible.count - a
            ScreenContainer(title: m.stage == .group ? "Grupă" : m.stage.label) {
                VStack(spacing: 16) {
                    HStack {
                        Text(game.data.meta(c.teamCode).flag).font(.system(size: 40))
                        Spacer()
                        Text("\(a) - \(b)")
                            .font(.stat(48, weight: .bold))
                            .foregroundStyle(Color.hwcRed)
                            .contentTransition(.numericText())
                        Spacer()
                        Text(game.data.meta(m.opp).flag).font(.system(size: 40))
                    }
                    .padding(18)
                    .background(Color.black.opacity(0.85), in: RoundedRectangle(cornerRadius: 14))

                    VStack(alignment: .leading, spacing: 8) {
                        if m.events.isEmpty && finished {
                            Text("Niciun gol — 0-0 la final.").foregroundStyle(Color.hwcTextDim)
                        }
                        ForEach(Array(visible.enumerated()), id: \.offset) { _, e in
                            Text("⚽ \(e.minute)' \(e.scorer ?? "?") (\(e.teamName))")
                                .font(.system(size: 15))
                                .foregroundStyle(e.team == .A ? Color.hwcText : Color.hwcTextDim)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if finished {
                        if let pens = m.pens {
                            Text("Penalty-uri: \(pens)").font(.stat(16)).foregroundStyle(Color.hwcGold2)
                        }
                        if let won = m.won {
                            Text(won ? "✅ Calificată mai departe!" : "❌ Eliminată")
                                .font(.scoreboard(20)).foregroundStyle(won ? Color.hwcPitch2 : Color.hwcRed)
                        }
                        HistoryCompare(record: m)
                        PrimaryButton(title: "Continuă", systemImage: "arrow.right") { game.continueAfterMatch() }
                    } else {
                        SecondaryButton(title: "Sări peste", systemImage: "forward.end.fill") { skip(m) }
                    }
                }
                .padding(.top, 8)
            }
            .onAppear { start(m) }
            .onDisappear { ticker?.cancel() }
        } else {
            MenuView()
        }
    }

    private func start(_ m: MatchRecord) {
        shown = 0
        finished = false
        ticker?.cancel()
        ticker = Task { @MainActor in
            for i in 0..<m.events.count {
                try? await Task.sleep(nanoseconds: 550_000_000)
                if Task.isCancelled { return }
                withAnimation(.spring(duration: 0.3)) { shown = i + 1 }
            }
            try? await Task.sleep(nanoseconds: 300_000_000)
            if !Task.isCancelled { withAnimation { finished = true } }
        }
    }

    private func skip(_ m: MatchRecord) {
        ticker?.cancel()
        shown = m.events.count
        finished = true
    }
}

// MARK: - Clasament grupă

struct GroupTableView: View {
    @EnvironmentObject var game: GameState

    var body: some View {
        if let c = game.career, let standings = c.standings {
            let advanced = (c.groupRank ?? 9) <= 1
            ScreenContainer(title: "Clasament grupă — CM \(String(c.year))") {
                VStack(spacing: 14) {
                    Panel {
                        HStack {
                            Text("#").frame(width: 22, alignment: .leading)
                            Text("Echipă")
                            Spacer()
                            Text("M").frame(width: 26)
                            Text("G").frame(width: 50)
                            Text("Pct").frame(width: 36)
                        }
                        .font(.scoreboard(13, weight: .semibold))
                        .foregroundStyle(Color.hwcTextDim)
                        ForEach(Array(standings.enumerated()), id: \.offset) { i, r in
                            HStack {
                                Text("\(i + 1)").frame(width: 22, alignment: .leading)
                                Text(game.label(r.code)).lineLimit(1).minimumScaleFactor(0.8)
                                Spacer()
                                Text("\(r.pl)").frame(width: 26)
                                Text("\(r.gf)-\(r.ga)").frame(width: 50)
                                Text("\(r.pts)").bold().frame(width: 36)
                            }
                            .font(.stat(14))
                            .foregroundStyle(r.code == c.teamCode ? Color.hwcGold2 : Color.hwcText)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 6)
                            .background(i < 2 ? Color.hwcPitch.opacity(0.18) : Color.clear, in: RoundedRectangle(cornerRadius: 6))
                        }
                    }
                    Panel(title: "Celelalte meciuri din grupă") {
                        ForEach(Array(c.otherGroupResults.enumerated()), id: \.offset) { _, m in
                            HStack {
                                Text("\(game.label(m.home)) – \(game.label(m.away))").font(.system(size: 14))
                                Spacer()
                                Text("\(m.goalsHome)-\(m.goalsAway)").font(.stat(14))
                            }
                            .foregroundStyle(Color.hwcText)
                        }
                    }
                    Text("Primele 2 echipe se califică în sferturi.").font(.system(size: 13)).foregroundStyle(Color.hwcTextDim)
                    if advanced {
                        PrimaryButton(title: "Continuă spre sferturi", systemImage: "arrow.right") { game.go(.hub) }
                    } else {
                        PrimaryButton(title: "Vezi sumarul carierei", systemImage: "list.bullet") { game.go(.summary) }
                    }
                }
            }
        } else {
            MenuView()
        }
    }
}

// MARK: - Sumar carieră

struct CareerSummaryView: View {
    @EnvironmentObject var game: GameState

    var body: some View {
        if let c = game.career {
            ScreenContainer(title: "Sumar carieră") {
                VStack(spacing: 14) {
                    VStack(spacing: 6) {
                        Text("\(game.label(c.teamCode)) · CM \(String(c.year))").font(.scoreboard(22)).foregroundStyle(Color.hwcText)
                        Text(summaryTitle(c)).font(.scoreboard(28)).foregroundStyle(c.outcome == .champion ? Color.hwcGold2 : Color.hwcRed)
                        let real = c.allResults.filter(\.isReal)
                        if !real.isEmpty {
                            let same = real.filter { $0.historyRepeated == true }.count
                            Text("📜 \(real.count) meciuri reale · 📖 \(same) scoruri identice cu istoria")
                                .font(.system(size: 13)).foregroundStyle(Color.hwcTextDim)
                        }
                    }
                    .padding(.vertical, 12)

                    Panel {
                        ForEach(Array(c.allResults.enumerated()), id: \.offset) { i, r in
                            VStack(alignment: .leading, spacing: 4) {
                                FixtureRow(label: r.stage == .group ? "Grupă \(i + 1)" : r.stage.shortLabel,
                                           code: r.opp, isReal: r.isReal, status: r.scoreText, dimmed: false)
                                HistoryCompare(record: r)
                            }
                            if i < c.allResults.count - 1 { Divider().overlay(Color.hwcBorder) }
                        }
                    }
                    PrimaryButton(title: "Meniu principal", systemImage: "house.fill") { game.endCareerAndGoHome() }
                }
            }
        } else {
            MenuView()
        }
    }

    private func summaryTitle(_ c: Career) -> String {
        switch c.outcome {
        case .champion: return "🏆 Campioană Mondială!"
        case .eliminatedGroup: return "Eliminată în faza grupelor"
        case .eliminatedKnockout: return "Eliminată în faza eliminatorie"
        case nil: return "În desfășurare"
        }
    }
}
