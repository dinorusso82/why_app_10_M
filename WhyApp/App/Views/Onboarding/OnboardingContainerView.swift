import SwiftUI

struct OnboardingContainerView: View {
    @EnvironmentObject var store: SharedDataStore
    @EnvironmentObject var screenTime: ScreenTimeManager
    @State private var currentStep: OnboardingStep = .welcome

    var body: some View {
        switch currentStep {
        case .welcome:
            OnboardingWelcomeView(currentStep: $currentStep)

        case .name:
            OnboardingNameView(currentStep: $currentStep)

        case .addItems:
            OnboardingAddItemsView(onFinish: {
                withAnimation(.easeInOut(duration: 0.4)) {
                    store.completeOnboarding()
                }
            })
        }
    }
}

struct OnboardingNameView: View {
    @EnvironmentObject var store: SharedDataStore
    @Binding var currentStep: OnboardingStep

    @State private var name = ""
    @State private var animate = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.whySurface)
                    .frame(width: 120, height: 120)
                    .scaleEffect(animate ? 1.0 : 0.8)

                Image(systemName: "person.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(Color.whyWarm)
                    .scaleEffect(animate ? 1.0 : 0.6)
            }
            .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animate)

            Spacer().frame(height: 40)

            VStack(spacing: 14) {
                Text("What should we call you?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.whyPrimary)

                Text("Just your first name. It stays on your device.")
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(Color.whySecondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(animate ? 1 : 0)
            .offset(y: animate ? 0 : 20)
            .animation(.easeOut(duration: 0.7).delay(0.2), value: animate)

            Spacer().frame(height: 40)

            TextField("Your first name", text: $name)
                .font(.system(.title3, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(16)
                .background(Color.whyCardBg)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: .black.opacity(0.04), radius: 12, x: 0, y: 4)
                .padding(.horizontal, 24)
                .opacity(animate ? 1 : 0)
                .animation(.easeOut(duration: 0.7).delay(0.35), value: animate)

            Spacer()

            WhyButton(title: "Continue", style: .primary) {
                store.saveUserName(name.trimmingCharacters(in: .whitespaces))
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentStep = .addItems
                }
            }
            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            .opacity(name.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)
            .animation(.easeOut(duration: 0.2), value: name.isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .whyBackground()
        .onAppear { animate = true }
    }
}

struct OnboardingAddItemsView: View {
    @EnvironmentObject var store: SharedDataStore
    @State private var showingAddSheet = false
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
    }
}
