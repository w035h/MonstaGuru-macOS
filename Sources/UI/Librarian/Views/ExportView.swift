// ExportView.swift
// MonstaGuru
// Created by Mistral Vibe Code (Librarian Agent)

import SwiftUI
import UniformTypeIdentifiers
import Data

/// View for exporting presets and banks to files.
public struct ExportView: View {
    
    @Environment(\.
        dismiss) private var dismiss
    @Environment(\.
        modelContainer) private var modelContainer
    
    @ObservedObject public var viewModel: LibrarianViewModel
    
    @State private var exportType: ExportType = .sysEx
    @State private var selectedBank: Bank?
    @State private var selectedPresets: Set<Preset> = []
    @State private var exportURL: URL?
    @State private var isExporting: Bool = false
    @State private var exportResult: ExportResult?
    
    // MARK: - Export Types
    
    public enum ExportType: String, Identifiable, CaseIterable {
        case sysEx = "SysEx File"
        case bank = "Bank File"
        case preset = "Preset File"
        
        public var id: String { rawValue }
    }
    
    // MARK: - Export Result
    
    public struct ExportResult {
        public let success: Bool
        public let message: String
        public let exportedCount: Int
    }
    
    // MARK: - Main View
    
    public var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Header
            Text("Export")
                .font(DesignSystem.Typography.title)
                .foregroundStyle(DesignSystem.Colors.textPrimary)
            
            // Export Type Selection
            Picker("Export Type", selection: $exportType) {
                ForEach(ExportType.allCases, id: \.self) { type in
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
            
            // Selection
            selectionArea
            
            // Result
            if let result = exportResult {
                resultView(result)
            }
            
            // Actions
            HStack(spacing: DesignSystem.Spacing.md) {
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle()
                
                Button("Export") {
                    exportData()
                }
                .buttonStyle(isPrimary: true)
                .disabled(!canExport)
                .keyboardShortcut(.return, modifiers: [])
            }
        }
        .padding(DesignSystem.Spacing.xl)
        .frame(width: 500)
        .fileExporter(
            isPresented: $isExporting,
            document: exportDocument,
            contentType: exportContentType,
            defaultFilename: defaultFilename
        ) { result in
            handleExportResult(result)
        }
    }
    
    // MARK: - Computed Properties
    
    private var description: String {
        switch exportType {
        case .sysEx:
            return "Export as SysEx file for MicroMonsta 2"
        case .bank:
            return "Export bank as JSON file"
        case .preset:
            return "Export individual presets as JSON files"
        }
    }
    
    private var canExport: Bool {
        switch exportType {
        case .sysEx:
            return !selectedPresets.isEmpty
        case .bank:
            return selectedBank != nil || !selectedPresets.isEmpty
        case .preset:
            return !selectedPresets.isEmpty
        }
    }
    
    private var defaultFilename: String {
        switch exportType {
        case .sysEx:
            return "MicroMonsta_Program.syx"
        case .bank:
            return selectedBank?.name ?? "Bank_" + Date().formatted(.dateTime) + ".json"
        case .preset:
            return "Presets_" + Date().formatted(.dateTime) + ".json"
        }
    }
    
    private var exportContentType: UTType {
        switch exportType {
        case .sysEx:
            return .data
        case .bank, .preset:
            return .json
        }
    }
    
    private var exportDocument: ExportDocument? {
        guard canExport else { return nil }
        
        switch exportType {
        case .sysEx:
            if let preset = selectedPresets.first, let program = preset.program {
                if let sysExData = SysExParser.programToSysEx(program: program) {
                    return ExportDocument(data: sysExData, filename: defaultFilename)
                }
            }
        case .bank:
            if let bank = selectedBank {
                return ExportDocument(data: try! JSONEncoder().encode(bank), filename: defaultFilename)
            }
        case .preset:
            let presets = Array(selectedPresets)
            return ExportDocument(data: try! JSONEncoder().encode(presets), filename: defaultFilename)
        }
        return nil
    }
    
