import SwiftUI

struct InterventionView: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) var dismiss

    let item: BlockedItem
    @State private var step: InterventionStep = .reminder
    @State private var whyYes = ""

    enum InterventionStep {
        case reminder
        case askWhy
        case logged
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                switch step {
                case .reminder:
                    reminderView
                case .askWhy:
                    askWhyView
                case .logged:
                    loggedView
                }
            }
            .padding(24)
            .navigationTitle(item.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    // MARK: - Step 1: Remind them why not

    private var reminderView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.orange)

            Text("Remember why you said no")
                .font(.title2)
                .fontWeight(.bold)

            Text(""\(item.whyNot)"")
                .font(.title3)
                .italic()
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            Text("You wrote this when you were thinking clearly.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    let attempt = AccessAttempt(
                        blockedItemId: item.id,
                        blockedItemName: item.name,
                        whyNot: item.whyNot,
                        whyYes: "",
                        proceeded: false
                    )
                    store.logAttempt(attempt)
                    dismiss()
                } label: {
                    Text("You're right, I'll stay away")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.green)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Button {
                    step = .askWhy
                } label: {
                    Text("I still want to use it…")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.red.opacity(0.1))
                        .foregroundStyle(.red)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }

    // MARK: - Step 2: Ask why they want to proceed

    private var askWhyView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.blue)

            Text("Why do you want to use \(item.name) right now?")
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            Text("Be honest. This will be saved in your log.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextEditor(text: $whyYes)
                .frame(minHeight: 120)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                )

            Spacer()

            Button {
                let attempt = AccessAttempt(
                    blockedItemId: item.id,
                    blockedItemName: item.name,
                    whyNot: item.whyNot,
                    whyYes: whyYes.trimmingCharacters(in: .whitespacesAndNewlines),
                    proceeded: true
                )
                store.logAttempt(attempt)
                step = .logged
            } label: {
                Text("Log & Proceed")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.red)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(whyYes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    // MARK: - Step 3: Confirmation

    private var loggedView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.blue)

            Text("Logged")
                .font(.title2)
                .fontWeight(.bold)

            Text("Your decision has been recorded. You can review it later in your log.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Close")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }
}
