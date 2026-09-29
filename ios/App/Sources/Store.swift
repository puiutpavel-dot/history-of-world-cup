import StoreKit
import SwiftUI
import WorldCupCore

/// Magazinul: un singur produs, „Full History” (non-consumable, 4,99 $),
/// care deblochează toate edițiile după 1938 și toate modurile de quiz.
/// Fără reclame, fără abonament, fără alte pachete. StoreKit 2.
@MainActor
final class Store: ObservableObject {
    static let fullHistoryID = "com.puiutpavel.historyofworldcup.fullhistory"
    /// prețul afișat până răspunde App Store-ul (prețul real vine din `Product.displayPrice`)
    static var fallbackPrice: String { tr("4,99 $", "$4.99") }

    @Published private(set) var product: Product?
    @Published private(set) var isUnlocked: Bool
    @Published private(set) var isBusy = false
    @Published var message: String?

    private let defaults: UserDefaults
    private let cacheKey = "hwc_full_history_v1"
    private var updates: Task<Void, Never>?

    init(defaults: UserDefaults = .standard, useStoreKit: Bool = true) {
        self.defaults = defaults
        // ultima stare cunoscută, ca aplicația să pornească deblocată și offline
        isUnlocked = defaults.bool(forKey: cacheKey)
        guard useStoreKit else { return }
        updates = Task { [weak self] in
            for await result in StoreKit.Transaction.updates {
                await self?.handle(result)
            }
        }
        Task { await refresh() }
    }

    var displayPrice: String { product?.displayPrice ?? Self.fallbackPrice }

    /// Încarcă produsul și verifică drepturile curente (inclusiv Family Sharing și rambursări).
    func refresh() async {
        if product == nil {
            product = try? await Product.products(for: [Self.fullHistoryID]).first
        }
        var owned = false
        for await result in StoreKit.Transaction.currentEntitlements {
            if case .verified(let t) = result, t.productID == Self.fullHistoryID, t.revocationDate == nil {
                owned = true
            }
        }
        setUnlocked(owned)
    }

    func purchase() async {
        message = nil
        if product == nil { await refresh() }
        guard let product else {
            message = tr("Magazinul App Store nu răspunde acum. Încearcă din nou puțin mai târziu.", "The App Store is not responding right now. Please try again a little later.")
            return
        }
        isBusy = true
        defer { isBusy = false }
        do {
            switch try await product.purchase() {
            case .success(let verification):
                if case .verified(let t) = verification {
                    await t.finish()
                    setUnlocked(true)
                } else {
                    message = tr("Achiziția nu a putut fi verificată.", "The purchase could not be verified.")
                }
            case .pending:
                message = tr("Achiziția așteaptă aprobarea (de exemplu „Cere permisiunea” din Partajare familială).", "The purchase is waiting for approval (for example Ask to Buy in Family Sharing).")
            case .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            message = tr("Achiziția nu a reușit: ", "The purchase failed: ") + error.localizedDescription
        }
    }

    /// „Restaurează achizițiile” — obligatoriu pentru un produs non-consumable.
    func restore() async {
        message = nil
        isBusy = true
        defer { isBusy = false }
        do {
            try await AppStore.sync()
        } catch {
            message = tr("Nu am putut contacta App Store: ", "Could not reach the App Store: ") + error.localizedDescription
            return
        }
        await refresh()
        message = isUnlocked ? tr("Achiziția a fost restaurată. Toată istoria e a ta!", "Purchase restored. All of history is yours!")
            : tr("Nu am găsit nicio achiziție „Full History” pentru acest Apple ID.", "No \"Full History\" purchase was found for this Apple ID.")
    }

    private func handle(_ result: VerificationResult<StoreKit.Transaction>) async {
        guard case .verified(let t) = result else { return }
        if t.productID == Self.fullHistoryID { setUnlocked(t.revocationDate == nil) }
        await t.finish()
    }

    private func setUnlocked(_ value: Bool) {
        isUnlocked = value
        defaults.set(value, forKey: cacheKey)
    }
}

// MARK: - Ecranul de deblocare

struct PaywallView: View {
    @EnvironmentObject var game: GameState
    @EnvironmentObject var store: Store

    private var perks: [(String, String)] { [
        ("trophy.fill", tr("Toate turneele finale 1930–2022, cu orice echipă, meci cu meci", "Every finals tournament 1930–2022, with any team, match by match")),
        ("questionmark.circle.fill", tr("Toate quizurile: pe ediție, Maraton, Duoul greșit, Alege faza", "Every quiz: by edition, Marathon, Spot the fake, Name the stage")),
        ("flag.fill", tr("Traseul oricărei țări, jucabil la orice ediție", "Any country's journey, playable at every edition")),
        ("sparkles", tr("Tot ce vine în actualizări este inclus", "Everything in future updates is included")),
        ("hand.raised.fill", tr("Fără reclame, fără abonament, fără pachete — o singură plată", "No ads, no subscription, no packs — one purchase")),
        ("person.2.fill", tr("Partajare familială: o plată pentru toată familia", "Family Sharing: one purchase for the whole family")),
    ] }

    var body: some View {
        ScreenContainer(title: "🏆 Full History", backLabel: tr("Înapoi", "Back"), onBack: { game.closePaywall() }) {
            VStack(alignment: .leading, spacing: 16) {
                if store.isUnlocked {
                    Text(tr("✅ Ai deblocat toată istoria. Mulțumim!", "✅ You unlocked all of history. Thank you!"))
                        .font(.scoreboard(24)).foregroundStyle(Color.hwcGold2)
                    PrimaryButton(title: tr("Continuă", "Continue"), systemImage: "arrow.right") { game.closePaywall() }
                } else {
                    Text(tr("Mondialele 1930–1938 sunt gratuite. Deblochează restul istoriei:", "The 1930–1938 World Cups are free. Unlock the rest of history:"))
                        .font(.system(size: 16)).foregroundStyle(Color.hwcText)
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(perks.enumerated()), id: \.offset) { _, perk in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: perk.0).foregroundStyle(Color.hwcGold).frame(width: 22)
                                Text(perk.1).font(.system(size: 15)).foregroundStyle(Color.hwcText)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.hwcPanel, in: RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.hwcBorder))

                    PrimaryButton(title: tr("Deblochează tot — ", "Unlock everything — ") + store.displayPrice, systemImage: "lock.open.fill") {
                        Task { await store.purchase() }
                    }
                    .disabled(store.isBusy)
                    SecondaryButton(title: tr("Restaurează achizițiile", "Restore purchases"), systemImage: "arrow.clockwise") {
                        Task { await store.restore() }
                    }
                    .disabled(store.isBusy)
                    if store.isBusy { ProgressView().frame(maxWidth: .infinity) }
                    Text(tr("Plată unică prin App Store, fără abonament. Achiziția se restaurează pe orice dispozitiv cu același Apple ID.", "A one-time App Store purchase, no subscription. It can be restored on any device with the same Apple ID."))
                        .font(.system(size: 12)).foregroundStyle(Color.hwcTextDim)
                }
                if let m = store.message {
                    Text(m).font(.system(size: 14)).foregroundStyle(Color.hwcText)
                }
            }
            .padding(.top, 8)
        }
    }
}
