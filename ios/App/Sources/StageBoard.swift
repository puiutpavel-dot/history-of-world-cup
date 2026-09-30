import SwiftUI
import WorldCupCore

// MARK: - După fiecare meci: clasamentul la zi al grupei sau tabloul eliminatoriilor.
// Se folosesc meciurile jucate până acum în calendarul cronologic al ediției (`MatchOrder`).
// Grupa = echipele legate prin meciuri din aceeași fază de grupe. Barajele de grupă
// (1954, 1958 — a doua întâlnire a aceleiași perechi) nu intră în clasament.

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
    /// meciul s-a jucat deja (altfel scorul nu se arată)
    let played: Bool
    let id: String
    /// 1 = a trecut mai departe, -1 = b, 0 = egal (rejucat) sau încă nejucat
    var winner: Int {
        guard played else { return 0 }
        if ga != gb { return ga > gb ? 1 : -1 }
        if let p = pens { return p.0 > p.1 ? 1 : -1 }
        return 0
    }
}

enum StageBoard {
    case group(title: String, rows: [StandingRow], played: Int, total: Int)
    case knockout(rounds: [(title: String, ties: [KnockoutTie])])

    static let groupLabels: Set<String> = ["Grupă", "Grupa a doua", "Grupa finală", "Group", "Second group stage", "Final group"]

    /// clasamentul grupei ultimului meci de pe ecran sau tabloul, cu meciurile jucate până acum
    static func build(data: GameData, run: RealRun) -> StageBoard? {
        let last = run.slot.upperBound - 1
        return build(data: data, run: run, index: last, current: last)
    }

    /// clasamentul grupei meciului `index` sau tabloul, cu meciurile jucate până la `current` inclusiv
    static func build(data: GameData, run: RealRun, index: Int, current: Int) -> StageBoard? {
        let all: [(f: Fixture, m: TrackMatch)?] = run.fixtures.map { f in data.match(f, year: run.year).map { (f: f, m: $0) } }
        guard all.indices.contains(index), all.indices.contains(current), let cur = all[index] else { return nil }
        if groupLabels.contains(cur.m.round) {
            return group(all: all, index: index, current: current, label: cur.m.round, year: run.year, data: data)
        }
        return knockout(all: all, current: current)
    }

    /// după meciurile de pe ecran (unul sau mai multe simultane): câte un clasament pentru fiecare grupă
    /// implicată și, dacă e cazul, tabloul — fiecare o singură dată
    static func boards(data: GameData, run: RealRun) -> [BoardItem] {
        let last = run.slot.upperBound - 1
        var out: [BoardItem] = []
        for i in run.slot {
            guard let b = build(data: data, run: run, index: i, current: last) else { continue }
            let key: String
            switch b {
            case let .group(title, rows, _, _): key = title + rows.map(\.code).sorted().joined()
            case .knockout: key = "knockout"
            }
            if !out.contains(where: { $0.key == key }) { out.append(BoardItem(key: key, board: b)) }
        }
        return out
    }

    private static func group(all: [(f: Fixture, m: TrackMatch)?], index: Int, current: Int, label: String, year: Int, data: GameData) -> StageBoard? {
        guard let cur = all[index] else { return nil }
        // echipele grupei: legate prin meciuri din aceeași fază de grupe
        var comp: Set<String> = [cur.f.home, cur.f.away]
        var grew = true
        while grew {
            grew = false
            for x in all.compactMap({ $0 }) where x.m.round == label && comp.contains(x.f.home) != comp.contains(x.f.away) {
                comp.insert(x.f.home); comp.insert(x.f.away); grew = true
            }
        }
        // meciurile grupei, fără barajele (a doua întâlnire a aceleiași perechi)
        var pairs = Set<String>()
        var games: [(i: Int, f: Fixture, m: TrackMatch)] = []
        for (i, x) in all.enumerated() {
            guard let x, x.m.round == label, comp.contains(x.f.home) else { continue }
            let key = [x.f.home, x.f.away].sorted().joined(separator: "-")
            if pairs.insert(key).inserted { games.append((i, x.f, x.m)) }
        }
        let win = year >= 1994 ? 3 : 2
        var rows = Dictionary(uniqueKeysWithValues: comp.map { ($0, StandingRow(code: $0)) })
        func add(_ code: String, _ gf: Int, _ ga: Int) {
            guard var r = rows[code] else { return }
            r.played += 1; r.gf += gf; r.ga += ga
            if gf > ga { r.won += 1; r.pts += win } else if gf == ga { r.drawn += 1; r.pts += 1 } else { r.lost += 1 }
            rows[code] = r
        }
        let played = games.filter { $0.i <= current }
        for g in played {
            add(g.f.home, g.m.gf, g.m.ga)
            add(g.f.away, g.m.ga, g.m.gf)
        }
        let final = played.count == games.count
        if final, let lastGroup = games.map(\.i).max() {
            // a mers mai departe = mai are un meci într-o altă fază, după grupă
            for code in comp {
                rows[code]?.qualified = all.indices.contains { i in
                    guard i > lastGroup, let x = all[i] else { return false }
                    return x.m.round != label && (x.f.home == code || x.f.away == code)
                }
            }
        }
        let sorted = rows.values.sorted {
            if $0.pts != $1.pts { return $0.pts > $1.pts }
            if $0.gf - $0.ga != $1.gf - $1.ga { return $0.gf - $0.ga > $1.gf - $1.ga }
            if $0.gf != $1.gf { return $0.gf > $1.gf }
            return data.meta($0.code).name < data.meta($1.code).name
        }
        return .group(title: label, rows: sorted, played: played.count, total: games.count)
    }

