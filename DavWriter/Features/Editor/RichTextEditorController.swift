import SwiftUI
import UIKit

@MainActor
final class RichTextEditorController: ObservableObject {
    weak var textView: UITextView?

    @Published private(set) var selectionRange = NSRange(location: 0, length: 0)
    @Published private(set) var selectedText = ""
    @Published var fontSize: CGFloat = AppConstants.defaultFontSize

    func attach(_ textView: UITextView) {
        self.textView = textView
        selectionDidChange()
    }

    func selectionDidChange() {
        guard let textView else { return }
        selectionRange = textView.selectedRange
        let nsText = textView.text as NSString
        selectedText = nsText.substring(with: safeRange(textView.selectedRange, length: nsText.length))
        if let font = textView.typingAttributes[.font] as? UIFont {
            fontSize = font.pointSize
        }
    }

    func toggleBold() {
        mutateFont { $0.toggling(.traitBold) }
    }

    func toggleItalic() {
        mutateFont { $0.toggling(.traitItalic) }
    }

    func toggleUnderline() {
        guard let textView else { return }
        applyAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, toggle: true)
        textViewDidMutate()
    }

    func setFontSize(_ size: CGFloat) {
        let clamped = min(max(size, AppConstants.minimumFontSize), AppConstants.maximumFontSize)
        fontSize = clamped
        mutateFont { $0.resized(to: clamped) }
    }

    func setAlignment(_ alignment: NSTextAlignment) {
        guard let textView else { return }
        let range = paragraphRange(in: textView)
        let mutable = NSMutableAttributedString(attributedString: textView.attributedText)
        mutable.enumerateAttribute(.paragraphStyle, in: range) { value, subrange, _ in
            let style = ((value as? NSParagraphStyle)?.mutableCopy() as? NSMutableParagraphStyle) ?? NSMutableParagraphStyle()
            style.alignment = alignment
            style.baseWritingDirection = alignment == .left ? .leftToRight : .rightToLeft
            mutable.addAttribute(.paragraphStyle, value: style, range: subrange)
        }
        textView.attributedText = mutable
        textView.selectedRange = selectionRange
        textViewDidMutate()
    }

    func toggleBulletList() {
        transformSelectedParagraphs { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            return trimmed.hasPrefix("• ") ? String(trimmed.dropFirst(2)) : "• " + line
        }
    }

    func toggleNumberedList() {
        guard let textView else { return }
        let range = paragraphRange(in: textView)
        let text = (textView.text as NSString).substring(with: range)
        let lines = text.components(separatedBy: "\n")
        let alreadyNumbered = lines.filter { !$0.isEmpty }.allSatisfy { $0.range(of: #"^\d+\. "#, options: .regularExpression) != nil }
        let transformed = lines.enumerated().map { index, line in
            if line.isEmpty { return line }
            if alreadyNumbered {
                return line.replacingOccurrences(of: #"^\d+\. "#, with: "", options: .regularExpression)
            }
            return "\(index + 1). \(line)"
        }.joined(separator: "\n")
        replace(range: range, with: transformed)
    }

    func insertLink(urlString: String) {
        guard let textView, let url = URL(string: urlString), selectionRange.length > 0 else { return }
        let mutable = NSMutableAttributedString(attributedString: textView.attributedText)
        mutable.addAttribute(.link, value: url, range: selectionRange)
        textView.attributedText = mutable
        textView.selectedRange = selectionRange
        textViewDidMutate()
    }

    func insertImage(_ image: UIImage) {
        guard let textView else { return }
        let attachment = NSTextAttachment()
        attachment.image = image
        let availableWidth = max(240, textView.bounds.width - textView.textContainerInset.left - textView.textContainerInset.right)
        let scale = min(1, availableWidth / max(image.size.width, 1))
        attachment.bounds = CGRect(origin: .zero, size: CGSize(width: image.size.width * scale, height: image.size.height * scale))
        let imageString = NSAttributedString(attachment: attachment)
        replaceSelection(with: imageString)
    }

    func replaceSelection(with attributedString: NSAttributedString) {
        guard let textView else { return }
        let mutable = NSMutableAttributedString(attributedString: textView.attributedText)
        let range = safeRange(selectionRange, length: mutable.length)
        mutable.replaceCharacters(in: range, with: attributedString)
        textView.attributedText = mutable
        let caret = range.location + attributedString.length
        textView.selectedRange = NSRange(location: caret, length: 0)
        selectionDidChange()
        textViewDidMutate()
    }

    func replaceSelection(with string: String) {
        let attributes = textView?.typingAttributes ?? [:]
        replaceSelection(with: NSAttributedString(string: string, attributes: attributes))
    }

    func undo() {
        textView?.undoManager?.undo()
        textViewDidMutate()
    }

    func redo() {
        textView?.undoManager?.redo()
        textViewDidMutate()
    }

    func currentPlainText() -> String {
        textView?.text ?? ""
    }

    func currentAttributedText() -> NSAttributedString {
        textView?.attributedText ?? EditorArchive.emptyRTL()
    }

    private func mutateFont(_ transform: (UIFont) -> UIFont) {
        guard let textView else { return }
        if selectionRange.length == 0 {
            let current = (textView.typingAttributes[.font] as? UIFont) ?? UIFont.systemFont(ofSize: fontSize)
            textView.typingAttributes[.font] = transform(current)
        } else {
            let mutable = NSMutableAttributedString(attributedString: textView.attributedText)
            mutable.enumerateAttribute(.font, in: selectionRange) { value, range, _ in
                let font = (value as? UIFont) ?? UIFont.systemFont(ofSize: self.fontSize)
                mutable.addAttribute(.font, value: transform(font), range: range)
            }
            textView.attributedText = mutable
            textView.selectedRange = selectionRange
        }
        textViewDidMutate()
    }

    private func applyAttribute(_ key: NSAttributedString.Key, value: Any, toggle: Bool) {
        guard let textView else { return }
        if selectionRange.length == 0 {
            if toggle, textView.typingAttributes[key] != nil {
                textView.typingAttributes.removeValue(forKey: key)
            } else {
                textView.typingAttributes[key] = value
            }
            return
        }
        let mutable = NSMutableAttributedString(attributedString: textView.attributedText)
        let existing = mutable.attribute(key, at: selectionRange.location, effectiveRange: nil)
        if toggle, existing != nil {
            mutable.removeAttribute(key, range: selectionRange)
        } else {
            mutable.addAttribute(key, value: value, range: selectionRange)
        }
        textView.attributedText = mutable
        textView.selectedRange = selectionRange
    }

    private func transformSelectedParagraphs(_ transform: (String) -> String) {
        guard let textView else { return }
        let range = paragraphRange(in: textView)
        let text = (textView.text as NSString).substring(with: range)
        let transformed = text.components(separatedBy: "\n").map(transform).joined(separator: "\n")
        replace(range: range, with: transformed)
    }

    private func replace(range: NSRange, with string: String) {
        guard let textView else { return }
        let mutable = NSMutableAttributedString(attributedString: textView.attributedText)
        let attributes = textView.typingAttributes
        mutable.replaceCharacters(in: range, with: NSAttributedString(string: string, attributes: attributes))
        textView.attributedText = mutable
        textView.selectedRange = NSRange(location: range.location, length: (string as NSString).length)
        selectionDidChange()
        textViewDidMutate()
    }

    private func paragraphRange(in textView: UITextView) -> NSRange {
        (textView.text as NSString).paragraphRange(for: safeRange(selectionRange, length: (textView.text as NSString).length))
    }

    private func safeRange(_ range: NSRange, length: Int) -> NSRange {
        let location = min(max(0, range.location), length)
        let upper = min(max(location, range.location + range.length), length)
        return NSRange(location: location, length: upper - location)
    }

    private func textViewDidMutate() {
        guard let textView else { return }
        textView.delegate?.textViewDidChange?(textView)
        objectWillChange.send()
    }
}
