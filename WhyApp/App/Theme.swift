import SwiftUI

// MARK: - Color Palette
// Warm, approachable palette inspired by Grow Therapy + Headway.
// Cream backgrounds, terracotta/amber accents, soft sage for positive actions.

extension Color {
    // Backgrounds
    static let whyCream       = Color(hex: "FAF6F1")
    static let whyCardBg      = Color.white
    static let whySurface     = Color(hex: "F0E8DF")

    // Text
    static let whyPrimary     = Color(hex: "2D2926")
    static let whySecondary   = Color(hex: "8A8480")
    static let whyTertiary    = Color(hex: "B8B2AC")

    // Accents
    static let whyWarm        = Color(hex: "D4845A")   // terracotta — primary actions
    static let whyAmber       = Color(hex: "E8A87C")   // lighter warm — highlights
    static let whySage        = Color(hex: "7BAE8E")   // sage green — positive / "walked away"
    static let whyRose        = Color(hex: "C85C5C")   // muted red — warnings / "proceeded"

    // Utility
    static let whyDivider     = Color(hex: "E8E2DA")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}

// MARK: - Reusable Components

struct WhyCard<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        content()
            .padding(20)
            .background(Color.whyCardBg)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4)
    }
}

struct WhyButton: View {
    let title: String
    var style: Style = .primary
    let action: () -> Void

    enum Style {
        case primary, secondary, destructive, ghost
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.body, design: .rounded, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(background)
                .foregroundStyle(foreground)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay {
                    if style == .ghost {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.whyDivider, lineWidth: 1.5)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    private var background: Color {
        switch style {
        case .primary:     return .whyWarm
        case .secondary:   return .whySage
        case .destructive: return .whyRose
        case .ghost:       return .clear
        }
    }

    private var foreground: Color {
        switch style {
        case .primary, .secondary, .destructive: return .white
        case .ghost: return .whyPrimary
        }
    }
}

struct WhyTag: View {
    let text: String
    var color: Color = .whyWarm

    var body: some View {
        Text(text)
            .font(.system(.caption2, design: .rounded, weight: .bold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}

// MARK: - View Modifiers

struct WhyScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.whyCream.ignoresSafeArea())
    }
}

extension View {
    func whyBackground() -> some View {
        modifier(WhyScreenBackground())
    }
}
