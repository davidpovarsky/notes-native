import SwiftUI

struct EditorScreen: View {
    @StateObject private var viewModel: EditorViewModel
    @StateObject private var editorController = RichTextEditorController()
    @StateObject private var toolRegistry = DocumentToolRegistry()
    @AppStorage("forceRTL") private var forceRTL = true
    @State private var isShowingTools = true
    @State private var isShowingInspector = false

    private let onDelete: () -> Void
    private let onDuplicate: () -> Void

    init(
        document: DocumentRecord,
        onSave: @escaping (String, NSAttributedString) -> Void,
        onDelete: @escaping () -> Void,
        onDuplicate: @escaping () -> Void
    ) {
        _viewModel = StateObject(wrappedValue: EditorViewModel(document: document, onSave: onSave))
        self.onDelete = onDelete
        self.onDuplicate = onDuplicate
    }

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                TextField("כותרת המסמך", text: $viewModel.title)
                    .font(.title2.bold())
                    .textFieldStyle(.plain)
                    .multilineTextAlignment(forceRTL ? .trailing : .leading)
                    .padding(.horizontal, 30)
                    .padding(.top, 18)
                    .padding(.bottom, 8)
                    .onChange(of: viewModel.title) { _, _ in viewModel.titleChanged() }

                FormattingToolbar(controller: editorController)

                RichTextEditor(
                    attributedText: $viewModel.attributedText,
                    controller: editorController,
                    forceRTL: forceRTL,
                    onChange: viewModel.contentChanged
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            if isShowingTools {
                Divider()
                DocumentToolPanel(
                    registry: toolRegistry,
                    controller: editorController,
                    documentTitle: viewModel.title
                )
                .frame(minWidth: 260, idealWidth: 310, maxWidth: 360)
            }
        }
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    isShowingTools.toggle()
                } label: {
                    Label("כלים", systemImage: "wrench.and.screwdriver")
                }
                Menu {
                    ForEach(ExportService.Format.allCases) { format in
                        Button(format.title) {
                            viewModel.export(format)
                        }
                    }
                } label: {
                    Label("ייצוא", systemImage: "square.and.arrow.up")
                }
                Button {
                    isShowingInspector = true
                } label: {
                    Label("פרטים", systemImage: "info.circle")
                }
                Menu {
                    Button("שכפול", action: onDuplicate)
                    Button("מחיקה", role: .destructive, action: onDelete)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $isShowingInspector) {
            DocumentInspectorView(
                title: viewModel.title,
                plainText: viewModel.attributedText.string
            )
        }
        .sheet(isPresented: Binding(
            get: { viewModel.exportURL != nil },
            set: { if !$0 { viewModel.exportURL = nil } }
        )) {
            if let url = viewModel.exportURL {
                ActivityView(items: [url])
            }
        }
        .alert("שגיאה", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("אישור", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onDisappear {
            viewModel.flushSave()
        }
    }
}


private struct ActivityView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
