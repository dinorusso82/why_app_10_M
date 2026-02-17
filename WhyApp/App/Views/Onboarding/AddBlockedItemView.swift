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
            Form {
                Section {
                    Button {
                        showingPicker = true
                    } label: {
                        HStack {
                            Text(hasSelection ? "App/website selected" : "Tap to choose an app or website")
                                .foregroundStyle(hasSelection ? .primary : .secondary)
                            Spacer()
                            Image(systemName: hasSelection ? "checkmark.circle.fill" : "chevron.right")
                                .foregroundStyle(hasSelection ? .green : .secondary)
                        }
                    }
                    .familyActivityPicker(isPresented: $showingPicker, selection: $selection)
                } header: {
                    Text("What do you want to avoid?")
                }

                Section {
                    TextField("e.g. YouTube, Twitter, Gambling Site", text: $name)
                } header: {
                    Text("Give it a name")
                } footer: {
                    Text("This name will appear on the block screen.")
                }

                Section {
                    TextEditor(text: $whyNot)
                        .frame(minHeight: 120)
                } header: {
                    Text("Why do you want to avoid it?")
                } footer: {
                    Text("Be honest with yourself. This is the reminder you'll see when you're tempted.")
                }
            }
            .navigationTitle("Block Something")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItems()
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }

    private var canSave: Bool {
        hasSelection
        && !name.trimmingCharacters(in: .whitespaces).isEmpty
        && !whyNot.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func saveItems() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedWhy = whyNot.trimmingCharacters(in: .whitespacesAndNewlines)

        // Create a BlockedItem for each selected app token
        for token in selection.applicationTokens {
            let item = BlockedItem(
                name: trimmedName,
                applicationToken: token,
                whyNot: trimmedWhy
            )
            store.addBlockedItem(item)
        }

        // Create a BlockedItem for each selected web domain token
        for token in selection.webDomainTokens {
            let item = BlockedItem(
                name: trimmedName,
                webDomainToken: token,
                whyNot: trimmedWhy
            )
            store.addBlockedItem(item)
        }

        // Apply shields immediately
        screenTime.applyShields()
    }
}