    private var selectionArea: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            switch exportType {
            case .sysEx:
                presetSelection
            case .bank:
                bankSelection
            case .preset:
                presetSelection
            }
        }
        .frame(width: 400)
        .cardStyle()
    }
    
    private var bankSelection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Select Bank")
                .font(DesignSystem.Typography.headline)
            
            Picker("Bank", selection: $selectedBank) {
                Text("None").tag(nil as Bank?)
                ForEach(viewModel.banks) { bank in
                    Text(bank.displayName).tag(bank as Bank?)
                }
            }
            .pickerStyle(.menu)
            
            if let bank = selectedBank {
                Text("Presets: \bank.presetCount)")
                    .font(DesignSystem.Typography.bodySmall)
                    .foregroundStyle(DesignSystem.Colors.textTertiary)
            }
        }
    }
    
    private var presetSelection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Select Presets")
                .font(DesignSystem.Typography.headline)
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    ForEach(viewModel.allPresets) { preset in
                        HStack {
                            Checkbox(isChecked: selectedPresets.contains(preset)) {
                                selectedPresets.insert(preset)
                            } onUncheck: {
                                selectedPresets.remove(preset)
                            }
                            
                            Text(preset.displayName)
                                .font(DesignSystem.Typography.bodySmall)
                        }
                        .padding(DesignSystem.Spacing.xs)
                        .background(
                            selectedPresets.contains(preset) ? 
                                DesignSystem.Colors.surfaceHover : 
                                Color.clear
                        )
                        .cornerRadius(DesignSystem.CornerRadius.xs)
                    }
                }
            }
            .frame(height: 200)
            
            Text("Selected: \selectedPresets.count)")
                .font(DesignSystem.Typography.bodySmall)
                .foregroundStyle(DesignSystem.Colors.textTertiary)
        }
    }
    
    private func resultView(_ result: ExportResult) -> some View {
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
            
            if result.exportedCount > 0 {
                Text("Exported: \result.exportedCount) items")
                    .font(DesignSystem.Typography.bodySmall)
                    .foregroundStyle(DesignSystem.Colors.textSecondary)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(result.success ? DesignSystem.Colors.success.opacity(0.1) : DesignSystem.Colors.error.opacity(0.1))
        .cornerRadius(DesignSystem.CornerRadius.md)
    }
    
    // MARK: - Actions
    
    private func exportData() {
        isExporting = true
    }
    
    private func handleExportResult(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            exportResult = ExportResult(
                success: true,
                message: "Exported to: \url.lastPathComponent)",
                exportedCount: exportCount
            )
        case .failure(let error):
            exportResult = ExportResult(
                success: false,
                message: error.localizedDescription,
                exportedCount: 0
            )
        }
    }
    
    private var exportCount: Int {
        switch exportType {
        case .sysEx:
            return 1
        case .bank:
            return selectedBank?.presetCount ?? 0
        case .preset:
            return selectedPresets.count
        }
    }
}

// MARK: - Export Document

private struct ExportDocument: FileExportDocument {
    let data: Data
    let filename: String
    
    init(data: Data, filename: String) {
        self.data = data
        self.filename = filename
    }
    
    func makeIterator() -> Data {
        return data
    }
    
    static var readableContentTypes: [UTType] { [.data, .json] }
}

// MARK: - Checkbox

private struct Checkbox: View {
    let isChecked: Bool
    let onCheck: () -> Void
    let onUncheck: () -> Void
    
    var body: some View {
        Button(action: { isChecked ? onUncheck() : onCheck() }) {
            Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                .foregroundStyle(isChecked ? DesignSystem.Colors.primary : DesignSystem.Colors.textSecondary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    ExportView(viewModel: LibrarianViewModel())
        .frame(width: 500, height: 500)
}
