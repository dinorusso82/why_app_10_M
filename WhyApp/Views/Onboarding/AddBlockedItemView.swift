import SwiftUI

struct AddBlockedItemView: View {
    @EnvironmentObject var store: DataStore
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var category: BlockedItem.Category = .website
    @State private var whyNot = ""

    var isFromOnboarding: Bool = false
    var onItemAdded: (() -> Void)?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Type", selection: $category) {
                        ForEach(BlockedItem.Category.allCases, id: \.self) { cat in
                            Text(cat.rawValue).tag(cat)
                        }
                    }
                    .pickerStyle(.segmented)

                    TextField(category == .website ? "e.g. gambling-site.com" : "e.g. Social Media App", text: $name)
                } header: {
                    Text("What do you want to avoid?")
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
            .navigationTitle(isFromOnboarding ? "Add an Item" : "Block Something New")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if !isFromOnboarding {
                        Button("Cancel") { dismiss() }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let item = BlockedItem(
                            name: name.trimmingCharacters(in: .whitespaces),
                            category: category,
                            whyNot: whyNot.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                        store.addBlockedItem(item)
                        name = ""
                        whyNot = ""
                        onItemAdded?()
                        if !isFromOnboarding {
                            dismiss()
                        }
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || whyNot.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
