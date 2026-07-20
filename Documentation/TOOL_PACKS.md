# Declarative tool packs

Tool packs add safe document commands without recompiling the editor core.

A tool pack is JSON:

```json
{
  "id": "com.example.basic",
  "name": "Basic tools",
  "version": 1,
  "tools": [
    {
      "id": "wrap-parentheses",
      "title": "Wrap in parentheses",
      "systemImage": "parentheses",
      "action": "wrapSelection",
      "prefix": "(",
      "suffix": ")"
    }
  ]
}
```

Supported actions in version 1:

- `uppercase`
- `lowercase`
- `wrapSelection`
- `insertTemplate`
- `replaceLiteral`

New native actions can be added by extending `DeclarativeAction` and `DeclarativeDocumentTool`.

Bundled packs live in `DavWriter/Resources/ToolPacks`. A future release can load signed packs from the app's Documents directory using the same schema.
