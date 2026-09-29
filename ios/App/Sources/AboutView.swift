import SwiftUI
import WorldCupCore

/// Linkurile publice ale aplicației (GitHub Pages) — aceleași ca în App Store Connect.
enum AppLinks {
    static let privacy = URL(string: "https://puiutpavel-dot.github.io/history-of-world-cup/privacy.html")!
    static let support = URL(string: "https://puiutpavel-dot.github.io/history-of-world-cup/support.html")!
}

/// Textul de neafiliere — același pe web, în aplicație și în descrierea din App Store.
let unofficialDisclaimer = "Arhiva Mondialelor este un joc educațional neoficial, creat independent. Nu este afiliat, sponsorizat sau aprobat de FIFA, de organizatorii turneelor sau de vreo federație națională. Numele competițiilor, echipelor și jucătorilor sunt folosite doar descriptiv, în scop istoric. Aplicația nu folosește logouri, embleme, trofee oficiale sau fotografii."

// MARK: - Despre și setări

struct AboutView: View {
    @EnvironmentObject var game: GameState
    @EnvironmentObject var store: Store

    var body: some View {
        ScreenContainer(title: "ℹ️ Despre și setări", backLabel: "Meniu", onBack: { game.go(.menu) }) {
            VStack(alignment: .leading, spacing: 14) {
                Panel(title: "Achiziții") {
                    Text(store.isUnlocked ? "✅ Full History este deblocat pe acest Apple ID."
                         : "Mondialele 1930–1938 sunt gratuite. Restul istoriei se deblochează cu o singură achiziție.")
                        .font(.system(size: 14)).foregroundStyle(Color.hwcText)
                    if !store.isUnlocked {
                        PrimaryButton(title: "Full History", systemImage: "lock.open.fill") { game.showPaywall() }
                    }
                    SecondaryButton(title: "Restaurează achizițiile", systemImage: "arrow.clockwise") {
                        Task { await store.restore() }
                    }
                    .disabled(store.isBusy)
                    if let m = store.message {
                        Text(m).font(.system(size: 13)).foregroundStyle(Color.hwcTextDim)
                    }
                }

                Panel(title: "Confidențialitate") {
                    Text("Aplicația nu are cont, reclame sau analytics și nu colectează date personale. Progresul se păstrează doar pe telefon. Plata este procesată exclusiv de Apple.")
                        .font(.system(size: 14)).foregroundStyle(Color.hwcText)
                    Link("Politica de confidențialitate", destination: AppLinks.privacy)
                        .font(.system(size: 15, weight: .semibold)).tint(.hwcGold)
                    Link("Suport și întrebări", destination: AppLinks.support)
                        .font(.system(size: 15, weight: .semibold)).tint(.hwcGold)
                }

                Panel(title: "Joc neoficial") {
                    Text(unofficialDisclaimer)
                        .font(.system(size: 14)).foregroundStyle(Color.hwcText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Panel(title: "Surse") {
                    Text("Rezultatele meciurilor reale: [Fjelstul World Cup Database](https://www.github.com/jfjelstul/worldcup) © 2023 Joshua C. Fjelstul, Ph.D., licență [CC-BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/legalcode) (date adaptate). Loturi: Wikipedia. Textele istorice sunt rezumate originale.")
                        .font(.system(size: 13)).foregroundStyle(Color.hwcTextDim).tint(.hwcGold)
                }

                Text("Versiunea \(Self.version)")
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
