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
    /// a început în același moment cu meciul anterior din calendar (se joacă pe același ecran)
    var together: Bool? = nil
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
    /// meciurile ecranului curent: meciul `idx` și cele care au început în același moment cu el
    var slot: Range<Int> {
        var end = idx + 1
        while end < fixtures.count, fixtures[end].together == true { end += 1 }
        return idx..<end
    }
    var isLastMatch: Bool { slot.upperBound >= fixtures.count }
    /// ecranul curent conține meciul dintre aceste echipe
    func has(_ teams: Set<String>) -> Bool { slot.contains { Set([fixtures[$0].home, fixtures[$0].away]) == teams } }

    /// calendarul ediției, din `MatchOrder`: meciurile fiecărei echipe se consumă în ordinea traseului ei
    static func fixtures(year: Int) -> [Fixture] {
        guard let s = MatchOrder.byYear[year] else { return [] }
        var next: [String: Int] = [:]
        return s.split(separator: " ").compactMap { item in
            var t = String(item)
            let together = t.hasPrefix("=")
            if together { t.removeFirst() }
            guard t.count == 11 else { return nil }
            let date = String(t.prefix(4))
            let home = String(t.dropFirst(4).prefix(3)), away = String(t.suffix(3))
            let i = next[home, default: 0]
            next[home] = i + 1
            next[away, default: 0] += 1
            return Fixture(home: home, away: away, homeIndex: i, date: date, together: together ? true : nil)
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

/// un meci de pe ecranul curent: indexul din calendar și meciul (din perspectiva echipei 1)
struct SlotMatch: Identifiable {
    let i: Int
    let m: TrackMatch
    var id: Int { i }
}

struct RunView: View {
    @EnvironmentObject var game: GameState
    /// derularea meciului: 0 → 1 în `matchSeconds` secunde
    @State private var progress: Double = 0
    /// loviturile de departajare: 0 → 1 în încă `matchSeconds` secunde, după fluierul final
    @State private var penProgress: Double = 0
    @State private var playing = false
    @State private var ticker: Task<Void, Never>?
    static let matchSeconds = 19.0

    var body: some View {
        if let r = game.run, game.data.match(r.fixture, year: r.year) != nil {
            let host = game.data.edition(r.year)?.host ?? ""
            let slot = Array(r.slot)
            let matches = slot.compactMap { i in game.data.match(r.fixtures[i], year: r.year).map { SlotMatch(i: i, m: $0) } }
            let maxMinutes: Double = matches.contains { $0.m.hadExtraTime } ? 120 : 90
            ScreenContainer(title: "\(String(r.year)) · \(host)", backLabel: tr("Meniu", "Menu"), onBack: { game.go(.menu) }) {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        if let f = r.focus {
                            Text(tr("Urmărești: ", "Following: ") + game.label(f))
                                .font(.system(size: 13)).foregroundStyle(Color.hwcGold).lineLimit(1)
                        }
                        Spacer()
                        Text(counterText(r) + " · " + fixtureDate(r.fixture.date))
                            .font(.stat(13)).foregroundStyle(Color.hwcTextDim).lineLimit(1).minimumScaleFactor(0.8)
                    }
                    if matches.count > 1 {
                        Text(tr("⏱ \(matches.count) meciuri care s-au jucat în același timp", "⏱ \(matches.count) matches played at the same time"))
                            .font(.system(size: 13, weight: .semibold)).foregroundStyle(Color.hwcGold)
                    }

                    let shown = playing ? progress : (r.revealed ? 1 : 0)
                    let penShown = playing ? penProgress : (r.revealed ? 1 : 0)
                    ForEach(matches) { x in
                        let events = MatchEvents.of(year: r.year, index: x.i)
                        let own: Double = x.m.hadExtraTime ? 120 : 90
                        // ceasul e comun: un meci de 90' se termină înaintea unuia cu prelungiri
                        let p = min(1, shown * maxMinutes / own)
                        let busy = playing && (p < 1 || (!events.kicks.isEmpty && penShown < 1))
                        RunMatchCard(team: r.fixtures[x.i].home, match: x.m, revealed: r.revealed, progress: p, playing: busy,
                                     events: events, penProgress: penShown,
                                     verdict: MatchVerdict.of(run: r, index: x.i, match: x.m, data: game.data),
                                     compact: matches.count > 1,
                                     title: GroupNames.title(round: x.m.round, letter: GroupNames.letter(year: r.year, index: x.i)))
                    }

                    if !r.revealed {
                        PrimaryButton(title: matches.count > 1 ? tr("Joacă meciurile", "Play the matches") : tr("Joacă meciul", "Play the match"),
                                      systemImage: "play.fill") {
                            play(minutes: maxMinutes, shootout: matches.contains { !MatchEvents.of(year: r.year, index: $0.i).kicks.isEmpty })
                        }
                    } else if !playing {
                        PrimaryButton(title: r.isLastMatch ? tr("Vezi rezultatul", "See the result") : tr("Meciul următor", "Next match"),
                                      systemImage: "arrow.right") { game.nextRunMatch() }
                    }

                    if r.revealed && !playing {
                        let each = matches.count > 1 ? 1 : 2
                        MatchFactsPanel(facts: slot.flatMap { i in
                            game.matchFacts.facts(team: r.fixtures[i].home, year: r.year, index: r.fixtures[i].homeIndex, limit: each)
                        })
                        .transition(.opacity)
                        let highlight = Set(slot.flatMap { [r.fixtures[$0].home, r.fixtures[$0].away] })
                        ForEach(StageBoard.boards(data: game.data, run: r)) { b in
                            StageBoardView(board: b.board, highlight: highlight, focus: r.focus)
                                .transition(.opacity)
                        }
                    }
                }
            }
            .overlay {
                // finala: confetti peste tot ecranul, după fluierul final (și după penalty-uri)
                if r.revealed && !playing, matches.contains(where: { MatchVerdict.of(run: r, index: $0.i, match: $0.m, data: game.data)?.isChampion == true }) {
                    ConfettiView().id(r.idx)
                }
            }
            .onChange(of: r.idx) { finish(); progress = 0; penProgress = 0 }
            .onDisappear { ticker?.cancel(); playing = false }
            .onAppear {
                // capturile din CI: meciul oprit la mijloc
                if let p = game.demoMatchProgress { progress = p; playing = true }
            }
        } else {
            MenuView()
        }
    }

    /// „Meciul 34/52” sau, pentru meciuri simultane, „Meciurile 33–34/52”
    private func counterText(_ r: RealRun) -> String {
        let s = r.slot, n = r.fixtures.count
        if s.count == 1 { return tr("Meciul \(s.lowerBound + 1)/\(n)", "Match \(s.lowerBound + 1)/\(n)") }
        return tr("Meciurile \(s.lowerBound + 1)–\(s.upperBound)/\(n)", "Matches \(s.lowerBound + 1)–\(s.upperBound)/\(n)")
    }

    /// Timpul regulamentar se derulează în 19 secunde: cronometrul merge până la 90 și golurile apar la minutul lor.
    /// Prelungirile continuă în același ritm (încă ~6 secunde pentru 30 de minute), deci nu se ghicesc dinainte.
    /// Meciurile simultane au același ceas. Dacă meciul s-a decis la penalty-uri, loviturile se derulează în încă 19 secunde.
    private func play(minutes: Double, shootout: Bool) {
        ticker?.cancel()
        progress = 0
        penProgress = 0
        playing = true
        game.revealRunMatch()
        let start = Date()
        let phase = Self.matchSeconds * minutes / 90
        let total = shootout ? phase + Self.matchSeconds : phase
        ticker = Task { @MainActor in
            while !Task.isCancelled {
                let t = Date().timeIntervalSince(start)
                progress = min(1, t / phase)
                penProgress = shootout ? max(0, min(1, (t - phase) / Self.matchSeconds)) : 1
                if t >= total { break }
                try? await Task.sleep(nanoseconds: 50_000_000)
            }
            if !Task.isCancelled { withAnimation(.easeInOut(duration: 0.25)) { playing = false } }
        }
    }

    private func finish() {
        ticker?.cancel()
        progress = 1
        penProgress = 1
        withAnimation(.easeInOut(duration: 0.25)) { playing = false }
    }
}

