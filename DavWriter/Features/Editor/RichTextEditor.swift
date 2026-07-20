import SwiftUI
import UIKit

struct RichTextEditor: UIViewRepresentable {
    @Binding var attributedText: NSAttributedString
    @ObservedObject var controller: RichTextEditorController
    let forceRTL: Bool
    let onChange: (NSAttributedString) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView(usingTextLayoutManager: true)
        textView.delegate = context.coordinator
        textView.attributedText = attributedText
        textView.backgroundColor = .clear
        textView.alwaysBounceVertical = true
        textView.keyboardDismissMode = .interactive
        textView.allowsEditingTextAttributes = true
        textView.adjustsFontForContentSizeCategory = true
        textView.textContainerInset = UIEdgeInsets(top: 28, left: 34, bottom: 80, right: 34)
        textView.linkTextAttributes = [
            .foregroundColor: UIColor.tintColor,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        textView.semanticContentAttribute = forceRTL ? .forceRightToLeft : .unspecified
        applyDefaultTypingAttributes(to: textView)
        controller.attach(textView)
        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        context.coordinator.parent = self
        textView.semanticContentAttribute = forceRTL ? .forceRightToLeft : .unspecified
        if !textView.attributedText.isEqual(to: attributedText) && !textView.isFirstResponder {
            textView.attributedText = attributedText
        }
    }

    private func applyDefaultTypingAttributes(to textView: UITextView) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.baseWritingDirection = forceRTL ? .rightToLeft : .natural
        paragraph.alignment = forceRTL ? .right : .natural
        paragraph.lineSpacing = 4
        textView.typingAttributes = [
            .font: UIFont.systemFont(ofSize: AppConstants.defaultFontSize),
            .paragraphStyle: paragraph,
            .foregroundColor: UIColor.label
        ]
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: RichTextEditor

        init(parent: RichTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            let copy = NSAttributedString(attributedString: textView.attributedText)
            parent.attributedText = copy
            parent.onChange(copy)
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            parent.controller.selectionDidChange()
        }
    }
}
