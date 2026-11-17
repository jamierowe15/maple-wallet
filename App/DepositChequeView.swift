import AVFoundation
import DesignSystem
import SwiftUI
import UIKit

/// Mock screen that exists to practise permissions: ask at the moment of use, handle "denied".
struct DepositChequeView: View {
    @State private var status = AVCaptureDevice.authorizationStatus(for: .video)
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: Spacing.l) {
            switch status {
            case .authorized:
                Label("Camera ready. (Demo only: no photo is taken.)", systemImage: "camera.fill")
            case .denied, .restricted:
                Text("Camera access is off. Turn it on in Settings to deposit a cheque.")
                    .multilineTextAlignment(.center)
                PrimaryButton("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
                }
            default:
                Text("We'll ask to use your camera to photograph the cheque.")
                    .multilineTextAlignment(.center)
                PrimaryButton("Scan cheque") {
                    Task {
                        _ = await AVCaptureDevice.requestAccess(for: .video)
                        status = AVCaptureDevice.authorizationStatus(for: .video)
                    }
                }
            }
        }
        .padding(Spacing.l)
        .navigationTitle("Deposit a cheque")
    }
}
