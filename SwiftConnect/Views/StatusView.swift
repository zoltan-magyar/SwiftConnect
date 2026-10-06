import OpenConnectKit
import SwiftUI

struct StatusView: View {
  var session: VPNSession

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        statusIndicator
        Text(statusText)
          .font(.headline)
      }

      if let ifname = session.status.connectionInfo?.interfaceName {
        LabeledContent("Interface", value: ifname)
          .font(.subheadline)
      }

      if let stats = session.stats {
        HStack(spacing: 24) {
          Label(
            "\(byteCount(stats.txBytes)) (\(stats.txPackets) pkts)",
            systemImage: "arrow.up"
          )
          Label(
            "\(byteCount(stats.rxBytes)) (\(stats.rxPackets) pkts)",
            systemImage: "arrow.down"
          )
        }
        .font(.subheadline.monospacedDigit())
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private func byteCount(_ bytes: UInt64) -> String {
    Int64(clamping: bytes).formatted(.byteCount(style: .binary))
  }

  private var statusIndicator: some View {
    Circle()
      .fill(statusColor)
      .frame(width: 10, height: 10)
  }

  private var statusColor: Color {
    switch session.status {
    case .connected:
      .green
    case .connecting, .reconnecting:
      .orange
    case .disconnecting:
      .yellow
    case .disconnected:
      session.lastError != nil ? .red : .gray
    }
  }

  private var statusText: String {
    switch session.status {
    case .disconnected:
      if let error = session.lastError {
        return "Disconnected: \(error.localizedDescription)"
      }
      return "Disconnected"
    case .connecting(let stage):
      return stage.displayText
    case .connected:
      return "Connected"
    case .disconnecting:
      return "Disconnecting..."
    case .reconnecting:
      return "Reconnecting..."
    }
  }
}

extension ConnectionStage {
  fileprivate var displayText: String {
    switch self {
    case .authenticating: "Authenticating..."
    case .establishingTunnel: "Establishing the tunnel..."
    case .settingUpDTLS: "Setting up DTLS..."
    case .configuringNetwork: "Configuring the network..."
    }
  }
}
