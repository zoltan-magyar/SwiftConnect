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
    .sheet(item: Bindable(model.prompts).pendingAuthentication) { prompt in
      AuthFormView(form: prompt.form) { filledForm in
        model.prompts.submit(filledForm)
      } onCancel: {
        model.prompts.cancelAuthentication()
      }
    }
    .alert(
      "Certificate Validation",
      isPresented: Bindable(model.prompts).isCertificatePending,
      presenting: model.prompts.pendingCertificate
    ) { _ in
      Button("Accept") { model.prompts.acceptCertificate() }
      Button("Reject", role: .cancel) { model.prompts.rejectCertificate() }
    } message: { prompt in
      // The system's reason already names the host, e.g. "“vpn.example.com” certificate is not
      // trusted".
      Text(prompt.reason)
    }
  }
}
