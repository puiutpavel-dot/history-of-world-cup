import SwiftUI
import WorldCupCore

// MARK: - După fiecare meci: clasamentul grupei (până la etapa jucată) sau tabloul eliminatoriilor.
// Totul se reconstruiește din traseele reale ale echipelor din ediția respectivă:
// grupa = echipele legate prin meciuri din aceeași fază de grupe; etapa unui meci = al câtelea
// meci din grupă era pentru fiecare dintre cele două echipe. Barajele de grupă (1954, 1958 —
// a doua întâlnire a aceleiași perechi) nu intră în clasament.

struct StandingRow: Identifiable {
    let code: String
    var played = 0, won = 0, drawn = 0, lost = 0, gf = 0, ga = 0, pts = 0
    var qualified = false
    var id: String { code }
}

struct KnockoutTie: Identifiable {
    let a: String, b: String
    let ga: Int, gb: Int
    let pens: (Int, Int)?
    let id: String
    /// 1 = a trecut mai departe, -1 = b, 0 = egal (rejucat)
    var winner: Int {
        if ga != gb { return ga > gb ? 1 : -1 }
        if let p = pens { return p.0 > p.1 ? 1 : -1 }
        return 0
    }
}

enum StageBoard {
    case group(title: String, rows: [StandingRow], day: Int, final: Bool)
    case knockout(rounds: [(title: String, ties: [KnockoutTie])])

    static let groupLabels: Set<String> = ["Grupă", "Grupa a doua", "Grupa finală", "Group", "Second group stage", "Final group"]

    static func build(data: GameData, team: String, year: Int, index: Int) -> StageBoard? {
        var tracks: [String: TrackEntry] = [:]
        for c in data.countries { for e in c.entries where e.year == year && tracks[e.code] == nil { tracks[e.code] = e } }
        guard let me = tracks[team], me.matches.indices.contains(index) else { return nil }
        let m = me.matches[index]
        if groupLabels.contains(m.round) {
            return group(tracks: tracks, team: team, year: year, index: index, label: m.round, data: data)
        }
        return knockout(tracks: tracks, team: team, index: index, data: data)
    }

    /// meciurile din faza de grupe `label` ale unei echipe, cu etapa (nil = baraj)
    private static func groupMatches(_ e: TrackEntry?, _ label: String) -> [(day: Int?, m: TrackMatch)] {
        var seen = Set<String>(), k = 0
        var out: [(Int?, TrackMatch)] = []
        for x in e?.matches ?? [] where x.round == label {
            if seen.contains(x.opp) { out.append((nil, x)) } else { seen.insert(x.opp); k += 1; out.append((k, x)) }
        }
        return out
    }

    private static func group(tracks: [String: TrackEntry], team: String, year: Int, index: Int, label: String, data: GameData) -> StageBoard? {
        guard let me = tracks[team] else { return nil }
        // etapa meciului curent (un baraj = după toate etapele)
        let before = me.matches.prefix(index + 1).filter { $0.round == label }
        let mine = groupMatches(me, label)
        let current = mine.indices.contains(before.count - 1) ? (mine[before.count - 1].day ?? Int.max) : Int.max

        // echipele grupei
        var comp: [String] = [team], queue = [team]
        while let c = queue.popLast() {
            for x in groupMatches(tracks[c], label) where !comp.contains(x.m.opp) {
                comp.append(x.m.opp); queue.append(x.m.opp)
            }
        }
        let win = year >= 1994 ? 3 : 2
        var maxDay = 0
        var rows: [StandingRow] = comp.map { code in
            var r = StandingRow(code: code)
            for x in groupMatches(tracks[code], label) {
                guard let d = x.day else { continue }
                maxDay = max(maxDay, d)
                let oppDay = groupMatches(tracks[x.m.opp], label).first { $0.m.opp == code && $0.day != nil }?.day ?? d
                guard max(d, oppDay) <= current else { continue }
                r.played += 1; r.gf += x.m.gf; r.ga += x.m.ga
                if x.m.gf > x.m.ga { r.won += 1; r.pts += win } else if x.m.gf == x.m.ga { r.drawn += 1; r.pts += 1 } else { r.lost += 1 }
            }
            return r
        }
        let final = current >= maxDay
        if final {
            for i in rows.indices {
                let ms = tracks[rows[i].code]?.matches ?? []
                if let last = ms.lastIndex(where: { $0.round == label }) { rows[i].qualified = last < ms.count - 1 }
            }
        }
        rows.sort {
            if $0.pts != $1.pts { return $0.pts > $1.pts }
            if $0.gf - $0.ga != $1.gf - $1.ga { return $0.gf - $0.ga > $1.gf - $1.ga }
            if $0.gf != $1.gf { return $0.gf > $1.gf }
            return data.meta($0.code).name < data.meta($1.code).name
        }
        return .group(title: label, rows: rows, day: min(current, maxDay), final: final)
    }

    private static func pens(_ note: String?) -> (Int, Int)? {
        guard let note, note.contains("penalt") else { return nil }
        let nums = note.split(whereSeparator: { !$0.isNumber }).compactMap { Int($0) }
        guard nums.count >= 2 else { return nil }
        return (nums[nums.count - 2], nums[nums.count - 1])
    }

