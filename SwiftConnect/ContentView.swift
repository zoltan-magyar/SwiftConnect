import OpenConnectKit
import SwiftUI

struct ContentView: View {
  @Bindable var model: AppModel
  @State private var logEntries: [LogEntry] = []

  var body: some View {
    VStack(spacing: 0) {
      ConnectionFormView(model: model)
        .padding()

      Divider()

      StatusView(session: model.session)
        .padding()

      Divider()

      LogView(entries: logEntries)
    }
    .task {
      for await entry in model.session.logs {
        logEntries.append(entry)
      }
    }
    .sheet(
      isPresented: .init(
        get: { model.handler.pendingAuthForm != nil },
        set: { if !$0 { model.handler.cancelAuth() } }
      )
    ) {
      if let form = model.handler.pendingAuthForm {
        AuthFormView(form: form) { filledForm in
          model.handler.submitAuth(filledForm)
        } onCancel: {
          model.handler.cancelAuth()
        }
      }
    }
    .alert(
      "Certificate Validation",
      isPresented: .init(
        get: { model.handler.pendingCertInfo != nil },
        set: { if !$0 { model.handler.rejectCertificate() } }
      )
    ) {
      Button("Accept") { model.handler.acceptCertificate() }
      Button("Reject", role: .cancel) { model.handler.rejectCertificate() }
    } message: {
      if let info = model.handler.pendingCertInfo {
        Text(info.reason)
      }
    }
  }
}
