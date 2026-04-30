import OpenConnectKit
import SwiftUI

struct StatusView: View {
  var session: VpnSession

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        statusIndicator
        Text(statusText)
          .font(.headline)
      }

      if let ifname = session.interfaceName {
        LabeledContent("Interface", value: ifname)
          .font(.subheadline)
      }

      if let stats = session.stats {
        HStack(spacing: 24) {
          Label(
            "\(stats.formattedTxBytes) (\(stats.txPackets) pkts)",
            systemImage: "arrow.up"
          )
          Label(
            "\(stats.formattedRxBytes) (\(stats.rxPackets) pkts)",
            systemImage: "arrow.down"
          )
        }
        .font(.subheadline.monospacedDigit())
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
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
    case .disconnected(let error):
      error != nil ? .red : .gray
    }
  }

  private var statusText: String {
    switch session.status {
    case .disconnected(let error):
      if let error {
        return "Disconnected: \(error.localizedDescription)"
      }
      return "Disconnected"
    case .connecting(let stage):
      return stage
    case .connected:
      return "Connected"
    case .disconnecting:
      return "Disconnecting..."
    case .reconnecting:
      return "Reconnecting..."
    }
  }
}
