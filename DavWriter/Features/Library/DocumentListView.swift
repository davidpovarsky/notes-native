import SwiftUI

struct DocumentListView: View {
    @EnvironmentObject private var model: LibraryViewModel

    var body: some View {
        List(selection: $model.selectedDocumentID) {
            ForEach(model.visibleDocuments) { document in
                DocumentRowView(document: document)
                    .tag(document.id)
                    .contextMenu {
                        Button(document.isFavorite ? "הסר ממועדפים" : "הוסף למועדפים") {
                            model.toggleFavorite(document.id)
                        }
                        Button("שכפול") {
                            model.duplicateDocument(document.id)
                        }
                        Menu("העבר לתיקייה") {
                            Button("ללא תיקייה") { model.moveDocument(document.id, to: nil) }
                            ForEach(model.folders) { folder in
                                Button(folder.name) { model.moveDocument(document.id, to: folder.id) }
                            }
                        }
                        Divider()
                        Button("מחיקה", role: .destructive) {
                            model.deleteDocument(document.id)
                        }
                    }
            }
        }
        .overlay {
            if model.visibleDocuments.isEmpty {
                ContentUnavailableView(
                    "לא נמצאו מסמכים",
                    systemImage: "doc.text.magnifyingglass",
                    description: Text("צור מסמך חדש או שנה את החיפוש.")
                )
            }
        }
        .navigationTitle(title)
        .searchable(text: $model.searchQuery, prompt: "חיפוש במסמכים")
    }

    private var title: String {
        switch model.selectedScope {
        case .all: return "כל המסמכים"
        case .favorites: return "מועדפים"
        case .folder(let id): return model.folders.first(where: { $0.id == id })?.name ?? "תיקייה"
        }
    }
}
