import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var model: LibraryViewModel
    @Environment(\.dismiss) private var dismiss
    @AppStorage("forceRTL") private var forceRTL = true
    @AppStorage("showWordCount") private var showWordCount = true
    @State private var isConfirmingReset = false

    var body: some View {
        Form {
            Section("עברית וכיוון") {
                Toggle("ממשק מימין לשמאל", isOn: $forceRTL)
                Toggle("הצג ספירת מילים", isOn: $showWordCount)
            }

            Section("אחסון") {
                Text("המסמכים נשמרים מקומית במכשיר. אין חשבון ואין שירות ענן חיצוני.")
                    .foregroundStyle(.secondary)
                Button("איפוס לספריית הדגמה", role: .destructive) {
                    isConfirmingReset = true
                }
            }

            Section("אודות") {
                LabeledContent("גרסה", value: "0.1.0")
                Text("SwiftUI + UIKit/TextKit 2. ללא WebView.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("הגדרות")
        .toolbar {
            Button("סגירה") { dismiss() }
        }
        .confirmationDialog("לאפס את כל המסמכים?", isPresented: $isConfirmingReset, titleVisibility: .visible) {
            Button("איפוס", role: .destructive) {
                Task { await model.resetSampleData() }
            }
            Button("ביטול", role: .cancel) {}
        }
    }
}
