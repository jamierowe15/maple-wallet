import Core
import Testing
@testable import Transfers

@MainActor
struct TransferViewModelTests {
    private func makeViewModel(_ result: Result<String, UserFacingError> = .success("MW-1")) -> TransferViewModel {
        TransferViewModel(accounts: Account.samples, service: MockTransfersService(result: result, delay: .zero))
    }

    @Test func preselectsTwoDifferentAccounts() {
        let viewModel = makeViewModel()
        #expect(viewModel.fromID == "chq-001")
        #expect(viewModel.toID == "sav-002")
    }

    @Test func prefillsRepeatedAmount() {
        let viewModel = TransferViewModel(accounts: Account.samples, service: MockTransfersService(),
                                          prefillAmount: Money(minorUnits: -4215))
        #expect(viewModel.amountText == "42.15")
    }

    @Test func requiresAnAmount() {
        let viewModel = makeViewModel()
        #expect(viewModel.validationMessage == "Enter an amount greater than zero.")
        #expect(!viewModel.canReview)
    }

    @Test func blocksSameAccount() {
        let viewModel = makeViewModel()
        viewModel.toID = viewModel.fromID
        viewModel.amountText = "10"
        #expect(viewModel.validationMessage == "Choose two different accounts.")
    }

    @Test func blocksMoreThanTheBalance() {
        let viewModel = makeViewModel()
        viewModel.amountText = "5000"
        #expect(viewModel.validationMessage?.contains("more than the balance") == true)
    }

    @Test func confirmsTransfer() async {
        let viewModel = makeViewModel()
        viewModel.amountText = "25"
        viewModel.review()
        #expect(viewModel.phase == .reviewing)
        await viewModel.confirm()
        #expect(viewModel.phase == .done(confirmation: "MW-1"))
    }

    @Test func showsFriendlyFailure() async {
        let viewModel = makeViewModel(.failure(.generic))
        viewModel.amountText = "25"
        viewModel.review()
        await viewModel.confirm()
        #expect(viewModel.phase == .failed(.generic))
    }

    @Test func startOverClearsAmount() async {
        let viewModel = makeViewModel()
        viewModel.amountText = "25"
        await viewModel.confirm()
        viewModel.startOver()
        #expect(viewModel.amountText.isEmpty)
        #expect(viewModel.phase == .editing)
    }
}
