import SwiftUI

struct EmptyStateView: View {
    let action: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("אין מסמך פתוח", systemImage: "doc.richtext")
        } description: {
            Text("בחר מסמך מן הרשימה או צור מסמך חדש.")
        } actions: {
            Button("מסמך חדש", action: action)
                .buttonStyle(.borderedProminent)
        }
    }
}
