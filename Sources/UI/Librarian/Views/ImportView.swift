// ImportView.swift
// MonstaGuru
// Created by Mistral Vibe Code (Librarian Agent)

import SwiftUI
import UniformTypeIdentifiers
import Data

/// View for importing presets and banks from files.
public struct ImportView: View {
    
    @Environment(\.
        dismiss) private var dismiss
    @Environment(\.
        modelContainer) private var modelContainer
    
    @ObservedObject public var viewModel: LibrarianViewModel
    
    @State private var importType: ImportType = .sysEx
    @State private var selectedFiles: [URL] = []
    @State private var isImporting: Bool = false
    @State private var importResult: ImportResult?
    
    // MARK: - Import Types
    
    public enum ImportType: String, Identifiable, CaseIterable {
        case sysEx = "SysEx File"
        case bank = "Bank File"
        case preset = "Preset File"
        
        public var id: String { rawValue }
    }
    
    // MARK: - Import Result
    
    public struct ImportResult {
        public let success: Bool
        public let message: String
        public let importedCount: Int
    }
    
    // MARK: - Main View
    
    public var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Header
            Text("Import")
                .font(DesignSystem.Typography.title)
                .foregroundStyle(DesignSystem.Colors.textPrimary)
            
            // Import Type Selection
            Picker("Import Type", selection: $importType) {
                ForEach(ImportType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 300)
            
            // Description
            Text(description)
                .font(DesignSystem.Typography.bodySmall)
                .foregroundStyle(DesignSystem.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(DesignSystem.Spacing.sm)
            
            // File Selection
            fileSelectionArea
            
            // Result
            if let result = importResult {
                resultView(result)
            }
            
            // Actions
            HStack(spacing: DesignSystem.Spacing.md) {
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle()
                
                Button("Import") {
                    importFiles()
                }
                .buttonStyle(isPrimary: true)
                .disabled(selectedFiles.isEmpty)
                .keyboardShortcut(.return, modifiers: [])
            }
        }
        .padding(DesignSystem.Spacing.xl)
        .frame(width: 500)
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: allowedContentTypes,
            allowsMultipleSelection: true
        ) { result in
            handleFileSelection(result)
        }
    }
    
    // MARK: - Computed Properties
    
    private var description: String {
        switch importType {
        case .sysEx:
            return "Import SysEx files containing MicroMonsta 2 program data"
        case .bank:
            return "Import bank files containing multiple presets"
        case .preset:
            return "Import individual preset files"
        }
    }
    
    private var allowedContentTypes: [UTType] {
        switch importType {
        case .sysEx:
            return [.data, .fileURL]
        case .bank:
            return [.json, .fileURL]
        case .preset:
            return [.json, .fileURL]
        }
    }
    
    private var fileSelectionArea: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            if selectedFiles.isEmpty {
                VStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "folder.badge.plus")
                        .font(DesignSystem.Typography.largeTitle)
                        .foregroundStyle(DesignSystem.Colors.textTertiary)
                    
                    Text("No files selected")
                        .font(DesignSystem.Typography.body)
                        .foregroundStyle(DesignSystem.Colors.textTertiary)
                    
                    Button("Select Files") {
                        isImporting = true
                    }
                    .buttonStyle(isPrimary: true)
                }
                .frame(height: 150)
            } else {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("Selected Files")
                        .font(DesignSystem.Typography.headline)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                            ForEach(selectedFiles, id: \.self) { url in
                                Text(url.lastPathComponent)
                                    .font(DesignSystem.Typography.bodySmall)
                                    .padding(DesignSystem.Spacing.xs)
                                    .background(DesignSystem.Colors.backgroundTertiary)
                                    .cornerRadius(DesignSystem.CornerRadius.xs)
                            }
                        }
                    }
                    .frame(height: 100)
                    
                    Button("Change Files") {
                        isImporting = true
                    }
                    .buttonStyle()
                }
            }
        }
        .frame(width: 400)
        .cardStyle()
    }
    
    private func resultView(_ result: ImportResult) -> some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            HStack {
                Image(systemName: result.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(result.success ? DesignSystem.Colors.success : DesignSystem.Colors.error)
                
                Text(result.success ? "Success" : "Error")
                    .font(DesignSystem.Typography.headline)
                    .foregroundStyle(result.success ? DesignSystem.Colors.success : DesignSystem.Colors.error)
            }
            
            Text(result.message)
                .font(DesignSystem.Typography.body)
                .foregroundStyle(DesignSystem.Colors.textPrimary)
            
            if result.importedCount > 0 {
                Text("Imported: \result.importedCount) items")
                    .font(DesignSystem.Typography.bodySmall)
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(result.success ? DesignSystem.Colors.success.opacity(0.1) : DesignSystem.Colors.error.opacity(0.1))
        .cornerRadius(DesignSystem.CornerRadius.md)
    }
    
    // MARK: - Actions
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            selectedFiles = urls
            importResult = nil
        case .failure(let error):
            importResult = ImportResult(
                success: false,
                message: error.localizedDescription,
                importedCount: 0
            )
        }
    }
    
    private func importFiles() {
        guard !selectedFiles.isEmpty else { return }
        
        var totalImported = 0
        var errorMessages: [String] = []
        
        for url in selectedFiles {
            do {
                switch importType {
                case .sysEx:
                    // Import SysEx file
                    let data = try Data(contentsOf: url)
                    if let program = SysExParser.parseProgramFromSysEx(data) {
                        let preset = viewModel.createPreset(
                            name: url.deletingPathExtension().lastPathComponent,
                            program: program
                        )
                        totalImported += 1
                    }
                case .bank:
                    // Import bank file
                    // Implementation for bank import
                    break
                case .preset:
                    // Import preset file
                    // Implementation for preset import
                    break
                }
            } catch {
                errorMessages.append("\url.lastPathComponent): \error.localizedDescription)")
            }
        }
        
        if totalImported > 0 {
            importResult = ImportResult(
                success: true,
                message: "Successfully imported files",
                importedCount: totalImported
            )
        } else if !errorMessages.isEmpty {
            importResult = ImportResult(
                success: false,
                message: errorMessages.joined(separator: "; "),
                importedCount: 0
            )
        }
        
        viewModel.refreshData()
    }
}

// MARK: - Preview

#Preview {
    ImportView(viewModel: LibrarianViewModel())
        .frame(width: 500, height: 500)
}
