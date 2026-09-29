import SwiftUI
import WorldCupCore

struct MuseumView: View {
    @EnvironmentObject var game: GameState
    @State private var open: Int?

    var body: some View {
        ScreenContainer(title: "📖 Muzeul Edițiilor", backLabel: "Meniu", onBack: { game.go(.menu) }) {
            VStack(spacing: 10) {
                ForEach(game.data.editions) { ed in
                    VStack(alignment: .leading, spacing: 0) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { open = open == ed.year ? nil : ed.year }
                        } label: {
                            HStack {
                                Text(String(ed.year)).font(.scoreboard(22)).foregroundStyle(Color.hwcGold2)
                                Text(ed.host).font(.system(size: 15)).foregroundStyle(Color.hwcText)
                                Spacer()
                                Image(systemName: open == ed.year ? "chevron.up" : "chevron.down").foregroundStyle(Color.hwcTextDim)
                            }
                            .padding(14)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        if open == ed.year {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("🏆 Campioană: **\(game.label(ed.champion))**")
                                Text("🥈 Finalistă: \(game.label(ed.runnerUp)) · 🥉 Locul 3: \(game.label(ed.third))")
                                Text("⚽ Golgheter: \(ed.topScorer)")
                                Text("🔴 Minge oficială: \(ed.ball)")
                                Text(ed.note).italic().foregroundStyle(Color.hwcTextDim)
                            }
                            .font(.system(size: 14))
                            .foregroundStyle(Color.hwcText)
                            .padding([.horizontal, .bottom], 14)
                            .transition(.opacity)
                        }
                    }
                    .background(Color.hwcPanel, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.hwcBorder))
                }
            }
        }
    }
}

struct LegendsView: View {
    @EnvironmentObject var game: GameState
    let columns = [GridItem(.adaptive(minimum: 280), spacing: 12)]

    var body: some View {
        ScreenContainer(title: "⭐ Galeria Legendelor", backLabel: "Meniu", onBack: { game.go(.menu) }) {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(game.data.legends) { l in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(l.name).font(.scoreboard(22)).foregroundStyle(Color.hwcGold2)
                        Text("\(game.label(l.team)) · \(String(l.yearTag))").font(.system(size: 13)).foregroundStyle(Color.hwcTextDim)
                        Text(l.bio).font(.system(size: 14)).foregroundStyle(Color.hwcText).fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color.hwcPanel, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.hwcBorder))
                }
            }
        }
    }
}

struct TrophyRoomView: View {
    @EnvironmentObject var game: GameState

    var body: some View {
        ScreenContainer(title: "🗄️ Sala Trofeelor", backLabel: "Meniu", onBack: { game.go(.menu) }) {
            VStack(spacing: 10) {
                if game.trophies.isEmpty {
                    Text("Nicio carieră încheiată încă — începe una din Meniu!")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.hwcTextDim)
                        .padding(.top, 30)
                } else {
                    let titles = game.trophies.filter { $0.outcome == .champion }.count
                    Text("🏆 Titluri mondiale: \(titles) · Cariere: \(game.trophies.count)")
                        .font(.scoreboard(18, weight: .semibold))
                        .foregroundStyle(Color.hwcGold2)
                    ForEach(game.trophies) { t in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(game.label(t.team)) · CM \(String(t.year))").font(.system(size: 15, weight: .medium))
                                Text(t.date, style: .date).font(.system(size: 12)).foregroundStyle(Color.hwcTextDim)
                            }
                            Spacer()
                            Text(t.label).font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(t.outcome == .champion ? Color.hwcGold2 : Color.hwcTextDim)
                        }
                        .foregroundStyle(Color.hwcText)
                        .padding(12)
                        .background(Color.hwcPanel, in: RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
    }
}
