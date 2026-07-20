# DavWriter

DavWriter is a native, Hebrew-first document editor for iPad. It is built with SwiftUI and UIKit/TextKit 2 only—no WebView, Flutter, React Native, or JavaScript editor.

## Included in this repository

- Three-column iPad document interface
- Native rich-text editor based on `UITextView(usingTextLayoutManager: true)`
- Paragraph-level RTL defaults and Hebrew-first UI layout
- Folders, favorites, document duplication, deletion, and search
- Autosave to a local JSON library in Application Support
- Native attributed-text archive with plain-text search shadow
- Bold, italic, underline, font size, alignment, lists, links, and image insertion
- Undo and redo
- PDF, RTF, HTML, and plain-text export
- TXT/RTF/RTFD/HTML/DOCX import
- Built-in document tools: source lookup and citation insertion
- Declarative JSON tool packs that can be extended without changing the editor core
- Unit tests for persistence, tool packs, and rich-text archiving
- XcodeGen configuration so the Xcode project can be generated on a GitHub Actions macOS runner

## Generate the Xcode project on macOS

```bash
./Scripts/generate_project.sh
open DavWriter.xcodeproj
```

## Project requirements

- Xcode 16 or newer
- iPadOS 17 or newer
- XcodeGen 2.42 or newer

The app has no third-party runtime dependencies.

See `Documentation/ARCHITECTURE.md` for the layer structure and `Documentation/TOOL_PACKS.md` for the extension format.
