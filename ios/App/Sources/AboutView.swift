import SwiftUI
import WorldCupCore

/// Linkurile publice ale aplicației (GitHub Pages) — aceleași ca în App Store Connect.
enum AppLinks {
    static var privacy: URL { URL(string: "https://puiutpavel-dot.github.io/history-of-world-cup/" + tr("privacy.html", "privacy-en.html"))! }
    static var support: URL { URL(string: "https://puiutpavel-dot.github.io/history-of-world-cup/" + tr("support.html", "support-en.html"))! }
}

/// Textul de neafiliere — același pe web, în aplicație și în descrierea din App Store.
var unofficialDisclaimer: String { tr("Arhiva Mondialelor este un joc educațional neoficial, creat independent. Nu este afiliat, sponsorizat sau aprobat de FIFA, de organizatorii turneelor sau de vreo federație națională. Numele competițiilor, echipelor și jucătorilor sunt folosite doar descriptiv, în scop istoric. Aplicația nu folosește logouri, embleme, trofee oficiale sau fotografii.", "Football Finals Archive is an unofficial educational game, made independently. It is not affiliated with, sponsored or endorsed by FIFA, the tournament organisers or any national federation. The names of competitions, teams and players are used only descriptively, for historical purposes. The app uses no logos, emblems, official trophies or photographs.") }

// MARK: - Despre și setări

struct AboutView: View {
    @EnvironmentObject var game: GameState
    @EnvironmentObject var store: Store

    var body: some View {
        ScreenContainer(title: tr("ℹ️ Despre și setări", "ℹ️ About & settings"), backLabel: tr("Meniu", "Menu"), onBack: { game.go(.menu) }) {
            VStack(alignment: .leading, spacing: 14) {
                Panel(title: tr("Achiziții", "Purchases")) {
                    Text(store.isUnlocked ? tr("✅ Full History este deblocat pe acest Apple ID.", "✅ Full History is unlocked on this Apple ID.")
                         : tr("Mondialele 1930–1938 sunt gratuite. Restul istoriei se deblochează cu o singură achiziție.", "The 1930–1938 World Cups are free. The rest of history unlocks with a single purchase."))
                        .font(.system(size: 14)).foregroundStyle(Color.hwcText)
                    if !store.isUnlocked {
                        PrimaryButton(title: "Full History", systemImage: "lock.open.fill") { game.showPaywall() }
                    }
                    SecondaryButton(title: tr("Restaurează achizițiile", "Restore purchases"), systemImage: "arrow.clockwise") {
                        Task { await store.restore() }
                    }
                    .disabled(store.isBusy)
                    if let m = store.message {
                        Text(m).font(.system(size: 13)).foregroundStyle(Color.hwcTextDim)
                    }
                }

                Panel(title: tr("Confidențialitate", "Privacy")) {
                    Text(tr("Aplicația nu are cont, reclame sau analytics și nu colectează date personale. Progresul se păstrează doar pe telefon. Plata este procesată exclusiv de Apple.", "The app has no account, no ads and no analytics, and collects no personal data. Your progress stays on your phone. Payment is handled entirely by Apple."))
                        .font(.system(size: 14)).foregroundStyle(Color.hwcText)
                    Link(tr("Politica de confidențialitate", "Privacy policy"), destination: AppLinks.privacy)
                        .font(.system(size: 15, weight: .semibold)).tint(.hwcGold)
                    Link(tr("Suport și întrebări", "Support & questions"), destination: AppLinks.support)
                        .font(.system(size: 15, weight: .semibold)).tint(.hwcGold)
                }

                Panel(title: tr("Joc neoficial", "Unofficial game")) {
                    Text(unofficialDisclaimer)
                        .font(.system(size: 14)).foregroundStyle(Color.hwcText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Panel(title: tr("Surse", "Sources")) {
                    Text(LocalizedStringKey(tr("Rezultatele meciurilor reale: [Fjelstul World Cup Database](https://www.github.com/jfjelstul/worldcup) © 2023 Joshua C. Fjelstul, Ph.D., licență [CC-BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/legalcode) (date adaptate). Meciurile din 2026: [openfootball](https://github.com/openfootball/worldcup.json) (domeniu public). Loturi: Wikipedia. Textele istorice sunt rezumate originale.", "Real match results: [Fjelstul World Cup Database](https://www.github.com/jfjelstul/worldcup) © 2023 Joshua C. Fjelstul, Ph.D., licensed [CC-BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/legalcode) (adapted data). 2026 matches: [openfootball](https://github.com/openfootball/worldcup.json) (public domain). Squads: Wikipedia. The historical texts are original summaries.")))
                        .font(.system(size: 13)).foregroundStyle(Color.hwcTextDim).tint(.hwcGold)
                }

                Text(tr("Versiunea ", "Version ") + Self.version)
                    .font(.system(size: 12)).foregroundStyle(Color.hwcTextDim)
            }
        }
    }

    static var version: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
        return "\(v) (\(b))"
    }
}
