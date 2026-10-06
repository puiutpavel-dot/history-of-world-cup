import SwiftUI
import WorldCupCore

struct MuseumView: View {
    @EnvironmentObject var game: GameState
    @State private var open: Int?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScreenContainer(title: tr("📖 Muzeul Edițiilor", "📖 Museum of Editions"), backLabel: tr("Meniu", "Menu"), onBack: { game.go(.menu) }) {
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
                                // vitrina 3D: mingea epocii și tricoul campioanei
                                Museum3DView(year: ed.year, champion: ed.champion, rotate: !reduceMotion)
                                    .id(ed.year)
                                    .frame(height: 190)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.black.opacity(0.25), in: RoundedRectangle(cornerRadius: 10))
                                    .accessibilityHidden(true)
                                Text(LocalizedStringKey(tr("🏆 Campioană: ", "🏆 Champions: ") + "**\(game.label(ed.champion))**"))
                                Text(tr("🥈 Finalistă: ", "🥈 Runners-up: ") + game.label(ed.runnerUp) + tr(" · 🥉 Locul 3: ", " · 🥉 Third: ") + game.label(ed.third))
                                Text(tr("⚽ Golgheter: ", "⚽ Top scorer: ") + ed.topScorer)
                                Text(tr("🔴 Minge oficială: ", "🔴 Match ball: ") + ed.ball)
                                Text(ed.note).italic().foregroundStyle(Color.hwcTextDim)
                                if let f = game.data.formats[ed.year] {
                                    Text(LocalizedStringKey("📋 **Format:** " + f.summary))
                                    Text(rulesLine(f)).foregroundStyle(Color.hwcTextDim)
                                }
                                if let st = game.data.story(ed.year) {
                                    StoryView(story: st)
                                }
                                SecondaryButton(title: game.quizButtonTitle(ed.year),
                                                systemImage: "questionmark.circle") { game.startQuiz(.edition, year: ed.year) }
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
                Text(LocalizedStringKey(tr("Rezultatele meciurilor reale: [Fjelstul World Cup Database](https://www.github.com/jfjelstul/worldcup) © 2023 Joshua C. Fjelstul, Ph.D., licență [CC-BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/legalcode) (date adaptate). Loturi: Wikipedia, „FIFA World Cup squads”.", "Real match results: [Fjelstul World Cup Database](https://www.github.com/jfjelstul/worldcup) © 2023 Joshua C. Fjelstul, Ph.D., licensed [CC-BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/legalcode) (adapted data). Squads: Wikipedia, \"FIFA World Cup squads\".")))
                    .font(.system(size: 11))
                    .foregroundStyle(Color.hwcTextDim)
                    .tint(.hwcGold)
                    .padding(.top, 8)
            }
        }
        .onAppear { if open == nil { open = game.museumOpenYear } }
    }
}

/// Regulile de pe teren ale ediției, pe scurt — `rulesLine(fmt)` din app.js.
func rulesLine(_ f: TournamentFormat) -> String {
    var parts: [String] = []
    if f.subs == 0 {
        parts.append(tr("Fără schimbări: un accidentat lasă echipa în 10", "No substitutions: an injury leaves the team with 10"))
    } else {
        var s = tr("\(f.subs) schimbări", "\(f.subs) substitutions")
        if f.gkSub ?? false { s += tr(" (+1 pentru portar)", " (+1 for the goalkeeper)") }
        if let et = f.etSub, et > 0 { s += tr(" (+\(et) în prelungiri)", " (+\(et) in extra time)") }
        parts.append(s)
    }
    switch f.cards {
    case "none": parts.append(tr("fără cartonașe", "no cards"))
    case "accumulate": parts.append(tr("2 galbene = suspendare, tot turneul", "2 yellows = suspension, whole tournament"))
    default: parts.append(tr("galbenele se șterg după grupe", "yellows wiped after the groups"))
    }
    if f.goldenGoal ?? false { parts.append(tr("gol de aur în prelungiri", "golden goal in extra time")) }
    if f.stages.contains(where: { $0.groupExtraTime ?? false }) { parts.append(tr("prelungiri și în grupă", "extra time in the groups too")) }
    if f.fairPlay ?? false { parts.append(tr("fair-play la departajare", "fair play as a tiebreaker")) }
    return "📏 " + parts.joined(separator: " · ")
}

