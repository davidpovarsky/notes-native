import SwiftUI

struct DocumentRowView: View {
    let document: DocumentRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(document.title)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                if document.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                }
            }
            Text(document.plainText.replacingOccurrences(of: "\n", with: " "))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            Text(document.updatedAt, style: .relative)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}
