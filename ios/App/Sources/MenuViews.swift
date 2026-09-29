import SwiftUI
import WorldCupCore

struct MenuView: View {
    @EnvironmentObject var game: GameState

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                VStack(spacing: 10) {
                    Text("⚽").font(.system(size: 64))
                    Text("HISTORY OF\nWORLD CUP")
                        .font(.scoreboard(44))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.hwcGold2)
                    Text("Confirmă sau rescrie istoria — 22 ediții, 1930-2022")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.hwcTextDim)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 50)

                VStack(spacing: 12) {
                    if game.hasResumableCareer, let c = game.career {
                        PrimaryButton(title: "Continuă: \(game.label(c.teamCode)) · \(String(c.year))", systemImage: "play.fill") {
                            game.go(.hub)
                        }
                        SecondaryButton(title: "Carieră nouă", systemImage: "trophy") { game.go(.editions) }
                    } else {
                        PrimaryButton(title: "Carieră nouă", systemImage: "trophy.fill") { game.go(.editions) }
                    }
                    SecondaryButton(title: "Muzeul Edițiilor", systemImage: "book") { game.go(.museum) }
                    SecondaryButton(title: "Galeria Legendelor", systemImage: "star") { game.go(.legends) }
                    SecondaryButton(title: "Sala Trofeelor", systemImage: "archivebox") { game.go(.trophies) }
                }
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
        }
        .background(Color.hwcBackground.ignoresSafeArea())
    }
}

struct EditionSelectView: View {
    @EnvironmentObject var game: GameState
    let columns = [GridItem(.adaptive(minimum: 150), spacing: 12)]

    var body: some View {
        ScreenContainer(title: "Alege o ediție", backLabel: "Meniu", onBack: { game.go(.menu) }) {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(game.data.editions) { ed in
                    Button { game.go(.teams(year: ed.year)) } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(ed.year)).font(.scoreboard(30)).foregroundStyle(Color.hwcGold2)
                            Text(ed.host).font(.system(size: 14)).foregroundStyle(Color.hwcText).lineLimit(1)
                            Text("🏆 \(game.label(ed.champion))").font(.system(size: 13)).foregroundStyle(Color.hwcTextDim)
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

struct TeamSelectView: View {
    @EnvironmentObject var game: GameState
    let year: Int
    let columns = [GridItem(.adaptive(minimum: 140), spacing: 12)]

    var body: some View {
        let host = game.data.edition(year)?.host ?? ""
        ScreenContainer(title: "\(String(year)) · \(host)", backLabel: "Ediții", onBack: { game.go(.editions) }) {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(game.engine.eligibleTeams(year)) { team in
                    let hasRealRoster = game.engine.realRoster(team.code, year) != nil
                    let hasRealPath = game.data.campaign(team.code, year) != nil
                    Button { game.startCareer(team: team.code, year: year) } label: {
                        VStack(spacing: 6) {
                            Text(team.flag).font(.system(size: 40))
                            Text(team.name).font(.scoreboard(18, weight: .semibold)).foregroundStyle(Color.hwcText)
                            Text("Rating \(game.engine.teamRating(team.code, year))").font(.stat(12)).foregroundStyle(Color.hwcTextDim)
                            HStack(spacing: 4) {
                                if hasRealRoster { Text("👥 lot real") }
                                if hasRealPath { Text("📜 traseu real") }
                            }
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color.hwcGold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.hwcPanel, in: RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(hasRealPath ? Color.hwcGold : Color.hwcBorder))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
