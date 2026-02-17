import SwiftUI

struct OnboardingWelcomeView: View {
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
                Text("Start by adding the apps or websites you want to avoid, and your reason why.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Button {
                    currentStep = .addItems
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
            }

            Spacer()
                .frame(height: 40)
        }
    }
}

enum OnboardingStep {
    case welcome
    case addItems
}
