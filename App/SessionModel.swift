import Auth
import Core
import Observation

@Observable @MainActor
final class SessionModel {
    enum Phase: Equatable { case checking, signedOut, signingIn, signedIn }

    private(set) var phase: Phase = .checking
    private(set) var error: UserFacingError?

    private let service: SignInService
    private let onSignOut: @MainActor () async -> Void

    init(service: SignInService, onSignOut: @escaping @MainActor () async -> Void) {
        self.service = service
        self.onSignOut = onSignOut
    }

    func restore() async {
        phase = await service.isSignedIn() ? .signedIn : .signedOut
    }

    func signIn() async {
        phase = .signingIn
        error = nil
        do {
            try await service.signIn()
            phase = .signedIn
        } catch {
            self.error = UserFacingError.from(error)
            phase = .signedOut
        }
    }

    func signOut() async {
        await service.signOut()
        await onSignOut()
        phase = .signedOut
    }
}
