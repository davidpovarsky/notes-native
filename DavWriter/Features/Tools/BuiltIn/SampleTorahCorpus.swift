import Foundation

struct TorahSource: Hashable {
    let reference: String
    let text: String
}

enum SampleTorahCorpus {
    static let sources: [TorahSource] = [
        TorahSource(reference: "בראשית א, א", text: "בראשית ברא אלהים את השמים ואת הארץ"),
        TorahSource(reference: "תהלים קיט, קה", text: "נר לרגלי דברך ואור לנתיבתי"),
        TorahSource(reference: "משלי ג, ו", text: "בכל דרכיך דעהו והוא יישר ארחותיך"),
        TorahSource(reference: "אבות א, יד", text: "אם אין אני לי מי לי וכשאני לעצמי מה אני ואם לא עכשיו אימתי")
    ]

    static func bestMatch(for query: String) -> TorahSource? {
        let words = Set(query.split { $0.isWhitespace || $0.isPunctuation }.map(String.init))
        guard !words.isEmpty else { return nil }
        return sources.max { lhs, rhs in
            score(lhs, words: words) < score(rhs, words: words)
        }.flatMap { score($0, words: words) > 0 ? $0 : nil }
    }

    private static func score(_ source: TorahSource, words: Set<String>) -> Int {
        words.reduce(0) { score, word in
            score + (source.text.localizedCaseInsensitiveContains(word) ? 1 : 0)
        }
    }
}
