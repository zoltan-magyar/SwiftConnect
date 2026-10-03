import Foundation
import OpenConnectKit

@Observable
@MainActor
final class AppModel {
  /// Publishes the session's authentication and certificate prompts for the views.
  let prompts = VPNPrompts()
  let session: VPNSession

  var serverURL: String = "https://"
  var selectedProtocol: VPNProtocol = .anyConnect
  var logLevel: LogLevel = .info

  init() {
    self.session = VPNSession(delegate: prompts)
  }

  // MARK: - Computed State

  var canConnect: Bool {
    !session.status.isActive && !serverURL.isEmpty
  }

  var canDisconnect: Bool {
    switch session.status {
    case .connected, .connecting, .reconnecting:
      return true
    case .disconnected, .disconnecting:
      return false
    }
  }

  // MARK: - Actions

  func connect() async {
    guard let url = URL(string: serverURL) else { return }
    let config = VPNConfiguration(
      serverURL: url,
      vpnProtocol: selectedProtocol,
      logLevel: logLevel
    )
    do {
      try await session.connect(using: config)
    } catch {
      // The error is also kept in session.lastError, which StatusView shows.
    }
  }

  func disconnect() async {
    await session.disconnect()
  }
}
