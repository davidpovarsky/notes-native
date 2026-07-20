import SwiftUI
import UniformTypeIdentifiers

struct LibraryView: View {
    @EnvironmentObject private var model: LibraryViewModel
    @State private var isImporting = false
    @State private var isShowingSettings = false

    var body: some View {
        NavigationSplitView {
            SidebarView()
                .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 320)
        } content: {
            DocumentListView()
                .navigationSplitViewColumnWidth(min: 260, ideal: 320, max: 420)
        } detail: {
            Group {
                if let document = model.selectedDocument {
                    EditorScreen(
                        document: document,
                        onSave: { title, content in
                            model.updateDocument(id: document.id, title: title, attributedText: content)
                        },
                        onDelete: { model.deleteDocument(document.id) },
                        onDuplicate: { model.duplicateDocument(document.id) }
                    )
                    .id(document.id)
                } else {
                    EmptyStateView(action: model.createDocument)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button(action: model.createDocument) {
                    Label("מסמך חדש", systemImage: "square.and.pencil")
                }
                Button {
                    isImporting = true
                } label: {
                    Label("ייבוא", systemImage: "square.and.arrow.down")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingSettings = true
                } label: {
                    Label("הגדרות", systemImage: "gearshape")
                }
            }
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: ImportService.supportedTypes,
            allowsMultipleSelection: false
        ) { result in
            do {
                guard let url = try result.get().first else { return }
                let imported = try ImportService.loadDocument(from: url)
                model.importDocument(title: imported.title, content: imported.content)
            } catch {
                model.errorMessage = error.localizedDescription
            }
        }
        .sheet(isPresented: $isShowingSettings) {
            NavigationStack { SettingsView() }
        }
        .alert("שגיאה", isPresented: Binding(
            get: { model.errorMessage != nil },
            set: { if !$0 { model.errorMessage = nil } }
        )) {
            Button("אישור", role: .cancel) {}
        } message: {
            Text(model.errorMessage ?? "")
        }
    }
}
