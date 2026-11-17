#if canImport(UIKit)
import SwiftUI

public struct PrimaryButton: View {
    private let title: String
    private let isLoading: Bool
    private let action: () -> Void

    public init(_ title: String, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                Text(title).font(.headline).opacity(isLoading ? 0 : 1)
                if isLoading { ProgressView().tint(.white) }
            }
            .frame(maxWidth: .infinity, minHeight: 50)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: Radius.button))
        .tint(Palette.brand)
        .disabled(isLoading)
        .accessibilityLabel(isLoading ? "\(title), in progress" : title)
    }
}
#endif
