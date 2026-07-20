import SwiftUI

struct SidebarView: View {
    @EnvironmentObject private var model: LibraryViewModel
    @State private var editingFolder: FolderRecord?
    @State private var folderName = ""

    var body: some View {
        List(selection: Binding<LibraryScope?>(
            get: { model.selectedScope },
            set: { if let value = $0 { model.selectedScope = value } }
        )) {
            Section("ספרייה") {
                Label("כל המסמכים", systemImage: "doc.text")
                    .tag(LibraryScope.all)
                Label("מועדפים", systemImage: "star")
                    .tag(LibraryScope.favorites)
            }

            Section("תיקיות") {
                ForEach(model.folders) { folder in
                    Label(folder.name, systemImage: "folder")
                        .tag(LibraryScope.folder(folder.id))
                        .contextMenu {
                            Button("שינוי שם") {
                                editingFolder = folder
                                folderName = folder.name
                            }
                            Button("מחיקה", role: .destructive) {
                                model.deleteFolder(folder.id)
                            }
                        }
                }
            }
        }
        .navigationTitle("Dav Writer")
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button(action: model.createFolder) {
                    Label("תיקייה חדשה", systemImage: "folder.badge.plus")
                }
            }
        }
        .alert("שינוי שם תיקייה", isPresented: Binding(
            get: { editingFolder != nil },
            set: { if !$0 { editingFolder = nil } }
        )) {
            TextField("שם", text: $folderName)
            Button("שמירה") {
                if let editingFolder {
                    model.renameFolder(editingFolder.id, to: folderName)
                }
                editingFolder = nil
            }
            Button("ביטול", role: .cancel) { editingFolder = nil }
        }
    }
}
