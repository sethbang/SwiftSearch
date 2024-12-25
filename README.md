
# SwiftSearch

SwiftSearch is a **privacy-focused MacOS file search tool** designed to outclass Spotlight. It indexes your local files for rapid, advanced querying (e.g., Boolean, regex, date filters) while keeping all data on your machine. Built with Swift and SwiftUI, SwiftSearch aims to be **fast, secure, and user-friendly**.

---

## Table of Contents
- [Features](#features)
- [Requirements](#requirements)
- [Installation & Setup](#installation--setup)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Development & Contributing](#development--contributing)
- [Roadmap](#roadmap)
- [License](#license)

---

## Features

1. **Local-Only Indexing**  
   - All data is stored on your Mac using a secure (optionally encrypted) SQLite database.

2. **Advanced Queries**  
   - Supports Boolean operators (AND, OR, NOT) and regex.  
   - Filter by file type, creation/modified date, and size.

3. **Incremental Updates**  
   - Monitors file changes via DispatchSourceFileSystemObject to avoid reindexing everything.

4. **SwiftUI Frontend**  
   - Modern interface with search bar, live previews, and batch actions (rename, move, compress).

5. **Security & Privacy**  
   - Folder exclusion to omit sensitive directories from indexing.  
   - Optional TouchID/FaceID gating for advanced security.

6. **Accessibility & Theming**  
   - Designed to work with VoiceOver, dynamic text sizing, and dark mode.

---

## Requirements

- **macOS 12 or later** (recommended)
- **Swift 5.7+**  
- **Xcode 14+** (if using Xcode)  
- Apple Developer Certificate (if you plan to notarize and distribute SwiftSearch)

---

## Installation & Setup

1. **Clone or Download** this repo:
   ```bash
   git clone https://github.com/YourUserName/swiftsearch.git
   cd swiftsearch
   ```
2. **Build using SwiftPM**:
   ```bash
   swift build
   ```
3. **(Optional) Open in Xcode**:  
   - `open Package.swift` or create an Xcode project for a more graphical workflow.

---

## Usage

1. **Command Line**:
   ```bash
   swift run SwiftSearch
   ```
   - This will launch the basic SwiftUI window if your Package.swift is configured as an executable.

2. **Feature Overview**:
   - **Search**: Type queries (with Boolean, regex) in the search bar.
   - **Filter**: Use checkboxes or date pickers to refine results.
   - **Batch Actions**: Select multiple items to rename, move, or compress.

3. **Folder Exclusion & Encryption**:
   - In-app preferences (coming soon) allow you to exclude folders from indexing and/or enable database encryption.

---

## Project Structure

```
swiftsearch/
├── Package.swift          # SwiftPM configuration
├── README.md              # This file
├── project_plan.md        # High-level roadmap & tasks
├── Sources/
│   ├── SwiftSearchCore/
│   │   ├── IndexManager.swift        # Indexing logic
│   │   └── SearchEngine.swift        # Query parsing & filtering
│   └── SwiftSearchApp/
│       └── ContentView.swift         # SwiftUI UI layer
├── Tests/
│   └── SwiftSearchTests/            # Unit & UI tests
└── CHANGELOG.md (optional)          # Records major changes
```

- **IndexManager.swift**: Crawls and updates file metadata in a SQLite database.  
- **SearchEngine.swift**: Executes Boolean/regex queries.  
- **ContentView.swift**: SwiftUI interface for user interaction.

---

## Development & Contributing

1. **Environment Setup**  
   - Use SwiftPM or Xcode for compilation.  
   - Make sure to run `swift test` or `xcodebuild test` before committing changes to maintain code quality.

2. **Following .clinerules**  
   - This project uses a `.clinerules` file to define coding standards (test coverage, doc updates, commit style).  
   - Always adhere to these rules when making contributions or requesting merges.

3. **Pull Requests**  
   - Please keep PRs focused and reference any relevant issues in commit messages (`feat: add new preview pane (#7)`).  
   - Ensure new or updated features are documented in the README or `CHANGELOG.md`.

---

## Roadmap

**Near-Term**  
1. **Folder Exclusion & Encryption**  
2. **Batch UI Actions** (move, rename, compress)  
3. **Improved UI Tests** in Xcode

**Mid-Term**  
1. **TouchID/FaceID gating** for secure searches  
2. **Enhanced Previews** (PDF, code syntax highlighting)

**Long-Term**  
1. **CoreML / Vision Integration** for OCR or advanced text extraction  
2. **Performance Scaling** for extremely large file systems

For detailed steps and tasks, see [project_plan.md](./project_plan.md).

---

## Known Constraints

1. **Local-Only Operation**
   - All indexing and search operations are strictly performed on your local machine
   - No data is ever sent to external servers or cloud services
   - No telemetry or usage data collection

2. **Zero External Dependencies**
   - No API calls or external service integrations
   - No cloud sync or backup features
   - Complete offline functionality

3. **Resource Considerations**
   - Index size scales with indexed content
   - Memory usage is optimized but depends on search complexity
   - Background processing used for intensive operations

---

## License

(Choose a license for your project, e.g. MIT, Apache 2.0, etc. If none is specified, just note "All rights reserved" or "Proprietary" here.)

```txt
MIT License (example)

Copyright (c) 2023 ...

Permission is hereby granted, free of charge, ...
```

---

### Questions or Feedback?

- For bugs or feature requests, please open an issue on GitHub.  
- For general inquiries or support, feel free to reach out at [Your Email/Website].

---

**Happy Searching!** If you’re spinning up a new Roo-Cline or Cline agent, feel free to refer it to this README for a quick overview of SwiftSearch and its development goals.
