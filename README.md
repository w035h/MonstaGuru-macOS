# MonstaGuru

**A native macOS application for Audiothingies MicroMonsta 2 polysynth**

Built with **SwiftUI**, **Foundation**, **CoreMIDI**, and **SwiftData**.
Fully compliant with **Apple's Human Interface Guidelines (HIG)** for macOS.

---

## Features

- **Program Editor**: Real-time editing of MicroMonsta 2 parameters with SwiftUI.
- **Librarian**: Organize, save, and load presets and banks with drag-and-drop.
- **MIDI Integration**: SysEx-based communication with MicroMonsta 2 hardware.
- **Clipboard**: Persistent multi-entry clipboard for program sections.
- **Dark Mode & Accessibility**: Full support for macOS Dark Mode, VoiceOver, and Dynamic Type.

---

## Project Structure

```
MonstaGuru-macOS/
├── Package.swift                 # Swift Package Manager manifest (swift-tools-version: 6.0)
├── MonstaGuru.xcodeproj/        # Xcode project for macOS app
├── Sources/
│   ├── MonstaGuru/              # Executable target with main entry point
│   │   ├── main.swift           # Application entry point
│   │   └── Resources/           # App assets (Colors.xcassets)
│   ├── App/                     # App module (SwiftUI entry, state management)
│   │   └── MonstaGuruApp.swift  # App struct with SwiftData container
│   ├── Data/                    # SwiftData models and repositories
│   │   ├── Program.swift         # Program data model
│   │   ├── Preset.swift          # Preset data model
│   │   ├── Bank.swift            # Bank data model
│   │   ├── ClipboardEntry.swift  # Clipboard data model
│   │   ├── MIDISetting.swift     # MIDI configuration model
│   │   └── Repositories/         # CRUD operations for models
│   ├── MIDI/                    # CoreMIDI integration
│   │   ├── MIDIManager.swift     # MIDI input/output handler
│   │   ├── MIDIUtilities.swift   # Type aliases and utilities
│   │   └── SysExParser.swift     # SysEx message parser/generator
│   └── UI/                      # SwiftUI views and ViewModels
│       ├── ProgramEditor/       # Program editor views and ViewModels
│       ├── Librarian/           # Preset/bank librarian views and ViewModels
│       ├── Clipboard/           # Clipboard views and ViewModels
│       └── Shared/              # Shared UI components (DesignSystem, ContentView)
├── Tests/
│   ├── UnitTests/               # Unit tests for models, repositories, ViewModels
│   ├── UITests/                 # UI tests for SwiftUI views
│   └── IntegrationTests/       # Cross-module integration tests
└── README.md                    # This file
```

---

## Requirements

| Component       | Version/Requirement                          |
|-----------------|---------------------------------------------|
| **macOS**       | 14.0+ (Sonoma)                              |
| **Swift**       | 6.0+ (updated for Xcode 26.4.1 compatibility) |
| **Xcode**       | 26.4.1+ (tested and verified)                |
| **Dependencies**| SwiftUI, Foundation, CoreMIDI, SwiftData   |

---

## Setup

### 1. Clone the Repository

```bash
git clone https://github.com/w035h/MonstaGuru-macOS.git
cd MonstaGuru-macOS
```

### 2. Open in Xcode

**Recommended**: Open the Xcode project directly for best macOS app support:
```bash
open MonstaGuru.xcodeproj
```

Or open `Package.swift` directly in Xcode (File > Open > Select `Package.swift`).

### 3. Build and Run

- Select the **MonstaGuru** scheme in Xcode.
- Press **Cmd+R** to build and run.
- The app requires **macOS 14.0+** (Sonoma).

**Note**: For Xcode 26.4.1+, use the Xcode project file (`MonstaGuru.xcodeproj`) rather than building directly through SPM, as SPM has limitations with macOS GUI applications (Info.plist, asset catalogs, app bundles).

---

## Agent Workflow

This project is built using a **multi-agent collaborative coding** approach.
Each agent has a specialized scope and dependencies:

| Agent               | Scope                                                                 | Dependencies                          |
|---------------------|-----------------------------------------------------------------------|---------------------------------------|
| **Project Architect** | Project structure, `Package.swift`, Xcode config                     | None                                  |
| **Core Data Model**  | SwiftData models (`Program`, `Preset`, `Bank`, etc.)                  | Project Architect                     |
| **MIDI Integration** | CoreMIDI communication (`MIDIManager`, `SysExParser`)                | Project Architect, Core Data Model   |
| **Program Editor**   | SwiftUI editor views (`ProgramEditorView`, `VoiceEditorView`)        | Project Architect, Core Data, MIDI   |
| **Librarian**        | Preset/bank management (`LibrarianView`, `SysExFileHandler`)        | Project Architect, Core Data, MIDI   |
| **Clipboard**        | Persistent clipboard (`ClipboardManager`, `ClipboardView`)           | Project Architect, Core Data Model   |
| **UI/UX**            | HIG compliance, accessibility, design system                         | All UI agents                         |
| **Testing**          | Unit/UI/integration tests, CI/CD pipeline                              | All agents                            |
| **Integration**      | Final app assembly, end-to-end testing, distribution                  | All agents                            |

---

## Conventions

### Code Style

- **Naming**: Use `PascalCase` for types, `camelCase` for variables/functions.
- **Indentation**: 4 spaces (Xcode default).
- **Line Length**: 120 characters max (soft limit).
- **Comments**: Use `//` for single-line, `/* */` for multi-line. Prefer self-documenting code.

### Swift Features

- **Concurrency**: Use `async/await` and `Task` for asynchronous operations.
- **Error Handling**: Use `Result` and `throws` for fallible operations.
- **Combine**: Use for reactive streams (e.g., MIDI events).
- **SwiftData**: Use `@Model` macro for persistence models.

### Documentation

- **Functions**: Document public APIs with `///` comments.
- **Types**: Document classes/structs with `///` comments.
- **Markdown**: Use for module-level documentation (e.g., `README.md` in subdirectories).

---

## MIDI Setup

1. Connect **MicroMonsta 2** via USB or MIDI interface.
2. Open **Audio MIDI Setup** (macOS) to verify the device is detected.
3. In MonstaGuru, go to **Settings > MIDI** to select input/output devices.

---

## Testing

### Run Unit Tests

```bash
swift test
```

Or in Xcode:
- Press **Cmd+U** to run all tests.
- Select a specific test target to run only its tests.

### Test Coverage

Aim for **>80% coverage** on critical paths (MIDI, data persistence, editor logic).

---

## Contributing

1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/your-feature`).
3. Commit changes (`git commit -m "Add your feature"`).
4. Push to the branch (`git push origin feature/your-feature`).
5. Open a Pull Request.

---

## License

This project is proprietary software for Audiothingies MicroMonsta 2.
Unauthorized distribution is prohibited.

---

## Contact

For issues or questions, contact the [Audiothingies team](https://www.audiothingies.com).
