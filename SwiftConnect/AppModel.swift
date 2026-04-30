import Foundation
import OpenConnectKit

@Observable
@MainActor
final class AppModel {
  let session: VpnSession
  let handler: VpnHandler

  var serverURL: String = "https://"
  var selectedProtocol: VpnProtocol = .anyConnect
  var logLevel: LogLevel = .info

  init() {
    let handler = VpnHandler()
    self.handler = handler
    self.session = VpnSession(delegate: handler)
  }

  // MARK: - Computed State

  var canConnect: Bool {
    if case .disconnected = session.status {
      return !serverURL.isEmpty
    }
    return false
  }

  var canDisconnect: Bool {
    switch session.status {
    case .connected, .connecting, .reconnecting:
      return true
    default:
      return false
    }
  }

  var statusText: String {
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

  // MARK: - Actions

  func connect() async {
    guard let url = URL(string: serverURL) else { return }
    let config = VpnConfiguration(
      serverURL: url,
      vpnProtocol: selectedProtocol,
      logLevel: logLevel
    )
    do {
      try await session.connect(configuration: config)
    } catch {
      // Error is reflected in session.status
    }
  }

  func disconnect() {
    session.disconnect()
  }
}
