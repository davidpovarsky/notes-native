import PhotosUI
import SwiftUI

struct FormattingToolbar: View {
    @ObservedObject var controller: RichTextEditorController
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isShowingLinkPrompt = false
    @State private var linkText = "https://"

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                Button(action: controller.undo) { Image(systemName: "arrow.uturn.backward") }
                Button(action: controller.redo) { Image(systemName: "arrow.uturn.forward") }
                Divider().frame(height: 24)
                Button(action: controller.toggleBold) { Image(systemName: "bold") }
                Button(action: controller.toggleItalic) { Image(systemName: "italic") }
                Button(action: controller.toggleUnderline) { Image(systemName: "underline") }
                Divider().frame(height: 24)
                Menu {
                    ForEach([14, 16, 18, 20, 24, 28, 32, 40], id: \.self) { size in
                        Button("\(size)") { controller.setFontSize(CGFloat(size)) }
                    }
                } label: {
                    Label("\(Int(controller.fontSize))", systemImage: "textformat.size")
                }
                Button { controller.setAlignment(.right) } label: { Image(systemName: "text.alignright") }
                Button { controller.setAlignment(.center) } label: { Image(systemName: "text.aligncenter") }
                Button { controller.setAlignment(.left) } label: { Image(systemName: "text.alignleft") }
                Divider().frame(height: 24)
                Button(action: controller.toggleBulletList) { Image(systemName: "list.bullet") }
                Button(action: controller.toggleNumberedList) { Image(systemName: "list.number") }
                Button {
                    isShowingLinkPrompt = true
                } label: {
                    Image(systemName: "link")
                }
                .disabled(controller.selectionRange.length == 0)
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Image(systemName: "photo.badge.plus")
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(.bar)
        .onChange(of: selectedPhoto) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    controller.insertImage(image)
                }
                selectedPhoto = nil
            }
        }
        .alert("הוספת קישור", isPresented: $isShowingLinkPrompt) {
            TextField("כתובת", text: $linkText)
                .textInputAutocapitalization(.never)
                .keyboardType(.URL)
            Button("הוספה") {
                controller.insertLink(urlString: linkText)
            }
            Button("ביטול", role: .cancel) {}
        } message: {
            Text("הקישור יוחל על הטקסט המסומן.")
        }
    }
}