    /// scorul de la penalty-uri din nota meciului („penalty-uri 4-5” / „penalties 4-5”)
    static func penalties(_ note: String?) -> (Int, Int)? {
        guard let note, note.contains("penalt") else { return nil }
        let nums = note.split(whereSeparator: { !$0.isNumber }).compactMap { Int($0) }
        guard nums.count >= 2 else { return nil }
        return (nums[nums.count - 2], nums[nums.count - 1])
    }

    private static func knockout(all: [(f: Fixture, m: TrackMatch)?], current: Int) -> StageBoard? {
        // fazele eliminatorii ajunse până acum (cea curentă prima); faza curentă apare întreagă,
        // cu meciurile încă nejucate fără scor
        var labels: [String] = []
        for x in all.prefix(current + 1).compactMap({ $0 }) where !groupLabels.contains(x.m.round) && !labels.contains(x.m.round) {
            labels.append(x.m.round)
        }
        let rounds: [(title: String, ties: [KnockoutTie])] = labels.reversed().map { label in
            let ties = all.enumerated().compactMap { i, x -> KnockoutTie? in
                guard let x, x.m.round == label else { return nil }
                return KnockoutTie(a: x.f.home, b: x.f.away, ga: x.m.gf, gb: x.m.ga, pens: penalties(x.m.note),
                                   played: i <= current, id: "\(i)")
            }
            return (label, ties)
        }
        return rounds.isEmpty ? nil : .knockout(rounds: rounds)
    }
}

struct BoardItem: Identifiable {
    let key: String
    let board: StageBoard
    var id: String { key }
}

// MARK: - Afișarea

struct StageBoardView: View {
    @EnvironmentObject var game: GameState
    let board: StageBoard
    /// echipele meciului curent
    let highlight: Set<String>
    /// echipa urmărită
    let focus: String?

    var body: some View {
        switch board {
        case let .group(title, rows, played, total):
            groupTable(title: title, rows: rows, played: played, total: total)
        case let .knockout(rounds):
            bracket(rounds)
        }
    }

    private func groupTable(title: String, rows: [StandingRow], played: Int, total: Int) -> some View {
        let final = played == total
        return Panel(title: "📊 " + title) {
            Text(final ? tr("Clasament final", "Final standings") : tr("Clasament la zi · \(played) din \(total) meciuri jucate", "Live table · \(played) of \(total) matches played"))
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
                let mine = highlight.contains(r.code)
                let followed = r.code == focus
                HStack(spacing: 0) {
                    HStack(spacing: 6) {
                        Text("\(i + 1)").font(.stat(12)).foregroundStyle(Color.hwcTextDim).frame(width: 14)
                        Text(meta.flag).font(.system(size: 16))
                        Text(meta.name).font(.system(size: 14, weight: mine || followed ? .bold : .regular)).lineLimit(1).minimumScaleFactor(0.75)
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
                .padding(.vertical, 2).padding(.horizontal, 4)
                .background(followed ? Color.hwcGold.opacity(0.14) : Color.clear, in: RoundedRectangle(cornerRadius: 6))
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
        let mine = highlight.contains(t.a) && highlight.contains(t.b)
        let followed = t.a == focus || t.b == focus
        return VStack(spacing: 2) {
            HStack(spacing: 6) {
                Text(a.flag).font(.system(size: 15))
                Text(a.name).font(.system(size: 14, weight: t.winner == 1 ? .bold : .regular))
                    .foregroundStyle(t.winner == -1 ? Color.hwcTextDim : Color.hwcText)
                    .lineLimit(1).minimumScaleFactor(0.75)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(t.played ? "\(t.ga) – \(t.gb)" : "– : –").font(.stat(14, weight: .bold))
                    .foregroundStyle(t.played ? Color.hwcText : Color.hwcTextDim)
                    .fixedSize()
                Text(b.name).font(.system(size: 14, weight: t.winner == -1 ? .bold : .regular))
                    .foregroundStyle(t.winner == 1 ? Color.hwcTextDim : Color.hwcText)
                    .lineLimit(1).minimumScaleFactor(0.75)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Text(b.flag).font(.system(size: 15))
            }
            if t.played, let p = t.pens {
                Text(tr("penalty-uri \(p.0)–\(p.1)", "penalties \(p.0)–\(p.1)"))
                    .font(.system(size: 11)).foregroundStyle(Color.hwcTextDim)
            }
        }
        .padding(.vertical, 5).padding(.horizontal, 8)
        .background(mine ? Color.hwcGold.opacity(0.22) : followed ? Color.hwcGold.opacity(0.1) : Color.clear, in: RoundedRectangle(cornerRadius: 8))
    }
}
