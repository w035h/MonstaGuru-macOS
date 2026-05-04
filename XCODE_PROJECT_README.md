# Xcode Project for MonstaGuru-macOS

This directory contains an Xcode project file (`MonstaGuru.xcodeproj`) that allows you to open and build the MonstaGuru-macOS project in Xcode.

## Project Structure

The Xcode project references the existing Swift Package Manager structure:

```
MonstaGuru-macOS/
├── Package.swift          # Swift Package Manager manifest
├── Sources/
│   ├── App/              # App module (entry point)
│   │   ├── MonstaGuruApp.swift
│   │   └── Info.plist
│   ├── Data/             # Data module (models, repositories)
│   │   ├── Bank.swift
│   │   ├── Preset.swift
│   │   ├── Program.swift
│   │   └── Repositories/
│   ├── MIDI/             # MIDI module (CoreMIDI integration)
│   │   ├── MIDIManager.swift
│   │   ├── MIDIUtilities.swift
│   │   └── SysExParser.swift
│   └── UI/               # UI module (SwiftUI views)
│       ├── Clipboard/
│       ├── Librarian/
│       ├── ProgramEditor/
│       └── Shared/
├── Resources/
│   └── Colors.xcassets
├── Tests/
│   ├── UnitTests/
│   ├── UITests/
│   └── IntegrationTests/
└── MonstaGuru.xcodeproj/  # Xcode project
    └── project.pbxproj
```

## How to Use

### Option 1: Open Directly in Xcode (Recommended)

1. **Open the project in Xcode:**
   ```bash
   open MonstaGuru.xcodeproj
   ```
   or double-click the `MonstaGuru.xcodeproj` file in Finder.

2. **Xcode will automatically resolve the Swift Package:**
   - Xcode 11+ has built-in support for Swift Packages
   - The project references the local `Package.swift` file
   - All targets (App, Data, MIDI, UI) will be automatically resolved

3. **Build and Run:**
   - Select the `MonstaGuru` scheme
   - Click the Run button (▶) or press ⌘R
   - The app should build and launch

### Option 2: Use Swift Package Manager Directly

If you prefer to use Swift Package Manager without Xcode:

```bash
# Build the project
swift build

# Run the app
swift run

# Generate Xcode project (if you have Swift installed)
swift package generate-xcodeproj --output MonstaGuru.xcodeproj
```

## Project Configuration

The Xcode project includes:

- **Target: MonstaGuru** (Application)
  - Product Bundle Identifier: `com.audiothingies.MonstaGuru`
  - Deployment Target: macOS 14.0 (Sonoma)
  - Info.plist: `Sources/App/Info.plist`
  - Resources: `Resources/Colors.xcassets`

- **Build Configurations:**
  - Debug: Full debug symbols, no optimization
  - Release: Optimized, stripped symbols

- **Swift Version:** 5.0

## Troubleshooting

### If Xcode doesn't recognize the package:
1. Close Xcode
2. Delete `DerivedData` folder: `rm -rf ~/Library/Developer/Xcode/DerivedData/`
3. Reopen the project

### If you see "No schemes" error:
1. Go to Product > Scheme > Manage Schemes...
2. Click "Autocreate Schemes Now"

### If build fails with missing files:
1. Clean the build folder: Product > Clean Build Folder (⇧⌘K)
2. Restart Xcode

## Modular Architecture

The project maintains the same modular structure as defined in `Package.swift`:

- **App**: Entry point, app delegate, main scene
- **Data**: SwiftData models and repositories
- **MIDI**: CoreMIDI integration and SysEx parsing
- **UI**: SwiftUI views and view models

Each module can be developed and tested independently.

## Notes

- The Xcode project uses `XCSwiftPackageReference` to reference the local Swift Package
- All source files are organized in groups matching the directory structure
- The project is configured for Xcode 14.0+ compatibility
- macOS 14.0 (Sonoma) is the minimum deployment target

## Additional Configuration

If you need to add custom build settings, you can:

1. Create `.xcconfig` files in a `Configurations` directory
2. Add them to the project and reference them in build configurations
3. Or modify the build settings directly in Xcode's UI
