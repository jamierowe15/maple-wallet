import Observation
import UIKit
import UserNotifications

/// Holds a link that arrived from a notification until the UI is ready for it.
@Observable @MainActor
final class DeepLinkInbox {
    static let shared = DeepLinkInbox()
    var pendingURL: URL?
}

@MainActor
final class AppDelegate: NSObject, UIApplicationDelegate, @preconcurrency UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        if CompositionRoot.isUITesting { UIView.setAnimationsEnabled(false) }
        return true
    }

    // Main-actor, completion-handler versions: the notification objects never leave the main thread.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound])
    }

    /// Tapping "Transfer received" opens that transaction.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if let link = response.notification.request.content.userInfo["deepLink"] as? String,
           let url = URL(string: link) {
            DeepLinkInbox.shared.pendingURL = url
        }
        completionHandler()
    }
}
