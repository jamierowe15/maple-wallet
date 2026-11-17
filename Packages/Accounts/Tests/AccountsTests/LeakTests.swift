import Core
import Testing
@testable import Accounts

/// Retain-cycle checks: once the last strong reference is gone, each object must be freed.
/// This is the unit-test version of what Instruments' Leaks tool looks for.
@MainActor
struct LeakTests {
    @Test func accountsViewModelIsFreed() async {
        weak var weakViewModel: AccountsViewModel?
        do {
            let viewModel = AccountsViewModel(service: MockAccountsService(delay: .zero), cache: InMemoryAccountsCache())
            weakViewModel = viewModel
            await viewModel.load()
        }
        #expect(weakViewModel == nil)
    }

    @Test func detailViewModelIsFreed() async {
        weak var weakViewModel: AccountDetailViewModel?
        do {
            let viewModel = AccountDetailViewModel(accountID: "chq-001", service: MockAccountsService(delay: .zero))
            weakViewModel = viewModel
            await viewModel.load()
        }
        #expect(weakViewModel == nil)
    }
}

/// Before: the classic retain cycle. The object owns a closure, and the closure owns the object.
final class LeakyTicker {
    var onTick: (() -> Void)?
    private(set) var ticks = 0

    init() {
        onTick = { self.ticks += 1 } // strong self: self -> closure -> self, never freed
    }
}

/// After: capture self weakly and the cycle is gone.
final class FixedTicker {
    var onTick: (() -> Void)?
    private(set) var ticks = 0

    init() {
        onTick = { [weak self] in self?.ticks += 1 }
    }
}

struct RetainCycleDemoTests {
    @Test func strongCaptureLeaks() {
        weak var weakTicker: LeakyTicker?
        do {
            let ticker = LeakyTicker()
            weakTicker = ticker
            ticker.onTick?()
        }
        #expect(weakTicker != nil, "The cycle keeps it alive: this is the leak Instruments would report")
        weakTicker?.onTick = nil // break the cycle so the test run itself stays leak-free
    }

    @Test func weakCaptureIsFreed() {
        weak var weakTicker: FixedTicker?
        do {
            let ticker = FixedTicker()
            weakTicker = ticker
            ticker.onTick?()
        }
        #expect(weakTicker == nil)
    }
}
