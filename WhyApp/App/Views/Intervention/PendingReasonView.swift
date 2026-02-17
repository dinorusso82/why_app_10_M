import SwiftUI

/// Shown when the user opens WhyApp and has outstanding pending reasons
/// (they bypassed a shield but haven't explained why yet).
struct PendingReasonView: View {
    @EnvironmentObject var store: SharedDataStore
    @EnvironmentObject var screenTime: ScreenTimeManager

    let pendingReason: PendingReason
    var onComplete: () -> Void

    @State private var whyYes = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.orange)

                Text("You used \(pendingReason.blockedItemName)")
                    .font(.title2)
                    .fontWeight(.bold)

                VStack(spacing: 8) {
                    Text("You said you didn't want to because:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(""\(pendingReason.whyNot)"")
                        .font(.body)
                        .italic()
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Text("Why did you decide to use it?")
                    .font(.headline)

                TextEditor(text: $whyYes)
                    .frame(minHeight: 100, maxHeight: 150)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
                    .padding(.horizontal)

                Spacer()

                Button {
                    store.resolvePendingReason(
                        pendingReason,
                        whyYes: whyYes.trimmingCharacters(in: .whitespacesAndNewlines),
                        proceeded: true
                    )
                    // Re-apply shield now that they've provided a reason
                    screenTime.applyShields()
                    onComplete()
                } label: {
                    Text("Submit & Re-enable Shield")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(whyYes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(.horizontal)

                Spacer().frame(height: 20)
            }
            .navigationTitle("Tell Us Why")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
        }
    }
}
