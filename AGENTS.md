# AGENTS.md

This document defines lightweight repo conventions and a small header template to follow when creating new source files in the NurseryApp project.

Purpose
- Keep filenames, file headers, and small workflow steps consistent so new files are predictable and easy to review.
- Make it quick for contributors to add new Swift files, resources, and tests with minimal friction.

Primary conventions

- Swift source files: use PascalCase and match the main type or view inside the file. Examples:
  - `ContentView.swift`, `PlantViewModel.swift`, `AddPlantView.swift`
- Resource files (assets, JSON, scripts): use lowercase, hyphen-separated. Examples:
  - `colors.json`, `plant-data.json`, `image-assets.xcassets`
- Test files: mirror the target file name and append `Tests` (or `UITests`) as appropriate. Examples:
  - `PlantViewModelTests.swift`, `NurseryAppUITests.swift`
- Keep file names short and descriptive. Avoid spaces and special characters.

Branch & commit guidance

- Branch naming: use `type/area/short-description`, e.g. `feature/add-favorites`, `fix/coredata-seed`, `chore/update-docs`.
- Commit messages: start with a short verb + area, e.g. `feat(Plants): add favorite toggle`, `fix(AddPlantView): emoji picker layout`.
- Make small commits with a clear message and include a short body when the change is non-trivial.

File header template (Swift)

Add the following header to new Swift files. Replace placeholders with actual values. Use the actual creation date in `YYYY/MM/DD` format.

```swift
// FileName.swift
// NurseryApp
//
// Created by Sumit Kumar on 2025/10/26.
// Module: NurseryApp
//

import Foundation
// ...other imports...
```

Notes about headers
- Always include `Created by Sumit Kumar` and the creation date (or your name if appropriate for your team).
- Keep the header small and focused — it's for quick identification in code review and file lists.

Core Data & model files

- If you add a Core Data model, prefer an `.xcdatamodeld` file for long-term maintainability. The project currently uses a programmatic model in `CoreDataManager.swift`; if you convert to a datamodel file, update the Core Data stack accordingly.
- When adding entities or attributes, think about migrations. If it's a simple app and you do in-development changes, an in-memory or lightweight migration may be acceptable; for production data, prefer explicit versioned migrations.

SwiftUI previews and tests

- Add previews for views where practical. Use sample data helpers inside `#if DEBUG` blocks or short factory methods to avoid depending on the live store.
- When adding logic to the app (view models, managers), add at least one unit test for core behavior (happy path + 1 edge case).

Quick checklist for adding a new Swift file

1. Create the file with PascalCase name matching the primary type in the file.
2. Add the header comment (see the template above).
3. Add the file to the Xcode target if necessary (check project navigator).
4. Add simple `#if DEBUG` preview or a small unit test to exercise the new type when practical.
5. Build the project (Cmd+B) and run the app (Cmd+R) — fix any compile errors.
6. Commit with a clear message and open a PR using the branch naming convention.

Helpful examples

- Adding a new SwiftUI view `MyView.swift`:
  - File name: `MyView.swift`
  - Header: use the Swift header template.
  - Include a `struct MyView_Previews: PreviewProvider { ... }` with sample data.
  - Add to the app or feature module and run previews.

- Adding a new model or manager that needs testing:
  - Add unit tests under the `NurseryAppTests` target.
  - Prefer an in-memory Core Data store for tests (or dependency-inject a test container) so tests are deterministic.

Housekeeping

- Keep files small and focused: one Swift type per file when practical.
- If a file grows beyond ~300-400 lines, consider splitting it (helpers, subviews, styling separated).
- Remove dead files from the Xcode project and the repository — commit deletions with a clear message like `chore(cleanup): remove unused Demo files`.

Contact / ownership

- This repository follows these conventions. If you need an exception, add a short rationale in the PR description and request a maintainer review.

--
Updated: 2025/10/26
