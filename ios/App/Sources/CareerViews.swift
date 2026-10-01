import SwiftUI
import WorldCupCore

// MARK: - Hub (drum, tactici, lot)

struct HubView: View {
    @EnvironmentObject var game: GameState
    @State private var confirmExit = false

    var body: some View {
        if let c = game.career {
            let team = game.data.meta(c.teamCode)
            let fmt = game.data.formats[c.year]
            ScreenContainer(title: "\(team.flag) \(team.name) · \(tr("CM", "WC")) \(String(c.year))", backLabel: tr("Meniu", "Menu"), onBack: { game.go(.menu) }) {
                VStack(spacing: 14) {
                    Panel(title: c.nextMatch?.label ?? c.outcomeLabel) {
                        if let members = c.groupMembers {
                            Text(tr("Grupa: ", "Group: ") + members.map { game.label($0) }.joined(separator: " · "))
                                .font(.system(size: 13)).foregroundStyle(Color.hwcTextDim)
                        }
                        ForEach(Array(c.records.enumerated()), id: \.offset) { _, r in
                            FixtureRow(label: r.label, code: r.opp, isReal: r.isReal, status: r.scoreText, dimmed: false)
                        }
                        if let next = c.nextMatch {
                            FixtureRow(label: next.label, code: next.opp, isReal: next.isReal, status: tr("urmează", "next"), dimmed: false)
                        }
                        if let fmt {
                            Text(fmt.summary).font(.system(size: 12)).foregroundStyle(Color.hwcTextDim).padding(.top, 4)
                        }
                    }

                    Panel(title: tr("Tactică", "Tactics")) {
                        Text(tr("Mentalitate", "Mentality")).font(.system(size: 13)).foregroundStyle(Color.hwcTextDim)
                        Picker(tr("Mentalitate", "Mentality"), selection: Binding(get: { c.mentality }, set: { game.setMentality($0) })) {
                            ForEach(Mentality.allCases) { Text($0.title).tag($0) }
                        }
                        .pickerStyle(.segmented)
                        Text(tr("Formație", "Formation")).font(.system(size: 13)).foregroundStyle(Color.hwcTextDim)
                        Picker(tr("Formație", "Formation"), selection: Binding(get: { c.formation }, set: { game.setFormation($0) })) {
                            ForEach(Formation.allCases) { Text($0.rawValue).tag($0) }
                        }
                        .pickerStyle(.segmented)
                        let r = c.yourRatings
                        Text(tr("Atac", "Attack") + " \(Int(r.attack.rounded())) · " + tr("Apărare", "Defence") + " \(Int(r.defense.rounded()))")
                            .font(.stat(13))
                            .foregroundStyle(Color.hwcText)
                        let suspended = c.squad.indices.filter { (c.suspended[$0] ?? 0) > 0 }.map { c.squad[$0].name }
                        if !suspended.isEmpty {
                            Text(tr("🟥 Suspendați pentru meciul următor: ", "🟥 Suspended for the next match: ") + suspended.joined(separator: ", "))
                                .font(.system(size: 13)).foregroundStyle(Color.hwcRed)
                        }
                    }

                    Panel(title: tr("Lot — Start XI", "Squad — starting XI")) {
                        let avail = c.availablePlayers.map { $0.player }
                        ForEach(Array(avail.prefix(11).enumerated()), id: \.offset) { _, p in PlayerChip(player: p) }
                        Text(tr("BANCĂ", "BENCH")).font(.scoreboard(13, weight: .semibold)).foregroundStyle(Color.hwcTextDim).padding(.top, 6)
                        ForEach(Array(avail.dropFirst(11).enumerated()), id: \.offset) { _, p in PlayerChip(player: p).opacity(0.8) }
                    }

                    if let next = c.nextMatch {
                        PrimaryButton(title: tr("Joacă: ", "Play: ") + next.label, systemImage: "sportscourt.fill") { game.openPreview() }
                    } else {
                        PrimaryButton(title: tr("Vezi sumarul carierei", "Career summary"), systemImage: "list.bullet") { game.go(.summary) }
                    }
                    Button(tr("Abandonează cariera", "Abandon career"), role: .destructive) { confirmExit = true }
                        .font(.system(size: 14))
                        .padding(.top, 4)
                }
            }
            .confirmationDialog(tr("Sigur vrei să abandonezi cariera curentă?", "Abandon your current career?"), isPresented: $confirmExit, titleVisibility: .visible) {
                Button(tr("Abandonează", "Abandon"), role: .destructive) { game.abandonCareer() }
                Button(tr("Renunță", "Cancel"), role: .cancel) {}
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
            Text(status).font(.stat(14)).foregroundStyle(Color.hwcGold2).multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 4)
        .opacity(dimmed ? 0.5 : 1)
    }
}

// MARK: - Preview

struct MatchPreviewView: View {
    @EnvironmentObject var game: GameState