/// O eliminare: t = 1 dacă e jucătorul echipei 1 (stânga), 0 al echipei 2.
struct RedCardEvent: Hashable {
    let m: String
    let t: Int
    let n: String
    /// al doilea galben (altfel roșu direct)
    let secondYellow: Bool

    var base: Int { Int(m.split(separator: "+").first ?? "") ?? 0 }
    var clock: Double {
        let extra = m.contains("+") ? Int(m.split(separator: "+").last ?? "") ?? 0 : 0
        return Double(base) + Double(min(extra, 9)) / 10
    }
}

/// Un penalty ratat în timpul jocului: t = 1 pentru echipa 1 (stânga); `keeper` gol = pe lângă / bară / peste.
struct MissedPenalty: Hashable {
    let m: String
    let t: Int
    let n: String
    let keeper: String

    var clock: Double {
        let base = Double(Int(m.split(separator: "+").first ?? "") ?? 0)
        let extra = m.contains("+") ? Int(m.split(separator: "+").last ?? "") ?? 0 : 0
        return base + Double(min(extra, 9)) / 10
    }
}

/// O lovitură de la departajare.
struct ShootoutKick: Hashable {
    let t: Int
    let n: String
    let scored: Bool
}

/// Eliminările și loviturile de departajare ale unui meci din calendar (`MatchEventsData`).
struct MatchEvents {
    var reds: [RedCardEvent] = []
    var kicks: [ShootoutKick] = []
    var misses: [MissedPenalty] = []

