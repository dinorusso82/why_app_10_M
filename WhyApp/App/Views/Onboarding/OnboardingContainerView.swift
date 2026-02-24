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
                withAnimation(.easeInOut(duration: 0.4)) {
                    store.completeOnboarding()
                }
            })
        }
    }
}

struct OnboardingAddItemsView: View {
    @EnvironmentObject var store: SharedDataStore
    @State private var showingAddSheet = false
    @State private var itemToDelete: BlockedItem?
    var onFinish: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("Your List")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.whyPrimary)
                Text("What do you want to stay away from?")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(Color.whySecondary)
            }
            .padding(.top, 60)
            .padding(.bottom, 24)

            if store.blockedItems.isEmpty {
                Spacer()
                VStack(spacing: 16) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.whyTertiary)
                    Text("Add an app or website\nyou want to avoid.")
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(Color.whySecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(store.blockedItems) { item in
                            WhyCard {
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.whySurface)
                                            .frame(width: 44, height: 44)
                                        Image(systemName: item.isApp ? "app.fill" : "globe")
                                            .font(.system(size: 18))
                                            .foregroundStyle(Color.whyWarm)
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.name)
                                            .font(.system(.body, design: .rounded, weight: .semibold))
                                            .foregroundStyle(Color.whyPrimary)
                                        Text(item.whyNot)
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundStyle(Color.whySecondary)
                                            .lineLimit(2)
                                            .lineSpacing(2)
                                    }

                                    Spacer()

                                    Button {
                                        itemToDelete = item
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundStyle(Color.whyTertiary)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }

            // Buttons
            VStack(spacing: 12) {
                WhyButton(title: "Add Item", style: .ghost) {
                    showingAddSheet = true
                }

                if !store.blockedItems.isEmpty {
                    WhyButton(title: "I'm Ready", style: .primary) {
                        onFinish()
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .whyBackground()
        .sheet(isPresented: $showingAddSheet) {
            AddBlockedItemView()
        }
        .alert(item: $itemToDelete) { item in
            Alert(
                title: Text("Remove \(item.name)?"),
                message: Text("This will remove it from your list."),
                primaryButton: .destructive(Text("Remove")) {
                    withAnimation(.easeOut(duration: 0.25)) {
                        store.removeBlockedItem(item)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}
