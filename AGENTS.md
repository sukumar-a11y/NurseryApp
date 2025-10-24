# AGENTS.md

## File naming conventions & file header

Keep file names predictable and consistent across the repo. When creating new files include a small header comment with author, creation date, filename and module name.

Simple rules:

- Swift source files: use PascalCase and match the main type or view inside the file. Examples:
  - `ContentView.swift`, `PlantViewModel.swift`, `AddPlantView.swift`
- Resource files (assets, JSON, scripts): use lowercase, hyphen-separated. Examples:
  - `colors.json`, `plant-data.json`, `image-assets.xcassets`
- Test files: mirror the target file name and append `Tests` (or `UITests`) as appropriate. Examples:
  - `PlantViewModelTests.swift`, `NurseryAppUITests.swift`
- Keep file names short and descriptive. Avoid spaces and special characters.

File header template

- Add a header at the top of each new source file (Swift example shown). Replace placeholders as appropriate.

Swift example header (add to top of new .swift files):

```swift
//  FileName.swift
//  ModuleName
//
//  Created by Sumit Kumar on YYYY/MM/DD.
//  Copyright © 2025 Grid Dynamics. All rights reserved.
```

Notes:
- Use the actual creation date in `YYYY/MM/DD` format (or your preferred consistent format).
- `FileName.swift` should match the saved filename. `ModuleName` is the Xcode module or target name (e.g., `NurseryApp`).
- For non-Swift files place a short one-line header with author and date if it makes sense (for scripts, configs, etc.).

Quick summary

- Branch naming: keep using `type/area/short-description` (see Git conventions above)
- File names: PascalCase for Swift, kebab-case for assets/resources, mirror names for tests
- File header: always include Created by Sumit Kumar, date, filename and module name at file top
