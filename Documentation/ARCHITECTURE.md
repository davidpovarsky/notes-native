# Architecture

DavWriter is divided into small layers with one-directional dependencies.

## App

Application entry point and root dependency composition.

## Core

- **Models**: Codable domain records. They do not depend on UI.
- **Persistence**: Actor-isolated local repository and atomic disk writes.
- **Services**: Import, export, search, and sample-library creation.
- **Utilities**: Shared file locations, debouncing, and constants.
- **Extensions**: Small Foundation/UIKit helpers.

## Features

- **Library**: Folders, document list, selection, search, and mutations.
- **Editor**: TextKit 2 bridge, formatting commands, autosave, and document inspector.
- **Tools**: Stable tool protocol, built-in tools, declarative tool packs, and the side panel.
- **Settings**: Persistent user preferences.
- **Onboarding**: Empty and initial states.

## UI

Reusable presentation-only components.

## Persistence format

The library is stored as one versioned JSON snapshot in Application Support. Rich text is stored as an Apple attributed-string secure archive, while a plain-text shadow is stored separately for fast search. Attachments are embedded in the attributed-string archive.

This format is intentionally isolated behind `DocumentRepository`. It can later be replaced by SQLite/GRDB without changing the editor or feature layers.

## Tool safety

Runtime tool packs are declarative JSON. They may call only actions implemented by the app. Arbitrary downloaded Swift or JavaScript is not executed. This keeps the interface native and App Store compatible.
