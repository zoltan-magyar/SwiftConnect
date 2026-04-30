import OpenConnectKit
import SwiftUI

struct ConnectionFormView: View {
  @Bindable var model: AppModel

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      TextField("Server URL", text: $model.serverURL)
        .textFieldStyle(.roundedBorder)

      HStack {
        Picker("Protocol", selection: $model.selectedProtocol) {
          ForEach(VpnProtocol.allCases, id: \.self) { proto in
            Text(proto.rawValue).tag(proto)
          }
        }
        .frame(maxWidth: 200)

        Picker("Log Level", selection: $model.logLevel) {
          Text("Error").tag(LogLevel.error)
          Text("Info").tag(LogLevel.info)
          Text("Debug").tag(LogLevel.debug)
          Text("Trace").tag(LogLevel.trace)
        }
        .frame(maxWidth: 150)
      }

      HStack {
        if model.canConnect {
          Button("Connect") {
            Task { await model.connect() }
          }
          .keyboardShortcut(.return, modifiers: .command)
        }

        if model.canDisconnect {
          Button("Disconnect") {
            model.disconnect()
          }
          .keyboardShortcut(.escape, modifiers: .command)
        }
      }
    }
  }
}