    var body: some View {
        if let c = game.career, let next = c.nextMatch {
            let oppRatings = Engine.tacticalRatings(Career.opponentSquad(next.opp, c.year, engine: game.engine), .echilibrat, .f442)
            ScreenContainer(title: next.label, backLabel: "Hub", onBack: { game.go(.hub) }) {
                VStack(spacing: 18) {
                    HStack(alignment: .top) {
                        TeamColumn(code: c.teamCode, ratings: c.yourRatings)
                        Text("VS").font(.scoreboard(34)).foregroundStyle(Color.hwcRed).padding(.top, 24)
                        TeamColumn(code: next.opp, ratings: oppRatings)
                    }
                    .padding(.top, 12)
                    RealBadge(isReal: next.isReal)
                    if let note = next.note {
                        Text(localizedNote(note)).font(.system(size: 14).italic()).foregroundStyle(Color.hwcTextDim).multilineTextAlignment(.center)
                    }
                    Text(tr("Mentalitate: ", "Mentality: ") + c.mentality.title + tr(" · Formație: ", " · Formation: ") + c.formation.rawValue
                         + (next.knockout ? tr(" · Eliminatoriu: la egal se joacă prelungiri", " · Knockout: extra time if level") : ""))
                        .font(.system(size: 13)).foregroundStyle(Color.hwcTextDim).multilineTextAlignment(.center)
                    if let f = game.data.formats[c.year] {
                        Text(rulesLine(f)).font(.system(size: 13)).foregroundStyle(Color.hwcTextDim).multilineTextAlignment(.center)
                    }
                    PrimaryButton(title: tr("Joacă meciul", "Play the match"), systemImage: "play.fill") { game.playMatch() }
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
            Text(tr("Atac", "Attack") + " \(Int(ratings.attack.rounded()))").font(.stat(12)).foregroundStyle(Color.hwcTextDim)
            Text(tr("Apărare", "Defence") + " \(Int(ratings.defense.rounded()))").font(.stat(12)).foregroundStyle(Color.hwcTextDim)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Meci live (ticker cu goluri și cartonașe)

struct TickerItem: Hashable {
    let minute: Int
    let team: Side
    let text: String
    let isGoal: Bool
}

struct MatchLiveView: View {
    @EnvironmentObject var game: GameState
    @State private var shown = 0
    @State private var finished = false
    @State private var ticker: Task<Void, Never>?

    static func items(_ m: MatchRecord, team: String, meta: (String) -> String) -> [TickerItem] {
        let goals = m.events.map { e in
            TickerItem(minute: e.minute, team: e.team, text: "⚽ \(e.minute)' \(e.scorer ?? "?") (\(meta(e.team == .A ? team : m.opp)))", isGoal: true)
        }
        let icon = ["Y": "🟨", "R": "🟥", "Y2R": "🟨🟥"]
        let cards = m.cards.map { c in
            TickerItem(minute: c.minute, team: c.team, text: "\(icon[c.type] ?? "") \(c.minute)' \(c.player) (\(meta(c.team == .A ? team : m.opp)))", isGoal: false)
        }
        let subs = m.subs.map { x -> TickerItem in
            let who: String = meta(x.team == .A ? team : m.opp)
            let text: String
            if let inn = x.inn {
                text = x.injury ? tr("🚑🔁 \(x.minute)' \(x.out) accidentat, intră \(inn) (\(who))", "🚑🔁 \(x.minute)' \(x.out) injured, \(inn) comes on (\(who))")
                                : tr("🔁 \(x.minute)' Intră \(inn), iese \(x.out) (\(who))", "🔁 \(x.minute)' \(inn) on, \(x.out) off (\(who))")
            } else {
                text = tr("🚑 \(x.minute)' \(x.out) (\(who)) accidentat — fără schimbări, echipa rămâne în 10", "🚑 \(x.minute)' \(x.out) (\(who)) injured — no substitutes, the team plays on with 10")
            }
            return TickerItem(minute: x.minute, team: x.team, text: text, isGoal: false)
        }
        return (goals + cards + subs).enumerated()
            .sorted { $0.element.minute != $1.element.minute ? $0.element.minute < $1.element.minute : $0.offset < $1.offset }
            .map(\.element)
    }

    var body: some View {
        if let c = game.career, let m = game.lastMatch {
            let all = Self.items(m, team: c.teamCode) { game.data.meta($0).name }
            let visible = Array(all.prefix(shown))
            let a = visible.filter { $0.isGoal && $0.team == .A }.count
            let b = visible.filter { $0.isGoal && $0.team == .B }.count
            ScreenContainer(title: m.label) {
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
                        if all.isEmpty && finished {
                            Text(tr("Niciun gol, niciun cartonaș.", "No goals, no cards.")).foregroundStyle(Color.hwcTextDim)
                        }
                        ForEach(Array(visible.enumerated()), id: \.offset) { _, e in
                            Text(e.text)
                                .font(.system(size: 15))
                                .foregroundStyle(e.team == .A ? Color.hwcText : Color.hwcTextDim)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if finished {
                        VStack(spacing: 6) {
                            if m.goldenGoal {
                                Text(tr("⚡ Gol de aur — primul gol din prelungiri a încheiat meciul.", "⚡ Golden goal — the first goal in extra time ended the match."))
                            } else if m.extraTime {
                                Text(tr("⏱️ S-au jucat prelungiri.", "⏱️ The match went to extra time."))
                            }
                            if let pens = m.pens { Text(tr("🎯 Penalty-uri: ", "🎯 Penalties: ") + pens).font(.stat(16)) }
                            if let lots = m.lots { Text(lots == .A ? tr("🪙 Tragere la sorți: câștigată!", "🪙 Drawing of lots: won!") : tr("🪙 Tragere la sorți: pierdută.", "🪙 Drawing of lots: lost.")) }
                            if m.tied { Text(tr("🔁 Egalitate după prelungiri — meciul se rejoacă.", "🔁 Level after extra time — the match will be replayed.")) }
                            if let won = m.won {
                                Text(won ? tr("✅ Calificată mai departe!", "✅ Through to the next round!") : tr("❌ Pierdut", "❌ Lost"))
                                    .font(.scoreboard(20)).foregroundStyle(won ? Color.hwcPitch2 : Color.hwcRed)
                            }
                            if !m.suspended.isEmpty {
                                Text(tr("🟥 Au lipsit (suspendați): ", "🟥 Missing (suspended): ") + m.suspended.joined(separator: ", ")).font(.system(size: 13))
                            }
                        }
                        .foregroundStyle(Color.hwcGold2)
                        HistoryCompare(record: m)
                        PrimaryButton(title: tr("Continuă", "Continue"), systemImage: "arrow.right") { game.continueAfterMatch() }
                    } else {
                        SecondaryButton(title: tr("Sări peste", "Skip"), systemImage: "forward.end.fill") { skip(all.count) }
                    }
                }
                .padding(.top, 8)
            }
            .onAppear { start(all.count) }
            .onDisappear { ticker?.cancel() }
        } else {
            MenuView()
        }
    }

    private func start(_ count: Int) {
        shown = 0
        finished = false
        ticker?.cancel()
        ticker = Task { @MainActor in
            for i in 0..<count {
                try? await Task.sleep(nanoseconds: 550_000_000)
                if Task.isCancelled { return }
                withAnimation(.spring(duration: 0.3)) { shown = i + 1 }
            }
            try? await Task.sleep(nanoseconds: 300_000_000)
            if !Task.isCancelled { withAnimation { finished = true } }
        }
    }

    private func skip(_ count: Int) {
        ticker?.cancel()
        shown = count
        finished = true
    }
}

// MARK: - Clasament (după fiecare fază de grupe)

struct GroupTableView: View {
    @EnvironmentObject var game: GameState

    var body: some View {
        if let c = game.career, game.tableIndex < c.tables.count {
            let t = c.tables[game.tableIndex]
            let titles = AppLanguage.isRomanian
                ? ["group": "Clasament grupă", "group2": "A doua fază a grupelor", "finalGroup": "Grupa finală"]
                : ["group": "Group table", "group2": "Second group stage", "finalGroup": "Final group"].mapValues(translated)
            let title = titles[t.type] ?? tr("Clasament", "Table")
            let verdict = t.type == "finalGroup" ? c.outcomeLabel : (t.qualified ? tr("✅ Calificată", "✅ Qualified") : tr("❌ Eliminată", "❌ Knocked out"))
            ScreenContainer(title: "\(title) — \(tr("CM", "WC")) \(String(c.year))") {
                VStack(spacing: 14) {
                    Panel {
                        HStack {
                            Text("#").frame(width: 22, alignment: .leading)
                            Text(tr("Echipă", "Team"))
                            Spacer()
                            Text(tr("M", "P")).frame(width: 26)
                            Text("G").frame(width: 50)
                            Text(tr("Pct", "Pts")).frame(width: 36)
                        }
                        .font(.scoreboard(13, weight: .semibold))
                        .foregroundStyle(Color.hwcTextDim)
                        ForEach(Array(t.rows.enumerated()), id: \.offset) { i, r in
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
                            .background(r.code == c.teamCode ? Color.hwcPitch.opacity(0.18) : Color.clear, in: RoundedRectangle(cornerRadius: 6))
                        }
                    }
                    if !t.others.isEmpty {
                        Panel(title: tr("Celelalte meciuri", "Other matches")) {
                            ForEach(Array(t.others.enumerated()), id: \.offset) { _, m in
                                HStack {
                                    Text("\(game.label(m.home)) – \(game.label(m.away))").font(.system(size: 14))
                                    Spacer()
                                    Text("\(m.gh)-\(m.ga)").font(.stat(14))
                                }
                                .foregroundStyle(Color.hwcText)
                            }
                        }
                    }
                    if let p = t.playoff {
                        if let o = p.result {
                            Text(tr("Baraj: ", "Play-off: ") + "\(game.label(o.home)) – \(game.label(o.away)) \(o.gh)-\(o.ga) (" + tr("trece ", "through: ") + "\(game.label(o.winner ?? "")))")
                                .font(.system(size: 13)).foregroundStyle(Color.hwcTextDim)
                        } else if let opp = p.opp {
                            Text(tr("Egalitate de puncte pe locul de calificare → baraj cu ", "Level on points for the qualifying place → play-off against ") + "\(game.label(opp)): " + (p.won == true ? tr("câștigat", "won") : tr("pierdut", "lost")) + ".")
                                .font(.system(size: 13)).foregroundStyle(Color.hwcTextDim)
                        }
                    }
                    if let th = t.thirds {
                        Text(tr("Clasamentul locurilor 3: locul \(th.rank + 1) din \(th.rows.count) — ", "Third-placed teams: \(th.rank + 1) of \(th.rows.count) — ")
                             + (t.qualified ? tr("calificată printre cele mai bune locuri 3!", "through as one of the best third-placed teams!") : tr("nu ajunge printre cele mai bune locuri 3.", "not among the best third-placed teams.")))
                            .font(.system(size: 13)).foregroundStyle(Color.hwcTextDim)
                    }
                    Text(tr("Victorie = \(game.data.formats[c.year]?.win ?? 2) puncte", "Win = \(game.data.formats[c.year]?.win ?? 2) points") + " · \(verdict)")
                        .font(.system(size: 13)).foregroundStyle(Color.hwcTextDim)
                    if c.isFinished {
                        PrimaryButton(title: tr("Vezi sumarul carierei", "Career summary"), systemImage: "list.bullet") { game.go(.summary) }
                    } else {
                        PrimaryButton(title: tr("Continuă", "Continue"), systemImage: "arrow.right") { game.go(.hub) }
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
            ScreenContainer(title: tr("Sumar carieră", "Career summary")) {
                VStack(spacing: 14) {
                    VStack(spacing: 6) {
                        Text("\(game.label(c.teamCode)) · \(tr("CM", "WC")) \(String(c.year))").font(.scoreboard(22)).foregroundStyle(Color.hwcText)
                        Text(c.outcomeLabel).font(.scoreboard(28))
                            .foregroundStyle(c.outcome == .champion ? Color.hwcGold2 : (c.outcome == .out ? Color.hwcRed : Color.hwcText))
                        let real = c.records.filter(\.isReal)
                        if !real.isEmpty {
                            let same = real.filter { $0.historyRepeated == true }.count
                            Text(tr("📜 \(real.count) meciuri reale · 📖 \(same) scoruri identice cu istoria", "📜 \(real.count) real matches · 📖 \(same) scores identical to history"))
                                .font(.system(size: 13)).foregroundStyle(Color.hwcTextDim)
                        }
                    }
                    .padding(.vertical, 12)

                    Panel {
                        ForEach(Array(c.records.enumerated()), id: \.offset) { i, r in
                            VStack(alignment: .leading, spacing: 4) {
                                FixtureRow(label: r.label, code: r.opp, isReal: r.isReal, status: r.scoreText, dimmed: false)
                                HistoryCompare(record: r)
                            }
                            if i < c.records.count - 1 { Divider().overlay(Color.hwcBorder) }
                        }
                    }
                    PrimaryButton(title: tr("Meniu principal", "Main menu"), systemImage: "house.fill") { game.endCareerAndGoHome() }
                }
            }
        } else {
            MenuView()
        }
    }
}
