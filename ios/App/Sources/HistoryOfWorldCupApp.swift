import SwiftUI
import WorldCupCore

@main
struct HistoryOfWorldCupApp: App {
    @StateObject private var game = GameState()
    @AppStorage("hwc_theme_v1") private var themeRaw = AppTheme.dark.rawValue

    var body: some Scene {
        WindowGroup {
            let theme = AppTheme(rawValue: themeRaw) ?? .dark
            RootView()
                .environmentObject(game)
                .preferredColorScheme(theme.colorScheme)
                .overlay(alignment: .topTrailing) {
                    Button {
                        themeRaw = theme.next.rawValue
                    } label: {
                        Image(systemName: theme.icon)
                            .font(.system(size: 15, weight: .semibold))
                            .padding(10)
                            .background(Color.hwcPanel2.opacity(0.9), in: Circle())
                    }
                    .tint(.hwcGold)
                    .padding(.trailing, 12)
                    .padding(.top, 4)
                    .accessibilityLabel("Schimbă tema")
                }
        }
    }
}

struct RootView: View {
    @EnvironmentObject var game: GameState

    var body: some View {
        Group {
            switch game.screen {
            case .menu: MenuView()
            case .editions: EditionSelectView()
            case .teams(let year): TeamSelectView(year: year)
            case .hub: HubView()
            case .preview: MatchPreviewView()
            case .live: MatchLiveView()
            case .groupTable: GroupTableView()
            case .summary: CareerSummaryView()
            case .museum: MuseumView()
            case .legends: LegendsView()
            case .trophies: TrophyRoomView()
            }
        }
        .transition(.opacity)
    }
}
