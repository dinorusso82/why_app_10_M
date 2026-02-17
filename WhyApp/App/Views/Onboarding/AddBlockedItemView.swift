import SwiftUI
import FamilyControls
import ManagedSettings

struct AddBlockedItemView: View {
    @EnvironmentObject var store: SharedDataStore
    @EnvironmentObject var screenTime: ScreenTimeManager
    @Environment(\.dismiss) var dismiss

    @State private var selection = FamilyActivitySelection()
    @State private var name = ""
    @State private var whyNot = ""
    @State private var showingPicker = false

    var hasSelection: Bool {
        !selection.applicationTokens.isEmpty || !selection.webDomainTokens.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Step 1 — Pick app/website
                    WhyCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label {
                                Text("Select App or Website")
                                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                    .foregroundStyle(Color.whyPrimary)
                            } icon: {
                                stepBadge(1)
                            }

                            Button {
                                showingPicker = true
                            } label: {
                                HStack {
                                    Image(systemName: hasSelection ? "checkmark.circle.fill" : "app.badge.fill")
                                        .foregroundStyle(hasSelection ? Color.whySage : Color.whyTertiary)
                                        .font(.title3)

                                    Text(hasSelection ? "Selected" : "Tap to choose…")
                                        .font(.system(.body, design: .rounded))
                                        .foregroundStyle(hasSelection ? Color.whyPrimary : Color.whySecondary)

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(Color.whyTertiary)
                                }
                                .padding(14)
                                .background(Color.whyCream)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .buttonStyle(.plain)
                            .familyActivityPicker(isPresented: $showingPicker, selection: $selection)
                        }
                    }

                    // Step 2 — Name it
                    WhyCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label {
                                Text("Give It a Name")
                                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                    .foregroundStyle(Color.whyPrimary)
                            } icon: {
                                stepBadge(2)
                            }

                            TextField("e.g. YouTube, Twitter, Betting App", text: $name)
                                .font(.system(.body, design: .rounded))
                                .padding(14)
                                .background(Color.whyCream)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                            Text("This name shows on the block screen.")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(Color.whyTertiary)
                        }
                    }

                    // Step 3 — Why not
                    WhyCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label {
                                Text("Why Do You Want to Avoid It?")
                                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                    .foregroundStyle(Color.whyPrimary)
                            } icon: {
                                stepBadge(3)
                            }

                            ZStack(alignment: .topLeading) {
                                if whyNot.isEmpty {
                                    Text("Be honest with yourself. This is the reminder you'll see when you're tempted…")
                                        .font(.system(.body, design: .rounded))
                                        .foregroundStyle(Color.whyTertiary)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 16)
                                }
                                TextEditor(text: $whyNot)
                                    .font(.system(.body, design: .rounded))
                                    .scrollContentBackground(.hidden)
                                    .padding(10)
                                    .frame(minHeight: 100)
                            }
                            .background(Color.whyCream)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                    }
                }
                .padding(24)
            }
            .whyBackground()
            .navigationTitle("Block Something")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(Color.whySecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItems()
                        dismiss()
                    }
                    .font(.system(.body, design: .rounded, weight: .semibold))
                    .foregroundStyle(canSave ? Color.whyWarm : Color.whyTertiary)
                    .disabled(!canSave)
                }
            }
        }
    }

    @ViewBuilder
    private func stepBadge(_ n: Int) -> some View {
        Text("\(n)")
            .font(.system(.caption2, design: .rounded, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 22, height: 22)
            .background(Color.whyWarm)
            .clipShape(Circle())
    }

    private var canSave: Bool {
        hasSelection
        && !name.trimmingCharacters(in: .whitespaces).isEmpty
        && !whyNot.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func saveItems() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedWhy = whyNot.trimmingCharacters(in: .whitespacesAndNewlines)

        for token in selection.applicationTokens {
            store.addBlockedItem(BlockedItem(
                name: trimmedName,
                applicationToken: token,
                whyNot: trimmedWhy
            ))
        }

        for token in selection.webDomainTokens {
            store.addBlockedItem(BlockedItem(
                name: trimmedName,
                webDomainToken: token,
                whyNot: trimmedWhy
            ))
        }

        screenTime.applyShields()
    }
}
