import Core
import Testing
@testable import Transfers

@MainActor
struct TransferLeakTests {
    @Test func transferViewModelIsFreedAfterSubmitting() async {
        weak var weakViewModel: TransferViewModel?
        do {
            let viewModel = TransferViewModel(accounts: Account.samples,
                                              service: MockTransfersService(delay: .zero))
            weakViewModel = viewModel
            viewModel.amountText = "10"
            await viewModel.confirm()
        }
        #expect(weakViewModel == nil)
    }
}
