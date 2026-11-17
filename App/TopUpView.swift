import Core
import DesignSystem
import PassKit
import SwiftUI

/// Apple Pay top-up. A real merchant ID needs a paid Apple Developer account,
/// so the button only appears where Apple Pay is set up.
struct TopUpView: View {
    @State private var amountText = "25.00"
    @State private var coordinator = ApplePayCoordinator()
    @State private var resultMessage: String?
    private let networks: [PKPaymentNetwork] = [.interac, .visa, .masterCard]

    var body: some View {
        Form {
            Section {
                TextField("Amount", text: $amountText)
                    .keyboardType(.decimalPad)
            } header: { SectionHeader("Amount") }
            Section {
                if PKPaymentAuthorizationController.canMakePayments(usingNetworks: networks) {
                    PayWithApplePayButton(.topUp) { startPayment() }
                        .frame(height: 48)
                } else {
                    Text("Apple Pay isn't set up on this device.")
                        .foregroundStyle(Palette.textSecondary)
                }
            }
            if let resultMessage {
                Section { Text(resultMessage) }
            }
        }
        .navigationTitle("Top up")
    }

    private func startPayment() {
        let request = PKPaymentRequest()
        request.merchantIdentifier = "merchant.com.jamierowe.maplewallet"
        request.countryCode = "CA"
        request.currencyCode = "CAD"
        request.supportedNetworks = networks
        request.merchantCapabilities = [.threeDSecure, .debit, .credit]
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "Maple Wallet top-up", amount: NSDecimalNumber(string: amountText)),
        ]
        coordinator.pay(request) { succeeded in
            resultMessage = succeeded ? "Top-up complete." : "Top-up didn't go through."
        }
    }
}

/// Receives Apple Pay's callbacks. The app never sees the card number: Apple gives it an
/// encrypted payment token that only the payment processor can read. The app sends that
/// token to its own server, which charges it through the processor and replies yes or no.
@MainActor
final class ApplePayCoordinator: NSObject, PKPaymentAuthorizationControllerDelegate {
    private var controller: PKPaymentAuthorizationController?
    private var onFinish: ((Bool) -> Void)?
    private var succeeded = false

    func pay(_ request: PKPaymentRequest, onFinish: @escaping (Bool) -> Void) {
        let controller = PKPaymentAuthorizationController(paymentRequest: request)
        controller.delegate = self
        self.controller = controller
        self.onFinish = onFinish
        succeeded = false
        controller.present { presented in
            if !presented { Task { @MainActor in self.finish() } }
        }
    }

    // Apple calls these on the main actor, the same isolation as this class,
    // so Apple Pay's (non-Sendable) objects never cross threads.
    func paymentAuthorizationController(
        _ controller: PKPaymentAuthorizationController,
        didAuthorizePayment payment: PKPayment
    ) async -> PKPaymentAuthorizationResult {
        let token = payment.token.paymentData // Data is Sendable
        let accepted = await DemoPaymentServer.charge(token: token)
        succeeded = accepted
        return PKPaymentAuthorizationResult(status: accepted ? .success : .failure, errors: nil)
    }

    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        controller.dismiss(completion: nil)
        finish()
    }

    private func finish() {
        onFinish?(succeeded)
        onFinish = nil
        controller = nil
    }
}

/// Stands in for the bank's server. A real one forwards the token to a processor such as
/// Moneris or Stripe over a secure connection and returns the processor's answer.
enum DemoPaymentServer {
    static func charge(token: Data) async -> Bool {
        try? await Task.sleep(for: .milliseconds(600))
        return true // the Simulator's token is empty; accept it for the demo
    }
}
