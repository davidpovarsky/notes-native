import SwiftUI

@main
struct DavWriterApp: App {
    @StateObject private var libraryModel = LibraryViewModel()
    @AppStorage("forceRTL") private var forceRTL = true

    var body: some Scene {
        WindowGroup {
            LibraryView()
                .environmentObject(libraryModel)
                .environment(\.layoutDirection, forceRTL ? .rightToLeft : .leftToRight)
                .task {
                    await libraryModel.loadIfNeeded()
                }
        }
        .commands {
            CommandGroup(after: .newItem) {
                Button("מסמך חדש") {
                    libraryModel.createDocument()
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }
}
