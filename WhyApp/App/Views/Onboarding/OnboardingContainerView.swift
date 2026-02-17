import SwiftUI

struct OnboardingContainerView: View {
    @EnvironmentObject var store: SharedDataStore
    @EnvironmentObject var screenTime: ScreenTimeManager
    @State private var currentStep: OnboardingStep = .welcome

    var body: some View {
        switch currentStep {
        case .welcome:
            OnboardingWelcomeView(currentStep: $currentStep)

        case .addItems:
            OnboardingAddItemsView(onFinish: {
                store.completeOnboarding()
            })
        }
    }
}

struct OnboardingAddItemsView: View {
    @EnvironmentObject var store: SharedDataStore
    @State private var showingAddSheet = false
    var onFinish: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if store.blockedItems.isEmpty {
                    ContentUnavailableView(
                        "No items yet",
                        systemImage: "plus.circle",
                        description: Text("Tap the button below to add an app or website you want to avoid.")
                    )
                } else {
                    List {
                        ForEach(store.blockedItems) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: item.isApp ? "app.fill" : "globe")
                                        .foregroundStyle(.secondary)
                                    Text(item.name)
                                        .font(.headline)
                                }
                                Text(item.whyNot)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                VStack(spacing: 12) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Label("Add Item", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    if !store.blockedItems.isEmpty {
                        Button {
                            onFinish()
                        } label: {
                            Text("Done — I'm Ready")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.green)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                }
                .padding(24)
            }
            .navigationTitle("Your List")
            .sheet(isPresented: $showingAddSheet) {
                AddBlockedItemView()
            }
        }
    }
}
