import OpenConnectKit
import SwiftUI

struct LogView: View {
  let entries: [LogEntry]

  var body: some View {
    ScrollViewReader { proxy in
      List(entries) { entry in
        HStack(alignment: .top, spacing: 8) {
          Text(entry.timestamp, format: .dateTime.hour().minute().second())
            .font(.caption.monospacedDigit())
            .foregroundStyle(.secondary)

          Text(entry.level.rawValue.uppercased())
            .font(.caption.monospaced().bold())
            .foregroundStyle(color(for: entry.level))
            .frame(width: 44, alignment: .leading)

          Text(entry.message)
            .font(.caption.monospaced())
            .textSelection(.enabled)
        }
      }
      .onChange(of: entries.count) {
        if let last = entries.last {
          proxy.scrollTo(last.id, anchor: .bottom)
        }
      }
    }
  }

  private func color(for level: LogLevel) -> Color {
    switch level {
    case .error: .red
    case .info: .primary
    case .debug: .secondary
    case .trace: .gray
    }
  }
}

#Preview {
  LogView(entries: [
    LogEntry(level: .info, message: "Connecting to server..."),
    LogEntry(level: .debug, message: "CSTP connected"),
    LogEntry(level: .error, message: "Connection failed"),
  ])
}