struct StoryView: View {
    let story: EditionStory

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider().overlay(Color.hwcBorder)
            Text(story.context)
            Text(tr("Momente-cheie", "Key moments")).font(.system(size: 14, weight: .bold)).foregroundStyle(Color.hwcGold2)
            ForEach(Array(story.moments.enumerated()), id: \.offset) { _, m in
                HStack(alignment: .top, spacing: 6) {
                    Text("•")
                    Text(m).fixedSize(horizontal: false, vertical: true)
                }
            }
            Text(LocalizedStringKey(tr("🏟️ **Finala:** ", "🏟️ **The final:** ") + story.finalMatch))
            Text(LocalizedStringKey(tr("🧑‍💼 **Antrenor campion:** ", "🧑‍💼 **Winning coach:** ") + story.coach))
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct RulesView: View {
    @EnvironmentObject var game: GameState

    var body: some View {
        ScreenContainer(title: tr("📜 Evoluția regulilor", "📜 How the rules changed"), backLabel: tr("Meniu", "Menu"), onBack: { game.go(.menu) }) {
            VStack(alignment: .leading, spacing: 12) {
                Text(tr("Regulile de pe teren s-au schimbat mai lent decât formatul turneului. Toate sunt aplicate în joc, pentru ediția aleasă.", "The laws on the pitch changed more slowly than the tournament format. All of them are applied in the game, for the edition you pick."))
                    .font(.system(size: 13)).foregroundStyle(Color.hwcTextDim)
                if let h = game.data.history {
                    ForEach(Array(h.rulesTimeline.enumerated()), id: \.offset) { _, era in
                        RulesCard(years: era.years, title: era.title, items: era.items)
                    }
                    RulesCard(years: nil, title: tr("Lotul", "The squad"),
                              items: h.squadRules.map { "**\($0.years) — \($0.size) " + tr("de jucători", "players") + ".** \($0.text)" })
                    RulesCard(years: nil, title: tr("Cele 7 familii de format", "The 7 format families"),
                              items: h.families.map { "**\($0.years):** \($0.text)" })
                    RulesCard(years: nil, title: tr("Câte meciuri joacă campioana", "Matches played by the champions"),
                              items: h.titlePath.map { "**\($0.years):** \($0.games) " + tr("meciuri", "matches") })
                }
            }
        }
    }
}

struct RulesCard: View {
    let years: String?
    let title: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let years { Text(years).font(.stat(12)).foregroundStyle(Color.hwcTextDim) }
            Text(title).font(.scoreboard(20, weight: .semibold)).foregroundStyle(Color.hwcGold2)
            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top, spacing: 6) {
                    Text("•")
                    Text(LocalizedStringKey(item)).fixedSize(horizontal: false, vertical: true)
                }
                .font(.system(size: 14))
                .foregroundStyle(Color.hwcText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.hwcPanel, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.hwcBorder))
    }
}

struct LegendsView: View {
    @EnvironmentObject var game: GameState
    let columns = [GridItem(.adaptive(minimum: 280), spacing: 12)]

    var body: some View {
        ScreenContainer(title: tr("⭐ Galeria Legendelor", "⭐ Hall of Legends"), backLabel: tr("Meniu", "Menu"), onBack: { game.go(.menu) }) {
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
        ScreenContainer(title: tr("🗄️ Sala Trofeelor", "🗄️ Trophy Room"), backLabel: tr("Meniu", "Menu"), onBack: { game.go(.menu) }) {
            VStack(spacing: 10) {
                if game.trophies.isEmpty {
                    Text(tr("Nicio carieră încheiată încă — începe una din Meniu!", "No finished careers yet — start one from the Menu!"))
                        .font(.system(size: 15))
                        .foregroundStyle(Color.hwcTextDim)
                        .padding(.top, 30)
                } else {
                    let titles = game.trophies.filter { $0.outcome == .champion }.count
                    Text(tr("🏆 Titluri mondiale: \(titles) · Cariere: \(game.trophies.count)", "🏆 World titles: \(titles) · Careers: \(game.trophies.count)"))
                        .font(.scoreboard(18, weight: .semibold))
                        .foregroundStyle(Color.hwcGold2)
                    ForEach(game.trophies) { t in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(game.label(t.team)) · \(tr("CM", "WC")) \(String(t.year))").font(.system(size: 15, weight: .medium))
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
