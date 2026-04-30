import OpenConnectKit
import SwiftUI

struct AuthFormView: View {
  @State private var form: AuthenticationForm
  let onSubmit: (AuthenticationForm) -> Void
  let onCancel: () -> Void

  init(
    form: AuthenticationForm,
    onSubmit: @escaping (AuthenticationForm) -> Void,
    onCancel: @escaping () -> Void
  ) {
    _form = State(initialValue: form)
    self.onSubmit = onSubmit
    self.onCancel = onCancel
  }

  var body: some View {
    VStack(spacing: 16) {
      if let title = form.title {
        Text(title)
          .font(.headline)
      }

      if let message = form.message {
        Text(message)
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }

      Form {
        ForEach(form.fields.indices, id: \.self) { index in
          fieldView(for: index)
        }
      }
      .formStyle(.grouped)

      HStack {
        Button("Cancel", role: .cancel) { onCancel() }
          .keyboardShortcut(.escape)

        Button("Submit") { onSubmit(form) }
          .keyboardShortcut(.return)
      }
    }
    .padding()
    .frame(minWidth: 350)
  }

  @ViewBuilder
  private func fieldView(for index: Int) -> some View {
    let field = form.fields[index]
    switch field.type {
    case .hidden:
      EmptyView()
    case .password:
      SecureField(field.label, text: $form.fields[index].value)
    case .text:
      TextField(field.label, text: $form.fields[index].value)
    case .select(let options):
      Picker(field.label, selection: $form.fields[index].value) {
        ForEach(options, id: \.self) { option in
          Text(option).tag(option)
        }
      }
    }
  }
}
