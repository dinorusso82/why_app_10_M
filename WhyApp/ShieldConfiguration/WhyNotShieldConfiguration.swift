import ManagedSettings
import ManagedSettingsUI
import UIKit

/// Customizes the full-screen shield that appears when the user tries to open a blocked app.
///
/// This runs as a separate extension process. It reads the shared data store
/// to find the user's "why not" reason and displays it on the shield.
class WhyNotShieldConfiguration: ShieldConfigurationExtension {

    private let store = SharedDataStore()

    // MARK: - App Shield

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        guard let token = application.token,
              let item = store.blockedItems.first(where: { $0.applicationToken == token }) else {
            return defaultConfiguration(name: application.localizedDisplayName ?? "this app")
        }

        return ShieldConfiguration(
            backgroundBlurStyle: .systemThickMaterial,
            backgroundColor: .systemBackground,
            icon: UIImage(systemName: "hand.raised.fill"),
            title: ShieldConfiguration.Label(
                text: "You don't want to use \(item.name)",
                color: .label
            ),
            subtitle: ShieldConfiguration.Label(
                text: "\"\(item.whyNot)\"",
                color: .secondaryLabel
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "You're right — close it",
                color: .white
            ),
            primaryButtonBackgroundColor: .systemGreen,
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "I need to use it…",
                color: .systemRed
            )
        )
    }

    // MARK: - Website Shield

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        guard let token = webDomain.token,
              let item = store.blockedItems.first(where: { $0.webDomainToken == token }) else {
            return defaultConfiguration(name: webDomain.domain ?? "this website")
        }

        return ShieldConfiguration(
            backgroundBlurStyle: .systemThickMaterial,
            backgroundColor: .systemBackground,
            icon: UIImage(systemName: "hand.raised.fill"),
            title: ShieldConfiguration.Label(
                text: "You don't want to visit \(item.name)",
                color: .label
            ),
            subtitle: ShieldConfiguration.Label(
                text: "\"\(item.whyNot)\"",
                color: .secondaryLabel
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "You're right — close it",
                color: .white
            ),
            primaryButtonBackgroundColor: .systemGreen,
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "I need to visit it…",
                color: .systemRed
            )
        )
    }

    // MARK: - Fallback

    private func defaultConfiguration(name: String) -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: .systemThickMaterial,
            icon: UIImage(systemName: "hand.raised.fill"),
            title: ShieldConfiguration.Label(
                text: "You chose to avoid \(name)",
                color: .label
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Open Why Not? to manage your list.",
                color: .secondaryLabel
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Close",
                color: .white
            ),
            primaryButtonBackgroundColor: .systemGray
        )
    }
}
