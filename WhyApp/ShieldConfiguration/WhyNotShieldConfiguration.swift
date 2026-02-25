import ManagedSettings
import ManagedSettingsUI
import UIKit

/// Customizes the full-screen shield that appears when the user tries to open a blocked app.
///
/// This runs as a separate extension process. It reads the shared data store
/// to find the user's "why not" reason and displays it on the shield.
///
/// Note: ShieldConfigurationExtension is unavailable in the iOS Simulator — guarded accordingly.
#if !targetEnvironment(simulator)
class WhyNotShieldConfiguration: ShieldConfigurationExtension {

    private let store = SharedDataStore()

    // Warm palette matching the main app (UIKit equivalents)
    private let warmBg      = UIColor(red: 250/255, green: 246/255, blue: 241/255, alpha: 1) // #FAF6F1
    private let warmDark    = UIColor(red: 45/255,  green: 41/255,  blue: 38/255,  alpha: 1) // #2D2926
    private let warmGray    = UIColor(red: 138/255, green: 132/255, blue: 128/255, alpha: 1) // #8A8480
    private let warmAccent  = UIColor(red: 212/255, green: 132/255, blue: 90/255,  alpha: 1) // #D4845A
    private let warmSage    = UIColor(red: 123/255, green: 174/255, blue: 142/255, alpha: 1) // #7BAE8E
    private let warmRose    = UIColor(red: 200/255, green: 92/255,  blue: 92/255,  alpha: 1) // #C85C5C

    // MARK: - App Shield

    override func configuration(shielding application: Application) -> ShieldConfiguration {
        guard let token = application.token,
              let item = store.blockedItems.first(where: { $0.applicationToken == token }) else {
            return defaultConfiguration(name: application.localizedDisplayName ?? "this app")
        }
        return makeConfig(name: item.name, whyNot: item.whyNot, verb: "use")
    }

    // MARK: - Website Shield

    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        guard let token = webDomain.token,
              let item = store.blockedItems.first(where: { $0.webDomainToken == token }) else {
            return defaultConfiguration(name: webDomain.domain ?? "this website")
        }
        return makeConfig(name: item.name, whyNot: item.whyNot, verb: "visit")
    }

    // MARK: - Shared Config

    private func makeConfig(name: String, whyNot: String, verb: String) -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial,
            backgroundColor: warmBg,
            icon: UIImage(systemName: "hand.raised.fill")?
                .withTintColor(warmAccent, renderingMode: .alwaysOriginal),
            title: ShieldConfiguration.Label(
                text: "You don't want to \(verb) \(name)",
                color: warmDark
            ),
            subtitle: ShieldConfiguration.Label(
                text: "\"\(whyNot)\"",
                color: warmGray
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "You're right — close it",
                color: .white
            ),
            primaryButtonBackgroundColor: warmSage,
            secondaryButtonLabel: ShieldConfiguration.Label(
                text: "I need to \(verb) it…",
                color: warmRose
            )
        )
    }

    // MARK: - Fallback

    private func defaultConfiguration(name: String) -> ShieldConfiguration {
        ShieldConfiguration(
            backgroundBlurStyle: .systemUltraThinMaterial,
            backgroundColor: warmBg,
            icon: UIImage(systemName: "hand.raised.fill")?
                .withTintColor(warmAccent, renderingMode: .alwaysOriginal),
            title: ShieldConfiguration.Label(
                text: "You chose to avoid \(name)",
                color: warmDark
            ),
            subtitle: ShieldConfiguration.Label(
                text: "Open Why Not? to manage your list.",
                color: warmGray
            ),
            primaryButtonLabel: ShieldConfiguration.Label(
                text: "Close",
                color: .white
            ),
            primaryButtonBackgroundColor: warmGray
        )
    }
}
#endif
