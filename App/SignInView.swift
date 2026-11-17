import DesignSystem
import SwiftUI

struct SignInView: View {
    let session: SessionModel

    var body: some View {
        VStack(spacing: Spacing.l) {
            Spacer()
            Image(systemName: "leaf.fill")
                .font(.system(size: 64))
                .foregroundStyle(Palette.brand)
                .accessibilityHidden(true)
            Text("Maple Wallet")
                .font(.largeTitle.bold())
                .accessibilityAddTraits(.isHeader)
            Text("A demo banking app. No real money.")
                .foregroundStyle(Palette.textSecondary)
            if let error = session.error {
                Text(error.message)
                    .foregroundStyle(Palette.brand)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            PrimaryButton("Sign in", isLoading: session.phase == .signingIn) {
                Task { await session.signIn() }
            }
            .accessibilityIdentifier("signIn.button")
        }
        .padding(Spacing.l)
    }
}
