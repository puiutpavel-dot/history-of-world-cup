import SwiftUI
import WorldCupCore

struct MenuView: View {
    @EnvironmentObject var game: GameState
    @EnvironmentObject var store: Store

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                VStack(spacing: 10) {
                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 27, style: .continuous))
                        .shadow(color: Color.hwcGold.opacity(0.35), radius: 18)
                    Text(tr("ARHIVA\nMONDIALELOR", "FOOTBALL FINALS\nARCHIVE"))
                        .font(.scoreboard(44))
                        .lineLimit(2)
                        .minimumScaleFactor(0.6)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.hwcGold2)
                    Text(tr("Retrăiește fiecare Mondial, meci cu meci — 1930-2026", "Relive every World Cup, match by match — 1930-2026"))
                        .font(.system(size: 15))
                        .foregroundStyle(Color.hwcTextDim)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 50)

                VStack(spacing: 12) {
                    if game.hasResumableRun, let r = game.run {
                        PrimaryButton(title: tr("Continuă: ", "Continue: ") + "\(String(r.year)) · \(r.idx + 1)/\(r.fixtures.count)", systemImage: "play.fill") {
                            game.go(.run)
                        }
                        SecondaryButton(title: tr("Retrăiește un Mondial", "Relive a World Cup"), systemImage: "trophy") { game.go(.editions) }
                    } else {
                        PrimaryButton(title: tr("Retrăiește un Mondial", "Relive a World Cup"), systemImage: "trophy.fill") { game.go(.editions) }
                    }
                    // butoanele secundare în perechi, ca două capsule alăturate
                    HStack(spacing: 12) {
                        SecondaryButton(title: "Quiz", systemImage: "questionmark.circle") { game.go(.quizMenu) }
                        if let t = game.userCountry {
                            SecondaryButton(title: "\(t.flag) \(t.name)", systemImage: "flag") { game.go(.country) }
                        } else {
                            SecondaryButton(title: tr("Țara ta", "Your country"), systemImage: "globe.europe.africa") { game.go(.country) }
                        }
                    }
                    HStack(spacing: 12) {
                        SecondaryButton(title: tr("Muzeul", "Museum"), systemImage: "book") { game.go(.museum) }
                        SecondaryButton(title: tr("Regulile", "Rules"), systemImage: "list.bullet.rectangle") { game.go(.rules) }
                    }
                    HStack(spacing: 12) {
                        SecondaryButton(title: tr("Legende", "Legends"), systemImage: "star") { game.go(.legends) }
                        SecondaryButton(title: tr("Trofee", "Trophies"), systemImage: "archivebox") { game.go(.trophies) }
                    }
                    SecondaryButton(title: tr("Despre și setări", "About & settings"), systemImage: "gearshape") { game.go(.about) }
                }

                if game.fullHistory {
                    Text(tr("✅ Full History — toate edițiile deblocate", "✅ Full History — every edition unlocked"))
                        .font(.system(size: 13)).foregroundStyle(Color.hwcTextDim)
                } else {
                    VStack(spacing: 8) {
                        Button { game.showPaywall() } label: {
                            Text(tr("🔓 Full History — deblochează toate edițiile", "🔓 Full History — unlock every edition") + " (\(store.displayPrice))")
                                .font(.system(size: 14, weight: .semibold)).foregroundStyle(Color.hwcGold)
                        }
                        Button(tr("Restaurează achizițiile", "Restore purchases")) { Task { await store.restore() } }
                            .font(.system(size: 13)).tint(.hwcTextDim)
                        if let m = store.message {
                            Text(m).font(.system(size: 12)).foregroundStyle(Color.hwcTextDim).multilineTextAlignment(.center)
                        }
                    }
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
        ScreenContainer(title: tr("Alege o ediție", "Choose an edition"), backLabel: tr("Meniu", "Menu"), onBack: { game.go(.menu) }) {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(game.data.editions) { ed in
                    Button { game.openEdition(ed.year) } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(ed.year)).font(.scoreboard(30)).foregroundStyle(Color.hwcGold2)
                            Text(ed.host).font(.system(size: 14)).foregroundStyle(Color.hwcText).lineLimit(1)
                            let unlocked = game.isOpen(ed.year)
                            let playable = game.hasRealMatches(ed.year)
                            let caption = !playable ? tr("⏳ Meciurile vin curând", "⏳ Matches coming soon")
                                : unlocked ? "🏆 " + game.label(ed.champion) : "🔒 Full History"
                            Text(caption)
                                .font(.system(size: 13)).foregroundStyle(unlocked || !playable ? Color.hwcTextDim : Color.hwcGold)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color.hwcPanel, in: RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.hwcBorder))
                        .opacity(game.hasRealMatches(ed.year) ? 1 : 0.55)
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
        ScreenContainer(title: "\(String(year)) · \(host)", backLabel: tr("Ediții", "Editions"), onBack: { game.go(.editions) }) {
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
                                if hasRealRoster { Text(tr("👥 lot real", "👥 real squad")) }
                                if hasRealPath { Text(tr("📜 traseu real", "📜 real path")) }
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
