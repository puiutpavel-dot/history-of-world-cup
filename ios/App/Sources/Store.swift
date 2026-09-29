import StoreKit
import SwiftUI

/// Magazinul: un singur produs, „Full History” (non-consumable, 4,99 $),
/// care deblochează toate edițiile după 1938 și toate modurile de quiz.
/// Fără reclame, fără abonament, fără alte pachete. StoreKit 2.
@MainActor
final class Store: ObservableObject {
    static let fullHistoryID = "com.puiutpavel.historyofworldcup.fullhistory"
    /// prețul afișat până răspunde App Store-ul (prețul real vine din `Product.displayPrice`)
    static let fallbackPrice = "4,99 $"

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
            message = "Magazinul App Store nu răspunde acum. Încearcă din nou puțin mai târziu."
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
                    message = "Achiziția nu a putut fi verificată."
                }
            case .pending:
                message = "Achiziția așteaptă aprobarea (de exemplu „Cere permisiunea” din Partajare familială)."
            case .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            message = "Achiziția nu a reușit: \(error.localizedDescription)"
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
            message = "Nu am putut contacta App Store: \(error.localizedDescription)"
            return
        }
        await refresh()
        message = isUnlocked ? "Achiziția a fost restaurată. Toată istoria e a ta!"
            : "Nu am găsit nicio achiziție „Full History” pentru acest Apple ID."
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

    private let perks = [
        ("trophy.fill", "Toate cele 23 de ediții, 1930–2026, în modul carieră"),
        ("questionmark.circle.fill", "Toate quizurile: pe ediție, Maraton, Duoul greșit, Alege faza"),
        ("flag.fill", "Traseul oricărei țări, jucabil la orice ediție"),
        ("sparkles", "Tot ce vine în actualizări este inclus"),
        ("hand.raised.fill", "Fără reclame, fără abonament, fără pachete — o singură plată"),
        ("person.2.fill", "Partajare familială: o plată pentru toată familia"),
    ]

    var body: some View {
        ScreenContainer(title: "🏆 Full History", backLabel: "Înapoi", onBack: { game.closePaywall() }) {
            VStack(alignment: .leading, spacing: 16) {
                if store.isUnlocked {
                    Text("✅ Ai deblocat toată istoria. Mulțumim!")
                        .font(.scoreboard(24)).foregroundStyle(Color.hwcGold2)
                    PrimaryButton(title: "Continuă", systemImage: "arrow.right") { game.closePaywall() }
                } else {
                    Text("Mondialele 1930–1938 sunt gratuite. Deblochează restul istoriei:")
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

                    PrimaryButton(title: "Deblochează tot — \(store.displayPrice)", systemImage: "lock.open.fill") {
                        Task { await store.purchase() }
                    }
                    .disabled(store.isBusy)
                    SecondaryButton(title: "Restaurează achizițiile", systemImage: "arrow.clockwise") {
                        Task { await store.restore() }
                    }
                    .disabled(store.isBusy)
                    if store.isBusy { ProgressView().frame(maxWidth: .infinity) }
                    Text("Plată unică prin App Store, fără abonament. Achiziția se restaurează pe orice dispozitiv cu același Apple ID.")
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