    static func of(year: Int, index: Int) -> MatchEvents {
        var out = MatchEvents()
        guard let s = MatchEventsData.byYear[year]?[index] else { return out }
        for item in s.split(separator: ";") {
            let p = item.split(separator: "|", omittingEmptySubsequences: false).map(String.init)
            if p.first == "R", p.count >= 5 {
                out.reds.append(RedCardEvent(m: p[1], t: Int(p[2]) ?? 0, n: p[3], secondYellow: p[4] == "2"))
            } else if p.first == "M", p.count >= 5 {
                out.misses.append(MissedPenalty(m: p[1], t: Int(p[2]) ?? 0, n: p[3], keeper: p[4]))
            } else if p.first == "K", p.count >= 4 {
                out.kicks.append(ShootoutKick(t: Int(p[1]) ?? 0, n: p[2], scored: p[3] == "1"))
            }
        }
        return out
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
    var events = MatchEvents()
    /// derularea loviturilor de departajare (după fluierul final)
    var penProgress: Double = 1
    /// cine merge mai departe / locul 3 / campioana (nil în grupe)
    var verdict: MatchVerdict?
    /// mai multe meciuri pe același ecran: card mai mic
    var compact = false
    /// titlul cardului („Grupa A”); implicit faza meciului
    var title: String? = nil

    /// loviturile în ordine alternativă: echipa 1, echipa 2, echipa 1…
    private var orderedKicks: [ShootoutKick] {
        let h = events.kicks.filter { $0.t == 1 }, a = events.kicks.filter { $0.t == 0 }
        var out: [ShootoutKick] = []
        for i in 0..<max(h.count, a.count) {
            if i < h.count { out.append(h[i]) }
            if i < a.count { out.append(a[i]) }
        }
        return out
    }
    private var kicksShown: Int {
        let n = orderedKicks.count
        return penProgress >= 1 ? n : min(n, Int(penProgress * Double(n + 1)))
    }
    private var inShootout: Bool { playing && progress >= 1 && !events.kicks.isEmpty }

    private enum Moment: Hashable {
        case goal(TrackGoal)
        case red(RedCardEvent)
        case miss(MissedPenalty)
        var clock: Double {
            switch self {
            case .goal(let g): return g.clock
            case .red(let r): return r.clock
            case .miss(let p): return p.clock
            }
        }
    }

    private var totalMinutes: Double { match.hadExtraTime ? 120 : 90 }
    private var minuteNow: Double { progress * totalMinutes }
    private var goals: [TrackGoal] { match.goals ?? [] }
    private var visibleGoals: [TrackGoal] {
        progress >= 1 ? goals : goals.filter { $0.clock <= minuteNow }
    }
    /// golurile și eliminările petrecute până acum, în ordinea minutelor
    private var moments: [Moment] {
        let reds = events.reds.filter { progress >= 1 || $0.clock <= minuteNow }
        let misses = events.misses.filter { progress >= 1 || $0.clock <= minuteNow }
        let all = visibleGoals.map(Moment.goal) + reds.map(Moment.red) + misses.map(Moment.miss)
        return all.enumerated().sorted { a, b in
            a.element.clock != b.element.clock ? a.element.clock < b.element.clock : a.offset < b.offset
        }.map(\.element)
    }
    private var score: (Int, Int) {
        guard revealed else { return (0, 0) }
        if progress >= 1 { return (match.gf, match.ga) }
        let v = visibleGoals
        return (v.filter { $0.t == 1 }.count, v.filter { $0.t == 0 }.count)
    }
    private var clockText: String {
        if !revealed { return tr("Înainte de meci", "Kick-off soon") }
        if inShootout { return tr("Lovituri de departajare", "Penalty shoot-out") }
        if progress >= 1 { return match.hadExtraTime ? tr("Final · după prelungiri", "Full time · after extra time") : tr("Final", "Full time") }
        return "\(max(1, Int(minuteNow.rounded(.up))))'"
    }

    var body: some View {
        let a = game.data.meta(team), b = game.data.meta(match.opp)
        let sc = score
        let shown = moments
        VStack(spacing: 10) {
            Text((title ?? match.round).uppercased()).font(.scoreboard(15, weight: .semibold)).foregroundStyle(Color.hwcGold)
            HStack(alignment: .center) {
                VStack(spacing: 4) {
                    Text(a.flag).font(.system(size: compact ? 32 : 44))
                    Text(a.name).font(.system(size: 13, weight: .semibold)).multilineTextAlignment(.center).lineLimit(2)
                }
                .frame(maxWidth: .infinity)
                Text(revealed ? "\(sc.0) - \(sc.1)" : "? - ?")
                    .font(.stat(compact ? 32 : 40, weight: .bold))
                    .foregroundStyle(revealed ? Color.hwcRed : Color.hwcTextDim)
                    .contentTransition(.numericText())
                    .animation(.spring(duration: 0.35), value: sc.0 + sc.1)
                    .lineLimit(1)
                    .fixedSize()
                    .layoutPriority(1)
                VStack(spacing: 4) {
                    Text(b.flag).font(.system(size: compact ? 32 : 44))
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
                if inShootout {
                    ProgressView(value: penProgress).tint(Color.hwcGold)
                } else {
                    HalvesBar(minute: minuteNow, extraTime: match.hadExtraTime)
                }
            }

            if revealed && !shown.isEmpty {
                VStack(spacing: 4) {
                    ForEach(Array(shown.enumerated()), id: \.offset) { _, moment in
                        Group {
                            switch moment {
                            case .goal(let g): GoalLine(goal: g)
                            case .red(let r): RedCardLine(card: r)
                            case .miss(let p): MissedPenaltyLine(penalty: p)
                            }
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .animation(.easeOut(duration: 0.3), value: shown.count)
            }

            if revealed && progress >= 1 && !events.kicks.isEmpty {
                ShootoutView(kicks: Array(orderedKicks.prefix(kicksShown)))
                    .animation(.easeOut(duration: 0.3), value: kicksShown)
            }

            if revealed && progress >= 1 && !playing {
                // „penalty-uri 4-5” e deja în titlul loviturilor de departajare
                if let note = match.note, events.kicks.isEmpty || !note.contains("penalt") {
                    Text(note).font(.system(size: 13)).foregroundStyle(Color.white.opacity(0.75))
                }
                if let verdict {
                    VerdictView(verdict: verdict)
                        .transition(.scale.combined(with: .opacity))
                }
                Text(tr("📜 Rezultat real", "📜 Real result")).font(.system(size: 11)).foregroundStyle(Color.white.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(compact ? 12 : 16)
        .background(Color.black.opacity(0.85), in: RoundedRectangle(cornerRadius: 14))
        .sensoryFeedback(.impact(weight: .medium), trigger: shown.count + kicksShown)
    }
}

/// Bara de derulare a meciului, împărțită pe reprize: 45' + 45'; prelungirile 15' + 15' se adaugă după minutul 90.
struct HalvesBar: View {
    let minute: Double
    let extraTime: Bool

    var body: some View {
        // prelungirile apar abia după fluierul final al timpului regulamentar (doar la meciurile care le-au avut)
        let parts: [(start: Double, len: Double)] = extraTime && minute >= 90 ? [(0, 45), (45, 45), (90, 15), (105, 15)] : [(0, 45), (45, 45)]
        let total = parts.reduce(0) { $0 + $1.len }
        let gap: CGFloat = 5
        GeometryReader { geo in
            let usable = geo.size.width - gap * CGFloat(parts.count - 1)
            HStack(spacing: gap) {
                ForEach(Array(parts.enumerated()), id: \.offset) { i, part in
                    let fill = max(0, min(1, (minute - part.start) / part.len))
                    let w = usable * CGFloat(part.len / total)
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.white.opacity(0.18))
                        Capsule().fill(i < 2 ? Color.hwcGold : Color.hwcGold2)
                            .frame(width: w * CGFloat(fill))
                    }
                    .frame(width: w)
                }
            }
        }
        .frame(height: 6)
        .animation(.easeInOut(duration: 0.4), value: parts.count)
        .accessibilityElement()
        .accessibilityLabel(extraTime ? tr("Două reprize și prelungiri", "Two halves and extra time") : tr("Două reprize", "Two halves"))
        .accessibilityValue("\(Int(minute))'")
    }
}

/// O eliminare în cardul meciului, de partea echipei jucătorului.
struct RedCardLine: View {
    let card: RedCardEvent

    var body: some View {
        let kind = card.secondYellow ? tr(" (al doilea galben)", " (second yellow)") : ""
        HStack(spacing: 6) {
            if card.t == 0 { Spacer(minLength: 0) }
            Text(card.secondYellow ? "🟨🟥" : "🟥").font(.system(size: 12))
            Text("\(card.m)'").font(.stat(13, weight: .bold))
            Text(card.n + kind).font(.system(size: 13)).lineLimit(1).minimumScaleFactor(0.7)
            if card.t == 1 { Spacer(minLength: 0) }
        }
        .foregroundStyle(Color.white.opacity(0.9))
    }
}

/// Un penalty ratat în cardul meciului: „❌ 39' Messi — penalty apărat de Szczęsny”.
struct MissedPenaltyLine: View {
    let penalty: MissedPenalty

    var body: some View {
        let how = penalty.keeper.isEmpty
            ? tr(" (penalty ratat)", " (missed penalty)")
            : tr(" (penalty apărat de \(penalty.keeper))", " (penalty saved by \(penalty.keeper))")
        HStack(spacing: 6) {
            if penalty.t == 0 { Spacer(minLength: 0) }
            Text("❌").font(.system(size: 12))
            Text("\(penalty.m)'").font(.stat(13, weight: .bold))
            Text(penalty.n + how).font(.system(size: 13)).lineLimit(1).minimumScaleFactor(0.65)
            if penalty.t == 1 { Spacer(minLength: 0) }
        }
        .foregroundStyle(Color.white.opacity(0.8))
    }
}

/// Loviturile de departajare, în ordinea bătăii (echipa 1 la stânga), cu scorul la zi.
struct ShootoutView: View {
    let kicks: [ShootoutKick]

    var body: some View {
        let h = kicks.filter { $0.t == 1 && $0.scored }.count, a = kicks.filter { $0.t == 0 && $0.scored }.count
        VStack(spacing: 4) {
            Text(tr("LOVITURI DE DEPARTAJARE", "PENALTY SHOOT-OUT") + "  \(h) – \(a)")
                .font(.scoreboard(13, weight: .semibold)).foregroundStyle(Color.hwcGold)
                .contentTransition(.numericText())
            ForEach(Array(kicks.enumerated()), id: \.offset) { _, k in
                HStack(spacing: 5) {
                    if k.t == 0 { Spacer(minLength: 0) }
                    Text(k.scored ? "✅" : "❌").font(.system(size: 11))
                    Text(k.n).font(.system(size: 12)).strikethrough(!k.scored, color: Color.hwcRed)
                        .foregroundStyle(k.scored ? Color.white : Color.white.opacity(0.6))
                        .lineLimit(1).minimumScaleFactor(0.7)
                    if k.t == 1 { Spacer(minLength: 0) }
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(.top, 4)
    }
}

/// Deznodământul unui meci eliminatoriu (în grupe nu se afișează nimic).
enum MatchVerdict: Equatable {
    case advances(String)
    case replay
    case third(String)
    case champion(String)

    static let thirdLabels: Set<String> = ["Finala mică", "Third place"]

    var isChampion: Bool {
        if case .champion = self { return true }
        return false
    }

    static func of(run: RealRun, index: Int, match m: TrackMatch, data: GameData) -> MatchVerdict? {
        let home = run.fixtures[index].home, away = run.fixtures[index].away
        // ultimul meci al turneului: campioana (inclusiv 1950, decis în grupa finală)
        if index == run.fixtures.count - 1, let champ = data.tracks(year: run.year).first(where: { $0.finish == "champion" }) {
            return .champion(champ.code)
        }
        guard !StageBoard.groupLabels.contains(m.round) else { return nil }
        var winner: String?
        if m.gf != m.ga {
            winner = m.gf > m.ga ? home : away
        } else if let p = StageBoard.penalties(m.note) {
            winner = p.0 > p.1 ? home : away
        }
        guard let winner else { return .replay }
        return thirdLabels.contains(m.round) ? .third(winner) : .advances(winner)
    }
}

struct VerdictView: View {
    @EnvironmentObject var game: GameState
    let verdict: MatchVerdict

    var body: some View {
        switch verdict {
        case .advances(let code):
            let t = game.data.meta(code)
            Text(tr("➡️ \(t.flag) \(t.name) merge mai departe", "➡️ \(t.flag) \(t.name) goes through"))
                .font(.scoreboard(17, weight: .semibold)).foregroundStyle(Color.hwcPitch2)
                .multilineTextAlignment(.center)
        case .replay:
            Text(tr("Egal — meciul se rejoacă", "A draw — the match will be replayed"))
                .font(.scoreboard(16, weight: .semibold)).foregroundStyle(Color.hwcGold)
        case .third(let code):
            let t = game.data.meta(code)
            Text(tr("🥉 \(t.flag) \(t.name) se clasează pe locul 3", "🥉 \(t.flag) \(t.name) finish third"))
                .font(.scoreboard(17, weight: .semibold)).foregroundStyle(Color.hwcGold)
                .multilineTextAlignment(.center)
        case .champion(let code):
            let t = game.data.meta(code)
            VStack(spacing: 6) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 54))
                    .foregroundStyle(LinearGradient(colors: [Color.hwcGold2, Color.hwcGold], startPoint: .top, endPoint: .bottom))
                    .shadow(color: Color.hwcGold.opacity(0.6), radius: 12)
                Text("\(t.flag) \(t.name)").font(.scoreboard(26)).foregroundStyle(Color.hwcGold2)
                Text(tr("Campioană mondială!", "World champions!")).font(.scoreboard(18, weight: .semibold)).foregroundStyle(Color.white)
            }
            .padding(.vertical, 4)
            .sensoryFeedback(.success, trigger: code)
        }
    }
}

/// Confetti pentru campioană: bucăți colorate care cad peste ecran câteva secunde.
struct ConfettiView: View {
    private struct Piece {
        let x = Double.random(in: 0...1)
        let delay = Double.random(in: 0...1.5)
        let speed = Double.random(in: 0.22...0.42)
        let drift = Double.random(in: 0.02...0.07)
        let phase = Double.random(in: 0...6.28)
        let spin = Double.random(in: 2...7)
        let size = Double.random(in: 7...12)
        let color: Color = [Color.hwcGold, Color.hwcGold2, .red, .green, .blue, .white, .orange].randomElement() ?? .yellow
    }

    @State private var start = Date()
    @State private var pieces = (0..<140).map { _ in Piece() }

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { ctx, size in
                let t = timeline.date.timeIntervalSince(start)
                for p in pieces {
                    let tt = t - p.delay
                    guard tt > 0 else { continue }
                    let y = tt * p.speed * size.height - 20
                    guard y < size.height + 20 else { continue }
                    let x = (p.x + p.drift * sin(tt * 3 + p.phase)) * size.width
                    var c = ctx
                    c.translateBy(x: x, y: y)
                    c.rotate(by: .radians(tt * p.spin))
                    c.fill(Path(CGRect(x: -p.size / 2, y: -p.size / 4, width: p.size, height: p.size / 2)), with: .color(p.color))
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
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
