#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
required=(
  "project.yml"
  "DavWriter/App/DavWriterApp.swift"
  "DavWriter/Features/Editor/RichTextEditor.swift"
  "DavWriter/Core/Persistence/DocumentRepository.swift"
  "DavWriter/Features/Tools/DocumentTool.swift"
  "DavWriter/Resources/ToolPacks/default-tools.json"
)
for path in "${required[@]}"; do
  test -f "$ROOT_DIR/$path" || { echo "Missing: $path" >&2; exit 1; }
done
echo "Project structure looks complete."