    private static func knockout(tracks: [String: TrackEntry], team: String, index: Int, data: GameData) -> StageBoard? {
        guard let me = tracks[team] else { return nil }
        var labels: [String] = []
        for x in me.matches.prefix(index + 1) where !groupLabels.contains(x.round) && !labels.contains(x.round) { labels.append(x.round) }
        let rounds: [(title: String, ties: [KnockoutTie])] = labels.reversed().map { label in
            var ties: [KnockoutTie] = []
            for code in tracks.keys.sorted() {
                for (i, x) in (tracks[code]?.matches ?? []).enumerated() where x.round == label && code < x.opp {
                    ties.append(KnockoutTie(a: code, b: x.opp, ga: x.gf, gb: x.ga, pens: pens(x.note), id: "\(code)-\(x.opp)-\(i)"))
                }
            }
            // meciul echipei tale primul
            ties.sort { t1, t2 in
                let m1 = t1.a == team || t1.b == team, m2 = t2.a == team || t2.b == team
                return m1 && !m2
            }
            return (label, ties)
        }
        return rounds.isEmpty ? nil : .knockout(rounds: rounds)
    }
}

// MARK: - Afișarea

struct StageBoardView: View {
    @EnvironmentObject var game: GameState
    let board: StageBoard
    let team: String

    var body: some View {
        switch board {
        case let .group(title, rows, day, final):
            groupTable(title: title, rows: rows, day: day, final: final)
        case let .knockout(rounds):
            bracket(rounds)
        }
    }

    private func groupTable(title: String, rows: [StandingRow], day: Int, final: Bool) -> some View {
        Panel(title: "📊 " + title) {
            Text(final ? tr("Clasament final", "Final standings") : tr("Clasament după etapa \(day)", "Standings after matchday \(day)"))
                .font(.system(size: 12)).foregroundStyle(Color.hwcTextDim)
            HStack(spacing: 0) {
                Text("").frame(maxWidth: .infinity, alignment: .leading)
                ForEach([tr("J", "P"), tr("V", "W"), tr("E", "D"), tr("Î", "L")], id: \.self) { h in
                    Text(h).frame(width: 24)
                }
                Text(tr("Gol", "Goals")).frame(width: 46)
                Text(tr("Pct", "Pts")).frame(width: 34)
            }
            .font(.stat(11, weight: .bold)).foregroundStyle(Color.hwcTextDim)
            ForEach(Array(rows.enumerated()), id: \.element.id) { i, r in
                let meta = game.data.meta(r.code)
                let mine = r.code == team
                HStack(spacing: 0) {
                    HStack(spacing: 6) {
                        Text("\(i + 1)").font(.stat(12)).foregroundStyle(Color.hwcTextDim).frame(width: 14)
                        Text(meta.flag).font(.system(size: 16))
                        Text(meta.name).font(.system(size: 14, weight: mine ? .bold : .regular)).lineLimit(1).minimumScaleFactor(0.75)
                        if r.qualified { Image(systemName: "checkmark.circle.fill").font(.system(size: 11)).foregroundStyle(Color.hwcPitch2) }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Group {
                        Text("\(r.played)").frame(width: 24)
                        Text("\(r.won)").frame(width: 24)
                        Text("\(r.drawn)").frame(width: 24)
                        Text("\(r.lost)").frame(width: 24)
                        Text("\(r.gf):\(r.ga)").frame(width: 46)
                    }
                    .font(.stat(13))
                    Text("\(r.pts)").font(.stat(14, weight: .bold)).frame(width: 34)
                }
                .foregroundStyle(mine ? Color.hwcGold : Color.hwcText)
                .padding(.vertical, 2)
            }
            if final && rows.contains(where: \.qualified) {
                Text(tr("✓ a mers mai departe", "✓ went through"))
                    .font(.system(size: 11)).foregroundStyle(Color.hwcTextDim)
            }
        }
    }

    private func bracket(_ rounds: [(title: String, ties: [KnockoutTie])]) -> some View {
        Panel(title: tr("🏆 Tabloul eliminatoriilor", "🏆 Knockout bracket")) {
            ForEach(Array(rounds.enumerated()), id: \.offset) { ri, round in
                Text(round.title.uppercased())
                    .font(.scoreboard(13, weight: .semibold))
                    .foregroundStyle(ri == 0 ? Color.hwcGold : Color.hwcTextDim)
                    .padding(.top, ri == 0 ? 0 : 6)
                ForEach(round.ties) { t in tieRow(t) }
            }
        }
    }

    private func tieRow(_ t: KnockoutTie) -> some View {
        let a = game.data.meta(t.a), b = game.data.meta(t.b)
        let mine = t.a == team || t.b == team
        return VStack(spacing: 2) {
            HStack(spacing: 6) {
                Text(a.flag).font(.system(size: 15))
                Text(a.name).font(.system(size: 14, weight: t.winner == 1 ? .bold : .regular))
                    .foregroundStyle(t.winner == -1 ? Color.hwcTextDim : Color.hwcText)
                    .lineLimit(1).minimumScaleFactor(0.75)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(t.ga) – \(t.gb)").font(.stat(14, weight: .bold)).foregroundStyle(Color.hwcText)
                    .fixedSize()
                Text(b.name).font(.system(size: 14, weight: t.winner == -1 ? .bold : .regular))
                    .foregroundStyle(t.winner == 1 ? Color.hwcTextDim : Color.hwcText)
                    .lineLimit(1).minimumScaleFactor(0.75)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Text(b.flag).font(.system(size: 15))
            }
            if let p = t.pens {
                Text(tr("penalty-uri \(p.0)–\(p.1)", "penalties \(p.0)–\(p.1)"))
                    .font(.system(size: 11)).foregroundStyle(Color.hwcTextDim)
            }
        }
        .padding(.vertical, 5).padding(.horizontal, 8)
        .background(mine ? Color.hwcGold.opacity(0.14) : Color.clear, in: RoundedRectangle(cornerRadius: 8))
    }
}
