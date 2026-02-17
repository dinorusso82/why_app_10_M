import SwiftUI

struct PendingReasonView: View {
    @EnvironmentObject var store: SharedDataStore
    @EnvironmentObject var screenTime: ScreenTimeManager

    let pendingReason: PendingReason
    var onComplete: () -> Void

    @State private var whyYes = ""
    @State private var animate = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Top illustration
            ZStack {
                Circle()
                    .fill(Color.whyAmber.opacity(0.15))
                    .frame(width: 120, height: 120)
                    .scaleEffect(animate ? 1.0 : 0.8)

                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(Color.whyWarm)
                    .scaleEffect(animate ? 1.0 : 0.6)
            }
            .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animate)

            Spacer().frame(height: 28)

            // Context
            VStack(spacing: 16) {
                Text("You used \(pendingReason.blockedItemName)")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.whyPrimary)

                WhyCard {
                    VStack(spacing: 8) {
                        Text("You said you wanted to avoid it because:")
                            .font(.system(.caption, design: .rounded, weight: .medium))
                            .foregroundStyle(Color.whySecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("\"\(pendingReason.whyNot)\"")
                            .font(.system(.body, design: .rounded))
                            .italic()
                            .foregroundStyle(Color.whyPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineSpacing(4)
                    }
                }
                .padding(.horizontal, 24)
            }

            Spacer().frame(height: 28)

            // Input
            VStack(alignment: .leading, spacing: 12) {
                Text("Why did you decide to use it?")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(Color.whyPrimary)
                    .padding(.horizontal, 24)

                ZStack(alignment: .topLeading) {
                    if whyYes.isEmpty {
                        Text("Be honest — no one sees this but you…")
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(Color.whyTertiary)
                            .padding(.horizontal, 38)
                            .padding(.vertical, 20)
                    }
                    TextEditor(text: $whyYes)
                        .font(.system(.body, design: .rounded))
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .frame(minHeight: 100, maxHeight: 140)
                }
                .background(Color.whyCardBg)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4)
                .padding(.horizontal, 24)
            }

            Spacer()

            // Submit button
            WhyButton(title: "Submit & Re-enable Shield", style: .primary) {
                store.resolvePendingReason(
                    pendingReason,
                    whyYes: whyYes.trimmingCharacters(in: .whitespacesAndNewlines),
                    proceeded: true
                )
                screenTime.applyShields()
                onComplete()
            }
            .disabled(whyYes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(whyYes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1.0)
            .padding(.horizontal, 24)
            .animation(.easeOut(duration: 0.2), value: whyYes.isEmpty)

            Spacer().frame(height: 40)
        }
        .whyBackground()
        .interactiveDismissDisabled()
        .onAppear { animate = true }
    }
}
