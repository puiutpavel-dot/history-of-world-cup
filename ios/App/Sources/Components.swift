import SwiftUI
import WorldCupCore

/// Fundal + bară de sus comună tuturor ecranelor.
struct ScreenContainer<Content: View>: View {
    let title: String
    var backLabel: String?
    var onBack: (() -> Void)?
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                if let backLabel, let onBack {
                    Button(action: onBack) {
                        Label(backLabel, systemImage: "chevron.left")
                            .font(.scoreboard(15, weight: .semibold))
                    }
                    .tint(.hwcGold)
                }
                Text(title)
                    .font(.scoreboard(22))
                    .foregroundStyle(Color.hwcText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
            }
            .padding(.leading, 16)
            .padding(.trailing, 56) // loc pentru butonul de temă
            .padding(.vertical, 12)
            ScrollView {
                content()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
            }
        }
        .background(Color.hwcBackground.ignoresSafeArea())
    }
}

struct Panel<Content: View>: View {
    var title: String?
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title {
                Text(title.uppercased())
                    .font(.scoreboard(15, weight: .semibold))
                    .foregroundStyle(Color.hwcGold)
            }
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.hwcPanel, in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.hwcBorder))
    }
}

struct PrimaryButton: View {
    let title: String
    var systemImage: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if let systemImage { Image(systemName: systemImage) }
                Text(title)
            }
            .font(.scoreboard(18, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundStyle(Color.black.opacity(0.85))
            .background(LinearGradient(colors: [.hwcGold2, .hwcGold], startPoint: .top, endPoint: .bottom),
                        in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

struct SecondaryButton: View {
    let title: String
    var systemImage: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                if let systemImage { Image(systemName: systemImage) }
                Text(title)
            }
            .font(.scoreboard(17, weight: .medium))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .foregroundStyle(Color.hwcText)
            .background(Color.hwcPanel2, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.hwcBorder))
        }
        .buttonStyle(.plain)
    }
}

/// Badge „📜 adversar real” / „🎲 adversar simulat”.
struct RealBadge: View {
    let isReal: Bool

    var body: some View {
        Text(isReal ? "📜 adversar real" : "🎲 adversar simulat")
            .font(.system(size: 11, weight: .semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .foregroundStyle(isReal ? Color.hwcGold2 : Color.hwcTextDim)
            .background((isReal ? Color.hwcGold : Color.hwcTextDim).opacity(0.15), in: Capsule())
    }
}

/// Comparația cu scorul istoric real.
struct HistoryCompare: View {
    let record: MatchRecord

    var body: some View {
        if let same = record.historyRepeated, let real = record.real {
            Text(same
                 ? "📖 Istoria s-a repetat: scor identic (\(real.scoreFor)-\(real.scoreAgainst))"
                 : "✍️ Ai rescris istoria! (real: \(real.scoreFor)-\(real.scoreAgainst))")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(same ? Color.hwcPitch2 : Color.hwcGold)
        }
    }
}

struct PlayerChip: View {
    let player: Player

    var body: some View {
        HStack(spacing: 8) {
            Text(player.pos.rawValue)
                .font(.stat(11))
                .frame(width: 26)
                .padding(.vertical, 2)
                .background(Color.hwcPitch.opacity(0.35), in: RoundedRectangle(cornerRadius: 4))
            Text(player.name + (player.isLegend ? " ⭐" : ""))
                .font(.system(size: 14, weight: player.isLegend ? .semibold : .regular))
                .foregroundStyle(player.isLegend ? Color.hwcGold2 : Color.hwcText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 4)
            Text("\(player.overall)")
                .font(.stat(14))
                .foregroundStyle(Color.hwcText)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(Color.hwcPanel2, in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(player.isLegend ? Color.hwcGold : .clear))
    }
}
