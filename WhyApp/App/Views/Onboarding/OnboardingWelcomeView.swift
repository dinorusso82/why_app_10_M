import SwiftUI

struct OnboardingWelcomeView: View {
    @EnvironmentObject var screenTime: ScreenTimeManager
    @Binding var currentStep: OnboardingStep

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "hand.raised.fill")
                .font(.system(size: 72))
                .foregroundStyle(.red.opacity(0.8))

            Text("Why Not?")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Before you reach for that app or website, remember why you chose to step away.")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            VStack(spacing: 16) {
                Text("We'll need Screen Time permission to show you a reminder when you try to open blocked apps.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Button {
                    Task {
                        await screenTime.requestAuthorization()
                        if screenTime.isAuthorized {
                            currentStep = .addItems
                        }
                    }
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 24)

                if let error = screenTime.authorizationError {
                    Text("Permission denied: \(error)")
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 32)
                }
            }

            Spacer().frame(height: 40)
        }
    }
}

enum OnboardingStep {
    case welcome
    case addItems
}
