#if canImport(UIKit)
import Core
import DesignSystem
import SwiftUI

public struct TransferView: View {
    @State private var viewModel: TransferViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @FocusState private var amountFocused: Bool

    public init(viewModel: TransferViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            Group {
                switch viewModel.phase {
                case .editing:
                    form.stepTransition()
                case .reviewing, .submitting:
                    review.stepTransition()
                case .done(let confirmation):
                    done(confirmation).stepTransition()
                case .failed(let error):
                    EmptyStateView(title: error.title, message: error.message,
                                   systemImage: "exclamationmark.triangle", actionTitle: "Back") { viewModel.edit() }
                }
            }
            .animation(.standard(reduceMotion: reduceMotion), value: viewModel.phase)
            .navigationTitle("Transfer")
        }
        .onChange(of: viewModel.phase) { _, phase in announce(phase) }
    }

    private var form: some View {
        Form {
            // Inline pickers list every account as a full row, so long names wrap
            // instead of being cut to "Ever...34.56" at large text sizes.
            Section {
                Picker("From account", selection: $viewModel.fromID) {
                    ForEach(viewModel.accounts) { account in
                        AccountOption(account: account).tag(Optional(account.id))
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
                .accessibilityIdentifier("transfer.from")
            } header: { SectionHeader("From") }
            Section {
                Picker("To account", selection: $viewModel.toID) {
                    ForEach(viewModel.accounts) { account in
                        AccountOption(account: account).tag(Optional(account.id))
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
                .accessibilityIdentifier("transfer.to")
            } header: { SectionHeader("To") }
            Section {
                TextField("Amount in dollars", text: $viewModel.amountText,
                          prompt: Text("Amount in dollars").foregroundStyle(Palette.textSecondary))
                    .keyboardType(.decimalPad)
                    .focused($amountFocused)
                    .accessibilityIdentifier("transfer.amount")
                if !viewModel.amountText.isEmpty, let message = viewModel.validationMessage {
                    Label(message, systemImage: "exclamationmark.circle")
                        .font(.footnote)
                        .foregroundStyle(Palette.brand)
                }
            } header: { SectionHeader("Amount") }
            Section {
                PrimaryButton("Review transfer") {
                    amountFocused = false
                    viewModel.review()
                }
                .disabled(!viewModel.canReview)
                .accessibilityIdentifier("transfer.review")
                .listRowInsets(EdgeInsets())
            }
        }
    }

    private var review: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.m) {
                Text("Review transfer")
                    .font(.title2.bold())
                    .accessibilityAddTraits(.isHeader)
                LabeledContent("From") { Text(viewModel.from?.name ?? "").foregroundStyle(Palette.textPrimary) }
                LabeledContent("To") { Text(viewModel.to?.name ?? "").foregroundStyle(Palette.textPrimary) }
                LabeledContent("Amount") {
                    Text(viewModel.amount?.formatted() ?? "")
                        .foregroundStyle(Palette.textPrimary)
                        .accessibilityLabel(viewModel.amount?.spokenDescription() ?? "")
                }
                PrimaryButton("Confirm transfer", isLoading: viewModel.phase == .submitting) {
                    Task { await viewModel.confirm() }
                }
                .accessibilityHint("Sends the money now.")
                .accessibilityIdentifier("transfer.confirm")
                Button("Edit") { viewModel.edit() }
                    .frame(maxWidth: .infinity)
                    .disabled(viewModel.phase == .submitting)
            }
            .padding(Spacing.l)
        }
    }

    private func done(_ confirmation: String) -> some View {
        VStack(spacing: Spacing.m) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(Palette.credit)
                .accessibilityHidden(true)
            Text("Transfer sent").font(.title2.bold()).accessibilityAddTraits(.isHeader)
            Text("Confirmation \(confirmation)").font(.body.monospaced())
            PrimaryButton("Make another transfer") { viewModel.startOver() }
        }
        .padding(Spacing.l)
        .accessibilityIdentifier("transfer.done")
    }

    private func announce(_ phase: TransferViewModel.Phase) {
        switch phase {
        case .done: AccessibilityNotification.Announcement("Transfer sent").post()
        case .failed(let error): AccessibilityNotification.Announcement("Transfer failed. \(error.message)").post()
        default: break
        }
    }
}

/// One account in the From/To pickers: name, then balance on its own line.
private struct AccountOption: View {
    let account: Account

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(account.name)
                .foregroundStyle(Palette.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            Text("Balance \(account.balance.formatted())")
                .font(.subheadline)
                .foregroundStyle(Palette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#if DEBUG
#Preview {
    TransferView(viewModel: TransferViewModel(accounts: Account.samples, service: MockTransfersService()))
}
#endif
#endif
