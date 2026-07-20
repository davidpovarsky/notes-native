import Foundation
import SwiftUI

@MainActor
final class LibraryViewModel: ObservableObject {
    @Published private(set) var folders: [FolderRecord] = []
    @Published private(set) var documents: [DocumentRecord] = []
    @Published var selectedScope: LibraryScope = .all
    @Published var selectedDocumentID: UUID?
    @Published var searchQuery = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repository: DocumentRepository
    private var hasLoaded = false

    init(repository: DocumentRepository = DocumentRepository()) {
        self.repository = repository
    }

    var selectedDocument: DocumentRecord? {
        documents.first { $0.id == selectedDocumentID }
    }

    var visibleDocuments: [DocumentRecord] {
        SearchService.filter(documents: documents, query: searchQuery, scope: selectedScope)
    }

    func loadIfNeeded() async {
        guard !hasLoaded else { return }
        hasLoaded = true
        isLoading = true
        defer { isLoading = false }

        do {
            let snapshot = try await repository.load()
            folders = snapshot.folders.sorted { $0.sortOrder < $1.sortOrder }
            documents = snapshot.documents
            selectedDocumentID = visibleDocuments.first?.id
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func createFolder() {
        let folder = FolderRecord(name: "תיקייה חדשה", sortOrder: folders.count)
        folders.append(folder)
        selectedScope = .folder(folder.id)
        persist()
    }

    func renameFolder(_ id: UUID, to name: String) {
        guard let index = folders.firstIndex(where: { $0.id == id }) else { return }
        folders[index].name = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "ללא שם" : name
        persist()
    }

    func deleteFolder(_ id: UUID) {
        folders.removeAll { $0.id == id }
        for index in documents.indices where documents[index].folderID == id {
            documents[index].folderID = nil
        }
        selectedScope = .all
        persist()
    }

    func createDocument() {
        let folderID: UUID?
        if case .folder(let id) = selectedScope {
            folderID = id
        } else {
            folderID = folders.first?.id
        }

        let archive = EditorArchive.emptyRTL()
        let document = DocumentRecord(
            folderID: folderID,
            title: "מסמך חדש",
            attributedContentData: EditorArchive.data(for: archive),
            plainText: ""
        )
        documents.append(document)
        selectedDocumentID = document.id
        persist()
    }

    func importDocument(title: String, content: NSAttributedString) {
        let folderID: UUID?
        if case .folder(let id) = selectedScope { folderID = id } else { folderID = nil }
        let document = DocumentRecord(
            folderID: folderID,
            title: title,
            attributedContentData: EditorArchive.data(for: content),
            plainText: content.string
        )
        documents.append(document)
        selectedDocumentID = document.id
        persist()
    }

    func updateDocument(id: UUID, title: String, attributedText: NSAttributedString) {
        guard let index = documents.firstIndex(where: { $0.id == id }) else { return }
        documents[index].title = title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "ללא שם" : title
        documents[index].attributedContentData = EditorArchive.data(for: attributedText)
        documents[index].plainText = attributedText.string
        documents[index].updatedAt = Date()
        persist()
    }

    func toggleFavorite(_ id: UUID) {
        guard let index = documents.firstIndex(where: { $0.id == id }) else { return }
        documents[index].isFavorite.toggle()
        persist()
    }

    func duplicateDocument(_ id: UUID) {
        guard var copy = documents.first(where: { $0.id == id }) else { return }
        copy.id = UUID()
        copy.title += " — עותק"
        copy.createdAt = Date()
        copy.updatedAt = Date()
        documents.append(copy)
        selectedDocumentID = copy.id
        persist()
    }

    func deleteDocument(_ id: UUID) {
        documents.removeAll { $0.id == id }
        if selectedDocumentID == id {
            selectedDocumentID = visibleDocuments.first?.id
        }
        persist()
    }

    func moveDocument(_ id: UUID, to folderID: UUID?) {
        guard let index = documents.firstIndex(where: { $0.id == id }) else { return }
        documents[index].folderID = folderID
        documents[index].updatedAt = Date()
        persist()
    }

    func resetSampleData() async {
        do {
            let snapshot = try await repository.resetWithSampleData()
            folders = snapshot.folders
            documents = snapshot.documents
            selectedScope = .all
            selectedDocumentID = documents.first?.id
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func persist() {
        let snapshot = LibrarySnapshot(folders: folders, documents: documents)
        Task {
            do {
                try await repository.save(snapshot)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
