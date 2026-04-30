import SwiftUI

@main
struct SwiftConnectApp: App {
  @State private var model = AppModel()


  var body: some Scene {
    WindowGroup {
      ContentView(model: model)
    }
    .defaultSize(width: 500, height: 600)
  }
}
