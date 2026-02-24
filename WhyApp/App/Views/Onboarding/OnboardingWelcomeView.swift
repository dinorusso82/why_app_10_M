import SwiftUI

struct OnboardingWelcomeView: View {
    @EnvironmentObject var screenTime: ScreenTimeManager
    @Binding var currentStep: OnboardingStep

    @State private var animate = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Hero illustration area
            ZStack {
                Circle()
                    .fill(Color.whySurface)
                    .frame(width: 160, height: 160)
                    .scaleEffect(animate ? 1.0 : 0.8)

                Image(systemName: "hand.raised.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.whyWarm)
                    .scaleEffect(animate ? 1.0 : 0.6)
            }
            .animation(.spring(response: 0.8, dampingFraction: 0.6), value: animate)

            Spacer().frame(height: 40)

            VStack(spacing: 14) {
                Text("Why Not?")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.whyPrimary)

                Text("A gentle nudge before you reach for that app or website you're trying to avoid.")
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(Color.whySecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .opacity(animate ? 1 : 0)
            .offset(y: animate ? 0 : 20)
            .animation(.easeOut(duration: 0.7).delay(0.3), value: animate)

            Spacer()

            // Bottom section
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    WhyCard {
                        HStack(spacing: 14) {
                            Image(systemName: "lock.shield")
                                .font(.title2)
                                .foregroundStyle(Color.whySage)
                                .frame(width: 36)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Screen Time Permission")
                                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                    .foregroundStyle(Color.whyPrimary)
                                Text("We need this to block apps and websites when you're tempted.")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundStyle(Color.whySecondary)
                                    .lineSpacing(2)
                            }
                        }
                    }

                    WhyCard {
                        HStack(spacing: 14) {
                            Image(systemName: "iphone.and.arrow.forward")
                                .font(.title2)
                                .foregroundStyle(Color.whySage)
                                .frame(width: 36)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("100% On-Device")
                                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                                    .foregroundStyle(Color.whyPrimary)
                                Text("Everything lives on your phone. No accounts, no cloud, no data ever leaves your device.")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundStyle(Color.whySecondary)
                                    .lineSpacing(2)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)

                WhyButton(title: "Get Started") {
                    Task {
                        await screenTime.requestAuthorization()
                        if screenTime.isAuthorized {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentStep = .name
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)

                if let error = screenTime.authorizationError {
                    Text(error)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(Color.whyRose)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
            }
            .opacity(animate ? 1 : 0)
            .animation(.easeOut(duration: 0.7).delay(0.6), value: animate)

            Spacer().frame(height: 40)
        }
        .whyBackground()
        .onAppear { animate = true }
    }
}

enum OnboardingStep {
    case welcome
    case name
    case addItems
}
