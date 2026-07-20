import SwiftUI

struct DocumentToolPanel: View {
    @ObservedObject var registry: DocumentToolRegistry
    @ObservedObject var controller: RichTextEditorController
    let documentTitle: String

    @State private var isRunning = false
    @State private var resultTitle: String?
    @State private var resultBody: String?
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PanelHeader(title: "כלים", systemImage: "wrench.and.screwdriver")

            List {
                Section {
                    ForEach(registry.tools, id: \.id) { tool in
                        Button {
                            run(tool)
                        } label: {
                            Label(tool.title, systemImage: tool.systemImage)
                        }
                        .disabled(isRunning || (tool.requiresSelection && controller.selectedText.isEmpty))
                    }
                }

                if let resultTitle, let resultBody {
                    Section(resultTitle) {
                        Text(resultBody)
                            .textSelection(.enabled)
                        Button("הכנס למסמך") {
                            controller.replaceSelection(with: resultBody)
                        }
                    }
                }
            }
            .listStyle(.sidebar)

            if isRunning {
                ProgressView("מריץ כלי…")
                    .padding()
            }
        }
        .background(.regularMaterial)
        .alert("שגיאת כלי", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("אישור", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func run(_ tool: AnyDocumentTool) {
        let context = DocumentToolContext(
            documentTitle: documentTitle,
            fullText: controller.currentPlainText(),
            selectedText: controller.selectedText,
            selectionRange: controller.selectionRange
        )
        isRunning = true
        Task {
            defer { isRunning = false }
            do {
                let output = try await tool.run(context: context)
                apply(output)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func apply(_ output: DocumentToolOutput) {
        switch output {
        case .replaceSelection(let attributed):
            controller.replaceSelection(with: attributed)
        case .insertAtCaret(let attributed):
            controller.replaceSelection(with: attributed)
        case .showResult(let title, let body):
            resultTitle = title
            resultBody = body
        case .none:
            break
        }
    }
}
