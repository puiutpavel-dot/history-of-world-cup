import SwiftUI
import WorldCupCore

@main
struct HistoryOfWorldCupApp: App {
    @StateObject private var game: GameState
    @StateObject private var store: Store

    init() {
        // limba se fixează înainte de încărcarea datelor: română pe telefoanele în română, engleză în rest
        // (`-demoLang ro|en` forțează limba pentru capturile din CI)
        let args = ProcessInfo.processInfo.arguments
        if let i = args.firstIndex(of: "-demoLang"), i + 1 < args.count {
            AppLanguage.code = args[i + 1]
        } else {
            AppLanguage.code = AppLanguage.resolve(Bundle.main.preferredLocalizations)
        }
        _game = StateObject(wrappedValue: GameState())
        _store = StateObject(wrappedValue: Store(useStoreKit: !args.contains("-demoScreen")))
    }
    @AppStorage("hwc_theme_v1") private var themeRaw = AppTheme.dark.rawValue

    var body: some Scene {
        WindowGroup {
            let theme = AppTheme(rawValue: themeRaw) ?? .dark
            RootView()
                .environmentObject(game)
                .environmentObject(store)
                .onReceive(store.$isUnlocked) { game.setStoreUnlocked($0) }
                .environment(\.locale, Locale(identifier: AppLanguage.isRomanian ? "ro_RO" : "en_US"))
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
                    .accessibilityLabel(tr("Schimbă tema", "Change theme"))
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
            case .teams(let year): RunTeamSelectView(year: year)
            case .hub: HubView()
            case .preview: MatchPreviewView()
            case .live: MatchLiveView()
            case .groupTable: GroupTableView()
            case .summary: CareerSummaryView()
            case .museum: MuseumView()
            case .legends: LegendsView()
            case .trophies: TrophyRoomView()
            case .rules: RulesView()
            case .quizMenu: QuizMenuView()
            case .quiz: QuizPlayView()
            case .quizResult: QuizResultView()
            case .country: CountryView()
            case .paywall: PaywallView()
            case .about: AboutView()
            case .run: RunView()
            case .runSummary: RunSummaryView()
            }
        }
        .transition(.opacity)
    }
}
